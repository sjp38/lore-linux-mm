Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1D4466B0038
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 17:18:24 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id k9so1889090wmg.11
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 14:18:24 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id k40si1484517wrf.308.2017.11.01.14.18.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 01 Nov 2017 14:18:23 -0700 (PDT)
Date: Wed, 1 Nov 2017 22:18:18 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 03/23] x86, kaiser: disable global pages
In-Reply-To: <20171031223152.B5D241B2@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.20.1711012213370.1942@nanos>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <20171031223152.B5D241B2@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On Tue, 31 Oct 2017, Dave Hansen wrote:
> --- a/arch/x86/include/asm/pgtable_types.h~kaiser-prep-disable-global-pages	2017-10-31 15:03:49.314064402 -0700
> +++ b/arch/x86/include/asm/pgtable_types.h	2017-10-31 15:03:49.323064827 -0700
> @@ -47,7 +47,12 @@
>  #define _PAGE_ACCESSED	(_AT(pteval_t, 1) << _PAGE_BIT_ACCESSED)
>  #define _PAGE_DIRTY	(_AT(pteval_t, 1) << _PAGE_BIT_DIRTY)
>  #define _PAGE_PSE	(_AT(pteval_t, 1) << _PAGE_BIT_PSE)
> +#ifdef CONFIG_X86_GLOBAL_PAGES
>  #define _PAGE_GLOBAL	(_AT(pteval_t, 1) << _PAGE_BIT_GLOBAL)
> +#else
> +/* We must ensure that kernel TLBs are unusable while in userspace */
> +#define _PAGE_GLOBAL	(_AT(pteval_t, 0))
> +#endif

What you really want to do here is to clear PAGE_GLOBAL in the
supported_pte_mask. probe_page_size_mask() is the proper place for that.

This allows both .config and boottime configuration.

Thanks,

	tglx






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
