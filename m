Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 86C3E6B01F2
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 03:08:47 -0400 (EDT)
Date: Wed, 7 Apr 2010 15:08:42 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: 32GB SSD on USB1.1 P3/700 == ___HELL___ (2.6.34-rc3)
Message-ID: <20100407070842.GA18215@localhost>
References: <20100404221349.GA18036@rhlx01.hs-esslingen.de> <20100405105319.GA16528@rhlx01.hs-esslingen.de> <20100407070050.GA10527@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100407070050.GA10527@localhost>
Sender: owner-linux-mm@kvack.org
To: Andreas Mohr <andi@lisas.de>
Cc: Jens Axboe <axboe@kernel.dk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> > console-kit-d D df970368     0  2760      1 0x00000000
> >  d9aa7c0c 00000046 00000000 df970368 bcc125ae 000002de df9700f0 df9700f0
> >  00000000 d9aa7c50 d9aa7c18 c1212374 d9aa7c48 d9aa7c20 c105b8f3 d9aa7c3c
> >  c121288c c105b8be c1bfe5f8 0000000e d9aa7c48 d9aa7c64 d9aa7c70 c105baf7
> > Call Trace:
> >  [<c1212374>] io_schedule+0x47/0x7d
> >  [<c105b8f3>] sync_page+0x35/0x39
> >  [<c121288c>] __wait_on_bit+0x34/0x5b
> >  [<c105b8be>] ? sync_page+0x0/0x39
> >  [<c105baf7>] wait_on_page_bit+0x7a/0x83
> >  [<c1033d28>] ? wake_bit_function+0x0/0x37
> >  [<c1063610>] shrink_page_list+0x115/0x3c3
> >  [<c10511fb>] ? __delayacct_blkio_end+0x2f/0x35
> >  [<c1068083>] ? congestion_wait+0x5d/0x67
> >  [<c1063ba9>] shrink_inactive_list+0x2eb/0x476
> >  [<c105117e>] ? delayacct_end+0x66/0x8d
> >  [<c1063f69>] shrink_zone+0x235/0x2d6
> >  [<c1033cf9>] ? autoremove_wake_function+0x0/0x2f
> >  [<c10647e8>] do_try_to_free_pages+0x12c/0x229
> >  [<c10649ed>] try_to_free_pages+0x6a/0x72
> >  [<c1062889>] ? isolate_pages_global+0x0/0x1a2
> >  [<c105fc64>] __alloc_pages_nodemask+0x2e8/0x493
> >  [<c105fe1e>] __get_free_pages+0xf/0x2c
> >  [<c1021fb6>] copy_process+0x9e/0xcc5
> >  [<c1022cf1>] do_fork+0x114/0x25e
> >  [<c106b07b>] ? handle_mm_fault+0x499/0x4f6
> >  [<c1018239>] ? do_page_fault+0xe4/0x279
> >  [<c10372bc>] ? up_read+0x16/0x2a
> >  [<c1007752>] sys_clone+0x1b/0x20
> >  [<c1002765>] ptregs_clone+0x15/0x30
> >  [<c12141b5>] ? syscall_call+0x7/0xb
> 
> Many applications (this one and below) are stuck in
> wait_on_page_writeback(). I guess this is why "heavy write to
> irrelevant partition stalls the whole system".  They are stuck on page
> allocation. Your 512MB system memory is a bit tight, so reclaim
> pressure is a bit high, which triggers the wait-on-writeback logic.

I wonder if this hacking patch may help.

When creating 300MB dirty file with dd, it is creating continuous
region of hard-to-reclaim pages in the LRU list. priority can easily
go low when irrelevant applications' direct reclaim run into these
regions..

Thanks,
Fengguang
---

diff --git a/mm/vmscan.c b/mm/vmscan.c
index e0e5f15..f7179cf 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1149,7 +1149,7 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 	 */
 	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
 		lumpy_reclaim = 1;
-	else if (sc->order && priority < DEF_PRIORITY - 2)
+	else if (sc->order && priority < DEF_PRIORITY / 2)
 		lumpy_reclaim = 1;
 
 	pagevec_init(&pvec, 1);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
