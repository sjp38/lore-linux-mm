Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 631CB6B00F4
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 07:36:09 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 28 Mar 2012 11:18:35 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2SBTkKd3694632
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 22:29:46 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2SBZs5T019441
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 22:35:55 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V4 02/10] hugetlbfs: don't use ERR_PTR with VM_FAULT* values
In-Reply-To: <20120328092547.GC20949@tiehlicka.suse.cz>
References: <1331919570-2264-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1331919570-2264-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120328092547.GC20949@tiehlicka.suse.cz>User-Agent: Notmuch/0.11.1+346~g13d19c3 (http://notmuchmail.org) Emacs/23.3.1 (x86_64-pc-linux-gnu)
Date: Wed, 28 Mar 2012 17:05:49 +0530
Message-ID: <87vclpyn3e.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

Michal Hocko <mhocko@suse.cz> writes:

> On Fri 16-03-12 23:09:22, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> Using VM_FAULT_* codes with ERR_PTR will require us to make sure
>> VM_FAULT_* values will not exceed MAX_ERRNO value.
>> 
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>> ---
>>  mm/hugetlb.c |   18 +++++++++++++-----
>>  1 files changed, 13 insertions(+), 5 deletions(-)
>> 
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index d623e71..3782da8 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
> [...]
>> @@ -1047,7 +1047,7 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
>>  		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
>>  		if (!page) {
>>  			hugetlb_put_quota(inode->i_mapping, chg);
>> -			return ERR_PTR(-VM_FAULT_SIGBUS);
>> +			return ERR_PTR(-ENOSPC);
>
> Hmm, so one error code abuse replaced by another?
> I know that ENOMEM would revert 4a6018f7 which would be unfortunate but
> ENOSPC doesn't feel right as well.
>

File systems do map ENOSPC to SIGBUS. block_page_mkwrite_return() does
that.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
