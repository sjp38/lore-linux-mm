Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id E780B6B0032
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 13:14:24 -0400 (EDT)
Message-ID: <51ED686E.6030606@bitsync.net>
Date: Mon, 22 Jul 2013 19:14:22 +0200
From: Zlatko Calusic <zcalusic@bitsync.net>
MIME-Version: 1.0
Subject: Re: [patch 0/3] mm: improve page aging fairness between zones/nodes
References: <1374267325-22865-1-git-send-email-hannes@cmpxchg.org> <51ED6274.3000509@bitsync.net> <20130722170112.GE715@cmpxchg.org>
In-Reply-To: <20130722170112.GE715@cmpxchg.org>
Content-Type: multipart/mixed;
 boundary="------------070706080602000903050200"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This is a multi-part message in MIME format.
--------------070706080602000903050200
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 22.07.2013 19:01, Johannes Weiner wrote:
> Hi Zlatko,
>
> On Mon, Jul 22, 2013 at 06:48:52PM +0200, Zlatko Calusic wrote:
>> On 19.07.2013 22:55, Johannes Weiner wrote:
>>> The way the page allocator interacts with kswapd creates aging
>>> imbalances, where the amount of time a userspace page gets in memory
>>> under reclaim pressure is dependent on which zone, which node the
>>> allocator took the page frame from.
>>>
>>> #1 fixes missed kswapd wakeups on NUMA systems, which lead to some
>>>     nodes falling behind for a full reclaim cycle relative to the other
>>>     nodes in the system
>>>
>>> #3 fixes an interaction where kswapd and a continuous stream of page
>>>     allocations keep the preferred zone of a task between the high and
>>>     low watermark (allocations succeed + kswapd does not go to sleep)
>>>     indefinitely, completely underutilizing the lower zones and
>>>     thrashing on the preferred zone
>>>
>>> These patches are the aging fairness part of the thrash-detection
>>> based file LRU balancing.  Andrea recommended to submit them
>>> separately as they are bugfixes in their own right.
>>>
>>
>> I have the patch applied and under testing. So far, so good. It
>> looks like it could finally fix the bug that I was chasing few
>> months ago (nicely described in your bullet #3). But, few more days
>> of testing will be needed before I can reach a quality verdict.
>
> I should have remembered that you talked about this problem... Thanks
> a lot for testing!
>
> May I ask for the zone layout of your test machine(s)?  I.e. how many
> nodes if NUMA, how big Normal and DMA32 (on Node 0) are.
>

I have been reading about NUMA hw for at least a decade, but I guess 
another one will pass before I actually see one. ;) Find /proc/zoneinfo 
attached.

If your patchset fails my case, then nr_{in,}active_file in Normal zone 
will drop close to zero in a matter of days. If it fixes this particular 
imbalance, and I have faith it will, then those two counters will stay 
in relative balance with nr_{in,}active_anon in the same zone. I also 
applied Konstantin's excellent lru-milestones-timestamps-and-ages, and 
graphing of interesting numbers on top of that, which is why I already 
have faith in your patchset. I can see much better balance between zones 
already. But, let's give it some more time...

-- 
Zlatko

--------------070706080602000903050200
Content-Type: text/plain; charset=UTF-8;
 name="zoneinfo"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="zoneinfo"

