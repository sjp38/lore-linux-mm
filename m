Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1E9CE8E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 11:01:33 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id k133so36292480ite.4
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 08:01:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s21sor6202629iol.146.2019.01.02.08.01.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 08:01:32 -0800 (PST)
MIME-Version: 1.0
References: <0000000000000f35c6057e780d36@google.com> <CACT4Y+ZECp8Ymq=0QUNfwmfpQvWkBpoMgyUCuz0M=peehEeCHw@mail.gmail.com>
 <010001680f42f192-82b4e12e-1565-4ee0-ae1f-1e98974906aa-000000@email.amazonses.com>
In-Reply-To: <010001680f42f192-82b4e12e-1565-4ee0-ae1f-1e98974906aa-000000@email.amazonses.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 2 Jan 2019 17:01:20 +0100
Message-ID: <CACT4Y+Z8M+ODKobZYzWBbPv_y_Y2xNBfuUuX7iVceeLap2Yq3g@mail.gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in setup_kmem_cache_node
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: syzbot <syzbot+d6ed4ec679652b4fd4e4@syzkaller.appspotmail.com>, Dominique Martinet <asmadeus@codewreck.org>, David Miller <davem@davemloft.net>, Eric Van Hensbergen <ericvh@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Latchesar Ionkov <lucho@ionkov.net>, netdev <netdev@vger.kernel.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, v9fs-developer@lists.sourceforge.net, Linux-MM <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Jan 2, 2019 at 4:51 PM Christopher Lameter <cl@linux.com> wrote:
>
> On Wed, 2 Jan 2019, Dmitry Vyukov wrote:
>
> > Am I missing something or __alloc_alien_cache misses check for
> > kmalloc_node result?
> >
> > static struct alien_cache *__alloc_alien_cache(int node, int entries,
> >                                                 int batch, gfp_t gfp)
> > {
> >         size_t memsize = sizeof(void *) * entries + sizeof(struct alien_cache);
> >         struct alien_cache *alc = NULL;
> >
> >         alc = kmalloc_node(memsize, gfp, node);
> >         init_arraycache(&alc->ac, entries, batch);
> >         spin_lock_init(&alc->lock);
> >         return alc;
> > }
> >
>
>
> True _alloc_alien_cache() needs to check for NULL
>
>
> From: Christoph Lameter <cl@linux.com>
> Subject: slab: Alien caches must not be initialized if the allocation of the alien cache failed
>
> Callers of __alloc_alien() check for NULL.
> We must do the same check in __alloc_alien_cache to avoid NULL pointer dereferences
> on allocation failures.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>

Please add:
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
