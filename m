Date: Sat, 9 Jun 2007 16:55:47 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH 00 of 16] OOM related fixes
Message-ID: <20070609145547.GC7130@v2.random>
References: <patchbomb.1181332978@v2.random> <20070608212610.GA11773@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070608212610.GA11773@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-mm@kvack.org, Petr Tesarik <ptesarik@suse.cz>
List-ID: <linux-mm.kvack.org>

Hi Wil,

On Fri, Jun 08, 2007 at 02:26:10PM -0700, William Lee Irwin III wrote:
> Interesting. This seems to demonstrate a need for file IO to handle
> fatal signals, beyond just people wanting faster responses to kill -9.
> Perhaps it's the case that fatal signals should always be handled, and
> there should be no waiting primitives excluding them. __GFP_NOFAIL is
> also "interesting."

Clearly the sooner we respond to a SIGKILL the better. We tried to
catch the two critical points to solve the evil read(huge)->oom. BTW,
the first suggestion that we had to also break out of read to make
progress substantially quicker, was from Petr so I'm cc'ing him. I'm
unsure what else of more generic we could do to solve more of those
troubles at the same time without having to pollute the code with
sigkill checks. For example we're not yet covering the o-direct paths
but I did the minimal changes to resolve the current workload and that
used buffered io of course ;). BTW, I could have checked the
TIF_MEMDIE instead of seeing if sigkill was pending, but since I had
to check the task structure anyway, I preferred to check for the
sigkill so that kill -9 will now work for the first time against a
large read/write syscall, besides allowing the TIF_MEMDIE task to exit
in reasonable time without triggering the deadlock detection in the
later patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
