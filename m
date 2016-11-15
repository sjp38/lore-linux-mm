Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C84AA6B029D
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 11:33:54 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id s63so3309057wms.7
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 08:33:54 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id q14si3667415wmd.13.2016.11.15.08.33.53
        for <linux-mm@kvack.org>;
        Tue, 15 Nov 2016 08:33:53 -0800 (PST)
Date: Tue, 15 Nov 2016 17:33:50 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v3 04/20] x86: Handle reduction in physical address
 size with SME
Message-ID: <20161115163350.jal7sd6ghbmk5sqc@pd.tnic>
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
 <20161110003513.3280.12104.stgit@tlendack-t1.amdoffice.net>
 <20161115121035.GD24857@8bytes.org>
 <20161115121456.f4slpk4i2jl3e2ke@pd.tnic>
 <a4cc5b07-89e1-aaa0-1977-1de95883ba62@amd.com>
 <20161115153338.a2cxmatnpqcgiaiy@pd.tnic>
 <bb47e943-f5b6-0d73-cf9a-fea002a5c70e@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <bb47e943-f5b6-0d73-cf9a-fea002a5c70e@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: Joerg Roedel <joro@8bytes.org>, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Tue, Nov 15, 2016 at 10:06:16AM -0600, Tom Lendacky wrote:
> Yes, but that doesn't relate to the physical address space reduction.
> 
> Once the SYS_CFG MSR bit for SME is set, even if the encryption bit is
> never used, there is a physical reduction of the address space. So when
> checking whether to adjust the physical address bits I can't rely on the
> sme_me_mask, I have to look at the MSR.
> 
> But when I'm looking to decide whether to encrypt or decrypt something,
> I use the sme_me_mask to decide if that is needed.  If the sme_me_mask
> is not set then the encrypt/decrypt op shouldn't be performed.
> 
> I might not be grasping the point you're trying to make...

Ok, let me try to summarize how I see it. There are a couple of states:

* CPUID bit in 0x8000001f - that's SME supported

* Reduction of address space - MSR bit. That could be called "SME
BIOS-eenabled".

* SME active. That's both of the above and is sme_me_mask != 0.

Right?

So you said previously "The feature may be present and enabled even if
it is not currently active."

But then you say "active" below

> > And in patch 12 you have:
> > 
> > +       /*
> > +        * If memory encryption is active, the trampoline area will need to
> > +        * be in un-encrypted memory in order to bring up other processors
> > +        * successfully.
> > +        */
> > +       sme_early_mem_dec(__pa(base), size);
> > +       sme_set_mem_unenc(base, size);

and test sme_me_mask. Which makes sense now after having explained which
hw setting controls what.

So can we agree on the nomenclature for all the different SME states
first and use those throughout the code? And hold those states down in
Documentation/x86/amd-memory-encryption.txt so that it is perfectly
clear to people looking at the code.

Also, if we need to check those states more than once, we should add
inline helpers:

sme_supported()
sme_bios_enabled()
sme_active()

How does that sound?

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
