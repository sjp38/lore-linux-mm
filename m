Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id EFD516B0044
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 23:18:58 -0500 (EST)
Date: Wed, 5 Dec 2012 13:18:55 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC v2] Support volatile range for anon vma
Message-ID: <20121205041855.GB9782@blaptop>
References: <1351560594-18366-1-git-send-email-minchan@kernel.org>
 <50AD739A.30804@linaro.org>
 <50B6E1F9.5010301@linaro.org>
 <20121204000042.GB20395@bbox>
 <50BD4A70.9060506@linaro.org>
 <20121204072207.GA9782@blaptop>
 <50BE4B64.6000003@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50BE4B64.6000003@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Tue, Dec 04, 2012 at 11:13:40AM -0800, John Stultz wrote:
> On 12/03/2012 11:22 PM, Minchan Kim wrote:
> >On Mon, Dec 03, 2012 at 04:57:20PM -0800, John Stultz wrote:
> >>On 12/03/2012 04:00 PM, Minchan Kim wrote:
> >>>On Wed, Nov 28, 2012 at 08:18:01PM -0800, John Stultz wrote:
> >>>>On 11/21/2012 04:36 PM, John Stultz wrote:
> >>>>>2) Being able to use this with tmpfs files. I'm currently trying
> >>>>>to better understand the rmap code, looking to see if there's a
> >>>>>way to have try_to_unmap_file() work similarly to
> >>>>>try_to_unmap_anon(), to allow allow users to madvise() on mmapped
> >>>>>tmpfs files. This would provide a very similar interface as to
> >>>>>what I've been proposing with fadvise/fallocate, but just using
> >>>>>process virtual addresses instead of (fd, offset) pairs.   The
> >>>>>benefit with (fd,offset) pairs for Android is that its easier to
> >>>>>manage shared volatile ranges between two processes that are
> >>>>>sharing data via an mmapped tmpfs file (although this actual use
> >>>>>case may be fairly rare).  I believe we should still be able to
> >>>>>rework the ashmem internals to use madvise (which would provide
> >>>>>legacy support for existing android apps), so then its just a
> >>>>>question of if we could then eventually convince Android apps to
> >>>>>use the madvise interface directly, rather then the ashmem unpin
> >>>>>ioctl.
> >>>>Hey Minchan,
> >>>>     I've been playing around with your patch trying to better
> >>>>understand your approach and to extend it to support tmpfs files. In
> >>>>doing so I've found a few bugs, and have some rough fixes I wanted
> >>>>to share. There's still a few edge cases I need to deal with (the
> >>>>vma-purged flag isn't being properly handled through vma merge/split
> >>>>operations), but its starting to come along.
> >>>Hmm, my patch doesn't allow to merge volatile with another one by
> >>>inserting VM_VOLATILE into VM_SPECIAL so I guess merge isn't problem.
> >>>In case of split, __split_vma copy old vma to new vma like this
> >>>
> >>>         *new = *vma;
> >>>
> >>>So the problem shouldn't happen, I guess.
> >>>Did you see the real problem about that?
> >>Yes, depending on the pattern that MADV_VOLATILE and MADV_NOVOLATILE
> >>is applied, we can get a result where data is purged, but we aren't
> >>notified of it.  Also, since madvise returns early if it encounters
> >>an error, in the case where you have checkerboard volatile regions
> >>(say every other page is volatile), which you mark non-volatile with
> >>one large MADV_NOVOLATILE call, the first volatile vma will be
> >>marked non-volatile, but since it returns purged, the madvise loop
> >>will stop and the following volatile regions will be left volatile.
> >>
> >>The patches in the git tree below which handle the perged state
> >>better seem to work for my tests, as far as resolving any
> >>overlapping calls. Of course there may yet still be problems I've
> >>not found.
> >>
> >>>>Anyway, take a look at the tree here and let me know what you think.
> >>>>http://git.linaro.org/gitweb?p=people/jstultz/android-dev.git;a=shortlog;h=refs/heads/dev/minchan-anonvol
> >>Eager to hear what you think!
> >Below two patches look good to me.
> >
> >[rmap: Simplify volatility checking by moving it out of try_to_unmap_one]
> >[rmap: ClearPageDirty() when returning SWAP_DISCARD]
> >
> >[madvise: Fix NOVOLATILE bug]
> >I can't understand description of the patch.
> >Could you elaborate it with example?
> The case I ran into here is if you have a range where you mark every
> other page as volatile. Then mark all the pages in that range as
> non-volatile in one madvise call.
> 
> sys_madvise() will then find the first vma in the range, and call
> madvise_vma(), which marks the first vma non-volatile and return the
> purged state.  If the page has been purged, sys_madvise code will
> note that as an error, and break out of the vma iteration loop,
> leaving the following vmas in the range volatile.
> 
> >[madvise: Fixup vma->purged handling]
> >I included VM_VOLATILE into VM_SPECIAL intentionally.
> >If comment of VM_SPECIAL is right, merge with volatile vmas shouldn't happen.
> >So I guess you see other problem. When I see my source code today, locking
> >scheme/purge handling is totally broken. I will look at it. Maybe you are seeing
> >bug related that. Part of patch is needed. It could be separate patch.
> >I will merge it.
> I don't think the problem is when vmas being marked VM_VOLATILE are
> being merged, its that when we mark the vma as *non-volatile*, and
> remove the VM_VOLATILE flag we merge the non-volatile vmas with
> neighboring vmas. So preserving the purged flag during that merge is
> important. Again, the example I used to trigger this was an
> alternating pattern of volatile and non volatile vmas, then marking
> the entire range non-volatile (though sometimes in two overlapping
> passes).

