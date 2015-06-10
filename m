Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 66D206B0038
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 17:00:14 -0400 (EDT)
Received: by qkx62 with SMTP id 62so31386265qkx.3
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 14:00:14 -0700 (PDT)
Received: from mail-qk0-x22c.google.com (mail-qk0-x22c.google.com. [2607:f8b0:400d:c09::22c])
        by mx.google.com with ESMTPS id t77si9906455qga.36.2015.06.10.14.00.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jun 2015 14:00:13 -0700 (PDT)
Received: by qkoo18 with SMTP id o18so31728337qko.1
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 14:00:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1433851493-23685-5-git-send-email-sergey.senozhatsky@gmail.com>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com> <1433851493-23685-5-git-send-email-sergey.senozhatsky@gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Wed, 10 Jun 2015 16:59:53 -0400
Message-ID: <CALZtONAyQn1qGusF4TXcS1FHmiHNmJT+Wrh2G6j7OYA=R+Q0dQ@mail.gmail.com>
Subject: Re: [RFC][PATCH 4/5] mm/zpool: allow NULL `zpool' pointer in zpool_destroy_pool()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Tue, Jun 9, 2015 at 8:04 AM, Sergey Senozhatsky
<sergey.senozhatsky@gmail.com> wrote:
> zpool_destroy_pool() does not tolerate a NULL zpool pointer
> argument and performs a NULL-pointer dereference. Although
> there is only one zpool_destroy_pool() user (as of 4.1),
> still update it to be coherent with the corresponding
> destroy() functions of the remainig pool-allocators (slab,
> mempool, etc.), which now allow NULL pool-pointers.
>
> For consistency, tweak zpool_destroy_pool() and NULL-check the
> pointer there.
>
> Proposed by Andrew Morton.
>
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Reported-by: Andrew Morton <akpm@linux-foundation.org>
> LKML-reference: https://lkml.org/lkml/2015/6/8/583

Acked-by: Dan Streetman <ddstreet@ieee.org>

> ---
>  mm/zpool.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/mm/zpool.c b/mm/zpool.c
> index bacdab6..2f59b90 100644
> --- a/mm/zpool.c
> +++ b/mm/zpool.c
> @@ -202,6 +202,9 @@ struct zpool *zpool_create_pool(char *type, char *name, gfp_t gfp,
>   */
>  void zpool_destroy_pool(struct zpool *zpool)
>  {
> +       if (unlikely(!zpool))
> +               return;
> +
>         pr_info("destroying pool type %s\n", zpool->type);
>
>         spin_lock(&pools_lock);
> --
> 2.4.3.368.g7974889
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
