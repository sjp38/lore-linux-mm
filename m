Date: Tue, 3 Oct 2000 00:53:09 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [highmem bug report against -test5 and -test6] Re: [PATCH] Re:
 simple FS application that hangs 2.4-test5, mem mgmt problem or FS buffer
 cache mgmt problem? (fwd)
In-Reply-To: <Pine.LNX.4.21.0010021849120.1067-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0010030038370.16056-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, Andrea Arcangeli <andrea@suse.de>, MM mailing list <linux-mm@kvack.org>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Oct 2000, Rik van Riel wrote:

> > yep, this would be nice, but i think it will be quite tough to
> > balance this properly. There are two kinds of bhs in this aging
> > scheme: 'normal' bhs (metadata), and 'virtual' bhs (aliased to a
> > page). Freeing a 'normal' bh will get rid of the bh, and will

> This is easy. Normal page aging will take care of the buffermem pages.
> Freeing the buffer heads on pagecache pages is the only thing we need
> to do in refill_inactive_scan.

to do some sort of aging is of course easy. But to treat a 4kbyte
'metadata bh' the same way as a 80 bytes worth 'cached mapping bh' is IMO
a stretch. This is what i ment by 'tough to balance properly'.

> > another thing is the complexity of marking a page dirty - right
> > now we can assume that page->buffers holds all the blocks. With
> > aging we must check wether a bh is there or not,
> 
> The code must already be able to handle this. This is nothing new.

sure this is new. The page->buffers list right now is assumed to stay
constant after being created.

> > i'd love to have all the cached objects within the system on a
> > global, size-neutral LRU list. (or at least attach a
> > last-accessed timestamp to them.) This way we could synchronize
> > the pagecache, inode/dentry and buffer-cache LRU lists.
> 
> s/LRU/page aging/   ;)

no - how does this handle the inode/dentry cache? Making everything a page
is a mistake.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
