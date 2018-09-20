Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4A2D68E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 23:59:21 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id a15-v6so6047266qtj.15
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 20:59:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n14-v6sor7223525qvd.35.2018.09.19.20.59.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Sep 2018 20:59:20 -0700 (PDT)
MIME-Version: 1.0
References: <CACVXFVOBq3L_EjSTCoiqUL1PH=HMR5EuNNQV0hNndFpGxmUK6g@mail.gmail.com>
 <877ejh3jv0.fsf@vitty.brq.redhat.com> <20180919100256.GD23172@ming.t460p>
 <8736u53fij.fsf@vitty.brq.redhat.com> <20180920012836.GA27645@ming.t460p>
In-Reply-To: <20180920012836.GA27645@ming.t460p>
From: Yang Shi <shy828301@gmail.com>
Date: Wed, 19 Sep 2018 20:59:07 -0700
Message-ID: <CAHbLzkrq-CSBK8p-GbUgkhP0tMbA53=Es3v8Zw26qmf2t_vSQQ@mail.gmail.com>
Subject: Re: block: DMA alignment of IO buffer allocated from slab
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ming.lei@redhat.com
Cc: vkuznets@redhat.com, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Ming Lei <tom.leiming@gmail.com>, linux-block@vger.kernel.org, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, dchinner@redhat.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, hch@lst.de, axboe@kernel.dk

On Wed, Sep 19, 2018 at 6:28 PM Ming Lei <ming.lei@redhat.com> wrote:
>
> On Wed, Sep 19, 2018 at 01:15:00PM +0200, Vitaly Kuznetsov wrote:
> > Ming Lei <ming.lei@redhat.com> writes:
> >
> > > Hi Vitaly,
> > >
> > > On Wed, Sep 19, 2018 at 11:41:07AM +0200, Vitaly Kuznetsov wrote:
> > >> Ming Lei <tom.leiming@gmail.com> writes:
> > >>
> > >> > Hi Guys,
> > >> >
> > >> > Some storage controllers have DMA alignment limit, which is often set via
> > >> > blk_queue_dma_alignment(), such as 512-byte alignment for IO buffer.
> > >>
> > >> While mostly drivers use 512-byte alignment it is not a rule of thumb,
> > >> 'git grep' tell me we have:
> > >> ide-cd.c with 32-byte alignment
> > >> ps3disk.c and rsxx/dev.c with variable alignment.
> > >>
> > >> What if our block configuration consists of several devices (in raid
> > >> array, for example) with different requirements, e.g. one requiring
> > >> 512-byte alignment and the other requiring 256?
> > >
> > > 512-byte alignment is also 256-byte aligned, and the sector size is 512 byte.
> > >
> >
> > Yes, but it doesn't work the other way around, e.g. what if some device
> > has e.g. PAGE_SIZE alignment requirement (this would likely imply that
> > it's sector size is also not 512 I guess)?
>
> Yeah, that can be true if one controller has 4k-byte sector size, also
> its DMA alignment is 4K. But there shouldn't be cases in which the two
> doesn't match.
>
> >
> > >
> > > From the Red Hat BZ, looks I understand this issue is only triggered when
> > > KASAN is enabled, or you have figured out how to reproduce it without
> > > KASAN involved?
> >
> > Yes, any SLUB debug triggers it (e.g. build your kernel with
> > SLUB_DEBUG_ON or slub_debug= options (Red zoning, User tracking, ... -
> > everything will trigger it)
>
> That means the slab always return 512-byte aligned buffer if the buffer
> size is 512byte in case of no any slab debug options enabled.
>
> The question is that if it is one reliable rule in slab. If yes, any
> slab debug option does violate the rule.

Once slub debug (i.e. red zone) is on, it will append extra bytes to
the object, so the object may look like:

-----------------------------------------------------------------
| object   | red zone | FP | owner track | red zone |
------------------------------------------------------------------

This is how slub debug is designed and how it works.

CC to Chris Lameter who is the maintainer of SLUB.

Regards,
Yang

>
> The same is true for 4k alignment and 4k sector size.
>
> I think we need our MM guys to clarify this point.
>
>
> Thanks,
> Ming
>
