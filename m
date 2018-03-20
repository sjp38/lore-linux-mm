Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 438426B0003
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 20:49:24 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id g107-v6so4198976otg.20
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 17:49:24 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id x109-v6si148221otb.12.2018.03.19.17.49.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Mar 2018 17:49:22 -0700 (PDT)
Subject: Re: [RFC PATCH 09/14] khwasan: add hooks implementation
References: <cover.1520017438.git.andreyknvl@google.com>
 <06a4d0c483fba8babd01fe23727fe4a79482d309.1520017438.git.andreyknvl@google.com>
From: Anthony Yznaga <anthony.yznaga@oracle.com>
Message-ID: <dd58d047-2a57-fcf5-b555-6e9630b52670@oracle.com>
Date: Mon, 19 Mar 2018 17:44:22 -0700
MIME-Version: 1.0
In-Reply-To: <06a4d0c483fba8babd01fe23727fe4a79482d309.1520017438.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

Hi Andrey,

On 3/2/18 11:44 AM, Andrey Konovalov wrote:
> void kasan_poison_kfree(void *ptr, unsigned long ip)
>  {
> +	struct page *page;
> +
> +	page = virt_to_head_page(ptr)

An untagged addr should be passed to virt_to_head_page(), no?

> +
> +	if (unlikely(!PageSlab(page))) {
> +		if (reset_tag(ptr) != page_address(page)) {
> +			/* Report invalid-free here */
> +			return;
> +		}
> +		kasan_poison_shadow(ptr, PAGE_SIZE << compound_order(page),
> +					khwasan_random_tag());
> +	} else {
> +		__kasan_slab_free(page->slab_cache, ptr, ip);
> +	}
>  }
>  
>  void kasan_kfree_large(void *ptr, unsigned long ip)
>  {
> +	struct page *page = virt_to_page(ptr);
> +	struct page *head_page = virt_to_head_page(ptr);

Same as above and for virt_to_page() as well.

Anthony


> +
> +	if (reset_tag(ptr) != page_address(head_page)) {
> +		/* Report invalid-free here */
> +		return;
> +	}
> +
> +	kasan_poison_shadow(ptr, PAGE_SIZE << compound_order(page),
> +			khwasan_random_tag());
>  }
