Date: Mon, 2 Jul 2001 20:22:19 +0100 (BST)
From: <markhe@veritas.com>
Subject: Re: Can reverse VM locks?
In-Reply-To: <Pine.LNX.4.33L.0107021601240.14332-100000@imladris.rielhome.conectiva>
Message-ID: <Pine.LNX.4.33.0107022014190.9756-100000@alloc.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2 Jul 2001, Rik van Riel wrote:
> On Mon, 2 Jul 2001 markhe@veritas.com wrote:
>
> >   Anyone know of any places where reversing the lock ordering would break?
>
> Basically add_to_page_cache and remove_from_page cache and friends ;)

  Hmm, does a page-cache page need to be on an LRU list?

  If not, the 'add' case falls out OK; add it to the page-cache first,
then add it to an LRU list _after_ dropping the pagecache_lock and taking
the pagemap_lru_lock.  ie. no lock overlap.

  For the delete/remove case, aren't both the locks normally held for this
anyway?  With the locks being reversed, they would still both be held (as
in reclaim_page(), invalidate_inode_pages()).
  For  truncate_complete_page(), there is no lock overlap so no problem.
True?

Mark

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
