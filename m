Message-Id: <l03130306b73b215af2d5@[192.168.239.105]>
In-Reply-To: 
        <Pine.LNX.4.21.0105301734030.13062-100000@imladris.rielhome.conectiva>
References: 
        <Pine.LNX.4.10.10105301539030.31487-100000@coffee.psychology.mcmaster.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 30 May 2001 23:41:59 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: Plain 2.4.5 VM
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, Mark Hahn <hahn@coffee.psychology.mcmaster.ca>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>The "getting rid of it" above consists of 2 parts:
>
>1) moving the page to the active list, where
>   refill_inactive_scan will age it

Ummm...  I don't see any movement of pages to the "active" list in
try_to_swap_out().  Instead, I see some very direct attempts to push the
page onto backing store by some means.  In the stock kernel, this is done
solely on the status of a single bit in the PTE, regardless of page->age or
it's position on any particular list.

IOW, all the fannying around with page->age really has very little (if any)
effect on the paging behaviour when it matters most - when memory pressure
is so intense that kswapd is looping.  That's why I put in the extra test
(and decrement) for page->age before going ahead with the swapping-out
business.

>2) the page->age will be higher if the page
>   has been accessed more often

In general, yes.  I think the numbers on that need to be adjusted a bit - I
really think page->age gets shrunk to zero far too quickly, compared to the
"effort" it takes to raise it.  I'm thinking about the best ways to adjust
that.

The first thing I'm considering is to make PAGE_AGE_START == PAGE_AGE_MAX,
to ensure that newly-allocated pages have the best chance of survival.
After all, it can take a *lot* of work to allocate a page, and we don't
want it swapped out before the process gets a chance to use it enough to
give it a decent age.

The second thing is to make age_page_down a decrement rather than a divide.
As I say above, it's looking far too easy to destroy a lot of hard-won
"age" with a few kswapd loops.  To go along with this, some playing with
the PAGE_AGE_* values would want doing.  If someone can give me a *really*
good reason why the aging down is a division operation, I'd like to hear it
- but in that case I suspect that PAGE_AGE_MAX should be lots higher.

--------------------------------------------------------------
from:     Jonathan "Chromatix" Morton
mail:     chromi@cyberspace.org  (not for attachments)
big-mail: chromatix@penguinpowered.com
uni-mail: j.d.morton@lancaster.ac.uk

The key to knowledge is not to rely on people to teach you it.

Get VNC Server for Macintosh from http://www.chromatix.uklinux.net/vnc/

-----BEGIN GEEK CODE BLOCK-----
Version 3.12
GCS$/E/S dpu(!) s:- a20 C+++ UL++ P L+++ E W+ N- o? K? w--- O-- M++$ V? PS
PE- Y+ PGP++ t- 5- X- R !tv b++ DI+++ D G e+ h+ r++ y+(*)
-----END GEEK CODE BLOCK-----


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
