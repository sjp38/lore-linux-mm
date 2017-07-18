Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id EE9576B02B4
	for <linux-mm@kvack.org>; Tue, 18 Jul 2017 05:36:35 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u89so3168825wrc.1
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 02:36:35 -0700 (PDT)
Received: from mail-wr0-x241.google.com (mail-wr0-x241.google.com. [2a00:1450:400c:c0c::241])
        by mx.google.com with ESMTPS id b124si5128369wmg.75.2017.07.18.02.36.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jul 2017 02:36:34 -0700 (PDT)
Received: by mail-wr0-x241.google.com with SMTP id w4so3374202wrb.1
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 02:36:34 -0700 (PDT)
Date: Tue, 18 Jul 2017 11:36:31 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v10 37/38] compiler-gcc.h: Introduce __nostackp function
 attribute
Message-ID: <20170718093631.pnamvdrkmzcjz64j@gmail.com>
References: <cover.1500319216.git.thomas.lendacky@amd.com>
 <0576fd5c74440ad0250f16ac6609ecf587812456.1500319216.git.thomas.lendacky@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0576fd5c74440ad0250f16ac6609ecf587812456.1500319216.git.thomas.lendacky@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, kasan-dev@googlegroups.com, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Dave Young <dyoung@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, "Michael S. Tsirkin" <mst@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>


* Tom Lendacky <thomas.lendacky@amd.com> wrote:

> Create a new function attribute, __nostackp, that can used to turn off
> stack protection on a per function basis.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  include/linux/compiler-gcc.h | 2 ++
>  include/linux/compiler.h     | 4 ++++
>  2 files changed, 6 insertions(+)
> 
> diff --git a/include/linux/compiler-gcc.h b/include/linux/compiler-gcc.h
> index cd4bbe8..682063b 100644
> --- a/include/linux/compiler-gcc.h
> +++ b/include/linux/compiler-gcc.h
> @@ -166,6 +166,8 @@
>  
>  #if GCC_VERSION >= 40100
>  # define __compiletime_object_size(obj) __builtin_object_size(obj, 0)
> +
> +#define __nostackp	__attribute__((__optimize__("no-stack-protector")))
>  #endif
>  
>  #if GCC_VERSION >= 40300
> diff --git a/include/linux/compiler.h b/include/linux/compiler.h
> index 219f82f..63cbca1 100644
> --- a/include/linux/compiler.h
> +++ b/include/linux/compiler.h
> @@ -470,6 +470,10 @@ static __always_inline void __write_once_size(volatile void *p, void *res, int s
>  #define __visible
>  #endif
>  
> +#ifndef __nostackp
> +#define __nostackp
> +#endif

So I changed this from the hard to read and ambiguous "__nostackp" abbreviation 
(does it mean 'no stack pointer?') to "__nostackprotector", plus added this detail 
to the changelog:

| ( This is needed by the SME in-place kernel memory encryption feature,
|   which activates encryption in its sme_enable() function and thus changes the 
|   visible value of the stack protection cookie on function return. )

Agreed?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
