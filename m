Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id AD2EB6B0036
	for <linux-mm@kvack.org>; Thu, 14 Aug 2014 23:36:17 -0400 (EDT)
Received: by mail-ig0-f172.google.com with SMTP id h15so844067igd.17
        for <linux-mm@kvack.org>; Thu, 14 Aug 2014 20:36:17 -0700 (PDT)
Received: from mail-ig0-x234.google.com (mail-ig0-x234.google.com [2607:f8b0:4001:c05::234])
        by mx.google.com with ESMTPS id fs5si736707igb.9.2014.08.14.20.36.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 14 Aug 2014 20:36:16 -0700 (PDT)
Received: by mail-ig0-f180.google.com with SMTP id l13so823282iga.7
        for <linux-mm@kvack.org>; Thu, 14 Aug 2014 20:36:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140814220704.GB26367@optiplex.redhat.com>
References: <CAPAsAGwk7kF6XtJNz6Y41zn0SHHzEt1Nwi_wC0gWgt0fpdp-ZQ@mail.gmail.com>
	<26c3333933769e4f9d1ed6226962a2f80719146b.1408050002.git.aquini@redhat.com>
	<20140814220704.GB26367@optiplex.redhat.com>
Date: Fri, 15 Aug 2014 07:36:16 +0400
Message-ID: <CALYGNiPbtav_ChUFW_kkh+HOHVmKeupTRsnKsaShK=p8ZKguBg@mail.gmail.com>
Subject: Re: mm: compaction: buffer overflow in isolate_migratepages_range
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, vbabka@suse.cz, rientjes@google.com, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrey Ryabinin <a.ryabinin@samsung.com>, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com

