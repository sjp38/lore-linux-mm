From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200004082354.QAA62699@google.engr.sgi.com>
Subject: Re: zap_page_range(): TLB flush race
Date: Sat, 8 Apr 2000 16:54:32 -0700 (PDT)
In-Reply-To: <E12e4mo-0003Pn-00@the-village.bc.nu> from "Alan Cox" at Apr 09, 2000 12:37:05 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Manfred Spraul <manfreds@colorfullife.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, torvalds@transmeta.com, davem@redhat.com
List-ID: <linux-mm.kvack.org>

> 
> > > Yes, establish_pte() is broken. We should reverse the calls:
> > > 
> > > 	set_pte(); /* update the kernel page tables */
> > > 	update_mmu(); /* update architecture specific page tables. */
> > > 	flush_tlb();  /* and flush the hardware tlb */
> > >
> > 
> > People are aware of this too, it was introduced during the 390 merge. 
> > I tried talking to the IBM guy about this, I didn't see a response from
> > him ...
> 
> Strange since I did and it included you

Yes, I did get the first mail from the IBM guy (was he from Denmark, seem 
to have seen ibm.de in his email?) explaining why the 390 wanted this
ordering ... In response, I pointed out that the 390 was either prone
to other races then, or was doing something in its low level handlers, 
and could he please confirm what is the case? 

Let me remember: he mentioned the old pte must be around for the ipte(?)
instruction to flush the tlb. If the new pte is dropped in before, the 
flush fails, the stale tlb entry stays, problems happen. So I pointed out
other places which do set_pte, then flush_tlb. I also wanted to know 
whether the flush_tlb somehow makes sure that other threads/cpus can not
pull in the old translation till the set_pte completes (something like
what freeze_pte_* does in my patch). I did not receive a response to this.

> 
> > I think what we now need is a critical mass, something that will make us
> > go "okay, lets just fix these races once and for all".
> 
> Basically establish_pte() has to be architecture specific, as some processors
> need different orders either to avoid races or to handle cpu specific
> limitations.

Even if you did that, wouldn't it just mean that the 390 would still be
prone to races, but other platforms are not? Of course, that's much
better than having all platforms be prone to the race!

And we should also handle the generic races with clones and ptes, an
example of which Manfred just demonstrated.

Kanoj
> 
> Alan
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
