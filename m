Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1ADF76B0005
	for <linux-mm@kvack.org>; Wed, 25 May 2016 12:10:45 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id a143so81603451oii.2
        for <linux-mm@kvack.org>; Wed, 25 May 2016 09:10:45 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 71si24577755itg.35.2016.05.25.09.10.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 May 2016 09:10:44 -0700 (PDT)
Date: Wed, 25 May 2016 18:09:30 +0200
From: Daniel Kiper <daniel.kiper@oracle.com>
Subject: Re: [RFC PATCH v1 10/18] x86/efi: Access EFI related tables in the
 clear
Message-ID: <20160525160930.GJ5490@olila.local.net-space.pl>
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
 <20160426225740.13567.85438.stgit@tlendack-t1.amdoffice.net>
 <20160510134358.GR2839@codeblueprint.co.uk>
 <20160510135758.GA16783@pd.tnic>
 <5734C97D.8060803@amd.com>
 <57446B27.20406@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57446B27.20406@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: Borislav Petkov <bp@alien8.de>, Matt Fleming <matt@codeblueprint.co.uk>, Leif Lindholm <leif.lindholm@linaro.org>, Mark Salter <msalter@redhat.com>, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Tue, May 24, 2016 at 09:54:31AM -0500, Tom Lendacky wrote:
> On 05/12/2016 01:20 PM, Tom Lendacky wrote:
> > On 05/10/2016 08:57 AM, Borislav Petkov wrote:
> >> On Tue, May 10, 2016 at 02:43:58PM +0100, Matt Fleming wrote:
> >>> Is it not possible to maintain some kind of kernel virtual address
> >>> mapping so memremap*() and friends can figure out when to twiddle the
> >>> mapping attributes and map with/without encryption?
> >>
> >> I guess we can move the sme_* specific stuff one indirection layer
> >> below, i.e., in the *memremap() routines so that callers don't have to
> >> care... That should keep the churn down...
> >>
> >
> > We could do that, but we'll have to generate that list of addresses so
> > that it can be checked against the range being mapped.  Since this is
> > part of early memmap support searching that list every time might not be
> > too bad. I'll have to look into that and see what that looks like.
>
> I looked into this and this would be a large change also to parse tables
> and build lists.  It occurred to me that this could all be taken care of
> if the early_memremap calls were changed to early_ioremap calls. Looking
> in the git log I see that they were originally early_ioremap calls but
> were changed to early_memremap calls with this commit:
>
> commit abc93f8eb6e4 ("efi: Use early_mem*() instead of early_io*()")
>
> Looking at the early_memremap code and the early_ioremap code they both
> call __early_ioremap so I don't see how this change makes any
> difference (especially since FIXMAP_PAGE_NORMAL and FIXMAP_PAGE_IO are
> identical in this case).
>
> Is it safe to change these back to early_ioremap calls (at least on
> x86)?

Commit f955371ca9d3986bca100666041fcfa9b6d21962 (x86: remove the Xen-specific
_PAGE_IOMAP PTE flag) made commit abc93f8eb6e4 unnecessary. Though, IMO, it
is still valid code cleanup. So, if it is not very strongly needed I would
not revert this change.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
