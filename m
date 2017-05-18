Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 84301831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 15:50:54 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id g143so10964155wme.13
        for <linux-mm@kvack.org>; Thu, 18 May 2017 12:50:54 -0700 (PDT)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id i1si324625wrc.136.2017.05.18.12.50.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 May 2017 12:50:53 -0700 (PDT)
Received: by mail-wm0-x22c.google.com with SMTP id d127so64074766wmf.0
        for <linux-mm@kvack.org>; Thu, 18 May 2017 12:50:53 -0700 (PDT)
Date: Thu, 18 May 2017 20:50:51 +0100
From: Matt Fleming <matt@codeblueprint.co.uk>
Subject: Re: [PATCH v5 17/32] x86/mm: Add support to access boot related data
 in the clear
Message-ID: <20170518195051.GA5651@codeblueprint.co.uk>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418211921.10190.1537.stgit@tlendack-t1.amdoffice.net>
 <20170515183517.mb4k2gp2qobbuvtm@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170515183517.mb4k2gp2qobbuvtm@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Tom Lendacky <thomas.lendacky@amd.com>, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>

On Mon, 15 May, at 08:35:17PM, Borislav Petkov wrote:
> On Tue, Apr 18, 2017 at 04:19:21PM -0500, Tom Lendacky wrote:
>
> > +		paddr = boot_params.efi_info.efi_memmap_hi;
> > +		paddr <<= 32;
> > +		paddr |= boot_params.efi_info.efi_memmap;
> > +		if (phys_addr == paddr)
> > +			return true;
> > +
> > +		paddr = boot_params.efi_info.efi_systab_hi;
> > +		paddr <<= 32;
> > +		paddr |= boot_params.efi_info.efi_systab;
> 
> So those two above look like could be two global vars which are
> initialized somewhere in the EFI init path:
> 
> efi_memmap_phys and efi_systab_phys or so.
> 
> Matt ?
> 
> And then you won't need to create that paddr each time on the fly. I
> mean, it's not a lot of instructions but still...
 
We should already have the physical memmap address available in
'efi.memmap.phys_map'.

And the physical address of the system table should be in
'efi_phys.systab'. See efi_init().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
