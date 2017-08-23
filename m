Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2D0526B04EC
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 12:21:45 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id y193so572884oie.4
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 09:21:45 -0700 (PDT)
Received: from mail-io0-x243.google.com (mail-io0-x243.google.com. [2607:f8b0:4001:c06::243])
        by mx.google.com with ESMTPS id x6si1642970oia.323.2017.08.23.09.21.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 09:21:43 -0700 (PDT)
Received: by mail-io0-x243.google.com with SMTP id z66so10791ioi.0
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 09:21:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170823034439.GA29634@yu-desktop-1.sh.intel.com>
References: <1503372002-13310-1-git-send-email-yu.c.chen@intel.com>
 <1595884.XH9dSsijkg@aspire.rjw.lan> <20170823034439.GA29634@yu-desktop-1.sh.intel.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Wed, 23 Aug 2017 18:21:42 +0200
Message-ID: <CAJZ5v0ibzuU=pzYZUTaLF7zGPU=CXU+H5HD+gy=ag6rKLyuL1A@mail.gmail.com>
Subject: Re: [PATCH][v2] PM / Hibernate: Feed the wathdog when creating snapshot
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Yu <yu.c.chen@intel.com>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Len Brown <lenb@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Linux PM <linux-pm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Aug 23, 2017 at 5:44 AM, Chen Yu <yu.c.chen@intel.com> wrote:
> On Tue, Aug 22, 2017 at 02:55:39PM +0200, Rafael J. Wysocki wrote:
>> On Tuesday, August 22, 2017 5:20:02 AM CEST Chen Yu wrote:
>> > There is a problem that when counting the pages for creating
>> > the hibernation snapshot will take significant amount of
>> > time, especially on system with large memory. Since the counting
>> > job is performed with irq disabled, this might lead to NMI lockup.
>> > The following warning were found on a system with 1.5TB DRAM:
>> >
>> > [ 1124.758184] Freezing user space processes ... (elapsed 0.002 seconds) done.
>> > [ 1124.768721] OOM killer disabled.
>> > [ 1124.847009] PM: Preallocating image memory...
>> > [ 1139.392042] NMI watchdog: Watchdog detected hard LOCKUP on cpu 27
>> > [ 1139.392076] CPU: 27 PID: 3128 Comm: systemd-sleep Not tainted 4.13.0-0.rc2.git0.1.fc27.x86_64 #1
>> > [ 1139.392077] task: ffff9f01971ac000 task.stack: ffffb1a3f325c000
>> > [ 1139.392083] RIP: 0010:memory_bm_find_bit+0xf4/0x100
>> > [ 1139.392084] RSP: 0018:ffffb1a3f325fc20 EFLAGS: 00000006
>> > [ 1139.392084] RAX: 0000000000000000 RBX: 0000000013b83000 RCX: ffff9fbe89caf000
>> > [ 1139.392085] RDX: ffffb1a3f325fc30 RSI: 0000000000003200 RDI: ffff9fbeaffffe80
>> > [ 1139.392085] RBP: ffffb1a3f325fc40 R08: 0000000013b80000 R09: ffff9fbe89c54878
>> > [ 1139.392085] R10: ffffb1a3f325fc2c R11: 0000000013b83200 R12: 0000000000000400
>> > [ 1139.392086] R13: fffffd552e0c0000 R14: ffff9fc1bffd31e0 R15: 0000000000000202
>> > [ 1139.392086] FS:  00007f3189704180(0000) GS:ffff9fbec8ec0000(0000) knlGS:0000000000000000
>> > [ 1139.392087] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> > [ 1139.392087] CR2: 00000085da0f7398 CR3: 000001771cf9a000 CR4: 00000000007406e0
>> > [ 1139.392088] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> > [ 1139.392088] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
>> > [ 1139.392088] PKRU: 55555554
>> > [ 1139.392089] Call Trace:
>> > [ 1139.392092]  ? memory_bm_set_bit+0x29/0x60
>> > [ 1139.392094]  swsusp_set_page_free+0x2b/0x30
>> > [ 1139.392098]  mark_free_pages+0x147/0x1c0
>> > [ 1139.392099]  count_data_pages+0x41/0xa0
>> > [ 1139.392101]  hibernate_preallocate_memory+0x80/0x450
>> > [ 1139.392102]  hibernation_snapshot+0x58/0x410
>> > [ 1139.392103]  hibernate+0x17c/0x310
>> > [ 1139.392104]  state_store+0xdf/0xf0
>> > [ 1139.392107]  kobj_attr_store+0xf/0x20
>> > [ 1139.392111]  sysfs_kf_write+0x37/0x40
>> > [ 1139.392113]  kernfs_fop_write+0x11c/0x1a0
>> > [ 1139.392117]  __vfs_write+0x37/0x170
>> > [ 1139.392121]  ? handle_mm_fault+0xd8/0x230
>> > [ 1139.392122]  vfs_write+0xb1/0x1a0
>> > [ 1139.392123]  SyS_write+0x55/0xc0
>> > [ 1139.392126]  entry_SYSCALL_64_fastpath+0x1a/0xa5
>> > ...
>> > [ 1144.690405] done (allocated 6590003 pages)
>> > [ 1144.694971] PM: Allocated 26360012 kbytes in 19.89 seconds (1325.28 MB/s)
>> >
>> > It has taken nearly 20 seconds(2.10GHz CPU) thus the NMI lockup
>> > was triggered. In case the timeout of the NMI watch dog has been
>> > set to 1 second, a safe interval should be 6590003/20 = 320k pages
>> > in theory. However there might also be some platforms running at a
>> > lower frequency, so feed the watchdog every 128k pages(per Andrew's
>> > suggestion, this should avoid the modulus operation).
>> >
>> > Reported-by: Jan Filipcewicz <jan.filipcewicz@intel.com>
>> > Suggested-by: Michal Hocko <mhocko@suse.com>
>> > Reviewed-by: Michal Hocko <mhocko@suse.com>
>> > Cc: Andrew Morton <akpm@linux-foundation.org>
>> > Cc: Michal Hocko <mhocko@kernel.org>
>> > Cc: Mel Gorman <mgorman@techsingularity.net>
>> > Cc: Vlastimil Babka <vbabka@suse.cz>
>> > Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
>> > Cc: Len Brown <lenb@kernel.org>
>> > Cc: Dan Williams <dan.j.williams@intel.com>
>> > Cc: linux-pm@vger.kernel.org
>> > Cc: linux-kernel@vger.kernel.org
>> > Signed-off-by: Chen Yu <yu.c.chen@intel.com>
>> > ---
>> > v2: Use an interval of 128k instead of 100k to
>> >     avoid the modulus operation.
>> > --
>> >  mm/page_alloc.c | 17 +++++++++++++++--
>> >  1 file changed, 15 insertions(+), 2 deletions(-)
>> >
>> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> > index 1bad301..3cf4201 100644
>> > --- a/mm/page_alloc.c
>> > +++ b/mm/page_alloc.c
>> > @@ -66,6 +66,7 @@
>> >  #include <linux/kthread.h>
>> >  #include <linux/memcontrol.h>
>> >  #include <linux/ftrace.h>
>> > +#include <linux/nmi.h>
>> >
>> >  #include <asm/sections.h>
>> >  #include <asm/tlbflush.h>
>> > @@ -2535,9 +2536,15 @@ void drain_all_pages(struct zone *zone)
>> >
>> >  #ifdef CONFIG_HIBERNATION
>> >
>> > +/*
>> > + * Touch the watchdog for every WD_INTERVAL_PAGE pages,
>> > + * choose a power of 2 to avoid the modulus operation.
>> > + */
>> > +#define WD_INTERVAL_PAGE   (128*1024)
>>
>> Sort of on a second thought I would define
>>
>> #define WD_PAGE_COUNT         (128*1024)
>>
>> and then ->
>>
>> > +
>> >  void mark_free_pages(struct zone *zone)
>> >  {
>> > -   unsigned long pfn, max_zone_pfn;
>> > +   unsigned long pfn, max_zone_pfn, page_num = 0;
>>
>> +     unsigned long pfn, max_zone_pfn, page_count = WD_PAGE_COUNT;
>>
>> >     unsigned long flags;
>> >     unsigned int order, t;
>> >     struct page *page;
>> > @@ -2552,6 +2559,9 @@ void mark_free_pages(struct zone *zone)
>> >             if (pfn_valid(pfn)) {
>> >                     page = pfn_to_page(pfn);
>> >
>> > +                   if (!((page_num++) % WD_INTERVAL_PAGE))
>> > +                           touch_nmi_watchdog();
>> > +
>>
>> ->
>>
>>       if (!--page_count) {
>>               touch_nmi_watchdog();
>>               page_count = WD_PAGE_COUNT;
>>       }
>>
> I guess this is to avoid the possible overflow if the page number is too large?
> I'll send another version out.

No, it's just one (a % b) evaluation per page less.  The assignments
are every WD_PAGE_COUNT pages, so much less frequent.

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
