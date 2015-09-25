Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 3B2496B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 01:56:19 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so5595130wic.0
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 22:56:18 -0700 (PDT)
Received: from mail-wi0-x232.google.com (mail-wi0-x232.google.com. [2a00:1450:400c:c05::232])
        by mx.google.com with ESMTPS id dq1si2444588wid.88.2015.09.24.22.56.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Sep 2015 22:56:17 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so5594755wic.0
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 22:56:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150923224127.GB17171@cerebellum.local.variantweb.net>
References: <20150922141733.d7d97f59f207d0655c3b881d@gmail.com>
	<CALZtONAhARM8FkxLpNQ9-jx4TOU-RyLm2c8suyOY3iN2yvWvLQ@mail.gmail.com>
	<20150923225900.64293d4c2c534f00bfa60435@gmail.com>
	<20150923224127.GB17171@cerebellum.local.variantweb.net>
Date: Fri, 25 Sep 2015 07:56:17 +0200
Message-ID: <CAMJBoFPwAq+ywq5g=a8mtis6w4Qe9gZobVMv1SZExhg1_bWBzw@mail.gmail.com>
Subject: Re: [PATCH v2] zbud: allow up to PAGE_SIZE allocations
From: Vitaly Wool <vitalywool@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

Hello Seth,

On Thu, Sep 24, 2015 at 12:41 AM, Seth Jennings
<sjennings@variantweb.net> wrote:
> On Wed, Sep 23, 2015 at 10:59:00PM +0200, Vitaly Wool wrote:
>> Okay, how about this? It's gotten smaller BTW :)
>>
>> zbud: allow up to PAGE_SIZE allocations
>>
>> Currently zbud is only capable of allocating not more than
>> PAGE_SIZE - ZHDR_SIZE_ALIGNED - CHUNK_SIZE. This is okay as
>> long as only zswap is using it, but other users of zbud may
>> (and likely will) want to allocate up to PAGE_SIZE. This patch
>> addresses that by skipping the creation of zbud internal
>> structure in the beginning of an allocated page. As a zbud page
>> is no longer guaranteed to contain zbud header, the following
>> changes have to be applied throughout the code:
>> * page->lru to be used for zbud page lists
>> * page->private to hold 'under_reclaim' flag
>>
>> page->private will also be used to indicate if this page contains
>> a zbud header in the beginning or not ('headless' flag).
>>
>> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
>> ---
>>  mm/zbud.c | 167 ++++++++++++++++++++++++++++++++++++++++++--------------------
>>  1 file changed, 113 insertions(+), 54 deletions(-)
>>
>> diff --git a/mm/zbud.c b/mm/zbud.c
>> index fa48bcdf..3946fba 100644
>> --- a/mm/zbud.c
>> +++ b/mm/zbud.c
>> @@ -105,18 +105,20 @@ struct zbud_pool {
>>
>>  /*
>>   * struct zbud_header - zbud page metadata occupying the first chunk of each
>> - *                   zbud page.
>> + *                   zbud page, except for HEADLESS pages
>>   * @buddy:   links the zbud page into the unbuddied/buddied lists in the pool
>> - * @lru:     links the zbud page into the lru list in the pool
>>   * @first_chunks:    the size of the first buddy in chunks, 0 if free
>>   * @last_chunks:     the size of the last buddy in chunks, 0 if free
>>   */
>>  struct zbud_header {
>>       struct list_head buddy;
>> -     struct list_head lru;
>>       unsigned int first_chunks;
>>       unsigned int last_chunks;
>> -     bool under_reclaim;
>> +};
>> +
>> +enum zbud_page_flags {
>> +     UNDER_RECLAIM = 0,
>
> Don't need the "= 0"
>
>> +     PAGE_HEADLESS,
>
> Also I think we should prefix the enum values here. With ZPF_ ?
>
>>  };
>>
>>  /*****************
>> @@ -221,6 +223,7 @@ MODULE_ALIAS("zpool-zbud");
>>  *****************/
>>  /* Just to make the code easier to read */
>>  enum buddy {
>> +     HEADLESS,
>>       FIRST,
>>       LAST
>>  };
>> @@ -238,11 +241,14 @@ static int size_to_chunks(size_t size)
>>  static struct zbud_header *init_zbud_page(struct page *page)
>>  {
>>       struct zbud_header *zhdr = page_address(page);
>> +
>> +     INIT_LIST_HEAD(&page->lru);
>> +     clear_bit(UNDER_RECLAIM, &page->private);
>> +     clear_bit(HEADLESS, &page->private);
>
> I know we are using private in a bitwise flags mode, but maybe we
> should just init with page->private = 0
>
>> +
>>       zhdr->first_chunks = 0;
>>       zhdr->last_chunks = 0;
>>       INIT_LIST_HEAD(&zhdr->buddy);
>> -     INIT_LIST_HEAD(&zhdr->lru);
>> -     zhdr->under_reclaim = 0;
>>       return zhdr;
>>  }
>>
>> @@ -267,11 +273,22 @@ static unsigned long encode_handle(struct zbud_header *zhdr, enum buddy bud)
>>        * over the zbud header in the first chunk.
>>        */
>>       handle = (unsigned long)zhdr;
>> -     if (bud == FIRST)
>> +     switch (bud) {
>> +     case FIRST:
>>               /* skip over zbud header */
>>               handle += ZHDR_SIZE_ALIGNED;
>> -     else /* bud == LAST */
>> +             break;
>> +     case LAST:
>>               handle += PAGE_SIZE - (zhdr->last_chunks  << CHUNK_SHIFT);
>> +             break;
>> +     case HEADLESS:
>> +             break;
>> +     default:
>> +             /* this should never happen */
>> +             pr_err("zbud: invalid buddy value %d\n", bud);
>> +             handle = 0;
>> +             break;
>> +     }
>
> Don't need this default case since we have a case for each valid value
> of the enum.
>
> Also, I think we want to add some code to free_zbud_page() to clear
> page->private and init page->lru so we don't leave dangling pointers.

Right, maybe it makes sense for free_zbud_page() to take struct page
pointer as an argument, too, to minimize back-and-forth conversions?

> Looks good though :)

Thanks, I'll come up with the new version shortly. :)

~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
