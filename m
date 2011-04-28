Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 576C16B0012
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 10:58:35 -0400 (EDT)
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback
 related.
From: Colin Ian King <colin.king@ubuntu.com>
In-Reply-To: <20110428143329.GE1696@quack.suse.cz>
References: <1303924902.2583.13.camel@mulgrave.site>
	 <1303925374-sup-7968@think> <1303926637.2583.17.camel@mulgrave.site>
	 <1303934716.2583.22.camel@mulgrave.site> <1303990590.2081.9.camel@lenovo>
	 <1303993705-sup-5213@think> <1303998140.2081.11.camel@lenovo>
	 <1303998300-sup-4941@think> <1303999282.2081.15.camel@lenovo>
	 <20110428142551.GD1696@quack.suse.cz> <20110428143329.GE1696@quack.suse.cz>
Content-Type: multipart/mixed; boundary="=-LqynJTKljXeD9s7ULxd/"
Date: Thu, 28 Apr 2011 15:58:21 +0100
Message-ID: <1304002701.2081.21.camel@lenovo>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Chris Mason <chris.mason@oracle.com>, James Bottomley <james.bottomley@suse.de>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>


--=-LqynJTKljXeD9s7ULxd/
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

On Thu, 2011-04-28 at 16:33 +0200, Jan Kara wrote:
> On Thu 28-04-11 16:25:51, Jan Kara wrote:
> > On Thu 28-04-11 15:01:22, Colin Ian King wrote:
> > > 
> > > > Could you post the soft lockups you're seeing?
> > > 
> > > As requested, attached
> >   Hum, what keeps puzzling me is that in all the cases of hangs I've seen
> > so far, we are stuck waiting for IO to finish for a long time - e.g. in the
> > traces below kjournald waits for PageWriteback bit to get cleared. Also we
> > are stuck waiting for page locks which might be because those pages are
> > being read in? All in all it seems that the IO is just incredibly slow.
> > 
> > But it's not clear to me what pushes us into that situation (especially
> > since ext4 refuses to do any IO from ->writepage (i.e. kswapd) when the
> > underlying blocks are not already allocated.
>   Hmm, maybe because the system is under memory pressure (and kswapd is not
> able to get rid of dirty pages), we page out clean pages. Thus also pages
> of executables which need to be paged in soon anyway thus putting heavy
> read load on the system which makes writes crawl? I'm not sure why
> compaction should make this any worse but maybe it can.
> 
> James, Colin, can you capture output of 'vmstat 1' while you do the
> copying? Thanks.

Attached.


