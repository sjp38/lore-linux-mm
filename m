Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id D66D26B0037
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 10:44:56 -0400 (EDT)
Received: by mail-qa0-f51.google.com with SMTP id k15so309649qaq.10
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 07:44:56 -0700 (PDT)
Received: from mail-qa0-x22a.google.com (mail-qa0-x22a.google.com [2607:f8b0:400d:c00::22a])
        by mx.google.com with ESMTPS id q90si876759qga.5.2014.08.27.07.44.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 27 Aug 2014 07:44:56 -0700 (PDT)
Received: by mail-qa0-f42.google.com with SMTP id j15so301961qaq.15
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 07:44:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALZtONDij=uioTACao7oK-44FsNX90ODXivwJWauFsgx01-=YQ@mail.gmail.com>
References: <1408925156-11733-1-git-send-email-minchan@kernel.org>
	<1408925156-11733-4-git-send-email-minchan@kernel.org>
	<20140826073730.GA1975@js1304-P5Q-DELUXE>
	<20140826075511.GI11319@bbox>
	<CAFdhcLQce05qi2LGP85N=aaQiKz1ArC3Kn+W-s86R58BkjMr3w@mail.gmail.com>
	<20140827012610.GA10198@js1304-P5Q-DELUXE>
	<20140827025132.GI32620@bbox>
	<CALZtONDij=uioTACao7oK-44FsNX90ODXivwJWauFsgx01-=YQ@mail.gmail.com>
Date: Wed, 27 Aug 2014 10:44:55 -0400
Message-ID: <CAFdhcLTS-4U-ynDhGzbMO0vc9nWoMR1=anO-SNDN09VOrbSw7w@mail.gmail.com>
Subject: Re: [PATCH v5 3/4] zram: zram memory size limitation
From: David Horner <ds2horner@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>

On Wed, Aug 27, 2014 at 10:03 AM, Dan Streetman <ddstreet@ieee.org> wrote:
> On Tue, Aug 26, 2014 at 10:51 PM, Minchan Kim <minchan@kernel.org> wrote:
>> Hey Joonsoo,
>>
>> On Wed, Aug 27, 2014 at 10:26:11AM +0900, Joonsoo Kim wrote:
>>> Hello, Minchan and David.
>>>
>>> On Tue, Aug 26, 2014 at 08:22:29AM -0400, David Horner wrote:
>>> > On Tue, Aug 26, 2014 at 3:55 AM, Minchan Kim <minchan@kernel.org> wrote:
>>> > > Hey Joonsoo,
>>> > >
>>> > > On Tue, Aug 26, 2014 at 04:37:30PM +0900, Joonsoo Kim wrote:
>>> > >> On Mon, Aug 25, 2014 at 09:05:55AM +0900, Minchan Kim wrote:
>>> > >> > @@ -513,6 +540,14 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
>>> > >> >             ret = -ENOMEM;
>>> > >> >             goto out;
>>> > >> >     }
>>> > >> > +
>>> > >> > +   if (zram->limit_pages &&
>>> > >> > +           zs_get_total_pages(meta->mem_pool) > zram->limit_pages) {
>>> > >> > +           zs_free(meta->mem_pool, handle);
>>> > >> > +           ret = -ENOMEM;
>>> > >> > +           goto out;
>>> > >> > +   }
>>> > >> > +
>>> > >> >     cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_WO);
>>> > >>
>>> > >> Hello,
>>> > >>
>>> > >> I don't follow up previous discussion, so I could be wrong.
>>> > >> Why this enforcement should be here?
>>> > >>
>>> > >> I think that this has two problems.
>>> > >> 1) alloc/free happens unnecessarilly if we have used memory over the
>>> > >> limitation.
>>> > >
>>> > > True but firstly, I implemented the logic in zsmalloc, not zram but
>>> > > as I described in cover-letter, it's not a requirement of zsmalloc
>>> > > but zram so it should be in there. If every user want it in future,
>>> > > then we could move the function into zsmalloc. That's what we
>>> > > concluded in previous discussion.
>>>
>>> Hmm...
>>> Problem is that we can't avoid these unnecessary overhead in this
>>> implementation. If we can implement this feature in zram efficiently,
>>> it's okay. But, I think that current form isn't.
>>
>>
>> If we can add it in zsmalloc, it would be more clean and efficient
>> for zram but as I said, at the moment, I didn't want to put zram's
>> requirement into zsmalloc because to me, it's weird to enforce max
>> limit to allocator. It's client's role, I think.
>>
>> If current implementation is expensive and rather hard to follow,
>> It would be one reason to move the feature into zsmalloc but
>> I don't think it makes critical trobule in zram usecase.
>> See below.
>>
>> But I still open and will wait others's opinion.
>> If other guys think zsmalloc is better place, I am willing to move
>> it into zsmalloc.
>
> Moving it into zsmalloc would allow rejecting new zsmallocs before
> actually crossing the limit, since it can calculate that internally.
> However, with the current patches the limit will only be briefly
> crossed, and it should not be crossed by a large amount.  Now, if this
> is happening repeatedly and quickly during extreme memory pressure,
> the constant alloc/free will clearly be worse than a simple internal
> calculation and failure.  But would it ever happen repeatedly once the
> zram limit is reached?
>
> Now that I'm thinking about the limit from the perspective of the zram
> user, I wonder what really will happen.  If zram is being used for
> swap space, then when swap starts getting errors trying to write
> pages, how damaging will that be to the system?  I haven't checked
> what swap does when it encounters disk errors.  Of course, with no
> zram limit, continually writing to zram until memory is totally
> consumed isn't good either.  But in any case, I would hope that swap
> would not repeatedly hammer on a disk when it's getting write failures
> from it.
>
> Alternately, if zram was being used as a compressed ram disk for
> regular file storage, it's entirely up to the application to handle
> write failures, so it may continue to try to write to a full zram
> disk.
>
> As far as what the zsmalloc api would look like with the limit added,
> it would need a setter and getter function (adding it as a param to
> the create function would be optional i think).  But more importantly,
> it would need to handle multiple ways of specifying the limit.  In our
> specific current use cases, zram and zswap, each handles their
> internal limit differently - zswap currently uses a % of total ram as
> its limit (defaulting to 20), while with these patches zram will use a
> specific number of bytes as its limit (defaulting to no limit).  If
> the limiting mechanism is moved into zsmalloc (and possibly zbud),
> then either both users need to use the same units (bytes or %ram), or
> zsmalloc/zbud need to be able to set their limit in either units.  It
> seems to me like keeping the limit in zram/zswap is currently
> preferable, at least without both using the same limit units.
>

