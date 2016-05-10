Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8203B6B025E
	for <linux-mm@kvack.org>; Tue, 10 May 2016 09:44:02 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 68so11398561lfq.2
        for <linux-mm@kvack.org>; Tue, 10 May 2016 06:44:02 -0700 (PDT)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id r11si3238315wmb.87.2016.05.10.06.44.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 May 2016 06:44:00 -0700 (PDT)
Received: by mail-wm0-x231.google.com with SMTP id e201so178805179wme.0
        for <linux-mm@kvack.org>; Tue, 10 May 2016 06:44:00 -0700 (PDT)
Date: Tue, 10 May 2016 14:43:58 +0100
From: Matt Fleming <matt@codeblueprint.co.uk>
Subject: Re: [RFC PATCH v1 10/18] x86/efi: Access EFI related tables in the
 clear
Message-ID: <20160510134358.GR2839@codeblueprint.co.uk>
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
 <20160426225740.13567.85438.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160426225740.13567.85438.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Tue, 26 Apr, at 05:57:40PM, Tom Lendacky wrote:
> The EFI tables are not encrypted and need to be accessed as such. Be sure
> to memmap them without the encryption attribute set. For EFI support that
> lives outside of the arch/x86 tree, create a routine that uses the __weak
> attribute so that it can be overridden by an architecture specific routine.
> 
> When freeing boot services related memory, since it has been mapped as
> un-encrypted, be sure to change the mapping to encrypted for future use.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/include/asm/cacheflush.h  |    3 +
>  arch/x86/include/asm/mem_encrypt.h |   22 +++++++++++
>  arch/x86/kernel/setup.c            |    6 +--
>  arch/x86/mm/mem_encrypt.c          |   56 +++++++++++++++++++++++++++
>  arch/x86/mm/pageattr.c             |   75 ++++++++++++++++++++++++++++++++++++
>  arch/x86/platform/efi/efi.c        |   26 +++++++-----
>  arch/x86/platform/efi/efi_64.c     |    9 +++-
>  arch/x86/platform/efi/quirks.c     |   12 +++++-
>  drivers/firmware/efi/efi.c         |   18 +++++++--
>  drivers/firmware/efi/esrt.c        |   12 +++---
>  include/linux/efi.h                |    3 +
>  11 files changed, 212 insertions(+), 30 deletions(-)

The size of this change is completely unexpected. Why is there so much
churn to workaround this new feature?

Is it not possible to maintain some kind of kernel virtual address
mapping so memremap*() and friends can figure out when to twiddle the
mapping attributes and map with/without encryption?

These API changes place an undue burden on developers that don't even
care about SME.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
