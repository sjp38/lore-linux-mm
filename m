Date: Tue, 26 Mar 2002 22:18:20 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] mmap bug with drivers that adjust vm_start
Message-ID: <20020326221820.P13052@dualathlon.random>
References: <20020325230046.A14421@redhat.com> <20020326174236.B13052@dualathlon.random> <20020326135703.B25375@redhat.com> <20020326201502.J13052@dualathlon.random> <20020326154345.B25595@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20020326154345.B25595@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 26, 2002 at 03:43:45PM -0500, Benjamin LaHaise wrote:
> I would rather see an mmap fail if it would collide with an existing mapping, 
> but that might break some applications.

That doesn't make it easier though, the time we should fail is still way
earlier the relocation of the virtual address space area.

> Thanks for looking this over.  Cheers,

You're welcome, thanks for fixing it.

> +		if (unlikely(NULL != find_vma_prepare(mm, addr, &prev,
> +						&rb_link, &rb_parent))) {

this looks wrong there may very well be a vma after our mapping but it
doesn't necessairly overlap with us (also the unlikely would make more
sense in the previous if). I hacked a bit on top of your previous patch,
this looks ok to me but it's untested:

diff -urN 2.4.19pre4aa1/mm/mmap.c vma/mm/mmap.c
--- 2.4.19pre4aa1/mm/mmap.c	Tue Mar 26 20:43:07 2002
+++ vma/mm/mmap.c	Tue Mar 26 20:48:24 2002
@@ -554,7 +554,26 @@
 	 * Answer: Yes, several device drivers can do it in their
 	 *         f_op->mmap method. -DaveM
 	 */
-	addr = vma->vm_start;
+	if (unlikely(addr != vma->vm_start)) {
+		/*
+		 * It is a bit too late to pretend changing the virtual
+		 * area of the mapping, we just corrupted userspace
+		 * in the do_munmap, so FIXME (not in 2.4 to avoid breaking
+		 * the driver API).
+		 */
+		struct vm_area_struct * stale_vma;
+		/* Since addr changed, we rely on the mmap op to prevent 
+		 * collisions with existing vmas and just use find_vma_prepare 
+		 * to update the tree pointers.
+		 */
+		addr = vma->vm_start;
+		stale_vma = find_vma_prepare(mm, addr, &prev, &rb_link, &rb_parent);
+		/*
+		 * Make sure the lowlevel driver did its job right.
+		 */
+		if (unlikely(stale_vma && stale_vma->vm_start < vma->vm_end))
+			BUG();
+	}
 
 	vma_link(mm, vma, prev, rb_link, rb_parent);
 	if (correct_wcount)


your printk also is valid debugging trick, I think it won't be necessary
most of the time but feel free to re-add it if you like.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
