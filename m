Date: Mon, 2 Oct 2000 14:31:31 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [highmem bug report against -test5 and -test6] Re: [PATCH] Re:
 simple FS application that hangs 2.4-test5, mem mgmt problem or FS buffer
 cache mgmt problem? (fwd)
In-Reply-To: <Pine.LNX.4.21.0010021821210.1067-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10010021429230.826-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>


On Mon, 2 Oct 2000, Rik van Riel wrote:
> 
> OK, so we want something like the following in
> refill_inactive_scan() ?
> 
> if (free_shortage() && inactive_shortage() && page->mapping &&
> 			page->buffers)
> 	try_to_free_buffers(page, 0);

That's just nasty.

Why not just do it unconditionally whenever we do the
age_page_down_ageonly(page) too? Simply something like

	if (page->buffers)
		try_to_free_buffers(page, 1);

(and yes, I think it should also start background writing - we probably
need the gfp_mask to know whether we can do that).

I hate code that tries to be clever. 

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
