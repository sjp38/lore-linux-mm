Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8146D6B0035
	for <linux-mm@kvack.org>; Thu, 28 Aug 2014 04:21:04 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id hz1so1575484pad.6
        for <linux-mm@kvack.org>; Thu, 28 Aug 2014 01:21:01 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id g3si4729319pdn.222.2014.08.28.01.20.59
        for <linux-mm@kvack.org>;
        Thu, 28 Aug 2014 01:21:00 -0700 (PDT)
Date: Thu, 28 Aug 2014 17:21:08 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v5 3/4] zram: zram memory size limitation
Message-ID: <20140828082108.GA17910@js1304-P5Q-DELUXE>
References: <1408925156-11733-1-git-send-email-minchan@kernel.org>
 <1408925156-11733-4-git-send-email-minchan@kernel.org>
 <20140826073730.GA1975@js1304-P5Q-DELUXE>
 <20140826075511.GI11319@bbox>
 <CAFdhcLQce05qi2LGP85N=aaQiKz1ArC3Kn+W-s86R58BkjMr3w@mail.gmail.com>
 <20140827012610.GA10198@js1304-P5Q-DELUXE>
 <20140827025132.GI32620@bbox>
 <20140827050438.GA13300@js1304-P5Q-DELUXE>
 <20140827072819.GK32620@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140827072819.GK32620@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: David Horner <ds2horner@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>

On Wed, Aug 27, 2014 at 04:28:19PM +0900, Minchan Kim wrote:
> On Wed, Aug 27, 2014 at 02:04:38PM +0900, Joonsoo Kim wrote:
> > On Wed, Aug 27, 2014 at 11:51:32AM +0900, Minchan Kim wrote:
> > > Hey Joonsoo,
> > > 
> > > On Wed, Aug 27, 2014 at 10:26:11AM +0900, Joonsoo Kim wrote:
> > > > Hello, Minchan and David.
> > > > 
> > > > On Tue, Aug 26, 2014 at 08:22:29AM -0400, David Horner wrote:
> > > > > On Tue, Aug 26, 2014 at 3:55 AM, Minchan Kim <minchan@kernel.org> wrote:
> > > > > > Hey Joonsoo,
> > > > > >
> > > > > > On Tue, Aug 26, 2014 at 04:37:30PM +0900, Joonsoo Kim wrote:
> > > > > >> On Mon, Aug 25, 2014 at 09:05:55AM +0900, Minchan Kim wrote:
> > > > > >> > @@ -513,6 +540,14 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
> > > > > >> >             ret = -ENOMEM;
> > > > > >> >             goto out;
> > > > > >> >     }
> > > > > >> > +
> > > > > >> > +   if (zram->limit_pages &&
> > > > > >> > +           zs_get_total_pages(meta->mem_pool) > zram->limit_pages) {
> > > > > >> > +           zs_free(meta->mem_pool, handle);
> > > > > >> > +           ret = -ENOMEM;
> > > > > >> > +           goto out;
> > > > > >> > +   }
> > > > > >> > +
> > > > > >> >     cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_WO);
> > > > > >>
> > > > > >> Hello,
> > > > > >>
> > > > > >> I don't follow up previous discussion, so I could be wrong.
> > > > > >> Why this enforcement should be here?
> > > > > >>
> > > > > >> I think that this has two problems.
> > > > > >> 1) alloc/free happens unnecessarilly if we have used memory over the
> > > > > >> limitation.
> > > > > >
> > > > > > True but firstly, I implemented the logic in zsmalloc, not zram but
> > > > > > as I described in cover-letter, it's not a requirement of zsmalloc
> > > > > > but zram so it should be in there. If every user want it in future,
> > > > > > then we could move the function into zsmalloc. That's what we
> > > > > > concluded in previous discussion.
> > > > 
> > > > Hmm...
> > > > Problem is that we can't avoid these unnecessary overhead in this
> > > > implementation. If we can implement this feature in zram efficiently,
> > > > it's okay. But, I think that current form isn't.
> > > 
> > > 
> > > If we can add it in zsmalloc, it would be more clean and efficient
> > > for zram but as I said, at the moment, I didn't want to put zram's
> > > requirement into zsmalloc because to me, it's weird to enforce max
> > > limit to allocator. It's client's role, I think.
> > 
> > AFAIK, many kinds of pools such as thread-pool or memory-pool have
> > their own limit. It's not weird for me.
> 
> Actually I don't know what is pool allocator but things you mentioned
> is basically used to gaurantee *new* thread/memory, not limit although
> it would implement limit.
> 
> Another question, why do you think zsmalloc is pool allocator?
> IOW, What logic makes you think it's pool allocator?

In fact, it is not pool allocator for now. But, it looks like pool
allocator because it is used only for one zram device. If there are
many zram devices, there are many zs_pool and their memory cannot be
shared. It is totally isolated each other. We can easily make it
actual pool allocator or impose memory usage limit on it with this
property. This make me think that zsmalloc is better place to limit
memory usage.

Anyway, I don't have strong objection to current implementation. You
can fix it later when it turn out to be real problem.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
