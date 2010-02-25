Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 4B4A06B0047
	for <linux-mm@kvack.org>; Thu, 25 Feb 2010 08:10:50 -0500 (EST)
Received: by bwz19 with SMTP id 19so4936458bwz.6
        for <linux-mm@kvack.org>; Thu, 25 Feb 2010 05:10:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201002242152.55408.rjw@sisk.pl>
References: <9b2b86521001020703v23152d0cy3ba2c08df88c0a79@mail.gmail.com>
	 <201002232213.56455.rjw@sisk.pl>
	 <9b2b86521002240823t126d5ad8nbd292da0f4090e6c@mail.gmail.com>
	 <201002242152.55408.rjw@sisk.pl>
Date: Thu, 25 Feb 2010 13:10:43 +0000
Message-ID: <9b2b86521002250510m75c8b314o37388a04b53a2b67@mail.gmail.com>
Subject: Re: s2disk hang update
From: Alan Jenkins <sourcejedi.lkml@googlemail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Mel Gorman <mel@csn.ul.ie>, hugh.dickins@tiscali.co.uk, Pavel Machek <pavel@ucw.cz>, pm list <linux-pm@lists.linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 2/24/10, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> On Wednesday 24 February 2010, Alan Jenkins wrote:
>> On 2/23/10, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> ...
>> > My guess is that the preallocated memory pages freed by
>> > free_unnecessary_pages() go into a place from where they cannot be taken
>> > for
>> > subsequent NOIO allocations.  I have no idea why that happens though.
>> >
>> > To test that theory you can try to change GFP_IOFS to GFP_KERNEL in the
>> > calls to clear_gfp_allowed_mask() in kernel/power/hibernate.c (and in
>> > kernel/power/suspend.c for completness).
>>
>> Effectively forcing GFP_NOWAIT, so the allocation should fail instead
>> of hanging?
>>
>> It seems to stop the hang, but I don't see any other difference - the
>> hibernation process isn't stopped earlier, and I don't get any new
>> kernel messages about allocation failures.  I wonder if it's because
>> GFP_NOWAIT triggers ALLOC_HARDER.
>>
>> I have other evidence which argues for your theory:
>>
>> [ successful s2disk, with forced NOIO (but not NOWAIT), and test code
>> as attached ]
>>
>>  Freezing remaining freezable tasks ... (elapsed 0.01 seconds) done.
>>  1280 GFP_NOWAIT allocations of order 0 are possible
>>  640 GFP_NOWAIT allocations of order 1 are possible
>>  320 GFP_NOWAIT allocations of order 2 are possible
>>
>> [ note - 1280 pages is the maximum test allocation used here.  The
>> test code is only accurate when talking about smaller numbers of free
>> pages ]
>>
>>  1280 GFP_KERNEL allocations of order 0 are possible
>>  640 GFP_KERNEL allocations of order 1 are possible
>>  320 GFP_KERNEL allocations of order 2 are possible
>>
>>  PM: Preallocating image memory...
>>  212 GFP_NOWAIT allocations of order 0 are possible
>>  102 GFP_NOWAIT allocations of order 1 are possible
>>  50 GFP_NOWAIT allocations of order 2 are possible
>>
>>  Freeing all 90083 preallocated pages
>>  (and 0 highmem pages, out of 0)
>>  190 GFP_NOWAIT allocations of order 0 are possible
>>  102 GFP_NOWAIT allocations of order 1 are possible
>>  50 GFP_NOWAIT allocations of order 2 are possible
>>  1280 GFP_KERNEL allocations of order 0 are possible
>>  640 GFP_KERNEL allocations of order 1 are possible
>>  320 GFP_KERNEL allocations of order 2 are possible
>>  done (allocated 90083 pages)
>>
>> It looks like you're right and the freed pages are not accessible with
>> GFP_NOWAIT for some reason.
>
> I'd expect this, really.  There only is a limited number of pages you can
> allocate with GFP_NOWAIT.
>
>> I also tried a number of test runs with too many applications, and saw
>> this:
>>
>> Freeing all 104006 preallocated pages ...
>> 65 GFP_NOWAIT allocations of order 0 ...
>> 18 GFP_NOWAIT allocations of order 1 ...
>> 9 GFP_NOWAIT allocations of order 2 ...
>> 0 GFP_KERNEL allocations of order 0 are possible
>> ...
>
> Now that's interesting.  We've just freed 104006 pages and we can't allocate
> any, so where did all of these freed pages go, actually?
>
> OK, I think I see what the problem is.  Quite embarassing, actually ...
>
> Can you check if the patch below helps?
>
> Rafael

