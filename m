Date: Thu, 11 May 2000 00:23:19 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] Recent VM fiasco - fixed
In-Reply-To: <20000510215301.A322@stormix.com>
Message-ID: <Pine.LNX.4.10.10005110019370.1355-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Simon Kirby <sim@stormix.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


Hmm..

 Having tested some more, the "wait for locked buffer" logic in
fs/buffer.c (sync_page_buffers()) seems toserialize thingsawhole lote more
than I initially thought..

Does it act the way you expect if you change the

	if (buffer_locked(p))
		__wait_on_buffer(p);
	else if (buffer_dirty(p))
		ll_rw_block(..

to a simpler

	if (buffer_dirty(p) && !buffer_locked(p))
		ll_rw_block(..

which doesn't endup serializing the IO all the time?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