On Fri, Aug 15, 2014 at 2:07 AM, Rafael Aquini <aquini@redhat.com> wrote:
> On Thu, Aug 14, 2014 at 06:43:50PM -0300, Rafael Aquini wrote:
>> On Thu, Aug 14, 2014 at 10:07:40PM +0400, Andrey Ryabinin wrote:
>> > We discussed this with Konstantin and he suggested a better solution for this.
>> > If I understood him correctly the main idea was to store bit
>> > identifying ballon page
>> > in struct page (special value in _mapcount), so we won't need to check
>> > mapping->flags.
>> >
>>
>> Here goes what I thought doing, following that suggestion of Konstantin and yours. (I didn't tested it yet)
>>
>> Comments are welcomed.
>>
>> Cheers,
>> -- Rafael
>>
>> ---- 8< ----
>> From: Rafael Aquini <aquini@redhat.com>
>> Subject: mm: balloon_compaction: enhance balloon_page_movable() checkpoint against races
>>
>> While testing linux-next for the Kernel Address Sanitizer patchset (KASAN)
>> Sasha Levin reported a buffer overflow warning triggered for
>> isolate_migratepages_range(), which lated was discovered happening due to
>> a condition where balloon_page_movable() raced against move_to_new_page(),
>> while the later was copying the page->mapping of an anon page.
>>
>> Because we can perform balloon_page_movable() in a lockless fashion at
>> isolate_migratepages_range(), the dicovered race has unveiled the scheme
>> actually used to spot ballooned pages among page blocks that checks for
>> page_flags_cleared() and dereference page->mapping to check its mapping flags
>> is weak and potentially prone to stumble across another similar conditions
>> in the future.
>>
>> Following Konstantin Khlebnikov's and Andrey Ryabinin's suggestions,
>> this patch replaces the old page->flags && mapping->flags checking scheme
>> with a more simple and strong page->_mapcount read and compare value test.
>> Similarly to what is done for PageBuddy() checks, BALLOON_PAGE_MAPCOUNT_VALUE
>> is introduced here to mark balloon pages. This allows balloon_page_movable()
>> to skip the proven troublesome dereference of page->mapping for flag checking
>> while it goes on isolate_migratepages_range() lockless rounds.
>> page->mapping dereference and flag-checking will be performed later, when
>> all locks are held properly.
>>
>> ---
>>  include/linux/balloon_compaction.h | 61 +++++++++++---------------------------
>>  mm/balloon_compaction.c            | 53 +++++++++++++++++----------------
>>  2 files changed, 45 insertions(+), 69 deletions(-)
>>
>> diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
>> index 089743a..1409ccc 100644
>> --- a/include/linux/balloon_compaction.h
>> +++ b/include/linux/balloon_compaction.h
>> @@ -108,54 +108,29 @@ static inline void balloon_mapping_free(struct address_space *balloon_mapping)
>>  }
>>
>>  /*
>> - * page_flags_cleared - helper to perform balloon @page ->flags tests.
>> + * balloon_page_movable - identify balloon pages that can be moved by
>> + *                     compaction / migration.
>>   *
>> - * As balloon pages are obtained from buddy and we do not play with page->flags
>> - * at driver level (exception made when we get the page lock for compaction),
>> - * we can safely identify a ballooned page by checking if the
>> - * PAGE_FLAGS_CHECK_AT_PREP page->flags are all cleared.  This approach also
>> - * helps us skip ballooned pages that are locked for compaction or release, thus
>> - * mitigating their racy check at balloon_page_movable()
>> + * BALLOON_PAGE_MAPCOUNT_VALUE must be <= -2 but better not too close to
>> + * -2 so that an underflow of the page_mapcount() won't be mistaken
>> + * for a genuine BALLOON_PAGE_MAPCOUNT_VALUE.
>>   */
>> -static inline bool page_flags_cleared(struct page *page)
>> +#define BALLOON_PAGE_MAPCOUNT_VALUE (-256)
>> +static inline bool balloon_page_movable(struct page *page)
>>  {
>> -     return !(page->flags & PAGE_FLAGS_CHECK_AT_PREP);
>> +     return atomic_read(&page->_mapcount) == BALLOON_PAGE_MAPCOUNT_VALUE;
>>  }
>>
>> -/*
>> - * __is_movable_balloon_page - helper to perform @page mapping->flags tests
>> - */
>> -static inline bool __is_movable_balloon_page(struct page *page)
>> +static inline void __balloon_page_set(struct page *page)
>>  {
>> -     struct address_space *mapping = page->mapping;
>> -     return mapping_balloon(mapping);
>> +     VM_BUG_ON_PAGE(!atomic_read(&page->_mapcount) != -1, page);
>> +     atomic_set(&page->_mapcount, BALLOON_PAGE_MAPCOUNT_VALUE);
>>  }
>>
>> -/*
>> - * balloon_page_movable - test page->mapping->flags to identify balloon pages
>> - *                     that can be moved by compaction/migration.
>> - *
>> - * This function is used at core compaction's page isolation scheme, therefore
>> - * most pages exposed to it are not enlisted as balloon pages and so, to avoid
>> - * undesired side effects like racing against __free_pages(), we cannot afford
>> - * holding the page locked while testing page->mapping->flags here.
>> - *
>> - * As we might return false positives in the case of a balloon page being just
>> - * released under us, the page->mapping->flags need to be re-tested later,
>> - * under the proper page lock, at the functions that will be coping with the
>> - * balloon page case.
>> - */
>> -static inline bool balloon_page_movable(struct page *page)
>> +static inline void __balloon_page_clear(struct page *page)
>>  {
>> -     /*
>> -      * Before dereferencing and testing mapping->flags, let's make sure
>> -      * this is not a page that uses ->mapping in a different way
>> -      */
>> -     if (page_flags_cleared(page) && !page_mapped(page) &&
>> -         page_count(page) == 1)
>> -             return __is_movable_balloon_page(page);
>> -
>> -     return false;
>> +     VM_BUG_ON_PAGE(!balloon_page_movable(page), page)
>> +     atomic_set(&page->_mapcount, -1);
>>  }
>>
>>  /*
>> @@ -170,10 +145,8 @@ static inline bool balloon_page_movable(struct page *page)
>>   */
>>  static inline bool isolated_balloon_page(struct page *page)
>>  {
>> -     /* Already isolated balloon pages, by default, have a raised refcount */
>> -     if (page_flags_cleared(page) && !page_mapped(page) &&
>> -         page_count(page) >= 2)
>> -             return __is_movable_balloon_page(page);
>> +     if (balloon_page_movable && page_count(page) > 1)
>> +             return true;
>>
>>       return false;
>>  }
>> @@ -193,6 +166,7 @@ static inline void balloon_page_insert(struct page *page,
>>                                      struct list_head *head)
>>  {
>>       page->mapping = mapping;
>> +     __balloon_page_set(page);
>>       list_add(&page->lru, head);
>>  }
>>
>> @@ -207,6 +181,7 @@ static inline void balloon_page_insert(struct page *page,
>>  static inline void balloon_page_delete(struct page *page)
>>  {
>>       page->mapping = NULL;
>> +     __balloon_page_clear(page);
>>       list_del(&page->lru);
>>  }
>>
>> diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
>> index 6e45a50..1cfb254 100644
>> --- a/mm/balloon_compaction.c
>> +++ b/mm/balloon_compaction.c
>> @@ -220,33 +220,32 @@ bool balloon_page_isolate(struct page *page)
>>        * raise its refcount preventing __free_pages() from doing its job
>>        * the put_page() at the end of this block will take care of
>>        * release this page, thus avoiding a nasty leakage.
>> +      *
>> +      * As balloon pages are not isolated from LRU lists, concurrent
>> +      * compaction threads can race against page migration functions
>> +      * as well as race against the balloon driver releasing a page.
>> +      * The aforementioned operations are done under the safety of
>> +      * page lock, so lets be sure we hold it before proceeding the
>> +      * isolations steps here.
>>        */
>> -     if (likely(get_page_unless_zero(page))) {
>> +     if (get_page_unless_zero(page) && trylock_page(page)) {
> Oops, I need to change this one, as we can left behind pages with raised
> refcounts if get_page_unless_zero(page) but trylock_page(page) fails
> here.

Don't hurry. The code in this state for years.
I'm working on patches for this, if everything goes well I'll show it today.
As usual I couldn't stop myself from cleaning the mess, so it will be
bigger than yours.

>
>
>>               /*
>> -              * As balloon pages are not isolated from LRU lists, concurrent
>> -              * compaction threads can race against page migration functions
>> -              * as well as race against the balloon driver releasing a page.
>> -              *
>> -              * In order to avoid having an already isolated balloon page
>> -              * being (wrongly) re-isolated while it is under migration,
>> -              * or to avoid attempting to isolate pages being released by
>> -              * the balloon driver, lets be sure we have the page lock
>> -              * before proceeding with the balloon page isolation steps.
>> +              * A ballooned page, by default, has just one refcount.
>> +              * Prevent concurrent compaction threads from isolating
>> +              * an already isolated balloon page by refcount check.
>>                */
>> -             if (likely(trylock_page(page))) {
>> -                     /*
>> -                      * A ballooned page, by default, has just one refcount.
>> -                      * Prevent concurrent compaction threads from isolating
>> -                      * an already isolated balloon page by refcount check.
>> -                      */
>> -                     if (__is_movable_balloon_page(page) &&
>> -                         page_count(page) == 2) {
>> +             if (balloon_page_movable(page) && page_count(page) == 2) {
>> +                     struct address_space *mapping = page_mapping(page);
>> +                     if (likely(mapping_balloon(mapping))) {
>>                               __isolate_balloon_page(page);
>>                               unlock_page(page);
>>                               return true;
>> +                     } else {
>> +                             dump_page(page, "not movable balloon page");
>> +                             WARN_ON(1);
>>                       }
>> -                     unlock_page(page);
>>               }
>> +             unlock_page(page);
>>               put_page(page);
>>       }
>>       return false;
>> @@ -255,19 +254,21 @@ bool balloon_page_isolate(struct page *page)
>>  /* putback_lru_page() counterpart for a ballooned page */
>>  void balloon_page_putback(struct page *page)
>>  {
>> +     struct address_space *mapping;
>>       /*
>>        * 'lock_page()' stabilizes the page and prevents races against
>>        * concurrent isolation threads attempting to re-isolate it.
>>        */
>>       lock_page(page);
>>
>> -     if (__is_movable_balloon_page(page)) {
>> +     mapping = page_mapping(page);
>> +     if (balloon_page_movable(page) && mapping_balloon(mapping)) {
>>               __putback_balloon_page(page);
>>               /* drop the extra ref count taken for page isolation */
>>               put_page(page);
>>       } else {
>> -             WARN_ON(1);
>>               dump_page(page, "not movable balloon page");
>> +             WARN_ON(1);
>>       }
>>       unlock_page(page);
>>  }
>> @@ -286,16 +287,16 @@ int balloon_page_migrate(struct page *newpage,
>>        */
>>       BUG_ON(!trylock_page(newpage));
>>
>> -     if (WARN_ON(!__is_movable_balloon_page(page))) {
>> +     mapping = page_mapping(page);
>> +     if (!(balloon_page_movable(page) && mapping_balloon(mapping))) {
>>               dump_page(page, "not movable balloon page");
>> -             unlock_page(newpage);
>> -             return rc;
>> +             WARN_ON(1);
>> +             goto out;
>>       }
>>
>> -     mapping = page->mapping;
>>       if (mapping)
>>               rc = __migrate_balloon_page(mapping, newpage, page, mode);
>> -
>> +out:
>>       unlock_page(newpage);
>>       return rc;
>>  }
>> --
>> 1.9.3
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
