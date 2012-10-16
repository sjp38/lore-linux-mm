Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 15FC36B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 13:36:37 -0400 (EDT)
Received: by mail-qc0-f169.google.com with SMTP id t2so6151331qcq.14
        for <linux-mm@kvack.org>; Tue, 16 Oct 2012 10:36:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121016061854.GB3934@barrios>
References: <CAA25o9TmsnR3T+CLk5LeRmXv3s8b719KrSU6C919cAu0YMKPkA@mail.gmail.com>
	<20121015144412.GA2173@barrios>
	<CAA25o9R53oJajrzrWcLSAXcjAd45oQ4U+gJ3Mq=bthD3HGRaFA@mail.gmail.com>
	<20121016061854.GB3934@barrios>
Date: Tue, 16 Oct 2012 10:36:35 -0700
Message-ID: <CAA25o9R5OYSMZ=Rs2qy9rPk3U9yaGLLXVB60Yncqvmf3Y_Xbvg@mail.gmail.com>
Subject: Re: zram OOM behavior
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>

On Mon, Oct 15, 2012 at 11:18 PM, Minchan Kim <minchan@kernel.org> wrote:
> On Mon, Oct 15, 2012 at 11:54:36AM -0700, Luigi Semenzato wrote:
>> On Mon, Oct 15, 2012 at 7:44 AM, Minchan Kim <minchan@kernel.org> wrote:
>> > Hello,
>> >
>> > On Fri, Sep 28, 2012 at 10:32:20AM -0700, Luigi Semenzato wrote:
>> >> Greetings,
>> >>
>> >> We are experimenting with zram in Chrome OS.  It works quite well
>> >> until the system runs out of memory, at which point it seems to hang,
>> >> but we suspect it is thrashing.
>> >>
>> >> Before the (apparent) hang, the OOM killer gets rid of a few
>> >> processes, but then the other processes gradually stop responding,
>> >> until the entire system becomes unresponsive.
>> >
>> > Why do you think it's zram problem? If you use swap device as storage
>> > instead of zram, does the problem disappear?
>>
>> I haven't tried with a swap device, but that is a good suggestion.
>>
>> I didn't want to swap to disk (too slow compared to zram, so it's not
>> the same experiment any more), but I could preallocate a RAM disk and
>> swap to that.
>
> Good idea.
>
>>
>> > Could you do sysrq+t,m several time and post it while hang happens?
>> > /proc/vmstat could be helpful, too.
>>
>> The stack traces look mostly like this:
>>
>> [ 2058.069020]  [<810681c4>] handle_edge_irq+0x8f/0xb1
>> [ 2058.069028]  <IRQ>  [<810037ed>] ? do_IRQ+0x3f/0x98
>> [ 2058.069044]  [<813b7eb0>] ? common_interrupt+0x30/0x38
>> [ 2058.069058]  [<8108007b>] ? ftrace_raw_event_rpm_internal+0xf/0x108
>> [ 2058.069072]  [<81196c1a>] ? do_raw_spin_lock+0x93/0xf3
>> [ 2058.069085]  [<813b70d5>] ? _raw_spin_lock+0xd/0xf
>> [ 2058.069097]  [<810b418c>] ? put_super+0x15/0x29
>> [ 2058.069108]  [<810b41ba>] ? drop_super+0x1a/0x1d
>> [ 2058.069119]  [<810b4d04>] ? prune_super+0x106/0x110
>> [ 2058.069132]  [<81093647>] ? shrink_slab+0x7f/0x22f
>> [ 2058.069144]  [<81095943>] ? try_to_free_pages+0x1b7/0x2e6
>> [ 2058.069158]  [<8108de27>] ? __alloc_pages_nodemask+0x412/0x5d5
>> [ 2058.069173]  [<810a9c6a>] ? read_swap_cache_async+0x4a/0xcf
>> [ 2058.069185]  [<810a9d50>] ? swapin_readahead+0x61/0x8d
>> [ 2058.069198]  [<8109fea0>] ? handle_pte_fault+0x310/0x5fb
>> [ 2058.069208]  [<8100223a>] ? do_signal+0x470/0x4fe
>> [ 2058.069220]  [<810a02cc>] ? handle_mm_fault+0xae/0xbd
>> [ 2058.069233]  [<8101d0f9>] ? do_page_fault+0x265/0x284
>> [ 2058.069247]  [<81192b32>] ? copy_to_user+0x3e/0x49
>> [ 2058.069257]  [<8100306d>] ? do_spurious_interrupt_bug+0x26/0x26
>> [ 2058.069270]  [<81009279>] ? init_fpu+0x73/0x81
>> [ 2058.069280]  [<8100275e>] ? math_state_restore+0x1f/0xa0
>> [ 2058.069290]  [<8100306d>] ? do_spurious_interrupt_bug+0x26/0x26
>> [ 2058.069303]  [<8101ce94>] ? vmalloc_sync_all+0xa/0xa
>> [ 2058.069315]  [<813b7737>] ? error_code+0x67/0x6c
>>
>> The bottom part of the stack varies, but most processes are spending a
>> lot of time in prune_super().  There is a pretty high number of
>> mounted file systems, and do_try_to_free_pages() keeps calling
>> shrink_slab() even when there is nothing to reclaim there.
>
> Good catch. We can check the number of reclaimable slab in a zone before
> diving into shrink_slab and abort it.
>
>>
>> In addition, do_try_to_free_pages() keeps returning 1 because
>> all_unreclaimable() at the end is always false.  The allocator thinks
>> that zone 1 has freeable pages (zones 0 and 2 do not).  That prevents
>> the allocator from ooming.
>
> It's a problem of your custom patch "min_filelist_kbytes".
>
>>
>> I went in some more depth, but didn't quite untangle all that goes on.
>>  In any case, this explains why I came up with the theory that somehow
>> mm is too optimistic about how many pages are freeable.  Then I found
>> what looks like a smoking gun in vmscan.c:
>>
>> if (nr_swap_pages > 0)
>>     nr += zone_page_state(zone, NR_ACTIVE_ANON) +
>>             zone_page_state(zone, NR_INACTIVE_ANON);
>>
>> which seems to ignore that not all ANON pages are freeable if swap
>> space is limited.
>
> It's a just check for whether swap is enable or not, NOT how many we have
> empty slot in swap. I understand your concern but it's not related to your
> problem directly. If you could change it, you might solve the problem by
> early OOM but it's not right fix, IMHO and break LRU and SLAB reclaim balancing
> logic.

