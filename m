Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 782776B0260
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 00:59:43 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id j90so1454539lfi.3
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 21:59:43 -0800 (PST)
Received: from smtp42.i.mail.ru (smtp42.i.mail.ru. [94.100.177.102])
        by mx.google.com with ESMTPS id y9si17055449lja.67.2017.01.17.21.59.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Jan 2017 21:59:41 -0800 (PST)
Message-ID: <1484719121.25232.1.camel@list.ru>
Subject: Re: [Bug 192571] zswap + zram enabled BUG
From: Alexandr <sss123next@list.ru>
Date: Wed, 18 Jan 2017 08:58:41 +0300
In-Reply-To: <20170118013948.GA580@jagdpanzerIV.localdomain>
References: <bug-192571-27@https.bugzilla.kernel.org/>
	 <bug-192571-27-qFfm1cXEv4@https.bugzilla.kernel.org/>
	 <20170117122249.815342d95117c3f444acc952@linux-foundation.org>
	 <20170118013948.GA580@jagdpanzerIV.localdomain>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, Minchan Kim <minchan@kernel.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

D? D!N?, 18/01/2017 D2 10:39 +0900, Sergey Senozhatsky D?D,N?DuN?:
> Cc Dan
> 
> On (01/17/17 12:22), Andrew Morton wrote:
> > > https://bugzilla.kernel.org/show_bug.cgi?id=192571
> > > 
> > > --- Comment #1 from Gluzskiy Alexandr <sss123next@list.ru> ---
> > > [199961.576604] ------------[ cut here ]------------
> > > [199961.577830] kernel BUG at mm/zswap.c:1108!
> 
> zswap didn't manage to decompress the page:
> 
> static int zswap_frontswap_load(unsigned type, pgoff_t offset,
> 				struct page *page)
> {
> ...
> 	dst = kmap_atomic(page);
> 	tfm = *get_cpu_ptr(entry->pool->tfm);
> 	ret = crypto_comp_decompress(tfm, src, entry->length, dst,
> &dlen);
> 	put_cpu_ptr(entry->pool->tfm);
> 	kunmap_atomic(dst);
> 	zpool_unmap_handle(entry->pool->zpool, entry->handle);
> 	BUG_ON(ret);
> 	^^^^^^^^^^^
> 
> is there anything suspicious in dmesg?
> 
> 	-ss
> 
> [..]
> > > [199961.596459] Hardware name: System manufacturer System Product
> > > Name/M4A77TD,
> > > BIOS 2104A A A A 06/28/2010
> > > [199961.597974] task: ffff880035c19680 task.stack:
> > > ffffc90000510000
> > > [199961.599490] RIP:
> > > 0010:[<ffffffff8112c6c2>]A A [<ffffffff8112c6c2>]
> > > zswap_frontswap_load+0x142/0x160
> > > [199961.601042] RSP: 0000:ffffc90000513cb0A A EFLAGS: 00010282
> > > [199961.602588] RAX: ffffffff818263a0 RBX: ffff88036b2fb930 RCX:
> > > ffffc90000513c98
> > > [199961.604141] RDX: ffff8801a75da000 RSI: ffff8802ee9d0240 RDI:
> > > ffff88041c25d000
> > > [199961.605687] RBP: ffff880035c19680 R08: ffff8802ee9d0249 R09:
> > > ffff8801a75da0ac
> > > [199961.607240] R10: ffff8801a75db000 R11: ffff8802ee9d027d R12:
> > > 00000000ffffffea
> > > [199961.608788] R13: ffff8804176e3830 R14: ffff8804176e3838 R15:
> > > 000000c42a6ac008
> > > [199961.610315] FS:A A 00007fe1fa7fc700(0000)
> > > GS:ffff88042fc80000(0000)
> > > knlGS:0000000000000000
> > > [199961.611838] CS:A A 0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > [199961.613357] CR2: 000000c42a6ac008 CR3: 00000000a8411000 CR4:
> > > 00000000000006e0
> > > [199961.614864] Stack:
> > > [199961.616327]A A 00001000fffffffe ffffffff81823780
> > > 000000000014487b
> > > ffffea00069d7680
> > > [199961.617820]A A 0000000000000001 ffff880418614c00
> > > ffffffff8112b768
> > > ffffea00069d7680
> > > [199961.619310]A A ffff880418614c00 000000000014487b
> > > 00000000024200ca
> > > ffff88011d834900
> > > [199961.620799] Call Trace:
> > > [199961.622250]A A [<ffffffff8112b768>] ?
> > > __frontswap_load+0x68/0xc0
> > > [199961.623689]A A [<ffffffff8112666c>] ? swap_readpage+0x8c/0x120
> > > [199961.625115]A A [<ffffffff81126e61>] ?
> > > read_swap_cache_async+0x21/0x40
> > > [199961.626545]A A [<ffffffff81126f96>] ?
> > > swapin_readahead+0x116/0x1e0
> > > [199961.627973]A A [<ffffffff812b704e>] ?
> > > radix_tree_lookup_slot+0xe/0x20
> > > [199961.629398]A A [<ffffffff8111236f>] ? do_swap_page+0x42f/0x660
> > > [199961.630799]A A [<ffffffff81114bca>] ?
> > > handle_mm_fault+0x76a/0x1080
> > > [199961.632163]A A [<ffffffff811544ec>] ? new_sync_read+0xac/0xe0
> > > [199961.633496]A A [<ffffffff8102c7a9>] ?
> > > __do_page_fault+0x169/0x3e0
> > > [199961.634798]A A [<ffffffff8102ca5b>] ? do_page_fault+0x1b/0x60
> > > [199961.636106]A A [<ffffffff810e3cc9>] ?
> > > __context_tracking_exit.part.1+0x49/0x60
> > > [199961.637424]A A [<ffffffff8157c7cf>] ? page_fault+0x1f/0x30
> > > [199961.638739] Code: fb ff ff 41 c6 45 08 00 48 83 c4 08 44 89
> > > e0 5b 5d 41 5c
> > > 41 5d 41 5e c3 be 0f 00 00 00 48 c7 c7 12 d6 6d 81 e8 e0 d2 f1 ff
> > > eb b0 <0f> 0b
> > > 0f 1f 84 00 00 00 00 00 66 2e 0f 1f 84 00 00 00 00 00 66A 
> > > [199961.641538] RIPA A [<ffffffff8112c6c2>]
> > > zswap_frontswap_load+0x142/0x160
> > > [199961.642922]A A RSP <ffffc90000513cb0>
> > > [199961.648971] ---[ end trace 76742a0cd4818a78 ]---

no, nothing interesting in dmesg. but i suspect what it may be because
of usage zram and zswap together.
i have following configuration:
1. boot option to kernel "ro radeon.audio=0 dma_debug=off reboot=warm
gbpages rootfstype=ext4
rootflags=relatime,user_xattr,journal_async_commit,delalloc,nobarrier
zswap.enabled=1"
2. zram activation in userspace:
"
cat /etc/local.d/zram.startA 
#!/bin/sh

modprobe zram
echo 10G > /sys/block/zram0/disksize
mkswap /dev/zram0
swapon --priority 200 /dev/zram0
"

3. also i have normal swap block device as fall back if all memory used
"
swapon
NAMEA A A A A A A A A A A A A TYPEA A A A A A SIZE USED PRIO
/dev/mapper/swap partitionA A 16GA A A 0BA A A A 0
/dev/zram0A A A A A A A partitionA A 10GA A A 1GA A 200
"

so, maybe problem related to zswap on zram ? just a guess...
-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEEl/sA7WQg6czXWI/dsEApXVthX7wFAlh/BBIACgkQsEApXVth
X7w9lw/+O55XK/YZHszD/DMKRuZaaAQz7to/JrkJOCOJaYsV/PpUBh6liqYH8LCV
6vYaavzKt3ICW1qRa6Wjj7QC2YZKZTe8i8ERGTamDOnSu/gMlJz3EQ/uOEsNxde5
eoJr9n+JtUqf0PUUaMc61FcRbePcb3csQDD7KAwMSO7Q7+uP/osFUApjFVBOv0yd
KggONcuyIlE0CIhmMk31Id+C7XoKeJogHa2qTIolGzi+yLCmiL+q+CujfXfrbOAz
N6mDr7v6RTwzzOyXULZahceVxVtpUSgj84HG9wxTF7dwN6kwbW/YtdMu7UruqRyb
SYHauUQSuEcbyb5m7tAPWfy4WsWaTacscdBCrOVqYJcn0nb945RMDz0RPIFZmLQS
da6/zh67UF9KuSgprVakvgQ/ITJOfd96USlwZ+E8icJzT36IPWkSmFe6pNEa+KMn
FiUf0JPN6ivO2q2wuwkIEKIeLiqDNX7QwcMxowMHKxezZobrzdyd4LoLx143mAa/
Ls0nABaN9bk+jzl3Ffl2Vx7YowuercwGaRzBuPEdxVQflA1gVPi7o/zwJ75CPAre
ntQk8nWAqpxB30s0/++xYPbYaJFqWtXM2e4AQKQjiZSAdq34yl+q+di/1iGS/u4Q
gfvGaprAtViK6AqURT8dXrWTv8KzAT2prIs3wdpmrc3V92p1cAo=
=5ZmQ
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
