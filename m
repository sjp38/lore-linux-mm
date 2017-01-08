Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id F0FB86B0069
	for <linux-mm@kvack.org>; Sun,  8 Jan 2017 14:08:42 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id k15so87349293qtg.5
        for <linux-mm@kvack.org>; Sun, 08 Jan 2017 11:08:42 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id y24si10155323qtb.243.2017.01.08.11.08.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Jan 2017 11:08:41 -0800 (PST)
Subject: Re: hugetlb: reservation race leading to under provisioning
References: <20170105151540.GT21618@dhcp22.suse.cz>
 <a46ad76e-2d73-1138-b871-fc110cc9d596@oracle.com>
 <20170106085808.GE5556@dhcp22.suse.cz>
 <alpine.LNX.2.00.1701061128390.9628@rueplumet.us.cray.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <f6f7338c-2afe-885b-4c72-44b7daba07d8@oracle.com>
Date: Sun, 8 Jan 2017 11:08:30 -0800
MIME-Version: 1.0
In-Reply-To: <alpine.LNX.2.00.1701061128390.9628@rueplumet.us.cray.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Cassella <cassella@cray.com>, Michal Hocko <mhocko@kernel.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org

On 01/06/2017 01:57 PM, Paul Cassella wrote:
> On Fri, 6 Jan 2017, Michal Hocko wrote:
>> On Thu 05-01-17 16:48:03, Mike Kravetz wrote:
>>> On 01/05/2017 07:15 AM, Michal Hocko wrote:
> 
>>>> we have a customer report on an older kernel (3.12) but I believe the
>>>> same issue is present in the current vanilla kernel. There is a race
>>>> between mmap trying to do a reservation which fails when racing with
>>>> truncate_hugepages. See the reproduced attached.
>>>>
>>>> It should go like this (analysis come from the customer and I hope I
>>>> haven't screwed their write up).
> 
> Hi Michal,
> 
> There may have been a step missing from what was sent to you, right at the 
> point Mike asked about.  I've added it below.
> 
> 
>>>> : Task (T1) does mmap and calls into gather_surplus_pages(), looking for N
>>>> : pages.  It determines it needs to allocate N pages, drops the lock, and
>>>> : does so.
>>>> : 
>>>> : We will have:
>>>> : hstate->resv_huge_pages == N
>>>> : hstate->free_huge_pages == N
> 
> Note that those N pages are not T1's.  (The test case involves several 
> tasks creating files of the same size.)  Those N pages belong to a 
> different file that T2 is about to munmap:
> 
>>>> : That mapping is then munmap()ed by task T2, which truncates the file:
>>>> : 
>>>> : truncate_hugepages() {
>>>> : 	for each page of the inode after lstart {
>>>> : 		truncate_huge_page(page) {
>>>> : 			hugetlb_unreserve_pages() {
>>>> : 				hugetlb_acct_memory() {
>>>> : 					return_unused_surplus_pages() {
>>>> : 
>>>> : return_unused_surplus_pages() drops h->resv_huge_pages to 0, then
>>>> : begins calling free_pool_huge_page() N times:
>>>> : 
>>>> : 	h->resv_huge_pages -= unused_resv_pages
>>>> : 	while (nr_pages--) {
>>>> : 		free_pool_huge_page(h, &node_states[N_MEMORY], 1) {
>>>> : 			h->free_huge_pages--;
>>>> : 		}
>>>> : 		cond_resched_lock(&hugetlb_lock);
>>>> : 	}
>>>> : 
>>>> : But the cond_resched_lock() triggers, and it releases the lock with
>>>> : 
>>>> : h->resv_huge_pages == 0
>>>> : h->free_huge_pages == M << N
> 
> T2 at this point has freed N-M pages.
> 
> 
>>>> : T1 having completed its allocations with allocated == N now
>>>> : acquires the lock, and recomputes
>>>> : 
>>>> : needed = (h->resv_huge_pages + delta) - (h->free_huge_pages + allocated);
>>>> : 
>>>> : needed = N - (M + N) = -M
>>>> : 
>>>> : Then
>>>> : 
>>>> : needed += N                  = -M+N
>>>> : h->resv_huge_pages += N       = N
>>>> : 
>>>> : It frees N-M pages to the hugetlb pool via enqueue_huge_page(),
>>>> : 
>>>> : list_for_each_entry_safe(page, tmp, &surplus_list, lru) {
>>>> : 	if ((--needed) < 0)
>>>> : 		break;
>>>> : 		/*
>>>> : 		* This page is now managed by the hugetlb allocator and has
>>>> : 		* no users -- drop the buddy allocator's reference.
>>>> : 		*/
>>>> : 		put_page_testzero(page);
>>>> : 		VM_BUG_ON(page_count(page));
>>>> : 		enqueue_huge_page(h, page) {
>>>> : 			h->free_huge_pages++;
>>>> : 		}
>>>> : 	}
> 
> 
>>> Are you sure about free_huge_page?
> 
> Hi Mike,
> 
> There was a step missing here.  You're right at that this point
> 
>     h->resv-huge_pages == N
>>> h->free_huge_pages == M + (N-M)
>                                     == N
> 
> Continuing with T1 releasing the lock:
> 
>>>> : It releases the lock in order to free the remainder of surplus_list
>>>> : via put_page().
> 
> When T1 releases the lock, T2 reacquires it and continues its loop in
> return_unused_surplus_pages().  It calls free_pool_huge_page() M
> more times to go with the N-M it had already done.  Then T2 releases
> the lock with
> 
> h->resv_huge_pages == N
> h->free_huge_pages == N - M
> 
>>>> : When it releases the lock, T1 reclaims it and returns from
>>>> : gather_surplus_pages().
>>>> : 
>>>> : But then hugetlb_acct_memory() checks
>>>> : 
>>>> : 	if (delta > cpuset_mems_nr(h->free_huge_pages_node)) {
>>>> : 		return_unused_surplus_pages(h, delta);
>>>> : 		goto out;
>>>> : 	}
>>>> : 
>>>> : and returns -ENOMEM.
> 
> 
> 
>>> I'm wondering if this may have more to do with numa allocations of
>>> surplus pages.  Do you know if customer uses any memory policy for
>>> allocations?  There was a change after 3.12 for this (commit 099730d67417).
> 
> FWIW, we do have that commit applied for reasons unrelated to this bug.
> 
> I had been wondering about the numa aspect, but the test case reproduces 
> the problem on a non-numa system with a more recent vanilla kernel.

Thanks for the additional information Paul.

I had to think about it a lot, but agree that the cond_resched_lock added
to return_unused_surplus_pages in commit 7848a4bf51b3.  As noted, the
routine first decrements resv_huge_pages by unused_resv_pages and then
frees surplus pages one by one while potentially dropping the hugetlb_lock
between calls to free pages.  Also note that these surplus pages are
counted as free pages, so they can be used by anyone else.  The only thing
that prevents them from being taken by others is the reservation count
(resv_huge_pages).

If the lock is dropped before freeing all the surplus pages, another task
(such as T1 in this case) can use the pages for it's own proposes.  In the
case of T1, it uses the pages to back the reservation associated with a
mmap call.  Note that one of the rules/assumptions is that the count
free_huge_pages must be greater than or equal to resv_huge_pages.

There is technically no problem with another task (such as T1) using the
free surplus pages.  The problem happens when return_unused_surplus_pages
reacquires the lock and continues to free surplus huge pages.  It does not
know (or take into account) that another task may have claimed the pages.

There are a couple ways to address this issue.  As Michal points out, we
could just revert 7848a4bf51b3.  But, that was added for a reason so we
would reintroduce the soft lockup issue it was trying to fix.  Another
approach is to have return_unused_surplus_pages decrement the resv_huge_pages
as it frees the surplus pages.  Michal's patch to do this did not always
decrement resv_huge_pages as it should.  A fixed up version of Michal's patch
would be something like the following (untested):

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3edb759..221abdc 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1783,12 +1783,9 @@ static void return_unused_surplus_pages(struct hstate *h,
 {
 	unsigned long nr_pages;
 
-	/* Uncommit the reservation */
-	h->resv_huge_pages -= unused_resv_pages;
-
 	/* Cannot return gigantic pages currently */
 	if (hstate_is_gigantic(h))
-		return;
+		goto out;
 
 	nr_pages = min(unused_resv_pages, h->surplus_huge_pages);
 
@@ -1801,10 +1798,16 @@ static void return_unused_surplus_pages(struct hstate *h,
 	 * on-line nodes with memory and will handle the hstate accounting.
 	 */
 	while (nr_pages--) {
+		h->resv_huge_pages--;
+		unused_resv_pages--;
 		if (!free_pool_huge_page(h, &node_states[N_MEMORY], 1))
-			break;
+			goto out;
 		cond_resched_lock(&hugetlb_lock);
 	}
+
+out:
+	/* Fully uncommit the reservation */
+	h->resv_huge_pages -= unused_resv_pages;
 }

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
