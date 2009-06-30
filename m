Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CDE196B004D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 21:08:44 -0400 (EDT)
Date: Tue, 30 Jun 2009 09:08:56 +0800
From: Shaohua Li <shaohua.li@intel.com>
Subject: Re: + memory-hotplug-migrate-swap-cache-page.patch added to -mm
	tree
Message-ID: <20090630010856.GE21254@sli10-desk.sh.intel.com>
References: <200906291949.n5TJnwFx028865@imap1.linux-foundation.org> <alpine.DEB.1.10.0906291813260.21956@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0906291813260.21956@gentwo.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "mel@csn.ul.ie" <mel@csn.ul.ie>, "Zhao, Yakui" <yakui.zhao@intel.com>
List-ID: <linux-mm.kvack.org>

Sorry, last mail sent to wrong list.

On Tue, Jun 30, 2009 at 06:13:54AM +0800, Christoph Lameter wrote:
> When does this occur? From user space you are typically not able to get to
> pages that are not mapped into your address space.
migrate.c has comments about this. swap readahead will make this happen too.

Thanks,
Shaohua
> >
> > The patch titled
> >      memory hotplug: migrate swap cache page
> > has been added to the -mm tree.  Its filename is
> >      memory-hotplug-migrate-swap-cache-page.patch
> >
> > Before you just go and hit "reply", please:
> >    a) Consider who else should be cc'ed
> >    b) Prefer to cc a suitable mailing list as well
> >    c) Ideally: find the original patch on the mailing list and do a
> >       reply-to-all to that, adding suitable additional cc's
> >
> > *** Remember to use Documentation/SubmitChecklist when testing your code ***
> >
> > See http://userweb.kernel.org/~akpm/stuff/added-to-mm.txt to find
> > out what to do about this
> >
> > The current -mm tree may be found at http://userweb.kernel.org/~akpm/mmotm/
> >
> > ------------------------------------------------------
> > Subject: memory hotplug: migrate swap cache page
> > From: Shaohua Li <shaohua.li@intel.com>
> >
> > In test, some pages in swap-cache can't be migrated, as they aren't rmap.
> >
> > unmap_and_move() ignores swap-cache page which is just read in and hasn't
> > rmap (see the comments in the code), but swap_aops provides .migratepage.
> > Better to migrate such pages instead of ignore them.
> >
> > Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> > Cc: Mel Gorman <mel@csn.ul.ie>
> > Cc: Christoph Lameter <cl@linux-foundation.org>
> > Cc: Yakui Zhao <yakui.zhao@intel.com>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > ---
> >
> >  mm/migrate.c |    6 ++++--
> >  1 file changed, 4 insertions(+), 2 deletions(-)
> >
> > diff -puN mm/migrate.c~memory-hotplug-migrate-swap-cache-page mm/migrate.c
> > --- a/mm/migrate.c~memory-hotplug-migrate-swap-cache-page
> > +++ a/mm/migrate.c
> > @@ -147,7 +147,7 @@ out:
> >  static void remove_file_migration_ptes(struct page *old, struct page *new)
> >  {
> >  	struct vm_area_struct *vma;
> > -	struct address_space *mapping = page_mapping(new);
> > +	struct address_space *mapping = new->mapping;
> >  	struct prio_tree_iter iter;
> >  	pgoff_t pgoff = new->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
> >
> > @@ -664,13 +664,15 @@ static int unmap_and_move(new_page_t get
> >  			 *    needs to be effective.
> >  			 */
> >  			try_to_free_buffers(page);
> > +			goto rcu_unlock;
> >  		}
> > -		goto rcu_unlock;
> > +		goto skip_unmap;
> >  	}
> >
> >  	/* Establish migration ptes or remove ptes */
> >  	try_to_unmap(page, 1);
> >
> > +skip_unmap:
> >  	if (!page_mapped(page))
> >  		rc = move_to_new_page(newpage, page);
> >
> > _
> >
> > Patches currently in -mm which might be from shaohua.li@intel.com are
> >
> > linux-next.patch
> > memory-hotplug-update-zone-pcp-at-memory-online.patch
> > memory-hotplug-exclude-isolated-page-from-pco-page-alloc.patch
> > memory-hotplug-make-pages-from-movable-zone-always-isolatable.patch
> > memory-hotplug-alloc-page-from-other-node-in-memory-online.patch
> > memory-hotplug-migrate-swap-cache-page.patch
> >
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
