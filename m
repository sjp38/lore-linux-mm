Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id 5C3146B0035
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 22:58:48 -0500 (EST)
Received: by mail-qc0-f169.google.com with SMTP id w7so6734044qcr.14
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 19:58:48 -0800 (PST)
Received: from mail-vc0-x22f.google.com (mail-vc0-x22f.google.com [2607:f8b0:400c:c03::22f])
        by mx.google.com with ESMTPS id r15si2135524qeu.6.2014.01.20.19.58.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 20 Jan 2014 19:58:47 -0800 (PST)
Received: by mail-vc0-f175.google.com with SMTP id ij19so3262245vcb.34
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 19:58:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAFLCcBqyhL=wfC4uJmpp9MkGExBuPJC4EqY2RHRngnEn_1ytSA@mail.gmail.com>
References: <CAFLCcBqyhL=wfC4uJmpp9MkGExBuPJC4EqY2RHRngnEn_1ytSA@mail.gmail.com>
Date: Tue, 21 Jan 2014 11:58:46 +0800
Message-ID: <CAA_GA1eR++9u+WrCnv-eLoAa-6K18aQwLJ+TkpC8LGQPEeHGSQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm/zswap: Check all pool pages instead of one pool pages
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cai Liu <liucai.lfn@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Bob Liu <bob.liu@oracle.com>, Cai Liu <cai.liu@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Tue, Jan 21, 2014 at 11:07 AM, Cai Liu <liucai.lfn@gmail.com> wrote:
> Thanks for your review.
>
> 2014/1/21 Minchan Kim <minchan@kernel.org>:
>> Hello Cai,
>>
>> On Mon, Jan 20, 2014 at 03:50:18PM +0800, Cai Liu wrote:
>>> zswap can support multiple swapfiles. So we need to check
>>> all zbud pool pages in zswap.
>>>
>>> Version 2:
>>>   * add *total_zbud_pages* in zbud to record all the pages in pools
>>>   * move the updating of pool pages statistics to
>>>     alloc_zbud_page/free_zbud_page to hide the details
>>>
>>> Signed-off-by: Cai Liu <cai.liu@samsung.com>
>>> ---
>>>  include/linux/zbud.h |    2 +-
>>>  mm/zbud.c            |   44 ++++++++++++++++++++++++++++++++------------
>>>  mm/zswap.c           |    4 ++--
>>>  3 files changed, 35 insertions(+), 15 deletions(-)
>>>
>>> diff --git a/include/linux/zbud.h b/include/linux/zbud.h
>>> index 2571a5c..1dbc13e 100644
>>> --- a/include/linux/zbud.h
>>> +++ b/include/linux/zbud.h
>>> @@ -17,6 +17,6 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle);
>>>  int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries);
>>>  void *zbud_map(struct zbud_pool *pool, unsigned long handle);
>>>  void zbud_unmap(struct zbud_pool *pool, unsigned long handle);
>>> -u64 zbud_get_pool_size(struct zbud_pool *pool);
>>> +u64 zbud_get_pool_size(void);
>>>
>>>  #endif /* _ZBUD_H_ */
>>> diff --git a/mm/zbud.c b/mm/zbud.c
>>> index 9451361..711aaf4 100644
>>> --- a/mm/zbud.c
>>> +++ b/mm/zbud.c
>>> @@ -52,6 +52,13 @@
>>>  #include <linux/spinlock.h>
>>>  #include <linux/zbud.h>
>>>
>>> +/*********************************
>>> +* statistics
>>> +**********************************/
>>> +
>>> +/* zbud pages in all pools */
>>> +static u64 total_zbud_pages;
>>> +
>>>  /*****************
>>>   * Structures
>>>  *****************/
>>> @@ -142,10 +149,28 @@ static struct zbud_header *init_zbud_page(struct page *page)
>>>       return zhdr;
>>>  }
>>>
>>> +static struct page *alloc_zbud_page(struct zbud_pool *pool, gfp_t gfp)
>>> +{
>>> +     struct page *page;
>>> +
>>> +     page = alloc_page(gfp);
>>> +
>>> +     if (page) {
>>> +             pool->pages_nr++;
>>> +             total_zbud_pages++;
>>
>> Who protect race?
>
> Yes, here the pool->pages_nr and also the total_zbud_pages are not protected.
> I will re-do it.
>
> I will change *total_zbud_pages* to atomic type.

And how about just add total_zbud_pages++ and leave pool->pages_nr in
its original place which already protected by pool->lock?

> For *pool->pages_nr*, one way is to use pool->lock to protect. But I
> think it is too heavy.
> So does it ok to change pages_nr to atomic type too?
>

-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
