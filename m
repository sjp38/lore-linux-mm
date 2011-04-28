Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 738606B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 10:33:34 -0400 (EDT)
Date: Thu, 28 Apr 2011 16:33:29 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback
 related.
Message-ID: <20110428143329.GE1696@quack.suse.cz>
References: <1303924902.2583.13.camel@mulgrave.site>
 <1303925374-sup-7968@think>
 <1303926637.2583.17.camel@mulgrave.site>
 <1303934716.2583.22.camel@mulgrave.site>
 <1303990590.2081.9.camel@lenovo>
 <1303993705-sup-5213@think>
 <1303998140.2081.11.camel@lenovo>
 <1303998300-sup-4941@think>
 <1303999282.2081.15.camel@lenovo>
 <20110428142551.GD1696@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110428142551.GD1696@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Ian King <colin.king@ubuntu.com>
Cc: Chris Mason <chris.mason@oracle.com>, James Bottomley <james.bottomley@suse.de>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Thu 28-04-11 16:25:51, Jan Kara wrote:
> On Thu 28-04-11 15:01:22, Colin Ian King wrote:
> > 
> > > Could you post the soft lockups you're seeing?
> > 
> > As requested, attached
>   Hum, what keeps puzzling me is that in all the cases of hangs I've seen
> so far, we are stuck waiting for IO to finish for a long time - e.g. in the
> traces below kjournald waits for PageWriteback bit to get cleared. Also we
> are stuck waiting for page locks which might be because those pages are
> being read in? All in all it seems that the IO is just incredibly slow.
> 
> But it's not clear to me what pushes us into that situation (especially
> since ext4 refuses to do any IO from ->writepage (i.e. kswapd) when the
> underlying blocks are not already allocated.
  Hmm, maybe because the system is under memory pressure (and kswapd is not
able to get rid of dirty pages), we page out clean pages. Thus also pages
of executables which need to be paged in soon anyway thus putting heavy
read load on the system which makes writes crawl? I'm not sure why
compaction should make this any worse but maybe it can.

James, Colin, can you capture output of 'vmstat 1' while you do the
copying? Thanks.

								Honza

