Date: Mon, 8 Jan 2001 10:38:19 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Subtle MM bug
In-Reply-To: <Pine.LNX.4.21.0101081613530.21675-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10101081028300.3750-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "David S. Miller" <davem@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 8 Jan 2001, Rik van Riel wrote:
> 
> > That _is_ the problem the above will fix. Don't read
> > "page_launder()" there: it's more meant to be "this is the old
> > code that does page_launder() etc.."
> > 
> > Trust me. Try my code. It will work.
> 
> Except for the small detail that pages inside the processes
> are often not on the active list  ;)

Yes, you're right - we don't have a good counter to test right now.		

That's actually fairly nasty. We can't even use the "reverse" test,
because while we can make it do something like

	if (nr_inactive + nr_inactive_dirty < X %)

that won't pick up on things like the dentry and inode caches, so that
would be wrong too. 

We would really need to count the number of mapped anonymous pages to get
this right. Damn. That makes it harder than I thought.

(Hmm.. Increment counter in "do_anonymous_page()" and "do_wp_page()".
Decrement in "add_to_swap_cache()". Decrement in "free_pte()" for the
!page->mapping case. Test. Find the places I forgot. Maybe it's not that
bad, after all).

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
