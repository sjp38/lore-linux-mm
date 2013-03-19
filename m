Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 70DF06B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 01:57:47 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id wz12so132467pbc.3
        for <linux-mm@kvack.org>; Mon, 18 Mar 2013 22:57:46 -0700 (PDT)
Date: Tue, 19 Mar 2013 13:57:06 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [LSF/MM TOPIC]swap improvements for fast SSD
Message-ID: <20130319055706.GA24130@kernel.org>
References: <20130122065341.GA1850@kernel.org>
 <5142EC5A.4010509@gmail.com>
 <5146EEA5.4030003@oracle.com>
 <20130319012725.GA28880@kernel.org>
 <5147C037.5020707@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5147C037.5020707@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Bob Liu <bob.liu@oracle.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, dan.magenheimer@oracle.com, sjenning@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com

On Tue, Mar 19, 2013 at 09:32:39AM +0800, Simon Jeons wrote:
> Hi Shaohua,
> On 03/19/2013 09:27 AM, Shaohua Li wrote:
> >On Mon, Mar 18, 2013 at 06:38:29PM +0800, Bob Liu wrote:
> >>On 03/15/2013 05:39 PM, Simon Jeons wrote:
> >>>On 01/22/2013 02:53 PM, Shaohua Li wrote:
> >>>>Hi,
> >>>>
> >>>>Because of high density, low power and low price, flash storage (SSD)
> >>>>is a good
> >>>>candidate to partially replace DRAM. A quick answer for this is using
> >>>>SSD as
> >>>>swap. But Linux swap is designed for slow hard disk storage. There are
> >>>>a lot of
> >>>>challenges to efficiently use SSD for swap:
> >>>>
> >>>>1. Lock contentions (swap_lock, anon_vma mutex, swap address space lock)
> >>>>2. TLB flush overhead. To reclaim one page, we need at least 2 TLB
> >>>>flush. This
> >>>>overhead is very high even in a normal 2-socket machine.
> >>>>3. Better swap IO pattern. Both direct and kswapd page reclaim can do
> >>>>swap,
> >>>>which makes swap IO pattern is interleave. Block layer isn't always
> >>>>efficient
> >>>>to do request merge. Such IO pattern also makes swap prefetch hard.
> >>>>4. Swap map scan overhead. Swap in-memory map scan scans an array,
> >>>>which is
> >>>>very inefficient, especially if swap storage is fast.
> >>>>5. SSD related optimization, mainly discard support
> >>>>6. Better swap prefetch algorithm. Besides item 3, sequentially
> >>>>accessed pages
> >>>>aren't always in LRU list adjacently, so page reclaim will not swap
> >>>>such pages
> >>>>in adjacent storage sectors. This makes swap prefetch hard.
> >>>>7. Alternative page reclaim policy to bias reclaiming anonymous page.
> >>>>Currently reclaim anonymous page is considering harder than reclaim
> >>>>file pages,
> >>>>so we bias reclaiming file pages. If there are high speed swap
> >>>>storage, we are
> >>>>considering doing swap more aggressively.
> >>>>8. Huge page swap. Huge page swap can solve a lot of problems above,
> >>>>but both
> >>>>THP and hugetlbfs don't support swap.
> >>>Could you tell me in which workload hugetlb/thp pages can't swapout
> >>>influence your performance? Is it worth?
> >>>
> >>I'm also very interesting in this workload.
> >>I think hugetlb/thp pages can be a potential user of zprojects like
> >>zswap/zcache.
> >>We can try to compress those pages before breaking them to normal pages.
> >I don't have particular workload and don't have data for obvious reason. What I
> >expected is swapout hugetlb/thp is to reduce some overheads (eg, tlb flush) and
> >improve IO pattern.
> Do you have any idea about implement this feature?

Didn't look at hugetlb yet, but for THP, maybe it's an overkill to really do 2M
page swapping. My idea is to provide a special version of add_to_swap +
try_to_unmap in page reclaim. We still do huge page split, but in the split, we
also do 'unmap' to reduce unnecessary TLB flush. In the split, tail pages
should be added back to page_list of shrink_page_list() instead of lru list, so
tail pages can be pageout soon. In this way, we can use existing swap code (not
bothering changing arch code and swap space allocation for example) and reach
my goal (reduce tlb flush and improve IO pattern). But that said, I didn't do
any coding yet, this might be just wrong actually, but I'll try some time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
