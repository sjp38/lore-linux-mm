Date: Mon, 27 Feb 2006 07:55:02 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: page_lock_anon_vma(): remove check for mapped page
In-Reply-To: <Pine.LNX.4.61.0602261558370.13368@goblin.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0602270748280.2419@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0602241658030.24668@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602251400520.7164@goblin.wat.veritas.com>
 <Pine.LNX.4.61.0602260359080.9682@goblin.wat.veritas.com>
 <Pine.LNX.4.64.0602252152500.29338@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602261558370.13368@goblin.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 26 Feb 2006, Hugh Dickins wrote:

> On Sat, 25 Feb 2006, Christoph Lameter wrote:
> > Here is the parameterization you wanted. However, I am still not sure
> > that a check for a valid mapping here is sufficient if the caller has no
> > other means to guarantee that the mapping is not vanishing.
> > 
> > If the mapping is removed after the check for the mapping was done then
> > we still have a problem.
> > 
> > Or is there some way that RCU can preserve the existence of an anonymous 
> > vma?
> > 
> > Cannot imagine how that would work. If an rcu free was done on the 
> > anonymous vma then it may vanish anytime after page_lock_anon_vma does a 
> > rcu unlock. And then we are holding a lock that is located in free 
> > space...... 
> 
> Please see comments on SLAB_DESTROY_BY_RCU in mm/slab.c: that's why the
> anon_vma cache is created with that flag, that's why page_lock_anon_vma
> uses rcu_read_lock.  Your patch, with more appropriate comments and my
> signoff added, below (but, in case there's any doubt, it's not suitable
> for 2.6.16 - the change itself is simple, but it suddenly makes the
> hitherto untried codepaths of remove_from_swap accessible).

At least my tests show that this codepath is valid and its for new 
functionality in 2.6.16. So I guess its suitable for 2.6.16.

I doubt that RCU can help if the anon_vma is removed after the check for 
page_mapped. In that case RCU prevents the ultimate free from happening 
until rcu_read_unlock. So in essence we lock the anon_vma, return a 
pointer to the anonymous vma and then free the anon_vma? Functions calling 
page_lock_anon_vma may operate on freed memory due to this race.

Should we not check again for page_mapped after taking the lock?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
