Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id D6E118E0002
	for <linux-mm@kvack.org>; Mon, 31 Dec 2018 19:44:36 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id r131so19770755oia.7
        for <linux-mm@kvack.org>; Mon, 31 Dec 2018 16:44:36 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s7sor18849967oic.155.2018.12.31.16.44.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 31 Dec 2018 16:44:35 -0800 (PST)
Date: Mon, 31 Dec 2018 16:44:24 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v3 2/2] mm: rid swapoff of quadratic complexity
In-Reply-To: <20181203170934.16512-2-vpillai@digitalocean.com>
Message-ID: <alpine.LSU.2.11.1812311635590.4106@eggly.anvils>
References: <20181203170934.16512-1-vpillai@digitalocean.com> <20181203170934.16512-2-vpillai@digitalocean.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineeth Remanan Pillai <vpillai@digitalocean.com>
Cc: Matthew Wilcox <willy@infradead.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kelley Nielsen <kelleynnn@gmail.com>, Rik van Riel <riel@surriel.com>

On Mon, 3 Dec 2018, Vineeth Remanan Pillai wrote:

> This patch was initially posted by Kelley(kelleynnn@gmail.com).
> Reposting the patch with all review comments addressed and with minor
> modifications and optimizations. Tests were rerun and commit message
> updated with new results.
> 
> The function try_to_unuse() is of quadratic complexity, with a lot of
> wasted effort. It unuses swap entries one by one, potentially iterating
> over all the page tables for all the processes in the system for each
> one.
> 
> This new proposed implementation of try_to_unuse simplifies its
> complexity to linear. It iterates over the system's mms once, unusing
> all the affected entries as it walks each set of page tables. It also
> makes similar changes to shmem_unuse.

Hi Vineeth, please fold in fixes below before reposting your
"mm,swap: rid swapoff of quadratic complexity" patch -
or ask for more detail if unclear.  I could split it up,
of course, but since they should all (except perhaps one)
just be merged into the base patch before going any further,
it'll save me time to keep them together here and just explain:-

shmem_unuse_swap_entries():
If a user fault races with swapoff, it's very normal for
shmem_swapin_page() to return -EEXIST, and the old code was
careful not to pass back any error but -ENOMEM; whereas on mmotm,
/usr/sbin/swapoff often failed silently because it got that EEXIST.

shmem_unuse():
A couple of crashing bugs there: a list_del_init without holding the
mutex, and too much faith in the "safe" in list_for_each_entry_safe():
it does assume that the mutex has been held throughout, you (very
nicely!) drop it, but that does require "next" to be re-evaluated.

shmem_writepage():
Not a bug fix, this is the "except perhaps one": minor optimization,
could be left out, but if shmem_unuse() is going through the list
in the forward direction, and may completely unswap a file and del
it from the list, then pages from that file can be swapped out to
*other* swap areas after that, and it be reinserted in the list:
better to reinsert it behind shmem_unuse()'s cursor than in front
of it, which would entail a second pointless pass over that file.

try_to_unuse():
Moved up the assignment of "oldi = i" (and changed the test to
"oldi <= i"), so as not to get trapped in that find_next_to_unuse()
loop when find_get_page() does not find it.

try_to_unuse():
But the main problem was passing entry.val to find_get_page() there:
that used to be correct, but since f6ab1f7f6b2d we need to pass just
the offset - as it stood, it could only find the pages when swapping
off area 0 (a similar issue was fixed in shmem_replace_page() recently).
That (together with the late oldi assignment) was why my swapoffs were
hanging on SWAP_HAS_CACHE swap_map entries.

With those changes, it all seems to work rather well, and is a nice
simplification of the source, in addition to removing the quadratic
complexity. To my great surprise, the KSM pages are already handled
fairly well - the ksm_might_need_to_copy() that has long been in
unuse_pte() turns out to do (almost) a good enough job already,
so most users of KSM and swapoff would never see any problem.
And I'd been afraid of swapin readahead causing spurious -ENOMEMs,
but have seen nothing of that in practice (though something else
in mmotm does appear to use up more memory than before).

My remaining criticisms would be:

As Huang Ying pointed out in other mail, there is a danger of
livelock (or rather, hitting the MAX_RETRIES limit) when a multiply
mapped page (most especially a KSM page, whose mappings are not
likely to be nearby in the mmlist) is swapped out then partially
swapped off then some ptes swapped back out.  As indeed the
"Under global memory pressure" comment admits.