Node 0, zone      DMA
  pages free     3975
        min      132
        low      165
        high     198
        scanned  0
        spanned  4095
        present  3998
        managed  3977
    nr_free_pages 3975
    nr_inactive_anon 0
    nr_active_anon 0
    nr_inactive_file 0
    nr_active_file 0
    nr_unevictable 0
    nr_mlock     0
    nr_anon_pages 0
    nr_mapped    0
    nr_file_pages 0
    nr_dirty     0
    nr_writeback 0
    nr_slab_reclaimable 0
    nr_slab_unreclaimable 2
    nr_page_table_pages 0
    nr_kernel_stack 0
    nr_unstable  0
    nr_bounce    0
    nr_vmscan_write 0
    nr_vmscan_immediate_reclaim 0
    nr_writeback_temp 0
    nr_isolated_anon 0
    nr_isolated_file 0
    nr_shmem     0
    nr_dirtied   0
    nr_written   0
    nr_anon_transparent_hugepages 0
    nr_free_cma  0
        protection: (0, 3236, 3933, 3933)
  pagesets
    cpu: 0
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 4
    cpu: 1
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 4
  all_unreclaimable: 1
  start_pfn:         1
  inactive_ratio:    1
  avg_age_inactive_anon: 0
  avg_age_active_anon:   0
  avg_age_inactive_file: 0
  avg_age_active_file:   0
Node 0, zone    DMA32
  pages free     83177
        min      27693
        low      34616
        high     41539
        scanned  0
        spanned  1044480
        present  847429
        managed  829295
    nr_free_pages 83177
    nr_inactive_anon 2061
    nr_active_anon 313380
    nr_inactive_file 199460
    nr_active_file 207097
    nr_unevictable 0
    nr_mlock     0
    nr_anon_pages 239688
    nr_mapped    38888
    nr_file_pages 424978
    nr_dirty     87
    nr_writeback 0
    nr_slab_reclaimable 9119
    nr_slab_unreclaimable 2054
    nr_page_table_pages 1795
    nr_kernel_stack 144
    nr_unstable  0
    nr_bounce    0
    nr_vmscan_write 0
    nr_vmscan_immediate_reclaim 0
    nr_writeback_temp 0
    nr_isolated_anon 0
    nr_isolated_file 0
    nr_shmem     18421
    nr_dirtied   725414
    nr_written   768505
    nr_anon_transparent_hugepages 112
    nr_free_cma  0
        protection: (0, 0, 697, 697)
  pagesets
    cpu: 0
              count: 132
              high:  186
              batch: 31
  vm stats threshold: 24
    cpu: 1
              count: 146
              high:  186
              batch: 31
  vm stats threshold: 24
  all_unreclaimable: 0
  start_pfn:         4096
  inactive_ratio:    5
  avg_age_inactive_anon: 5467648
  avg_age_active_anon:   5467648
  avg_age_inactive_file: 3184128
  avg_age_active_file:   5467648
Node 0, zone   Normal
  pages free     17164
        min      5965
        low      7456
        high     8947
        scanned  0
        spanned  196607
        present  196607
        managed  178491
    nr_free_pages 17164
    nr_inactive_anon 294
    nr_active_anon 64754
    nr_inactive_file 42191
    nr_active_file 44925
    nr_unevictable 0
    nr_mlock     0
    nr_anon_pages 51456
    nr_mapped    9580
    nr_file_pages 91492
    nr_dirty     27
    nr_writeback 0
    nr_slab_reclaimable 2686
    nr_slab_unreclaimable 1194
    nr_page_table_pages 401
    nr_kernel_stack 65
    nr_unstable  0
    nr_bounce    0
    nr_vmscan_write 0
    nr_vmscan_immediate_reclaim 0
    nr_writeback_temp 0
    nr_isolated_anon 0
    nr_isolated_file 0
    nr_shmem     4376
    nr_dirtied   163250
    nr_written   172369
    nr_anon_transparent_hugepages 18
    nr_free_cma  0
        protection: (0, 0, 0, 0)
  pagesets
    cpu: 0
              count: 177
              high:  186
              batch: 31
  vm stats threshold: 16
    cpu: 1
              count: 170
              high:  186
              batch: 31
  vm stats threshold: 16
  all_unreclaimable: 0
  start_pfn:         1048576
  inactive_ratio:    1
  avg_age_inactive_anon: 5468672
  avg_age_active_anon:   5468672
  avg_age_inactive_file: 3382628
  avg_age_active_file:   5468672

--------------070706080602000903050200--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
