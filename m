Date: Mon, 2 Oct 2000 18:52:59 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [highmem bug report against -test5 and -test6] Re: [PATCH] Re:
 simple FS application that hangs 2.4-test5, mem mgmt problem or FS buffer
 cache mgmt problem? (fwd)
In-Reply-To: <Pine.LNX.4.21.0010022337030.13733-100000@elte.hu>
Message-ID: <Pine.LNX.4.21.0010021849120.1067-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@transmeta.com>, Andrea Arcangeli <andrea@suse.de>, MM mailing list <linux-mm@kvack.org>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Oct 2000, Ingo Molnar wrote:

> yep, this would be nice, but i think it will be quite tough to
> balance this properly. There are two kinds of bhs in this aging
> scheme: 'normal' bhs (metadata), and 'virtual' bhs (aliased to a
> page). Freeing a 'normal' bh will get rid of the bh, and will
> (statistically) free the data buffer behind. A 'virtual' bh on
> the other hand has only sizeof(*bh) bytes worth of RAM
> footprint.

This is easy. Normal page aging will take care of the buffermem
pages. Freeing the buffer heads on pagecache pages is the only
thing we need to do in refill_inactive_scan.

> another thing is the complexity of marking a page dirty - right
> now we can assume that page->buffers holds all the blocks. With
> aging we must check wether a bh is there or not,

The code must already be able to handle this. This is nothing new.

> Plus some sort of locking has to be added as well - right now we
> dont have to care about anyone else accessing page->buffers if
> the PG_lock held - with an aging mechanizm this could get
> tougher.

OK, so we'll have:

	if (page->buffers && page->mapping && !TryLockPage(page)) {
		try_to_free_buffers(page);
		UnlockPage(page);
	}

> > So if we have "lots" of memory, we basically optimize for speed (leave
> > the cached mapping around), while if we get low on memory we
> > automatically optimize for space (get rid of bh's when we don't know
> > that we'll need them).
> 
> i'd love to have all the cached objects within the system on a
> global, size-neutral LRU list. (or at least attach a
> last-accessed timestamp to them.) This way we could synchronize
> the pagecache, inode/dentry and buffer-cache LRU lists.

s/LRU/page aging/   ;)

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
