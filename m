Date: Mon, 24 Nov 2008 12:29:54 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] memcg: memswap controller core swapcache fixes
In-Reply-To: <20081124151542.3c1a4c88.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0811241154130.11615@blonde.site>
References: <Pine.LNX.4.64.0811232151400.3748@blonde.site>
 <Pine.LNX.4.64.0811232156120.4142@blonde.site> <Pine.LNX.4.64.0811232208380.6437@blonde.site>
 <20081124144344.d2703a60.kamezawa.hiroyu@jp.fujitsu.com>
 <20081124151542.3c1a4c88.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 24 Nov 2008, KAMEZAWA Hiroyuki wrote:
> On Mon, 24 Nov 2008 14:43:44 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Sun, 23 Nov 2008 22:11:07 +0000 (GMT)
> > Hugh Dickins <hugh@veritas.com> wrote:
> > > +	/*
> > > +	 * A racing thread's fault, or swapoff, may have already updated
> > > +	 * the pte, and even removed page from swap cache: return success
> > > +	 * to go on to do_swap_page()'s pte_same() test, which should fail.
> > > +	 */
> > > +	if (!PageSwapCache(page))
> > > +		return 0;
> > > +
> > >  	ent.val = page_private(page);
> 
> I think 
> ==
> 	if (!PageSwapCache(page))
> 		goto charge_cur_mm;
> ==
> is better.
> 
> In following case,
> ==
> 	CPUA				CPUB
> 				    remove_from_swapcache
> 	lock_page()                 <==========================(*)
> 	try_charge_swapin()          
> 	....
> 	commit_charge()
> ==
> At (*), the page may be fully unmapped and not charged
> (and PCG_USED bit is cleared.)
> If so, returing without any charge here means leak of charge.
> 
> Even if *charged* here,
>   - mem_cgroup_cancel_charge_swapin (handles !pte_same() case.)
>   - mem_cgroup_commit_charge_swapin (handles page is doubly charged case.)
> 
> try-commit-cancel is introduced to handle this kind of case and bug in my code
> is accessing page->private without checking PageSwapCache().

I've not studied your charging regime at all, but I think either
my way or yours should work.

There shouldn't be a leak of charge with my patch, because CPUB cannot
remove the page from swapcache until all references to that swap have
been removed: so do_swap_page's (second) pte_same test will fail, and
it'll goto out_nomap.

With my patch, no charge was made, ptr was left NULL and no uncharge
will be made: it was easier for me to see that way.  Doing it your
way, ptr will be set and charged and there will be uncharging to do.

But your way does look better, given that above we've already done
	if (!do_swap_account)
		goto charge_cur_mm;
It looks rather suspicious to "return 0" in some cases after that.

Which of us should update the patch to Andrew?  I'd prefer you
to do it, since you understand the charging and uncharging,
but I can send it if you're busy.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
