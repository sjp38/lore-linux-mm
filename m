Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id CFD826B02B1
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 14:16:40 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id k201so111633832qke.6
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 11:16:40 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o8si19295254qkh.138.2016.11.15.11.16.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 11:16:39 -0800 (PST)
Date: Tue, 15 Nov 2016 21:16:33 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH v3 13/20] x86: DMA support for memory encryption
Message-ID: <20161115211603-mutt-send-email-mst@kernel.org>
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
 <20161110003723.3280.62636.stgit@tlendack-t1.amdoffice.net>
 <20161115171443-mutt-send-email-mst@kernel.org>
 <4d97f998-5835-f4e0-9840-7f7979251275@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4d97f998-5835-f4e0-9840-7f7979251275@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Tue, Nov 15, 2016 at 12:29:35PM -0600, Tom Lendacky wrote:
> On 11/15/2016 9:16 AM, Michael S. Tsirkin wrote:
> > On Wed, Nov 09, 2016 at 06:37:23PM -0600, Tom Lendacky wrote:
> >> Since DMA addresses will effectively look like 48-bit addresses when the
> >> memory encryption mask is set, SWIOTLB is needed if the DMA mask of the
> >> device performing the DMA does not support 48-bits. SWIOTLB will be
> >> initialized to create un-encrypted bounce buffers for use by these devices.
> >>
> >> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> >> ---
> >>  arch/x86/include/asm/dma-mapping.h |    5 ++-
> >>  arch/x86/include/asm/mem_encrypt.h |    5 +++
> >>  arch/x86/kernel/pci-dma.c          |   11 ++++---
> >>  arch/x86/kernel/pci-nommu.c        |    2 +
> >>  arch/x86/kernel/pci-swiotlb.c      |    8 ++++-
> >>  arch/x86/mm/mem_encrypt.c          |   17 +++++++++++
> >>  include/linux/swiotlb.h            |    1 +
> >>  init/main.c                        |   13 ++++++++
> >>  lib/swiotlb.c                      |   58 +++++++++++++++++++++++++++++++-----
> >>  9 files changed, 103 insertions(+), 17 deletions(-)
> >>
> >> diff --git a/arch/x86/include/asm/dma-mapping.h b/arch/x86/include/asm/dma-mapping.h
> >> index 4446162..c9cdcae 100644
> >> --- a/arch/x86/include/asm/dma-mapping.h
> >> +++ b/arch/x86/include/asm/dma-mapping.h
> 
> ..SNIP...
> 
> >>  
> >> +/*
> >> + * If memory encryption is active, the DMA address for an encrypted page may
> >> + * be beyond the range of the device. If bounce buffers are required be sure
> >> + * that they are not on an encrypted page. This should be called before the
> >> + * iotlb area is used.
> > 
> > Makes sense, but I think at least a dmesg warning here
> > might be a good idea.
> 
> Good idea.  Should it be a warning when it is first being set up or
> a warning the first time the bounce buffers need to be used.  Or maybe
> both?
> 
> > 
> > A boot flag that says "don't enable devices that don't support
> > encryption" might be a good idea, too, since most people
> > don't read dmesg output and won't notice the message.
> 
> I'll look into this. It might be something that can be checked as
> part of the device setting its DMA mask or the first time a DMA
> API is used if the device doesn't explicitly set its mask.
> 
> Thanks,
> Tom
> 
> > 

I think setup time is nicer if it's possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
