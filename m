From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 0/5] hugetlb: add support gigantic page allocation at
 runtime
Date: Fri, 11 Apr 2014 15:08:40 +0300
Message-ID: <20140411120840.GA27458@node.dhcp.inet.fi>
References: <1397152725-20990-1-git-send-email-lcapitulino@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1397152725-20990-1-git-send-email-lcapitulino@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mtosatti@redhat.com, aarcange@redhat.com, mgorman@suse.de, akpm@linux-foundation.org, andi@firstfloor.org, davidlohr@hp.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, riel@redhat.com, n-horiguchi@ah.jp.nec.com
List-Id: linux-mm.kvack.org

On Thu, Apr 10, 2014 at 01:58:40PM -0400, Luiz Capitulino wrote:
> [Full introduction right after the changelog]
> 
> Changelog
> ---------
> 
> v3
> 
> - Dropped unnecessary WARN_ON() call [Kirill]
> - Always check if the pfn range lies within a zone [Yasuaki]
> - Renamed some function arguments for consistency
> 
> v2
> 
> - Rewrote allocation loop to avoid scanning unless PFNs [Yasuaki]
> - Dropped incomplete multi-arch support [Naoya]
> - Added patch to drop __init from prep_compound_gigantic_page()
> - Restricted the feature to x86_64 (more details in patch 5/5)
> - Added review-bys plus minor changelog changes
> 
> Introduction
> ------------
> 
> The HugeTLB subsystem uses the buddy allocator to allocate hugepages during
> runtime. This means that hugepages allocation during runtime is limited to
> MAX_ORDER order. For archs supporting gigantic pages (that is, page sizes
> greater than MAX_ORDER), this in turn means that those pages can't be
> allocated at runtime.
> 
> HugeTLB supports gigantic page allocation during boottime, via the boot
> allocator. To this end the kernel provides the command-line options
> hugepagesz= and hugepages=, which can be used to instruct the kernel to
> allocate N gigantic pages during boot.
> 
> For example, x86_64 supports 2M and 1G hugepages, but only 2M hugepages can
> be allocated and freed at runtime. If one wants to allocate 1G gigantic pages,
> this has to be done at boot via the hugepagesz= and hugepages= command-line
> options.
> 
> Now, gigantic page allocation at boottime has two serious problems:
> 
>  1. Boottime allocation is not NUMA aware. On a NUMA machine the kernel
>     evenly distributes boottime allocated hugepages among nodes.
> 
>     For example, suppose you have a four-node NUMA machine and want
>     to allocate four 1G gigantic pages at boottime. The kernel will
>     allocate one gigantic page per node.
> 
>     On the other hand, we do have users who want to be able to specify
>     which NUMA node gigantic pages should allocated from. So that they
>     can place virtual machines on a specific NUMA node.
> 
>  2. Gigantic pages allocated at boottime can't be freed
> 
> At this point it's important to observe that regular hugepages allocated
> at runtime don't have those problems. This is so because HugeTLB interface
> for runtime allocation in sysfs supports NUMA and runtime allocated pages
> can be freed just fine via the buddy allocator.
> 
> This series adds support for allocating gigantic pages at runtime. It does
> so by allocating gigantic pages via CMA instead of the buddy allocator.
> Releasing gigantic pages is also supported via CMA. As this series builds
> on top of the existing HugeTLB interface, it makes gigantic page allocation
> and releasing just like regular sized hugepages. This also means that NUMA
> support just works.
> 
> For example, to allocate two 1G gigantic pages on node 1, one can do:
> 
>  # echo 2 > \
>    /sys/devices/system/node/node1/hugepages/hugepages-1048576kB/nr_hugepages
> 
> And, to release all gigantic pages on the same node:
> 
>  # echo 0 > \
>    /sys/devices/system/node/node1/hugepages/hugepages-1048576kB/nr_hugepages
> 
> Please, refer to patch 5/5 for full technical details.
> 
> Finally, please note that this series is a follow up for a previous series
> that tried to extend the command-line options set to be NUMA aware:
> 
>  http://marc.info/?l=linux-mm&m=139593335312191&w=2
> 
> During the discussion of that series it was agreed that having runtime
> allocation support for gigantic pages was a better solution.
> 
> Luiz Capitulino (5):
>   hugetlb: prep_compound_gigantic_page(): drop __init marker
>   hugetlb: add hstate_is_gigantic()
>   hugetlb: update_and_free_page(): don't clear PG_reserved bit
>   hugetlb: move helpers up in the file
>   hugetlb: add support for gigantic page allocation at runtime

Thanks for doing this. It was on my todo list for some time.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov
