Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 0CAAA6B005D
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 18:25:44 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so286911eek.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 15:25:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1211131507370.17623@chino.kir.corp.google.com>
References: <CALCETrVgbx-8Ex1Q6YgEYv-Oxjoa1oprpsQE-Ww6iuwf7jFeGg@mail.gmail.com>
 <alpine.DEB.2.00.1211131507370.17623@chino.kir.corp.google.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 13 Nov 2012 15:25:23 -0800
Message-ID: <CALCETrU=7+pk_rMKKuzgW1gafWfv6v7eQtVw3p8JryaTkyVQYQ@mail.gmail.com>
Subject: Re: [3.6 regression?] THP + migration/compaction livelock (I think)
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Marc Duponcheel <marc@offline.be>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Nov 13, 2012 at 3:11 PM, David Rientjes <rientjes@google.com> wrote:
> On Tue, 13 Nov 2012, Andy Lutomirski wrote:
>
>> I've seen an odd problem three times in the past two weeks.  I suspect
>> a Linux 3.6 regression.  I"m on 3.6.3-1.fc17.x86_64.  I run a parallel
>> compilation, and no progress is made.  All cpus are pegged at 100%
>> system time by the respective cc1plus processes.  Reading
>> /proc/<pid>/stack shows either
>>
>> [<ffffffff8108e01a>] __cond_resched+0x2a/0x40
>> [<ffffffff8114e432>] isolate_migratepages_range+0xb2/0x620
>> [<ffffffff8114eba4>] compact_zone+0x144/0x410
>> [<ffffffff8114f152>] compact_zone_order+0x82/0xc0
>> [<ffffffff8114f271>] try_to_compact_pages+0xe1/0x130
>> [<ffffffff816143db>] __alloc_pages_direct_compact+0xaa/0x190
>> [<ffffffff81133d26>] __alloc_pages_nodemask+0x526/0x990
>> [<ffffffff81171496>] alloc_pages_vma+0xb6/0x190
>> [<ffffffff81182683>] do_huge_pmd_anonymous_page+0x143/0x340
>> [<ffffffff811549fd>] handle_mm_fault+0x27d/0x320
>> [<ffffffff81620adc>] do_page_fault+0x15c/0x4b0
>> [<ffffffff8161d625>] page_fault+0x25/0x30
>> [<ffffffffffffffff>] 0xffffffffffffffff
>>
>> or
>>
>> [<ffffffffffffffff>] 0xffffffffffffffff
>>
>
> This reminds me of the thread at http://marc.info/?t=135102111800004 which
> caused Marc's system to reportedly go unresponsive like your report but in
> his case it also caused a reboot.  If your system is still running (or,
> even better, if you're able to capture this happening in realtime), could
> you try to capture
>
>         grep -E "compact_|thp_" /proc/vmstat
>
> as well while it is in progress?  (Even if it's not happening right now,
> the data might still be useful if you have knowledge that it has occurred
> since the last reboot.)

It just happened again.

$ grep -E "compact_|thp_" /proc/vmstat
compact_blocks_moved 8332448774
compact_pages_moved 21831286
compact_pagemigrate_failed 211260
compact_stall 13484
compact_fail 6717
compact_success 6755
thp_fault_alloc 150665
thp_fault_fallback 4270
thp_collapse_alloc 19771
thp_collapse_alloc_failed 2188
thp_split 19600


/proc/meminfo:

MemTotal:       16388116 kB
MemFree:         6684372 kB
Buffers:           34960 kB
Cached:          6233588 kB
SwapCached:        29500 kB
Active:          4881396 kB
Inactive:        3824296 kB
Active(anon):    1687576 kB
Inactive(anon):   764852 kB
Active(file):    3193820 kB
Inactive(file):  3059444 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:      16777212 kB
SwapFree:       16643864 kB
Dirty:               184 kB
Writeback:             0 kB
AnonPages:       2408692 kB
Mapped:           126964 kB
Shmem:             15272 kB
Slab:             635496 kB
SReclaimable:     528924 kB
SUnreclaim:       106572 kB
KernelStack:        3600 kB
PageTables:        39460 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:    24971268 kB
Committed_AS:    5688448 kB
VmallocTotal:   34359738367 kB
VmallocUsed:      614952 kB
VmallocChunk:   34359109524 kB
HardwareCorrupted:     0 kB
AnonHugePages:   1050624 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
DirectMap4k:     3600384 kB
DirectMap2M:    11038720 kB
DirectMap1G:     1048576 kB

$ sudo ./perf stat -p 11764 -e
compaction:mm_compaction_isolate_migratepages,task-clock,vmscan:mm_vmscan_direct_reclaim_begin,vmscan:mm_vmscan_lru_isolate,vmscan:mm_vmscan_memcg_isolate
[sudo] password for luto:
^C
 Performance counter stats for process id '11764':

         1,638,009 compaction:mm_compaction_isolate_migratepages #
0.716 M/sec                   [100.00%]
       2286.993046 task-clock                #    0.872 CPUs utilized
         [100.00%]
                 0 vmscan:mm_vmscan_direct_reclaim_begin #    0.000
M/sec                   [100.00%]
                 0 vmscan:mm_vmscan_lru_isolate #    0.000 M/sec
            [100.00%]
                 0 vmscan:mm_vmscan_memcg_isolate #    0.000 M/sec

       2.623626878 seconds time elapsed

/proc/zoneinfo:
Node 0, zone      DMA
  pages free     3972
        min      16
        low      20
        high     24
        scanned  0
        spanned  4080
        present  3911
    nr_free_pages 3972
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
    nr_slab_unreclaimable 4
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
    numa_hit     1
    numa_miss    0
    numa_foreign 0
    numa_interleave 0
    numa_local   1
    numa_other   0
    nr_anon_transparent_hugepages 0
        protection: (0, 2434, 16042, 16042)
  pagesets
    cpu: 0
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 8
    cpu: 1
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 8
    cpu: 2
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 8
    cpu: 3
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 8
    cpu: 4
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 8
    cpu: 5
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 8
    cpu: 6
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 8
    cpu: 7
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 8
    cpu: 8
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 8
    cpu: 9
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 8
    cpu: 10
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 8
    cpu: 11
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 8
  all_unreclaimable: 1
  start_pfn:         16
  inactive_ratio:    1
Node 0, zone    DMA32
  pages free     321075
        min      2561
        low      3201
        high     3841
        scanned  0
        spanned  1044480
        present  623163
    nr_free_pages 321075
    nr_inactive_anon 43450
    nr_active_anon 203472
    nr_inactive_file 5416
    nr_active_file 39568
    nr_unevictable 0
    nr_mlock     0
    nr_anon_pages 86455
    nr_mapped    156
    nr_file_pages 45195
    nr_dirty     0
    nr_writeback 0
    nr_slab_reclaimable 6679
    nr_slab_unreclaimable 419
    nr_page_table_pages 2
    nr_kernel_stack 0
    nr_unstable  0
    nr_bounce    0
    nr_vmscan_write 9994
    nr_vmscan_immediate_reclaim 1
    nr_writeback_temp 0
    nr_isolated_anon 0
    nr_isolated_file 0
    nr_shmem     1
    nr_dirtied   1765256
    nr_written   1763392
    numa_hit     53134489
    numa_miss    0
    numa_foreign 0
    numa_interleave 0
    numa_local   53134489
    numa_other   0
    nr_anon_transparent_hugepages 313
        protection: (0, 0, 13608, 13608)
  pagesets
    cpu: 0
              count: 0
              high:  186
              batch: 31
  vm stats threshold: 48
    cpu: 1
              count: 4
              high:  186
              batch: 31
  vm stats threshold: 48
    cpu: 2
              count: 4
              high:  186
              batch: 31
  vm stats threshold: 48
    cpu: 3
              count: 0
              high:  186
              batch: 31
  vm stats threshold: 48
    cpu: 4
              count: 4
              high:  186
              batch: 31
  vm stats threshold: 48
    cpu: 5
              count: 0
              high:  186
              batch: 31
  vm stats threshold: 48
    cpu: 6
              count: 0
              high:  186
              batch: 31
  vm stats threshold: 48
    cpu: 7
              count: 11
              high:  186
              batch: 31
  vm stats threshold: 48
    cpu: 8
              count: 0
              high:  186
              batch: 31
  vm stats threshold: 48
    cpu: 9
              count: 4
              high:  186
              batch: 31
  vm stats threshold: 48
    cpu: 10
              count: 13
              high:  186
              batch: 31
  vm stats threshold: 48
    cpu: 11
              count: 4
              high:  186
              batch: 31
  vm stats threshold: 48
  all_unreclaimable: 0
  start_pfn:         4096
  inactive_ratio:    4
Node 0, zone   Normal
  pages free     1343098
        min      14318
        low      17897
        high     21477
        scanned  0
        spanned  3538944
        present  3483648
    nr_free_pages 1343098
    nr_inactive_anon 147925
    nr_active_anon 221736
    nr_inactive_file 759336
    nr_active_file 758833
    nr_unevictable 0
    nr_mlock     0
    nr_anon_pages 257074
    nr_mapped    31632
    nr_file_pages 1529150
    nr_dirty     25
    nr_writeback 0
    nr_slab_reclaimable 125552
    nr_slab_unreclaimable 26176
    nr_page_table_pages 9844
    nr_kernel_stack 456
    nr_unstable  0
    nr_bounce    0
    nr_vmscan_write 36224
    nr_vmscan_immediate_reclaim 117
    nr_writeback_temp 0
    nr_isolated_anon 0
    nr_isolated_file 0
    nr_shmem     3815
    nr_dirtied   51415788
    nr_written   48993658
    numa_hit     1081691700
    numa_miss    0
    numa_foreign 0
    numa_interleave 25195
    numa_local   1081691700
    numa_other   0
    nr_anon_transparent_hugepages 199
        protection: (0, 0, 0, 0)
  pagesets
    cpu: 0
              count: 156
              high:  186
              batch: 31
  vm stats threshold: 64
    cpu: 1
              count: 177
              high:  186
              batch: 31
  vm stats threshold: 64
    cpu: 2
              count: 159
              high:  186
              batch: 31
  vm stats threshold: 64
    cpu: 3
              count: 161
              high:  186
              batch: 31
  vm stats threshold: 64
    cpu: 4
              count: 146
              high:  186
              batch: 31
  vm stats threshold: 64
    cpu: 5
              count: 98
              high:  186
              batch: 31
  vm stats threshold: 64
    cpu: 6
              count: 59
              high:  186
              batch: 31
  vm stats threshold: 64
    cpu: 7
              count: 54
              high:  186
              batch: 31
  vm stats threshold: 64
    cpu: 8
              count: 40
              high:  186
              batch: 31
  vm stats threshold: 64
    cpu: 9
              count: 32
              high:  186
              batch: 31
  vm stats threshold: 64
    cpu: 10
              count: 46
              high:  186
              batch: 31
  vm stats threshold: 64
    cpu: 11
              count: 57
              high:  186
              batch: 31
  vm stats threshold: 64
  all_unreclaimable: 0
  start_pfn:         1048576
  inactive_ratio:    11


--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
