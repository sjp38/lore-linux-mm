Received: from post.mail.nl.demon.net (post-10.mail.nl.demon.net [194.159.73.20])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA24754
	for <linux-mm@kvack.org>; Tue, 11 May 1999 18:03:30 -0400
Date: Tue, 11 May 1999 23:30:35 +0200 (CEST)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: Swap Questions (includes possible bug) - swapfile.c / swap.c
In-Reply-To: <Pine.LNX.4.03.9905111114210.19954-100000@baltimore.wwaves.com>
Message-ID: <Pine.LNX.4.03.9905112321550.226-100000@mirkwood.nl.linux.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Joseph Pranevich <knight@baltimore.wwaves.com>
Cc: Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 11 May 1999, Joseph Pranevich wrote:

> I've been gradually sifting my way through the kernel source and I
> have a few minor questions about memory management.

linux-mm@kvack.org	(majordomo-managed)
http://www.linux.eu.org/Linux-MM/

> 1) swap.c : page clustering?

> 	else
> 		page_cluster = 4;
> 
> This is fine, but wouldn't it make sense to generalize this, or is
> the benifit not as great with larger amounts of ram?

The swapOUT clustering is only done to a maximum of 32 (2^5)
pages, so it doesn't make much sense to read in more pages
(which are probably unrelated to the current process).

For mmap() reading we might want to switch to a smarter
algorithm though. Not with reading in more pages, but with
reading in the _next_ area while the program is still busy
processing this one. The idea is to have all data in memory
just before the process needs it :)


> 2) swapfile.c : sys_swapon() question 1
> 
> I'm unable to figure out exactly what this code is supposed to be
> doing. Can someone help me out here? I don't understand why we set
> the blocksize twice or what the funniness is with "filp"
> 
> 		p->swap_device = swap_dentry->d_inode->i_rdev;
> 		set_blocksize(p->swap_device, PAGE_SIZE);

We do I/O on this device in chunks of PAGE_SIZE.

> 		filp.f_dentry = swap_dentry;
> 		filp.f_mode = 3; /* read write */

Of course, we want to have our swap device read-write and we
mark it with a magic number so no harm will come to it...

> 		set_blocksize(p->swap_device, PAGE_SIZE);

Hmm, haven't we seen this one before? Stephen?


> I do apologise for the many questions, I'm just trying to get a
> feel for the swapping subsystem. I apologise if this is already
> documented someplace.

AFAIK it's not yet documented. I'd really appreciate it
if you could do that and send me the docs for inclusion
on the Linux-MM site...

cheers,

Rik -- Open Source: you deserve to be in control of your data.
+-------------------------------------------------------------------+
| Le Reseau netwerksystemen BV:               http://www.reseau.nl/ |
| Linux Memory Management site:   http://www.linux.eu.org/Linux-MM/ |
| Nederlandse Linux documentatie:          http://www.nl.linux.org/ |
+-------------------------------------------------------------------+

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
