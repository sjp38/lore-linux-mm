Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 625276B0273
	for <linux-mm@kvack.org>; Tue, 15 May 2018 09:12:29 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id i200-v6so1084519itb.9
        for <linux-mm@kvack.org>; Tue, 15 May 2018 06:12:29 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50139.outbound.protection.outlook.com. [40.107.5.139])
        by mx.google.com with ESMTPS id r87-v6si12447ioe.169.2018.05.15.06.12.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 15 May 2018 06:12:27 -0700 (PDT)
Subject: Re: [PATCH v1 13/16] khwasan: add hooks implementation
References: <cover.1525798753.git.andreyknvl@google.com>
 <5dddd7d6f18927de291e7b09e1ff45190dd6d361.1525798754.git.andreyknvl@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <f86e7172-023d-b381-64f0-6039ae1b1dce@virtuozzo.com>
Date: Tue, 15 May 2018 16:13:20 +0300
MIME-Version: 1.0
In-Reply-To: <5dddd7d6f18927de291e7b09e1ff45190dd6d361.1525798754.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Yury Norov <ynorov@caviumnetworks.com>, Marc Zyngier <marc.zyngier@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, James Morse <james.morse@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Julien Thierry <julien.thierry@arm.com>, Tyler Baicar <tbaicar@codeaurora.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Kees Cook <keescook@chromium.org>, Sandipan Das <sandipan@linux.vnet.ibm.com>, David Woodhouse <dwmw@amazon.co.uk>, Paul Lawrence <paullawrence@google.com>, Herbert Xu <herbert@gondor.apana.org.au>, Josh Poimboeuf <jpoimboe@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Tom Lendacky <thomas.lendacky@amd.com>, Arnd Bergmann <arnd@arndb.de>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Souptick Joarder <jrdr.linux@gmail.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, Laura Abbott <labbott@redhat.com>, Boris Brezillon <boris.brezillon@bootlin.com>, Vlastimil Babka <vbabka@suse.cz>, Pintu Agarwal <pintu.ping@gmail.com>, Doug Berger <opendmb@gmail.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Pavel Tatashin <pasha.tatashin@oracle.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>



On 05/08/2018 08:20 PM, Andrey Konovalov wrote:

