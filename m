Date: Sun, 25 Mar 2001 00:13:38 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] Fix races in 2.4.2-ac22 SysV shared memory
Message-ID: <20010325001338.C11686@redhat.com>
References: <20010323011331.J7756@redhat.com> <Pine.LNX.4.31.0103231157200.766-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.31.0103231157200.766-100000@penguin.transmeta.com>; from torvalds@transmeta.com on Fri, Mar 23, 2001 at 11:58:50AM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@nl.linux.org>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, Ben LaHaise <bcrl@redhat.com>, Christoph Rohland <cr@sap.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, Mar 23, 2001 at 11:58:50AM -0800, Linus Torvalds wrote:

> Ehh.. Sleeping with the spin-lock held? Sounds like a truly bad idea.

Uggh --- the shmem code already does, see:

shmem_truncate->shmem_truncate_part->shmem_free_swp->
lookup_swap_cache->find_lock_page

It looks messy: lookup_swap_cache seems to be abusing the page lock
gratuitously, but there are probably callers of it which rely on the
assumption that it performs an implicit wait_on_page().

Rik, do you think it is really necessary to take the page lock and
release it inside lookup_swap_cache?  I may be overlooking something,
but I can't see the benefit of it --- we can still race against
page_launder, so the page may still get locked behind our backs after
we get the reference from lookup_swap_cache (page_launder explicitly
avoids taking the pagecache hash spinlock which might avoid this
particular race).

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
