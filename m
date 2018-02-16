Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1D9BA6B0003
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 14:00:06 -0500 (EST)
Received: by mail-yb0-f197.google.com with SMTP id c10-v6so1546900ybn.8
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 11:00:06 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id w13si1922773ywi.253.2018.02.16.11.00.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 11:00:04 -0800 (PST)
Subject: Re: [RFC 1/2] Protect larger order pages from breaking up
References: <20180216160110.641666320@linux.com>
 <20180216160121.519788537@linux.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <5108eb20-2b20-bd48-903e-bce312e96974@oracle.com>
Date: Fri, 16 Feb 2018 10:59:19 -0800
MIME-Version: 1.0
In-Reply-To: <20180216160121.519788537@linux.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Mel Gorman <mel@skynet.ie>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-rdma@vger.kernel.org, akpm@linux-foundation.org, Thomas Schoebel-Theuer <tst@schoebel-theuer.de>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>

On 02/16/2018 08:01 AM, Christoph Lameter wrote:
> Over time as the kernel is churning through memory it will break
> up larger pages and as time progresses larger contiguous allocations
> will no longer be possible. This is an approach to preserve these
> large pages and prevent them from being broken up.
> 
> This is useful for example for the use of jumbo pages and can
> satify various needs of subsystems and device drivers that require
> large contiguous allocation to operate properly.
> 
> The idea is to reserve a pool of pages of the required order
> so that the kernel is not allowed to use the pages for allocations
> of a different order. This is a pool that is fully integrated
> into the page allocator and therefore transparently usable.
> 
> Control over this feature is by writing to /proc/zoneinfo.
> 
> F.e. to ensure that 2000 16K pages stay available for jumbo
> frames do
> 
> 	echo "2=2000" >/proc/zoneinfo
> 
> or through the order=<page spec> on the kernel command line.
> F.e.
> 
> 	order=2=2000,4N2=500
> 
> These pages will be subject to reclaim etc as usual but will not
> be broken up.
> 
> One can then also f.e. operate the slub allocator with
> 64k pages. Specify "slub_max_order=4 slub_min_order=4" on
> the kernel command line and all slab allocator allocations
> will occur in 64K page sizes.
> 
> Note that this will reduce the memory available to the application
> in some cases. Reclaim may occur more often. If more than
> the reserved number of higher order pages are being used then
> allocations will still fail as normal.
> 
> In order to make this work just right one needs to be able to
> know the workload well enough to reserve the right amount
> of pages. This is comparable to other reservation schemes.

Yes.

I like the idea that this only comes into play as the result of explicit
user/sysadmin action.  It does remind me of hugetlbfs reservations.  So,
we hope that only people who really know their workload and know what
they are doing would use this feature.

> Well that f.e brings up huge pages. You can of course
> also use this to reserve those and can then be sure that
> you can dynamically resize your huge page pools even after
> a long time of system up time.

Yes, and no.  Doesn't that assume nobody else is doing allocations
of that size?  For example, I could image THP using huge page sized
reservations.  The when it comes time to resize your hugetlbfs pool
there may not be enough.  Although, we may quickly split THP pages
in this case.  I am not sure.

IIRC, Guy Shattah's use case was for allocations greater than MAX_ORDER.
This would not directly address that.  A huge contiguous area (2GB) is
the sweet spot' for best performance in his case.  However, I think he
could still benefit from using a set of larger (such as 2MB) size
allocations which this scheme could help with.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
