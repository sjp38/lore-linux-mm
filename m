Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5DCFE6B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 03:27:31 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id w10so23691126pde.18
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 00:27:30 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id rd7si7534265pab.160.2014.08.27.00.27.28
        for <linux-mm@kvack.org>;
        Wed, 27 Aug 2014 00:27:30 -0700 (PDT)
Date: Wed, 27 Aug 2014 16:28:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v5 3/4] zram: zram memory size limitation
Message-ID: <20140827072819.GK32620@bbox>
References: <1408925156-11733-1-git-send-email-minchan@kernel.org>
 <1408925156-11733-4-git-send-email-minchan@kernel.org>
 <20140826073730.GA1975@js1304-P5Q-DELUXE>
 <20140826075511.GI11319@bbox>
 <CAFdhcLQce05qi2LGP85N=aaQiKz1ArC3Kn+W-s86R58BkjMr3w@mail.gmail.com>
 <20140827012610.GA10198@js1304-P5Q-DELUXE>
 <20140827025132.GI32620@bbox>
 <20140827050438.GA13300@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20140827050438.GA13300@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: David Horner <ds2horner@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>

On Wed, Aug 27, 2014 at 02:04:38PM +0900, Joonsoo Kim wrote:
> On Wed, Aug 27, 2014 at 11:51:32AM +0900, Minchan Kim wrote:
> > Hey Joonsoo,
> > 
> > On Wed, Aug 27, 2014 at 10:26:11AM +0900, Joonsoo Kim wrote:
> > > Hello, Minchan and David.
> > > 
> > > On Tue, Aug 26, 2014 at 08:22:29AM -0400, David Horner wrote:
> > > > On Tue, Aug 26, 2014 at 3:55 AM, Minchan Kim <minchan@kernel.org> wrote:
> > > > > Hey Joonsoo,
> > > > >
> > > > > On Tue, Aug 26, 2014 at 04:37:30PM +0900, Joonsoo Kim wrote:
> > > > >> On Mon, Aug 25, 2014 at 09:05:55AM +0900, Minchan Kim wrote:
> > > > >> > @@ -513,6 +540,14 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
> > > > >> >             ret = -ENOMEM;
> > > > >> >             goto out;
> > > > >> >     }
> > > > >> > +
> > > > >> > +   if (zram->limit_pages &&
> > > > >> > +           zs_get_total_pages(meta->mem_pool) > zram->limit_pages) {
> > > > >> > +           zs_free(meta->mem_pool, handle);
> > > > >> > +           ret = -ENOMEM;
> > > > >> > +           goto out;
> > > > >> > +   }
> > > > >> > +
> > > > >> >     cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_WO);
> > > > >>
> > > > >> Hello,
> > > > >>
> > > > >> I don't follow up previous discussion, so I could be wrong.
> > > > >> Why this enforcement should be here?
> > > > >>
> > > > >> I think that this has two problems.
> > > > >> 1) alloc/free happens unnecessarilly if we have used memory over the
> > > > >> limitation.
> > > > >
> > > > > True but firstly, I implemented the logic in zsmalloc, not zram but
> > > > > as I described in cover-letter, it's not a requirement of zsmalloc
> > > > > but zram so it should be in there. If every user want it in future,
> > > > > then we could move the function into zsmalloc. That's what we
> > > > > concluded in previous discussion.
> > > 
> > > Hmm...
> > > Problem is that we can't avoid these unnecessary overhead in this
> > > implementation. If we can implement this feature in zram efficiently,
> > > it's okay. But, I think that current form isn't.
> > 
> > 
> > If we can add it in zsmalloc, it would be more clean and efficient
> > for zram but as I said, at the moment, I didn't want to put zram's
> > requirement into zsmalloc because to me, it's weird to enforce max
> > limit to allocator. It's client's role, I think.
> 
> AFAIK, many kinds of pools such as thread-pool or memory-pool have
> their own limit. It's not weird for me.

Actually I don't know what is pool allocator but things you mentioned
is basically used to gaurantee *new* thread/memory, not limit although
it would implement limit.

Another question, why do you think zsmalloc is pool allocator?
IOW, What logic makes you think it's pool allocator?

