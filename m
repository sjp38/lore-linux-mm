Date: Wed, 20 Feb 2008 04:14:58 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
In-Reply-To: <20080220100333.a014083c.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0802200355220.3569@blonde.site>
References: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0802191449490.6254@blonde.site>
 <20080220100333.a014083c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "riel@redhat.com" <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 20 Feb 2008, KAMEZAWA Hiroyuki wrote:
> On Tue, 19 Feb 2008 15:40:45 +0000 (GMT)
> Hugh Dickins <hugh@veritas.com> wrote:
> 
> > A lot in common with yours, a lot not.  (And none of it addressing
> > that issue of opt-out I raise in the last paragraph: haven't begun
> > to go into that one, hoped you and Balbir would look into it.)
> > 
> I have some trial patches for reducing atomic_ops by do_it_lazy method.
> Now, I'm afraid that performence is too bad when there is *no* memory
> pressure.

But it isn't just the atomic ops, it's the whole business of
mem_cgroup_charge_common plus mem_cgroup_uncharge_page per page.

The existence of force_empty indicates that the system can get along
without the charge on the page.  What's needed, I think, is something
in struct mm, a flag or a reserved value in mm->mem_cgroup, to say
don't do any of this mem_cgroup stuff on me; and a cgroup fs interface
to set that, in the same way as force_empty is done.

> > I haven't completed my solution in mem_cgroup_move_lists yet: but
> > the way it wants a lock in a structure which isn't stabilized until
> > it's got that lock, reminds me very much of my page_lock_anon_vma,
> > so I'm expecting to use a SLAB_DESTROY_BY_RCU cache there.
> > 
> 
> IMHO, because tons of page_cgroup can be freed at once, we need some good
> idea for reducing RCU's GC work to do that.

That's a good point that hadn't yet crossed my mind, but it may not
be relevant.  It's not the struct page_cgroups that would need to go
into a SLAB_DESTROY_BY_RCU slab, but the struct mem_cgroups.

> 
> > Ha, you have lock_page_cgroup in your mem_cgroup_move_lists: yes,
> > tried that too, and it deadlocks: someone holding lock_page_cgroup
> > can be interrupted by an end of I/O interrupt which does
> > rotate_reclaimable_page and wants the main lru_lock, but that
> > main lru_lock is held across mem_cgroup_move_lists.  There are
> > several different ways to address that, but for this release I
> > think we just go for a try_lock_page_cgroup there.
> > 
> Hm, I'd like to remove mem_cgroup_move_lists if possible ;(
> (But its result will be bad LRU ordering.)

I'm not sure if you're actually proposing to revert all that, or just
expressing regret at the difficulty it introduces.  I'll assume the
latter: certainly I'm not arguing for such a large reversion.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
