Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id AE2436B0256
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 16:32:49 -0500 (EST)
Received: by mail-qk0-f178.google.com with SMTP id x1so29712766qkc.1
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 13:32:49 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t105si19617040qgd.119.2016.01.29.13.32.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 13:32:49 -0800 (PST)
Subject: Re: [PATCHv2 2/2] mm/page_poisoning.c: Allow for zero poisoning
References: <1454035099-31583-1-git-send-email-labbott@fedoraproject.org>
 <1454035099-31583-3-git-send-email-labbott@fedoraproject.org>
 <CAGXu5jL2MJkJS8H7Gxbtw1P+FREa2XgF_7xkVMgqSvGXRLWAJw@mail.gmail.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <56ABDA7C.5080206@redhat.com>
Date: Fri, 29 Jan 2016 13:32:44 -0800
MIME-Version: 1.0
In-Reply-To: <CAGXu5jL2MJkJS8H7Gxbtw1P+FREa2XgF_7xkVMgqSvGXRLWAJw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@fedoraproject.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, linux-pm@vger.kernel.org

On 01/28/2016 08:46 PM, Kees Cook wrote:
> On Thu, Jan 28, 2016 at 6:38 PM, Laura Abbott <labbott@fedoraproject.org> wrote:
>> By default, page poisoning uses a poison value (0xaa) on free. If this
>> is changed to 0, the page is not only sanitized but zeroing on alloc
>> with __GFP_ZERO can be skipped as well. The tradeoff is that detecting
>> corruption from the poisoning is harder to detect. This feature also
>> cannot be used with hibernation since pages are not guaranteed to be
>> zeroed after hibernation.
>>
>> Credit to Grsecurity/PaX team for inspiring this work
>>
>> Signed-off-by: Laura Abbott <labbott@fedoraproject.org>
>> ---
>>   include/linux/mm.h       |  2 ++
>>   include/linux/poison.h   |  4 ++++
>>   kernel/power/hibernate.c | 17 +++++++++++++++++
>>   mm/Kconfig.debug         | 14 ++++++++++++++
>>   mm/page_alloc.c          | 11 ++++++++++-
>>   mm/page_ext.c            | 10 ++++++++--
>>   mm/page_poison.c         |  7 +++++--
>>   7 files changed, 60 insertions(+), 5 deletions(-)
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index 966bf0e..59ce0dc 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -2177,10 +2177,12 @@ extern int apply_to_page_range(struct mm_struct *mm, unsigned long address,
>>   #ifdef CONFIG_PAGE_POISONING
>>   extern bool page_poisoning_enabled(void);
>>   extern void kernel_poison_pages(struct page *page, int numpages, int enable);
>> +extern bool page_is_poisoned(struct page *page);
>>   #else
>>   static inline bool page_poisoning_enabled(void) { return false; }
>>   static inline void kernel_poison_pages(struct page *page, int numpages,
>>                                          int enable) { }
>> +static inline bool page_is_poisoned(struct page *page) { return false; }
>>   #endif
>>
>>   #ifdef CONFIG_DEBUG_PAGEALLOC
>> diff --git a/include/linux/poison.h b/include/linux/poison.h
>> index 4a27153..51334ed 100644
>> --- a/include/linux/poison.h
>> +++ b/include/linux/poison.h
>> @@ -30,7 +30,11 @@
>>   #define TIMER_ENTRY_STATIC     ((void *) 0x300 + POISON_POINTER_DELTA)
>>
>>   /********** mm/debug-pagealloc.c **********/
>> +#ifdef CONFIG_PAGE_POISONING_ZERO
>> +#define PAGE_POISON 0x00
>> +#else
>>   #define PAGE_POISON 0xaa
>> +#endif
>>
>>   /********** mm/page_alloc.c ************/
>>
>> diff --git a/kernel/power/hibernate.c b/kernel/power/hibernate.c
>> index b7342a2..aa0f26b 100644
>> --- a/kernel/power/hibernate.c
>> +++ b/kernel/power/hibernate.c
>> @@ -1158,6 +1158,22 @@ static int __init kaslr_nohibernate_setup(char *str)
>>          return nohibernate_setup(str);
>>   }
>>
>> +static int __init page_poison_nohibernate_setup(char *str)
>> +{
>> +#ifdef CONFIG_PAGE_POISONING_ZERO
>> +       /*
>> +        * The zeroing option for page poison skips the checks on alloc.
>> +        * since hibernation doesn't save free pages there's no way to
>> +        * guarantee the pages will still be zeroed.
>> +        */
>> +       if (!strcmp(str, "on")) {
>> +               pr_info("Disabling hibernation due to page poisoning\n");
>> +               return nohibernate_setup(str);
>> +       }
>> +#endif
>> +       return 1;
>> +}
>> +
>>   __setup("noresume", noresume_setup);
>>   __setup("resume_offset=", resume_offset_setup);
>>   __setup("resume=", resume_setup);
>> @@ -1166,3 +1182,4 @@ __setup("resumewait", resumewait_setup);
>>   __setup("resumedelay=", resumedelay_setup);
>>   __setup("nohibernate", nohibernate_setup);
>>   __setup("kaslr", kaslr_nohibernate_setup);
>> +__setup("page_poison=", page_poison_nohibernate_setup);
>> diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
>> index 25c98ae..3d3b954 100644
>> --- a/mm/Kconfig.debug
>> +++ b/mm/Kconfig.debug
>> @@ -48,3 +48,17 @@ config PAGE_POISONING_NO_SANITY
>>
>>             If you are only interested in sanitization, say Y. Otherwise
>>             say N.
>> +
>> +config PAGE_POISONING_ZERO
>> +       bool "Use zero for poisoning instead of random data"
>> +       depends on PAGE_POISONING
>> +       ---help---
>> +          Instead of using the existing poison value, fill the pages with
>> +          zeros. This makes it harder to detect when errors are occurring
>> +          due to sanitization but the zeroing at free means that it is
>> +          no longer necessary to write zeros when GFP_ZERO is used on
>> +          allocation.
>
> May be worth noting the security benefit in this help text.
>

