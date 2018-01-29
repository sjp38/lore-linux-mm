Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 69C3A6B0005
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 08:01:04 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id w72so5281551ota.18
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 05:01:04 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t21si1921568oie.402.2018.01.29.05.01.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jan 2018 05:01:03 -0800 (PST)
Date: Mon, 29 Jan 2018 21:00:09 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH] x86/kexec: Make kexec work in 5-level paging mode
Message-ID: <20180129130009.GB7344@localhost.localdomain>
References: <20180129110845.26633-1-kirill.shutemov@linux.intel.com>
 <20180129111901.GA7344@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180129111901.GA7344@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/29/18 at 07:19pm, Baoquan He wrote:
> On 01/29/18 at 02:08pm, Kirill A. Shutemov wrote:
> > I've missed that we need to change relocate_kernel() to set CR4.LA57
> > flag if the kernel has 5-level paging enabled.
> > 
> > I avoided to use ifdef CONFIG_X86_5LEVEL here and inferred if we need to
> > enabled 5-level paging from previous CR4 value. This way the code is
> > ready for boot-time switching between paging modes.
> > 
> > Fixes: 77ef56e4f0fb ("x86: Enable 5-level paging support via CONFIG_X86_5LEVEL=y")
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Reported-by: Baoquan He <bhe@redhat.com>
> 
> Thanks, Kirill.
> 
> Tested on qemu with la57 support, kexec works well. Kdump kernel can
> boot into kernel, while there's a memory allocation failure during
> boot which I am trying to fix. The reason is kdump kernel need reserve
> as small memory as possible. Will post soon.

By the way, the kdump failure can be worked around by increasing
crashkernel memory, then kdump kernel can still work well. So this patch
is necessary fix for kexec/kdump.

> 
> For this patch, feel free to add my Tested-by.
> 
> Tested-by: Baoquan He <bhe@redhat.com>
> 
> Thanks
> Baoquan
> > ---
> >  arch/x86/kernel/relocate_kernel_64.S | 8 ++++++++
> >  1 file changed, 8 insertions(+)
> > 
> > diff --git a/arch/x86/kernel/relocate_kernel_64.S b/arch/x86/kernel/relocate_kernel_64.S
> > index 307d3bac5f04..11eda21eb697 100644
> > --- a/arch/x86/kernel/relocate_kernel_64.S
> > +++ b/arch/x86/kernel/relocate_kernel_64.S
> > @@ -68,6 +68,9 @@ relocate_kernel:
> >  	movq	%cr4, %rax
> >  	movq	%rax, CR4(%r11)
> >  
> > +	/* Save CR4. Required to enable the right paging mode later. */
> > +	movq	%rax, %r13
> > +
> >  	/* zero out flags, and disable interrupts */
> >  	pushq $0
> >  	popfq
> > @@ -126,8 +129,13 @@ identity_mapped:
> >  	/*
> >  	 * Set cr4 to a known state:
> >  	 *  - physical address extension enabled
> > +	 *  - 5-level paging, if it was enabled before
> >  	 */
> >  	movl	$X86_CR4_PAE, %eax
> > +	testq	$X86_CR4_LA57, %r13
> > +	jz	1f
> > +	orl	$X86_CR4_LA57, %eax
> > +1:
> >  	movq	%rax, %cr4
> >  
> >  	jmp 1f
> > -- 
> > 2.15.1
> > 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
