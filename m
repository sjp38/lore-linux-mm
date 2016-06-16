Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id C09006B0005
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 22:57:53 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id d71so65449492ith.1
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 19:57:53 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id z64si301633itd.81.2016.06.15.19.57.52
        for <linux-mm@kvack.org>;
        Wed, 15 Jun 2016 19:57:53 -0700 (PDT)
Date: Thu, 16 Jun 2016 11:58:00 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v7 00/12] Support non-lru page migration
Message-ID: <20160616025800.GO17127@bbox>
References: <1464736881-24886-1-git-send-email-minchan@kernel.org>
 <20160615075909.GA425@swordfish>
 <20160615231248.GI17127@bbox>
 <20160616024827.GA497@swordfish>
MIME-Version: 1.0
In-Reply-To: <20160616024827.GA497@swordfish>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, dri-devel@lists.freedesktop.org, Hugh Dickins <hughd@google.com>, John Einar Reitan <john.reitan@foss.arm.com>, Jonathan Corbet <corbet@lwn.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Aquini <aquini@redhat.com>, Rik van Riel <riel@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, virtualization@lists.linux-foundation.org, Gioh Kim <gi-oh.kim@profitbricks.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Sangseok Lee <sangseok.lee@lge.com>, Kyeongdon Kim <kyeongdon.kim@lge.com>, Chulmin Kim <cmlaika.kim@samsung.com>

On Thu, Jun 16, 2016 at 11:48:27AM +0900, Sergey Senozhatsky wrote:
> Hi,
> 
> On (06/16/16 08:12), Minchan Kim wrote:
> > > [  315.146533] kasan: CONFIG_KASAN_INLINE enabled
> > > [  315.146538] kasan: GPF could be caused by NULL-ptr deref or user memory access
> > > [  315.146546] general protection fault: 0000 [#1] PREEMPT SMP KASAN
> > > [  315.146576] Modules linked in: lzo zram zsmalloc mousedev coretemp hwmon crc32c_intel r8169 i2c_i801 mii snd_hda_codec_realtek snd_hda_codec_generic snd_hda_intel snd_hda_codec snd_hda_core acpi_cpufreq snd_pcm snd_timer snd soundcore lpc_ich mfd_core processor sch_fq_codel sd_mod hid_generic usbhid hid ahci libahci libata ehci_pci ehci_hcd scsi_mod usbcore usb_common
> > > [  315.146785] CPU: 3 PID: 38 Comm: khugepaged Not tainted 4.7.0-rc3-next-20160614-dbg-00004-ga1c2cbc-dirty #488
> > > [  315.146841] task: ffff8800bfaf2900 ti: ffff880112468000 task.ti: ffff880112468000
> > > [  315.146859] RIP: 0010:[<ffffffffa02c413d>]  [<ffffffffa02c413d>] zs_page_migrate+0x355/0xaa0 [zsmalloc]
> > 
> > Thanks for the report!
> > 
> > zs_page_migrate+0x355? Could you tell me what line is it?
> > 
> > It seems to be related to obj_to_head.
> 
> reproduced. a bit different call stack this time. but the problem is
> still the same.
> 
> zs_compact()
> ...
>     6371:       e8 00 00 00 00          callq  6376 <zs_compact+0x22b>
>     6376:       0f 0b                   ud2    
>     6378:       48 8b 95 a8 fe ff ff    mov    -0x158(%rbp),%rdx
>     637f:       4d 8d 74 24 78          lea    0x78(%r12),%r14
>     6384:       4c 89 ee                mov    %r13,%rsi
>     6387:       4c 89 e7                mov    %r12,%rdi
>     638a:       e8 86 c7 ff ff          callq  2b15 <get_first_obj_offset>
>     638f:       41 89 c5                mov    %eax,%r13d
>     6392:       4c 89 f0                mov    %r14,%rax
>     6395:       48 c1 e8 03             shr    $0x3,%rax
>     6399:       8a 04 18                mov    (%rax,%rbx,1),%al
>     639c:       84 c0                   test   %al,%al
>     639e:       0f 85 f2 02 00 00       jne    6696 <zs_compact+0x54b>
>     63a4:       41 8b 44 24 78          mov    0x78(%r12),%eax
>     63a9:       41 0f af c7             imul   %r15d,%eax
>     63ad:       41 01 c5                add    %eax,%r13d
>     63b0:       4c 89 f0                mov    %r14,%rax
>     63b3:       48 c1 e8 03             shr    $0x3,%rax
>     63b7:       48 01 d8                add    %rbx,%rax
>     63ba:       48 89 85 88 fe ff ff    mov    %rax,-0x178(%rbp)
>     63c1:       41 81 fd ff 0f 00 00    cmp    $0xfff,%r13d
>     63c8:       0f 87 1a 03 00 00       ja     66e8 <zs_compact+0x59d>
>     63ce:       49 63 f5                movslq %r13d,%rsi
>     63d1:       48 03 b5 98 fe ff ff    add    -0x168(%rbp),%rsi
>     63d8:       48 8b bd a8 fe ff ff    mov    -0x158(%rbp),%rdi
>     63df:       e8 67 d9 ff ff          callq  3d4b <obj_to_head>
>     63e4:       a8 01                   test   $0x1,%al
>     63e6:       0f 84 d9 02 00 00       je     66c5 <zs_compact+0x57a>
>     63ec:       48 83 e0 fe             and    $0xfffffffffffffffe,%rax
>     63f0:       bf 01 00 00 00          mov    $0x1,%edi
>     63f5:       48 89 85 b0 fe ff ff    mov    %rax,-0x150(%rbp)
>     63fc:       e8 00 00 00 00          callq  6401 <zs_compact+0x2b6>
>     6401:       48 8b 85 b0 fe ff ff    mov    -0x150(%rbp),%rax

RAX: 2065676162726166 so rax is totally garbage, I think.
It means obj_to_head returns garbage because get_first_obj_offset is
utter crab because (page_idx / class->pages_per_zspage) was totally
wrong.

> 					^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>     6408:       f0 0f ba 28 00          lock btsl $0x0,(%rax)
 
<snip>

> > Could you test with [zsmalloc: keep first object offset in struct page]
> > in mmotm?
> 
> sure, I can.  will it help, tho? we have a race condition here I think.

I guess root cause is caused by get_first_obj_offset.
Please test with it.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
