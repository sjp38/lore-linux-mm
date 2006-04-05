Date: Wed, 5 Apr 2006 12:33:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC 5/6] Swapless V1: Rip out swap migration code
Message-Id: <20060405123341.52145bf5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0604041940390.28908@schroedinger.engr.sgi.com>
References: <20060404065739.24532.95451.sendpatchset@schroedinger.engr.sgi.com>
	<20060404065805.24532.65008.sendpatchset@schroedinger.engr.sgi.com>
	<20060404193714.2dfafa79.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0604040804560.26787@schroedinger.engr.sgi.com>
	<20060405100614.97d2e422.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0604041940390.28908@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, lee.schermerhorn@hp.com, lhms-devel@lists.sourceforge.net, taka@valinux.co.jp, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

On Tue, 4 Apr 2006 19:45:49 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> > My concern is refcnt handling of SWP_TYPE_MIGRATION pages, but maybe no problem.
> 
> What are the exact concerns?
> 
When a page is converted into SWP_TYPE_MIGRATION, changed pte entry
implicitly points old page. This introduces the state 'a page is referred 
but no refcnt'. if mmap_sem is held, this is maybe no problem. 
but looks a bit dangerous.


> On Wed, 5 Apr 2006, KAMEZAWA Hiroyuki wrote:
> 
> > I think adding SWP_TYPE_MIGRATION consideration to free_swap_and_cache() is
> > enough against anon_vma vanishing. Because remove_migration_ptes() compares 
> > old pte entry with old page's pfn, a page cannot be remapped into old place
> > when anon_vma has gone. This is my first impression.
> 
> However, the last process containing the page may terminate and free the 
> page, while we migrate. The SWAP_TYPE_MIGRATION pte will be rewoved 
> together with the anonvma if no lock is held on mmap_sem. 
yes. 

> Then remove_migration_ptes() cannot obtain a anon_vma. So it would break 
> without holding mmap_sem. We could fix this if we could somehow know that 
> the last process mapping the page vanished and skip 
> remove_migration_ptes().
> 

Hmm, I'm not sure but how about this way ?
1. don't drop refcnt in try_to_unmap_one() when changing a page to 
   SWP_TYPE_MIGRATION. because it is referred. (rmap should be removed ?)
2. drop refcnt of the old page and inc refcnt of the new page in 
   remove_migration_ptes()

like this.
==
in remove_migration_pte
+	ptep = page_check_address(old, mm, addr, &ptl);
+	if (!ptep)
+		return;
+
+	get_page(new);
+	set_pte_at(mm, addr, ptep, pte_mkold(mk_pte(new, vma->vm_page_prot)));
+	page_add_anon_rmap(new, vma, addr);

+ put_page(old); << add this

We can check old page's refcnt in remove_migration_ptes().
if page_count(oldpage)==1, this page's anon_vma is removed.
So we don't have to modify ptes, all of them are zapped..
(In this method, page's refcnt should be dropped when swp_entry
 for SWP_TYPE_MIGRATION is freed.)

In page unmapping, each page's refcnt is dropped before zapping anon_vma.
So, I think this can work.

> 
> > Note: unuse_vma() doesn't check what pte entry contains.
> 
> unuse_vma() relies on the mapping via swap space that will no longer exist 
> with the new code.
> 
Yes. I know. just wrote about old code. sorry.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
