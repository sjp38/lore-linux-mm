Date: Mon, 8 Jan 2001 14:18:23 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Call me crazy..
Message-ID: <20010108141823.S9321@redhat.com>
References: <Pine.LNX.4.10.10101072242340.29065-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.10.10101072242340.29065-100000@penguin.transmeta.com>; from torvalds@transmeta.com on Sun, Jan 07, 2001 at 10:51:04PM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>, Alan Cox <alan@redhat.com>, Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, Jan 07, 2001 at 10:51:04PM -0800, Linus Torvalds wrote:
> ..but there seems to be a huge gaping hole in copy_page_range().
> 
> It's called during fork(), and as far as I can tell it doesn't get the
> page table lock at all when it copies the page table from the parent to
> the child.
> 
> Now, just for fun, explain to me why some other process couldn't race with
> copy_page_range() on another CPU, and decimate the parents page tables,
> resulting in the child getting a page table entry that isn't valid any
> more?

It looks like it is needed.  It's even worse on PAE36, where we are
doing things like

				if (!pte_present(pte)) {
					swap_duplicate(pte_to_swp_entry(pte));
					goto cont_copy_pte_range;
				}

without the lock: other CPUs may be doing non-atomic operations such
as ptep_get_and_clear() which leave a !pte_present() pte with invalid
contents for a brief period.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
