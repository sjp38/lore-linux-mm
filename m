Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7EAB36B0035
	for <linux-mm@kvack.org>; Tue, 26 Aug 2014 21:25:57 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id bj1so24385987pad.39
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 18:25:57 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id sc9si6836904pac.60.2014.08.26.18.25.53
        for <linux-mm@kvack.org>;
        Tue, 26 Aug 2014 18:25:55 -0700 (PDT)
Date: Wed, 27 Aug 2014 10:26:11 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v5 3/4] zram: zram memory size limitation
Message-ID: <20140827012610.GA10198@js1304-P5Q-DELUXE>
References: <1408925156-11733-1-git-send-email-minchan@kernel.org>
 <1408925156-11733-4-git-send-email-minchan@kernel.org>
 <20140826073730.GA1975@js1304-P5Q-DELUXE>
 <20140826075511.GI11319@bbox>
 <CAFdhcLQce05qi2LGP85N=aaQiKz1ArC3Kn+W-s86R58BkjMr3w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFdhcLQce05qi2LGP85N=aaQiKz1ArC3Kn+W-s86R58BkjMr3w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Horner <ds2horner@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>

Hello, Minchan and David.

On Tue, Aug 26, 2014 at 08:22:29AM -0400, David Horner wrote:
> On Tue, Aug 26, 2014 at 3:55 AM, Minchan Kim <minchan@kernel.org> wrote:
> > Hey Joonsoo,
> >
> > On Tue, Aug 26, 2014 at 04:37:30PM +0900, Joonsoo Kim wrote:
> >> On Mon, Aug 25, 2014 at 09:05:55AM +0900, Minchan Kim wrote:
> >> > @@ -513,6 +540,14 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
> >> >             ret = -ENOMEM;
> >> >             goto out;
> >> >     }
> >> > +
> >> > +   if (zram->limit_pages &&
> >> > +           zs_get_total_pages(meta->mem_pool) > zram->limit_pages) {
> >> > +           zs_free(meta->mem_pool, handle);
> >> > +           ret = -ENOMEM;
> >> > +           goto out;
> >> > +   }
> >> > +
> >> >     cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_WO);
> >>
> >> Hello,
> >>
> >> I don't follow up previous discussion, so I could be wrong.
> >> Why this enforcement should be here?
> >>
> >> I think that this has two problems.
> >> 1) alloc/free happens unnecessarilly if we have used memory over the
> >> limitation.
> >
> > True but firstly, I implemented the logic in zsmalloc, not zram but
> > as I described in cover-letter, it's not a requirement of zsmalloc
> > but zram so it should be in there. If every user want it in future,
> > then we could move the function into zsmalloc. That's what we
> > concluded in previous discussion.

Hmm...
Problem is that we can't avoid these unnecessary overhead in this
implementation. If we can implement this feature in zram efficiently,
it's okay. But, I think that current form isn't.

> >
> > Another idea is we could call zs_get_total_pages right before zs_malloc
> > but the problem is we cannot know how many of pages are allocated
> > by zsmalloc in advance.
> > IOW, zram should be blind on zsmalloc's internal.
> >
> 
> We did however suggest that we could check before hand to see if
> max was already exceeded as an optimization.
> (possibly with a guess on usage but at least using the minimum of 1 page)
> In the contested case, the max may already be exceeded transiently and
> therefore we know this one _could_ fail (it could also pass, but odds
> aren't good).
> As Minchan mentions this was discussed before - but not into great detail.
> Testing should be done to determine possible benefit. And as he also
> mentions, the better place for it may be in zsmalloc, but that
> requires an ABI change.

Why we hesitate to change zsmalloc API? It is in-kernel API and there
are just two users now, zswap and zram. We can change it easily.
I think that we just need following simple API change in zsmalloc.c.

zs_zpool_create(gfp_t gfp, struct zpool_ops *zpool_op)
=>
zs_zpool_create(unsigned long limit, gfp_t gfp, struct zpool_ops
*zpool_op)

It's pool allocator so there is no obstacle for us to limit maximum
memory usage in zsmalloc. It's a natural idea to limit memory usage
for pool allocator.

> Certainly a detailed suggestion could happen on this thread and I'm
> also interested
> in your thoughts, but this patchset should be able to go in as is.
> Memory exhaustion avoidance probably trumps the possible thrashing at
> threshold.
> 
> > About alloc/free cost once if it is over the limit,
> > I don't think it's important to consider.
> > Do you have any scenario in your mind to consider alloc/free cost
> > when the limit is over?
> >
> >> 2) Even if this request doesn't do new allocation, it could be failed
> >> due to other's allocation. There is time gap between allocation and
> >> free, so legimate user who want to use preallocated zsmalloc memory
> >> could also see this condition true and then he will be failed.
> >
> > Yeb, we already discussed that. :)
> > Such false positive shouldn't be a severe problem if we can keep a
> > promise that zram user cannot exceed mem_limit.
> >

If we can keep such a promise, why we need to limit memory usage?
I guess that this limit feature is useful for user who can't keep such promise.
So, we should assume that this false positive happens frequently.

> And we cannot avoid the race, nor can we avoid in a low overhead competitive
> concurrent process transient inconsistent states.
> Different views for different observers.
>  They are a consequence of the theory of "Special Computational Relativity".
>  I am working on a String Unification Theory of Quantum and General CR in LISP.
>  ;-)

If we move limit logic to zsmalloc, we can avoid the race by commiting
needed memory size before actual allocation attempt. This commiting makes
concurrent process serialized so there is no race here. There is
possibilty to fail to allocate, but I think this is better than alloc
and free blindlessly depending on inconsistent states.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
