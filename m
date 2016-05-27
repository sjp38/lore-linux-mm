Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 063136B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 06:55:44 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e3so49795246wme.3
        for <linux-mm@kvack.org>; Fri, 27 May 2016 03:55:43 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id r11si11457394wmb.87.2016.05.27.03.55.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 03:55:42 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id a136so13710009wme.0
        for <linux-mm@kvack.org>; Fri, 27 May 2016 03:55:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALZtOND-METjAmuNdMjNs-FPUcTX3OyoeG5f2zOCz=fBm6OiXA@mail.gmail.com>
References: <20160509151753.ec3f9fda3c9898d31ff52a32@gmail.com>
	<CALZtOND-METjAmuNdMjNs-FPUcTX3OyoeG5f2zOCz=fBm6OiXA@mail.gmail.com>
Date: Fri, 27 May 2016 12:55:41 +0200
Message-ID: <CAMJBoFNdpJ0Ra-93rAkH8sjAO1nYkbHUdaZx09juZKRck4o-bg@mail.gmail.com>
Subject: Re: [PATCH v4] z3fold: the 3-fold allocator for compressed pages
From: Vitaly Wool <vitalywool@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Seth Jennings <sjenning@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>

Hello Dan,

On Fri, May 20, 2016 at 2:39 PM, Dan Streetman <ddstreet@ieee.org> wrote:

<snip>
>> +static int z3fold_compact_page(struct z3fold_header *zhdr)
>> +{
>> +       struct page *page = virt_to_page(zhdr);
>> +       void *beg = zhdr;
>> +
>> +
>> +       if (!test_bit(MIDDLE_CHUNK_MAPPED, &page->private) &&
>> +           zhdr->middle_chunks != 0 &&
>> +           zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
>> +               memmove(beg + ZHDR_SIZE_ALIGNED,
>> +                       beg + (zhdr->start_middle << CHUNK_SHIFT),
>> +                       zhdr->middle_chunks << CHUNK_SHIFT);
>> +               zhdr->first_chunks = zhdr->middle_chunks;
>> +               zhdr->middle_chunks = 0;
>> +               zhdr->start_middle = 0;
>> +               zhdr->first_num++;
>> +               return 1;
>> +       }
>
> what about the case of only first and middle, or only middle and last?
>  you can still optimize space in those cases.

That's right, but I ran some performance tests, too, and with those
extra optimizations
z3fold is on par with zsmalloc, while the existing implementation
gives 10-30% better
numbers. OTOH, the gain in space according to my measurements is 5-10% so I am
not that eager to trade performance gain for it. I was thinking of
having theoe extra
optimizations under a module parameter/flag and I'll come up with the
patch soon, but
I'm going to have that disabled by default anyway.

<snip>
>> +static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
>> +{
>> +       struct z3fold_header *zhdr;
>> +       int freechunks;
>> +       struct page *page;
>> +       enum buddy bud;
>> +
>> +       spin_lock(&pool->lock);
>> +       zhdr = handle_to_z3fold_header(handle);
>> +       page = virt_to_page(zhdr);
>> +
>> +       if (test_bit(PAGE_HEADLESS, &page->private)) {
>> +               /* HEADLESS page stored */
>> +               bud = HEADLESS;
>> +       } else {
>> +               bud = (handle - zhdr->first_num) & BUDDY_MASK;
>
> this should use handle_to_buddy()

Thanks, will fix that.

<snip>
>> +static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
>> +{
>> +       int i, ret = 0, freechunks;
>> +       struct z3fold_header *zhdr;
>> +       struct page *page;
>> +       unsigned long first_handle = 0, middle_handle = 0, last_handle = 0;
>> +
>> +       spin_lock(&pool->lock);
>> +       if (!pool->ops || !pool->ops->evict || list_empty(&pool->lru) ||
>> +                       retries == 0) {
>> +               spin_unlock(&pool->lock);
>> +               return -EINVAL;
>> +       }
>> +       for (i = 0; i < retries; i++) {
>> +               page = list_last_entry(&pool->lru, struct page, lru);
>> +               list_del(&page->lru);
>> +
>> +               /* Protect z3fold page against free */
>> +               set_bit(UNDER_RECLAIM, &page->private);
>> +               zhdr = page_address(page);
>> +               if (!test_bit(PAGE_HEADLESS, &page->private)) {
>> +                       list_del(&zhdr->buddy);
>> +                       /*
>> +                        * We need encode the handles before unlocking, since
>> +                        * we can race with free that will set
>> +                        * (first|last)_chunks to 0
>> +                        */
>> +                       first_handle = 0;
>> +                       last_handle = 0;
>> +                       middle_handle = 0;
>> +                       if (zhdr->first_chunks)
>> +                               first_handle = encode_handle(zhdr, FIRST);
>> +                       if (zhdr->middle_chunks)
>> +                               middle_handle = encode_handle(zhdr, MIDDLE);
>> +                       if (zhdr->last_chunks)
>> +                               last_handle = encode_handle(zhdr, LAST);
>> +               } else {
>> +                       first_handle = encode_handle(zhdr, HEADLESS);
>> +                       last_handle = middle_handle = 0;
>> +               }
>> +
>> +               spin_unlock(&pool->lock);
>> +
>> +               /* Issue the eviction callback(s) */
>> +               if (middle_handle) {
>> +                       ret = pool->ops->evict(pool, middle_handle);
>> +                       if (ret)
>> +                               goto next;
>> +               }
>> +               if (first_handle) {
>> +                       ret = pool->ops->evict(pool, first_handle);
>> +                       if (ret)
>> +                               goto next;
>> +               }
>> +               if (last_handle) {
>> +                       ret = pool->ops->evict(pool, last_handle);
>> +                       if (ret)
>> +                               goto next;
>> +               }
>> +next:
>> +               spin_lock(&pool->lock);
>> +               clear_bit(UNDER_RECLAIM, &page->private);
>> +               if ((test_bit(PAGE_HEADLESS, &page->private) && ret == 0) ||
>> +                   (zhdr->first_chunks == 0 && zhdr->last_chunks == 0 &&
>> +                    zhdr->middle_chunks == 0)) {
>> +                       /*
>> +                        * All buddies are now free, free the z3fold page and
>> +                        * return success.
>> +                        */
>> +                       clear_bit(PAGE_HEADLESS, &page->private);
>> +                       free_z3fold_page(zhdr);
>> +                       pool->pages_nr--;
>> +                       spin_unlock(&pool->lock);
>> +                       return 0;
>> +               } else if (zhdr->first_chunks != 0 &&
>> +                          zhdr->last_chunks != 0 && zhdr->middle_chunks != 0) {
>
> if this is a HEADLESS page and the reclaim failed, this else-if will
> be checked which isn't good, since the zhdr data doesn't exist for
> headless pages.

Thanks, and that too.

<snip>
>> +static void z3fold_unmap(struct z3fold_pool *pool, unsigned long handle)
>> +{
>> +       struct z3fold_header *zhdr;
>> +       struct page *page;
>> +       enum buddy buddy;
>> +
>> +       spin_lock(&pool->lock);
>> +       zhdr = handle_to_z3fold_header(handle);
>> +       page = virt_to_page(zhdr);
>> +
>> +       if (test_bit(PAGE_HEADLESS, &page->private)) {
>> +               spin_unlock(&pool->lock);
>> +               return;
>> +       }
>> +
>> +       buddy = handle_to_buddy(handle);
>> +       if (buddy == MIDDLE)
>> +               clear_bit(MIDDLE_CHUNK_MAPPED, &page->private);
>
> maybe it should be compacted here, in case a compaction was missed
> while the middle chunk was mapped?

I was thinking about that but decided not to go for it at least right
now because
I want map() and unmap() functions to be as fast as possible. I am
considering adding a worker thread that would run compaction in an async
mode and here would be one of the places to trigger it then. Does that sound
reasonable to you?

~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