This is supposed to build on the existing page poisoning which mentions the
security bit. I think this text needs to be clarified how this works.
  
>> +
>> +          Enabling page poisoning with this option will disable hibernation
>
> This isn't obvious to me. It looks like you need to both use
> CONFIG_PAGE_POISOING_ZERO and put "page_poison=on" on the command line
> to enable it?

Yeah, this isn't really clear. I'll make it more obvious this is an extension
of page poisoning so page poisoning must be enabled first.

>
> -Kees
>

Thanks,
Laura
  
>> +
>> +          If unsure, say N
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index cc4762a..59bd9dc 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -1382,15 +1382,24 @@ static inline int check_new_page(struct page *page)
>>          return 0;
>>   }
>>
>> +static inline bool free_pages_prezeroed(bool poisoned)
>> +{
>> +       return IS_ENABLED(CONFIG_PAGE_POISONING_ZERO) &&
>> +               page_poisoning_enabled() && poisoned;
>> +}
>> +
>>   static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
>>                                                                  int alloc_flags)
>>   {
>>          int i;
>> +       bool poisoned = true;
>>
>>          for (i = 0; i < (1 << order); i++) {
>>                  struct page *p = page + i;
>>                  if (unlikely(check_new_page(p)))
>>                          return 1;
>> +               if (poisoned)
>> +                       poisoned &= page_is_poisoned(p);
>>          }
>>
>>          set_page_private(page, 0);
>> @@ -1401,7 +1410,7 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
>>          kernel_poison_pages(page, 1 << order, 1);
>>          kasan_alloc_pages(page, order);
>>
>> -       if (gfp_flags & __GFP_ZERO)
>> +       if (!free_pages_prezeroed(poisoned) && (gfp_flags & __GFP_ZERO))
>>                  for (i = 0; i < (1 << order); i++)
>>                          clear_highpage(page + i);
>>
>> diff --git a/mm/page_ext.c b/mm/page_ext.c
>> index 292ca7b..2d864e6 100644
>> --- a/mm/page_ext.c
>> +++ b/mm/page_ext.c
>> @@ -106,12 +106,15 @@ struct page_ext *lookup_page_ext(struct page *page)
>>          struct page_ext *base;
>>
>>          base = NODE_DATA(page_to_nid(page))->node_page_ext;
>> -#ifdef CONFIG_DEBUG_VM
>> +#if defined(CONFIG_DEBUG_VM) || defined(CONFIG_PAGE_POISONING)
>>          /*
>>           * The sanity checks the page allocator does upon freeing a
>>           * page can reach here before the page_ext arrays are
>>           * allocated when feeding a range of pages to the allocator
>>           * for the first time during bootup or memory hotplug.
>> +        *
>> +        * This check is also necessary for ensuring page poisoning
>> +        * works as expected when enabled
>>           */
>>          if (unlikely(!base))
>>                  return NULL;
>> @@ -180,12 +183,15 @@ struct page_ext *lookup_page_ext(struct page *page)
>>   {
>>          unsigned long pfn = page_to_pfn(page);
>>          struct mem_section *section = __pfn_to_section(pfn);
>> -#ifdef CONFIG_DEBUG_VM
>> +#if defined(CONFIG_DEBUG_VM) || defined(CONFIG_PAGE_POISONING)
>>          /*
>>           * The sanity checks the page allocator does upon freeing a
>>           * page can reach here before the page_ext arrays are
>>           * allocated when feeding a range of pages to the allocator
>>           * for the first time during bootup or memory hotplug.
>> +        *
>> +        * This check is also necessary for ensuring page poisoning
>> +        * works as expected when enabled
>>           */
>>          if (!section->page_ext)
>>                  return NULL;
>> diff --git a/mm/page_poison.c b/mm/page_poison.c
>> index 89d3bc7..479e7ea 100644
>> --- a/mm/page_poison.c
>> +++ b/mm/page_poison.c
>> @@ -71,11 +71,14 @@ static inline void clear_page_poison(struct page *page)
>>          __clear_bit(PAGE_EXT_DEBUG_POISON, &page_ext->flags);
>>   }
>>
>> -static inline bool page_poison(struct page *page)
>> +bool page_is_poisoned(struct page *page)
>>   {
>>          struct page_ext *page_ext;
>>
>>          page_ext = lookup_page_ext(page);
>> +       if (!page_ext)
>> +               return false;
>> +
>>          return test_bit(PAGE_EXT_DEBUG_POISON, &page_ext->flags);
>>   }
>>
>> @@ -137,7 +140,7 @@ static void unpoison_page(struct page *page)
>>   {
>>          void *addr;
>>
>> -       if (!page_poison(page))
>> +       if (!page_is_poisoned(page))
>>                  return;
>>
>>          addr = kmap_atomic(page);
>> --
>> 2.5.0
>>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