> [  287.088371] INFO: task rs:main Q:Reg:749 blocked for more than 30 seconds.
> [  287.088374] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [  287.088376] rs:main Q:Reg   D 0000000000000000     0   749      1 0x00000000
> [  287.088381]  ffff880072c17b68 0000000000000082 ffff880072c17fd8 ffff880072c16000
> [  287.088392]  0000000000013d00 ffff88003591b178 ffff880072c17fd8 0000000000013d00
> [  287.088396]  ffffffff81a0b020 ffff88003591adc0 ffff88001fffc3e8 ffff88001fc13d00
> [  287.088400] Call Trace:
> [  287.088404]  [<ffffffff8110c070>] ? sync_page+0x0/0x50
> [  287.088408]  [<ffffffff815c0990>] io_schedule+0x70/0xc0
> [  287.088411]  [<ffffffff8110c0b0>] sync_page+0x40/0x50
> [  287.088414]  [<ffffffff815c130f>] __wait_on_bit+0x5f/0x90
> [  287.088418]  [<ffffffff8110c278>] wait_on_page_bit+0x78/0x80
> [  287.088421]  [<ffffffff81087f70>] ? wake_bit_function+0x0/0x50
> [  287.088425]  [<ffffffff8110dffd>] __lock_page_or_retry+0x3d/0x70
> [  287.088428]  [<ffffffff8110e3c7>] filemap_fault+0x397/0x4a0
> [  287.088431]  [<ffffffff8112d144>] __do_fault+0x54/0x520
> [  287.088434]  [<ffffffff81134a43>] ? unmap_region+0x113/0x170
> [  287.088437]  [<ffffffff812ded90>] ? prio_tree_insert+0x150/0x1c0
> [  287.088440]  [<ffffffff811309da>] handle_pte_fault+0xfa/0x210
> [  287.088442]  [<ffffffff810442a7>] ? pte_alloc_one+0x37/0x50
> [  287.088446]  [<ffffffff815c2cce>] ? _raw_spin_lock+0xe/0x20
> [  287.088448]  [<ffffffff8112de25>] ? __pte_alloc+0xb5/0x100
> [  287.088451]  [<ffffffff81131d5d>] handle_mm_fault+0x16d/0x250
> [  287.088454]  [<ffffffff815c6a47>] do_page_fault+0x1a7/0x540
> [  287.088457]  [<ffffffff81136f85>] ? do_mmap_pgoff+0x335/0x370
> [  287.088460]  [<ffffffff81137127>] ? sys_mmap_pgoff+0x167/0x230
> [  287.088463]  [<ffffffff815c34d5>] page_fault+0x25/0x30
> [  287.088466] INFO: task NetworkManager:764 blocked for more than 30 seconds.
> [  287.088468] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [  287.088470] NetworkManager  D 0000000000000002     0   764      1 0x00000000
> [  287.088473]  ffff880074ffbb68 0000000000000082 ffff880074ffbfd8 ffff880074ffa000
> [  287.088477]  0000000000013d00 ffff880036051a98 ffff880074ffbfd8 0000000000013d00
> [  287.088481]  ffff8801005badc0 ffff8800360516e0 ffff88001ffef128 ffff88001fc53d00
> [  287.088484] Call Trace:
> [  287.088488]  [<ffffffff8110c070>] ? sync_page+0x0/0x50
> [  287.088491]  [<ffffffff815c0990>] io_schedule+0x70/0xc0
> [  287.088494]  [<ffffffff8110c0b0>] sync_page+0x40/0x50
> [  287.088497]  [<ffffffff815c130f>] __wait_on_bit+0x5f/0x90
> [  287.088500]  [<ffffffff8110c278>] wait_on_page_bit+0x78/0x80
> [  287.088503]  [<ffffffff81087f70>] ? wake_bit_function+0x0/0x50
> [  287.088506]  [<ffffffff8110dffd>] __lock_page_or_retry+0x3d/0x70
> [  287.088509]  [<ffffffff8110e3c7>] filemap_fault+0x397/0x4a0
> [  287.088513]  [<ffffffff81177110>] ? pollwake+0x0/0x60
> [  287.088516]  [<ffffffff8112d144>] __do_fault+0x54/0x520
> [  287.088519]  [<ffffffff81177110>] ? pollwake+0x0/0x60
> [  287.088522]  [<ffffffff811309da>] handle_pte_fault+0xfa/0x210
> [  287.088525]  [<ffffffff8111561d>] ? __free_pages+0x2d/0x40
> [  287.088527]  [<ffffffff8112de4f>] ? __pte_alloc+0xdf/0x100
> [  287.088530]  [<ffffffff81131d5d>] handle_mm_fault+0x16d/0x250
> [  287.088533]  [<ffffffff815c6a47>] do_page_fault+0x1a7/0x540
> [  287.088537]  [<ffffffff81013859>] ? read_tsc+0x9/0x20
> [  287.088540]  [<ffffffff81092eb1>] ? ktime_get_ts+0xb1/0xf0
> [  287.088543]  [<ffffffff811776d2>] ? poll_select_set_timeout+0x82/0x90
> [  287.088546]  [<ffffffff815c34d5>] page_fault+0x25/0x30
> [  287.088559] INFO: task unity-panel-ser:1521 blocked for more than 30 seconds.
> [  287.088561] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [  287.088562] unity-panel-ser D 0000000000000000     0  1521      1 0x00000000
> [  287.088566]  ffff880061f37b68 0000000000000082 ffff880061f37fd8 ffff880061f36000
> [  287.088570]  0000000000013d00 ffff880068c7c858 ffff880061f37fd8 0000000000013d00
> [  287.088573]  ffff88003591c4a0 ffff880068c7c4a0 ffff88001fff0c88 ffff88001fc13d00
> [  287.088577] Call Trace:
> [  287.088581]  [<ffffffff8110c070>] ? sync_page+0x0/0x50
> [  287.088583]  [<ffffffff815c0990>] io_schedule+0x70/0xc0
> [  287.088587]  [<ffffffff8110c0b0>] sync_page+0x40/0x50
> [  287.088589]  [<ffffffff815c130f>] __wait_on_bit+0x5f/0x90
> [  287.088593]  [<ffffffff8110c278>] wait_on_page_bit+0x78/0x80
> [  287.088596]  [<ffffffff81087f70>] ? wake_bit_function+0x0/0x50
> [  287.088599]  [<ffffffff8110dffd>] __lock_page_or_retry+0x3d/0x70
> [  287.088602]  [<ffffffff8110e3c7>] filemap_fault+0x397/0x4a0
> [  287.088605]  [<ffffffff8112d144>] __do_fault+0x54/0x520
> [  287.088608]  [<ffffffff811309da>] handle_pte_fault+0xfa/0x210
> [  287.088610]  [<ffffffff8111561d>] ? __free_pages+0x2d/0x40
> [  287.088613]  [<ffffffff8112de4f>] ? __pte_alloc+0xdf/0x100
> [  287.088616]  [<ffffffff81131d5d>] handle_mm_fault+0x16d/0x250
> [  287.088619]  [<ffffffff815c6a47>] do_page_fault+0x1a7/0x540
> [  287.088622]  [<ffffffff81136f85>] ? do_mmap_pgoff+0x335/0x370
> [  287.088625]  [<ffffffff815c34d5>] page_fault+0x25/0x30
> [  287.088629] INFO: task jbd2/sda4-8:1845 blocked for more than 30 seconds.
> [  287.088630] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [  287.088632] jbd2/sda4-8     D 0000000000000000     0  1845      2 0x00000000
> [  287.088636]  ffff880068f6baf0 0000000000000046 ffff880068f6bfd8 ffff880068f6a000
> [  287.088639]  0000000000013d00 ffff880061d603b8 ffff880068f6bfd8 0000000000013d00
> [  287.088643]  ffff88003591c4a0 ffff880061d60000 ffff88001fff8548 ffff88001fc13d00
> [  287.088647] Call Trace:
> [  287.088650]  [<ffffffff8110c070>] ? sync_page+0x0/0x50
> [  287.088653]  [<ffffffff815c0990>] io_schedule+0x70/0xc0
> [  287.088656]  [<ffffffff8110c0b0>] sync_page+0x40/0x50
> [  287.088659]  [<ffffffff815c130f>] __wait_on_bit+0x5f/0x90
> [  287.088662]  [<ffffffff8110c278>] wait_on_page_bit+0x78/0x80
> [  287.088665]  [<ffffffff81087f70>] ? wake_bit_function+0x0/0x50
> [  287.088668]  [<ffffffff8110c41d>] filemap_fdatawait_range+0xfd/0x190
> [  287.088672]  [<ffffffff8110c4db>] filemap_fdatawait+0x2b/0x30
> [  287.088675]  [<ffffffff81242a93>] journal_finish_inode_data_buffers+0x63/0x170
> [  287.088678]  [<ffffffff81243284>] jbd2_journal_commit_transaction+0x6e4/0x1190
> [  287.088682]  [<ffffffff81076185>] ? try_to_del_timer_sync+0x85/0xe0
> [  287.088685]  [<ffffffff81247e9b>] kjournald2+0xbb/0x220
> [  287.088688]  [<ffffffff81087f30>] ? autoremove_wake_function+0x0/0x40
> [  287.088691]  [<ffffffff81247de0>] ? kjournald2+0x0/0x220
> [  287.088694]  [<ffffffff810877e6>] kthread+0x96/0xa0
> [  287.088697]  [<ffffffff8100ce24>] kernel_thread_helper+0x4/0x10
> [  287.088700]  [<ffffffff81087750>] ? kthread+0x0/0xa0
> [  287.088703]  [<ffffffff8100ce20>] ? kernel_thread_helper+0x0/0x10
> [  287.088705] INFO: task dirname:5969 blocked for more than 30 seconds.
> [  287.088707] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [  287.088709] dirname         D 0000000000000002     0  5969   5214 0x00000000
> [  287.088712]  ffff88005bd9d8b8 0000000000000086 ffff88005bd9dfd8 ffff88005bd9c000
> [  287.088716]  0000000000013d00 ffff88005d65b178 ffff88005bd9dfd8 0000000000013d00
> [  287.088720]  ffff8801005e5b80 ffff88005d65adc0 ffff88001ffe5228 ffff88001fc53d00
> [  287.088723] Call Trace:
> [  287.088726]  [<ffffffff8110c070>] ? sync_page+0x0/0x50
> [  287.088729]  [<ffffffff815c0990>] io_schedule+0x70/0xc0
> [  287.088732]  [<ffffffff8110c0b0>] sync_page+0x40/0x50
> [  287.088735]  [<ffffffff815c130f>] __wait_on_bit+0x5f/0x90
> [  287.088738]  [<ffffffff8110c278>] wait_on_page_bit+0x78/0x80
> [  287.088741]  [<ffffffff81087f70>] ? wake_bit_function+0x0/0x50
> [  287.088744]  [<ffffffff8110dffd>] __lock_page_or_retry+0x3d/0x70
> [  287.088747]  [<ffffffff8110e3c7>] filemap_fault+0x397/0x4a0
> [  287.088750]  [<ffffffff8112d144>] __do_fault+0x54/0x520
> [  287.088753]  [<ffffffff811309da>] handle_pte_fault+0xfa/0x210
> [  287.088756]  [<ffffffff810442a7>] ? pte_alloc_one+0x37/0x50
> [  287.088759]  [<ffffffff815c2cce>] ? _raw_spin_lock+0xe/0x20
> [  287.088761]  [<ffffffff8112de25>] ? __pte_alloc+0xb5/0x100
> [  287.088764]  [<ffffffff81131d5d>] handle_mm_fault+0x16d/0x250
> [  287.088767]  [<ffffffff815c6a47>] do_page_fault+0x1a7/0x540
> [  287.088770]  [<ffffffff81136947>] ? mmap_region+0x1f7/0x500
> [  287.088773]  [<ffffffff8112db06>] ? free_pgd_range+0x356/0x4a0
> [  287.088776]  [<ffffffff815c34d5>] page_fault+0x25/0x30
> [  287.088779]  [<ffffffff812e6d5f>] ? __clear_user+0x3f/0x70
> [  287.088782]  [<ffffffff812e6d41>] ? __clear_user+0x21/0x70
> [  287.088786]  [<ffffffff812e6dc6>] clear_user+0x36/0x40
> [  287.088788]  [<ffffffff811b0b6d>] padzero+0x2d/0x40
> [  287.088791]  [<ffffffff811b2c7a>] load_elf_binary+0x95a/0xe00
> [  287.088794]  [<ffffffff8116aa8a>] search_binary_handler+0xda/0x300
> [  287.088797]  [<ffffffff811b2320>] ? load_elf_binary+0x0/0xe00
> [  287.088800]  [<ffffffff8116c49c>] do_execve+0x24c/0x2d0
> [  287.088802]  [<ffffffff8101521a>] sys_execve+0x4a/0x80
> [  287.088805]  [<ffffffff8100c45c>] stub_execve+0x6c/0xc0
> -- 
> Jan Kara <jack@suse.cz>
> SUSE Labs, CR
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
