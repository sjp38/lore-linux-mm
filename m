Subject: Re: [RFC][PATCH 0/4] VM deadlock prevention -v4
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <47227.81.207.0.53.1155406611.squirrel@81.207.0.53>
References: <20060812141415.30842.78695.sendpatchset@lappy>
	 <33471.81.207.0.53.1155401489.squirrel@81.207.0.53>
	 <1155404014.13508.72.camel@lappy>
	 <47227.81.207.0.53.1155406611.squirrel@81.207.0.53>
Content-Type: text/plain
Date: Sat, 12 Aug 2006 20:54:06 +0200
Message-Id: <1155408846.13508.115.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Indan Zupancic <indan@nul.nu>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, Daniel Phillips <phillips@google.com>, Rik van Riel <riel@redhat.com>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Sat, 2006-08-12 at 20:16 +0200, Indan Zupancic wrote:
> On Sat, August 12, 2006 19:33, Peter Zijlstra said:
> > Simpler yes, but also more complete; the old patches had serious issues
> > with the alternative allocation scheme.
> 
> It sure is more complete, and looks nicer, but the price is IMHO too high.
> I'm curious what those serious issues are, and if they can't be fixed.
> 
> > As for why SROG, because trying to stick all the semantics needed for
> > all skb operations into the old approach was nasty, I had it almost
> > complete but it was horror (and more code than the SROG approach).
> 
> What was missing or wrong in the old approach? Can't you use the new
> approach, but use alloc_pages() instead of SROG?
> 
> Sorry if I bug you so, but I'm also trying to increase my knowledge here. ;-)

I'm almost sorry I threw that code out, you'd understand instantly..

Lemme see what I can do to explain; what I need/want is:
 - single allocation group per packet - that is, when I free a packet
and all its associated object I get my memory back.
 - not waste too much space managing the various objects

skb operations want to allocate various sk_buffs for the same data
clones. Also, it wants to be able to break the COW or realloc the data.

The trivial approach would be one page (or higher alloc page) per
object, and that will work quite well, except that it'll waste a _lot_
of memory. 

So I tried manual packing (parts of that you have seen in previous
attempts). This gets hard when you want to do unlimited clones and COW
breaks. To do either you need to go link several pages.

So needing a list of pages and wanting packing gave me SROG. The biggest
wart is having to deal with higher order pages. Explicitly coding in
knowledge of the object you're packing just makes the code bigger - such
is the power of abstraction.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
