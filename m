Date: Wed, 4 Feb 2004 10:53:15 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 3/5] mm improvements
Message-Id: <20040204105315.3644dcd3.akpm@osdl.org>
In-Reply-To: <16417.8644.203682.640759@laputa.namesys.com>
References: <4020BE45.10007@cyberone.com.au>
	<Pine.LNX.4.44.0402041027380.24515-100000@chimarrao.boston.redhat.com>
	<16417.8644.203682.640759@laputa.namesys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <Nikita@Namesys.COM>
Cc: riel@redhat.com, piggin@cyberone.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nikita Danilov <Nikita@Namesys.COM> wrote:
>
>  Rik van Riel writes:
>   > On Wed, 4 Feb 2004, Nick Piggin wrote:
>   > > Nick Piggin wrote:
>   > > 
>   > > > 3/5: vm-lru-info.patch
>   > > >     Keep more referenced info in the active list. Should also improve
>   > > >     system time in some cases. Helps swapping loads significantly.
>   > 
>   > I suspect this is one of the more important ones in this
>   > batch of patches...
> 
>  I don't understand how this works. This patch just parks mapped pages on
>  the "ignored" segment of the active list, where they rest until
>  reclaim_mapped mode is entered.
> 
>  This only makes a difference for the pages that were page_referenced():
> 
>  1. they are moved to the ignored segment rather than to the head of the
>  active list.
> 
>  2. their referenced bit is not cleared
> 
>  Now, as "ignored" segment is not scanned in !reclaim_mode, (2) would
>  only make a difference when VM rapidly oscillates between reclaim_mapped
>  and !reclaim_mapped, because after a long period of !reclaim_mapped
>  operation preserved referenced bit on a page only means "this page has
>  been referenced in the past, but not necessary recently".

Yes, reclaim_mapped shouldn't change at all frequently, unless the
zone->prev_priority thing is broken.  prev_priority is supposed to remember
the reclaim_mapped state between successive scan attempts so we go straight
into doing the right thing.

It _was_ working - I instrumented and tested that when it went in.  It was
a bit tricky to get right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
