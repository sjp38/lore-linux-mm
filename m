Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 895D96B0003
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 12:33:00 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id h10-v6so5468498ljk.18
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 09:33:00 -0700 (PDT)
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id s142-v6si25218042lfe.139.2018.10.31.09.32.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 09:32:58 -0700 (PDT)
Subject: Re: [PATCH v9 01/20] kasan, mm: change hooks signatures
References: <cover.1537542735.git.andreyknvl@google.com>
 <37b1d7e7c372b60e2323b33bf2e57d4e3409df0b.1537542735.git.andreyknvl@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <64a7030a-d6bf-3b52-aa7d-dbb1b25a7bc8@virtuozzo.com>
Date: Wed, 31 Oct 2018 19:33:34 +0300
MIME-Version: 1.0
In-Reply-To: <37b1d7e7c372b60e2323b33bf2e57d4e3409df0b.1537542735.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>



On 09/21/2018 06:13 PM, Andrey Konovalov wrote:
> Tag-based KASAN changes the value of the top byte of pointers returned
> from the kernel allocation functions (such as kmalloc). This patch updates
> KASAN hooks signatures and their usage in SLAB and SLUB code to reflect
> that.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  include/linux/kasan.h | 43 +++++++++++++++++++++++++++++--------------
>  mm/kasan/kasan.c      | 30 ++++++++++++++++++------------
>  mm/slab.c             | 12 ++++++------
>  mm/slab.h             |  2 +-
>  mm/slab_common.c      |  4 ++--
>  mm/slub.c             | 15 +++++++--------
>  6 files changed, 63 insertions(+), 43 deletions(-)
> 
> diff --git a/include/linux/kasan.h b/include/linux/kasan.h
> index 46aae129917c..52c86a568a4e 100644
> --- a/include/linux/kasan.h
> +++ b/include/linux/kasan.h
> @@ -51,16 +51,16 @@ void kasan_cache_shutdown(struct kmem_cache *cache);
>  void kasan_poison_slab(struct page *page);
>  void kasan_unpoison_object_data(struct kmem_cache *cache, void *object);
>  void kasan_poison_object_data(struct kmem_cache *cache, void *object);
> -void kasan_init_slab_obj(struct kmem_cache *cache, const void *object);
> +void *kasan_init_slab_obj(struct kmem_cache *cache, const void *object);
>  
> -void kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags);
> +void *kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags);
>  void kasan_kfree_large(void *ptr, unsigned long ip);
>  void kasan_poison_kfree(void *ptr, unsigned long ip);
> -void kasan_kmalloc(struct kmem_cache *s, const void *object, size_t size,
> +void *kasan_kmalloc(struct kmem_cache *s, const void *object, size_t size,
>  		  gfp_t flags);

This patch missed couple call-sites, in kmem_cache_alloc_trace() and kmem_cache_alloc_node_trace() in include/linux/slab.h,
the return value of kasan_kmalloc() is ignored. Probably worth adding __must_check to functions like this.

Once that fixed you can add Reviewed-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
here and to the rest of the patches. They look fine me.
