From: yannis@cc.gatech.edu (Yannis Smaragdakis)
Message-Id: <200007170709.DAA27512@ocelot.cc.gatech.edu>
Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on
Date: Mon, 17 Jul 2000 03:09:06 -0400 (EDT)
In-Reply-To: <Pine.LNX.4.21.0007111503520.10961-100000@duckman.distro.conectiva> from "Rik van Riel" at Jul 11, 2000 03:06:38 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andrea Arcangeli <andrea@suse.de>, "Stephen C. Tweedie" <sct@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, Jens Axboe <axboe@suse.de>, Alan Cox <alan@redhat.com>, Derek Martin <derek@cerberus.ne.mediaone.net>, davem@redhat.com, linux-mm@kvack.org, Yannis Smaragdakis <yannis@cc.gatech.edu>
List-ID: <linux-mm.kvack.org>

> On Tue, 11 Jul 2000, Rik van Riel wrote:
> And that is correct behaviour. The problem with LRU is that the
> "eventually" is too short, but proper page aging is as close to
> LFU (least _frequently_ used) as it is to LRU. In that case any
> page which was used only once (or was only used a long time ago)
> will be freed before a page which has been used more often
> recently will be.


I'm a Linux kernel newbie and perhaps I should keep my mouth shut, but
I have done a bit of work in memory management and I can't resist
putting my 2c in.


Although I agree with Rik in many major points, I disagree in that I
don't think that page aging should be frequency-based. Overall, I strongly
believe that frequency is the wrong thing to be measuring for deciding
which page to evict from RAM. The reason is that a page that is brought
to memory and touched 1000 times in relatively quick succession is *not*
more valuable than one that is brought to memory and only touched once. 
Both will cause exactly one page fault. Also, one should be cautious of
pages that are brought in RAM, touched many times, but then stay untouched
for a long time. Frequency should never outweigh recency--the latter is
a better predictor, as OS designers have found since the early 70s.


Having said that, LRU is certainly broken, but there are other ways to
fix it. I'll shamelessly plug a paper by myself, Scott Kaplan, and
Paul Wilson, from SIGMETRICS 99. It is in:
	http://www.cc.gatech.edu/~yannis/eelru.ps.gz
(Sorry for the PS, but it compresses well and the original is >3MB.)

I'll be glad to answer questions. The main idea is that we can keep
rough page "ages" (where "age" refers to recency) not only for pages
in RAM, but also for recently evicted pages. Then if we detect that
our overall eviction strategy is wrong (i.e., we touch lots of the
pages we recently evicted), we adapt it by evicting more recently 
touched pages (sounds hacky, but it is actually very clean).

The results are very good (even better than in the paper, as we have
improved the algorithm since).


Back to my cave...
	Yannis.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
