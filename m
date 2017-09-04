Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8FD016B04AD
	for <linux-mm@kvack.org>; Mon,  4 Sep 2017 09:02:46 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id w12so390989wrc.2
        for <linux-mm@kvack.org>; Mon, 04 Sep 2017 06:02:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a2sor1190871edd.11.2017.09.04.06.02.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Sep 2017 06:02:44 -0700 (PDT)
Date: Mon, 4 Sep 2017 16:02:42 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 06/19] x86/boot/compressed/64: Detect and handle
 5-level paging at boot-time
Message-ID: <20170904130242.4nj3emoltk4taypp@node.shutemov.name>
References: <20170821152916.40124-1-kirill.shutemov@linux.intel.com>
 <20170821152916.40124-7-kirill.shutemov@linux.intel.com>
 <20170827112926.GA1942@uranus.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170827112926.GA1942@uranus.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Dmitry Safonov <dsafonov@virtuozzo.com>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Aug 27, 2017 at 02:29:26PM +0300, Cyrill Gorcunov wrote:
> On Mon, Aug 21, 2017 at 06:29:03PM +0300, Kirill A. Shutemov wrote:
> > This patch prepare decompression code to boot-time switching between 4-
> > and 5-level paging.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  arch/x86/boot/compressed/head_64.S | 24 ++++++++++++++++++++++++
> >  1 file changed, 24 insertions(+)
> > 
> > diff --git a/arch/x86/boot/compressed/head_64.S b/arch/x86/boot/compressed/head_64.S
> > index fbf4c32d0b62..2e362aea3319 100644
> > --- a/arch/x86/boot/compressed/head_64.S
> > +++ b/arch/x86/boot/compressed/head_64.S
> > @@ -347,6 +347,28 @@ preferred_addr:
> >  	leaq	boot_stack_end(%rbx), %rsp
> >  
> >  #ifdef CONFIG_X86_5LEVEL
> > +	/* Preserve rbx across cpuid */
> > +	movq	%rbx, %r8
> > +
> > +	/* Check if leaf 7 is supported */
> > +	movl	$0, %eax
> 
> Use xor instead, it should be shorter
> 
> > +	cpuid
> > +	cmpl	$7, %eax
> > +	jb	lvl5
> > +
> > +	/*
> > +	 * Check if la57 is supported.
> > +	 * The feature is enumerated with CPUID.(EAX=07H, ECX=0):ECX[bit 16]
> > +	 */
> > +	movl	$7, %eax
> > +	movl	$0, %ecx
> 
> same

Thanks. I'll update it for the next re-spin.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
