Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E97C48D0039
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 03:20:09 -0500 (EST)
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1PiN5J-0005Yj-Dx
	for linux-mm@kvack.org; Thu, 27 Jan 2011 09:20:05 +0100
Received: from pool-98-117-134-162.sttlwa.fios.verizon.net ([98.117.134.162])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 27 Jan 2011 09:20:05 +0100
Received: from eternaleye by pool-98-117-134-162.sttlwa.fios.verizon.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 27 Jan 2011 09:20:05 +0100
From: Alex Elsayed <eternaleye@gmail.com>
Subject: Re: [PATCH V1 0/3] drivers/staging: kztmem: dynamic page =?utf-8?b?Y2FjaGUvc3dhcAljb21wcmVzc2lvbg==?=
Date: Thu, 27 Jan 2011 08:02:47 +0000 (UTC)
Message-ID: <loom.20110127T083126-210@post.gmane.org>
References: <20110118171850.GA20439@ca-server1.us.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dan Magenheimer <dan.magenheimer <at> oracle.com> writes:
> Kztmem (see kztmem.c) provides both "host" services (setup and
> core memory allocation) for a single client for the generic tmem
> code plus two different PAM implementations:
> 
> A. "compression buddies" ("zbud") which mates compression with a
>    shrinker interface to store ephemeral pages so they can be
>    easily reclaimed; compressed pages are paired and stored in
>    a physical page, resulting in higher internal fragmentation
> B. a shim to xvMalloc [8] which is more space-efficient but
>    less receptive to page reclamation, so is fine for persistent
>    pages

One feature that was present in compcache before it became zcache and zram
was the ability to have a backing store on disk. I personally would find it
interesting if:
 - 'True' swap was reimplemented as a frontswap backend
 - Multiple frontswap backends could be active at any time (Is this already
possible?)
 - Frontswap backends could provide a 'cost' metric, possibly based on
latency
 - Frontswap backends could 'delegate' pages to the backend with the
next-highest cost

Thus, the core kernel could put pages into kztmem, which could then delegate
to disk-based swap (possibly storing the buddy-compressed page, for IO and
space reduction)

A backend might 'hand off' a page if it is full, or for backend-specific
reasons (like if it compressed badly).

If a backend delegates pages which went a long time without being accessed,
congratulations - you have a hierarchical storage manager. This bit makes me
think the idea of delegation may be worth extending to cleancache.

Implementing traditional disk-based swap as a frontswap backend would strike
me as being a good way to test the flexibility (and performance) of
frontswap, and the traditional 'priority' parameter for swap could probably
be handled just by adding it to the base 'cost' of the swap backend.

There is the question of what to do if two backends have the same cost.
Using a round-robin system would probably be the simplest option, and
hopefully not too far off from the 'striping' that goes on when a user
specifies two swap devices with the same priority.

Thoughts?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
