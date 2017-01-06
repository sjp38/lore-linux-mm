Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 63D806B026F
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 16:58:05 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id c69so70158642qkg.1
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 13:58:05 -0800 (PST)
Received: from esa2.cray.iphmx.com (esa2.cray.iphmx.com. [68.232.143.164])
        by mx.google.com with ESMTPS id m30si51009258qtg.333.2017.01.06.13.58.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jan 2017 13:58:04 -0800 (PST)
Date: Fri, 6 Jan 2017 13:57:59 -0800 (PST)
From: Paul Cassella <cassella@cray.com>
Subject: Re: hugetlb: reservation race leading to under provisioning
In-Reply-To: <20170106085808.GE5556@dhcp22.suse.cz>
Message-ID: <alpine.LNX.2.00.1701061128390.9628@rueplumet.us.cray.com>
References: <20170105151540.GT21618@dhcp22.suse.cz> <a46ad76e-2d73-1138-b871-fc110cc9d596@oracle.com> <20170106085808.GE5556@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org

On Fri, 6 Jan 2017, Michal Hocko wrote:
> On Thu 05-01-17 16:48:03, Mike Kravetz wrote:
> > On 01/05/2017 07:15 AM, Michal Hocko wrote:

> > > we have a customer report on an older kernel (3.12) but I believe the
> > > same issue is present in the current vanilla kernel. There is a race
> > > between mmap trying to do a reservation which fails when racing with
> > > truncate_hugepages. See the reproduced attached.
> > > 
> > > It should go like this (analysis come from the customer and I hope I
> > > haven't screwed their write up).

Hi Michal,

There may have been a step missing from what was sent to you, right at the 
point Mike asked about.  I've added it below.


> > > : Task (T1) does mmap and calls into gather_surplus_pages(), looking for N
> > > : pages.  It determines it needs to allocate N pages, drops the lock, and
> > > : does so.
> > > : 
> > > : We will have:
> > > : hstate->resv_huge_pages == N
> > > : hstate->free_huge_pages == N

Note that those N pages are not T1's.  (The test case involves several 
tasks creating files of the same size.)  Those N pages belong to a 
different file that T2 is about to munmap:

> > > : That mapping is then munmap()ed by task T2, which truncates the file:
> > > : 
> > > : truncate_hugepages() {
> > > : 	for each page of the inode after lstart {
> > > : 		truncate_huge_page(page) {
> > > : 			hugetlb_unreserve_pages() {
> > > : 				hugetlb_acct_memory() {
> > > : 					return_unused_surplus_pages() {
> > > : 
> > > : return_unused_surplus_pages() drops h->resv_huge_pages to 0, then
> > > : begins calling free_pool_huge_page() N times:
> > > : 
> > > : 	h->resv_huge_pages -= unused_resv_pages
> > > : 	while (nr_pages--) {
> > > : 		free_pool_huge_page(h, &node_states[N_MEMORY], 1) {
> > > : 			h->free_huge_pages--;
> > > : 		}
> > > : 		cond_resched_lock(&hugetlb_lock);
> > > : 	}
> > > : 
> > > : But the cond_resched_lock() triggers, and it releases the lock with
> > > : 
> > > : h->resv_huge_pages == 0
> > > : h->free_huge_pages == M << N

T2 at this point has freed N-M pages.


> > > : T1 having completed its allocations with allocated == N now
> > > : acquires the lock, and recomputes
> > > : 
> > > : needed = (h->resv_huge_pages + delta) - (h->free_huge_pages + allocated);
> > > : 
> > > : needed = N - (M + N) = -M
> > > : 
> > > : Then
> > > : 
> > > : needed += N                  = -M+N
> > > : h->resv_huge_pages += N       = N
> > > : 
> > > : It frees N-M pages to the hugetlb pool via enqueue_huge_page(),
> > > : 
> > > : list_for_each_entry_safe(page, tmp, &surplus_list, lru) {
> > > : 	if ((--needed) < 0)
> > > : 		break;
> > > : 		/*
> > > : 		* This page is now managed by the hugetlb allocator and has
> > > : 		* no users -- drop the buddy allocator's reference.
> > > : 		*/
> > > : 		put_page_testzero(page);
> > > : 		VM_BUG_ON(page_count(page));
> > > : 		enqueue_huge_page(h, page) {
> > > : 			h->free_huge_pages++;
> > > : 		}
> > > : 	}


> > Are you sure about free_huge_page?

Hi Mike,

There was a step missing here.  You're right at that this point

    h->resv-huge_pages == N
> > h->free_huge_pages == M + (N-M)
                                    == N

Continuing with T1 releasing the lock:

> > > : It releases the lock in order to free the remainder of surplus_list
> > > : via put_page().

When T1 releases the lock, T2 reacquires it and continues its loop in
return_unused_surplus_pages().  It calls free_pool_huge_page() M
more times to go with the N-M it had already done.  Then T2 releases
the lock with

h->resv_huge_pages == N
h->free_huge_pages == N - M

> > > : When it releases the lock, T1 reclaims it and returns from
> > > : gather_surplus_pages().
> > > : 
> > > : But then hugetlb_acct_memory() checks
> > > : 
> > > : 	if (delta > cpuset_mems_nr(h->free_huge_pages_node)) {
> > > : 		return_unused_surplus_pages(h, delta);
> > > : 		goto out;
> > > : 	}
> > > : 
> > > : and returns -ENOMEM.



> > I'm wondering if this may have more to do with numa allocations of
> > surplus pages.  Do you know if customer uses any memory policy for
> > allocations?  There was a change after 3.12 for this (commit 099730d67417).

FWIW, we do have that commit applied for reasons unrelated to this bug.

I had been wondering about the numa aspect, but the test case reproduces 
the problem on a non-numa system with a more recent vanilla kernel.


-- 
Paul Cassella

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
