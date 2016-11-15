Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 010476B0277
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 07:10:48 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id i131so49729426wmf.3
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 04:10:47 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id p21si2799506wmb.29.2016.11.15.04.10.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 04:10:46 -0800 (PST)
Date: Tue, 15 Nov 2016 13:10:35 +0100
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [RFC PATCH v3 04/20] x86: Handle reduction in physical address
 size with SME
Message-ID: <20161115121035.GD24857@8bytes.org>
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
 <20161110003513.3280.12104.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161110003513.3280.12104.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Nov 09, 2016 at 06:35:13PM -0600, Tom Lendacky wrote:
> +/*
> + * AMD Secure Memory Encryption (SME) can reduce the size of the physical
> + * address space if it is enabled, even if memory encryption is not active.
> + * Adjust x86_phys_bits if SME is enabled.
> + */
> +static void phys_bits_adjust(struct cpuinfo_x86 *c)
> +{

Better call this function amd_sme_phys_bits_adjust(). This name makes it
clear at the call-site why it is there and what it does.

> +	u32 eax, ebx, ecx, edx;
> +	u64 msr;
> +
> +	if (c->x86_vendor != X86_VENDOR_AMD)
> +		return;
> +
> +	if (c->extended_cpuid_level < 0x8000001f)
> +		return;
> +
> +	/* Check for SME feature */
> +	cpuid(0x8000001f, &eax, &ebx, &ecx, &edx);
> +	if (!(eax & 0x01))
> +		return;

Maybe add a comment here why you can't use cpu_has (yet).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
