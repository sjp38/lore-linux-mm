Date: Sun, 10 Oct 1999 13:25:14 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: locking question: do_mmap(), do_munmap()
In-Reply-To: <3800C2BF.716C9D65@colorfullife.com>
Message-ID: <Pine.GSO.4.10.9910101301050.16317-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfreds@colorfullife.com>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[Apologies to Andrea - idiot me looked into the wrong place ;-<]

On Sun, 10 Oct 1999, Manfred Spraul wrote:

> AFAIK the problem is OOM:
> * a process accesses a not-present, ie page fault:
> ...
> handle_mm_fault(): this process own mm->mmap_sem.
> ->handle_pte_fault().
> -> (eg.) do_wp_page().
> -> get_free_page().
> now get_free_page() notices that there is no free memory.
> --> wakeup kswapd.
> 
> * the swapper runs, and it tries to swap out data from that process.
> mm->mmap_sem is already acquired --> lock-up.

Nasty... But adding a big lock around all traversals of the mm->mmap will
hurt like hell. Let's see... The problem is in swap_out_mm(), right? And
it looks for the first suitable page. OK, it looks like we can get a
deadlock only if we call try_to_free_pages() with ->mmap_sem grabbed and
__GFP_WAIT in flags. Umhm... Called only from __get_free_pages() which
sets PF_MEMALLOC... OK, I'll try to look at it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
