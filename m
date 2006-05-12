Date: Thu, 11 May 2006 18:06:20 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Status and the future of page migration
In-Reply-To: <20060512095614.7f3d2047.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0605111758400.17334@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0605111703020.17098@schroedinger.engr.sgi.com>
 <20060512095614.7f3d2047.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, ak@suse.de, pj@sgi.com, kravetz@us.ibm.com, marcelo.tosatti@cyclades.com, taka@valinux.co.jp, lee.schermerhorn@hp.com, haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Fri, 12 May 2006, KAMEZAWA Hiroyuki wrote:

> > 4. A new system call for the migration of lists of pages (incomplete
> >    implementation!)
> > 
> >    sys_move_pages([int pid,?] int nr_pages, unsigned long *addresses,
> >    		int *nodes, unsigned int flags);
> > 
> >    This function would migrate individual pages of a process to specific nodes.
> >    F.e. user space tools exist that can provide off node access statistics
> >    that show from what node a pages is most frequently accessed.
> >    Additional code could then use this new system call to migrate the lists
> >    of pages to the more advantageous location. Automatic page migration
> >    could be implemented in user space. Many of us remain unconvinced that
> >    automatic page migration can provide a consistent benefit.
> >    This API would allow the implementation of various automatic migration
> >    methods without changes to the kernel.
> > 
> Maybe implementing the interface to show necessary information to do this is
> necessary before doing this. A user process can get enough precise information now ?

What precise information would be needed? We could return the current node 
information in a status array. Right I forgot to include the status array 
that returns success / or failure of the call. The status array would 
allow to find out the failure reason for each page.

> > 5. vma migration hooks
> >    Adds a new function call "migrate" to the vm_operations structure. The
> >    vm_ops migration method may be used by vmas without page structs (PFN_MAP?)
> >    to implement their own migration schemes. Currently there is no user of
> >    such functionality. The uncached allocator for IA64 could potentially use
> >    such vma migration hooks.
> > 
> uncached allocator doesn't use struct address_space ?

Right.

> > - Implement the migration of mlocked pages. This would mean to ignore
> >   VM_LOCKED in try_to_unmap. Currently VM_LOCKED can be used to prevent the
> >   migration of pages. If we allow the migration of mlocked pages then we
> >   would need to introduce some alternate means of being able to declare a
> >   page not migratable (VM_DONTMIGRATE?).
> >   Not sure if this should be done at all.
> > 
> I think VM_LOCKED just means the address has the physical page. So I think
> migration is Okay. But I don't think VM_DONTMIGRATE is necessary..

You are right but there may be system components (such as device drivers) 
that require the page not to be moved. Without page migration VM_LOCKED 
implies that the physical address stays the same. Kernel code may assume 
that VM_LOCKED -> dont migrate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
