Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id E9E496B00F6
	for <linux-mm@kvack.org>; Thu, 17 Oct 2013 21:17:05 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so3742167pdj.1
        for <linux-mm@kvack.org>; Thu, 17 Oct 2013 18:17:05 -0700 (PDT)
Received: by mail-ve0-f179.google.com with SMTP id cz12so1462537veb.10
        for <linux-mm@kvack.org>; Thu, 17 Oct 2013 18:17:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1382057438-3306-4-git-send-email-davidlohr@hp.com>
References: <1382057438-3306-1-git-send-email-davidlohr@hp.com>
	<1382057438-3306-4-git-send-email-davidlohr@hp.com>
Date: Thu, 17 Oct 2013 18:17:02 -0700
Message-ID: <CA+55aFxjBoLYbRM5hsASsLWxXkmizVY6Th2niOz2x3GQQgU+ig@mail.gmail.com>
Subject: Re: [PATCH 3/3] vdso: preallocate new vmas
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Michel Lespinasse <walken@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, "Chandramouleeswaran, Aswin" <aswin@hp.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Richard Kuo <rkuo@codeaurora.org>, Ralf Baechle <ralf@linux-mips.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Paul Mundt <lethal@linux-sh.org>, Chris Metcalf <cmetcalf@tilera.com>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

This seems somewhat insane:

   int install_special_mapping(struct mm_struct *mm,
                              unsigned long addr, unsigned long len,
  +                           unsigned long vm_flags, struct page **pages,
  +                           struct vm_area_struct **vma_prealloc)
   {
  +       int ret = 0;
  +       struct vm_area_struct *vma = *vma_prealloc;

(removed the "old" lines to make it more readable).

Why pass in "struct vm_area_struct **vma_prealloc" when you could just
pass in a plain and more readable "struct vm_area_struct *vma"?

My *guess* is that you originally cleared the vma_prealloc thing if
you used it, but in the patch you sent out you definitely don't (the
_only_ use of that "vma_prealloc" is the line that loads the content
into "vma", so this interface looks like it is some remnant of an
earlier and more complicated patch?

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
