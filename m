Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 50C386B00C5
	for <linux-mm@kvack.org>; Sat, 16 Feb 2013 23:55:16 -0500 (EST)
Received: by mail-we0-f171.google.com with SMTP id u54so3983230wey.16
        for <linux-mm@kvack.org>; Sat, 16 Feb 2013 20:55:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <51204F6C.2090603@gmail.com>
References: <CAA25o9T8cBhuFnesnxHDsv3PmV8tiHKoLz0dGQeUSCvtpBBv3A@mail.gmail.com>
	<51204F6C.2090603@gmail.com>
Date: Sat, 16 Feb 2013 20:55:14 -0800
Message-ID: <CAA25o9S6kuXtFbQVoSuXdqN5G6Ptk=aZtUJ8kAuodT0Texi9cQ@mail.gmail.com>
Subject: Re: another allocation livelock with zram
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
Cc: linux-mm@kvack.org

On Sat, Feb 16, 2013 at 7:33 PM, Jaegeuk Hanse <jaegeuk.hanse@gmail.com> wrote:
>
> On 11/21/2012 07:46 AM, Luigi Semenzato wrote:
>>
>> Greetings MM folks,
>>
>> and thanks again for fixing my previous hang-with-zram problem.  I am
>> now running into a similar problem and I hope I will not take
>> advantage of your kindness by asking for further advice.
>>
>> By running a few dozen memory-hungry processes on an ARM cpu with 2 Gb
>> RAM, with zram enabled, I can easily get into a situation where all
>> processes are either:
>>
>> 1. blocked in a futex
>> 2. trying unsuccessfully to allocate memory
>>
>> This happens when there should still be plenty of memory: the zram
>> swap device is about 1/3 full. (The output of SysRq-M is at the end.)
>> Yet the SI and SO fields of vmstat stay at 0, and CPU utilization is
>> 100% system.
>>
>> procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
>>   r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
>> 46  0 1076432  13636   2844 216648    0    0     0     0  621  229  0 100  0  0
>> 44  0 1076432  13636   2844 216648    0    0     0     0  618  204  0 100  0  0
>>
>> I added counters in various places in the page allocator to see which
>> paths were being taken and noticed the following facts:
>>
>> - alloc_page_slowpath is looping, apparently trying to rebalance.  It
>> calls alloc_pages_direct_reclaim at a rate of about 155 times/second,
>> and gets one page about once every 500 calls.  Did_some_progress is
>
>
> You use which tool to get this data?

No tool.  As I mentioned a few lines above, I added counters in the code,
and printed them together with other stats with SysRq-M (if I remember
correctly).

To answer your previous question, I think everything was working as
expected.  I think the anomaly was due to a mistake in my synthetic load.
I was allocating more zero-filled pages as time went by, and those
pages compress very well :-)

I apologize if I don't remember the details, but it's been a while :-)


