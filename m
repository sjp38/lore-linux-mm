Date: Thu, 15 Feb 2007 18:48:00 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] Remove unswappable anonymous pages off the LRU
Message-Id: <20070215184800.e2820947.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0702151830080.1471@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702151300500.31366@schroedinger.engr.sgi.com>
	<20070215171355.67c7e8b4.akpm@linux-foundation.org>
	<45D50B79.5080002@mbligh.org>
	<20070215174957.f1fb8711.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0702151830080.1471@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Martin Bligh <mbligh@mbligh.org>, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Feb 2007 18:34:12 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Thu, 15 Feb 2007, Andrew Morton wrote:
> 
> > Guys, this page-flag problem is really serious.  -mm adds PG_mlocked and
> > PG_readahead and the ext4 patches add PG_booked (am currently fighting the
> > good fight there).  There's ongoing steady growth in these things and soon
> > we're going to be in a lot of pain.
> 
> Well is it possible to restrict some of the features to 64 bit only? There 
> we have lots of page flags.

We discussed that a while back and iirc ia64 has gone and gobbled most of
the upper 32bits.  Someone went and added some ascii art around the
PG_uncached definition but it is incomprehensible.  It seems to claim that
ia64 has gone and used all 32 bits, dammit.  If so, some adjustments to
ia64 might be called for.

> One additional measure that may be possible is to have a page type field
> (maybe 3 bits long) that would consolidate a series of page flags that 
> cannot occur together. But then we have issues with the atomicity of 
> updates to that field.
> 
> F.e.
> 
> page_type = { SLAB, LRU, MLOCK, RESERVED, BUDDY, <add 3 more types here> }

Yeah, maybe.  There doesn't seem to be a lot of room for that though - a
lot of those flags are quite independent and can occur simultaneously.

Maybe PageSwapCache can be worked out by other means.

The two swsusp bits can be removed: they're only needed at suspend/resume
time and can be replaced by an external data structure.

I still reckon there must be a way to avoid PG_buddy but Martin put up
stiff-and-squealy resistance when I resisted the addition of that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
