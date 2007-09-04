Date: Tue, 4 Sep 2007 19:37:48 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [MAILER-DAEMON@watson.ibm.com: Returned mail: see transcript for details]
Message-ID: <20070904173748.GC1191@wotan.suse.de>
References: <20070903201645.GA11502@wotan.suse.de> <46DCFBB2.3060200@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <46DCFBB2.3060200@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Balbir Singh <balbir@in.ibm.com>, Shailabh Nagar <nagar1234@in.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 04, 2007 at 07:31:14AM +0100, Balbir Singh wrote:
> Nick Piggin wrote:
> 
> > But the most obvious delay, where we actually lock the page waiting for
> > the swap IO to finish, does not seem to be accounted at all!
> > 
> 
> Hmm.. Does lock_page() eventually call io_schedule() or io_schedule_timeout()?
> I think it does -- via sync_page(). The way our accounting works is that we
> account for block I/O in io_schedule*(). If we see the SWAPIN flag set, we
> then account for that I/O as swap I/O.

Yes, lock_page will io_schedule() down the path you say.

> > My proposed fix is to just move the swaping delay accounting to the
> > point where the VM does actually wait, for the swapin.
> > 
> > I have no idea what uses swapin delay accounting, but it would be good to
> > see if this makes a positive (or at least not negative) impact on those
> > users...
> > 
> > Thanks,
> > Nick
> > 
> > --
> > Index: linux-2.6/mm/memory.c
> > ===================================================================
> > --- linux-2.6.orig/mm/memory.c
> > +++ linux-2.6/mm/memory.c
> > @@ -2158,7 +2158,6 @@ static int do_swap_page(struct mm_struct
> >  		migration_entry_wait(mm, pmd, address);
> >  		goto out;
> >  	}
> > -	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
> 
> Let's start the accounting here.
 
If you start accounting here, then you can potentially also count other
stuff as swapin delay which I don't think you want to. I'm not sure if
there is any part of reclaim where we directly wait on page IO, but we
do wait on blkdev congestion which calls io_schedule. It seems funny to
account this as swapin delay.


> >  	page = lookup_swap_cache(entry);
> >  	if (!page) {
> >  		grab_swap_token(); /* Contend for token _before_ read-in */
> > @@ -2172,7 +2171,6 @@ static int do_swap_page(struct mm_struct
> >  			page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
> >  			if (likely(pte_same(*page_table, orig_pte)))
> >  				ret = VM_FAULT_OOM;
> > -			delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
> >  			goto unlock;
> >  		}
> > 
> > @@ -2181,9 +2179,10 @@ static int do_swap_page(struct mm_struct
> >  		count_vm_event(PGMAJFAULT);
> >  	}
> > 
> > -	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
> >  	mark_page_accessed(page);
> > +	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
> >  	lock_page(page);
> > +	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
> > 
> 
> I agree that we should end it after lock_page().

OK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