>
>> always set to true.  Then should_alloc_retry returns true (because
>> order < PAGE_ALLOC_COSTLY_ORDER).
>>
>> - kswapd is asleep and is not woken up because alloc_page_slowpath
>> never goes to the "restart" label.
>>
>> My questions are:
>>
>> 1. is it obvious to any of you what is going wrong?
>> 1.1 is the allocation failing because nobody is waking up kswapd?  And
>> if so, why not?
>>
>> 2. if it's not obvious, what are the next things to look into?
>>
>> 3. is there a better way of debugging this?
>>
>> Thanks!
>> Luigi
>>
>> [    0.000000] Linux version 3.4.0
>> (semenzato@luigi.mtv.corp.google.com) (gcc version 4.6.x-google
>> 20120301 (prerelease) (gcc-4.6.3_cos_gg_2a32ae6) ) #26 SMP Tue Nov 20
>> 14:27:15 PST 2012
>> [    0.000000] CPU: ARMv7 Processor [410fc0f4] revision 4 (ARMv7), cr=10c5387d
>> [    0.000000] CPU: PIPT / VIPT nonaliasing data cache, PIPT instruction cache
>> [    0.000000] Machine: SAMSUNG EXYNOS5 (Flattened Device Tree),
>> model: Google Snow
>> ...
>> [  198.564328] SysRq : Show Memory
>> [  198.564347] Mem-info:
>> [  198.564355] Normal per-cpu:
>> [  198.564364] CPU    0: hi:  186, btch:  31 usd:   0
>> [  198.564373] CPU    1: hi:  186, btch:  31 usd:   0
>> [  198.564381] HighMem per-cpu:
>> [  198.564389] CPU    0: hi:   90, btch:  15 usd:   0
>> [  198.564397] CPU    1: hi:   90, btch:  15 usd:   0
>> [  198.564411] active_anon:196868 inactive_anon:66835 isolated_anon:47
>> [  198.564415]  active_file:13931 inactive_file:11043 isolated_file:0
>> [  198.564419]  unevictable:0 dirty:4 writeback:1 unstable:0
>> [  198.564423]  free:3409 slab_reclaimable:2583 slab_unreclaimable:3337
>> [  198.564427]  mapped:137910 shmem:29899 pagetables:3972 bounce:0
>> [  198.564449] Normal free:13384kB min:5380kB low:6724kB high:8068kB
>> active_anon:782052kB inactive_anon:261808kB active_file:25020kB
>> inactive_file:24900kB unevictable:0kB isolated(anon):16kB
>> isolated(file):0kB present:1811520kB mlocked:0kB dirty:12kB
>> writeback:0kB mapped:461296kB shmem:115892kB slab_reclaimable:10332kB
>> slab_unreclaimable:13348kB kernel_stack:3008kB pagetables:15888kB
>> unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:107282320
>> all_unreclaimable? no
>> [  198.564474] lowmem_reserve[]: 0 2095 2095
>> [  198.564499] HighMem free:252kB min:260kB low:456kB high:656kB
>> active_anon:5420kB inactive_anon:5532kB active_file:30704kB
>> inactive_file:19272kB unevictable:0kB isolated(anon):172kB
>> isolated(file):0kB present:268224kB mlocked:0kB dirty:4kB
>> writeback:4kB mapped:90344kB shmem:3704kB slab_reclaimable:0kB
>> slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB
>> bounce:0kB writeback_tmp:0kB pages_scanned:7081406 all_unreclaimable?
>> no
>> [  198.564523] lowmem_reserve[]: 0 0 0
>> [  198.564536] Normal: 1570*4kB 6*8kB 1*16kB 0*32kB 0*64kB 1*128kB
>> 1*256kB 1*512kB 0*1024kB 1*2048kB 1*4096kB = 13384kB
>> [  198.564574] HighMem: 59*4kB 2*8kB 0*16kB 0*32kB 0*64kB 0*128kB
>> 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 252kB
>> [  198.564610] 123112 total pagecache pages
>> [  198.564616] 68239 pages in swap cache
>> [  198.564622] Swap cache stats: add 466115, delete 397876, find 31817/56350
>> [  198.564630] Free swap  = 1952336kB
>> [  198.564635] Total swap = 3028768kB
>> [  198.564640] xxcount_nr_reclaimed 358488
>> [  198.564646] xxcount_nr_reclaims 6201
>> [  198.564651] xxcount_aborted_reclaim 0
>> [  198.564656] xxcount_more_to_do 5137
>> [  198.564662] xxcount_direct_reclaims 17065
>> [  198.564667] xxcount_failed_direct_reclaims 10708
>> [  198.564673] xxcount_no_progress 5696
>> [  198.564678] xxcount_restarts 5696
>> [  198.564683] xxcount_should_alloc_retry 5008
>> [  198.564688] xxcount_direct_compact 1
>> [  198.564693] xxcount_alloc_failed 115
>> [  198.564699] xxcount_gfp_nofail 0
>> [  198.564704] xxcount_costly_order 5009
>> [  198.564709] xxcount_repeat 0
>> [  198.564714] xxcount_kswapd_nap 2210
>> [  198.564719] xxcount_kswapd_sleep 17
>> [  198.564724] xxcount_kswapd_loop 2211
>> [  198.564729] xxcount_kswapd_try_to_sleep 2210
>> [  198.575349] 524288 pages of RAM
>> [  198.575358] 4420 free pages
>> [  198.575365] 7122 reserved pages
>> [  198.575371] 4091 slab pages
>> [  198.575378] 302549 pages shared
>> [  198.575384] 68239 pages swap cached
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
