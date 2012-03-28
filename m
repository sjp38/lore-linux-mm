Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id A6A6A6B0117
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 13:38:49 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 28 Mar 2012 17:30:14 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q2SHWZHx3473636
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 04:32:35 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q2SHciYS004477
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 04:38:44 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V4 08/10] hugetlbfs: Add a list for tracking in-use HugeTLB pages
In-Reply-To: <20120328135845.GH20949@tiehlicka.suse.cz>
References: <1331919570-2264-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1331919570-2264-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120328135845.GH20949@tiehlicka.suse.cz>User-Agent: Notmuch/0.11.1+346~g13d19c3 (http://notmuchmail.org) Emacs/23.3.1 (x86_64-pc-linux-gnu)
Date: Wed, 28 Mar 2012 23:08:34 +0530
Message-ID: <87vclo1v8l.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

Michal Hocko <mhocko@suse.cz> writes:

> On Fri 16-03-12 23:09:28, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> hugepage_activelist will be used to track currently used HugeTLB pages.
>> We need to find the in-use HugeTLB pages to support memcg removal.
>> On memcg removal we update the page's memory cgroup to point to
>> parent cgroup.
>> 
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>> ---
>>  include/linux/hugetlb.h |    1 +
>>  mm/hugetlb.c            |   23 ++++++++++++++++++-----
>>  2 files changed, 19 insertions(+), 5 deletions(-)
>> 
>> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
>> index cbd8dc5..6919100 100644
>> --- a/include/linux/hugetlb.h
>> +++ b/include/linux/hugetlb.h
> [...]
>> @@ -2319,14 +2322,24 @@ void __unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
>>  		page = pte_page(pte);
>>  		if (pte_dirty(pte))
>>  			set_page_dirty(page);
>> -		list_add(&page->lru, &page_list);
>> +
>> +		spin_lock(&hugetlb_lock);
>> +		list_move(&page->lru, &page_list);
>> +		spin_unlock(&hugetlb_lock);
>
> Why do we really need the spinlock here?


It does a list_del from hugepage_activelist.


>
>>  	}
>>  	spin_unlock(&mm->page_table_lock);
>>  	flush_tlb_range(vma, start, end);
>>  	mmu_notifier_invalidate_range_end(mm, start, end);
>>  	list_for_each_entry_safe(page, tmp, &page_list, lru) {
>>  		page_remove_rmap(page);
>> -		list_del(&page->lru);
>> +		/*
>> +		 * We need to move it back huge page active list. If we are
>> +		 * holding the last reference, below put_page will move it
>> +		 * back to free list.
>> +		 */
>> +		spin_lock(&hugetlb_lock);
>> +		list_move(&page->lru, &h->hugepage_activelist);
>> +		spin_unlock(&hugetlb_lock);
>
> This spinlock usage doesn't look nice but I guess we do not have many
> other options.
>

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
