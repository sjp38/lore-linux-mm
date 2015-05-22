Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7717A82997
	for <linux-mm@kvack.org>; Fri, 22 May 2015 02:30:17 -0400 (EDT)
Received: by lami4 with SMTP id i4so5972183lam.0
        for <linux-mm@kvack.org>; Thu, 21 May 2015 23:30:16 -0700 (PDT)
Received: from numascale.com (numascale.com. [213.162.240.84])
        by mx.google.com with ESMTPS id pf2si788192lbc.2.2015.05.21.23.30.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 May 2015 23:30:15 -0700 (PDT)
Date: Fri, 22 May 2015 14:30:01 +0800
From: Daniel J Blueman <daniel@numascale.com>
Subject: Re: [PATCH] mm: meminit: Finish initialisation of struct pages
 before basic setup
Message-Id: <1432276201.11133.1@cpanel21.proisp.no>
In-Reply-To: <1431597783.26797.1@cpanel21.proisp.no>
References: <1431597783.26797.1@cpanel21.proisp.no>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: nzimmer <nzimmer@sgi.com>, Waiman Long <waiman.long@hp.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Steffen Persvold <sp@numascale.com>

On Thu, May 14, 2015 at 6:03 PM, Daniel J Blueman 
<daniel@numascale.com> wrote:
> On Thu, May 14, 2015 at 12:31 AM, Mel Gorman <mgorman@suse.de> wrote:
>> On Wed, May 13, 2015 at 10:53:33AM -0500, nzimmer wrote:
>>>  I am just noticed a hang on my largest box.
>>>  I can only reproduce with large core counts, if I turn down the
>>>  number of cpus it doesn't have an issue.
>>> 
>> 
>> Odd. The number of core counts should make little a difference as 
>> only
>> one CPU per node should be in use. Does sysrq+t give any indication 
>> how
>> or where it is hanging?
> 
> I was seeing the same behaviour of 1000ms increasing to 5500ms [1]; 
> this suggests either lock contention or O(n) behaviour.
> 
> Nathan, can you check with this ordering of patches from Andrew's 
> cache [2]? I was getting hanging until I a found them all.
> 
> I'll follow up with timing data.

7TB over 216 NUMA nodes, 1728 cores, from kernel 4.0.4 load to login:

1. 2086s with patches 01-19 [1]

2. 2026s adding "Take into account that large system caches scale 
linearly with memory", which has:
 min(2UL << (30 - PAGE_SHIFT), (pgdat->node_spanned_pages >> 3));

3. 2442s fixing to:
 max(2UL << (30 - PAGE_SHIFT), (pgdat->node_spanned_pages >> 3));

4. 2064s adjusting minimum and shift to:
 max(512UL << (20 - PAGE_SHIFT), (pgdat->node_spanned_pages >> 8));

5. 1934s adjusting minimum and shift to:
 max(128UL << (20 - PAGE_SHIFT), (pgdat->node_spanned_pages >> 8));

6. 930s #5 with the non-temporal PMD init patch I had earlier proposed 
(I'll pursue separately)

The scaling patch isn't in -mm. #5 tests out nice on a bunch of other 
AMD systems, 64GB and up, so: Tested-by: Daniel J Blueman 
<daniel@numascale.com>.

Fine work, Mel!

Daniel

-- [1]

> http://ozlabs.org/~akpm/mmots/broken-out/memblock-introduce-a-for_each_reserved_mem_region-iterator.patch
> http://ozlabs.org/~akpm/mmots/broken-out/mm-meminit-move-page-initialization-into-a-separate-function.patch
> http://ozlabs.org/~akpm/mmots/broken-out/mm-meminit-only-set-page-reserved-in-the-memblock-region.patch
> http://ozlabs.org/~akpm/mmots/broken-out/mm-page_alloc-pass-pfn-to-__free_pages_bootmem.patch
> http://ozlabs.org/~akpm/mmots/broken-out/mm-meminit-make-__early_pfn_to_nid-smp-safe-and-introduce-meminit_pfn_in_nid.patch
> http://ozlabs.org/~akpm/mmots/broken-out/mm-meminit-inline-some-helper-functions.patch
> http://ozlabs.org/~akpm/mmots/broken-out/mm-meminit-inline-some-helper-functions-fix.patch
> http://ozlabs.org/~akpm/mmots/broken-out/mm-meminit-initialise-a-subset-of-struct-pages-if-config_deferred_struct_page_init-is-set.patch
> http://ozlabs.org/~akpm/mmots/broken-out/mm-meminit-initialise-remaining-struct-pages-in-parallel-with-kswapd.patch
> http://ozlabs.org/~akpm/mmots/broken-out/mm-meminit-minimise-number-of-pfn-page-lookups-during-initialisation.patch
> http://ozlabs.org/~akpm/mmots/broken-out/x86-mm-enable-deferred-struct-page-initialisation-on-x86-64.patch
> http://ozlabs.org/~akpm/mmots/broken-out/mm-meminit-free-pages-in-large-chunks-where-possible.patch
> http://ozlabs.org/~akpm/mmots/broken-out/mm-meminit-reduce-number-of-times-pageblocks-are-set-during-struct-page-init.patch
> http://ozlabs.org/~akpm/mmots/broken-out/mm-meminit-remove-mminit_verify_page_links.patch
> http://ozlabs.org/~akpm/mmots/broken-out/mm-meminit-initialise-a-subset-of-struct-pages-if-config_deferred_struct_page_init-is-set-fix.patch
> http://ozlabs.org/~akpm/mmots/broken-out/mm-meminit-finish-initialisation-of-struct-pages-before-basic-setup.patch
> http://ozlabs.org/~akpm/mmots/broken-out/mm-meminit-finish-initialisation-of-struct-pages-before-basic-setup-fix.patch
> http://ozlabs.org/~akpm/mmots/broken-out/mm-meminit-reduce-number-of-times-pageblocks-are-set-during-struct-page-init-fix.patch
> http://ozlabs.org/~akpm/mmots/broken-out/mm-meminit-inline-some-helper-functions-fix2.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
