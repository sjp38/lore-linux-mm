Date: Sun, 7 Jan 2001 22:51:04 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Call me crazy..
Message-ID: <Pine.LNX.4.10.10101072242340.29065-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: "David S. Miller" <davem@redhat.com>, Alan Cox <alan@redhat.com>, Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

..but there seems to be a huge gaping hole in copy_page_range().

It's called during fork(), and as far as I can tell it doesn't get the
page table lock at all when it copies the page table from the parent to
the child.

Now, just for fun, explain to me why some other process couldn't race with
copy_page_range() on another CPU, and decimate the parents page tables,
resulting in the child getting a page table entry that isn't valid any
more?

Now, that race looks fairly small (we do increase the page count pretty
quickly after having looked up the page in the parent), but even so it
does look to me like the thing needs a 

	spin_lock(&src->page_table_lock);
	..
	spin_unlock(&src->page_table_lock);

around the innermost loop (we don't need it in the destination, because
the destination won't even be visible to the page-outs yet. Never mind the
fact that the destination will be empty, and after we've filled it in it
_would_ be ok to page it out because we no longer care).

Does anybody see why this wouldn't be required?

Can anybody find any _other_ cases of something like this?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
