Date: Fri, 7 Dec 2001 01:45:04 -0500
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: [steiner@sgi.com: Re: TLB flushing in 2.4.14]
Message-ID: <20011207014503.A7964@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@transmeta.com
Cc: linux-mm@kvack.org, Jack Steiner <steiner@sgi.com>
List-ID: <linux-mm.kvack.org>

Hey folks,

I'm just going through my backlog, and this patch looks reasonable to 
me.  Linus, could you drop this into 2.5?

		-ben

----- Forwarded message from Jack Steiner <steiner@sgi.com> -----

From: Jack Steiner <steiner@sgi.com>
Subject: Re: TLB flushing in 2.4.14
To: bcrl@redhat.com (Benjamin LaHaise)
Date: Wed, 28 Nov 2001 14:01:14 -0600 (CST)
In-Reply-To: <20011127132519.B19568@redhat.com> from "Benjamin LaHaise" at Nov 27, 2001 01:25:19 PM
X-Mailer: ELM [version 2.5 PL2]

> 
> On Tue, Nov 27, 2001 at 12:22:28PM -0600, Jack Steiner wrote:
> > Do you see any problems with this patch??  
> > 
> > (I also sent a copy of this to Andrea Arcangeli)
> 
> Yes.  Your system will now happily corrupt memory if you run ps or top at 
> the right time.  I'd suggested adding an mm->dead flag and using that 
> instead, but Linus is the keeper of the vm code, so run it by him.

You are right, of course. I should have studied the code better.

Here is a much cleaner fix (ignore the previous patch completely). This
keeps all the changes in just one spot - no changes to fs/exec.c. 

Do you see any problems here...



--- linux_base/include/asm-generic/tlb.h	Wed Oct 31 08:06:36 2001
+++ linux/include/asm-generic/tlb.h	Wed Nov 28 13:56:03 2001
@@ -43,7 +43,7 @@
 
 	tlb->mm = mm;
 	/* Use fast mode if there is only one user of this mm (this process) */
-	tlb->nr = (atomic_read(&(mm)->mm_users) == 1) ? ~0UL : 0UL;
+	tlb->nr = (atomic_read(&(mm)->mm_users) <= 1) ? ~0UL : 0UL;
 	return tlb;
 }
 
@@ -70,6 +70,8 @@
 /* tlb_finish_mmu
  *	Called at the end of the shootdown operation to free up any resources
  *	that were required.  The page talbe lock is still held at this point.
+ *	Note that no TLB flushes are needed if there are no users of the mm
+ *	context.
  */
 static inline void tlb_finish_mmu(struct free_pte_ctx *ctx, unsigned long start, unsigned long end)
 {
@@ -77,7 +79,8 @@
 
 	/* Handle the fast case first. */
 	if (ctx->nr == ~0UL) {
-		flush_tlb_range(ctx->mm, start, end);
+		if (ctx->mm->mmap)
+			flush_tlb_range(ctx->mm, start, end);
 		return;
 	}
 	nr = ctx->nr;

-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com

----- End forwarded message -----

-- 
Fish.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
