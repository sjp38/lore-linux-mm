Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 675FC6B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 10:41:15 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id m98so115043874iod.2
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 07:41:15 -0800 (PST)
Received: from mail-io0-x236.google.com (mail-io0-x236.google.com. [2607:f8b0:4001:c06::236])
        by mx.google.com with ESMTPS id g199si12062735ioe.8.2017.02.07.07.41.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 07:41:14 -0800 (PST)
Received: by mail-io0-x236.google.com with SMTP id l66so92923853ioi.1
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 07:41:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170207140707.20824-1-sean@erifax.org>
References: <20170207140707.20824-1-sean@erifax.org>
From: Thomas Garnier <thgarnie@google.com>
Date: Tue, 7 Feb 2017 07:41:13 -0800
Message-ID: <CAJcbSZEKdgpuTYWO4R-KP3c2fsi-8OKyE=JhF1e83n+SYLrxAQ@mail.gmail.com>
Subject: Re: [PATCH] mm/slub: Fix random_seq offset destruction
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sean Rees <sean@erifax.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Feb 7, 2017 at 6:07 AM, Sean Rees <sean@erifax.org> wrote:
> Bailout early from init_cache_random_seq if s->random_seq is already
> initialised. This prevents destroying the previously computed random_seq
> offsets later in the function.
>
> If the offsets are destroyed, then shuffle_freelist will truncate
> page->freelist to just the first object (orphaning the rest).
>
> This fixes https://bugzilla.kernel.org/show_bug.cgi?id=177551.
>
> Signed-off-by: Sean Rees <sean@erifax.org>

Please add:

Fixes: 210e7a43fa90 ("mm: SLUB freelist randomization")

> ---
>  mm/slub.c | 4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/mm/slub.c b/mm/slub.c
> index 7aa6f43..7ec0a96 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1422,6 +1422,10 @@ static int init_cache_random_seq(struct kmem_cache *s)
>         int err;
>         unsigned long i, count = oo_objects(s->oo);
>
> +       /* Bailout if already initialised */
> +       if (s->random_seq)
> +               return 0;
> +
>         err = cache_random_seq_create(s, count, GFP_KERNEL);
>         if (err) {
>                 pr_err("SLUB: Unable to initialize free list for %s\n",
> --
> 2.9.3
>

Otherwise, looks good to me.

Reviewed-by: Thomas Garnier <thgarnie@google.com>

-- 
Thomas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
