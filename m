Date: Fri, 8 Jun 2001 15:33:05 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Background scanning change on 2.4.6-pre1
In-Reply-To: <Pine.LNX.4.21.0106081743070.2699-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.31.0106081526400.1067-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: "David S. Miller" <davem@redhat.com>, Mike Galbraith <mikeg@wen-online.de>, Zlatko Calusic <zlatko.calusic@iskon.hr>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 8 Jun 2001, Marcelo Tosatti wrote:
>
> I've tried that in the past, and the behaviour I got was pages being
> swapped out with little (or not any) VM pressure.

What is "past"?

Remember: these days we don't do any IO at all inside "swap_out()", the
_only_ thing we do is to age the VM and possibly move pages to the swap
cache.

Which is really what you wanted - it's just that we delay moving anonymous
pages to the swap-cache until we have some reason to (ie we delay it until
we want to re-fill the inactive list).

Think of it as a simple issue of
 - when we age pages, we should also check whether they've been dirtied by
   being mapped, and whether the mappings have accessed them.

Put that way, I doubt you'll disagree.

(Now, whether it gets the balancing _right_ is another matter altogether.
We may have to tune the amount of pages that get looked at, both on the VM
mapping side and on the active/inactive list sides).

We actually always used to do this, it was just that we delayed it until
the active list scan started failing. Which may have been delaying it too
much, causing "spikes" of activity.

Or maybe not. I'd like people to explore the balancing space more, instead
of trying to tune specific parts of the existing balance.

> Yes, we want fair aging. No, we dont want more pages being swapped out.

Absolutely. "swap_out()" does not really swap pages out. The name is
purely due to historical reasons. It should really be called
"scan_process_mappings()" or similar.

The actual swap-out obviously happens in page_launder().

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
