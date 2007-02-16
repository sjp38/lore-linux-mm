Date: Thu, 15 Feb 2007 20:02:04 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] Remove unswappable anonymous pages off the LRU
Message-Id: <20070215200204.899811b4.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0702151945090.1696@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702151300500.31366@schroedinger.engr.sgi.com>
	<20070215171355.67c7e8b4.akpm@linux-foundation.org>
	<45D50B79.5080002@mbligh.org>
	<20070215174957.f1fb8711.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0702151830080.1471@schroedinger.engr.sgi.com>
	<20070215184800.e2820947.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0702151849030.1511@schroedinger.engr.sgi.com>
	<20070215191858.1a864874.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0702151929180.1696@schroedinger.engr.sgi.com>
	<20070215194258.a354f428.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0702151945090.1696@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Martin Bligh <mbligh@mbligh.org>, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Feb 2007 19:50:45 -0800 (PST) Christoph Lameter <clameter@sgi.com> wrote:

> On Thu, 15 Feb 2007, Andrew Morton wrote:
> 
> > > Maybe we could somehow splite up page->flags into 4 separate bytes?
> > > Updating one byte would not endanger the other bytes in the other 
> > > sets?
> > 
> > yipes.  I'm not sure that'd work?
> 
> Are all arches able to do atomic ops on bytes?

I think they are, but you only wanted three bits.  I don't think we'll be
able to convert eight bits into a 256-value scalar efficiently.

> > compare-and-swap-in-a-loop could be used, I guess.  With the obvious problem..
> 
> Yucks. There seems to be no easy solution.
>  
> > I do think that those two swsusp flags are low-hanging-fruit.  It'd be
> > trivial to vmalloc a bitmap or use a radix-tree-holding-longs, but I have a
> > vague feeling that there were subtle issues with that.  Still, Something
> > Needs To Be Done.
> 
> I tinkered with some similar radical ideas lately. Maybe a bit vector
> could be used instead? For 1G of memory we would need 
> 
> 2^(30 - PAGE_SHIFT / 8 = 2^(30-12-3) = 2^15 = 32k bytes of a bitmap.
> 
> Seems to be reasonable?
> 

32k per bit per gig, yes.  Better for large PAGE_SIZE.  More cachemisses.

But will it come unstuck for machines which have a super-sparse pfn space?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
