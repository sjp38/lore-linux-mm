Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 2B69B6B006C
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 04:58:38 -0400 (EDT)
Date: Tue, 3 Jul 2012 09:58:31 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/12] Swap-over-NFS without deadlocking V8
Message-ID: <20120703085831.GY14154@suse.de>
References: <1340976805-5799-1-git-send-email-mgorman@suse.de>
 <20120701172254.GB2470@mgebm.net>
 <20120702143556.GT14154@suse.de>
 <20120703001051.GA5508@mgebm.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120703001051.GA5508@mgebm.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@mgebm.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Sebastian Andrzej Siewior <sebastian@breakpoint.cc>

On Mon, Jul 02, 2012 at 08:10:51PM -0400, Eric B Munson wrote:
> On Mon, 02 Jul 2012, Mel Gorman wrote:
> 
> > On Sun, Jul 01, 2012 at 01:22:54PM -0400, Eric B Munson wrote:
> > > On Fri, 29 Jun 2012, Mel Gorman wrote:
> > > 
> > > > Changelog since V7
> > > >   o Rebase to linux-next 20120629
> > > >   o bi->page_dma instead of bi->page in intel driver
> > > >   o Build fix for !CONFIG_NET					(sebastian)
> > > >   o Restore PF_MEMALLOC flags correctly in all cases		(jlayton)
> > > > 
> > > > Changelog since V6
> > > >   o Rebase to linux-next 20120622
> > > > 
> > > > Changelog since V5
> > > >   o Rebase to v3.5-rc3
> > > > 
> > > > Changelog since V4
> > > >   o Catch if SOCK_MEMALLOC flag is cleared with rmem tokens	(davem)
> > > > 
> > > > Changelog since V3
> > > >   o Rebase to 3.4-rc5
> > > >   o kmap pages for writing to swap				(akpm)
> > > >   o Move forward declaration to reduce chance of duplication	(akpm)
> > > > 
> > > > Changelog since V2
> > > >   o Nothing significant, just rebases. A radix tree lookup is replaced with
> > > >     a linear search would be the biggest rebase artifact
> > > > 
> > > > This patch series is based on top of "Swap-over-NBD without deadlocking v14"
> > > > as it depends on the same reservation of PF_MEMALLOC reserves logic.
> > > > 
> > > > When a user or administrator requires swap for their application, they
> > > > create a swap partition and file, format it with mkswap and activate it with
> > > > swapon. In diskless systems this is not an option so if swap if required
> > > > then swapping over the network is considered.  The two likely scenarios
> > > > are when blade servers are used as part of a cluster where the form factor
> > > > or maintenance costs do not allow the use of disks and thin clients.
> > > > 
> > > > The Linux Terminal Server Project recommends the use of the Network
> > > > Block Device (NBD) for swap but this is not always an option.  There is
> > > > no guarantee that the network attached storage (NAS) device is running
> > > > Linux or supports NBD. However, it is likely that it supports NFS so there
> > > > are users that want support for swapping over NFS despite any performance
> > > > concern. Some distributions currently carry patches that support swapping
> > > > over NFS but it would be preferable to support it in the mainline kernel.
> > > > 
> > > > Patch 1 avoids a stream-specific deadlock that potentially affects TCP.
> > > > 
> > > > Patch 2 is a small modification to SELinux to avoid using PFMEMALLOC
> > > > 	reserves.
> > > > 
> > > > Patch 3 adds three helpers for filesystems to handle swap cache pages.
> > > > 	For example, page_file_mapping() returns page->mapping for
> > > > 	file-backed pages and the address_space of the underlying
> > > > 	swap file for swap cache pages.
> > > > 
> > > > Patch 4 adds two address_space_operations to allow a filesystem
> > > > 	to pin all metadata relevant to a swapfile in memory. Upon
> > > > 	successful activation, the swapfile is marked SWP_FILE and
> > > > 	the address space operation ->direct_IO is used for writing
> > > > 	and ->readpage for reading in swap pages.
> > > > 
> > > > Patch 5 notes that patch 3 is bolting
> > > > 	filesystem-specific-swapfile-support onto the side and that
> > > > 	the default handlers have different information to what
> > > > 	is available to the filesystem. This patch refactors the
> > > > 	code so that there are generic handlers for each of the new
> > > > 	address_space operations.
> > > > 
> > > > Patch 6 adds an API to allow a vector of kernel addresses to be
> > > > 	translated to struct pages and pinned for IO.
> > > > 
> > > > Patch 7 adds support for using highmem pages for swap by kmapping
> > > > 	the pages before calling the direct_IO handler.
> > > > 
> > > > Patch 8 updates NFS to use the helpers from patch 3 where necessary.
> > > > 
> > > > Patch 9 avoids setting PF_private on PG_swapcache pages within NFS.
> > > > 
> > > > Patch 10 implements the new swapfile-related address_space operations
> > > > 	for NFS and teaches the direct IO handler how to manage
> > > > 	kernel addresses.
> > > > 
> > > > Patch 11 prevents page allocator recursions in NFS by using GFP_NOIO
> > > > 	where appropriate.
> > > > 
> > > > Patch 12 fixes a NULL pointer dereference that occurs when using
> > > > 	swap-over-NFS.
> > > > 
> > > > With the patches applied, it is possible to mount a swapfile that is on an
> > > > NFS filesystem. Swap performance is not great with a swap stress test taking
> > > > roughly twice as long to complete than if the swap device was backed by NBD.
> > > 
> > > To test this set I am using memory cgroups to force swap usage.  I am seeing
> > > the cgroup controller killing my processes instead of using the nfs swapfile.
> > > 
> > 
> > How sure are you that this is not a cgroup bug? For dirty file data on some
> > kernels, cgroups can prematurely kill processes if pages are not being
> > cleaned fast enough. I would not expect the same problem for anonymous
> > pages but it's worth considering. Please also test with a normal swapfile.
> > 
> > If OOM is disabled and the process hangs, try capturing a sysrq+t and
> > see where the process is stuck.
> > 
> 
> It looks like the problem is with cgroups, when I run without cgroups and limit
> memory on the boot command line everything works fine.  To test I limited the
> machine to 1G of ram then ran several memory benchmarks with work set sizes of
> 1.5G, all completed successfully with my swap file located on an NFS share.
> 
> Tested-by: Eric B Munson <emunson@mgebm.net>

Thanks a lot for testing.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
