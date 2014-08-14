Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id A22406B0036
	for <linux-mm@kvack.org>; Thu, 14 Aug 2014 11:36:59 -0400 (EDT)
Received: by mail-qc0-f171.google.com with SMTP id r5so1216185qcx.16
        for <linux-mm@kvack.org>; Thu, 14 Aug 2014 08:36:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l43si7623768qga.73.2014.08.14.08.36.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Aug 2014 08:36:58 -0700 (PDT)
Date: Thu, 14 Aug 2014 12:13:30 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: mm: compaction: buffer overflow in isolate_migratepages_range
Message-ID: <20140814151329.GA22187@optiplex.redhat.com>
References: <53E6CEAA.9020105@oracle.com>
 <CAPAsAGxcC0+V1ZzR3LL=ASx=KXifPbw_cyvHCBBJT4mZ1grg+Q@mail.gmail.com>
 <20140813153501.GE21041@optiplex.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140813153501.GE21041@optiplex.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrey Ryabinin <a.ryabinin@samsung.com>

On Wed, Aug 13, 2014 at 12:35:02PM -0300, Rafael Aquini wrote:
> On Sun, Aug 10, 2014 at 12:49:47PM +0400, Andrey Ryabinin wrote:
> > 2014-08-10 5:45 GMT+04:00 Sasha Levin <sasha.levin@oracle.com>:
> > > Hi all,
> > >
> > > While fuzzing with trinity inside a KVM tools guest running the latest -next
> > > kernel with the KASAN patchset, I've stumbled on the following spew:
> > >
> > >
> > > [ 3837.070452] ==================================================================
> > > [ 3837.073101] AddressSanitizer: buffer overflow in isolate_migratepages_range+0x85f/0xd90 at addr ffff88051b70eb49
> > > [ 3837.076310] page:ffffea00146dc380 count:0 mapcount:0 mapping:          (null) index:0x0
> > > [ 3837.079876] page flags: 0xafffff80008000(tail)
> > > [ 3837.114592] page dumped because: kasan error
> > > [ 3837.115897] CPU: 4 PID: 29613 Comm: trinity-c467 Not tainted 3.16.0-next-20140808-sasha-00051-gf368221 #1051
> > > [ 3837.118024]  00000000000000fc 0000000000000000 ffffea00146dc380 ffff8801f326f718
> > > [ 3837.119837]  ffffffff97e0d344 ffff8801f326f7e8 ffff8801f326f7d8 ffffffff9342d5bc
> > > [ 3837.121708]  ffffea00085163c0 0000000000000000 ffff8801f326f8e0 ffffffff93fe02fb
> > > [ 3837.123704] Call Trace:
> > > [ 3837.124272] dump_stack (lib/dump_stack.c:52)
> > > [ 3837.125166] kasan_report_error (mm/kasan/report.c:98 mm/kasan/report.c:166)
> > > [ 3837.126128] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:33)
> > > [ 3837.127462] ? retint_restore_args (arch/x86/kernel/entry_64.S:828)
> > > [ 3837.128753] __asan_load8 (mm/kasan/kasan.c:364)
> > > [ 3837.129914] ? isolate_migratepages_range (./arch/x86/include/asm/bitops.h:311 include/linux/pagemap.h:70 include/linux/balloon_compaction.h:131 include/linux/balloon_compaction.h:156 mm/compaction.c:596)
> > > [ 3837.131613] isolate_migratepages_range (./arch/x86/include/asm/bitops.h:311 include/linux/pagemap.h:70 include/linux/balloon_compaction.h:131 include/linux/balloon_compaction.h:156 mm/compaction.c:596)
> > > [ 3837.132838] compact_zone (mm/compaction.c:877 mm/compaction.c:1044)
> > > [ 3837.133818] compact_zone_order (mm/compaction.c:1106)
> > > [ 3837.134982] try_to_compact_pages (mm/compaction.c:1161)
> > > [ 3837.135970] __alloc_pages_direct_compact (mm/page_alloc.c:2313)
> > > [ 3837.137217] ? next_zones_zonelist (mm/mmzone.c:72)
> > > [ 3837.138861] __alloc_pages_nodemask (mm/page_alloc.c:2640 mm/page_alloc.c:2806)
> > > [ 3837.139897] ? check_chain_key (kernel/locking/lockdep.c:2190)
> > > [ 3837.141220] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
> > > [ 3837.142434] alloc_pages_vma (mm/mempolicy.c:2046)
> > > [ 3837.143479] ? do_huge_pmd_wp_page (mm/huge_memory.c:774 mm/huge_memory.c:1123)
> > > [ 3837.144663] do_huge_pmd_wp_page (mm/huge_memory.c:774 mm/huge_memory.c:1123)
> > > [ 3837.145653] handle_mm_fault (mm/memory.c:3312 mm/memory.c:3370)
> > > [ 3837.146717] ? vmacache_find (mm/vmacache.c:100 (discriminator 1))
> > > [ 3837.147404] ? find_vma (mm/mmap.c:2024)
> > > [ 3837.147982] __do_page_fault (arch/x86/mm/fault.c:1231)
> > > [ 3837.148613] ? context_tracking_user_exit (kernel/context_tracking.c:184)
> > > [ 3837.149388] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
> > > [ 3837.150212] ? trace_hardirqs_off_caller (kernel/locking/lockdep.c:2641 (discriminator 8))
> > > [ 3837.150977] ? trace_hardirqs_off (kernel/locking/lockdep.c:2647)
> > > [ 3837.151686] trace_do_page_fault (arch/x86/mm/fault.c:1314 include/linux/jump_label.h:115 include/linux/context_tracking_state.h:27 include/linux/context_tracking.h:45 arch/x86/mm/fault.c:1315)
> > > [ 3837.152870] do_async_page_fault (arch/x86/kernel/kvm.c:279)
> > > [ 3837.153886] async_page_fault (arch/x86/kernel/entry_64.S:1313)
> > > [ 3837.155293] Read of size 8 by thread T29613:
> > > [ 3837.156058] Memory state around the buggy address:
> > > [ 3837.156885]  ffff88051b70e880: 00 00 00 00 00 00 00 fc fc fc fc fc fc fc fc fc
> > > [ 3837.158141]  ffff88051b70e900: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
> > > [ 3837.159492]  ffff88051b70e980: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
> > > [ 3837.160863]  ffff88051b70ea00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> > > [ 3837.162165]  ffff88051b70ea80: 00 00 00 00 00 00 00 fc fc fc fc fc fc fc fc fc
> > > [ 3837.163552] >ffff88051b70eb00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
> > > [ 3837.164866]                                               ^
> > > [ 3837.165914]  ffff88051b70eb80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
> > > [ 3837.167317]  ffff88051b70ec00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> > > [ 3837.168616]  ffff88051b70ec80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> > > [ 3837.169898]  ffff88051b70ed00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> > > [ 3837.171298]  ffff88051b70ed80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> > > [ 3837.172611] ==================================================================
> > >
> > >
> > > Thanks,
> > > Sasha
> 
> Nice pick from the sanitizer bits!
> 
> > 
> > Bad access happens when we read page->mapping->flags in mapping_ballon().
> > Address of page->mapping->flags here is ffff88051b70eb49, so the
> > lowest bit is set,
> > which means that the lowest bit is also set in page->mapping pointer.
> > So page->mapping is a pointer to anon_vma, not to address_space.
> >
> 
> Yeah, it happens because I failed to anticipate a race window opening where
> balloon_page_movable() can stumble across an anon page being released --
> somewhere in the midway of __page_cache_release() & free_pages_prepare() 
> down on the put_page() codepath -- while isolate_migratepages_range() performs
> its loop in the (lru) unlocked case.
>

