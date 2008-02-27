Date: Wed, 27 Feb 2008 13:23:00 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 05/15] memcg: fix VM_BUG_ON from page migration
In-Reply-To: <20080227055211.GB2317@balbir.in.ibm.com>
Message-ID: <Pine.LNX.4.64.0802271257540.8683@blonde.site>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
 <Pine.LNX.4.64.0802252338080.27067@blonde.site> <20080227055211.GB2317@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 27 Feb 2008, Balbir Singh wrote:
> * Hugh Dickins <hugh@veritas.com> [2008-02-25 23:39:23]:
> 
> > Page migration gave me free_hot_cold_page's VM_BUG_ON page->page_cgroup.
> > remove_migration_pte was calling mem_cgroup_charge on the new page whenever
> > it found a swap pte, before it had determined it to be a migration entry.
> > That left a surplus reference count on the page_cgroup, so it was still
> > attached when the page was later freed.
> > 
> > Move that mem_cgroup_charge down to where we're sure it's a migration entry.
> > We were already under i_mmap_lock or anon_vma->lock, so its GFP_KERNEL was
> > already inappropriate: change that to GFP_ATOMIC.
> >
> 
> One side effect I see of this patch is that the page_cgroup lock and
> the lru_lock can now be taken from within i_mmap_lock or
> anon_vma->lock.

That's not a side-effect of this patch, but it is something which was
already being done there, and you're absolutely right to draw attention
to it, thank you.

Although I mentioned they were held in the comment, it hadn't really
dawned on me how unwelcome that is: it's not a violation, and lockdep
doesn't protest, but we'd all be happier not to interweave those
otherwise independent locks in that one place.

Oh, hold on, no, it's not that one place.  It's a well-established
nesting of locks, as when mem_cgroup_uncharge_page is called by
page_remove_rmap from try_to_unmap_one.  Panic over!  But we'd
better add memcontrol's locks to the hierarchies shown in
filemap.c and in rmap.c.

> > -	if (mem_cgroup_charge(new, mm, GFP_KERNEL)) {
> > -		pte_unmap(ptep);
> > -		return;
> > -	}
> > -
> >   	ptl = pte_lockptr(mm, pmd);
> >   	spin_lock(ptl);
> >  	pte = *ptep;
> > @@ -169,6 +164,20 @@ static void remove_migration_pte(struct 
> >  	if (!is_migration_entry(entry) || migration_entry_to_page(entry) != old)
> >  		goto out;
> 
> Is it not easier to uncharge here then to move to the charging to the
> context below? Do you suspect this will be a common operation (so we
> might end up charging/uncharing more frequently?)

In what way would it be easier to charge too early, then uncharge
when we find it was wrong, than simply to charge once we know it's
right, as the patch does?

If we were not already in atomic context, it would definitely be
better to do it the way you suggest, with GFP_KERNEL not GFP_ATOMIC;
but we're already in atomic context, so I cannot see any advantage
to doing it your way.

What would be a real improvement is a way of doing it outside the
atomic context: I've given that little thought, but it's not obvious
how.  And really the wider issue of force_empty inconsistencies is
more important than this singular wart in page migration.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
