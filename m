Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id F33C76B0069
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 07:09:09 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id 14so7805764itm.6
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 04:09:09 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id k202si3171098itk.72.2017.12.14.04.09.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 04:09:08 -0800 (PST)
Date: Thu, 14 Dec 2017 13:08:53 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 00/17] x86/ldt: Use a VMA based read only mapping
Message-ID: <20171214120853.u2vc4x55faurkgec@hirez.programming.kicks-ass.net>
References: <20171214112726.742649793@infradead.org>
 <alpine.DEB.2.20.1712141302540.4998@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1712141302540.4998@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com

On Thu, Dec 14, 2017 at 01:03:37PM +0100, Thomas Gleixner wrote:
> On Thu, 14 Dec 2017, Peter Zijlstra wrote:
> > So here's a second posting of the VMA based LDT implementation; now without
> > most of the crazy.
> > 
> > I took out the write fault handler and the magic LAR touching code.
> > 
> > Additionally there are a bunch of patches that address generic vm issue.
> > 
> >  - gup() access control; In specific I looked at accessing !_PAGE_USER pages
> >    because these patches rely on not being able to do that.
> > 
> >  - special mappings; A whole bunch of mmap ops don't make sense on special
> >    mappings so disallow them.
> > 
> > Both things make sense independent of the rest of the series. Similarly, the
> > patches that kill that rediculous LDT inherit on exec() are also unquestionably
> > good.
> > 
> > So I think at least the first 6 patches are good, irrespective of the
> > VMA approach.
> > 
> > On the whole VMA approach, Andy I know you hate it with a passion, but I really
> > rather like how it ties the LDT to the process that it belongs to and it
> > reduces the amount of 'special' pages in the whole PTI mapping.
> > 
> > I'm not the one going to make the decision on this; but I figured I at least
> > post a version without the obvious crap parts of the last one.
> > 
> > Note: if we were to also disallow munmap() for special mappings (which I
> > suppose makes perfect sense) then we could further reduce the actual LDT
> > code (we'd no longer need the sm::close callback and related things).
> 
> That makes a lot of sense for the other special mapping users like VDSO and
> kprobes.

Right, and while looking at that I also figured it might make sense to
unconditionally disallow splitting special mappings.


--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2698,6 +2698,9 @@ int do_munmap(struct mm_struct *mm, unsi
 	}
 	vma = prev ? prev->vm_next : mm->mmap;
 
+	if (vma_is_special_mapping(vma))
+		return -EINVAL;
+
 	if (unlikely(uf)) {
 		/*
 		 * If userfaultfd_unmap_prep returns an error the vmas
@@ -3223,10 +3226,11 @@ static int special_mapping_fault(struct
  */
 static void special_mapping_close(struct vm_area_struct *vma)
 {
-	struct vm_special_mapping *sm = vma->vm_private_data;
+}
 
-	if (sm->close)
-		sm->close(sm, vma);
+static int special_mapping_split(struct vm_area_struct *vma, unsigned long addr)
+{
+	return -EINVAL;
 }
 
 static const char *special_mapping_name(struct vm_area_struct *vma)
@@ -3252,6 +3256,7 @@ static const struct vm_operations_struct
 	.fault = special_mapping_fault,
 	.mremap = special_mapping_mremap,
 	.name = special_mapping_name,
+	.split = special_mapping_split,
 };
 
 static const struct vm_operations_struct legacy_special_mapping_vmops = {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