Yes, I was afraid of some consequence of that kind.

However, I still don't understand that computation.
"zone_reclaimable_pages" suggests we're computing how many anonymous
pages can be reclaimed.  If there is zero swap, no anonymous pages can
be reclaimed.  If there is very little swap left, very few anonymous
pages can be reclaimed.  So that confuses me.  But don't worry,
because many other things confuse me too!

>
>>
>> Pretty much all processes hang while trying to allocate memory.  Those
>> that don't allocate memory keep running fine.
>>
>> vmstat 1 shows a large amount of swapping activity, which drops to 0
>> when the processes hang.
>>
>> /proc/meminfo and /proc/vmstat are at the bottom.
>>
>> >
>> >>
>> >> I am wondering if anybody has run into this.  Thanks!
>> >>
>> >> Luigi
>> >>
>> >> P.S.  For those who wish to know more:
>> >>
>> >> 1. We use the min_filelist_kbytes patch
>> >> (http://lwn.net/Articles/412313/)  (I am not sure if it made it into
>> >> the standard kernel) and set min_filelist_kbytes to 50Mb.  (This may
>> >> not matter, as it's unlikely to make things worse.)
>> >
>> > One of the problem I look at this patch is it might prevent
>> > increasing of zone->pages_scanned when the swap if full or anon pages
>> > are very small although there are lots of file-backed pages.
>> > It means OOM can't occur and page allocator could loop forever.
>> > Please look at zone_reclaimable.
>>
>> Yes---I think you are right.  It didn't matter to us because we don't
>> use swap.  The problem looks fixable.
>
> No use swap? You mentioned you used zram as swap?
> Which is right? I started to confuse your word.

I apologize for the confusion.  We don't use swap now in Chrome OS.  I
am investigating the possibility of using zram, if I can get it to
work.

We are not likely to consider swap to disk because the resulting jank
for interactive loads is too high and difficult to control, and we may
do a better job by managing memory at a higher level (basically in the
Chrome app).

> If you don't use swap, it's more error prone because get_scan_count makes
> your reclaim logic never get reclaim anonymous memory and your min_filelist_kbytes
> patch makes reclaim logic never get reclaim file memory if file memory is smaller
> than 50M. It means VM never reclaim both anon and file LRU pages so all of processes
> try to allocate will be loop forever.

Actually, our patch seems to work fine in our systems, which are
commercially available.  (I'll be happy to send you any data that you
may find interesting).  Without the patch, the system can thrash badly
when we allocate memory aggressively (for instance, by loading many
browser tabs in parallel).

So, if we ignore zram for the moment, the min_filelist_kbytes patch
prevents the last 50 Mb of file memory from being evicted.  It has no
impact on anon memory.  For that memory,  we take same code path as
before.  It may be suboptimal because it doesn't try to reclaim
inactive file memory in the last 50 Mb, but that doesn't seem to
matter.

>
> You mean you didn't use it but start to use it these days?
> If so, please resend min_filelist_kbytes patch with the fix to linux-mm.
>
>>
>> > Have you ever test it without above patch?
>>
>> Good suggestion.  I just did.  Almost all text pages are evicted, and
>> then the system thrashes so badly that the hang detector kicks in
>> after a couple of minutes and panics.
>
> I guess culprit is your min_filelist_kbytes patch.

That could be, but I still need some way of preventing file pages
thrash.  Without that patch, the system thrashes when low on memory,
with or without zram, and with or without other changes related to
nr_swap_pages.

> If you think it's really good feature, please resend it and let's makes it better
> than now. I think motivation is good for embedded. :)

