Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 345FE8E0001
	for <linux-mm@kvack.org>; Sun,  6 Jan 2019 10:58:00 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id t133so46175548iof.20
        for <linux-mm@kvack.org>; Sun, 06 Jan 2019 07:58:00 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j79sor23583883jad.11.2019.01.06.07.57.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 06 Jan 2019 07:57:59 -0800 (PST)
MIME-Version: 1.0
References: <0100016819f5682e-a7e2541c-4390-4e14-ac65-8793243215c6-000000@email.amazonses.com>
In-Reply-To: <0100016819f5682e-a7e2541c-4390-4e14-ac65-8793243215c6-000000@email.amazonses.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sun, 6 Jan 2019 16:57:47 +0100
Message-ID: <CACT4Y+avxq-9MshcDAtKMpGbQPBGvAmK801TuTgiK12onM9H9Q@mail.gmail.com>
Subject: Re: [FIX] slab: Alien caches must not be initialized if the
 allocation of the alien cache failed
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: akpm@linuxfoundation.org, Linux-MM <linux-mm@kvack.org>, stable@kernel.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri, Jan 4, 2019 at 6:42 PM Christopher Lameter <cl@linux.com> wrote:
>
> From: Christoph Lameter <cl@linux.com>
>
> Callers of __alloc_alien() check for NULL.
> We must do the same check in __alloc_alien() after the allocation of
> the alien cache to avoid potential NULL pointer dereferences
> should the  allocation fail.
>
> Fixes: 49dfc304ba241b315068023962004542c5118103 ("slab: use the lock on alien_cache, instead of the lock on array_cache")
> Fixes: c8522a3a5832b843570a3315674f5a3575958a5 ("Slab: introduce alloc_alien")
> Signed-off-by: Christoph Lameter <cl@linux.com>

Please also add the Reported-by tag to commit for tracking purposes:

Reported-by: syzbot+d6ed4ec679652b4fd4e4@syzkaller.appspotmail.com


> Index: linux/mm/slab.c
> ===================================================================
> --- linux.orig/mm/slab.c
> +++ linux/mm/slab.c
> @@ -666,8 +666,10 @@ static struct alien_cache *__alloc_alien
>         struct alien_cache *alc = NULL;
>
>         alc = kmalloc_node(memsize, gfp, node);
> -       init_arraycache(&alc->ac, entries, batch);
> -       spin_lock_init(&alc->lock);
> +       if (alc) {
> +               init_arraycache(&alc->ac, entries, batch);
> +               spin_lock_init(&alc->lock);
> +       }
>         return alc;
>  }
>
