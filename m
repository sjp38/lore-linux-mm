Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3CFFC6B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 05:54:59 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a69so94856859pfa.1
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 02:54:59 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id k9si5234829pfj.91.2016.06.16.02.54.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 02:54:58 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id c74so3751900pfb.0
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 02:54:58 -0700 (PDT)
Date: Thu, 16 Jun 2016 18:54:57 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [next-20160615] kernel BUG at mm/rmap.c:1251!
Message-ID: <20160616095457.GD432@swordfish>
References: <20160616084656.GB432@swordfish>
 <20160616085836.GC6836@dhcp22.suse.cz>
 <20160616092345.GC432@swordfish>
 <20160616094139.GE6836@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160616094139.GE6836@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (06/16/16 11:41), Michal Hocko wrote:
> On Thu 16-06-16 18:23:45, Sergey Senozhatsky wrote:
> > On (06/16/16 10:58), Michal Hocko wrote:
> > > > [..]
> > > > [  272.687656] vma ffff8800b855a5a0 start 00007f3576d58000 end 00007f3576f66000
> > > >                next ffff8800b977d2c0 prev ffff8800bdfb1860 mm ffff8801315ff200
> > > >                prot 8000000000000025 anon_vma ffff8800b7e583b0 vm_ops           (null)
> > > >                pgoff 7f3576d58 file           (null) private_data           (null)
> > > >                flags: 0x100073(read|write|mayread|maywrite|mayexec|account)
> > > > [  272.691793] ------------[ cut here ]------------
> > > > [  272.692820] kernel BUG at mm/rmap.c:1251!
> > > 
> > > Is this?
> > > page_add_new_anon_rmap:
> > > 	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma)
> > > [...]
> > 
> > I think it is
> > 
> > 1248 void page_add_new_anon_rmap(struct page *page,
> > 1249         struct vm_area_struct *vma, unsigned long address, bool compound)
> > 1250 {
> > 1251         int nr = compound ? hpage_nr_pages(page) : 1;
> > 1252
> > 1253         VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma);
> > 1254         __SetPageSwapBacked(page);
> > 
> > > > [  272.727842] BUG: sleeping function called from invalid context at include/linux/sched.h:2960
> > > 
> > > If yes then I am not sure we can do much about the this part. BUG_ON in
> > > an atomic context is unfortunate but the BUG_ON points out a real bug so
> > > we shouldn't drop it because of the potential atomic context. The above
> > > VM_BUG_ON should definitely be addressed. I thought that Vlastimil has
> > > pointed out some issues with the khugepaged lock inconsistencies which
> > > might lead to issues like this.
> > 
> > collapse_huge_page() ->mmap_sem fixup patch (http://marc.info/?l=linux-mm&m=146495692807404&w=2)
> > is in next-20160615. or do you mean some other patch?
> 
> Yes that's what I meant, but I haven't reviewed the patch to see whether
> it is correct/complete. It would be good to see whether the issue is
> related to those changes.

I'll copy-paste one more backtrace I swa today [originally was posted to another
mail thread].


