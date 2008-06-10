Date: Tue, 10 Jun 2008 05:31:30 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH -mm 17/25] Mlocked Pages are non-reclaimable
Message-ID: <20080610033130.GK19404@wotan.suse.de>
References: <20080606202838.390050172@redhat.com> <20080606202859.522708682@redhat.com> <20080606180746.6c2b5288.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080606180746.6c2b5288.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, Jun 06, 2008 at 06:07:46PM -0700, Andrew Morton wrote:
> On Fri, 06 Jun 2008 16:28:55 -0400
> Rik van Riel <riel@redhat.com> wrote:
> 
> > Originally
> > From: Nick Piggin <npiggin@suse.de>
> > 
> > Against:  2.6.26-rc2-mm1
> > 
> > This patch:
> > 
> > 1) defines the [CONFIG_]NORECLAIM_MLOCK sub-option and the
> >    stub version of the mlock/noreclaim APIs when it's
> >    not configured.  Depends on [CONFIG_]NORECLAIM_LRU.
> 
> Oh sob.
> 
> akpm:/usr/src/25> find . -name '*.[ch]' | xargs grep CONFIG_NORECLAIM | wc -l
> 51
> 
> why oh why?  Must we really really do this to ourselves?  Cheerfully
> unchangeloggedly?
> 
> > 2) add yet another page flag--PG_mlocked--to indicate that
> >    the page is locked for efficient testing in vmscan and,
> >    optionally, fault path.  This allows early culling of
> >    nonreclaimable pages, preventing them from getting to
> >    page_referenced()/try_to_unmap().  Also allows separate
> >    accounting of mlock'd pages, as Nick's original patch
> >    did.
> > 
> >    Note:  Nick's original mlock patch used a PG_mlocked
> >    flag.  I had removed this in favor of the PG_noreclaim
> >    flag + an mlock_count [new page struct member].  I
> >    restored the PG_mlocked flag to eliminate the new
> >    count field.  
> 
> How many page flags are left?  I keep on asking this and I end up
> either a) not being told or b) forgetting.  I thought that we had
> a whopping big comment somewhere which describes how all these
> flags are allocated but I can't immediately locate it.
> 
> > 3) add the mlock/noreclaim infrastructure to mm/mlock.c,
> >    with internal APIs in mm/internal.h.  This is a rework
> >    of Nick's original patch to these files, taking into
> >    account that mlocked pages are now kept on noreclaim
> >    LRU list.
> > 
> > 4) update vmscan.c:page_reclaimable() to check PageMlocked()
> >    and, if vma passed in, the vm_flags.  Note that the vma
> >    will only be passed in for new pages in the fault path;
> >    and then only if the "cull nonreclaimable pages in fault
> >    path" patch is included.
> > 
> > 5) add try_to_unlock() to rmap.c to walk a page's rmap and
> >    ClearPageMlocked() if no other vmas have it mlocked.  
> >    Reuses as much of try_to_unmap() as possible.  This
> >    effectively replaces the use of one of the lru list links
> >    as an mlock count.  If this mechanism let's pages in mlocked
> >    vmas leak through w/o PG_mlocked set [I don't know that it
> >    does], we should catch them later in try_to_unmap().  One
> >    hopes this will be rare, as it will be relatively expensive.
> > 
> > 6) Kosaki:  added munlock page table walk to avoid using
> >    get_user_pages() for unlock.  get_user_pages() is unreliable
> >    for some vma protections.
> >    Lee:  modified to wait for in-flight migration to complete
> >    to close munlock/migration race that could strand pages.
> 
> None of which is available on 32-bit machines.  That's pretty significant.

It should definitely be enabled for 32-bit machines, and enabled by default.
The argument is that 32 bit machines won't have much memory so it won't
be a problem, but a) it also has to work well on other machines without
much memory, and b) it is a nightmare to have significant behaviour changes
like this. For kernel development as well as kernel running.

If we eventually run out of page flags on 32 bit, then sure this might be
one we could look at geting rid of. Once the code has proven itself.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