> 
> > If current implementation is expensive and rather hard to follow,
> > It would be one reason to move the feature into zsmalloc but
> > I don't think it makes critical trobule in zram usecase.
> > See below.
> > 
> > But I still open and will wait others's opinion.
> > If other guys think zsmalloc is better place, I am willing to move
> > it into zsmalloc.
> > 
> > > 
> > > > >
> > > > > Another idea is we could call zs_get_total_pages right before zs_malloc
> > > > > but the problem is we cannot know how many of pages are allocated
> > > > > by zsmalloc in advance.
> > > > > IOW, zram should be blind on zsmalloc's internal.
> > > > >
> > > > 
> > > > We did however suggest that we could check before hand to see if
> > > > max was already exceeded as an optimization.
> > > > (possibly with a guess on usage but at least using the minimum of 1 page)
> > > > In the contested case, the max may already be exceeded transiently and
> > > > therefore we know this one _could_ fail (it could also pass, but odds
> > > > aren't good).
> > > > As Minchan mentions this was discussed before - but not into great detail.
> > > > Testing should be done to determine possible benefit. And as he also
> > > > mentions, the better place for it may be in zsmalloc, but that
> > > > requires an ABI change.
> > > 
> > > Why we hesitate to change zsmalloc API? It is in-kernel API and there
> > > are just two users now, zswap and zram. We can change it easily.
> > > I think that we just need following simple API change in zsmalloc.c.
> > > 
> > > zs_zpool_create(gfp_t gfp, struct zpool_ops *zpool_op)
> > > =>
> > > zs_zpool_create(unsigned long limit, gfp_t gfp, struct zpool_ops
> > > *zpool_op)
> > > 
> > > It's pool allocator so there is no obstacle for us to limit maximum
> > > memory usage in zsmalloc. It's a natural idea to limit memory usage
> > > for pool allocator.
> > > 
> > > > Certainly a detailed suggestion could happen on this thread and I'm
> > > > also interested
> > > > in your thoughts, but this patchset should be able to go in as is.
> > > > Memory exhaustion avoidance probably trumps the possible thrashing at
> > > > threshold.
> > > > 
> > > > > About alloc/free cost once if it is over the limit,
> > > > > I don't think it's important to consider.
> > > > > Do you have any scenario in your mind to consider alloc/free cost
> > > > > when the limit is over?
> > > > >
> > > > >> 2) Even if this request doesn't do new allocation, it could be failed
> > > > >> due to other's allocation. There is time gap between allocation and
> > > > >> free, so legimate user who want to use preallocated zsmalloc memory
> > > > >> could also see this condition true and then he will be failed.
> > > > >
> > > > > Yeb, we already discussed that. :)
> > > > > Such false positive shouldn't be a severe problem if we can keep a
> > > > > promise that zram user cannot exceed mem_limit.
> > > > >
> > > 
> > > If we can keep such a promise, why we need to limit memory usage?
> > > I guess that this limit feature is useful for user who can't keep such promise.
> > > So, we should assume that this false positive happens frequently.
> > 
> > 
> > The goal is to limit memory usage within some threshold.
> > so false positive shouldn't be harmful unless it exceeds the threshold.
> > In addition, If such false positive happens frequently, it means
> > zram is very trobule so that user would see lots of write fail
> > message, sometime really slow system if zram is used for swap.
> > If we protect just one write from the race, how much does it help
> > this situation? I don't think it's critical problem.
> 
> If it is just rarely happend event that memory usage exceeds the threshold,
> why this limit is needed? Could you tell me when this limit is useful
> with such assumption?

If there is no feature, zram can use up all of memory so it's out of control.
Although we could control virtual disksize, it's not perfect all the time.
I expect userspace will have more flexibility to handle memory if zram support
the feature. For example, system can set the limit very low and if it hit the
limit and see enough free memory in system, he could increase the limit to
the hard limit. If it hit the hard limit and other component needs more memory,
we could decrease the limit and kill old process to get a free memory.
It's a simple example but it might give more freedom to userspace memory
manager.

> 
> > 
> > > 
> > > > And we cannot avoid the race, nor can we avoid in a low overhead competitive
> > > > concurrent process transient inconsistent states.
> > > > Different views for different observers.
> > > >  They are a consequence of the theory of "Special Computational Relativity".
> > > >  I am working on a String Unification Theory of Quantum and General CR in LISP.
> > > >  ;-)
> > > 
> > > If we move limit logic to zsmalloc, we can avoid the race by commiting
> > > needed memory size before actual allocation attempt. This commiting makes
> > > concurrent process serialized so there is no race here. There is
> > > possibilty to fail to allocate, but I think this is better than alloc
> > > and free blindlessly depending on inconsistent states.
> > 
> > Normally, zsmalloc/zsfree allocates object from existing pool so
> > it's not big overhead and if someone continue to try writing  once limit is
> > full, another overhead (vfs, fs, block) would be bigger than zsmalloc
> > so it's not a problem, I think.
> 
> We should do our best, regardless other subsystem does. If there is
> known possibility to suffer from needless alloc/free, why we ignore
> it? :)

Yeb, I'd like to do my best and gap between you and me is just difference
of which is best.

> 
> Thanks.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
