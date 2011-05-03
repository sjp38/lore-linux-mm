Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1EDAF6B0011
	for <linux-mm@kvack.org>; Tue,  3 May 2011 14:55:56 -0400 (EDT)
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback
 related.
From: Colin Ian King <colin.king@ubuntu.com>
In-Reply-To: <20110428224038.GG1696@quack.suse.cz>
References: <1303926637.2583.17.camel@mulgrave.site>
	 <1303934716.2583.22.camel@mulgrave.site> <1303990590.2081.9.camel@lenovo>
	 <1303993705-sup-5213@think> <1303998140.2081.11.camel@lenovo>
	 <1303998300-sup-4941@think> <1303999282.2081.15.camel@lenovo>
	 <20110428142551.GD1696@quack.suse.cz> <20110428143329.GE1696@quack.suse.cz>
	 <1304002701.2081.21.camel@lenovo>  <20110428224038.GG1696@quack.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 03 May 2011 19:55:45 +0100
Message-ID: <1304448945.5533.9.camel@lenovo>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Chris Mason <chris.mason@oracle.com>, James Bottomley <james.bottomley@suse.de>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, mgorman@novell.com

On Fri, 2011-04-29 at 00:40 +0200, Jan Kara wrote:
> On Thu 28-04-11 15:58:21, Colin Ian King wrote:
> > On Thu, 2011-04-28 at 16:33 +0200, Jan Kara wrote:
> > > On Thu 28-04-11 16:25:51, Jan Kara wrote:
> > > > On Thu 28-04-11 15:01:22, Colin Ian King wrote:
> > > > > 
> > > > > > Could you post the soft lockups you're seeing?
> > > > > 
> > > > > As requested, attached
> > > >   Hum, what keeps puzzling me is that in all the cases of hangs I've seen
> > > > so far, we are stuck waiting for IO to finish for a long time - e.g. in the
> > > > traces below kjournald waits for PageWriteback bit to get cleared. Also we
> > > > are stuck waiting for page locks which might be because those pages are
> > > > being read in? All in all it seems that the IO is just incredibly slow.
> > > > 
> > > > But it's not clear to me what pushes us into that situation (especially
> > > > since ext4 refuses to do any IO from ->writepage (i.e. kswapd) when the
> > > > underlying blocks are not already allocated.
> > >   Hmm, maybe because the system is under memory pressure (and kswapd is not
> > > able to get rid of dirty pages), we page out clean pages. Thus also pages
> > > of executables which need to be paged in soon anyway thus putting heavy
> > > read load on the system which makes writes crawl? I'm not sure why
> > > compaction should make this any worse but maybe it can.
> > > 
> > > James, Colin, can you capture output of 'vmstat 1' while you do the
> > > copying? Thanks.
> > 
> > Attached.
>   Thanks. So I there are a few interesting points in the vmstat output:
> For first 30 seconds, we are happily copying data - relatively steady read
> throughput (about 20-40 MB/s) and occasional peak from flusher thread
> flushing dirty data. During this time free memory drops from about 1.4 GB
> to about 22!!! MB - mm seems to like to really use the machine ;). Then
> things get interesting:
> procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
>  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
>  0  1      0  83372   5228 1450776    0    0 39684 90132  450  918  0  4 74 22
>  0  1      0  22416   5228 1509864    0    0 29452 48492  403  869  1  2 80 18
>  2  0      0  20056   5384 1513996    0    0  2248  2116  434 1191  4  4 71 21
>  0  1      0  19800   5932 1514600    0    0   644   104  454 1166  8  3 64 24
>  1  0      0  21848   5940 1515244    0    0   292   380  468 1775 15  6 75 3
>  1  0      0  20936   5940 1515876    0    0   296   296  496 1846 18  8 74 0
>  1  0      0  17792   5940 1516580    0    0   356   356  484 1862 23  8 69 0
>  1  0      0  17544   5940 1517364    0    0   412   412  482 1812 16  7 77 0
>  4  0      0  18148   5948 1517968    0    0   288   344  436 1749 19  9 69 3
>  0  2    220 137528   1616 1402468    0  220 74708  2164  849 1806  3  6 63 28
>  0  3    224  36184   1628 1499648    0    4 50820 86204  532 1272  0  4 64 32
>  0  2  19680  53688   1628 1484388   32 19456  6080 62972  242  287  0  2 63 34
>  0  2  36928 1407432   1356 150980    0 17252  1564 17276  368  764  1  3 73 22
> 
> So when free memory reached about 20 MB, both read and write activity
> almost stalled for 7 s (probably everybody waits for free memory). Then
> mm manages to free 100 MB from page cache, things move on for two seconds,
> then we swap out! about 36 MB and page reclaim also finally decides it
> maybe has too much of page cache and reaps most of it (1.3 GB in one go).

