Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id 64F2D6B006E
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 11:27:33 -0400 (EDT)
Received: by mail-qa0-f47.google.com with SMTP id dc16so1104775qab.6
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 08:27:32 -0700 (PDT)
Received: from relay.variantweb.net ([104.131.199.242])
        by mx.google.com with ESMTP id t8si8395710qap.38.2014.10.24.08.27.10
        for <linux-mm@kvack.org>;
        Fri, 24 Oct 2014 08:27:10 -0700 (PDT)
Received: from mail (unknown [10.42.10.20])
	by relay.variantweb.net (Postfix) with ESMTP id 9EA7F100ECF
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 11:27:06 -0400 (EDT)
Date: Fri, 24 Oct 2014 10:27:05 -0500
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [RFC PATCH 0/9] mm/zbud: support highmem pages
Message-ID: <20141024152705.GA18884@cerebellum.variantweb.net>
References: <1413287968-13940-1-git-send-email-heesub.shin@samsung.com>
 <CALZtONCn8R0v7WV+fhMBh=y9b=ES0GuM9ds6TBtYeyKR-Z7LxA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONCn8R0v7WV+fhMBh=y9b=ES0GuM9ds6TBtYeyKR-Z7LxA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Heesub Shin <heesub.shin@samsung.com>, Nitin Gupta <ngupta@vflare.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Sunae Seo <sunae.seo@samsung.com>

On Thu, Oct 23, 2014 at 07:14:15PM -0400, Dan Streetman wrote:
> On Tue, Oct 14, 2014 at 7:59 AM, Heesub Shin <heesub.shin@samsung.com> wrote:
> > zbud is a memory allocator for storing compressed data pages. It keeps
> > two data objects of arbitrary size on a single page. This simple design
> > provides very deterministic behavior on reclamation, which is one of
> > reasons why zswap selected zbud as a default allocator over zsmalloc.
> >
> > Unlike zsmalloc, however, zbud does not support highmem. This is
> > problomatic especially on 32-bit machines having relatively small
> > lowmem. Compressing anonymous pages from highmem and storing them into
> > lowmem could eat up lowmem spaces.
> >
> > This limitation is due to the fact that zbud manages its internal data
> > structures on zbud_header which is kept in the head of zbud_page. For
> > example, zbud_pages are tracked by several lists and have some status
> > information, which are being referenced at any time by the kernel. Thus,
> > zbud_pages should be allocated on a memory region directly mapped,
> > lowmem.
> >
> > After some digging out, I found that internal data structures of zbud
> > can be kept in the struct page, the same way as zsmalloc does. So, this
> > series moves out all fields in zbud_header to struct page. Though it
> > alters quite a lot, it does not add any functional differences except
> > highmem support. I am afraid that this kind of modification abusing
> > several fields in struct page would be ok.
> 
> Seth, have you had a chance to review this yet?  I'm going to try to
> take a look at it next week if you haven't yet.  Letting zbud use
> highmem would be a good thing.

I have looked at it, and it looks sound to me.  I seem to remember
having a comment on something, but I'll have to look back over
it. Haven't tested it yet.

Seth

> 
> 
> >
> > Heesub Shin (9):
> >   mm/zbud: tidy up a bit
> >   mm/zbud: remove buddied list from zbud_pool
> >   mm/zbud: remove lru from zbud_header
> >   mm/zbud: remove first|last_chunks from zbud_header
> >   mm/zbud: encode zbud handle using struct page
> >   mm/zbud: remove list_head for buddied list from zbud_header
> >   mm/zbud: drop zbud_header
> >   mm/zbud: allow clients to use highmem pages
> >   mm/zswap: use highmem pages for compressed pool
> >
> >  mm/zbud.c  | 244 ++++++++++++++++++++++++++++++-------------------------------
> >  mm/zswap.c |   4 +-
> >  2 files changed, 121 insertions(+), 127 deletions(-)
> >
> > --
> > 1.9.1
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
