Date: Mon, 27 Feb 2006 16:32:11 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: page_lock_anon_vma(): remove check for mapped page
In-Reply-To: <Pine.LNX.4.64.0602270748280.2419@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.61.0602271608510.8280@goblin.wat.veritas.com>
References: <Pine.LNX.4.64.0602241658030.24668@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602251400520.7164@goblin.wat.veritas.com>
 <Pine.LNX.4.61.0602260359080.9682@goblin.wat.veritas.com>
 <Pine.LNX.4.64.0602252152500.29338@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602261558370.13368@goblin.wat.veritas.com>
 <Pine.LNX.4.64.0602270748280.2419@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Thanks for pointing me to the fs use of buffer_migrate_page in other mail.

On Mon, 27 Feb 2006, Christoph Lameter wrote:
> On Sun, 26 Feb 2006, Hugh Dickins wrote:
> > 
> > Please see comments on SLAB_DESTROY_BY_RCU in mm/slab.c: that's why the
> > anon_vma cache is created with that flag, that's why page_lock_anon_vma
> > uses rcu_read_lock.  Your patch, with more appropriate comments and my
> > signoff added, below (but, in case there's any doubt, it's not suitable
> > for 2.6.16 - the change itself is simple, but it suddenly makes the
> > hitherto untried codepaths of remove_from_swap accessible).
> 
> At least my tests show that this codepath is valid and its for new 
> functionality in 2.6.16. So I guess its suitable for 2.6.16.

Well, it's certainly not for me to decide: I just didn't want my signoff
to be interpreted as a request to push it into 2.6.16.  It seemed to me
rather late to be enabling this new functionality in 2.6.16, even though
it's a bug that it wasn't already enabled in 2.6.16-rc: you'll have to
argue that one without me.  Perhaps it doesn't matter if the vast
majority have CONFIG_MIGRATION configured off.

> I doubt that RCU can help if the anon_vma is removed after the check for 
> page_mapped. In that case RCU prevents the ultimate free from happening 
> until rcu_read_unlock. So in essence we lock the anon_vma, return a 
> pointer to the anonymous vma and then free the anon_vma? Functions calling 
> page_lock_anon_vma may operate on freed memory due to this race.

I'm not sure that I've understood your doubt correctly.  But I think
you're missing that rcu_read_lock is just another name for preempt_disable,
plus we always disable preemption when taking a spin lock: so in effect
we have rcu_read_lock in force until the spin_unlock(&anon_vma->lock).

> Should we not check again for page_mapped after taking the lock?

There's no need to.  But it certainly requires that the functions we go
on to call (page_referenced_one, try_to_unmap_one, remove_vma_swap) act
in the way they do, checking ptes for a match with page or swap entry:
would be dangerous if they ever assumed a match without looking.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
