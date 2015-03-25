Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 12B816B0032
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 18:16:50 -0400 (EDT)
Received: by wgdm6 with SMTP id m6so43960417wgd.2
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 15:16:49 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h3si7349045wix.93.2015.03.25.15.16.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Mar 2015 15:16:48 -0700 (PDT)
Message-ID: <551333D6.20708@suse.cz>
Date: Wed, 25 Mar 2015 23:16:54 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFCv2] mm: page allocation for less fragmentation
References: <1427251155-12322-1-git-send-email-gioh.kim@lge.com>
In-Reply-To: <1427251155-12322-1-git-send-email-gioh.kim@lge.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>, akpm@linux-foundation.org, mgorman@suse.de, riel@redhat.com, hannes@cmpxchg.org, rientjes@google.com, vdavydov@parallels.com, iamjoonsoo.kim@lge.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, gunho.lee@lge.com

On 25.3.2015 3:39, Gioh Kim wrote:
> My driver allocates more than 40MB pages via alloc_page() at a time and
> maps them at virtual address. Totally it uses 300~400MB pages.
> 
> If I run a heavy load test for a few days in 1GB memory system, I cannot allocate even order=3 pages
> because-of the external fragmentation.
> 
> I thought I needed a anti-fragmentation solution for my driver.
> But there is no allocation function that considers fragmentation.
> The compaction is not helpful because it is only for movable pages, not unmovable pages.
> 
> This patch proposes a allocation function allocates only pages in the same pageblock.
> 
> I tested this patch like following:
> 
> 1. When the driver allocates about 400MB and do "cat /proc/pagetypeinfo;cat /proc/buddyinfo"
> 
> Free pages count per migrate type at order       0      1      2      3      4      5      6      7      8      9     10
> Node    0, zone   Normal, type    Unmovable   3864    728    394    216    129     47     18      9      1      0      0
> Node    0, zone   Normal, type  Reclaimable    902     96     68     17      3      0      1      0      0      0      0
> Node    0, zone   Normal, type      Movable   5146    663    178     91     43     16      4      0      0      0      0
> Node    0, zone   Normal, type      Reserve      1      4      6      6      2      1      1      1      0      1      1
> Node    0, zone   Normal, type          CMA      0      0      0      0      0      0      0      0      0      0      0
> Node    0, zone   Normal, type      Isolate      0      0      0      0      0      0      0      0      0      0      0
> 
> Number of blocks type     Unmovable  Reclaimable      Movable      Reserve          CMA      Isolate
> Node 0, zone   Normal          135            3          124            2            0            0
> Node 0, zone   Normal   9880   1489    647    332    177     64     24     10      1      1      1
> 
> 2. The driver frees all pages and allocates pages again with alloc_pages_compact.

This is not a good test setup. You shouldn't switch the allocation types during
single system boot. You should compare results from a boot where common
allocation is used and from a boot where your new allocation is used.

> This is a kind of compaction of the driver.
> Following is the result of "cat /proc/pagetypeinfo;cat /proc/buddyinfo"
> 
> Free pages count per migrate type at order       0      1      2      3      4      5      6      7      8      9     10
> Node    0, zone   Normal, type    Unmovable      8      5      1    432    272     91     37     11      1      0      0
> Node    0, zone   Normal, type  Reclaimable    901     96     68     17      3      0      1      0      0      0      0
> Node    0, zone   Normal, type      Movable   4790    776    192     91     43     16      4      0      0      0      0
> Node    0, zone   Normal, type      Reserve      1      4      6      6      2      1      1      1      0      1      1
> Node    0, zone   Normal, type          CMA      0      0      0      0      0      0      0      0      0      0      0
> Node    0, zone   Normal, type      Isolate      0      0      0      0      0      0      0      0      0      0      0
> 
> Number of blocks type     Unmovable  Reclaimable      Movable      Reserve          CMA      Isolate
> Node 0, zone   Normal          135            3          124            2            0            0
> Node 0, zone   Normal   5693    877    266    544    320    108     43     12      1      1      1

The number of unmovable pageblocks didn't change here. The stats for free
unmovable pages does look better for higher orders than in the first listing
above, but even the common allocation logic would give you that result, if you
allocated your 400 MB using (many) order-0 allocations (since you apparently
don't care about physically contiguous memory). That would also prefer order-0
free pages before splitting higher orders. So this doesn't demonstrate benefits
of the alloc_pages_compact() approach I'm afraid. The results suggest that the
system was in a worst state when the first allocation happened, and meanwhile
some pages were freed, creating the large numbers of order-0 unmovable free
pages. Or maybe the system got fragmented in the first allocation because your
driver tries to allocate the memory with high-order allocations before falling
back to lower orders? That would probably defeat the natural anti-fragmentation
of the buddy system.

So a proper test could be based on this:

> If I run a heavy load test for a few days in 1GB memory system, I cannot
allocate even order=3 pages
> because-of the external fragmentation.

With this patch, is the situation quantifiably better? Can you post the
pagetype/buddyinfo for system boot where all driver allocations use the common
allocator, and system boot with the patch? That should be comparable if the
workload is the same for both boots.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
