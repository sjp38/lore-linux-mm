Date: Fri, 12 May 2006 09:56:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Status and the future of page migration
Message-Id: <20060512095614.7f3d2047.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0605111703020.17098@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0605111703020.17098@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, ak@suse.de, pj@sgi.com, kravetz@us.ibm.com, marcelo.tosatti@cyclades.com, taka@valinux.co.jp, lee.schermerhorn@hp.com, haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Thu, 11 May 2006 17:06:31 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:
> Some additional patches for page migration are at
> ftp://ftp.kernel.org/pub/linux/kernel/people/christoph/pmig/patches-2.6.17-rc3-mm1/.
> These are in testing and need work. Feedback on these would be useful.
> 
Thank you for clarification and, of course, your works.

> 1. Restructure migrate_pages() so that the current goto mess is avoided. This
>    extracts two functions from migrate pages that deal with either taking the
>    page lock for the source or destination page.
> 
> 2. Dispose of migrated pages immediately. Moves the recycling of migrated
>    pages into migrate_pages(). Callers only have to deal with pages that
>    are still candidates for still could be repeated. This simplifies handling
>    but prevents potential necessary post processing of migrated pages.
>    Should we do this at all?
> 
I don't think this is necessary now.
Some codes may be going to use migrated pages, I think. For example, migrating
pages to create Hugepage size contigous pages. But this will not come in near
future ;)

> 3. Uses arrays to pass list of pages to migrate_pages().
>    Doing so will make a 1-1 association possible between the pages to be
>    migrated. If we have this 1-1 association then we can accurately allocate
>    pages for MPOL_INTERLEAVE during migration. Specifying
>    MPOL_INTERLEAVE|MPOL_MF_MOVE to mbind() could move all pages so that they
>    follow the best interleave pattern accurately.
> 
I like this. 

> 4. A new system call for the migration of lists of pages (incomplete
>    implementation!)
> 
>    sys_move_pages([int pid,?] int nr_pages, unsigned long *addresses,
>    		int *nodes, unsigned int flags);
> 
>    This function would migrate individual pages of a process to specific nodes.
>    F.e. user space tools exist that can provide off node access statistics
>    that show from what node a pages is most frequently accessed.
>    Additional code could then use this new system call to migrate the lists
>    of pages to the more advantageous location. Automatic page migration
>    could be implemented in user space. Many of us remain unconvinced that
>    automatic page migration can provide a consistent benefit.
>    This API would allow the implementation of various automatic migration
>    methods without changes to the kernel.
> 
Maybe implementing the interface to show necessary information to do this is
necessary before doing this. A user process can get enough precise information now ?


> 5. vma migration hooks
>    Adds a new function call "migrate" to the vm_operations structure. The
>    vm_ops migration method may be used by vmas without page structs (PFN_MAP?)
>    to implement their own migration schemes. Currently there is no user of
>    such functionality. The uncached allocator for IA64 could potentially use
>    such vma migration hooks.
> 
uncached allocator doesn't use struct address_space ?

> Potential future work:
> 
> - Implement the migration of mlocked pages. This would mean to ignore
>   VM_LOCKED in try_to_unmap. Currently VM_LOCKED can be used to prevent the
>   migration of pages. If we allow the migration of mlocked pages then we
>   would need to introduce some alternate means of being able to declare a
>   page not migratable (VM_DONTMIGRATE?).
>   Not sure if this should be done at all.
> 
I think VM_LOCKED just means the address has the physical page. So I think
migration is Okay. But I don't think VM_DONTMIGRATE is necessary..

> - Migration of pages outside of a process context.
>   Currently page migration requires that a read lock on mmap_sem is held to
>   prevent the anonymous vmas from vanishing while we migrate pages.
>   If page migration would be used to remove all pages from a zone (like needed
>   by the memory hotplug project) then we would need to first find a way
>   to insure that the anon_vmas do not vanish under us.
>   We could f.e. take a read_lock on the one of the mm_structs that may be
>   discovered via the reverse maps.
> 
I think taking anon_vma->lock while migration is one way. But this will make
try_to_umap() dirtier...

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
