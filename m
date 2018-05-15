Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B4BC46B029D
	for <linux-mm@kvack.org>; Tue, 15 May 2018 10:05:43 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r63-v6so125952pfl.12
        for <linux-mm@kvack.org>; Tue, 15 May 2018 07:05:43 -0700 (PDT)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30102.outbound.protection.outlook.com. [40.107.3.102])
        by mx.google.com with ESMTPS id k130-v6si108884pgc.81.2018.05.15.07.05.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 15 May 2018 07:05:42 -0700 (PDT)
Subject: Re: [PATCH v1 15/16] khwasan, mm, arm64: tag non slab memory
 allocated via pagealloc
References: <cover.1525798753.git.andreyknvl@google.com>
 <52d2542323262ede3510754bb07cbc1ed8c347b0.1525798754.git.andreyknvl@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <0043ffdf-4a75-d41c-966e-073eac3dc557@virtuozzo.com>
Date: Tue, 15 May 2018 17:06:45 +0300
MIME-Version: 1.0
In-Reply-To: <52d2542323262ede3510754bb07cbc1ed8c347b0.1525798754.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Yury Norov <ynorov@caviumnetworks.com>, Marc Zyngier <marc.zyngier@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, James Morse <james.morse@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Julien Thierry <julien.thierry@arm.com>, Tyler Baicar <tbaicar@codeaurora.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Kees Cook <keescook@chromium.org>, Sandipan Das <sandipan@linux.vnet.ibm.com>, David Woodhouse <dwmw@amazon.co.uk>, Paul Lawrence <paullawrence@google.com>, Herbert Xu <herbert@gondor.apana.org.au>, Josh Poimboeuf <jpoimboe@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Tom Lendacky <thomas.lendacky@amd.com>, Arnd Bergmann <arnd@arndb.de>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Souptick Joarder <jrdr.linux@gmail.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, Laura Abbott <labbott@redhat.com>, Boris Brezillon <boris.brezillon@bootlin.com>, Vlastimil Babka <vbabka@suse.cz>, Pintu Agarwal <pintu.ping@gmail.com>, Doug Berger <opendmb@gmail.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Pavel Tatashin <pasha.tatashin@oracle.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>



On 05/08/2018 08:21 PM, Andrey Konovalov wrote:

> +#ifndef CONFIG_KASAN_HW
>  #define page_to_virt(page)	((void *)((__page_to_voff(page)) | PAGE_OFFSET))
> +#else
> +#define page_to_virt(page)	({					\
> +	unsigned long __addr =						\
> +		((__page_to_voff(page)) | PAGE_OFFSET);			\
> +	if (!PageSlab((struct page *)page))				\
> +		__addr = KASAN_SET_TAG(__addr, page_kasan_tag(page));	\

You could avoid 'if (!PageSlab())' check by adding page_kasan_tag_reset() into kasan_poison_slab().


> +	((void *)__addr);						\
> +})
> +#endif
> +
>  #define virt_to_page(vaddr)	((struct page *)((__virt_to_pgoff(vaddr)) | VMEMMAP_START))
>  
>  #define _virt_addr_valid(kaddr)	pfn_valid((((u64)(kaddr) & ~PAGE_OFFSET) \



> diff --git a/mm/cma.c b/mm/cma.c
> index aa40e6c7b042..f657db289bba 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -526,6 +526,7 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align,
>  	}
>  
>  	trace_cma_alloc(pfn, page, count, align);
> +	page_kasan_tag_reset(page);
  

Why? Comment needed.


>  	if (ret && !(gfp_mask & __GFP_NOWARN)) {
>  		pr_err("%s: alloc failed, req-size: %zu pages, ret: %d\n",
> diff --git a/mm/kasan/common.c b/mm/kasan/common.c
> index 0654bf97257b..7cd4a4e8c3be 100644
> --- a/mm/kasan/common.c
> +++ b/mm/kasan/common.c
> @@ -207,8 +207,18 @@ void kasan_unpoison_stack_above_sp_to(const void *watermark)
>  
>  void kasan_alloc_pages(struct page *page, unsigned int order)
>  {
> +#ifdef CONFIG_KASAN_GENERIC
>  	if (likely(!PageHighMem(page)))
>  		kasan_unpoison_shadow(page_address(page), PAGE_SIZE << order);
> +#else
> +	if (!PageSlab(page)) {
> +		u8 tag = random_tag();
> +
> +		kasan_poison_shadow(page_address(page), PAGE_SIZE << order,
> +					tag);
> +		page_kasan_tag_set(page, tag);
> +	}
> +#endif
>  }


diff --git a/mm/kasan/common.c b/mm/kasan/common.c
index b8e0a8215021..f9f2181164a2 100644
--- a/mm/kasan/common.c
+++ b/mm/kasan/common.c
@@ -207,18 +207,11 @@ void kasan_unpoison_stack_above_sp_to(const void *watermark)
 
 void kasan_alloc_pages(struct page *page, unsigned int order)
 {
-#ifdef CONFIG_KASAN_GENERIC
-	if (likely(!PageHighMem(page)))
-		kasan_unpoison_shadow(page_address(page), PAGE_SIZE << order);
-#else
-	if (!PageSlab(page)) {
-		u8 tag = random_tag();
+	if (unlikely(PageHighMem(page)))
+		return;
 
-		kasan_poison_shadow(page_address(page), PAGE_SIZE << order,
-					tag);
-		page_kasan_tag_set(page, tag);
-	}
-#endif
+	page_kasan_tag_set(page, random_tag());
+	kasan_unpoison_shadow(page_address(page), PAGE_SIZE << order);
 }
 
 void kasan_free_pages(struct page *page, unsigned int order)
-- 
2.16.1


>  
>  void kasan_free_pages(struct page *page, unsigned int order)
> @@ -433,6 +443,7 @@ void *kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags)
>  #else
>  	tag = random_tag();
>  	kasan_poison_shadow(ptr, redzone_start - (unsigned long)ptr, tag);
> +	page_kasan_tag_set(page, tag);

As already said before no changes needed in kasan_kmalloc_large. kasan_alloc_pages() alredy did tag_set().

>  #endif
>  	kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_start,
>  		KASAN_PAGE_REDZONE);
> @@ -462,7 +473,7 @@ void kasan_poison_kfree(void *ptr, unsigned long ip)
>  	page = virt_to_head_page(ptr);
>  
>  	if (unlikely(!PageSlab(page))) {
> -		if (reset_tag(ptr) != page_address(page)) {
> +		if (ptr != page_address(page)) {
>  			kasan_report_invalid_free(ptr, ip);
>  			return;
>  		}
> @@ -475,7 +486,7 @@ void kasan_poison_kfree(void *ptr, unsigned long ip)
>  
>  void kasan_kfree_large(void *ptr, unsigned long ip)
>  {
> -	if (reset_tag(ptr) != page_address(virt_to_head_page(ptr)))
> +	if (ptr != page_address(virt_to_head_page(ptr)))
>  		kasan_report_invalid_free(ptr, ip);
>  	/* The object will be poisoned by page_alloc. */
>  }
