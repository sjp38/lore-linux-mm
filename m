Date: Thu, 15 Feb 2007 17:49:57 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] Remove unswappable anonymous pages off the LRU
Message-Id: <20070215174957.f1fb8711.akpm@linux-foundation.org>
In-Reply-To: <45D50B79.5080002@mbligh.org>
References: <Pine.LNX.4.64.0702151300500.31366@schroedinger.engr.sgi.com>
	<20070215171355.67c7e8b4.akpm@linux-foundation.org>
	<45D50B79.5080002@mbligh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Bligh <mbligh@mbligh.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Feb 2007 17:40:09 -0800
Martin Bligh <mbligh@mbligh.org> wrote:

> Andrew Morton wrote:
> > On Thu, 15 Feb 2007 13:05:47 -0800 (PST)
> > Christoph Lameter <clameter@sgi.com> wrote:
> > 
> >> If we do not have any swap or we have run out of swap then anonymous pages
> >> can no longer be removed from memory. In that case we simply treat them
> >> like mlocked pages. For a kernel compiled CONFIG_SWAP off this means
> >> that all anonymous pages are marked mlocked when they are allocated.
> > 
> > It's nice and simple, but I think I'd prefer to wait for the existing mlock
> > changes to crash a bit less before we do this.
> > 
> > Is it true that PageMlocked() pages are never on the LRU?  If so, perhaps
> > we could overload the lru.next/prev on these pages to flag an mlocked page.
> > 
> > #define PageMlocked(page)	(page->lru.next == some_address_which_isnt_used_for_anwything_else)
> 
> Mine just created a locked list. If you stick them there, there's no
> need for a page flag ... and we don't abuse the lru pointers AGAIN! ;-)

I don't think there's a need for a mlocked list in the mlock patches:
nothing ever needs to walk it.

However this might be a good way of solving the someone-did-a-swapon
problem for this anon patch.

Guys, this page-flag problem is really serious.  -mm adds PG_mlocked and
PG_readahead and the ext4 patches add PG_booked (am currently fighting the
good fight there).  There's ongoing steady growth in these things and soon
we're going to be in a lot of pain.

> Suspect most of the rest of my patch is crap, but that might be useful?

wordwrapped, space-stuffed and tab-replaced.  The trifecta!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
