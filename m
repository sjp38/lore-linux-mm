Date: Mon, 14 Oct 2002 14:20:45 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [patch, feature] nonlinear mappings, prefaulting support, 2.5.42-F8
Message-ID: <20021014212045.GF27878@holomorphy.com>
References: <Pine.LNX.4.44.0210141739510.8792-100000@localhost.localdomain> <Pine.LNX.4.44.0210141800160.9302-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0210141800160.9302-100000@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Oct 14, 2002 at 06:02:30PM +0200, Ingo Molnar wrote:
>> if this is really an issue then we could force vma->vm_page_prot to
>> PROT_NONE within remap_file_pages(), so at least all subsequent faults
>> will be PROT_NONE and the user would have to explicitly re-mprotect()
>> the vma again to change this.
> i've added this to the -G1 patch at:
>         http://redhat.com/~mingo/remap-file-pages-patches/
>     Ingo

Also, this may be relaxed when the file offsets match.
Against unpatched -G1:


Bill


--- mpop-2.5.42/mm/fremap.c	2002-10-14 11:43:03.000000000 -0700
+++ wlipop-2.5.42/mm/fremap.c	2002-10-14 14:17:11.000000000 -0700
@@ -129,10 +129,16 @@
 			end > start && start >= vma->vm_start &&
 				end <= vma->vm_end) {
 		/*
-		 * Change the default protection to PROT_NONE:
+		 * Change the default protection to PROT_NONE if
+		 * the file offset doesn't coincide with the vma's:
 		 */
-		if (pgprot_val(vma->vm_page_prot) != pgprot_val(__S000))
-			vma->vm_page_prot = __S000;
+		if (pgprot_val(vma->vm_page_prot) != pgprot_val(__S000)) {
+			unsigned long offset;
+			offset = (start - vma->vm_start) >> PAGE_CACHE_SHIFT
+					+ vma->vm_pgoff;
+			if (offset != pgoff)
+				vma->vm_page_prot = __S000;
+		}
 		err = vma->vm_ops->populate(vma, start, size, prot,
 						pgoff, flags & MAP_NONBLOCK);
 	}
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
