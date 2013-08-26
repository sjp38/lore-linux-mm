Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id CC0F16B003B
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 18:28:44 -0400 (EDT)
Date: Mon, 26 Aug 2013 18:28:33 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: unused swap offset / bad page map.
Message-ID: <20130826222833.GA24320@redhat.com>
References: <20130821204901.GA19802@redhat.com>
 <CAJd=RBBNCf5_V-nHjK0gOqS4OLMszgB7Rg_WMf4DvL-De+ZdHA@mail.gmail.com>
 <20130823032127.GA5098@redhat.com>
 <CAJd=RBArkh3sKVoOJUZBLngXtJubjx4-a3G6s7Tn0N=Pr1gU4g@mail.gmail.com>
 <20130823035344.GB5098@redhat.com>
 <CAJd=RBBtY-nJfo9nzG5gtgcvB2bz+sxpK5kX33o1sLeLhvEU1Q@mail.gmail.com>
 <20130826190757.GB27768@redhat.com>
 <CA+55aFw_bhMOP73owFHRFHZDAYEdWgF9j-502Aq9tZe3tEfmwg@mail.gmail.com>
 <CA+55aFwQbJbR3xij1+iGbvj3EQggF9NLGAfDbmA54FkKz9xfew@mail.gmail.com>
 <alpine.LNX.2.00.1308261448490.4982@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1308261448490.4982@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Hillf Danton <dhillf@gmail.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Mon, Aug 26, 2013 at 03:08:45PM -0700, Hugh Dickins wrote:
 
 > > That said, google does find "swap_free: Unused swap offset entry"
 > > reports from over the years. Most of them seem to be single-bit
 > > errors, though (ie when the entry is 00000100 or similar I'm more
 > > inclined to blame a bit error
 > 
 > Yes, historically they have usually represented either single-bit
 > errors, or corruption of page tables by other kernel data.  The
 > swap subsystem discovers it, but it's rarely an error of swap.
 
Just to rule out bad hardware, I've seen this on two systems
(admittedly the exact same spec, but still..)

 > So I don't care for Dave's suggestion much earlier in this thread,
 > that swapoff should fail with -EINVAL if there has been a bad page
 > taint: that doesn't necessarily interfere with swapoff at all.
 > 
 > And besides, swapoff is killable: yes, if counts go wrong, it
 > can cycle around endlessly, but it checks for signal_pending()
 > each time around the loop.

It might be killable, but if I've done /sbin/reboot, and the
kernel dies in sys_swapoff because of the corruption, I won't
get a chance to kill it, because at that point the shutdown process
has killed my shell, sshd, and just about everything else.
It mieans a grumpy walk to the other side of the house to prod a
reset button.  So yeah, it might not be a mergable thing, but
at least while bisecting it's pretty much a must-have.

 > I just did a quick diff of 3.11-rc7/mm against 3.10, and here's
 > a line in mremap which worries me.  That set_pte_at() is operating
 > on anything that isn't pte_none(), so the pte_mksoft_dirty() looks
 > prone to corrupt a swap entry.
 > 
 > I've not tried matching up bits with Dave's reports, and just going
 > into a meeting now, but this patch looks worth a try: probably Cyrill
 > can improve it meanwhile to what he actually wants there (I'm
 > surprised anything special is needed for just moving a pte).
 > 
 > Hugh
 > 
 > --- 3.11-rc7/mm/mremap.c	2013-07-14 17:10:16.640003652 -0700
 > +++ linux/mm/mremap.c	2013-08-26 14:46:14.460027627 -0700
 > @@ -126,7 +126,7 @@ static void move_ptes(struct vm_area_str
 >  			continue;
 >  		pte = ptep_get_and_clear(mm, old_addr, old_pte);
 >  		pte = move_pte(pte, new_vma->vm_page_prot, old_addr, new_addr);
 > -		set_pte_at(mm, new_addr, new_pte, pte_mksoft_dirty(pte));
 > +		set_pte_at(mm, new_addr, new_pte, pte);
 >  	}

I'll give this a shot once I'm done with the bisect.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
