Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 95B936B0003
	for <linux-mm@kvack.org>; Tue, 29 May 2018 17:15:22 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id i200-v6so13642814itb.9
        for <linux-mm@kvack.org>; Tue, 29 May 2018 14:15:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b185-v6sor7828687itb.40.2018.05.29.14.15.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 May 2018 14:15:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180524095752.17770-1-liwang@redhat.com>
References: <20180524095752.17770-1-liwang@redhat.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Tue, 29 May 2018 17:14:39 -0400
Message-ID: <CALZtONA4y+7vzUr2xPa8ZbwCczjJV9EMCOXaCsE94DdfGbrmtA@mail.gmail.com>
Subject: Re: [PATCH RFC] zswap: reject to compress/store page if
 zswap_max_pool_percent is 0
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Wang <liwang@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Seth Jennings <sjenning@redhat.com>, Huang Ying <huang.ying.caritas@gmail.com>, Yu Zhao <yuzhao@google.com>

On Thu, May 24, 2018 at 5:57 AM, Li Wang <liwang@redhat.com> wrote:
> The '/sys/../zswap/stored_pages:' keep raising in zswap test with
> "zswap.max_pool_percent=0" parameter. But theoretically, it should
> not compress or store pages any more since there is no space for
> compressed pool.
>
> Reproduce steps:
>
>   1. Boot kernel with "zswap.enabled=1 zswap.max_pool_percent=17"
>   2. Set the max_pool_percent to 0
>       # echo 0 > /sys/module/zswap/parameters/max_pool_percent
>      Confirm this parameter works fine
>       # cat /sys/kernel/debug/zswap/pool_total_size
>       0
>   3. Do memory stress test to see if some pages have been compressed
>       # stress --vm 1 --vm-bytes $mem_available"M" --timeout 60s
>      Watching the 'stored_pages' numbers increasing or not
>
> The root cause is:
>
>   When the zswap_max_pool_percent is set to 0 via kernel parameter, the zswap_is_full()
>   will always return true to shrink the pool size by zswap_shrink(). If the pool size
>   has been shrinked a little success, zswap will do compress/store pages again. Then we
>   get fails on that as above.

special casing 0% doesn't make a lot of sense to me, and I'm not
entirely sure what exactly you are trying to fix here.

however, zswap does currently do a zswap_is_full() check, and then if
it's able to reclaim a page happily proceeds to store another page,
without re-checking zswap_is_full().  If you're trying to fix that,
then I would ack a patch that adds a second zswap_is_full() check
after zswap_shrink() to make sure it's now under the max_pool_percent
(or somehow otherwise fixes that behavior).

>
> Signed-off-by: Li Wang <liwang@redhat.com>
> Cc: Seth Jennings <sjenning@redhat.com>
> Cc: Dan Streetman <ddstreet@ieee.org>
> Cc: Huang Ying <huang.ying.caritas@gmail.com>
> Cc: Yu Zhao <yuzhao@google.com>
> ---
>  mm/zswap.c | 5 +++++
>  1 file changed, 5 insertions(+)
>
> diff --git a/mm/zswap.c b/mm/zswap.c
> index 61a5c41..2b537bb 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -1007,6 +1007,11 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>         u8 *src, *dst;
>         struct zswap_header zhdr = { .swpentry = swp_entry(type, offset) };
>
> +       if (!zswap_max_pool_percent) {
> +               ret = -ENOMEM;
> +               goto reject;
> +       }
> +
>         /* THP isn't supported */
>         if (PageTransHuge(page)) {
>                 ret = -EINVAL;
> --
> 2.9.5
>
