Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8FEC26B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 00:47:02 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id b126so94973385ite.3
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 21:47:02 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id c125si16544940itg.12.2016.06.15.21.47.00
        for <linux-mm@kvack.org>;
        Wed, 15 Jun 2016 21:47:01 -0700 (PDT)
Date: Thu, 16 Jun 2016 13:47:10 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v7 00/12] Support non-lru page migration
Message-ID: <20160616044710.GP17127@bbox>
References: <1464736881-24886-1-git-send-email-minchan@kernel.org>
 <20160615075909.GA425@swordfish>
 <20160615231248.GI17127@bbox>
 <20160616024827.GA497@swordfish>
 <20160616025800.GO17127@bbox>
 <20160616042343.GA516@swordfish>
MIME-Version: 1.0
In-Reply-To: <20160616042343.GA516@swordfish>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, dri-devel@lists.freedesktop.org, Hugh Dickins <hughd@google.com>, John Einar Reitan <john.reitan@foss.arm.com>, Jonathan Corbet <corbet@lwn.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Aquini <aquini@redhat.com>, Rik van Riel <riel@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, virtualization@lists.linux-foundation.org, Gioh Kim <gi-oh.kim@profitbricks.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Sangseok Lee <sangseok.lee@lge.com>, Kyeongdon Kim <kyeongdon.kim@lge.com>, Chulmin Kim <cmlaika.kim@samsung.com>

On Thu, Jun 16, 2016 at 01:23:43PM +0900, Sergey Senozhatsky wrote:
> On (06/16/16 11:58), Minchan Kim wrote:
> [..]
> > RAX: 2065676162726166 so rax is totally garbage, I think.
> > It means obj_to_head returns garbage because get_first_obj_offset is
> > utter crab because (page_idx / class->pages_per_zspage) was totally
> > wrong.
> > 
> > > 					^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> > >     6408:       f0 0f ba 28 00          lock btsl $0x0,(%rax)
> >  
> > <snip>
> > 
> > > > Could you test with [zsmalloc: keep first object offset in struct page]
> > > > in mmotm?
> > > 
> > > sure, I can.  will it help, tho? we have a race condition here I think.
> > 
> > I guess root cause is caused by get_first_obj_offset.
> 
> sounds reasonable.
> 
> > Please test with it.
> 
> 
> this is what I'm getting with the [zsmalloc: keep first object offset in struct page]
> applied:  "count:0 mapcount:-127". which may be not related to zsmalloc at this point.
> 
> kernel: BUG: Bad page state in process khugepaged  pfn:101db8
> kernel: page:ffffea0004076e00 count:0 mapcount:-127 mapping:          (null) index:0x1

Hm, it seems double free.

It doen't happen if you disable zram? IOW, it seems to be related
zsmalloc migration?

How easy can you reprodcue it? Could you bisect it?

> kernel: flags: 0x8000000000000000()
> kernel: page dumped because: nonzero mapcount
> kernel: Modules linked in: lzo zram zsmalloc mousedev coretemp hwmon crc32c_intel snd_hda_codec_realtek i2c_i801 snd_hda_codec_generic r8169 mii snd_hda_intel snd_hda_codec snd_hda_core acpi_cpufreq snd_pcm snd_timer snd soundcore lpc_ich processor mfd_core sch_fq_codel sd_mod hid_generic usb
> kernel: CPU: 3 PID: 38 Comm: khugepaged Not tainted 4.7.0-rc3-next-20160615-dbg-00005-gfd11984-dirty #491
> kernel:  0000000000000000 ffff8801124c73f8 ffffffff814d69b0 ffffea0004076e00
> kernel:  ffffffff81e658a0 ffff8801124c7420 ffffffff811e9b63 0000000000000000
> kernel:  ffffea0004076e00 ffffffff81e658a0 ffff8801124c7440 ffffffff811e9ca9
> kernel: Call Trace:
> kernel:  [<ffffffff814d69b0>] dump_stack+0x68/0x92
> kernel:  [<ffffffff811e9b63>] bad_page+0x158/0x1a2
> kernel:  [<ffffffff811e9ca9>] free_pages_check_bad+0xfc/0x101
> kernel:  [<ffffffff811ee516>] free_hot_cold_page+0x135/0x5de
> kernel:  [<ffffffff811eea26>] __free_pages+0x67/0x72
> kernel:  [<ffffffff81227c63>] release_freepages+0x13a/0x191
> kernel:  [<ffffffff8122b3c2>] compact_zone+0x845/0x1155
> kernel:  [<ffffffff8122ab7d>] ? compaction_suitable+0x76/0x76
> kernel:  [<ffffffff8122bdb2>] compact_zone_order+0xe0/0x167
> kernel:  [<ffffffff8122bcd2>] ? compact_zone+0x1155/0x1155
> kernel:  [<ffffffff8122ce88>] try_to_compact_pages+0x2f1/0x648
> kernel:  [<ffffffff8122ce88>] ? try_to_compact_pages+0x2f1/0x648
> kernel:  [<ffffffff8122cb97>] ? compaction_zonelist_suitable+0x3a6/0x3a6
> kernel:  [<ffffffff811ef1ea>] ? get_page_from_freelist+0x2c0/0x133c
> kernel:  [<ffffffff811f0350>] __alloc_pages_direct_compact+0xea/0x30d
> kernel:  [<ffffffff811f0266>] ? get_page_from_freelist+0x133c/0x133c
> kernel:  [<ffffffff811ee3b2>] ? drain_all_pages+0x1d6/0x205
> kernel:  [<ffffffff811f21a8>] __alloc_pages_nodemask+0x143d/0x16b6
> kernel:  [<ffffffff8111f405>] ? debug_show_all_locks+0x226/0x226
> kernel:  [<ffffffff811f0d6b>] ? warn_alloc_failed+0x24c/0x24c
> kernel:  [<ffffffff81110ffc>] ? finish_wait+0x1a4/0x1b0
> kernel:  [<ffffffff81122faf>] ? lock_acquire+0xec/0x147
> kernel:  [<ffffffff81d32ed0>] ? _raw_spin_unlock_irqrestore+0x3b/0x5c
> kernel:  [<ffffffff81d32edc>] ? _raw_spin_unlock_irqrestore+0x47/0x5c
> kernel:  [<ffffffff81110ffc>] ? finish_wait+0x1a4/0x1b0
> kernel:  [<ffffffff8128f73a>] khugepaged+0x1d4/0x484f
> kernel:  [<ffffffff8128f566>] ? hugepage_vma_revalidate+0xef/0xef
> kernel:  [<ffffffff810d5bcc>] ? finish_task_switch+0x3de/0x484
> kernel:  [<ffffffff81d32f18>] ? _raw_spin_unlock_irq+0x27/0x45
> kernel:  [<ffffffff8111d13f>] ? trace_hardirqs_on_caller+0x3d2/0x492
> kernel:  [<ffffffff81111487>] ? prepare_to_wait_event+0x3f7/0x3f7
> kernel:  [<ffffffff81d28bf5>] ? __schedule+0xa4d/0xd16
> kernel:  [<ffffffff810cd0de>] kthread+0x252/0x261
> kernel:  [<ffffffff8128f566>] ? hugepage_vma_revalidate+0xef/0xef
> kernel:  [<ffffffff810cce8c>] ? kthread_create_on_node+0x377/0x377
> kernel:  [<ffffffff81d3387f>] ret_from_fork+0x1f/0x40
> kernel:  [<ffffffff810cce8c>] ? kthread_create_on_node+0x377/0x377
> -- Reboot --
> 
> 	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
