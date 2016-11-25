Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9EBE96B025E
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 02:34:59 -0500 (EST)
Received: by mail-vk0-f72.google.com with SMTP id 19so27912019vko.0
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 23:34:59 -0800 (PST)
Received: from mail-ua0-x241.google.com (mail-ua0-x241.google.com. [2607:f8b0:400c:c08::241])
        by mx.google.com with ESMTPS id 103si9787742ual.22.2016.11.24.23.34.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Nov 2016 23:34:58 -0800 (PST)
Received: by mail-ua0-x241.google.com with SMTP id 12so3090130uas.3
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 23:34:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161124223613.GA20370@mwanda>
References: <20161124223613.GA20370@mwanda>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Fri, 25 Nov 2016 08:34:57 +0100
Message-ID: <CAMJBoFNZ+YcX0Yh2XUfBp2kT6WHyptFEXjKWrz2teWYsm-KTrA@mail.gmail.com>
Subject: Re: [bug report] z3fold: use per-page spinlock
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Linux-MM <linux-mm@kvack.org>

Hi Dan,

On Thu, Nov 24, 2016 at 11:36 PM, Dan Carpenter
<dan.carpenter@oracle.com> wrote:
> Hello Vitaly Wool,
>
> The patch 570931c8c567: "z3fold: use per-page spinlock" from Nov 24,
> 2016, leads to the following Smatch warning:
>
>         mm/z3fold.c:699 z3fold_reclaim_page()
>         error: double unlock 'spin_lock:&pool->lock'
>
> mm/z3fold.c
>    597  static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
>    598  {
>    599          int i, ret = 0, freechunks;
>    600          struct z3fold_header *zhdr;
>    601          struct page *page;
>    602          unsigned long first_handle = 0, middle_handle = 0, last_handle = 0;
>    603
>    604          spin_lock(&pool->lock);
>    605          if (!pool->ops || !pool->ops->evict || list_empty(&pool->lru) ||
>    606                          retries == 0) {
>    607                  spin_unlock(&pool->lock);
>    608                  return -EINVAL;
>    609          }
>    610          for (i = 0; i < retries; i++) {
>    611                  page = list_last_entry(&pool->lru, struct page, lru);
>    612                  list_del(&page->lru);
>    613
>    614                  /* Protect z3fold page against free */
>    615                  set_bit(UNDER_RECLAIM, &page->private);
>    616                  zhdr = page_address(page);
>    617                  if (!test_bit(PAGE_HEADLESS, &page->private)) {
>    618                          list_del(&zhdr->buddy);
>    619                          spin_unlock(&pool->lock);
>    620                          z3fold_page_lock(zhdr);
>    621                          /*
>    622                           * We need encode the handles before unlocking, since
>    623                           * we can race with free that will set
>    624                           * (first|last)_chunks to 0
>    625                           */
>    626                          first_handle = 0;
>    627                          last_handle = 0;
>    628                          middle_handle = 0;
>    629                          if (zhdr->first_chunks)
>    630                                  first_handle = encode_handle(zhdr, FIRST);
>    631                          if (zhdr->middle_chunks)
>    632                                  middle_handle = encode_handle(zhdr, MIDDLE);
>    633                          if (zhdr->last_chunks)
>    634                                  last_handle = encode_handle(zhdr, LAST);
>    635                          z3fold_page_unlock(zhdr);
>    636                  } else {
>    637                          first_handle = encode_handle(zhdr, HEADLESS);
>    638                          last_handle = middle_handle = 0;
>    639                          spin_unlock(&pool->lock);
>    640                  }
>    641
>    642                  /* Issue the eviction callback(s) */
>    643                  if (middle_handle) {
>    644                          ret = pool->ops->evict(pool, middle_handle);
>    645                          if (ret)
>    646                                  goto next;
>    647                  }
>    648                  if (first_handle) {
>    649                          ret = pool->ops->evict(pool, first_handle);
>    650                          if (ret)
>    651                                  goto next;
>    652                  }
>    653                  if (last_handle) {
>    654                          ret = pool->ops->evict(pool, last_handle);
>    655                          if (ret)
>    656                                  goto next;
>
> "ret" is non-zero so we do a little bunny hop to the next line.  Small
> jump deserves a small pun.
>
>    657                  }
>    658  next:
>
> Originally we took the lock here, but now we've moved it into the if
> statement branches.
>
>    659                  if (!test_bit(PAGE_HEADLESS, &page->private))
>    660                          z3fold_page_lock(zhdr);
>    661                  clear_bit(UNDER_RECLAIM, &page->private);
>    662                  if ((test_bit(PAGE_HEADLESS, &page->private) && ret == 0) ||
>    663                      (zhdr->first_chunks == 0 && zhdr->last_chunks == 0 &&
>    664                       zhdr->middle_chunks == 0)) {
>    665                          /*
>    666                           * All buddies are now free, free the z3fold page and
>    667                           * return success.
>    668                           */
>    669                          clear_bit(PAGE_HEADLESS, &page->private);
>    670                          if (!test_bit(PAGE_HEADLESS, &page->private))
>    671                                  z3fold_page_unlock(zhdr);
>    672                          free_z3fold_page(zhdr);
>    673                          atomic64_dec(&pool->pages_nr);
>    674                          return 0;
>    675                  }  else if (!test_bit(PAGE_HEADLESS, &page->private)) {
>    676                          if (zhdr->first_chunks != 0 &&
>    677                              zhdr->last_chunks != 0 &&
>    678                              zhdr->middle_chunks != 0) {
>    679                                  /* Full, add to buddied list */
>    680                                  spin_lock(&pool->lock);
>    681                                  list_add(&zhdr->buddy, &pool->buddied);
>    682                          } else {
>    683                                  int compacted = z3fold_compact_page(zhdr);
>    684                                  /* add to unbuddied list */
>    685                                  spin_lock(&pool->lock);
>    686                                  freechunks = num_free_chunks(zhdr);
>    687                                  if (compacted)
>    688                                          list_add(&zhdr->buddy,
>    689                                                  &pool->unbuddied[freechunks]);
>    690                                  else
>    691                                          list_add_tail(&zhdr->buddy,
>    692                                                  &pool->unbuddied[freechunks]);
>    693                          }
>    694                  }
>
> We don't take the lock if PAGE_HEADLESS is set but ret is non-zero.
>
>    695
>    696                  /* add to beginning of LRU */
>    697                  list_add(&page->lru, &pool->lru);
>    698          }
>    699          spin_unlock(&pool->lock);
>
> Leading to a double unlock.

thanks for the report, will upload the fix shortly.

~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
