Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9D7EE831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 05:02:26 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 139so7716609wmf.5
        for <linux-mm@kvack.org>; Thu, 18 May 2017 02:02:26 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id s12si4708290wrb.115.2017.05.18.02.02.25
        for <linux-mm@kvack.org>;
        Thu, 18 May 2017 02:02:25 -0700 (PDT)
Date: Thu, 18 May 2017 11:02:12 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v5 17/32] x86/mm: Add support to access boot related data
 in the clear
Message-ID: <20170518090212.kebstmnjv4h3cjf2@pd.tnic>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418211921.10190.1537.stgit@tlendack-t1.amdoffice.net>
 <20170515183517.mb4k2gp2qobbuvtm@pd.tnic>
 <4845df29-bae7-9b78-0428-ff96dbef2128@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <4845df29-bae7-9b78-0428-ff96dbef2128@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Wed, May 17, 2017 at 01:54:39PM -0500, Tom Lendacky wrote:
> I was worried what the compiler might do when CONFIG_EFI is not set,
> but it appears to take care of it. I'll double check though.

There's a efi_enabled() !CONFIG_EFI version too, so should be fine.

> I may introduce a length variable to capture data->len right after
> paddr_next is set and then have just a single memunmap() call before
> the if check.

Yap.

> I tried that, but calling an "__init" function (early_memremap()) from
> a non "__init" function generated warnings. I suppose I can pass in a
> function for the map and unmap but that looks worse to me (also the
> unmap functions take different arguments).

No, the other way around: the __init function should call the non-init
one and you need the non-init one anyway for memremap_is_setup_data().

> This is like the chicken and the egg scenario. In order to determine if
> an address is setup data I have to explicitly map the setup data chain
> as decrypted. In order to do that I have to supply a flag to explicitly
> map the data decrypted otherwise I wind up back in the
> memremap_is_setup_data() function again and again and again...

Oh, fun.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
