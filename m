Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 4FACD6B0031
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 05:18:27 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 5 Sep 2013 19:06:58 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id DEA3E2CE804D
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 19:18:22 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r85927Tt57999420
	for <linux-mm@kvack.org>; Thu, 5 Sep 2013 19:02:07 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r859ILtM025735
	for <linux-mm@kvack.org>; Thu, 5 Sep 2013 19:18:22 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] hugetlbfs: support split page table lock
In-Reply-To: <1378312330-afoa3r2y-mutt-n-horiguchi@ah.jp.nec.com>
References: <1377883120-5280-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1377883120-5280-2-git-send-email-n-horiguchi@ah.jp.nec.com> <87li3dvz3k.fsf@linux.vnet.ibm.com> <1378312330-afoa3r2y-mutt-n-horiguchi@ah.jp.nec.com>
Date: Thu, 05 Sep 2013 14:48:18 +0530
Message-ID: <87d2onwrs5.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, kirill.shutemov@linux.intel.com, Alex Thorlton <athorlton@sgi.com>, linux-kernel@vger.kernel.org

Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:

> Hi Aneesh,
>
> On Wed, Sep 04, 2013 at 12:43:19PM +0530, Aneesh Kumar K.V wrote:
>> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:
>> 
>> > Currently all of page table handling by hugetlbfs code are done under
>> > mm->page_table_lock. So when a process have many threads and they heavily
>> > access to the memory, lock contention happens and impacts the performance.
>> >
>> > This patch makes hugepage support split page table lock so that we use
>> > page->ptl of the leaf node of page table tree which is pte for normal pages
>> > but can be pmd and/or pud for hugepages of some architectures.
>> >
>> > ChangeLog v2:
>> >  - add split ptl on other archs missed in v1
>> >
>> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> > ---
>> >  arch/powerpc/mm/hugetlbpage.c |  6 ++-
>> >  arch/tile/mm/hugetlbpage.c    |  6 ++-
>> >  include/linux/hugetlb.h       | 20 ++++++++++
>> >  mm/hugetlb.c                  | 92 ++++++++++++++++++++++++++-----------------
>> >  mm/mempolicy.c                |  5 ++-
>> >  mm/migrate.c                  |  4 +-
>> >  mm/rmap.c                     |  2 +-
>> >  7 files changed, 90 insertions(+), 45 deletions(-)
>> >
>> > diff --git v3.11-rc3.orig/arch/powerpc/mm/hugetlbpage.c v3.11-rc3/arch/powerpc/mm/hugetlbpage.c
>> > index d67db4b..7e56cb7 100644
>> > --- v3.11-rc3.orig/arch/powerpc/mm/hugetlbpage.c
>> > +++ v3.11-rc3/arch/powerpc/mm/hugetlbpage.c
>> > @@ -124,6 +124,7 @@ static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
>> >  {
>> >  	struct kmem_cache *cachep;
>> >  	pte_t *new;
>> > +	spinlock_t *ptl;
>> >
>> >  #ifdef CONFIG_PPC_FSL_BOOK3E
>> >  	int i;
>> > @@ -141,7 +142,8 @@ static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
>> >  	if (! new)
>> >  		return -ENOMEM;
>> >
>> > -	spin_lock(&mm->page_table_lock);
>> > +	ptl = huge_pte_lockptr(mm, new);
>> > +	spin_lock(ptl);
>> 
>> 
>> Are you sure we can do that for ppc ?
>> 	new = kmem_cache_zalloc(cachep, GFP_KERNEL|__GFP_REPEAT);
>
> Ah, thanks. new is not a pointer to one full page occupied by page
> table entries, so trying to use struct page of it is totally wrong.
>
>> The page for new(pte_t) could be shared right ? which mean a deadlock ?
>
> Yes, that's disastrous.
>
>> May be you should do it at the pmd level itself for ppc

The pgd page also cannot be used because pgd also comes from kmem
cache.

>
> Yes, that's possible, but I simply drop the changes in __hugepte_alloc()
> for now because this lock seems to protect us from the race between concurrent
> calls of __hugepte_alloc(), not between allocation and read/write access.
> Split ptl is used to avoid race between read/write accesses, so I think
> that using different types of locks here is not dangerous.
> # I guess that that's why we now use mm->page_table_lock for __pte_alloc()
> # and its family even if USE_SPLIT_PTLOCKS is true.

A simpler approach could be to make huge_pte_lockptr arch
specific and leave it as mm->page_table_lock for ppc 


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
