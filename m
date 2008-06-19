From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <24280609.1213889550357.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 20 Jun 2008 00:32:30 +0900 (JST)
Subject: Re: Re: [Experimental][PATCH] putback_lru_page rework
In-Reply-To: <1213886722.6398.29.camel@lts-notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <1213886722.6398.29.camel@lts-notebook>
 <20080611225945.4da7bb7f.akpm@linux-foundation.org>
	 <20080617163501.7cf411ee.nishimura@mxp.nes.nec.co.jp>
	 <20080617164709.de4db070.nishimura@mxp.nes.nec.co.jp>
	 <20080618184000.a855dfe0.kamezawa.hiroyu@jp.fujitsu.com>
	 <1213813266.6497.14.camel@lts-notebook>
	 <20080619092242.79648592.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org
List-ID: <linux-mm.kvack.org>

----- Original Message -----
>Subject: Re: [Experimental][PATCH] putback_lru_page rework
>From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>

>On Thu, 2008-06-19 at 09:22 +0900, KAMEZAWA Hiroyuki wrote:
>> On Wed, 18 Jun 2008 14:21:06 -0400
>> Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
>> 
>> > On Wed, 2008-06-18 at 18:40 +0900, KAMEZAWA Hiroyuki wrote:
>> > > Lee-san, how about this ?
>> > > Tested on x86-64 and tried Nisimura-san's test at el. works good now.
>> > 
>> > I have been testing with my work load on both ia64 and x86_64 and it
>> > seems to be working well.  I'll let them run for a day or so.
>> > 
>> thank you.
>> <snip>
>
>Update:
>
>On x86_64 [32GB, 4xdual-core Opteron], my work load has run for ~20:40
>hours.  Still running.
>
>On ia64 [32G, 16cpu, 4 node], the system started going into softlockup
>after ~7 hours.  Stack trace [below] indicates zone-lru lock in
>__page_cache_release() called from put_page().  Either heavy contention
>or failure to unlock.  Note that previous run, with patches to
>putback_lru_page() and unmap_and_move(), the same load ran for ~18 hours
>before I shut it down to try these patches.
>
Thanks, then there are more troubles should be shooted down.


>I'm going to try again with the collected patches posted by Kosaki-san
>[for which, Thanks!].  If it occurs again, I'll deconfig the unevictable
>lru feature and see if I can reproduce it there.  It may be unrelated to
>the unevictable lru patches.
>
I hope so...Hmm..I'll dig tomorrow. 


>> 
>> > > @@ -240,6 +232,9 @@ static int __munlock_pte_handler(pte_t *
>> > >  	struct page *page;
>> > >  	pte_t pte;
>> > >  
>> > > +	/*
>> > > +	 * page is never be unmapped by page-reclaim. we lock this page now.
>> > > +	 */
>> > 
>> > I don't understand what you're trying to say here.  That is, what the
>> > point of this comment is...
>> > 
>> We access the page-table without taking pte_lock. But this vm is MLOCKED
>> and migration-race is handled. So we don't need to be too nervous to access
>> the pte. I'll consider more meaningful words.
>
>OK, so you just want to note that we're accessing the pte w/o locking
>and that this is safe because the vma has been VM_LOCKED and all pages
>should be mlocked?  
>
yes that was my thought.

>I'll note that the vma is NOT VM_LOCKED during the pte walk.
Ouch..
>munlock_vma_pages_range() resets it so that try_to_unlock(), called from
>munlock_vma_page(), won't try to re-mlock the page.  However, we hold
>the mmap sem for write, so faults are held off--no need to worry about a
>COW fault occurring between when the VM_LOCKED was cleared and before
>the page is munlocked. 
okay.

> If that could occur, it could open a window
>where a non-mlocked page is mapped in this vma, and page reclaim could
>potentially unmap the page.  Shouldn't be an issue as long as we never
>downgrade the semaphore to read during munlock.
>

Thank you for clarification. (so..will check Kosaki-san's one's comment later.
)


>
>Probably zone lru_lock in __page_cache_release().
>
> [<a0000001001264a0>] put_page+0x100/0x300
>                                sp=e0000741aaac7d50 bsp=e0000741aaac1280
> [<a000000100157170>] free_page_and_swap_cache+0x70/0xe0
>                                sp=e0000741aaac7d50 bsp=e0000741aaac1260
> [<a000000100145a10>] exit_mmap+0x3b0/0x580
>                                sp=e0000741aaac7d50 bsp=e0000741aaac1210
> [<a00000010008b420>] mmput+0x80/0x1c0
>                                sp=e0000741aaac7e10 bsp=e0000741aaac11d8
>
I think I have never seen this kind of dead-lock related to zone->lock.
(maybe it's because zone->lock is used in clear way historically)
I'll check around zone->lock. thanks.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
