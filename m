Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 325CD6B0390
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 02:06:33 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u18so5200748wrc.17
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 23:06:33 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p9si34525717wrd.131.2017.04.12.23.06.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Apr 2017 23:06:31 -0700 (PDT)
Subject: Re: [RFC 1/6] mm, page_alloc: fix more premature OOM due to race with
 cpuset update
References: <20170411140609.3787-1-vbabka@suse.cz>
 <20170411140609.3787-2-vbabka@suse.cz>
 <95469f35-56e9-7dc4-b7fd-a3e8c25bdff3@linux.vnet.ibm.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2dbcff3c-f0f1-b568-f98c-519dd98c6e63@suse.cz>
Date: Thu, 13 Apr 2017 08:06:29 +0200
MIME-Version: 1.0
In-Reply-To: <95469f35-56e9-7dc4-b7fd-a3e8c25bdff3@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 04/13/2017 07:42 AM, Anshuman Khandual wrote:
> On 04/11/2017 07:36 PM, Vlastimil Babka wrote:
>> Commit e47483bca2cc ("mm, page_alloc: fix premature OOM when racing with cpuset
>> mems update") has fixed known recent regressions found by LTP's cpuset01
>> testcase. I have however found that by modifying the testcase to use per-vma
>> mempolicies via bind(2) instead of per-task mempolicies via set_mempolicy(2),
>> the premature OOM still happens and the issue is much older.
> 
> Meanwhile while we are discussing this RFC, will it be better to WARN
> out these situations where we dont have node in the intersection,
> hence no usable zone during allocation. That might actually give
> a hint to the user before a premature OOM/allocation failure comes.

Well, the bug is very old and nobody reported it so far, AFAIK. So it's
not that urgent.

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
> 
> Did you really mean node_zonelist() in both the instances above. Because
> that function just picks up either FALLBACK_ZONELIST or NOFALLBACK_ZONELIST
> depending upon the passed GFP flags in the allocation request and does not
> deal with ignoring the passed nodemask.

Oops, I meant policy_zonelist(), thanks for noticing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
