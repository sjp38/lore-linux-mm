Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id F0EBE6B02B4
	for <linux-mm@kvack.org>; Tue, 23 May 2017 07:32:56 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 139so29015359wmf.5
        for <linux-mm@kvack.org>; Tue, 23 May 2017 04:32:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w19si15408260wra.150.2017.05.23.04.32.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 May 2017 04:32:55 -0700 (PDT)
Subject: Re: [PATCH v2 1/6] mm, page_alloc: fix more premature OOM due to race
 with cpuset update
References: <20170517081140.30654-1-vbabka@suse.cz>
 <20170517081140.30654-2-vbabka@suse.cz>
 <20170519115110.GB29839@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <73475c95-621b-f061-3847-f8cd326bb8db@suse.cz>
Date: Tue, 23 May 2017 13:32:53 +0200
MIME-Version: 1.0
In-Reply-To: <20170519115110.GB29839@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 05/19/2017 01:51 PM, Michal Hocko wrote:
> On Wed 17-05-17 10:11:35, Vlastimil Babka wrote:
>> Commit e47483bca2cc ("mm, page_alloc: fix premature OOM when racing with cpuset
>> mems update") has fixed known recent regressions found by LTP's cpuset01
>> testcase. I have however found that by modifying the testcase to use per-vma
>> mempolicies via bind(2) instead of per-task mempolicies via set_mempolicy(2),
>> the premature OOM still happens and the issue is much older.
>>
>> The root of the problem is that the cpuset's mems_allowed and mempolicy's
>> nodemask can temporarily have no intersection, thus get_page_from_freelist()
>> cannot find any usable zone. The current semantic for empty intersection is to
>> ignore mempolicy's nodemask and honour cpuset restrictions. This is checked in
>> node_zonelist(), but the racy update can happen after we already passed the
>> check. Such races should be protected by the seqlock task->mems_allowed_seq,
>> but it doesn't work here, because 1) mpol_rebind_mm() does not happen under
>> seqlock for write, and doing so would lead to deadlock, as it takes mmap_sem
>> for write, while the allocation can have mmap_sem for read when it's taking the
>> seqlock for read. And 2) the seqlock cookie of callers of node_zonelist()
>> (alloc_pages_vma() and alloc_pages_current()) is different than the one of
>> __alloc_pages_slowpath(), so there's still a potential race window.
>>
>> This patch fixes the issue by having __alloc_pages_slowpath() check for empty
>> intersection of cpuset and ac->nodemask before OOM or allocation failure. If
>> it's indeed empty, the nodemask is ignored and allocation retried, which mimics
>> node_zonelist(). This works fine, because almost all callers of
>> __alloc_pages_nodemask are obtaining the nodemask via node_zonelist(). The only
>> exception is new_node_page() from hotplug, where the potential violation of
>> nodemask isn't an issue, as there's already a fallback allocation attempt
>> without any nodemask. If there's a future caller that needs to have its specific
>> nodemask honoured over task's cpuset restrictions, we'll have to e.g. add a gfp
>> flag for that.
>>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> 
> Do we want this backported to the stable tree?

I'm not aware of any external report and the problem is there for a long
time.

> OK I do agree this makes some sense as a quick and easy to backport
> workaround.

It might not be that straightforward, the __alloc_pages* stuff has been
through a lot of changes recently, and e.g. the handling of
cpuset_mems_cookie has moved to __alloc_pages_slowpath() in the last
version or two.

So I'm not very enthusiastic about stable here.

> Acked-by: Michal Hocko <mhocko@suse.com?

Thanks!

> 
>> ---
>>  mm/page_alloc.c | 51 ++++++++++++++++++++++++++++++++++++++-------------
>>  1 file changed, 38 insertions(+), 13 deletions(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index beb2827fd5de..43aa767c3188 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -3661,6 +3661,39 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
>>  	return false;
>>  }
>>  
>> +static inline bool
>> +check_retry_cpuset(int cpuset_mems_cookie, struct alloc_context *ac)
>> +{
>> +	/*
>> +	 * It's possible that cpuset's mems_allowed and the nodemask from
>> +	 * mempolicy don't intersect. This should be normally dealt with by
>> +	 * policy_nodemask(), but it's possible to race with cpuset update in
>> +	 * such a way the check therein was true, and then it became false
>> +	 * before we got our cpuset_mems_cookie here.
>> +	 * This assumes that for all allocations, ac->nodemask can come only
>> +	 * from MPOL_BIND mempolicy (whose documented semantics is to be ignored
>> +	 * when it does not intersect with the cpuset restrictions) or the
>> +	 * caller can deal with a violated nodemask.
>> +	 */
>> +	if (cpusets_enabled() && ac->nodemask &&
>> +			!cpuset_nodemask_valid_mems_allowed(ac->nodemask)) {
>> +		ac->nodemask = NULL;
>> +		return true;
>> +	}
>> +
>> +	/*
>> +	 * When updating a task's mems_allowed or mempolicy nodemask, it is
>> +	 * possible to race with parallel threads in such a way that our
>> +	 * allocation can fail while the mask is being updated. If we are about
>> +	 * to fail, check if the cpuset changed during allocation and if so,
>> +	 * retry.
>> +	 */
>> +	if (read_mems_allowed_retry(cpuset_mems_cookie))
>> +		return true;
>> +
>> +	return false;
>> +}
>> +
>>  static inline struct page *
>>  __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>>  						struct alloc_context *ac)
>> @@ -3856,11 +3889,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>>  				&compaction_retries))
>>  		goto retry;
>>  
>> -	/*
>> -	 * It's possible we raced with cpuset update so the OOM would be
>> -	 * premature (see below the nopage: label for full explanation).
>> -	 */
>> -	if (read_mems_allowed_retry(cpuset_mems_cookie))
>> +
>> +	/* Deal with possible cpuset update races before we start OOM killing */
>> +	if (check_retry_cpuset(cpuset_mems_cookie, ac))
>>  		goto retry_cpuset;
>>  
>>  	/* Reclaim has failed us, start killing things */
>> @@ -3879,14 +3910,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>>  	}
>>  
>>  nopage:
>> -	/*
>> -	 * When updating a task's mems_allowed or mempolicy nodemask, it is
>> -	 * possible to race with parallel threads in such a way that our
>> -	 * allocation can fail while the mask is being updated. If we are about
>> -	 * to fail, check if the cpuset changed during allocation and if so,
>> -	 * retry.
>> -	 */
>> -	if (read_mems_allowed_retry(cpuset_mems_cookie))
>> +	/* Deal with possible cpuset update races before we fail */
>> +	if (check_retry_cpuset(cpuset_mems_cookie, ac))
>>  		goto retry_cpuset;
>>  
>>  	/*
>> -- 
>> 2.12.2
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
