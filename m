Message-ID: <20000904094750.A13518@saw.sw.com.sg>
Date: Mon, 4 Sep 2000 09:47:50 +0800
From: Andrey Savochkin <saw@saw.sw.com.sg>
Subject: Re: Rik van Riel's VM patch
References: <E13VYF1-0000gN-00@the-village.bc.nu> <Pine.LNX.4.21.0009031743190.1112-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0009031743190.1112-100000@duckman.distro.conectiva>; from "Rik van Riel" on Sun, Sep 03, 2000 at 05:47:01PM
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Bill Huey <billh@gnuppy.monkey.org>, John Levon <moz@compsoc.man.ac.uk>, linux-mm@kvack.org, "Theodore Y. Ts'o" <tytso@MIT.EDU>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, Sep 03, 2000 at 05:47:01PM -0300, Rik van Riel wrote:
> On Sun, 3 Sep 2000, Alan Cox wrote:
> 
> > Things like random memory corruption from dropping dirty bits,
> > and some of the others are far more serious showstoppers alas
> 
> Indeed, there are 4 major issues left in the VM area:
> 
[snip]
> 2) dirty bits can get lost, try_to_swap_out() and other
>    places have a race with the hardware
> 
>    [from mm/vmscan.c, line 60 has a race with the /hardware/]
>      55         if (pte_young(pte)) {
>      56                 /*
>      57                  * Transfer the "accessed" bit from the page
>      58                  * tables to the global page map.
>      59                  */
>      60                 set_pte(page_table, pte_mkold(pte));
>      61                 SetPageReferenced(page);
>      62                 goto out_failed;
>      63         }

I wonder about software races.
Page table manipulations in mm/memory.c are guarded by page_table_lock
against concurrent kswapd actions, with the following comments:
        /*
         * This is a long-lived spinlock. That's fine.
         * There's no contention, because the page table
         * lock only protects against kswapd anyway, and
         * even if kswapd happened to be looking at this
         * process we _want_ it to get stuck.
         */
and in the other place
 *
 * Note the "page_table_lock". It is to protect against kswapd removing
 * pages from under us. Note that kswapd only ever _removes_ pages, never
 * adds them. As such, once we have noticed that the page is not present,
 * we can drop the lock early.

Fine.  However, I don't see a trace of page_table_lock in swapping-out code!
And I don't see any other lock which may ensure the serialization.
Am I missing something?

	Andrey
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
