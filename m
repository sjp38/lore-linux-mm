Date: Fri, 23 Mar 2001 11:58:50 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] Fix races in 2.4.2-ac22 SysV shared memory
In-Reply-To: <20010323011331.J7756@redhat.com>
Message-ID: <Pine.LNX.4.31.0103231157200.766-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, Ben LaHaise <bcrl@redhat.com>, Christoph Rohland <cr@sap.com>
List-ID: <linux-mm.kvack.org>


On Fri, 23 Mar 2001, Stephen C. Tweedie wrote:
>
> The patch below is for two races in sysV shared memory.

	+       spin_lock (&info->lock);
	+
	+       /* The shmem_swp_entry() call may have blocked, and
	+        * shmem_writepage may have been moving a page between the page
	+        * cache and swap cache.  We need to recheck the page cache
	+        * under the protection of the info->lock spinlock. */
	+
	+       page = find_lock_page(mapping, idx);

Ehh.. Sleeping with the spin-lock held? Sounds like a truly bad idea.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
