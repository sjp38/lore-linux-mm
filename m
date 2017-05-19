Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4F37A28041F
	for <linux-mm@kvack.org>; Fri, 19 May 2017 07:30:08 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 70so13729885wmq.12
        for <linux-mm@kvack.org>; Fri, 19 May 2017 04:30:08 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id x62si23427244wmb.160.2017.05.19.04.30.06
        for <linux-mm@kvack.org>;
        Fri, 19 May 2017 04:30:07 -0700 (PDT)
Date: Fri, 19 May 2017 13:30:05 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v5 32/32] x86/mm: Add support to make use of Secure
 Memory Encryption
Message-ID: <20170519113005.3f5kwzg4pgh7j6a5@pd.tnic>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418212223.10190.85121.stgit@tlendack-t1.amdoffice.net>
 <c29edaff-24f2-ee9b-4142-bdbf8c42083f@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <c29edaff-24f2-ee9b-4142-bdbf8c42083f@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>, Josh Poimboeuf <jpoimboe@redhat.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Fri, Apr 21, 2017 at 01:56:13PM -0500, Tom Lendacky wrote:
> On 4/18/2017 4:22 PM, Tom Lendacky wrote:
> > Add support to check if SME has been enabled and if memory encryption
> > should be activated (checking of command line option based on the
> > configuration of the default state).  If memory encryption is to be
> > activated, then the encryption mask is set and the kernel is encrypted
> > "in place."
> > 
> > Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> > ---
> >  arch/x86/kernel/head_64.S |    1 +
> >  arch/x86/mm/mem_encrypt.c |   83 +++++++++++++++++++++++++++++++++++++++++++--
> >  2 files changed, 80 insertions(+), 4 deletions(-)
> > 
> 
> ...
> 
> > 
> > -unsigned long __init sme_enable(void)
> > +unsigned long __init sme_enable(struct boot_params *bp)
> >  {
> > +	const char *cmdline_ptr, *cmdline_arg, *cmdline_on, *cmdline_off;
> > +	unsigned int eax, ebx, ecx, edx;
> > +	unsigned long me_mask;
> > +	bool active_by_default;
> > +	char buffer[16];
> 
> So it turns out that when KASLR is enabled (CONFIG_RAMDOMIZE_BASE=y)
> the stack-protector support causes issues with this function because

What issues?

> it is called so early. I can get past it by adding:
> 
> CFLAGS_mem_encrypt.o := $(nostackp)
> 
> in the arch/x86/mm/Makefile, but that obviously eliminates the support
> for the whole file.  Would it be better to split out the sme_enable()
> and other boot routines into a separate file or just apply the
> $(nostackp) to the whole file?

Josh might have a better idea here... CCed.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