Yes!  Thanks, I'll try to do that.

>
>>
>> Thank you for the very helpful suggestions!
>
> Thanks for the interesting problem!
>
>>
>>
>> >
>> >>
>> >> 2. We swap only to compressed ram.  The setup is very simple:
>> >>
>> >>  echo ${ZRAM_SIZE_KB}000 >/sys/block/zram0/disksize ||
>> >>       logger -t "$UPSTART_JOB" "failed to set zram size"
>> >>   mkswap /dev/zram0 || logger -t "$UPSTART_JOB" "mkswap /dev/zram0 failed"
>> >>   swapon /dev/zram0 || logger -t "$UPSTART_JOB" "swapon /dev/zram0 failed"
>> >>
>> >> For ZRAM_SIZE_KB, we typically use 1.5 the size of RAM (which is 2 or
>> >> 4 Gb).  The compression factor is about 3:1.  The hangs happen for
>> >> quite a wide range of zram sizes.
>> >>
>> >> --
>> >> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> >> the body to majordomo@kvack.org.  For more info on Linux MM,
>> >> see: http://www.linux-mm.org/ .
>> >> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>> >
>> > --
>> > Kind Regards,
>> > Minchan Kim
>>
>>
>> MemTotal:        2002292 kB
>> MemFree:           15148 kB
>> Buffers:             260 kB
>> Cached:           169952 kB
>> SwapCached:       149448 kB
>> Active:           722608 kB
>> Inactive:         290824 kB
>> Active(anon):     682680 kB
>> Inactive(anon):   230888 kB
>> Active(file):      39928 kB
>> Inactive(file):    59936 kB
>> Unevictable:           0 kB
>> Mlocked:               0 kB
>> HighTotal:         74504 kB
>> HighFree:              0 kB
>> LowTotal:        1927788 kB
>> LowFree:           15148 kB
>> SwapTotal:       2933044 kB
>> SwapFree:          47968 kB
>> Dirty:                 0 kB
>> Writeback:            56 kB
>> AnonPages:        695180 kB
>> Mapped:            73276 kB
>> Shmem:             70276 kB
>> Slab:              19596 kB
>> SReclaimable:       9152 kB
>> SUnreclaim:        10444 kB
>> KernelStack:        1448 kB
>> PageTables:         9964 kB
>> NFS_Unstable:          0 kB
>> Bounce:                0 kB
>> WritebackTmp:          0 kB
>> CommitLimit:     3934188 kB
>> Committed_AS:    4371740 kB
>> VmallocTotal:     122880 kB
>> VmallocUsed:       22268 kB
>> VmallocChunk:     100340 kB
>> DirectMap4k:       34808 kB
>> DirectMap2M:     1927168 kB
>>
>>
>> nr_free_pages 3776
>> nr_inactive_anon 58243
>> nr_active_anon 172106
>> nr_inactive_file 14984
>> nr_active_file 9982
>> nr_unevictable 0
>> nr_mlock 0
>> nr_anon_pages 174840
>> nr_mapped 18387
>> nr_file_pages 80762
>> nr_dirty 0
>> nr_writeback 13
>> nr_slab_reclaimable 2290
>> nr_slab_unreclaimable 2611
>> nr_page_table_pages 2471
>> nr_kernel_stack 180
>> nr_unstable 0
>> nr_bounce 0
>> nr_vmscan_write 679247
>> nr_vmscan_immediate_reclaim 0
>> nr_writeback_temp 0
>> nr_isolated_anon 416
>> nr_isolated_file 0
>> nr_shmem 17637
>> nr_dirtied 7630
>> nr_written 686863
>> nr_anon_transparent_hugepages 0
>> nr_dirty_threshold 151452
>> nr_dirty_background_threshold 2524
>> pgpgin 284189
>> pgpgout 2748940
>> pswpin 5602
>> pswpout 679271
>> pgalloc_dma 9976
>> pgalloc_normal 1426651
>> pgalloc_high 34659
>> pgalloc_movable 0
>> pgfree 1475099
>> pgactivate 58092
>> pgdeactivate 745734
>> pgfault 1489876
>> pgmajfault 1098
>> pgrefill_dma 8557
>> pgrefill_normal 742123
>> pgrefill_high 4088
>> pgrefill_movable 0
>> pgsteal_kswapd_dma 199
>> pgsteal_kswapd_normal 48387
>> pgsteal_kswapd_high 2443
>> pgsteal_kswapd_movable 0
>> pgsteal_direct_dma 7688
>> pgsteal_direct_normal 652670
>> pgsteal_direct_high 6242
>> pgsteal_direct_movable 0
>> pgscan_kswapd_dma 268
>> pgscan_kswapd_normal 105036
>> pgscan_kswapd_high 8395
>> pgscan_kswapd_movable 0
>> pgscan_direct_dma 185240
>> pgscan_direct_normal 23961886
>> pgscan_direct_high 584047
>> pgscan_direct_movable 0
>> pginodesteal 123
>> slabs_scanned 10368
>> kswapd_inodesteal 1
>> kswapd_low_wmark_hit_quickly 15
>> kswapd_high_wmark_hit_quickly 8
>> kswapd_skip_congestion_wait 639
>> pageoutrun 582
>> allocstall 14514
>> pgrotated 1
>> unevictable_pgs_culled 0
>> unevictable_pgs_scanned 0
>> unevictable_pgs_rescued 1
>> unevictable_pgs_mlocked 1
>> unevictable_pgs_munlocked 1
>> unevictable_pgs_cleared 0
>> unevictable_pgs_stranded 0
>> unevictable_pgs_mlockfreed 0
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
> --
> Kind Regards,
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
