Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id F3FA16B0022
	for <linux-mm@kvack.org>; Thu, 19 May 2011 17:24:18 -0400 (EDT)
Date: Thu, 19 May 2011 16:24:15 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] kernel buffer overflow kmalloc_slab() fix
In-Reply-To: <1305839647.2400.32.camel@localhost>
Message-ID: <alpine.DEB.2.00.1105191618460.12530@router.home>
References: <james_p_freyensee@linux.intel.com>  <1305834712-27805-2-git-send-email-james_p_freyensee@linux.intel.com>  <alpine.DEB.2.00.1105191550001.12530@router.home> <1305839647.2400.32.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: J Freyensee <james_p_freyensee@linux.intel.com>
Cc: linux-mm@kvack.org, gregkh@suse.de, hari.k.kanigeri@intel.com

On Thu, 19 May 2011, J Freyensee wrote:

> On Thu, 2011-05-19 at 15:51 -0500, Christoph Lameter wrote:
> > On Thu, 19 May 2011, james_p_freyensee@linux.intel.com wrote:
> >
> > > From: J Freyensee <james_p_freyensee@linux.intel.com>
> > >
> > > Currently, kmalloc_index() can return -1, which can be
> > > passed right to the kmalloc_caches[] array, cause a
> >
> > No kmalloc_index() cannot return -1 for the use case that you are
> > considering here. The value passed as a size to
> > kmalloc_slab is bounded by 2 * PAGE_SIZE and kmalloc_slab will only return
> > -1 for sizes > 4M. So we will have to get machines with page sizes > 2M
> > before this can be triggered.
> >
> >
>
> Okay.  I thought it would still be good to check for -1 anyways, even if
> machines today cannot go above 2M page sizes.  I would think it would be
> better for software code to always make sure a case that this could
> never happen instead of relying on whatever physical hardware limits the
> linux kernel could be running on on today's machines or future machines,
> because technology has shown limits can change.  I would think
> regardless what this code runs on, this is still a software flaw that
> can be considered not a good thing to allow lying around in software
> code that can easily be fixed.

This is basically macro style code that is mostly folded at compile time
and we have to obey certain restrictions to convince the compiler to
properly do that. Took us a long time to get that right.

Not sure what to do instead of returning -1 in kmalloc_slab. I'd be glad
if you could get the compiler to simply fail in kmalloc_slab() if a value
larger than 4M is passed to it. But please make sure that all versions of
GCC do proper constant folding and that the function also works if
constant folding is not possible for some reason. Consider esoteric arches
and compiler version also.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
