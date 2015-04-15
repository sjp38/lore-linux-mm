Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id A35FC6B0038
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 04:21:59 -0400 (EDT)
Received: by paboj16 with SMTP id oj16so42742574pab.0
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 01:21:59 -0700 (PDT)
Received: from mail-pd0-x233.google.com (mail-pd0-x233.google.com. [2607:f8b0:400e:c02::233])
        by mx.google.com with ESMTPS id ae4si5890249pbc.57.2015.04.15.01.21.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Apr 2015 01:21:58 -0700 (PDT)
Received: by pdbnk13 with SMTP id nk13so43951026pdb.0
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 01:21:58 -0700 (PDT)
Date: Wed, 15 Apr 2015 17:22:11 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: advice on bad_page instance
Message-ID: <20150415082211.GC464@swordfish>
References: <CAA25o9SF=1G6PCBpdUJx9=DQrqhVm=XUY+4jB=M_Qbz-z-3Xfg@mail.gmail.com>
 <20150415071642.GB22700@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150415071642.GB22700@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, sergey.senozhatsky@gmail.com

On (04/15/15 16:16), Minchan Kim wrote:
> On Tue, Apr 14, 2015 at 11:36:57AM -0700, Luigi Semenzato wrote:
> > We are seeing several instances of these things (often with different
> > but plausible values in the struct page) in kernel 3.8.11, followed by
> > a panic() in release_pages a few seconds later.
> > 
> > I realize it's an old kernel and probably of little interest here, but
> > I would be most grateful for any pointers on how to proceed.  In
> > particular, I suspect that many such bugs may have been fixed by now,
> > but I am not sure how to find the right fix (which I would backport).
> > 
> > Also, this happens under heavy swap, and we're using zram.  I wonder
> > if there may be a race condition related to zram which may have been
> > fixed since then, and which may result in these symptoms.
> 
> I didn't see such bug until now. Sorry. However, I might miss something
> because zram has changed a lot since then.
> What I recommend is just to use recent zram/zsmalloc.
> I think it's not hard to backport it because they are almost isolated
> from other parts in kernel.
> If you don't see any problem any more with recent zram, yay, your
> system doesn't have any problem. But if you see the problem still,
> it means you should suspect another stuffs as culprits as well as
> zram.
> 
> Thanks.
> 

assuming that you use zram0, does 'mkswap -c /dev/zram0' show any bad
pages right after the swap creation/activation?

	-ss

> > <1>[ 5392.106074] BUG: Bad page state in process CompositorTileW  pfn:57a7e
> > <1>[ 5392.106109] page:ffffea00015e9f80 count:0 mapcount:0 mapping:
> >       (null) index:0x2
> > <1>[ 5392.106122] page flags: 0x4000000000000004(referenced)
> > <5>[ 5392.106139] Modules linked in: i2c_dev uinput
> > snd_hda_codec_realtek memconsole snd_hda_codec_hdmi uvcvideo
> > videobuf2_vmalloc videobuf2_memops videobuf2_core videodev
> > snd_hda_intel snd_hda_codec snd_hwdep snd_pcm snd_page_alloc snd_timer
> > zram(C) lzo_compress zsmalloc(C) fuse nf_conntrack_ipv6 nf_defrag_ipv6
> > ip6table_filter ip6_tables ath9k_btcoex ath9k_common_btcoex
> > ath9k_hw_btcoex ath mac80211 cfg80211 option usb_wwan cdc_ether usbnet
> > ath3k btusb bluetooth joydev ppp_async ppp_generic slhc tun
> > <5>[ 5392.106333] Pid: 27363, comm: CompositorTileW Tainted: G    B
> > C   3.8.11 #1
> > <5>[ 5392.106344] Call Trace:
> > <5>[ 5392.106357]  [<ffffffff978ba5bb>] bad_page+0xcf/0xe3
> > <5>[ 5392.106370]  [<ffffffff978bb181>] get_page_from_freelist+0x21a/0x46c
> > <5>[ 5392.106383]  [<ffffffff978beb74>] ? release_pages+0x19b/0x1be
> > <5>[ 5392.106394]  [<ffffffff978bb5da>] __alloc_pages_nodemask+0x207/0x685
> > <5>[ 5392.106407]  [<ffffffff97cb8caf>] ? _cond_resched+0xe/0x1e
> > <5>[ 5392.106421]  [<ffffffff978d215a>] handle_pte_fault+0x305/0x500
> > <5>[ 5392.106433]  [<ffffffff978d4f5e>] ? __vma_link_file+0x65/0x67
> > <5>[ 5392.106445]  [<ffffffff978d30d0>] handle_mm_fault+0x97/0xbb
> > <5>[ 5392.106459]  [<ffffffff97828616>] __do_page_fault+0x1d4/0x38c
> > <5>[ 5392.106470]  [<ffffffff978d7803>] ? do_mmap_pgoff+0x284/0x2c0
> > <5>[ 5392.106482]  [<ffffffff978ca82c>] ? vm_mmap_pgoff+0x7d/0x8e
> > <5>[ 5392.106495]  [<ffffffff97828800>] do_page_fault+0xe/0x10
> > <5>[ 5392.106506]  [<ffffffff97cb9d32>] page_fault+0x22/0x30

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
