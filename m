Date: Wed, 5 Apr 2006 13:07:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC 5/6] Swapless V1: Rip out swap migration code
Message-Id: <20060405130747.6a0dd54f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0604042038370.31431@schroedinger.engr.sgi.com>
References: <20060404065739.24532.95451.sendpatchset@schroedinger.engr.sgi.com>
	<20060404065805.24532.65008.sendpatchset@schroedinger.engr.sgi.com>
	<20060404193714.2dfafa79.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0604040804560.26787@schroedinger.engr.sgi.com>
	<20060405100614.97d2e422.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0604041940390.28908@schroedinger.engr.sgi.com>
	<20060405123341.52145bf5.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0604042038370.31431@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, lee.schermerhorn@hp.com, lhms-devel@lists.sourceforge.net, taka@valinux.co.jp, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

On Tue, 4 Apr 2006 20:47:58 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:
> > When a page is converted into SWP_TYPE_MIGRATION, changed pte entry
> > implicitly points old page. This introduces the state 'a page is referred 
> > but no refcnt'. if mmap_sem is held, this is maybe no problem. 
> > but looks a bit dangerous.
> 
> We have increased the refcnt on the page (see isolate_lru_page()) and the 
> page is locked when  SWP_TYPE_MIGRATION is used. So there is a refcnt.
> 
yes. I just wrote about implicit refcnt.

> > > > I think adding SWP_TYPE_MIGRATION consideration to free_swap_and_cache() is
> > > > enough against anon_vma vanishing. Because remove_migration_ptes() compares 
> > > > old pte entry with old page's pfn, a page cannot be remapped into old place
> > > > when anon_vma has gone. This is my first impression.
> > > 
> > > However, the last process containing the page may terminate and free the 
> > > page, while we migrate. The SWAP_TYPE_MIGRATION pte will be rewoved 
> > > together with the anonvma if no lock is held on mmap_sem. 
> > yes. 
> > 
> > > Then remove_migration_ptes() cannot obtain a anon_vma. So it would break 
> > > without holding mmap_sem. We could fix this if we could somehow know that 
> > > the last process mapping the page vanished and skip 
> > > remove_migration_ptes().
> > > 
> > 
> > Hmm, I'm not sure but how about this way ?
> > 1. don't drop refcnt in try_to_unmap_one() when changing a page to 
> >    SWP_TYPE_MIGRATION. because it is referred. (rmap should be removed ?)
> 
> Then we would have a page with mapcounts but there are no real ptes 
> pointing to the page. It would be a strange condition for the page. 
> 
O.K. dropping mapcount is necessary. (migrate_page_remove_reference checks it, 
anyway)
refcnt mentioned above is page_count(page).

> Moreover, a process may fork or terminate while we migrate. Forking may 
> increase the refcnt and termination may decrease it. We do not keep
> refcnts for the SWP_TYPE_MIGRATION entry but rely on the reverse maps. So 
> we may end up with a messed up mapcount if we do not drop the refcnts.

At fork, copy_one_pte() can manage swap entry.
Adding SWP_TYPE_MIGRATION consideration there is necessary and enough if 
not holding mmap_sem. Hmm...maybe.

exit is the same case as zap_page_range(). modifing swap_entry_free() will be
necessary.

-Kame









--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
