Message-Id: <200108222103.f7ML3Lb26463@maile.telia.com>
Content-Type: text/plain;
  charset="iso-8859-1"
From: Roger Larsson <roger.larsson@norran.net>
Subject: Re: [PATCH] __alloc_pages_limit pages_min
Date: Wed, 22 Aug 2001 22:58:59 +0200
References: <Pine.LNX.4.33L.0108221400290.31410-100000@duckman.distro.conectiva>
In-Reply-To: <Pine.LNX.4.33L.0108221400290.31410-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesdayen den 22 August 2001 19:01, Rik van Riel wrote:
> On Wed, 22 Aug 2001, Roger Larsson wrote:
> > Note: reclaim_page will fix this situation direct it is allowed to
> > run since it is kicked in __alloc_pages. But since we cannot
> > guarantee that this will never happen...
>
> In this case kreclaimd will be woken up and the free pages
> will be refilled.
>
> Rik

Yes it will be woken up - but when will it actually do something?
(we might have lots of stuff before in the run queue)

Suppose we are at low for all zones on free pages - the natural.
And we get requsts for DMA pages, non direct_reclaim.
(with inactive_clean greater than pages_high)

An alloc will then take let you allocate at the first __alloc_pages_limit
until zero pages left. You might have got it anyway but not until a
later test in __alloc_pages but it is not guaranteed.

We should not accept to let free_pages go (more than one) under
pages_min, at least not as a undocumented feature of __alloc_pages_limit...

It might be worse then first tought of since all allocations with order != 0
are non direct_reclaim... you might eat the free pages fast...

And this limit at the end of alloc_pages
		if (z->free_pages < z->pages_min / 4 &&
				!(current->flags & PF_MEMALLOC))
is not enforced earlier in the same code...

/RogerL

-- 
Roger Larsson
Skelleftea
Sweden
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