Understood. Thanks.
Below patch solves your problems? It's simple than yours.
Anyway, both yours and mine are not right fix.
As I mentioned, locking scheme is broken.
We need anon_vma_lock to handle purged and we should consider fork
case, too.

diff --git a/mm/madvise.c b/mm/madvise.c
index 965a53d..5fa3254 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -41,7 +41,8 @@ static int madvise_need_mmap_write(int behavior)
  */
 static long madvise_behavior(struct vm_area_struct * vma,
 		     struct vm_area_struct **prev,
-		     unsigned long start, unsigned long end, int behavior)
+		     unsigned long start, unsigned long end,
+		     int behavior, bool *purged)
 {
 	struct mm_struct * mm = vma->vm_mm;
 	int error = 0;
@@ -151,7 +152,7 @@ success:
 		volatile_lock(vma);
 	vma->vm_flags = new_flags;
 	if (behavior == MADV_NOVOLATILE) {
-		error = vma->purged;
+		*purged |= vma->purged;
 		vma->purged = false;
 	}
 	if (behavior == MADV_NOVOLATILE || behavior == MADV_VOLATILE)
@@ -309,7 +310,7 @@ static int madvise_hwpoison(int bhv, unsigned long start, unsigned long end)
 
 static long
 madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
-		unsigned long start, unsigned long end, int behavior)
+	unsigned long start, unsigned long end, int behavior, bool *purged)
 {
 	switch (behavior) {
 	case MADV_REMOVE:
@@ -319,7 +320,7 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	case MADV_DONTNEED:
 		return madvise_dontneed(vma, prev, start, end);
 	default:
-		return madvise_behavior(vma, prev, start, end, behavior);
+		return madvise_behavior(vma, prev, start, end, behavior, purged);
 	}
 }
 
@@ -405,6 +406,7 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 	int error = -EINVAL;
 	int write;
 	size_t len;
+	bool purged = false;
 
 #ifdef CONFIG_MEMORY_FAILURE
 	if (behavior == MADV_HWPOISON || behavior == MADV_SOFT_OFFLINE)
@@ -468,7 +470,7 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 			tmp = end;
 
 		/* Here vma->vm_start <= start < tmp <= (end|vma->vm_end). */
-		error = madvise_vma(vma, &prev, start, tmp, behavior);
+		error = madvise_vma(vma, &prev, start, tmp, behavior, &purged);
 		if (error)
 			goto out;
 		start = tmp;
@@ -488,5 +490,7 @@ out:
 	else
 		up_read(&current->mm->mmap_sem);
 
+	if (!error & purged)
+		error = 1;
 	return error;
 }
> 
> thanks
> -john
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