>  
>  static bool __kasan_slab_free(struct kmem_cache *cache, void *object,
>  			      unsigned long ip, bool quarantine)
>  {
>  	s8 shadow_byte;
> +	u8 tag;
>  	unsigned long rounded_up_size;
>  
> +	tag = get_tag(object);
> +	object = reset_tag(object);
> +
>  	if (unlikely(nearest_obj(cache, virt_to_head_page(object), object) !=
>  	    object)) {
> -		kasan_report_invalid_free(object, ip);
> +		kasan_report_invalid_free(set_tag(object, tag), ip);

Using variable to store untagged_object pointer, instead of tagging/untagging back and forth would make the
code easier to follow.

>  		return true;
>  	}
>  
> @@ -326,20 +346,29 @@ static bool __kasan_slab_free(struct kmem_cache *cache, void *object,
>  		return false;
>  
>  	shadow_byte = READ_ONCE(*(s8 *)kasan_mem_to_shadow(object));
> +#ifdef CONFIG_KASAN_GENERIC
>  	if (shadow_byte < 0 || shadow_byte >= KASAN_SHADOW_SCALE_SIZE) {
>  		kasan_report_invalid_free(object, ip);
>  		return true;
>  	}
> +#else
> +	if (tag != (u8)shadow_byte) {
> +		kasan_report_invalid_free(set_tag(object, tag), ip);
> +		return true;
> +	}
> +#endif



static bool inline shadow_ivalid(u8 tag, s8 shadow_byte)
{
	if (IS_ENABLED(CONFIG_KASAN_GENERIC))
		return shadow_byte < 0 || shadow_byte >= KASAN_SHADOW_SCALE_SIZE;
	else
		return tag != (u8)shadow_byte;
}


static bool __kasan_slab_free(struct kmem_cache *cache, void *object,

...
	if (shadow_invalid(tag, shadow_byte)) {
		kasan_report_invalid_free(object, ip);
		return true;
	}


>  
>  	rounded_up_size = round_up(cache->object_size, KASAN_SHADOW_SCALE_SIZE);
>  	kasan_poison_shadow(object, rounded_up_size, KASAN_KMALLOC_FREE);
>  
> -	if (!quarantine || unlikely(!(cache->flags & SLAB_KASAN)))
> +	if ((IS_ENABLED(CONFIG_KASAN_GENERIC) && !quarantine) ||
> +			unlikely(!(cache->flags & SLAB_KASAN)))
>  		return false;
>  
>  	set_track(&get_alloc_info(cache, object)->free_track, GFP_NOWAIT);
>  	quarantine_put(get_free_info(cache, object), cache);
> -	return true;
> +
> +	return IS_ENABLED(CONFIG_KASAN_GENERIC);
>  }
>  
>  bool kasan_slab_free(struct kmem_cache *cache, void *object, unsigned long ip)
> @@ -352,6 +381,7 @@ void *kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
>  {
>  	unsigned long redzone_start;
>  	unsigned long redzone_end;
> +	u8 tag;
>  
>  	if (gfpflags_allow_blocking(flags))
>  		quarantine_reduce();
> @@ -364,14 +394,19 @@ void *kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
>  	redzone_end = round_up((unsigned long)object + cache->object_size,
>  				KASAN_SHADOW_SCALE_SIZE);
>  
> +#ifdef CONFIG_KASAN_GENERIC
>  	kasan_unpoison_shadow(object, size);
> +#else
> +	tag = random_tag();
> +	kasan_poison_shadow(object, redzone_start - (unsigned long)object, tag);
> +#

diff --git a/mm/kasan/common.c b/mm/kasan/common.c
index 7cd4a4e8c3be..f11d6059fc06 100644
--- a/mm/kasan/common.c
+++ b/mm/kasan/common.c
@@ -404,12 +404,9 @@ void *kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
 	redzone_end = round_up((unsigned long)object + cache->object_size,
 				KASAN_SHADOW_SCALE_SIZE);
 
-#ifdef CONFIG_KASAN_GENERIC
-	kasan_unpoison_shadow(object, size);
-#else
 	tag = random_tag();
-	kasan_poison_shadow(object, redzone_start - (unsigned long)object, tag);
-#endif
+	kasan_unpoison_shadow(set_tag(object, tag), size);
+
 	kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_start,
 		KASAN_KMALLOC_REDZONE);
 


>  	kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_start,
>  		KASAN_KMALLOC_REDZONE);
>  
>  	if (cache->flags & SLAB_KASAN)
>  		set_track(&get_alloc_info(cache, object)->alloc_track, flags);
>  
> -	return (void *)object;
> +	return set_tag(object, tag);
>  }
>  EXPORT_SYMBOL(kasan_kmalloc);
>  



> @@ -380,6 +415,7 @@ void *kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags)
>  	struct page *page;
>  	unsigned long redzone_start;
>  	unsigned long redzone_end;
> +	u8 tag;
>  
>  	if (gfpflags_allow_blocking(flags))
>  		quarantine_reduce();
> @@ -392,11 +428,16 @@ void *kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags)
>  				KASAN_SHADOW_SCALE_SIZE);
>  	redzone_end = (unsigned long)ptr + (PAGE_SIZE << compound_order(page));
>  
> +#ifdef CONFIG_KASAN_GENERIC
>  	kasan_unpoison_shadow(ptr, size);
> +#else
> +	tag = random_tag();
> +	kasan_poison_shadow(ptr, redzone_start - (unsigned long)ptr, tag);
> +#endif
>  	kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_start,
>  		KASAN_PAGE_REDZONE);
>  
> -	return (void *)ptr;
> +	return set_tag(ptr, tag);
>  }

kasan_kmalloc_large() should be left untouched. It works correctly as is in both cases.
ptr comes from page allocator already already tagged at this point.
