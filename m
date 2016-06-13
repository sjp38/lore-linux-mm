Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id CB2976B0005
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 08:35:00 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r5so28539050wmr.0
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 05:35:00 -0700 (PDT)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id d7si29504354wjy.166.2016.06.13.05.34.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 05:34:59 -0700 (PDT)
Received: by mail-wm0-x22d.google.com with SMTP id m124so77590119wme.1
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 05:34:59 -0700 (PDT)
Date: Mon, 13 Jun 2016 13:34:52 +0100
From: Matt Fleming <matt@codeblueprint.co.uk>
Subject: Re: [RFC PATCH v1 10/18] x86/efi: Access EFI related tables in the
 clear
Message-ID: <20160613123452.GB2658@codeblueprint.co.uk>
References: <20160426225740.13567.85438.stgit@tlendack-t1.amdoffice.net>
 <20160510134358.GR2839@codeblueprint.co.uk>
 <20160510135758.GA16783@pd.tnic>
 <5734C97D.8060803@amd.com>
 <57446B27.20406@amd.com>
 <20160525193011.GC2984@codeblueprint.co.uk>
 <5746FE16.9070408@amd.com>
 <20160608100713.GU2658@codeblueprint.co.uk>
 <57599668.20000@amd.com>
 <20160613120322.GA2658@codeblueprint.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160613120322.GA2658@codeblueprint.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: Borislav Petkov <bp@alien8.de>, Leif Lindholm <leif.lindholm@linaro.org>, Mark Salter <msalter@redhat.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>

On Mon, 13 Jun, at 01:03:22PM, Matt Fleming wrote:
> 
> Would we need a new function? Couldn't we just have a new
> FIXMAP_PAGE_* constant? e.g. would something like this work?
> 
> ---
> 
> enum memremap_owner {
> 	KERNEL_DATA = 0,
> 	BOOT_DATA,
> };
> 
> void __init *
> early_memremap(resource_size_t phys_addr, unsigned long size,
> 	       enum memremap_owner owner)
> {
> 	pgprot_t prot;
> 
> 	switch (owner) {
> 	case BOOT_DATA:
> 		prot = FIXMAP_PAGE_BOOT;
> 		break;
> 	case KERNEL_DATA:	/* FALLTHROUGH */
> 	default:
> 		prot = FIXMAP_PAGE_NORMAL;
> 		
> 	}
> 
> 	return (__force void *)__early_ioremap(phys_addr, size, prot);
> }

Although it occurs to me that if there's a trivial 1:1 mapping between
memremap_owner and FIXMAP_PAGE_* we might as well just add a new
early_memremap_boot() that uses the correct FIXMAP_PAGE_* constant,
akin to early_memremap_ro().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
