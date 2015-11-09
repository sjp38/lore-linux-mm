Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id A8EE16B0259
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 18:23:02 -0500 (EST)
Received: by pasz6 with SMTP id z6so220064013pas.2
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 15:23:02 -0800 (PST)
Received: from g2t2352.austin.hp.com (g2t2352.austin.hp.com. [15.217.128.51])
        by mx.google.com with ESMTPS id pp8si545828pbb.200.2015.11.09.15.23.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 15:23:01 -0800 (PST)
Message-ID: <1447111134.21443.30.camel@hpe.com>
Subject: Re: [PATCH v4 RESEND 4/11] x86/asm: Fix pud/pmd interfaces to
 handle large PAT bit
From: Toshi Kani <toshi.kani@hpe.com>
Date: Mon, 09 Nov 2015 16:18:54 -0700
In-Reply-To: <56411FFB.80104@oracle.com>
References: <1442514264-12475-1-git-send-email-toshi.kani@hpe.com>
	 <1442514264-12475-5-git-send-email-toshi.kani@hpe.com>
	 <5640E08F.5020206@oracle.com> <1447096601.21443.15.camel@hpe.com>
	 <5640F673.8070400@oracle.com> <20151109204710.GB5443@node.shutemov.name>
	 <56411FFB.80104@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hpe.com

On Mon, 2015-11-09 at 17:36 -0500, Boris Ostrovsky wrote:
> On 11/09/2015 03:47 PM, Kirill A. Shutemov wrote:
> > On Mon, Nov 09, 2015 at 02:39:31PM -0500, Boris Ostrovsky wrote:
> > > On 11/09/2015 02:16 PM, Toshi Kani wrote:
> > > > On Mon, 2015-11-09 at 13:06 -0500, Boris Ostrovsky wrote:
> > > > > On 09/17/2015 02:24 PM, Toshi Kani wrote:
> > > > > > Now that we have pud/pmd mask interfaces, which handle pfn & flags
> > > > > > mask properly for the large PAT bit.
> > > > > > 
> > > > > > Fix pud/pmd pfn & flags interfaces by replacing PTE_PFN_MASK and
> > > > > > PTE_FLAGS_MASK with the pud/pmd mask interfaces.
> > > > > > 
> > > > > > Suggested-by: Juergen Gross <jgross@suse.com>
> > > > > > Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
> > > > > > Cc: Juergen Gross <jgross@suse.com>
> > > > > > Cc: Konrad Wilk <konrad.wilk@oracle.com>
> > > > > > Cc: Thomas Gleixner <tglx@linutronix.de>
> > > > > > Cc: H. Peter Anvin <hpa@zytor.com>
> > > > > > Cc: Ingo Molnar <mingo@redhat.com>
> > > > > > Cc: Borislav Petkov <bp@alien8.de>
> > > > > > ---
> > > > > >    arch/x86/include/asm/pgtable.h       |   14 ++++++++------
> > > > > >    arch/x86/include/asm/pgtable_types.h |    4 ++--
> > > > > >    2 files changed, 10 insertions(+), 8 deletions(-)
> > > > > > 
> > > > > Looks like this commit is causing this splat for 32-bit kernels. I am
> > > > > attaching my config file, just in case.
> > > > Thanks for the report!  I'd like to reproduce the issue since I am not
> > > > sure how
> > > > this change caused it...
> > > > 
> > > > I tried to build a kernel with the attached config file, and got the
> > > > following
> > > > error.  Not sure what I am missing.
> > > > 
> > > > ----
> > > > $ make -j24 ARCH=i386
> > > >     :
> > > >    LD      drivers/built-in.o
> > > >    LINK    vmlinux
> > > > ./.config: line 44: $'\r': command not found
> > > I wonder whether my email client added ^Ms to the file that I send. It
> > > shouldn't have.
> > > 
> > > > Makefile:929: recipe for target 'vmlinux' failed
> > > > make: *** [vmlinux] Error 127
> > > > ----
> > > > 
> > > > Do you have steps to reproduce the issue?  Or do you see it during boot
> > > > -time?
> > > This always happens just after system has booted, it may still be going
> > > over
> > > init scripts. I am booting with ramdisk, don't know whether it has
> > > anything
> > > to do with this problem.
> > > 
> > > FWIW, it looks like pmd_pfn_mask() inline is causing this. Reverting it
> > > alone makes this crash go away.
> > Could you check the patch below?
> 
> 
> I does fix the problem on baremetal, thanks. My 32-bit Xen guests still 
> fail which I thought was the same issue but now that I looked at it more 
> carefully it has different signature.

I do not think Xen is hitting this, but I think page_level_mask() has the same
issue for a long time.  I will set up 32-bit env on a system with >4GB memory to
verify this.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
