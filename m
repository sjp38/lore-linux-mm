Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 640616B009B
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 18:00:50 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y10so1948804pdj.0
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 15:00:50 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id dl2si482225pbc.108.2014.07.16.15.00.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 15:00:49 -0700 (PDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so2059609pab.12
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 15:00:48 -0700 (PDT)
Received: from mail (104-54-201-27.lightspeed.austtx.sbcglobal.net. [104.54.201.27])
        by mx.google.com with ESMTPSA id oy12sm383373pbb.27.2014.07.16.15.00.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jul 2014 15:00:47 -0700 (PDT)
Date: Wed, 16 Jul 2014 17:00:40 -0500
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCHv5 0/4] mm/zpool: add common api for zswap to use
 zbud/zsmalloc
Message-ID: <20140716220040.GA16681@cerebellum.variantweb.net>
References: <1401747586-11861-1-git-send-email-ddstreet@ieee.org>
 <1404337536-11037-1-git-send-email-ddstreet@ieee.org>
 <CALZtONBYwm5t39z8wiEkTrFw-g=Be+ypaZo2nuFo0ob5pRXSAw@mail.gmail.com>
 <20140716205907.GA13058@cerebellum.variantweb.net>
 <CALZtONB0k_Vw6OwV6u3FA=Hu7FO+nY7bhTUQ+sb+hx3fwYDXyA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONB0k_Vw6OwV6u3FA=Hu7FO+nY7bhTUQ+sb+hx3fwYDXyA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Wed, Jul 16, 2014 at 05:05:45PM -0400, Dan Streetman wrote:
> On Wed, Jul 16, 2014 at 4:59 PM, Seth Jennings <sjennings@variantweb.net> wrote:
> > On Mon, Jul 14, 2014 at 02:10:42PM -0400, Dan Streetman wrote:
> >> Andrew, any thoughts on this latest version of the patch set?  Let me
> >> know if I missed anything or you have any other suggestions.
> >>
> >> Seth, did you get a chance to review this and/or test it out?
> >
> > I did have a chance to test it out quickly and didn't run into any
> > issues.  Your patchset is already in linux-next so I'll test more from
> > there.
> 
> This latest version has a few changes that Andrew requested, which
> presumably will replace the patches that are currently in -mm and
> -next; can you test with these patches instead of (or in addition to)
> what's in -next?

Looks like Andrew just did the legwork for me to get the new patches
into mmotm.  When the hit there (tomorrow?), I'll put it down and test
with that.

Thanks,
Seth

> 
> >
> > Seth
> >
> >>
> >>
> >>
> >> On Wed, Jul 2, 2014 at 5:45 PM, Dan Streetman <ddstreet@ieee.org> wrote:
> >> > In order to allow zswap users to choose between zbud and zsmalloc for
> >> > the compressed storage pool, this patch set adds a new api "zpool" that
> >> > provides an interface to both zbud and zsmalloc.  This does not include
> >> > implementing shrinking in zsmalloc, which will be sent separately.
> >> >
> >> > I believe Seth originally was using zsmalloc for swap, but there were
> >> > concerns about how significant the impact of shrinking zsmalloc would
> >> > be when zswap had to start reclaiming pages.  That still may be an
> >> > issue, but this at least allows users to choose themselves whether
> >> > they want a lower-density or higher-density compressed storage medium.
> >> > At least for situations where zswap reclaim is never or rarely reached,
> >> > it probably makes sense to use the higher density of zsmalloc.
> >> >
> >> > Note this patch set does not change zram to use zpool, although that
> >> > change should be possible as well.
> >> >
> >> > ---
> >> > Changes since v4 : https://lkml.org/lkml/2014/6/2/711
> >> >   -omit first patch, that removed gfp_t param from zpool_malloc()
> >> >   -move function doc from zpool.h to zpool.c
> >> >   -move module usage refcounting into patch that adds zpool
> >> >   -add extra refcounting to prevent driver unregister if in use
> >> >   -add doc clarifying concurrency usage
> >> >   -make zbud/zsmalloc zpool functions static
> >> >   -typo corrections
> >> >
> >> > Changes since v3 : https://lkml.org/lkml/2014/5/24/130
> >> >   -In zpool_shrink() use # pages instead of # bytes
> >> >   -Add reclaimed param to zpool_shrink() to indicate to caller
> >> >    # pages actually reclaimed
> >> >   -move module usage counting to zpool, from zbud/zsmalloc
> >> >   -update zbud_zpool_shrink() to call zbud_reclaim_page() in a
> >> >    loop until requested # pages have been reclaimed (or error)
> >> >
> >> > Changes since v2 : https://lkml.org/lkml/2014/5/7/927
> >> >   -Change zpool to use driver registration instead of hardcoding
> >> >    implementations
> >> >   -Add module use counting in zbud/zsmalloc
> >> >
> >> > Changes since v1 https://lkml.org/lkml/2014/4/19/97
> >> >  -remove zsmalloc shrinking
> >> >  -change zbud size param type from unsigned int to size_t
> >> >  -remove zpool fallback creation
> >> >  -zswap manually falls back to zbud if specified type fails
> >> >
> >> >
> >> > Dan Streetman (4):
> >> >   mm/zbud: change zbud_alloc size type to size_t
> >> >   mm/zpool: implement common zpool api to zbud/zsmalloc
> >> >   mm/zpool: zbud/zsmalloc implement zpool
> >> >   mm/zpool: update zswap to use zpool
> >> >
> >> >  include/linux/zbud.h  |   2 +-
> >> >  include/linux/zpool.h | 106 +++++++++++++++
> >> >  mm/Kconfig            |  43 +++---
> >> >  mm/Makefile           |   1 +
> >> >  mm/zbud.c             |  98 +++++++++++++-
> >> >  mm/zpool.c            | 364 ++++++++++++++++++++++++++++++++++++++++++++++++++
> >> >  mm/zsmalloc.c         |  84 ++++++++++++
> >> >  mm/zswap.c            |  75 ++++++-----
> >> >  8 files changed, 722 insertions(+), 51 deletions(-)
> >> >  create mode 100644 include/linux/zpool.h
> >> >  create mode 100644 mm/zpool.c
> >> >
> >> > --
> >> > 1.8.3.1
> >> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