zswap knows what 20% (or whatever % it currently uses , and perhaps it too
will become a tuning knob) of memory is in bytes.

So, if the interface to establish a limit for a pool (or pool set, or whatever
zsmalloc sets up for its allocation mechanism) is stipulated in bytes
(to actually use pages internally, of visa-versa) , then both can use
that interface.
zram with its native page stipulation, and zswap with calculated % of memory).

Both would need a mechanism to change the max as need change,
 so the API has to handle this.


Or am I way off base?


>
>>
>>>
>>> > >
>>> > > Another idea is we could call zs_get_total_pages right before zs_malloc
>>> > > but the problem is we cannot know how many of pages are allocated
>>> > > by zsmalloc in advance.
>>> > > IOW, zram should be blind on zsmalloc's internal.
>>> > >
>>> >
>>> > We did however suggest that we could check before hand to see if
>>> > max was already exceeded as an optimization.
>>> > (possibly with a guess on usage but at least using the minimum of 1 page)
>>> > In the contested case, the max may already be exceeded transiently and
>>> > therefore we know this one _could_ fail (it could also pass, but odds
>>> > aren't good).
>>> > As Minchan mentions this was discussed before - but not into great detail.
>>> > Testing should be done to determine possible benefit. And as he also
>>> > mentions, the better place for it may be in zsmalloc, but that
>>> > requires an ABI change.
>>>
>>> Why we hesitate to change zsmalloc API? It is in-kernel API and there
>>> are just two users now, zswap and zram. We can change it easily.
>>> I think that we just need following simple API change in zsmalloc.c.
>>>
>>> zs_zpool_create(gfp_t gfp, struct zpool_ops *zpool_op)
>>> =>
>>> zs_zpool_create(unsigned long limit, gfp_t gfp, struct zpool_ops
>>> *zpool_op)
>>>
>>> It's pool allocator so there is no obstacle for us to limit maximum
>>> memory usage in zsmalloc. It's a natural idea to limit memory usage
>>> for pool allocator.
>>>
>>> > Certainly a detailed suggestion could happen on this thread and I'm
>>> > also interested
>>> > in your thoughts, but this patchset should be able to go in as is.
>>> > Memory exhaustion avoidance probably trumps the possible thrashing at
>>> > threshold.
>>> >
>>> > > About alloc/free cost once if it is over the limit,
>>> > > I don't think it's important to consider.
>>> > > Do you have any scenario in your mind to consider alloc/free cost
>>> > > when the limit is over?
>>> > >
>>> > >> 2) Even if this request doesn't do new allocation, it could be failed
>>> > >> due to other's allocation. There is time gap between allocation and
>>> > >> free, so legimate user who want to use preallocated zsmalloc memory
>>> > >> could also see this condition true and then he will be failed.
>>> > >
>>> > > Yeb, we already discussed that. :)
>>> > > Such false positive shouldn't be a severe problem if we can keep a
>>> > > promise that zram user cannot exceed mem_limit.
>>> > >
>>>
>>> If we can keep such a promise, why we need to limit memory usage?
>>> I guess that this limit feature is useful for user who can't keep such promise.
>>> So, we should assume that this false positive happens frequently.
>>
>>
>> The goal is to limit memory usage within some threshold.
>> so false positive shouldn't be harmful unless it exceeds the threshold.
>> In addition, If such false positive happens frequently, it means
>> zram is very trobule so that user would see lots of write fail
>> message, sometime really slow system if zram is used for swap.
>> If we protect just one write from the race, how much does it help
>> this situation? I don't think it's critical problem.
>>
>>>
>>> > And we cannot avoid the race, nor can we avoid in a low overhead competitive
>>> > concurrent process transient inconsistent states.
>>> > Different views for different observers.
>>> >  They are a consequence of the theory of "Special Computational Relativity".
>>> >  I am working on a String Unification Theory of Quantum and General CR in LISP.
>>> >  ;-)
>>>
>>> If we move limit logic to zsmalloc, we can avoid the race by commiting
>>> needed memory size before actual allocation attempt. This commiting makes
>>> concurrent process serialized so there is no race here. There is
>>> possibilty to fail to allocate, but I think this is better than alloc
>>> and free blindlessly depending on inconsistent states.
>>
>> Normally, zsmalloc/zsfree allocates object from existing pool so
>> it's not big overhead and if someone continue to try writing  once limit is
>> full, another overhead (vfs, fs, block) would be bigger than zsmalloc
>> so it's not a problem, I think.
>>
>>>
>>> Thanks.
>>>
>>> --
>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>> see: http://www.linux-mm.org/ .
>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
>> --
>> Kind regards,
>> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
