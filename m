From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14338.1859.507452.652164@dukat.scot.redhat.com>
Date: Mon, 11 Oct 1999 16:50:27 +0100 (BST)
Subject: Re: locking question: do_mmap(), do_munmap()
In-Reply-To: <Pine.GSO.4.10.9910101450250.16317-100000@weyl.math.psu.edu>
References: <3800DE17.935ADF8D@colorfullife.com>
	<Pine.GSO.4.10.9910101450250.16317-100000@weyl.math.psu.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: Manfred Spraul <manfreds@colorfullife.com>, Andrea Arcangeli <andrea@suse.de>, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, 10 Oct 1999 15:03:45 -0400 (EDT), Alexander Viro
<viro@math.psu.edu> said:

> Hold on. In swap_out_mm() you have to protect find_vma() (OK, it doesn't
> block, but we'll have to take care of mm->mmap_cache) _and_ you'll have to
> protect vma from destruction all way down to try_to_swap_out(). And to
> vma->swapout(). Which can sleep, so spinlocks are out of question
> here.

No, spinlocks would be ideal.  The vma swapout codes _have_ to be
prepared for the vma to be destroyed as soon as we sleep.  In fact, the
entire mm may disappear if the process happens to exit.  Once we know
which page to write where, the swapout operation becomes a per-page
operation, not per-vma.

We had some rather interesting bugs in the 1.0 and 1.2 timeframes
surrounding exactly this.  Nowadays we assume that all mm context
disappears as soon as the swapper blocks.  We bump the refcount on the
page itself to make the page write safe, but we have to be very careful
indeed to do all the mm manipulations before we get to that stage.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
