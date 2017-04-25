Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id EE8226B0388
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 12:44:13 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id m79so100402738oik.5
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 09:44:13 -0700 (PDT)
Received: from mail-oi0-x231.google.com (mail-oi0-x231.google.com. [2607:f8b0:4003:c06::231])
        by mx.google.com with ESMTPS id 23si12769236otc.329.2017.04.25.09.44.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 09:44:13 -0700 (PDT)
Received: by mail-oi0-x231.google.com with SMTP id j201so178539625oih.2
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 09:44:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170425131904.nu5dlhweblwzyeit@black.fi.intel.com>
References: <CAA9_cmf7=aGXKoQFkzS_UJtznfRtWofitDpV2AyGwpaRGKyQkg@mail.gmail.com>
 <20170423233125.nehmgtzldgi25niy@node.shutemov.name> <CAPcyv4i8mBOCuA8k-A8RXGMibbnqHUsa3Ly+YcQbr0eCdjruUw@mail.gmail.com>
 <20170424173021.ayj3hslvfrrgrie7@node.shutemov.name> <CAPcyv4g74LT6sK2WgG6FnwQHCC5fNTwfqBPq1BY8PnZ7zwdGPw@mail.gmail.com>
 <20170424180158.y26m3kgzhpmawbhg@node.shutemov.name> <20170424182555.faoarzlpi4ilm5dt@black.fi.intel.com>
 <CAPcyv4iFhpSo-nbypHuZVZz7S92PwPx17bxUgMsksRHYPQkqEA@mail.gmail.com> <20170425131904.nu5dlhweblwzyeit@black.fi.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 25 Apr 2017 09:44:12 -0700
Message-ID: <CAPcyv4h7+Rgs83JefhJajHtitPWUFEKKgUt-_e-bqhQZM5L2FA@mail.gmail.com>
Subject: Re: get_zone_device_page() in get_page() and page_cache_get_speculative()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Linux MM <linux-mm@kvack.org>, Catalin Marinas <catalin.marinas@arm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Steve Capper <steve.capper@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@redhat.com>, Dann Frazier <dann.frazier@canonical.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-tip-commits@vger.kernel.org

On Tue, Apr 25, 2017 at 6:19 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> On Mon, Apr 24, 2017 at 11:41:51AM -0700, Dan Williams wrote:
>> On Mon, Apr 24, 2017 at 11:25 AM, Kirill A. Shutemov
>> <kirill.shutemov@linux.intel.com> wrote:
>> > On Mon, Apr 24, 2017 at 09:01:58PM +0300, Kirill A. Shutemov wrote:
>> >> On Mon, Apr 24, 2017 at 10:47:43AM -0700, Dan Williams wrote:
>> >> I think it's still better to do it on page_ref_* level.
>> >
>> > Something like patch below? What do you think?
>>
>> From a quick glance, I think this looks like the right way to go.
>
> Okay, but I still would like to remove manipulation with pgmap->ref from
> hot path.
>
> Can we just check that page_count() match our expectation on
> devm_memremap_pages_release() instead of this?
>
> I probably miss something in bigger picture, but would something like
> patch work too? It seems work for the test case.

No, unfortunately this is broken. It should be perfectly legal to
start the driver shutdown process while page references are still
outstanding. We use the percpu-ref infrastructure to wait for those
references to be dropped. With the approach below we'll just race and
crash.

>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index a835edd2db34..695da2a19b4c 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -762,19 +762,11 @@ static inline enum zone_type page_zonenum(const struct page *page)
>  }
>
>  #ifdef CONFIG_ZONE_DEVICE
> -void get_zone_device_page(struct page *page);
> -void put_zone_device_page(struct page *page);
>  static inline bool is_zone_device_page(const struct page *page)
>  {
>         return page_zonenum(page) == ZONE_DEVICE;
>  }
>  #else
> -static inline void get_zone_device_page(struct page *page)
> -{
> -}
> -static inline void put_zone_device_page(struct page *page)
> -{
> -}
>  static inline bool is_zone_device_page(const struct page *page)
>  {
>         return false;
> @@ -790,9 +782,6 @@ static inline void get_page(struct page *page)
>          */
>         VM_BUG_ON_PAGE(page_ref_count(page) <= 0, page);
>         page_ref_inc(page);
> -
> -       if (unlikely(is_zone_device_page(page)))
> -               get_zone_device_page(page);
>  }
>
>  static inline void put_page(struct page *page)
> @@ -801,9 +790,6 @@ static inline void put_page(struct page *page)
>
>         if (put_page_testzero(page))
>                 __put_page(page);
> -
> -       if (unlikely(is_zone_device_page(page)))
> -               put_zone_device_page(page);
>  }
>
>  #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index 07e85e5229da..e542bb2f7ab0 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -182,18 +182,6 @@ struct page_map {
>         struct vmem_altmap altmap;
>  };
>
> -void get_zone_device_page(struct page *page)
> -{
> -       percpu_ref_get(page->pgmap->ref);
> -}
> -EXPORT_SYMBOL(get_zone_device_page);
> -
> -void put_zone_device_page(struct page *page)
> -{
> -       put_dev_pagemap(page->pgmap);
> -}
> -EXPORT_SYMBOL(put_zone_device_page);
> -
>  static void pgmap_radix_release(struct resource *res)
>  {
>         resource_size_t key, align_start, align_size, align_end;
> @@ -237,12 +225,21 @@ static void devm_memremap_pages_release(struct device *dev, void *data)
>         struct resource *res = &page_map->res;
>         resource_size_t align_start, align_size;
>         struct dev_pagemap *pgmap = &page_map->pgmap;
> +       unsigned long pfn;
>
>         if (percpu_ref_tryget_live(pgmap->ref)) {
>                 dev_WARN(dev, "%s: page mapping is still live!\n", __func__);
>                 percpu_ref_put(pgmap->ref);
>         }
>
> +       for_each_device_pfn(pfn, page_map) {
> +               struct page *page = pfn_to_page(pfn);
> +
> +               dev_WARN_ONCE(dev, page_count(page) != 1,
> +                               "%s: unexpected page count: %d!\n",
> +                               __func__, page_count(page));
> +       }
> +
>         /* pages are dead and unused, undo the arch mapping */
>         align_start = res->start & ~(SECTION_SIZE - 1);
>         align_size = ALIGN(resource_size(res), SECTION_SIZE);
> --
>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
