Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id BC5C36B0036
	for <linux-mm@kvack.org>; Mon, 25 Aug 2014 22:18:53 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id z10so21451040pdj.30
        for <linux-mm@kvack.org>; Mon, 25 Aug 2014 19:18:53 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id g3si1803753pdk.230.2014.08.25.19.18.51
        for <linux-mm@kvack.org>;
        Mon, 25 Aug 2014 19:18:52 -0700 (PDT)
Date: Tue, 26 Aug 2014 11:19:04 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/3] mm/slab: use percpu allocator for cpu cache
Message-ID: <20140826021904.GA1035@js1304-P5Q-DELUXE>
References: <1408608675-20420-1-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.11.1408210918050.32524@gentwo.org>
 <20140825082615.GA13475@js1304-P5Q-DELUXE>
 <alpine.DEB.2.11.1408250809420.17236@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1408250809420.17236@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Tejun Heo <htejun@gmail.com>, linux-kernel@vger.kernel.org

On Mon, Aug 25, 2014 at 08:13:58AM -0500, Christoph Lameter wrote:
> On Mon, 25 Aug 2014, Joonsoo Kim wrote:
> 
> > On Thu, Aug 21, 2014 at 09:21:30AM -0500, Christoph Lameter wrote:
> > > On Thu, 21 Aug 2014, Joonsoo Kim wrote:
> > >
> > > > So, this patch try to use percpu allocator in SLAB. This simplify
> > > > initialization step in SLAB so that we could maintain SLAB code more
> > > > easily.
> > >
> > > I thought about this a couple of times but the amount of memory used for
> > > the per cpu arrays can be huge. In contrast to slub which needs just a
> > > few pointers, slab requires one pointer per object that can be in the
> > > local cache. CC Tj.
> > >
> > > Lets say we have 300 caches and we allow 1000 objects to be cached per
> > > cpu. That is 300k pointers per cpu. 1.2M on 32 bit. 2.4M per cpu on
> > > 64bit.
> >
> > Amount of memory we need to keep pointers for object is same in any case.
> 
> What case? SLUB uses a linked list and therefore does not have these
> storage requirements.

I misunderstand that you mentioned just memory usage. My *any case*
means memory usage of previous SLAB and SLAB with this percpu alloc
change. Sorry for confusion.

> 
> > I know that percpu allocator occupy vmalloc space, so maybe we could
> > exhaust vmalloc space on 32 bit. 64 bit has no problem on it.
> > How many cores does largest 32 bit system have? Is it possible
> > to exhaust vmalloc space if we use percpu allocator?
> 
> There were NUMA systems on x86 a while back (not sure if they still
> exists) with 128 or so processors.
> 
> Some people boot 32 bit kernels on contemporary servers. The Intel ones
> max out at 18 cores (36 hyperthreaded). I think they support up to 8
> scokets. So 8 * 36?
> 
> 
> Its different on other platforms with much higher numbers. Power can
> easily go up to hundreds of hardware threads and SGI Altixes 7 yearsago
> where at 8000 or so.

Okay... These large systems with 32 bit kernel could be break with this
change. I will do more investigation. Possibly, I will drop this patch. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
