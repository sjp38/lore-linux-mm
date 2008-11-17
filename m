Date: Sun, 16 Nov 2008 20:47:20 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: evict streaming IO cache first
Message-Id: <20081116204720.1b8cbe18.akpm@linux-foundation.org>
In-Reply-To: <49208E9A.5080801@redhat.com>
References: <20081115181748.3410.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20081115210039.537f59f5.akpm@linux-foundation.org>
	<alpine.LFD.2.00.0811161013270.3468@nehalem.linux-foundation.org>
	<49208E9A.5080801@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Gene Heskett <gene.heskett@gmail.com>
List-ID: <linux-mm.kvack.org>

On Sun, 16 Nov 2008 16:20:26 -0500 Rik van Riel <riel@redhat.com> wrote:

> Linus Torvalds wrote:
> > On Sat, 15 Nov 2008, Andrew Morton wrote:
> >> Really, I think that the old approach of observing the scanner
> >> behaviour (rather than trying to predict it) was better.
> > 
> > That's generally true. Self-adjusting behaviour rather than a-priori rules 
> > would be much nicer. However, we apparently need to fix this some way. 
> > Anybody willing to re-introduce some of the old logic?
> 
> The old behaviour has big problems, especially on large memory
> systems.  If the old behaviour worked right, we would not have
> been working on the split LRU code for the last year and a half.

Split LRU is (in this aspect) worse than the old code.

> Due to programs manipulating memory many pages at a time, the
> LRU ends up getting mapped and cache pages on the list in bunches.
>
> On large memory systems, after the scanner runs into a bunch
> of mapped pages, it will switch to evicting mapped pages, even
> if the next bunch of pages turns out to be cache pages.

Sure.  But that sounds like theory to me.  I've never seen anyone even
vaguely get anywhere near the level of instrumentation and
investigation and testing to be in a position to demonstrate that this
is a problem in practice.

> I am not convinced that "reacting to what happened in the last
> 1/4096th of the LRU" is any better than "look at the list stats
> and decide what to do".

I bet it is.  The list stats are aggregated over the entire list and
aren't very useful for predicting the state of the few hundred pages at
the tail of the list.

> Andrew's objection to how things behave on small memory systems
> (the patch does not change anything) is valid, but going back
> to the old behaviour does not seem like an option to me, either.

There's also the behaviour change at the randomly-chosen
(nr[LRU_INACTIVE_FILE] == nr[LRU_ACTIVE_FILE) point..

> I will take a look at producing smoother self tuning behaviour
> in get_scan_ratio(), with logic along these lines:
> - the more file pages are inactive, the more eviction should
>    focus on file pages, because we are not eating away at the
>    working set yet
> - the more file pages are active, the more there needs to be
>    a balance between file and anon scanning, because we are
>    starting to get to the working sets for both

hm.  I wonder if it would be prohibitive to say "hey, we did the wrong
thing in that scanning pass - rewind and try it again".  Probably it
would be.

Anyway, we need to do something.

Shouldn't get_scan_ratio() be handling this case already?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
