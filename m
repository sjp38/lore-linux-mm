Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 89FEC6B3F4E
	for <linux-mm@kvack.org>; Sun, 25 Nov 2018 21:00:10 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id h7so17507228iof.19
        for <linux-mm@kvack.org>; Sun, 25 Nov 2018 18:00:10 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r8sor16329463ioo.135.2018.11.25.18.00.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 25 Nov 2018 18:00:09 -0800 (PST)
MIME-Version: 1.0
References: <20181117013335.32220-1-wen.gang.wang@oracle.com> <5BF36EE9.9090808@huawei.com>
In-Reply-To: <5BF36EE9.9090808@huawei.com>
From: Wei Yang <richard.weiyang@gmail.com>
Date: Mon, 26 Nov 2018 09:59:58 +0800
Message-ID: <CADZGycb=kxdqSdbdXNWwmgyWp2CtC3-UFmy1-PqtdgS2BrmyjA@mail.gmail.com>
Subject: Re: [PATCH] mm: use this_cpu_cmpxchg_double in put_cpu_partial
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Wengang Wang <wen.gang.wang@oracle.com>, Christopher Lameter <cl@linux.com>, penberg@kernel.org, David Rientjes <rientjes@google.com>, iamjoonsoo.kim@lge.com, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Nov 20, 2018 at 10:58 AM zhong jiang <zhongjiang@huawei.com> wrote:
>
> On 2018/11/17 9:33, Wengang Wang wrote:
> > The this_cpu_cmpxchg makes the do-while loop pass as long as the
> > s->cpu_slab->partial as the same value. It doesn't care what happened to
> > that slab. Interrupt is not disabled, and new alloc/free can happen in the
> > interrupt handlers. Theoretically, after we have a reference to the it,
> > stored in _oldpage_, the first slab on the partial list on this CPU can be
> > moved to kmem_cache_node and then moved to different kmem_cache_cpu and
> > then somehow can be added back as head to partial list of current
> > kmem_cache_cpu, though that is a very rare case. If that rare case really
> > happened, the reading of oldpage->pobjects may get a 0xdead0000
> > unexpectedly, stored in _pobjects_, if the reading happens just after
> > another CPU removed the slab from kmem_cache_node, setting lru.prev to
> > LIST_POISON2 (0xdead000000000200). The wrong _pobjects_(negative) then
> > prevents slabs from being moved to kmem_cache_node and being finally freed.
> >
> > We see in a vmcore, there are 375210 slabs kept in the partial list of one
> > kmem_cache_cpu, but only 305 in-use objects in the same list for
> > kmalloc-2048 cache. We see negative values for page.pobjects, the last page
> > with negative _pobjects_ has the value of 0xdead0004, the next page looks
> > good (_pobjects is 1).
> >
> > For the fix, I wanted to call this_cpu_cmpxchg_double with
> > oldpage->pobjects, but failed due to size difference between
> > oldpage->pobjects and cpu_slab->partial. So I changed to call
> > this_cpu_cmpxchg_double with _tid_. I don't really want no alloc/free
> > happen in between, but just want to make sure the first slab did expereince
> > a remove and re-add. This patch is more to call for ideas.
> Have you hit the really issue or just review the code ?
>
> I did hit the issue and fixed in the upstream patch unpredictably by the following patch.
> e5d9998f3e09 ("slub: make ->cpu_partial unsigned int")
>

Zhong,

I took a look into your upstream patch, while I am confused how your patch
fix this issue?

In put_cpu_partial(), the cmpxchg compare cpu_slab->partial (a page struct)
instead of the cpu_partial (an unsigned integer). I didn't get the
point of this fix.

> Thanks,
> zhong jiang
> > Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
> > ---
> >  mm/slub.c | 20 +++++++++++++++++---
> >  1 file changed, 17 insertions(+), 3 deletions(-)
> >
> > diff --git a/mm/slub.c b/mm/slub.c
> > index e3629cd..26539e6 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -2248,6 +2248,7 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
> >  {
> >  #ifdef CONFIG_SLUB_CPU_PARTIAL
> >       struct page *oldpage;
> > +     unsigned long tid;
> >       int pages;
> >       int pobjects;
> >
> > @@ -2255,8 +2256,12 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
> >       do {
> >               pages = 0;
> >               pobjects = 0;
> > -             oldpage = this_cpu_read(s->cpu_slab->partial);
> >
> > +             tid = this_cpu_read(s->cpu_slab->tid);
> > +             /* read tid before reading oldpage */
> > +             barrier();
> > +
> > +             oldpage = this_cpu_read(s->cpu_slab->partial);
> >               if (oldpage) {
> >                       pobjects = oldpage->pobjects;
> >                       pages = oldpage->pages;
> > @@ -2283,8 +2288,17 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
> >               page->pobjects = pobjects;
> >               page->next = oldpage;
> >
> > -     } while (this_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page)
> > -                                                             != oldpage);
> > +             /* we dont' change tid, but want to make sure it didn't change
> > +              * in between. We don't really hope alloc/free not happen on
> > +              * this CPU, but don't want the first slab be removed from and
> > +              * then re-added as head to this partial list. If that case
> > +              * happened, pobjects may read 0xdead0000 when this slab is just
> > +              * removed from kmem_cache_node by other CPU setting lru.prev
> > +              * to LIST_POISON2.
> > +              */
> > +     } while (this_cpu_cmpxchg_double(s->cpu_slab->partial, s->cpu_slab->tid,
> > +                                      oldpage, tid, page, tid) == 0);
> > +
> >       if (unlikely(!s->cpu_partial)) {
> >               unsigned long flags;
> >
>
>
