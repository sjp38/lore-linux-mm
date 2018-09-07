Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 57C796B7ED6
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 12:06:34 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id l14-v6so17419336oii.9
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 09:06:34 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0106.outbound.protection.outlook.com. [104.47.1.106])
        by mx.google.com with ESMTPS id q205-v6si5656087oib.63.2018.09.07.09.06.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 07 Sep 2018 09:06:33 -0700 (PDT)
Subject: Re: [PATCH v6 16/18] khwasan, mm, arm64: tag non slab memory
 allocated via pagealloc
References: <cover.1535462971.git.andreyknvl@google.com>
 <db103bdc2109396af0c6007f1669ebbbb63b872b.1535462971.git.andreyknvl@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <3f2dee71-1615-4a34-d611-3ccaf407551e@virtuozzo.com>
Date: Fri, 7 Sep 2018 19:06:42 +0300
MIME-Version: 1.0
In-Reply-To: <db103bdc2109396af0c6007f1669ebbbb63b872b.1535462971.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>



On 08/29/2018 02:35 PM, Andrey Konovalov wrote:

>  void kasan_poison_slab(struct page *page)
>  {
> +	unsigned long i;
> +
> +	if (IS_ENABLED(CONFIG_SLAB))
> +		page->s_mem = reset_tag(page->s_mem);

Why reinitialize here, instead of single initialization in alloc_slabmgmt()?


> +	for (i = 0; i < (1 << compound_order(page)); i++)
> +		page_kasan_tag_reset(page + i);
>  	kasan_poison_shadow(page_address(page),
>  			PAGE_SIZE << compound_order(page),
>  			KASAN_KMALLOC_REDZONE);
