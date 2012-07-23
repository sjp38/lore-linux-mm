Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id BBF346B005A
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 00:05:19 -0400 (EDT)
Received: by yhr47 with SMTP id 47so6234619yhr.14
        for <linux-mm@kvack.org>; Sun, 22 Jul 2012 21:05:18 -0700 (PDT)
Date: Sun, 22 Jul 2012 21:04:33 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH -alternative] mm: hugetlbfs: Close race during teardown
 of hugetlbfs shared page tables V2 (resend)
In-Reply-To: <20120720145121.GJ9222@suse.de>
Message-ID: <alpine.LSU.2.00.1207222033030.6810@eggly.anvils>
References: <20120720134937.GG9222@suse.de> <20120720141108.GH9222@suse.de> <20120720143635.GE12434@tiehlicka.suse.cz> <20120720145121.GJ9222@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, 20 Jul 2012, Mel Gorman wrote:
> On Fri, Jul 20, 2012 at 04:36:35PM +0200, Michal Hocko wrote:
> > And here is my attempt for the fix (Hugh mentioned something similar
> > earlier but he suggested using special flags in ptes or VMAs). I still
> > owe doc. update and it hasn't been tested with too many configs and I
> > could missed some definition updates.
> > I also think that changelog could be much better, I will add (steal) the
> > full bug description if people think that this way is worth going rather
> > than the one suggested by Mel.
> > To be honest I am not quite happy how I had to pollute generic mm code with
> > something that is specific to a single architecture.
> > Mel hammered it with the test case and it survived.
> 
> Tested-by: Mel Gorman <mgorman@suse.de>
> 
> This approach looks more or less like what I was expecting. I like that
> the trick was applied to the page table page instead of using PTE tricks
> or by bodging it with a VMA flag like I was thinking so kudos for that. I
> also prefer this approach to trying to free the page tables on or near
> huge_pmd_unshare()
> 
> In general I think this patch would execute better than mine because it is
> far less heavy-handed but I share your concern that it changes the core MM
> quite a bit for a corner case that only one architecture cares about. I am
> completely biased of course, but I still prefer my patch because other than
> an API change it keeps the bulk of the madness in arch/x86/mm/hugetlbpage.c
> . I am also not concerned with the scalability of how quickly we can setup
> page table sharing.
> 
> Hugh, I'm afraid you get to choose :)

Thank you bestowing that honour upon me :)  Seriously, though, you
were quite right to Cc me on this, it is one of those areas I ought
to know something about (unlike hugetlb reservations, for example).

Please don't be upset if I say that I don't like either of your patches.
Mainly for obvious reasons - I don't like Mel's because anything with
trylock retries and nested spinlocks worries me before I can even start
to think about it; and I don't like Michal's for the same reason as Mel,
that it spreads more change around in common paths than we would like.

But I didn't spend much time thinking through either of them, they just
seemed more complicated than should be needed.  I cannot confirm or deny
whether they're correct - though I still do not understand how mmap_sem
can help you, Mel.  I can see that it will help in your shmdt()ing test,
but if you leave the area mapped on exit, then mmap_sem is not taken in
the exit_mmap() path, so how does it help?

I spent hours trying to dream up a better patch, trying various
approaches.  I think I have a nice one now, what do you think?  And
more importantly, does it work?  I have not tried to test it at all,
that I'm hoping to leave to you, I'm sure you'll attack it with gusto!

If you like it, please take it over and add your comments and signoff
and send it in.  The second part won't come up in your testing, and could
be made a separate patch if you prefer: it's a related point that struck
me while I was playing with a different approach.

I'm sorely tempted to leave a dangerous pair of eyes off the Cc,
but that too would be unfair.

Subject-to-your-testing-
Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/hugetlb.c |   18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

--- v3.5/mm/hugetlb.c	2012-07-21 13:58:29.000000000 -0700
+++ linux/mm/hugetlb.c	2012-07-22 20:28:59.858077817 -0700
@@ -2393,6 +2393,15 @@ void unmap_hugepage_range(struct vm_area
 {
 	mutex_lock(&vma->vm_file->f_mapping->i_mmap_mutex);
 	__unmap_hugepage_range(vma, start, end, ref_page);
+	/*
+	 * Clear this flag so that x86's huge_pmd_share page_table_shareable
+	 * test will fail on a vma being torn down, and not grab a page table
+	 * on its way out.  We're lucky that the flag has such an appropriate
+	 * name, and can in fact be safely cleared here.  We could clear it
+	 * before the __unmap_hugepage_range above, but all that's necessary
+	 * is to clear it before releasing the i_mmap_mutex below.
+	 */
+	vma->vm_flags &= ~VM_MAYSHARE;
 	mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
 }
 
@@ -2959,9 +2968,14 @@ void hugetlb_change_protection(struct vm
 		}
 	}
 	spin_unlock(&mm->page_table_lock);
-	mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
-
+	/*
+	 * Must flush TLB before releasing i_mmap_mutex: x86's huge_pmd_unshare
+	 * may have cleared our pud entry and done put_page on the page table:
+	 * once we release i_mmap_mutex, another task can do the final put_page
+	 * and that page table be reused and filled with junk.
+	 */
 	flush_tlb_range(vma, start, end);
+	mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
 }
 
 int hugetlb_reserve_pages(struct inode *inode,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
