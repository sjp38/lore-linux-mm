Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id BC0E66B000A
	for <linux-mm@kvack.org>; Wed, 30 May 2018 08:54:03 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id k129-v6so10011804itg.8
        for <linux-mm@kvack.org>; Wed, 30 May 2018 05:54:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v25-v6sor529823iog.107.2018.05.30.05.54.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 May 2018 05:54:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180530103936.17812-1-liwang@redhat.com>
References: <20180530103936.17812-1-liwang@redhat.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Wed, 30 May 2018 08:53:21 -0400
Message-ID: <CALZtONBKSVfXe+RHOjgS=4VrDqFsxNRx3OuGctp0o1Hrtix3Ew@mail.gmail.com>
Subject: Re: [PATCH v2] zswap: re-check zswap_is_full after do zswap_shrink
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Wang <liwang@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Seth Jennings <sjenning@redhat.com>, Huang Ying <huang.ying.caritas@gmail.com>, Yu Zhao <yuzhao@google.com>

On Wed, May 30, 2018 at 6:39 AM, Li Wang <liwang@redhat.com> wrote:
> The '/sys/../zswap/stored_pages:' keep raising in zswap test with
> "zswap.max_pool_percent=0" parameter. But theoretically, it should
> not compress or store pages any more since there is no space in
> compressed pool.
>
> Reproduce steps:
>   1. Boot kernel with "zswap.enabled=1"
>   2. Set the max_pool_percent to 0
>       # echo 0 > /sys/module/zswap/parameters/max_pool_percent
>   3. Do memory stress test to see if some pages have been compressed
>       # stress --vm 1 --vm-bytes $mem_available"M" --timeout 60s
>   4. Watching the 'stored_pages' number increasing or not
>
> The root cause is:
>   When zswap_max_pool_percent is setting to 0 via kernel parameter, the
>   zswap_is_full() will always return true to do zswap_shrink(). But if
>   the shinking is able to reclain a page successful, then proceeds to
>   compress/store another page, so the value of stored_pages will keep
>   changing.
>
> To solve the issue, this patch adds zswap_is_full() check again after
> zswap_shrink() to make sure it's now under the max_pool_percent, and
> not to compress/store if reach its limitaion.
>
> Signed-off-by: Li Wang <liwang@redhat.com>

Acked-by: Dan Streetman <ddstreet@ieee.org>

> Cc: Seth Jennings <sjenning@redhat.com>
> Cc: Dan Streetman <ddstreet@ieee.org>
> Cc: Huang Ying <huang.ying.caritas@gmail.com>
> Cc: Yu Zhao <yuzhao@google.com>
> ---
>  mm/zswap.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
>
> diff --git a/mm/zswap.c b/mm/zswap.c
> index 61a5c41..fd320c3 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -1026,6 +1026,15 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
>                         ret = -ENOMEM;
>                         goto reject;
>                 }
> +
> +               /* A second zswap_is_full() check after
> +                * zswap_shrink() to make sure it's now
> +                * under the max_pool_percent
> +                */
> +               if (zswap_is_full()) {
> +                       ret = -ENOMEM;
> +                       goto reject;
> +               }
>         }
>
>         /* allocate entry */
> --
> 2.9.5
>
