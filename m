From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14337.64699.741408.60931@dukat.scot.redhat.com>
Date: Mon, 11 Oct 1999 16:05:31 +0100 (BST)
Subject: Re: locking question: do_mmap(), do_munmap()
In-Reply-To: <Pine.LNX.4.10.9910091758380.5808-100000@alpha.random>
References: <Pine.GSO.4.10.9910090903530.14891-100000@weyl.math.psu.edu>
	<Pine.LNX.4.10.9910091758380.5808-100000@alpha.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Alexander Viro <viro@math.psu.edu>, Manfred Spraul <manfreds@colorfullife.com>, linux-kernel@vger.rutgers.edu, "linux-mm@kvack.org" <linux-mm@kvack.org>, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, 9 Oct 1999 18:01:27 +0200 (CEST), Andrea Arcangeli
<andrea@suse.de> said:

> On Sat, 9 Oct 1999, Alexander Viro wrote:
>> do_munmap() doesn't need the big lock. do_mmap() callers should grab

> Look the swapout path. Without the big kernel lock you'll free vmas under
> swap_out().

Yes.  The swapout code relies on the big lock to freeze the vma, and on
the page_table_lock to protect the ptes, so that it can avoid worrying
about the mm_sem at all.

If munmap ever drops vmas without the big lock, the swapper _will_
break.  Making this into a per-mm lock would not be hard, btw.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