I have hit the MAX_RETRIES 3 limit several times in load testing,
not investigated but I presume due to such a multiply mapped page,
so at present we do have a regression there.  A very simple answer
would be to remove the retries limiting - perhaps you just added
that to get around the find_get_page() failure before it was
understood?  That does then tend towards the livelock alternative,
but you've kept the signal_pending() check, so there's still the
same way out as the old technique had (but greater likelihood of
needing it with the new technique).  The right fix will be to do
an rmap walk to unuse all the swap entries of a single anon_vma
while holding page lock (with KSM needing that page force-deleted
from swap cache before moving on); but none of us have written
that code yet, maybe just removing the retries limit good enough.

Two dislikes on the code structure, probably one solution: the
"goto retry", up two levels from inside the lower loop, is easy to
misunderstand; and the oldi business is ugly - find_next_to_unuse()
was written to wrap around continuously to suit the old loop, but
now it's left with its "++i >= max" code to achieve that, then your
"i <= oldi" code to detect when it did, to undo that again: please
delete code from both ends to make that all simpler.

I'd expect to see checks on inuse_pages in some places, to terminate
the scans as soon as possible (swapoff of an unused swapfile should
be very quick, shouldn't it? not requiring any scans at all); but it
looks like the old code did not have those either - was inuse_pages
unreliable once upon a time? is it unreliable now?

Hugh

---

 mm/shmem.c    |   12 ++++++++----
 mm/swapfile.c |    8 ++++----
 2 files changed, 12 insertions(+), 8 deletions(-)

--- mmotm/mm/shmem.c	2018-12-22 13:32:51.339584848 -0800
+++ linux/mm/shmem.c	2018-12-31 12:30:55.822407154 -0800
@@ -1149,6 +1149,7 @@ static int shmem_unuse_swap_entries(stru
 		}
 		if (error == -ENOMEM)
 			break;
+		error = 0;
 	}
 	return error;
 }
@@ -1216,12 +1217,15 @@ int shmem_unuse(unsigned int type)
 		mutex_unlock(&shmem_swaplist_mutex);
 		if (prev_inode)
 			iput(prev_inode);
+		prev_inode = inode;
+
 		error = shmem_unuse_inode(inode, type);
-		if (!info->swapped)
-			list_del_init(&info->swaplist);
 		cond_resched();
-		prev_inode = inode;
+
 		mutex_lock(&shmem_swaplist_mutex);
+		next = list_next_entry(info, swaplist);
+		if (!info->swapped)
+			list_del_init(&info->swaplist);
 		if (error)
 			break;
 	}
@@ -1313,7 +1317,7 @@ static int shmem_writepage(struct page *
 	 */
 	mutex_lock(&shmem_swaplist_mutex);
 	if (list_empty(&info->swaplist))
-		list_add_tail(&info->swaplist, &shmem_swaplist);
+		list_add(&info->swaplist, &shmem_swaplist);
 
 	if (add_to_swap_cache(page, swap, GFP_ATOMIC) == 0) {
 		spin_lock_irq(&info->lock);
diff -purN mmotm/mm/swapfile.c linux/mm/swapfile.c
--- mmotm/mm/swapfile.c	2018-12-22 13:32:51.347584880 -0800
+++ linux/mm/swapfile.c	2018-12-31 12:30:55.822407154 -0800
@@ -2156,7 +2156,7 @@ retry:
 
 	while ((i = find_next_to_unuse(si, i, frontswap)) != 0) {
 		/*
-		 * under global memory pressure, swap entries
+		 * Under global memory pressure, swap entries
 		 * can be reinserted back into process space
 		 * after the mmlist loop above passes over them.
 		 * This loop will then repeat fruitlessly,
@@ -2164,7 +2164,7 @@ retry:
 		 * but doing nothing to actually free up the swap.
 		 * In this case, go over the mmlist loop again.
 		 */
-		if (i < oldi) {
+		if (i <= oldi) {
 			retries++;
 			if (retries > MAX_RETRIES) {
 				retval = -EBUSY;
@@ -2172,8 +2172,9 @@ retry:
 			}
 			goto retry;
 		}
+		oldi = i;
 		entry = swp_entry(type, i);
-		page = find_get_page(swap_address_space(entry), entry.val);
+		page = find_get_page(swap_address_space(entry), i);
 		if (!page)
 			continue;
 
@@ -2188,7 +2189,6 @@ retry:
 		try_to_free_swap(page);
 		unlock_page(page);
 		put_page(page);
-		oldi = i;
 	}
 out:
 	return retval;