> -	while (to_free_normal > 0 && to_free_highmem > 0) {
> +	while (to_free_normal > 0 || to_free_highmem > 0) {


Yes, that seems to do it.  No more hangs so far (and I can still
reproduce the hang with too many applications if I un-apply the
patch).

I did see a non-fatal allocation failure though, so I'm still not sure
that the current implementation is strictly correct.

This is without the patch to increase "to_free_normal".  If I get the
allocation failure again, should I try testing the "free 20% extra"
patch?

Many thanks
Alan

Freezing remaining freezable tasks ... (elapsed 0.01 seconds) done.
PM: Preallocating image memory...
events/0: page allocation failure. order:0, mode:0xd0
Pid: 6, comm: events/0 Not tainted 2.6.33-rc8eeepc-00165-gecdaf98-dirty #101
Call Trace:
? printk+0xf/0x18
__alloc_pages_nodemask+0x46a/0x4dd
cache_alloc_refill+0x250/0x42d
kmem_cache_alloc+0x70/0xee
acpi_ps_alloc_op+0x4a/0x84
acpi_ps_create_scope_op+0xd/0x1c
acpi_ps_execute_method+0xed/0x29c
acpi_ns_evaluate+0x13b/0x241
acpi_evaluate_object+0x11c/0x243
? trace_hardirqs_on_caller+0x100/0x121
acpi_evaluate_integer+0x30/0x9c
acpi_thermal_get_temperature+0x2d/0x6a [thermal]
thermal_get_temp+0x1d/0x33 [thermal]
thermal_zone_device_update+0x29/0x1ce [thermal_sys]
? worker_thread+0x14b/0x250
thermal_zone_device_check+0xd/0xf [thermal_sys]
worker_thread+0x18d/0x250
? worker_thread+0x14b/0x250
? thermal_zone_device_check+0x0/0xf [thermal_sys]
? autoremove_wake_function+0x0/0x2f
? worker_thread+0x0/0x250
kthread+0x6a/0x6f
? kthread+0x0/0x6f
kernel_thread_helper+0x6/0x1a
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:  186, btch:  31 usd: 192
active_anon:4987 inactive_anon:5012 isolated_anon:0
 active_file:34 inactive_file:86 isolated_file:0
 unevictable:1042 dirty:0 writeback:0 unstable:0
 free:1188 slab_reclaimable:1510 slab_unreclaimable:2338
 mapped:1975 shmem:7985 pagetables:894 bounce:0
DMA free:2016kB min:88kB low:108kB high:132kB active_anon:0kB
inactive_anon:12kB active_file:8kB inactive_file:0kB unevictable:40kB
isolated(anon):0kB isolated(file):0kB present:15804kB mlocked:40kB
dirty:0kB writeback:0kB mapped:48kB shmem:0kB slab_reclaimable:8kB
slab_unreclaimable:4kB kernel_stack:0kB pagetables:8kB unstable:0kB
bounce:0kB writeback_tmp:0kB pages_scanned:3 all_unreclaimable? no
lowmem_reserve[]: 0 483 483 483
Normal free:2736kB min:2764kB low:3452kB high:4144kB
active_anon:19948kB inactive_anon:20036kB active_file:128kB
inactive_file:344kB unevictable:4128kB isolated(anon):0kB
isolated(file):0kB present:495300kB mlocked:4128kB dirty:0kB
writeback:0kB mapped:7852kB shmem:31940kB slab_reclaimable:6032kB
slab_unreclaimable:9348kB kernel_stack:920kB pagetables:3568kB
unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:20672
all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 0*4kB 0*8kB 0*16kB 1*32kB 1*64kB 1*128kB 1*256kB 1*512kB 1*1024kB
0*2048kB 0*4096kB = 2016kB
Normal: 684*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB
0*1024kB 0*2048kB 0*4096kB = 2736kB
9036 total pagecache pages
0 pages in swap cache
Swap cache stats: add 132152, delete 132152, find 22472/27086
Free swap  = 63644kB
Total swap = 358392kB
128880 pages RAM
0 pages HighMem
3743 pages reserved
20404 pages shared
116286 pages non-shared
hda-intel: IRQ timing workaround is activated for card #0. Suggest a
bigger bdl_pos_adj.
Thermal: failed to read out thermal zone 0
done (allocated 105868 pages)
PM: Allocated 423472 kbytes in 25.48 seconds (16.61 MB/s)
atl2 0000:03:00.0: PCI INT A disabled
ata_piix 0000:00:1f.2: PCI INT B disabled
HDA Intel 0000:00:1b.0: PCI INT A disabled
PM: freeze of devices complete after 163.921 msecs
PM: late freeze of devices complete after 2.951 msecs
Disabling non-boot CPUs ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
