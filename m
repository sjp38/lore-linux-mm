Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E2F656B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 20:39:37 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 204so79358811pge.5
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 17:39:37 -0800 (PST)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id g14si26637963pgp.183.2017.01.17.17.39.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 17:39:36 -0800 (PST)
Received: by mail-pf0-x243.google.com with SMTP id 19so6544001pfo.3
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 17:39:36 -0800 (PST)
Date: Wed, 18 Jan 2017 10:39:48 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [Bug 192571] zswap + zram enabled BUG
Message-ID: <20170118013948.GA580@jagdpanzerIV.localdomain>
References: <bug-192571-27@https.bugzilla.kernel.org/>
 <bug-192571-27-qFfm1cXEv4@https.bugzilla.kernel.org/>
 <20170117122249.815342d95117c3f444acc952@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170117122249.815342d95117c3f444acc952@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sss123next@list.ru
Cc: Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

Cc Dan

On (01/17/17 12:22), Andrew Morton wrote:
> > https://bugzilla.kernel.org/show_bug.cgi?id=192571
> > 
> > --- Comment #1 from Gluzskiy Alexandr <sss123next@list.ru> ---
> > [199961.576604] ------------[ cut here ]------------
> > [199961.577830] kernel BUG at mm/zswap.c:1108!

zswap didn't manage to decompress the page:

static int zswap_frontswap_load(unsigned type, pgoff_t offset,
				struct page *page)
{
...
	dst = kmap_atomic(page);
	tfm = *get_cpu_ptr(entry->pool->tfm);
	ret = crypto_comp_decompress(tfm, src, entry->length, dst, &dlen);
	put_cpu_ptr(entry->pool->tfm);
	kunmap_atomic(dst);
	zpool_unmap_handle(entry->pool->zpool, entry->handle);
	BUG_ON(ret);
	^^^^^^^^^^^

is there anything suspicious in dmesg?

	-ss

[..]
> > [199961.596459] Hardware name: System manufacturer System Product Name/M4A77TD,
> > BIOS 2104    06/28/2010
> > [199961.597974] task: ffff880035c19680 task.stack: ffffc90000510000
> > [199961.599490] RIP: 0010:[<ffffffff8112c6c2>]  [<ffffffff8112c6c2>]
> > zswap_frontswap_load+0x142/0x160
> > [199961.601042] RSP: 0000:ffffc90000513cb0  EFLAGS: 00010282
> > [199961.602588] RAX: ffffffff818263a0 RBX: ffff88036b2fb930 RCX:
> > ffffc90000513c98
> > [199961.604141] RDX: ffff8801a75da000 RSI: ffff8802ee9d0240 RDI:
> > ffff88041c25d000
> > [199961.605687] RBP: ffff880035c19680 R08: ffff8802ee9d0249 R09:
> > ffff8801a75da0ac
> > [199961.607240] R10: ffff8801a75db000 R11: ffff8802ee9d027d R12:
> > 00000000ffffffea
> > [199961.608788] R13: ffff8804176e3830 R14: ffff8804176e3838 R15:
> > 000000c42a6ac008
> > [199961.610315] FS:  00007fe1fa7fc700(0000) GS:ffff88042fc80000(0000)
> > knlGS:0000000000000000
> > [199961.611838] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [199961.613357] CR2: 000000c42a6ac008 CR3: 00000000a8411000 CR4:
> > 00000000000006e0
> > [199961.614864] Stack:
> > [199961.616327]  00001000fffffffe ffffffff81823780 000000000014487b
> > ffffea00069d7680
> > [199961.617820]  0000000000000001 ffff880418614c00 ffffffff8112b768
> > ffffea00069d7680
> > [199961.619310]  ffff880418614c00 000000000014487b 00000000024200ca
> > ffff88011d834900
> > [199961.620799] Call Trace:
> > [199961.622250]  [<ffffffff8112b768>] ? __frontswap_load+0x68/0xc0
> > [199961.623689]  [<ffffffff8112666c>] ? swap_readpage+0x8c/0x120
> > [199961.625115]  [<ffffffff81126e61>] ? read_swap_cache_async+0x21/0x40
> > [199961.626545]  [<ffffffff81126f96>] ? swapin_readahead+0x116/0x1e0
> > [199961.627973]  [<ffffffff812b704e>] ? radix_tree_lookup_slot+0xe/0x20
> > [199961.629398]  [<ffffffff8111236f>] ? do_swap_page+0x42f/0x660
> > [199961.630799]  [<ffffffff81114bca>] ? handle_mm_fault+0x76a/0x1080
> > [199961.632163]  [<ffffffff811544ec>] ? new_sync_read+0xac/0xe0
> > [199961.633496]  [<ffffffff8102c7a9>] ? __do_page_fault+0x169/0x3e0
> > [199961.634798]  [<ffffffff8102ca5b>] ? do_page_fault+0x1b/0x60
> > [199961.636106]  [<ffffffff810e3cc9>] ?
> > __context_tracking_exit.part.1+0x49/0x60
> > [199961.637424]  [<ffffffff8157c7cf>] ? page_fault+0x1f/0x30
> > [199961.638739] Code: fb ff ff 41 c6 45 08 00 48 83 c4 08 44 89 e0 5b 5d 41 5c
> > 41 5d 41 5e c3 be 0f 00 00 00 48 c7 c7 12 d6 6d 81 e8 e0 d2 f1 ff eb b0 <0f> 0b
> > 0f 1f 84 00 00 00 00 00 66 2e 0f 1f 84 00 00 00 00 00 66 
> > [199961.641538] RIP  [<ffffffff8112c6c2>] zswap_frontswap_load+0x142/0x160
> > [199961.642922]  RSP <ffffc90000513cb0>
> > [199961.648971] ---[ end trace 76742a0cd4818a78 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