> Then things get going again, although there are still occasional stalls
> such as this (about 30s later):
>  1  3  36688 753192   1208 792344    0    0 35948 32768  435 6625  0  6 61 33
>  0  2  36668 754996   1344 792760    0    0   252 58736 2832 16239  0  1 60 39
>  0  2  36668 750132   1388 796688    0    0  2508  1524  325  959  1  3 68 28
>  1  0  36668 751160   1400 797968    0    0   620   620  460 1470  6  6 50 38
>  1  0  36668 750516   1400 798520    0    0   300   300  412 1764 17  8 75 1
>  1  0  36668 750648   1408 799108    0    0   280   340  423 1816 18  6 73 3
>  1  0  36668 748856   1408 799752    0    0   336   328  409 1788 18  8 75 0
>  1  0  36668 748120   1416 800604    0    0   428   452  407 1723 14 10 75 2
>  1  0  36668 750048   1416 801176    0    0   296   296  405 1779 18  7 75 1
>  0  1  36668 650428   1420 897252    0    0 48100   556  658 1718 10  3 71 15
>  0  2  36668 505444   1424 1037012    0    0 69888 90272  686 1491  1  4 68 27
>  0  1  36668 479264   1428 1063372    0    0 12984 40896  324  674  1  1 76 23
> ...
> I'm not sure what we were blocked on here since there is still plenty of
> free memory (750 MB). These stalls repeat once in a while but things go on.
> Then at about 350s, things just stop:
> procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
>  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
>  3  1  75280  73564   1844 1503848    0    0 43396 81976  627 1061  0 25 42 32
>  3  3  75280  73344   1852 1504256    0    0   256    20  240  149  0 26 25 49
>  3  3  75280  73344   1852 1504268    0    0     0     0  265  140  0 29 13 58
>  3  3  75280  73468   1852 1504232    0    0     0     0  265  132  0 22 34 44
>  3  3  75280  73468   1852 1504232    0    0     0     0  339  283  0 25 26 49
>  3  3  75280  73468   1852 1504232    0    0     0     0  362  327  0 25 25 50
>  3  3  75280  73468   1852 1504232    0    0     0     0  317  320  0 26 25 49
>  3  3  75280  73468   1852 1504232    0    0     0     0  361  343  0 26 25 50
> 
> and nothing really happens for 150 s, except more and more tasks blocking
> in D state (second column).
>  3  6  75272  73416   1872 1503872    0    0     0     0  445  700  0 25 25 50
>  0  7  75264  67940   1884 1509008   64    0  5056    16  481  876  0 22 23 55
> Then suddently things get going again:
>  0  2  75104  76808   1892 1502552  352    0 14292 40456  459 14865  0  2 39 59
>  0  1  75104  75704   1900 1503412    0    0   820    32  405  788  1  1 72 27
>  1  0  75104  76512   1904 1505576    0    0  1068  1072  454 1586  8  7 74 11
> 
> I guess this 150 s stall is when kernel barfs the "task blocked for more
> than 30 seconds" messages. And from the traces we know that everyone is
> waiting for PageWriteback or page lock during this time. Also James's vmstat
> report shows that IO is stalled when kswapd is spinning. Really strange.

Just to add, this machine has relatively low amount of memory (1GB).
I've re-run the tests today with cgroups disabled and it ran for 47
'copy' cycles, 27 'copy' cycles and then 35 'copy' cycles.

One extra data point, with maxcpus=1 I get a lockup after 2 'copy'
cycles every time, so it's more predictable than the default 4 processor
configuration.

> 
> James in the meantime identified that cgroups are somehow involved. Are you
> using systemd by any chance?

No, I'm using upstart.