kernel: BUG: Bad page state in process khugepaged  pfn:101db8
kernel: page:ffffea0004076e00 count:0 mapcount:-127 mapping:          (null) index:0x1
kernel: flags: 0x8000000000000000()
kernel: page dumped because: nonzero mapcount
kernel: Modules linked in: lzo zram zsmalloc mousedev coretemp hwmon crc32c_intel snd_hda_codec_realtek i2c_i801 snd_hda_codec_generic r8169 mii snd_hda_intel snd_hda_codec snd_hda_core acpi_cpufreq snd_pcm snd_timer snd soundcore lpc_ich
+processor mfd_core sch_fq_codel sd_mod hid_generic usb
kernel: CPU: 3 PID: 38 Comm: khugepaged Not tainted 4.7.0-rc3-next-20160615-dbg-00005-gfd11984-dirty #491
kernel:  0000000000000000 ffff8801124c73f8 ffffffff814d69b0 ffffea0004076e00
kernel:  ffffffff81e658a0 ffff8801124c7420 ffffffff811e9b63 0000000000000000
kernel:  ffffea0004076e00 ffffffff81e658a0 ffff8801124c7440 ffffffff811e9ca9
kernel: Call Trace:
kernel:  [<ffffffff814d69b0>] dump_stack+0x68/0x92
kernel:  [<ffffffff811e9b63>] bad_page+0x158/0x1a2
kernel:  [<ffffffff811e9ca9>] free_pages_check_bad+0xfc/0x101
kernel:  [<ffffffff811ee516>] free_hot_cold_page+0x135/0x5de
kernel:  [<ffffffff811eea26>] __free_pages+0x67/0x72
kernel:  [<ffffffff81227c63>] release_freepages+0x13a/0x191
kernel:  [<ffffffff8122b3c2>] compact_zone+0x845/0x1155
kernel:  [<ffffffff8122ab7d>] ? compaction_suitable+0x76/0x76
kernel:  [<ffffffff8122bdb2>] compact_zone_order+0xe0/0x167
kernel:  [<ffffffff8122bcd2>] ? compact_zone+0x1155/0x1155
kernel:  [<ffffffff8122ce88>] try_to_compact_pages+0x2f1/0x648
kernel:  [<ffffffff8122ce88>] ? try_to_compact_pages+0x2f1/0x648
kernel:  [<ffffffff8122cb97>] ? compaction_zonelist_suitable+0x3a6/0x3a6
kernel:  [<ffffffff811ef1ea>] ? get_page_from_freelist+0x2c0/0x133c
kernel:  [<ffffffff811f0350>] __alloc_pages_direct_compact+0xea/0x30d
kernel:  [<ffffffff811f0266>] ? get_page_from_freelist+0x133c/0x133c
kernel:  [<ffffffff811ee3b2>] ? drain_all_pages+0x1d6/0x205
kernel:  [<ffffffff811f21a8>] __alloc_pages_nodemask+0x143d/0x16b6
kernel:  [<ffffffff8111f405>] ? debug_show_all_locks+0x226/0x226
kernel:  [<ffffffff811f0d6b>] ? warn_alloc_failed+0x24c/0x24c
kernel:  [<ffffffff81110ffc>] ? finish_wait+0x1a4/0x1b0
kernel:  [<ffffffff81122faf>] ? lock_acquire+0xec/0x147
kernel:  [<ffffffff81d32ed0>] ? _raw_spin_unlock_irqrestore+0x3b/0x5c
kernel:  [<ffffffff81d32edc>] ? _raw_spin_unlock_irqrestore+0x47/0x5c
kernel:  [<ffffffff81110ffc>] ? finish_wait+0x1a4/0x1b0
kernel:  [<ffffffff8128f73a>] khugepaged+0x1d4/0x484f
kernel:  [<ffffffff8128f566>] ? hugepage_vma_revalidate+0xef/0xef
kernel:  [<ffffffff810d5bcc>] ? finish_task_switch+0x3de/0x484
kernel:  [<ffffffff81d32f18>] ? _raw_spin_unlock_irq+0x27/0x45
kernel:  [<ffffffff8111d13f>] ? trace_hardirqs_on_caller+0x3d2/0x492
kernel:  [<ffffffff81111487>] ? prepare_to_wait_event+0x3f7/0x3f7
kernel:  [<ffffffff81d28bf5>] ? __schedule+0xa4d/0xd16
kernel:  [<ffffffff810cd0de>] kthread+0x252/0x261
kernel:  [<ffffffff8128f566>] ? hugepage_vma_revalidate+0xef/0xef
kernel:  [<ffffffff810cce8c>] ? kthread_create_on_node+0x377/0x377
kernel:  [<ffffffff81d3387f>] ret_from_fork+0x1f/0x40
kernel:  [<ffffffff810cce8c>] ? kthread_create_on_node+0x377/0x377
-- Reboot --

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
