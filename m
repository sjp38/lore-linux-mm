Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f198.google.com (mail-ig0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 089C06B025E
	for <linux-mm@kvack.org>; Tue, 24 May 2016 01:36:27 -0400 (EDT)
Received: by mail-ig0-f198.google.com with SMTP id f11so17291631igo.1
        for <linux-mm@kvack.org>; Mon, 23 May 2016 22:36:27 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id bx19si2433976igb.50.2016.05.23.22.36.25
        for <linux-mm@kvack.org>;
        Mon, 23 May 2016 22:36:26 -0700 (PDT)
Date: Tue, 24 May 2016 14:37:14 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm: page_is_guard return false when page_ext arrays are
 not allocated yet
Message-ID: <20160524053714.GB32186@js1304-P5Q-DELUXE>
References: <1463610225-29060-1-git-send-email-yang.shi@linaro.org>
 <20160519002809.GA10245@js1304-P5Q-DELUXE>
 <4cb2025a-1b62-9c66-3d61-b457c92a7401@linaro.org>
 <CAAmzW4OUmyPwQjvd7QUfc6W1Aic__TyAuH80MLRZNMxKy0-wPQ@mail.gmail.com>
 <a1c9d2e7-6fdf-593a-58b1-928a71d647ef@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a1c9d2e7-6fdf-593a-58b1-928a71d647ef@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Shi, Yang" <yang.shi@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linaro-kernel@lists.linaro.org

On Fri, May 20, 2016 at 10:00:06AM -0700, Shi, Yang wrote:
> On 5/19/2016 7:40 PM, Joonsoo Kim wrote:
> >2016-05-20 2:18 GMT+09:00 Shi, Yang <yang.shi@linaro.org>:
> >>On 5/18/2016 5:28 PM, Joonsoo Kim wrote:
> >>>
> >>>Vlastiml, thanks for ccing me on original bug report.
> >>>
> >>>On Wed, May 18, 2016 at 03:23:45PM -0700, Yang Shi wrote:
> >>>>
> >>>>When enabling the below kernel configs:
> >>>>
> >>>>CONFIG_DEFERRED_STRUCT_PAGE_INIT
> >>>>CONFIG_DEBUG_PAGEALLOC
> >>>>CONFIG_PAGE_EXTENSION
> >>>>CONFIG_DEBUG_VM
> >>>>
> >>>>kernel bootup may fail due to the following oops:
> >>>>
> >>>>BUG: unable to handle kernel NULL pointer dereference at           (null)
> >>>>IP: [<ffffffff8118d982>] free_pcppages_bulk+0x2d2/0x8d0
> >>>>PGD 0
> >>>>Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> >>>>Modules linked in:
> >>>>CPU: 11 PID: 106 Comm: pgdatinit1 Not tainted 4.6.0-rc5-next-20160427 #26
> >>>>Hardware name: Intel Corporation S5520HC/S5520HC, BIOS
> >>>>S5500.86B.01.10.0025.030220091519 03/02/2009
> >>>>task: ffff88017c080040 ti: ffff88017c084000 task.ti: ffff88017c084000
> >>>>RIP: 0010:[<ffffffff8118d982>]  [<ffffffff8118d982>]
> >>>>free_pcppages_bulk+0x2d2/0x8d0
> >>>>RSP: 0000:ffff88017c087c48  EFLAGS: 00010046
> >>>>RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000001
> >>>>RDX: 0000000000000980 RSI: 0000000000000080 RDI: 0000000000660401
> >>>>RBP: ffff88017c087cd0 R08: 0000000000000401 R09: 0000000000000009
> >>>>R10: ffff88017c080040 R11: 000000000000000a R12: 0000000000000400
> >>>>R13: ffffea0019810000 R14: ffffea0019810040 R15: ffff88066cfe6080
> >>>>FS:  0000000000000000(0000) GS:ffff88066cd40000(0000)
> >>>>knlGS:0000000000000000
> >>>>CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> >>>>CR2: 0000000000000000 CR3: 0000000002406000 CR4: 00000000000006e0
> >>>>Stack:
> >>>> ffff88066cd5bbd8 ffff88066cfe6640 0000000000000000 0000000000000000
> >>>> 0000001f0000001f ffff88066cd5bbe8 ffffea0019810000 000000008118f53e
> >>>> 0000000000000009 0000000000000401 ffffffff0000000a 0000000000000001
> >>>>Call Trace:
> >>>> [<ffffffff8118f602>] free_hot_cold_page+0x192/0x1d0
> >>>> [<ffffffff8118f69c>] __free_pages+0x5c/0x90
> >>>> [<ffffffff8262a676>] __free_pages_boot_core+0x11a/0x14e
> >>>> [<ffffffff8262a6fa>] deferred_free_range+0x50/0x62
> >>>> [<ffffffff8262aa46>] deferred_init_memmap+0x220/0x3c3
> >>>> [<ffffffff8262a826>] ? setup_per_cpu_pageset+0x35/0x35
> >>>> [<ffffffff8108b1f8>] kthread+0xf8/0x110
> >>>> [<ffffffff81c1b732>] ret_from_fork+0x22/0x40
> >>>> [<ffffffff8108b100>] ? kthread_create_on_node+0x200/0x200
> >>>>Code: 49 89 d4 48 c1 e0 06 49 01 c5 e9 de fe ff ff 4c 89 f7 44 89 4d b8
> >>>>4c 89 45 c0 44 89 5d c8 48 89 4d d0 e8 62 c7 07 00 48 8b 4d d0 <48> 8b 00 44
> >>>>8b 5d c8 4c 8b 45 c0 44 8b 4d b8 a8 02 0f 84 05 ff
> >>>>RIP  [<ffffffff8118d982>] free_pcppages_bulk+0x2d2/0x8d0
> >>>> RSP <ffff88017c087c48>
> >>>>CR2: 0000000000000000
> >>>>
> >>>>The problem is lookup_page_ext() returns NULL then page_is_guard() tried
> >>>>to
> >>>>access it in page freeing.
> >>>>
> >>>>page_is_guard() depends on PAGE_EXT_DEBUG_GUARD bit of page extension
> >>>>flag, but
> >>>>freeing page might reach here before the page_ext arrays are allocated
> >>>>when
> >>>>feeding a range of pages to the allocator for the first time during
> >>>>bootup or
> >>>>memory hotplug.
> >>>
> >>>
> >>>Patch itself looks find to me because I also found that this kind of
> >>>problem happens during memory hotplug. So, we need to fix more sites,
> >>>all callers of lookup_page_ext().
> >>
> >>
> >>Yes, I agree. I will come up with a patch or a couple of patches to check
> >>the return value of lookup_page_ext().
> >>
> >>>
> >>>But, I'd like to know how your problem occurs during bootup.
> >>>debug_guardpage_enabled() is turned to 'enable' after page_ext is
> >>>initialized. Before that, page_is_guard() unconditionally returns
> >>>false so I think that the problem what you mentioned can't happen.
> >>>
> >>>Could you check that when debug_guardpage_enabled() returns 'enable'
> >>>and init_section_page_ext() is called?
> >>
> >>
> >>I think the problem is I have CONFIG_DEFERRED_STRUCT_PAGE_INIT enabled,
> >>which will defer some struct pages initialization to "pgdatinitX" kernel
> >>thread in page_alloc_init_late(). But, page_ext_init() is called before it.
> >>So, it leads debug_guardpage_enabled() return true, but page extension is
> >>not allocated yet for the struct pages initialized by "pgdatinitX".
> >
> >No. After page_ext_init(), it is ensured that all page extension is initialized.
> >
> >>It sounds page_ext_init() should be called after page_alloc_init_late(). Or
> >>it should be just incompatible with CONFIG_DEFERRED_STRUCT_PAGE_INIT.
> >>
> >>I will try to move the init call around.
> >
> >We need to investigate more. I guess that problem is introduced by
> >CONFIG_DEFERRED_STRUCT_PAGE_INIT. It makes pfn_to_nid() invalid
> >until page_alloc_init_late() is done. That is a big side-effect. If
> >there is pfn walker
> >and it uses pfn_to_nid() between memmap_init_zone() and page_alloc_init_late(),
> >it also has same problem. So, we need to think how to fix it more
> >carefully.
> 
> Thanks for the analysis. I think you are correct. Since pfn_to_nid()
> depends on memmap which has not been fully setup yet until
> page_alloc_init_late() is done.
> 
> So, for such usecase early_pfn_to_nid() should be used.
> 
> >
> >Anyway, to make sure that my assumption is true, could you confirm that
> >below change fix your problem?
> 
> Yes, it does.
> 
> >
> >Thanks.
> >
> >----->8----------
> >diff --git a/mm/page_ext.c b/mm/page_ext.c
> >index 2d864e6..cac5dc9 100644
> >--- a/mm/page_ext.c
> >+++ b/mm/page_ext.c
> >@@ -391,7 +391,7 @@ void __init page_ext_init(void)
> >                         * -------------pfn-------------->
> >                         * N0 | N1 | N2 | N0 | N1 | N2|....
> >                         */
> >-                       if (pfn_to_nid(pfn) != nid)
> >+                       if (!early_pfn_in_nid(pfn nid))
> 
> early_pfn_in_nid() is static function in page_alloc.c. I'm supposed
> early_pfn_to_nid() should be used.

Thanks for checking. Then, please revert your patch "mm: call
page_ext_init() after all struct pages are initialized" and apply this
change, because deferring page_ext_init() would make page owner which
uses page_ext miss some early page allocation callsites. Although it
already miss some early page allocation callsites, we don't need to
miss more.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
