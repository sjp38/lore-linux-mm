Received: by fenrus.demon.nl
	via sendmail from stdin
	id <m12qjP0-000OVtC@amadeus.home.nl> (Debian Smail3.2.0.102)
	for linux-mm@kvack.org; Sat, 13 May 2000 23:24:50 +0200 (CEST)
Message-Id: <m12qjP0-000OVtC@amadeus.home.nl>
Date: Sat, 13 May 2000 23:24:50 +0200 (CEST)
From: arjan@fenrus.demon.nl (Arjan van de Ven)
Subject: Re: pre8: where has the anti-hog code gone?
In-Reply-To: <Pine.LNX.4.21.0005122031500.28943-100000@duckman.distro.conectiva> <Pine.LNX.4.10.10005130819330.1721-100000@penguin.transmeta.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[snip stuff about "first make it work, then make it nice/fast"]

> So pre-8 with your suggested for for kswapd() looks pretty good, actually,
> but still has this issue that try_to_free_pages() seems to give up too
> easily and return failure when it shouldn't. 

I have been looking at it right now, and I think there are a few issues:

1) shrink_[id]node_memory always return 0, even if they free memory
2) shrink_inode_memory is broken for priority == 0

2) is easily fixable, but even with that fixed, my traces show that, for the
mmap002 test, shrink_mmap fails just before the OOM.

My idea is (but I have not tested this) that for priority == 0 (aka "Uh oh")
shrink_mmap or do_try_to_free_pages have to block while waiting for pages to
be commited to disk. As far as I can see, shrink_mmap just skips pages that
are being commited to disk, while these could be freed when they are waited
upon. 

Greetings,
    Arjan van de Ven
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