>  Maybe cgroup IO throttling screws us?
> 
> 								Honza
> 
> > > > [  287.088371] INFO: task rs:main Q:Reg:749 blocked for more than 30 seconds.
> > > > [  287.088374] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> > > > [  287.088376] rs:main Q:Reg   D 0000000000000000     0   749      1 0x00000000
> > > > [  287.088381]  ffff880072c17b68 0000000000000082 ffff880072c17fd8 ffff880072c16000
> > > > [  287.088392]  0000000000013d00 ffff88003591b178 ffff880072c17fd8 0000000000013d00
> > > > [  287.088396]  ffffffff81a0b020 ffff88003591adc0 ffff88001fffc3e8 ffff88001fc13d00
> > > > [  287.088400] Call Trace:
> > > > [  287.088404]  [<ffffffff8110c070>] ? sync_page+0x0/0x50
> > > > [  287.088408]  [<ffffffff815c0990>] io_schedule+0x70/0xc0
> > > > [  287.088411]  [<ffffffff8110c0b0>] sync_page+0x40/0x50
> > > > [  287.088414]  [<ffffffff815c130f>] __wait_on_bit+0x5f/0x90
> > > > [  287.088418]  [<ffffffff8110c278>] wait_on_page_bit+0x78/0x80
> > > > [  287.088421]  [<ffffffff81087f70>] ? wake_bit_function+0x0/0x50
> > > > [  287.088425]  [<ffffffff8110dffd>] __lock_page_or_retry+0x3d/0x70
> > > > [  287.088428]  [<ffffffff8110e3c7>] filemap_fault+0x397/0x4a0
> > > > [  287.088431]  [<ffffffff8112d144>] __do_fault+0x54/0x520
> > > > [  287.088434]  [<ffffffff81134a43>] ? unmap_region+0x113/0x170
> > > > [  287.088437]  [<ffffffff812ded90>] ? prio_tree_insert+0x150/0x1c0
> > > > [  287.088440]  [<ffffffff811309da>] handle_pte_fault+0xfa/0x210
> > > > [  287.088442]  [<ffffffff810442a7>] ? pte_alloc_one+0x37/0x50
> > > > [  287.088446]  [<ffffffff815c2cce>] ? _raw_spin_lock+0xe/0x20
> > > > [  287.088448]  [<ffffffff8112de25>] ? __pte_alloc+0xb5/0x100
> > > > [  287.088451]  [<ffffffff81131d5d>] handle_mm_fault+0x16d/0x250
> > > > [  287.088454]  [<ffffffff815c6a47>] do_page_fault+0x1a7/0x540
> > > > [  287.088457]  [<ffffffff81136f85>] ? do_mmap_pgoff+0x335/0x370
> > > > [  287.088460]  [<ffffffff81137127>] ? sys_mmap_pgoff+0x167/0x230
> > > > [  287.088463]  [<ffffffff815c34d5>] page_fault+0x25/0x30
> > > > [  287.088466] INFO: task NetworkManager:764 blocked for more than 30 seconds.
> > > > [  287.088468] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> > > > [  287.088470] NetworkManager  D 0000000000000002     0   764      1 0x00000000
> > > > [  287.088473]  ffff880074ffbb68 0000000000000082 ffff880074ffbfd8 ffff880074ffa000
> > > > [  287.088477]  0000000000013d00 ffff880036051a98 ffff880074ffbfd8 0000000000013d00
> > > > [  287.088481]  ffff8801005badc0 ffff8800360516e0 ffff88001ffef128 ffff88001fc53d00
> > > > [  287.088484] Call Trace:
> > > > [  287.088488]  [<ffffffff8110c070>] ? sync_page+0x0/0x50
> > > > [  287.088491]  [<ffffffff815c0990>] io_schedule+0x70/0xc0
> > > > [  287.088494]  [<ffffffff8110c0b0>] sync_page+0x40/0x50
> > > > [  287.088497]  [<ffffffff815c130f>] __wait_on_bit+0x5f/0x90
> > > > [  287.088500]  [<ffffffff8110c278>] wait_on_page_bit+0x78/0x80
> > > > [  287.088503]  [<ffffffff81087f70>] ? wake_bit_function+0x0/0x50
> > > > [  287.088506]  [<ffffffff8110dffd>] __lock_page_or_retry+0x3d/0x70
> > > > [  287.088509]  [<ffffffff8110e3c7>] filemap_fault+0x397/0x4a0
> > > > [  287.088513]  [<ffffffff81177110>] ? pollwake+0x0/0x60
> > > > [  287.088516]  [<ffffffff8112d144>] __do_fault+0x54/0x520
> > > > [  287.088519]  [<ffffffff81177110>] ? pollwake+0x0/0x60
> > > > [  287.088522]  [<ffffffff811309da>] handle_pte_fault+0xfa/0x210
> > > > [  287.088525]  [<ffffffff8111561d>] ? __free_pages+0x2d/0x40
> > > > [  287.088527]  [<ffffffff8112de4f>] ? __pte_alloc+0xdf/0x100
> > > > [  287.088530]  [<ffffffff81131d5d>] handle_mm_fault+0x16d/0x250
> > > > [  287.088533]  [<ffffffff815c6a47>] do_page_fault+0x1a7/0x540
> > > > [  287.088537]  [<ffffffff81013859>] ? read_tsc+0x9/0x20
> > > > [  287.088540]  [<ffffffff81092eb1>] ? ktime_get_ts+0xb1/0xf0
> > > > [  287.088543]  [<ffffffff811776d2>] ? poll_select_set_timeout+0x82/0x90
> > > > [  287.088546]  [<ffffffff815c34d5>] page_fault+0x25/0x30
> > > > [  287.088559] INFO: task unity-panel-ser:1521 blocked for more than 30 seconds.
> > > > [  287.088561] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> > > > [  287.088562] unity-panel-ser D 0000000000000000     0  1521      1 0x00000000
> > > > [  287.088566]  ffff880061f37b68 0000000000000082 ffff880061f37fd8 ffff880061f36000
> > > > [  287.088570]  0000000000013d00 ffff880068c7c858 ffff880061f37fd8 0000000000013d00
> > > > [  287.088573]  ffff88003591c4a0 ffff880068c7c4a0 ffff88001fff0c88 ffff88001fc13d00
> > > > [  287.088577] Call Trace:
> > > > [  287.088581]  [<ffffffff8110c070>] ? sync_page+0x0/0x50
> > > > [  287.088583]  [<ffffffff815c0990>] io_schedule+0x70/0xc0
> > > > [  287.088587]  [<ffffffff8110c0b0>] sync_page+0x40/0x50
> > > > [  287.088589]  [<ffffffff815c130f>] __wait_on_bit+0x5f/0x90
> > > > [  287.088593]  [<ffffffff8110c278>] wait_on_page_bit+0x78/0x80
> > > > [  287.088596]  [<ffffffff81087f70>] ? wake_bit_function+0x0/0x50
> > > > [  287.088599]  [<ffffffff8110dffd>] __lock_page_or_retry+0x3d/0x70
> > > > [  287.088602]  [<ffffffff8110e3c7>] filemap_fault+0x397/0x4a0
> > > > [  287.088605]  [<ffffffff8112d144>] __do_fault+0x54/0x520
> > > > [  287.088608]  [<ffffffff811309da>] handle_pte_fault+0xfa/0x210
> > > > [  287.088610]  [<ffffffff8111561d>] ? __free_pages+0x2d/0x40
> > > > [  287.088613]  [<ffffffff8112de4f>] ? __pte_alloc+0xdf/0x100
> > > > [  287.088616]  [<ffffffff81131d5d>] handle_mm_fault+0x16d/0x250
> > > > [  287.088619]  [<ffffffff815c6a47>] do_page_fault+0x1a7/0x540
> > > > [  287.088622]  [<ffffffff81136f85>] ? do_mmap_pgoff+0x335/0x370
> > > > [  287.088625]  [<ffffffff815c34d5>] page_fault+0x25/0x30
> > > > [  287.088629] INFO: task jbd2/sda4-8:1845 blocked for more than 30 seconds.
> > > > [  287.088630] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> > > > [  287.088632] jbd2/sda4-8     D 0000000000000000     0  1845      2 0x00000000
> > > > [  287.088636]  ffff880068f6baf0 0000000000000046 ffff880068f6bfd8 ffff880068f6a000
> > > > [  287.088639]  0000000000013d00 ffff880061d603b8 ffff880068f6bfd8 0000000000013d00
> > > > [  287.088643]  ffff88003591c4a0 ffff880061d60000 ffff88001fff8548 ffff88001fc13d00
> > > > [  287.088647] Call Trace:
> > > > [  287.088650]  [<ffffffff8110c070>] ? sync_page+0x0/0x50
> > > > [  287.088653]  [<ffffffff815c0990>] io_schedule+0x70/0xc0
> > > > [  287.088656]  [<ffffffff8110c0b0>] sync_page+0x40/0x50
> > > > [  287.088659]  [<ffffffff815c130f>] __wait_on_bit+0x5f/0x90
> > > > [  287.088662]  [<ffffffff8110c278>] wait_on_page_bit+0x78/0x80
> > > > [  287.088665]  [<ffffffff81087f70>] ? wake_bit_function+0x0/0x50
> > > > [  287.088668]  [<ffffffff8110c41d>] filemap_fdatawait_range+0xfd/0x190
> > > > [  287.088672]  [<ffffffff8110c4db>] filemap_fdatawait+0x2b/0x30
> > > > [  287.088675]  [<ffffffff81242a93>] journal_finish_inode_data_buffers+0x63/0x170
> > > > [  287.088678]  [<ffffffff81243284>] jbd2_journal_commit_transaction+0x6e4/0x1190
> > > > [  287.088682]  [<ffffffff81076185>] ? try_to_del_timer_sync+0x85/0xe0
> > > > [  287.088685]  [<ffffffff81247e9b>] kjournald2+0xbb/0x220
> > > > [  287.088688]  [<ffffffff81087f30>] ? autoremove_wake_function+0x0/0x40
> > > > [  287.088691]  [<ffffffff81247de0>] ? kjournald2+0x0/0x220
> > > > [  287.088694]  [<ffffffff810877e6>] kthread+0x96/0xa0
> > > > [  287.088697]  [<ffffffff8100ce24>] kernel_thread_helper+0x4/0x10
> > > > [  287.088700]  [<ffffffff81087750>] ? kthread+0x0/0xa0
> > > > [  287.088703]  [<ffffffff8100ce20>] ? kernel_thread_helper+0x0/0x10
> > > > [  287.088705] INFO: task dirname:5969 blocked for more than 30 seconds.
> > > > [  287.088707] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> > > > [  287.088709] dirname         D 0000000000000002     0  5969   5214 0x00000000
> > > > [  287.088712]  ffff88005bd9d8b8 0000000000000086 ffff88005bd9dfd8 ffff88005bd9c000
> > > > [  287.088716]  0000000000013d00 ffff88005d65b178 ffff88005bd9dfd8 0000000000013d00
> > > > [  287.088720]  ffff8801005e5b80 ffff88005d65adc0 ffff88001ffe5228 ffff88001fc53d00
> > > > [  287.088723] Call Trace:
> > > > [  287.088726]  [<ffffffff8110c070>] ? sync_page+0x0/0x50
> > > > [  287.088729]  [<ffffffff815c0990>] io_schedule+0x70/0xc0
> > > > [  287.088732]  [<ffffffff8110c0b0>] sync_page+0x40/0x50
> > > > [  287.088735]  [<ffffffff815c130f>] __wait_on_bit+0x5f/0x90
> > > > [  287.088738]  [<ffffffff8110c278>] wait_on_page_bit+0x78/0x80
> > > > [  287.088741]  [<ffffffff81087f70>] ? wake_bit_function+0x0/0x50
> > > > [  287.088744]  [<ffffffff8110dffd>] __lock_page_or_retry+0x3d/0x70
> > > > [  287.088747]  [<ffffffff8110e3c7>] filemap_fault+0x397/0x4a0
> > > > [  287.088750]  [<ffffffff8112d144>] __do_fault+0x54/0x520
> > > > [  287.088753]  [<ffffffff811309da>] handle_pte_fault+0xfa/0x210
> > > > [  287.088756]  [<ffffffff810442a7>] ? pte_alloc_one+0x37/0x50
> > > > [  287.088759]  [<ffffffff815c2cce>] ? _raw_spin_lock+0xe/0x20
> > > > [  287.088761]  [<ffffffff8112de25>] ? __pte_alloc+0xb5/0x100
> > > > [  287.088764]  [<ffffffff81131d5d>] handle_mm_fault+0x16d/0x250
> > > > [  287.088767]  [<ffffffff815c6a47>] do_page_fault+0x1a7/0x540
> > > > [  287.088770]  [<ffffffff81136947>] ? mmap_region+0x1f7/0x500
> > > > [  287.088773]  [<ffffffff8112db06>] ? free_pgd_range+0x356/0x4a0
> > > > [  287.088776]  [<ffffffff815c34d5>] page_fault+0x25/0x30
> > > > [  287.088779]  [<ffffffff812e6d5f>] ? __clear_user+0x3f/0x70
> > > > [  287.088782]  [<ffffffff812e6d41>] ? __clear_user+0x21/0x70
> > > > [  287.088786]  [<ffffffff812e6dc6>] clear_user+0x36/0x40
> > > > [  287.088788]  [<ffffffff811b0b6d>] padzero+0x2d/0x40
> > > > [  287.088791]  [<ffffffff811b2c7a>] load_elf_binary+0x95a/0xe00
> > > > [  287.088794]  [<ffffffff8116aa8a>] search_binary_handler+0xda/0x300
> > > > [  287.088797]  [<ffffffff811b2320>] ? load_elf_binary+0x0/0xe00
> > > > [  287.088800]  [<ffffffff8116c49c>] do_execve+0x24c/0x2d0
> > > > [  287.088802]  [<ffffffff8101521a>] sys_execve+0x4a/0x80
> > > > [  287.088805]  [<ffffffff8100c45c>] stub_execve+0x6c/0xc0
> > > > -- 
> > > > Jan Kara <jack@suse.cz>
> > > > SUSE Labs, CR
> > > > --
> > > > To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> > > > the body of a message to majordomo@vger.kernel.org
> > > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
