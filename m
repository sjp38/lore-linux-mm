Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8A19E6B0036
	for <linux-mm@kvack.org>; Mon, 25 Aug 2014 09:14:15 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id z10so20212890pdj.30
        for <linux-mm@kvack.org>; Mon, 25 Aug 2014 06:14:15 -0700 (PDT)
Received: from qmta12.emeryville.ca.mail.comcast.net (qmta12.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:227])
        by mx.google.com with ESMTP id v3si40249458pdr.152.2014.08.25.06.14.01
        for <linux-mm@kvack.org>;
        Mon, 25 Aug 2014 06:14:01 -0700 (PDT)
Date: Mon, 25 Aug 2014 08:13:58 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] mm/slab: use percpu allocator for cpu cache
In-Reply-To: <20140825082615.GA13475@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.11.1408250809420.17236@gentwo.org>
References: <1408608675-20420-1-git-send-email-iamjoonsoo.kim@lge.com> <alpine.DEB.2.11.1408210918050.32524@gentwo.org> <20140825082615.GA13475@js1304-P5Q-DELUXE>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Tejun Heo <htejun@gmail.com>, linux-kernel@vger.kernel.org

On Mon, 25 Aug 2014, Joonsoo Kim wrote:

> On Thu, Aug 21, 2014 at 09:21:30AM -0500, Christoph Lameter wrote:
> > On Thu, 21 Aug 2014, Joonsoo Kim wrote:
> >
> > > So, this patch try to use percpu allocator in SLAB. This simplify
> > > initialization step in SLAB so that we could maintain SLAB code more
> > > easily.
> >
> > I thought about this a couple of times but the amount of memory used for
> > the per cpu arrays can be huge. In contrast to slub which needs just a
> > few pointers, slab requires one pointer per object that can be in the
> > local cache. CC Tj.
> >
> > Lets say we have 300 caches and we allow 1000 objects to be cached per
> > cpu. That is 300k pointers per cpu. 1.2M on 32 bit. 2.4M per cpu on
> > 64bit.
>
> Amount of memory we need to keep pointers for object is same in any case.

What case? SLUB uses a linked list and therefore does not have these
storage requirements.

> I know that percpu allocator occupy vmalloc space, so maybe we could
> exhaust vmalloc space on 32 bit. 64 bit has no problem on it.
> How many cores does largest 32 bit system have? Is it possible
> to exhaust vmalloc space if we use percpu allocator?

There were NUMA systems on x86 a while back (not sure if they still
exists) with 128 or so processors.

Some people boot 32 bit kernels on contemporary servers. The Intel ones
max out at 18 cores (36 hyperthreaded). I think they support up to 8
scokets. So 8 * 36?


Its different on other platforms with much higher numbers. Power can
easily go up to hundreds of hardware threads and SGI Altixes 7 yearsago
where at 8000 or so.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
