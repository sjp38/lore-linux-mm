Received: from edge05.upc.biz ([192.168.13.212]) by viefep20-int.chello.at
          (InterMail vM.7.08.02.02 201-2186-121-104-20070414) with ESMTP
          id <20080814124903.YGD14987.viefep20-int.chello.at@edge05.upc.biz>
          for <linux-mm@kvack.org>; Thu, 14 Aug 2008 14:49:03 +0200
Subject: Re: [rfc][patch] mm: dirty page accounting race fix
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0808141210200.4398@blonde.site>
References: <20080814094537.GA741@wotan.suse.de>
	 <Pine.LNX.4.64.0808141210200.4398@blonde.site>
Content-Type: text/plain
Date: Thu, 14 Aug 2008 14:49:09 +0200
Message-Id: <1218718149.10800.224.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-08-14 at 12:55 +0100, Hugh Dickins wrote:

> Am I confused, or is your "do_wp_page calls ptep_clear_flush_notify"
> example a very bad one?  The page it's dealing with there doesn't
> go back into the page table (its COW does), and the dirty_accounting
> case doesn't even get down there, it's dealt with in the reuse case
> above, which uses ptep_set_access_flags. 

Also, the new page is only added to the rmap _after_ it has been
installed. So page_mkclean() will never get to it to see the empty pte.

>  Now, I think that one may
> well behave as you suggest on some arches (though it's extending
> permissions not restricting them, so maybe not); but please check
> that out and improve your example.

Another case I just looked at is if ptep_clear_flush_young() actually
does the clear bit. But the few arches (x86_64, ppc64) that I looked at
don't seem to do so.

If someone would, you could hit this race.

/me continues searching for a convincing candidate..

> Even if it does, it's not clear to me that your fix is the answer.
> That may well be because the whole of dirty page accounting grew too
> subtle for me! 

    CPU1                      CPU2

    lock(pte_lock)
    ptep_clear_flush(ptep)
                            page_mkclean()
                              page_check_address()
                                !pte_present(ptep)
                                   return NULL
    ptep_set(ptep, new_pte);
    unlock(pte_lock)

Now, if page_check_address() doesn't return prematurely, but is forced
to take the pte_lock, we won't see that hole and will not skip the page.

> But holding the page table lock on one pte of the
> page doesn't guarantee much about the integrity of the whole dance:
> do_wp_page does its set_page_dirty_balance for this case, you'd
> need to spell out the bad sequence more to convince me.
 
Now you're confusing me... are you saying ptes can be changed from under
your feet even while holding the pte_lock?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
