Date: Wed, 3 May 2000 18:38:50 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long) (backtrace)
In-Reply-To: <200005031608.JAA87583@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.10005031828520.950-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Rajagopal Ananthanarayanan <ananth@sgi.com>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

Ok,
 there's a pre7-4 out there that does the swapout with the page locked.
I've given it some rudimentary testing, but certainly nothing really
exotic. Please comment..

David pointed out that swapout_highmem can't really work, and he's right
and wrong. It does work, but it works for rather undocumented reasons: it
only gets invoced for anonymous dirty pages, and they are always
cow-shared, so it's ok to "break" the page up into an "old" page and a
"new" page with the same contents. Even though it's not legal in general.

I'm not claiming that this fixes any known bugs, but it _does_ mean that
we probably have the page locked in all fundamental cases where it really
matters. If anybody finds a case where we play with the page-cached-ness
(or similar) of a page without holding the page lock, please holler
loudly.

This way it should be easy to verify that yes, our coherency is fine.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
