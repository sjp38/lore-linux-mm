Message-ID: <4021A62D.40002@cyberone.com.au>
Date: Thu, 05 Feb 2004 13:10:53 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] mm improvements
References: <4020BE45.10007@cyberone.com.au>	<Pine.LNX.4.44.0402041027380.24515-100000@chimarrao.boston.redhat.com> <16417.8644.203682.640759@laputa.namesys.com>
In-Reply-To: <16417.8644.203682.640759@laputa.namesys.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <Nikita@Namesys.COM>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Nikita Danilov wrote:

>Rik van Riel writes:
> > On Wed, 4 Feb 2004, Nick Piggin wrote:
> > > Nick Piggin wrote:
> > > 
> > > > 3/5: vm-lru-info.patch
> > > >     Keep more referenced info in the active list. Should also improve
> > > >     system time in some cases. Helps swapping loads significantly.
> > 
> > I suspect this is one of the more important ones in this
> > batch of patches...
>
>I don't understand how this works. This patch just parks mapped pages on
>the "ignored" segment of the active list, where they rest until
>reclaim_mapped mode is entered.
>
>This only makes a difference for the pages that were page_referenced():
>
>1. they are moved to the ignored segment rather than to the head of the
>active list.
>
>2. their referenced bit is not cleared
>
>

It treats all mapped pages in the same manner. Without this
patch, referenced mapped pages are distinctly disadvantaged
vs unreferenced mapped pages.

Even if reclaim_mapped is only flipped once every few
seconds it can make a big impact. On a 64MB heavily
swapping, you probably take 10 seconds to reclaim 64MB. It
is of critical importance that we keep as much hotness
information as possible.

It shows on the benchmarks too. It provides nearly as
much improvement as your patch alone for a make -j16.
ie. over 20%

http://www.kerneltrap.org/~npiggin/vm/2/


Also, when you're heavily swapping, everything slows down
to such an extent that "hot" pages are no longer touched
thousands of times per second, but maybe a few times every
few seconds. If you're continually clearing this information,
as soon as reclaim_mapped is triggered, all your hot pages
get evicted.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
