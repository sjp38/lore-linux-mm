Date: Fri, 23 Mar 2001 14:27:12 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] Fix races in 2.4.2-ac22 SysV shared memory
In-Reply-To: <E14gZuj-0005YN-00@the-village.bc.nu>
Message-ID: <Pine.LNX.4.31.0103231424230.766-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ben LaHaise <bcrl@redhat.com>, Christoph Rohland <cr@sap.com>
List-ID: <linux-mm.kvack.org>


On Fri, 23 Mar 2001, Alan Cox wrote:
> >
> > 	+       spin_lock (&info->lock);
> > 	+
> > 	+       /* The shmem_swp_entry() call may have blocked, and
> > 	+        * shmem_writepage may have been moving a page between the page
> > 	+        * cache and swap cache.  We need to recheck the page cache
> > 	+        * under the protection of the info->lock spinlock. */
> > 	+
> > 	+       page = find_lock_page(mapping, idx);
> >
> > Ehh.. Sleeping with the spin-lock held? Sounds like a truly bad idea.
>
> Umm find_lock_page doesnt sleep does it ?

Sure it does. Note the "lock" in find_lock_page(). It will lock the page,
which implies sleeping if somebody is accessing it at the same time.

If you don't want to sleep, you need to use one of the wrappers for
"__find_page_nolock()". Something like "find_get_page()", which only
"gets" the page.

The naming actually does make sense in this area.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
