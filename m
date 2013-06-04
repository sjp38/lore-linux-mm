Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id C5A9A6B0031
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 10:02:31 -0400 (EDT)
Date: Tue, 4 Jun 2013 16:02:30 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Handling NUMA page migration
Message-ID: <20130604140230.GB31247@dhcp22.suse.cz>
References: <201306040922.10235.frank.mehnert@oracle.com>
 <20130604115807.GF3672@sgi.com>
 <201306041414.52237.frank.mehnert@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201306041414.52237.frank.mehnert@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frank Mehnert <frank.mehnert@oracle.com>
Cc: Robin Holt <holt@sgi.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

On Tue 04-06-13 14:14:45, Frank Mehnert wrote:
> On Tuesday 04 June 2013 13:58:07 Robin Holt wrote:
> > This is probably more appropriate to be directed at the linux-mm
> > mailing list.
> > 
> > On Tue, Jun 04, 2013 at 09:22:10AM +0200, Frank Mehnert wrote:
> > > Hi,
> > > 
> > > our memory management on Linux hosts conflicts with NUMA page migration.
> > > I assume this problem existed for a longer time but Linux 3.8 introduced
> > > automatic NUMA page balancing which makes the problem visible on
> > > multi-node hosts leading to kernel oopses.
> > > 
> > > NUMA page migration means that the physical address of a page changes.
> > > This is fatal if the application assumes that this never happens for
> > > that page as it was supposed to be pinned.
> > > 
> > > We have two kind of pinned memory:
> > > 
> > > A) 1. allocate memory in userland with mmap()
> > > 
> > >    2. madvise(MADV_DONTFORK)
> > >    3. pin with get_user_pages().
> > >    4. flush dcache_page()
> > >    5. vm_flags |= (VM_DONTCOPY | VM_LOCKED)
> > >    
> > >       (resulting flags are VM_MIXEDMAP | VM_DONTDUMP | VM_DONTEXPAND |
> > >       
> > >        VM_DONTCOPY | VM_LOCKED | 0xff)
> > 
> > I don't think this type of allocation should be affected.  The
> > get_user_pages() call should elevate the pages reference count which
> > should prevent migration from completing.  I would, however, wait for
> > a more definitive answer.
> 
> Thanks Robin! Actually case B) is more important for us so I'm waiting
> for more feedback :)

The manual node migration code seems to be OK in case B as well because
Reserved are skipped (check check_pte_range called from down the
do_migrate_pages path).

Maybe auto-numa code is missing this check assuming that it cannot
encounter reserved pages.

migrate_misplaced_page relies on numamigrate_isolate_page which relies
on isolate_lru_page and that one expects a LRU page. Is your Reserved
page on the LRU list? That would be a bit unexpected.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