Giving it a second thought, I see my first analisys (above) isn't accurate, 
as if we had raced against a page being released at the point I mentioned,
balloon_page_movable() would have bailed out while performing its
page_flags_cleared() checkpoint. 

But I now can see from where this occurrence is coming from, actually.

The real race window for this issue opens when balloon_page_movable() 
checkpoint @ isolate_migratepages_range() stumbles across a (new) 
page under migration at:

static int move_to_new_page(struct page *newpage, struct page *page, ...
{
   ...
   newpage->mapping = page->mapping;


At this point, *newpage points to a fresh page coming out from the allocator
(just as any other possible ballooned page), but it gets its ->mapping
pointer set, which can create the conditions to the access (for mapping flag
checking purposes only) KASAN is complaining about, if *page happens to
be pointing to an anon page.

 
> Although harmless, IMO, as we only go for the isolation step if we hold the
> lru lock (and the check is re-done under lock safety) this is an
> annoying thing we have to get rid of to not defeat the purpose of having
> the kasan in place.
>

It still a harmless condition as before, but considering what goes above
I'm now convinced & confident the patch proposed by Andrey is the real fix 
for such occurrences.

Cheers,
-- Rafael 

>  
> > I guess this could be fixed with something like following (completely
> > untested) patch:
> >
> Despite not having it tested, as well: yes, I belive this should be the way 
> to sort out that warning, for the aforementioned unlocked iteration case of
> isolate_migratepages_range(). 
>  
> > --- a/include/linux/balloon_compaction.h
> > +++ b/include/linux/balloon_compaction.h
> > @@ -127,7 +127,7 @@ static inline bool page_flags_cleared(struct page *page)
> >   */
> >  static inline bool __is_movable_balloon_page(struct page *page)
> >  {
> > -       struct address_space *mapping = page->mapping;
> > +       struct address_space *mapping = page_mapping(page);
> >         return mapping_balloon(mapping);
> >  }
> > 
> 
> Please, keep me in the loop if things don't settle properly.
> 
> Cheers,
> -- Rafael
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
