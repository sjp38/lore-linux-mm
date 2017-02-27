Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 50C916B0038
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 04:35:11 -0500 (EST)
Received: by mail-ua0-f200.google.com with SMTP id 72so30535263uaf.7
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 01:35:11 -0800 (PST)
Received: from mail-ua0-x236.google.com (mail-ua0-x236.google.com. [2607:f8b0:400c:c08::236])
        by mx.google.com with ESMTPS id r202si2203471vkf.177.2017.02.27.01.35.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 01:35:10 -0800 (PST)
Received: by mail-ua0-x236.google.com with SMTP id e4so15918052uae.0
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 01:35:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAPcyv4iwhkW+cLbsT1Ns4=DhnfvZvdhbEVmj0zZcS+PRP6GMpA@mail.gmail.com>
References: <20170215205826.13356-1-nicstange@gmail.com> <CAPcyv4iwhkW+cLbsT1Ns4=DhnfvZvdhbEVmj0zZcS+PRP6GMpA@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 27 Feb 2017 10:34:49 +0100
Message-ID: <CACT4Y+aHwos6PyYhRGx6Hn1xQkSkf1vWgzbYVdC=eLA8MknHeg@mail.gmail.com>
Subject: Re: [RFC 0/3] Regressions due to 7b79d10a2d64 ("mm: convert
 kmalloc_section_memmap() to populate_section_memmap()") and Kasan
 initialization on
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Nicolai Stange <nicstange@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Alexander Potapenko <glider@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev <kasan-dev@googlegroups.com>

On Sat, Feb 25, 2017 at 8:03 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> [ adding kasan folks ]
>
> On Wed, Feb 15, 2017 at 12:58 PM, Nicolai Stange <nicstange@gmail.com> wrote:
>> Hi Dan,
>>
>> your recent commit 7b79d10a2d64 ("mm: convert kmalloc_section_memmap() to
>> populate_section_memmap()") seems to cause some issues with respect to
>> Kasan initialization on x86.
>>
>> This is because Kasan's initialization (ab)uses the arch provided
>> vmemmap_populate().
>>
>> The first one is a boot failure, see [1/3]. The commit before the
>> aforementioned one works fine.
>>
>> The second one, i.e. [2/3], is something that hit my eye while browsing
>> the source and I verified that this is indeed an issue by printk'ing and
>> dumping the page tables.
>>
>> The third one are excessive warnings from vmemmap_verify() due to Kasan's
>> NUMA_NO_NODE page populations.
>>
>>
>> I'll be travelling the next two days and certainly not be able to respond
>> or polish these patches any further. Furthermore, the next merge window is
>> close. So please, take these three patches as bug reports only, meant to
>> illustrate the issues. Feel free to use, change and adopt them however
>> you deemed best.
>>
>> That being said,
>> - [2/3] will break arm64 due to the current lack of a pmd_large().
>> - Maybe it's easier and better to restore former behaviour by letting
>>   Kasan's shadow initialization on x86 use vmemmap_populate_hugepages()
>>   directly rather than vmemmap_populate(). This would require x86_64
>>   implying X86_FEATURE_PSE though. I'm not sure whether this holds,
>>   in particular not since the vmemmap_populate() from
>>   arch/x86/mm/init_64.c checks for it.
>
> I think your intuition is correct here, and yes, it is a safe
> assumption that x86_64 implies X86_FEATURE_PSE. The following patch
> works for me. If there's no objections I'll roll it into the series
> and resubmit the sub-section hotplug support after testing on top of
> 4.11-rc1.
>
> --- gmail mangled-whitespace patch follows ---
>
> Subject: x86, kasan: clarify kasan's dependency on vmemmap_populate_hugepages()
>
> From: Dan Williams <dan.j.williams@intel.com>
>
> Historically kasan has not been careful about whether vmemmap_populate()
> internally allocates a section worth of memmap even if the parameters
> call for less.  For example, a request to shadow map a single page is
> internally results in mapping the full section (128MB) that contains
> that page. Also, kasan has not been careful to handle cases where this
> section promotion causes overlaps / overrides of previous calls to
> vmemmap_populate().
>
> Before we teach vmemmap_populate() to support sub-section hotplug,
> arrange for kasan to explicitly avoid vmemmap_populate_basepages().
> This should be functionally equivalent to the current state since
> CONFIG_KASAN requires x86_64 (implies PSE) and it does not collide with
> sub-section hotplug support since CONFIG_KASAN disables
> CONFIG_MEMORY_HOTPLUG.
>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: Alexander Potapenko <glider@google.com>
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Reported-by: Nicolai Stange <nicstange@gmail.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  arch/x86/mm/init_64.c       |    2 +-
>  arch/x86/mm/kasan_init_64.c |   30 ++++++++++++++++++++++++++----
>  include/linux/mm.h          |    2 ++
>  3 files changed, 29 insertions(+), 5 deletions(-)
>
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index af85b686a7b0..32e0befcbfe8 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -1157,7 +1157,7 @@ static long __meminitdata addr_start, addr_end;
>  static void __meminitdata *p_start, *p_end;
>  static int __meminitdata node_start;
>
> -static int __meminit vmemmap_populate_hugepages(unsigned long start,
> +int __meminit vmemmap_populate_hugepages(unsigned long start,
>   unsigned long end, int node, struct vmem_altmap *altmap)
>  {
>   unsigned long addr;
> diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
> index 0493c17b8a51..4cfc0fb43af3 100644
> --- a/arch/x86/mm/kasan_init_64.c
> +++ b/arch/x86/mm/kasan_init_64.c
> @@ -12,6 +12,25 @@
>  extern pgd_t early_level4_pgt[PTRS_PER_PGD];
>  extern struct range pfn_mapped[E820_X_MAX];
>
> +static int __init kasan_vmemmap_populate(unsigned long start,
> unsigned long end)
> +{
> + /*
> + * Historically kasan has not been careful about whether
> + * vmemmap_populate() internally allocates a section worth of memmap
> + * even if the parameters call for less.  For example, a request to
> + * shadow map a single page is internally results in mapping the full
> + * section (128MB) that contains that page.  Also, kasan has not been
> + * careful to handle cases where this section promotion causes overlaps
> + * / overrides of previous calls to vmemmap_populate(). Make this
> + * implicit dependency explicit to avoid interactions with sub-section
> + * memory hotplug support.
> + */
> + if (!boot_cpu_has(X86_FEATURE_PSE))
> + return -ENXIO;
> +
> + return vmemmap_populate_hugepages(start, end, NUMA_NO_NODE, NULL);
> +}
> +
>  static int __init map_range(struct range *range)
>  {
>   unsigned long start;
> @@ -25,7 +44,7 @@ static int __init map_range(struct range *range)
>   * to slightly speed up fastpath. In some rare cases we could cross
>   * boundary of mapped shadow, so we just map some more here.
>   */
> - return vmemmap_populate(start, end + 1, NUMA_NO_NODE);
> + return kasan_vmemmap_populate(start, end + 1);
>  }
>
>  static void __init clear_pgds(unsigned long start,
> @@ -89,6 +108,10 @@ void __init kasan_init(void)
>  {
>   int i;
>
> + /* should never trigger, x86_64 implies PSE */
> + WARN(!boot_cpu_has(X86_FEATURE_PSE),
> + "kasan requires page size extensions\n");
> +
>  #ifdef CONFIG_KASAN_INLINE
>   register_die_notifier(&kasan_die_notifier);
>  #endif
> @@ -113,9 +136,8 @@ void __init kasan_init(void)
>   kasan_mem_to_shadow((void *)PAGE_OFFSET + MAXMEM),
>   kasan_mem_to_shadow((void *)__START_KERNEL_map));
>
> - vmemmap_populate((unsigned long)kasan_mem_to_shadow(_stext),
> - (unsigned long)kasan_mem_to_shadow(_end),
> - NUMA_NO_NODE);
> + kasan_vmemmap_populate((unsigned long)kasan_mem_to_shadow(_stext),
> + (unsigned long)kasan_mem_to_shadow(_end));
>
>   kasan_populate_zero_shadow(kasan_mem_to_shadow((void *)MODULES_END),
>   (void *)KASAN_SHADOW_END);
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index b84615b0f64c..fb3e84aec5c4 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2331,6 +2331,8 @@ void vmemmap_verify(pte_t *, int, unsigned long,
> unsigned long);
>  int vmemmap_populate_basepages(unsigned long start, unsigned long end,
>         int node);
>  int vmemmap_populate(unsigned long start, unsigned long end, int node);
> +int vmemmap_populate_hugepages(unsigned long start, unsigned long
> end, int node,
> + struct vmem_altmap *altmap);
>  void vmemmap_populate_print_last(void);
>  #ifdef CONFIG_MEMORY_HOTPLUG
>  void vmemmap_free(unsigned long start, unsigned long end);


+kasan-dev

Andrey, do you mind looking at this?

What is the manifestation of the problem? I have kasan bots on tip of
upstream/mmotm/linux-next and they seem to be working.

Re the added comment: is it true that we are wasting up to 128MB per
region? We have some small ones (like text). So is it something to fix
in future?

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
