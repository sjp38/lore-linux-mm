Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B3F636B0003
	for <linux-mm@kvack.org>; Sat, 24 Feb 2018 09:28:34 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id j21so5682328pff.12
        for <linux-mm@kvack.org>; Sat, 24 Feb 2018 06:28:34 -0800 (PST)
Received: from huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id z19si3018421pgc.353.2018.02.24.06.28.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Feb 2018 06:28:33 -0800 (PST)
From: "Liuwenliang (Abbott Liu)" <liuwenliang@huawei.com>
Subject: Re: [PATCH 01/11] Initialize the mapping of KASan shadow memory
Date: Sat, 24 Feb 2018 14:28:26 +0000
Message-ID: <B8AC3E80E903784988AB3003E3E97330C0072EF7@dggemm510-mbs.china.huawei.com>
References: <20171011082227.20546-1-liuwenliang@huawei.com>
 <20171011082227.20546-2-liuwenliang@huawei.com>
 <20171019110921.GS20805@n2100.armlinux.org.uk>
In-Reply-To: <20171019110921.GS20805@n2100.armlinux.org.uk>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Cc: "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, "labbott@redhat.com" <labbott@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "cdall@linaro.org" <cdall@linaro.org>, "marc.zyngier@arm.com" <marc.zyngier@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "thgarnie@google.com" <thgarnie@google.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "mingo@kernel.org" <mingo@kernel.org>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "glider@google.com" <glider@google.com>, "dvyukov@google.com" <dvyukov@google.com>, "opendmb@gmail.com" <opendmb@gmail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Oct 19, 2017 at 19:09, Russell King - ARM Linux [mailto:linux@armlinux.o=
rg.uk] wrote:
>On Wed, Oct 11, 2017 at 04:22:17PM +0800, Abbott Liu wrote:
>> +#else
>> +#define pud_populate(mm,pmd,pte)	do { } while (0)
>> +#endif
>
>Please explain this change - we don't have a "pud" as far as the rest of
>the Linux MM layer is concerned, so why do we need it for kasan?
>
>I suspect it comes from the way we wrap up the page tables - where ARM
>does it one way (because it has to) vs the subsequently merged method
>which is completely upside down to what ARMs doing, and therefore is
>totally incompatible and impossible to fit in with our way.

We will use pud_polulate in kasan_populate_zero_shadow function.
....
>>  obj-$(CONFIG_CACHE_TAUROS2)	+=3D cache-tauros2.o
>> +
>> +KASAN_SANITIZE_kasan_init.o    :=3D n
>> +obj-$(CONFIG_KASAN)            +=3D kasan_init.o
>
>Why is this placed in the middle of the cache object listing?

Sorry, I will place this at the end of the arch/arm/mm/Makefile.
>> +
>> +
>>  obj-$(CONFIG_CACHE_UNIPHIER)	+=3D cache-uniphier.o
...

>> +pgd_t * __meminit kasan_pgd_populate(unsigned long addr, int node)
>> +{
>> +	pgd_t *pgd =3D pgd_offset_k(addr);
>> +	if (pgd_none(*pgd)) {
>> +		void *p =3D kasan_alloc_block(PAGE_SIZE, node);
>> +		if (!p)
>> +			return NULL;
>> +		pgd_populate(&init_mm, pgd, p);
>> +	}
>> +	return pgd;
>> +}

>This all looks wrong - you are aware that on non-LPAE platforms, there
>is only a _two_ level page table - the top level page table is 16K in
>size, and each _individual_ lower level page table is actually 1024
>bytes, but we do some special handling in the kernel to combine two
>together.  It looks to me that you allocate memory for each Linux-
>abstracted page table level whether the hardware needs it or not.

You are right. If non-LPAE platform check if(pgd_none(*pgd)) true,
void *p =3D kasan_alloc_block(PAGE_SIZE, node) alloc space is not enough.
But the the function kasan_pgd_populate only used in :
Kasan_init-> create_mapping-> kasan_pgd_populate , so when non-LPAE platfor=
m
the if (pgd_none(*pgd)) always false.
But I also think change those code is much better :
if (IS_ENABLED(CONFIG_ARM_LPAE)) {
   p =3D kasan_alloc_block(PAGE_SIZE, node);
} else {
   /* non-LPAE need 16K for first level pagetabe*/
   p =3D kasan_alloc_block(PAGE_SIZE*4, node);
}

>Is there any reason why the pre-existing "create_mapping()" function
>can't be used, and you've had to rewrite that code here?

Two reason:
1) Here create_mapping can dynamic alloc phys memory space for mapping to v=
irtual space=20
Which from start to end, but the create_mapping in arch/arm/mm/mmu.c can't.
2) for LPAE, create_mapping need alloc pgd which we need use virtual space =
below 0xc0000000,
 here create_mapping can alloc pgd, but create_mapping in arch/arm/mm/mmu.c=
 can't.

>> +
>> +static int __init create_mapping(unsigned long start, unsigned long end=
, int node)
>> +{
>> +	unsigned long addr =3D start;
>> +	pgd_t *pgd;
>> +	pud_t *pud;
>> +	pmd_t *pmd;
>> +	pte_t *pte;
>
>A blank line would help between the auto variables and the code of the
>function.

Ok, I will add blank line in new version.
>> +	pr_info("populating shadow for %lx, %lx\n", start, end);
>
>Blank line here too please.

Ok, I will add blank line in new version.

>> +	for (; addr < end; addr +=3D PAGE_SIZE) {
>> +		pgd =3D kasan_pgd_populate(addr, node);
>> +		if (!pgd)
>> +			return -ENOMEM;
...
>> +void __init kasan_init(void)
>> +{
>> +	struct memblock_region *reg;
>> +	u64 orig_ttbr0;
>> +
>> +	orig_ttbr0 =3D cpu_get_ttbr(0);
>> +
>> +#ifdef CONFIG_ARM_LPAE
>> +	memcpy(tmp_pmd_table, pgd_page_vaddr(*pgd_offset_k(KASAN_SHADOW_START)=
), sizeof(tmp_pmd_table));
>> +	memcpy(tmp_page_table, swapper_pg_dir, sizeof(tmp_page_table));
>> +	set_pgd(&tmp_page_table[pgd_index(KASAN_SHADOW_START)], __pgd(__pa(tmp=
_pmd_table) | PMD_TYPE_TABLE | L_PGD_SWAPPER));
>> +	cpu_set_ttbr0(__pa(tmp_page_table));
>> +#else
>> +	memcpy(tmp_page_table, swapper_pg_dir, sizeof(tmp_page_table));
>> +	cpu_set_ttbr0(__pa(tmp_page_table));
>> +#endif
>> +	flush_cache_all();
>> +	local_flush_bp_all();
>> +	local_flush_tlb_all();

>What are you trying to achieve with all this complexity?  Some comments
>might be useful, especially for those of us who don't know the internals
>of kasan.
OK, I will add some comments in kasan_init function in new version.
...
>> +	for_each_memblock(memory, reg) {
>> +		void *start =3D __va(reg->base);
>> +		void *end =3D __va(reg->base + reg->size);
>
>Isn't this going to complain if the translation macro debugging is enabled=
?

Sorry, I don't what is the translation macro. Can you tell me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