> 
> 								Honza
> 
> > [  287.088371] INFO: task rs:main Q:Reg:749 blocked for more than 30 seconds.
> > [  287.088374] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> > [  287.088376] rs:main Q:Reg   D 0000000000000000     0   749      1 0x00000000
> > [  287.088381]  ffff880072c17b68 0000000000000082 ffff880072c17fd8 ffff880072c16000
> > [  287.088392]  0000000000013d00 ffff88003591b178 ffff880072c17fd8 0000000000013d00
> > [  287.088396]  ffffffff81a0b020 ffff88003591adc0 ffff88001fffc3e8 ffff88001fc13d00
> > [  287.088400] Call Trace:
> > [  287.088404]  [<ffffffff8110c070>] ? sync_page+0x0/0x50
> > [  287.088408]  [<ffffffff815c0990>] io_schedule+0x70/0xc0
> > [  287.088411]  [<ffffffff8110c0b0>] sync_page+0x40/0x50
> > [  287.088414]  [<ffffffff815c130f>] __wait_on_bit+0x5f/0x90
> > [  287.088418]  [<ffffffff8110c278>] wait_on_page_bit+0x78/0x80
> > [  287.088421]  [<ffffffff81087f70>] ? wake_bit_function+0x0/0x50
> > [  287.088425]  [<ffffffff8110dffd>] __lock_page_or_retry+0x3d/0x70
> > [  287.088428]  [<ffffffff8110e3c7>] filemap_fault+0x397/0x4a0
> > [  287.088431]  [<ffffffff8112d144>] __do_fault+0x54/0x520
> > [  287.088434]  [<ffffffff81134a43>] ? unmap_region+0x113/0x170
> > [  287.088437]  [<ffffffff812ded90>] ? prio_tree_insert+0x150/0x1c0
> > [  287.088440]  [<ffffffff811309da>] handle_pte_fault+0xfa/0x210
> > [  287.088442]  [<ffffffff810442a7>] ? pte_alloc_one+0x37/0x50
> > [  287.088446]  [<ffffffff815c2cce>] ? _raw_spin_lock+0xe/0x20
> > [  287.088448]  [<ffffffff8112de25>] ? __pte_alloc+0xb5/0x100
> > [  287.088451]  [<ffffffff81131d5d>] handle_mm_fault+0x16d/0x250
> > [  287.088454]  [<ffffffff815c6a47>] do_page_fault+0x1a7/0x540
> > [  287.088457]  [<ffffffff81136f85>] ? do_mmap_pgoff+0x335/0x370
> > [  287.088460]  [<ffffffff81137127>] ? sys_mmap_pgoff+0x167/0x230
> > [  287.088463]  [<ffffffff815c34d5>] page_fault+0x25/0x30
> > [  287.088466] INFO: task NetworkManager:764 blocked for more than 30 seconds.
> > [  287.088468] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> > [  287.088470] NetworkManager  D 0000000000000002     0   764      1 0x00000000
> > [  287.088473]  ffff880074ffbb68 0000000000000082 ffff880074ffbfd8 ffff880074ffa000
> > [  287.088477]  0000000000013d00 ffff880036051a98 ffff880074ffbfd8 0000000000013d00
> > [  287.088481]  ffff8801005badc0 ffff8800360516e0 ffff88001ffef128 ffff88001fc53d00
> > [  287.088484] Call Trace:
> > [  287.088488]  [<ffffffff8110c070>] ? sync_page+0x0/0x50
> > [  287.088491]  [<ffffffff815c0990>] io_schedule+0x70/0xc0
> > [  287.088494]  [<ffffffff8110c0b0>] sync_page+0x40/0x50
> > [  287.088497]  [<ffffffff815c130f>] __wait_on_bit+0x5f/0x90
> > [  287.088500]  [<ffffffff8110c278>] wait_on_page_bit+0x78/0x80
> > [  287.088503]  [<ffffffff81087f70>] ? wake_bit_function+0x0/0x50
> > [  287.088506]  [<ffffffff8110dffd>] __lock_page_or_retry+0x3d/0x70
> > [  287.088509]  [<ffffffff8110e3c7>] filemap_fault+0x397/0x4a0
> > [  287.088513]  [<ffffffff81177110>] ? pollwake+0x0/0x60
> > [  287.088516]  [<ffffffff8112d144>] __do_fault+0x54/0x520
> > [  287.088519]  [<ffffffff81177110>] ? pollwake+0x0/0x60
> > [  287.088522]  [<ffffffff811309da>] handle_pte_fault+0xfa/0x210
> > [  287.088525]  [<ffffffff8111561d>] ? __free_pages+0x2d/0x40
> > [  287.088527]  [<ffffffff8112de4f>] ? __pte_alloc+0xdf/0x100
> > [  287.088530]  [<ffffffff81131d5d>] handle_mm_fault+0x16d/0x250
> > [  287.088533]  [<ffffffff815c6a47>] do_page_fault+0x1a7/0x540
> > [  287.088537]  [<ffffffff81013859>] ? read_tsc+0x9/0x20
> > [  287.088540]  [<ffffffff81092eb1>] ? ktime_get_ts+0xb1/0xf0
> > [  287.088543]  [<ffffffff811776d2>] ? poll_select_set_timeout+0x82/0x90
> > [  287.088546]  [<ffffffff815c34d5>] page_fault+0x25/0x30
> > [  287.088559] INFO: task unity-panel-ser:1521 blocked for more than 30 seconds.
> > [  287.088561] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> > [  287.088562] unity-panel-ser D 0000000000000000     0  1521      1 0x00000000
> > [  287.088566]  ffff880061f37b68 0000000000000082 ffff880061f37fd8 ffff880061f36000
> > [  287.088570]  0000000000013d00 ffff880068c7c858 ffff880061f37fd8 0000000000013d00
> > [  287.088573]  ffff88003591c4a0 ffff880068c7c4a0 ffff88001fff0c88 ffff88001fc13d00
> > [  287.088577] Call Trace:
> > [  287.088581]  [<ffffffff8110c070>] ? sync_page+0x0/0x50
> > [  287.088583]  [<ffffffff815c0990>] io_schedule+0x70/0xc0
> > [  287.088587]  [<ffffffff8110c0b0>] sync_page+0x40/0x50
> > [  287.088589]  [<ffffffff815c130f>] __wait_on_bit+0x5f/0x90
> > [  287.088593]  [<ffffffff8110c278>] wait_on_page_bit+0x78/0x80
> > [  287.088596]  [<ffffffff81087f70>] ? wake_bit_function+0x0/0x50
> > [  287.088599]  [<ffffffff8110dffd>] __lock_page_or_retry+0x3d/0x70
> > [  287.088602]  [<ffffffff8110e3c7>] filemap_fault+0x397/0x4a0
> > [  287.088605]  [<ffffffff8112d144>] __do_fault+0x54/0x520
> > [  287.088608]  [<ffffffff811309da>] handle_pte_fault+0xfa/0x210
> > [  287.088610]  [<ffffffff8111561d>] ? __free_pages+0x2d/0x40
> > [  287.088613]  [<ffffffff8112de4f>] ? __pte_alloc+0xdf/0x100
> > [  287.088616]  [<ffffffff81131d5d>] handle_mm_fault+0x16d/0x250
> > [  287.088619]  [<ffffffff815c6a47>] do_page_fault+0x1a7/0x540
> > [  287.088622]  [<ffffffff81136f85>] ? do_mmap_pgoff+0x335/0x370
> > [  287.088625]  [<ffffffff815c34d5>] page_fault+0x25/0x30
> > [  287.088629] INFO: task jbd2/sda4-8:1845 blocked for more than 30 seconds.
> > [  287.088630] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> > [  287.088632] jbd2/sda4-8     D 0000000000000000     0  1845      2 0x00000000
> > [  287.088636]  ffff880068f6baf0 0000000000000046 ffff880068f6bfd8 ffff880068f6a000
> > [  287.088639]  0000000000013d00 ffff880061d603b8 ffff880068f6bfd8 0000000000013d00
> > [  287.088643]  ffff88003591c4a0 ffff880061d60000 ffff88001fff8548 ffff88001fc13d00
> > [  287.088647] Call Trace:
> > [  287.088650]  [<ffffffff8110c070>] ? sync_page+0x0/0x50
> > [  287.088653]  [<ffffffff815c0990>] io_schedule+0x70/0xc0
> > [  287.088656]  [<ffffffff8110c0b0>] sync_page+0x40/0x50
> > [  287.088659]  [<ffffffff815c130f>] __wait_on_bit+0x5f/0x90
> > [  287.088662]  [<ffffffff8110c278>] wait_on_page_bit+0x78/0x80
> > [  287.088665]  [<ffffffff81087f70>] ? wake_bit_function+0x0/0x50
> > [  287.088668]  [<ffffffff8110c41d>] filemap_fdatawait_range+0xfd/0x190
> > [  287.088672]  [<ffffffff8110c4db>] filemap_fdatawait+0x2b/0x30
> > [  287.088675]  [<ffffffff81242a93>] journal_finish_inode_data_buffers+0x63/0x170
> > [  287.088678]  [<ffffffff81243284>] jbd2_journal_commit_transaction+0x6e4/0x1190
> > [  287.088682]  [<ffffffff81076185>] ? try_to_del_timer_sync+0x85/0xe0
> > [  287.088685]  [<ffffffff81247e9b>] kjournald2+0xbb/0x220
> > [  287.088688]  [<ffffffff81087f30>] ? autoremove_wake_function+0x0/0x40
> > [  287.088691]  [<ffffffff81247de0>] ? kjournald2+0x0/0x220
> > [  287.088694]  [<ffffffff810877e6>] kthread+0x96/0xa0
> > [  287.088697]  [<ffffffff8100ce24>] kernel_thread_helper+0x4/0x10
> > [  287.088700]  [<ffffffff81087750>] ? kthread+0x0/0xa0
> > [  287.088703]  [<ffffffff8100ce20>] ? kernel_thread_helper+0x0/0x10
> > [  287.088705] INFO: task dirname:5969 blocked for more than 30 seconds.
> > [  287.088707] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> > [  287.088709] dirname         D 0000000000000002     0  5969   5214 0x00000000
> > [  287.088712]  ffff88005bd9d8b8 0000000000000086 ffff88005bd9dfd8 ffff88005bd9c000
> > [  287.088716]  0000000000013d00 ffff88005d65b178 ffff88005bd9dfd8 0000000000013d00
> > [  287.088720]  ffff8801005e5b80 ffff88005d65adc0 ffff88001ffe5228 ffff88001fc53d00
> > [  287.088723] Call Trace:
> > [  287.088726]  [<ffffffff8110c070>] ? sync_page+0x0/0x50
> > [  287.088729]  [<ffffffff815c0990>] io_schedule+0x70/0xc0
> > [  287.088732]  [<ffffffff8110c0b0>] sync_page+0x40/0x50
> > [  287.088735]  [<ffffffff815c130f>] __wait_on_bit+0x5f/0x90
> > [  287.088738]  [<ffffffff8110c278>] wait_on_page_bit+0x78/0x80
> > [  287.088741]  [<ffffffff81087f70>] ? wake_bit_function+0x0/0x50
> > [  287.088744]  [<ffffffff8110dffd>] __lock_page_or_retry+0x3d/0x70
> > [  287.088747]  [<ffffffff8110e3c7>] filemap_fault+0x397/0x4a0
> > [  287.088750]  [<ffffffff8112d144>] __do_fault+0x54/0x520
> > [  287.088753]  [<ffffffff811309da>] handle_pte_fault+0xfa/0x210
> > [  287.088756]  [<ffffffff810442a7>] ? pte_alloc_one+0x37/0x50
> > [  287.088759]  [<ffffffff815c2cce>] ? _raw_spin_lock+0xe/0x20
> > [  287.088761]  [<ffffffff8112de25>] ? __pte_alloc+0xb5/0x100
> > [  287.088764]  [<ffffffff81131d5d>] handle_mm_fault+0x16d/0x250
> > [  287.088767]  [<ffffffff815c6a47>] do_page_fault+0x1a7/0x540
> > [  287.088770]  [<ffffffff81136947>] ? mmap_region+0x1f7/0x500
> > [  287.088773]  [<ffffffff8112db06>] ? free_pgd_range+0x356/0x4a0
> > [  287.088776]  [<ffffffff815c34d5>] page_fault+0x25/0x30
> > [  287.088779]  [<ffffffff812e6d5f>] ? __clear_user+0x3f/0x70
> > [  287.088782]  [<ffffffff812e6d41>] ? __clear_user+0x21/0x70
> > [  287.088786]  [<ffffffff812e6dc6>] clear_user+0x36/0x40
> > [  287.088788]  [<ffffffff811b0b6d>] padzero+0x2d/0x40
> > [  287.088791]  [<ffffffff811b2c7a>] load_elf_binary+0x95a/0xe00
> > [  287.088794]  [<ffffffff8116aa8a>] search_binary_handler+0xda/0x300
> > [  287.088797]  [<ffffffff811b2320>] ? load_elf_binary+0x0/0xe00
> > [  287.088800]  [<ffffffff8116c49c>] do_execve+0x24c/0x2d0
> > [  287.088802]  [<ffffffff8101521a>] sys_execve+0x4a/0x80
> > [  287.088805]  [<ffffffff8100c45c>] stub_execve+0x6c/0xc0
> > -- 
> > Jan Kara <jack@suse.cz>
> > SUSE Labs, CR
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html


--=-LqynJTKljXeD9s7ULxd/
Content-Type: application/x-gzip; name="vmstat.log.gz"
Content-Disposition: attachment; filename="vmstat.log.gz"
Content-Transfer-Encoding: base64

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
iwgBAE==


--=-LqynJTKljXeD9s7ULxd/--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
