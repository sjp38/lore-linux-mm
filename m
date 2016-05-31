Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id BE9E36B025E
	for <linux-mm@kvack.org>; Tue, 31 May 2016 05:28:06 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id h144so135517744ita.1
        for <linux-mm@kvack.org>; Tue, 31 May 2016 02:28:06 -0700 (PDT)
Received: from mail-it0-x244.google.com (mail-it0-x244.google.com. [2607:f8b0:4001:c0b::244])
        by mx.google.com with ESMTPS id l83si43573173ioi.6.2016.05.31.02.28.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 May 2016 02:28:05 -0700 (PDT)
Received: by mail-it0-x244.google.com with SMTP id k76so9646421ita.1
        for <linux-mm@kvack.org>; Tue, 31 May 2016 02:28:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160530185616.GQ2527@techsingularity.net>
References: <CAMuHMdV00vJJxoA7XABw+mFF+2QUd1MuQbPKKgkmGnK_NySZpg@mail.gmail.com>
	<20160530155644.GP2527@techsingularity.net>
	<CAMuHMdWioTRo1PGymqCEv+3CoQYH8qnhP2T__orSbMw1q-CBMA@mail.gmail.com>
	<20160530185616.GQ2527@techsingularity.net>
Date: Tue, 31 May 2016 11:28:05 +0200
Message-ID: <CAMuHMdXCN5LeNCNJ9=B5sGAtdd81JeRNrUMSCOjSL_Bx1-tDvA@mail.gmail.com>
Subject: Re: BUG: scheduling while atomic: cron/668/0x10c9a0c0 (was: Re: mm,
 page_alloc: avoid looking up the first zone in a zonelist twice)
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>

Hi Mel,

On Mon, May 30, 2016 at 8:56 PM, Mel Gorman <mgorman@techsingularity.net> wrote:
> Thanks. Please try the following instead
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index bb320cde4d6d..557549c81083 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3024,6 +3024,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
>                 apply_fair = false;
>                 fair_skipped = false;
>                 reset_alloc_batches(ac->preferred_zoneref->zone);
> +               z = ac->preferred_zoneref;
>                 goto zonelist_scan;
>         }

Thanks a lot, that seems to fix the issue!.

Tested-by: Geert Uytterhoeven <geert@linux-m68k.org>

JFTR, without the fix, sometimes I get a different, but equally obscure, crash
than the one I posted before:

Kernel panic - not syncing: Aiee, killing interrupt handler!
CPU: 0 PID: 668 Comm: cron Not tainted
4.7.0-rc1-atari-01184-g21f2f74eaf41989e #370
Stack from 00bf9be0:
        00bf9be0 0031a075 000236d0 0000000f 007e9060 efcc5cd0 00bf800c 00bf9fcc
        00000000 00000000 ffffffff 00bf9c18 00024cbe 00303d7f 0000000f 007e9060
        efcc5cd0 007e9104 00bf9fcc 00bf9ea0 000061b2 00bf9cf8 efcc5d54 00bf9cf8
        00000007 00000000 00000000 efcc5d50 00000000 00000000 00000000 00000000
        00000000 00029efe 008fe870 008fe858 efcc5d50 008fe5d0 00029ee4 00bf9eb4
        00000009 008fe858 008fe5d0 00355490 008fe5d0 0002a880 efcc5d50 007e9060
Call Trace: [<000236d0>] panic+0xae/0x23e
 [<00024cbe>] do_exit+0x8e/0x6e4
 [<000061b2>] send_fault_sig+0x5a/0xb8
 [<00029efe>] __dequeue_signal+0x1a/0xb2
 [<00029ee4>] __dequeue_signal+0x0/0xb2
 [<0002a880>] dequeue_signal+0xec/0xf6
 [<0002538e>] do_group_exit+0x7a/0xa2
 [<0002c084>] get_signal+0x19c/0x3d2
 [<0002c280>] get_signal+0x398/0x3d2
 [<00003648>] do_notify_resume+0x2e/0x786
 [<00005654>] buserr_c+0x2d4/0x610
 [<00034212>] search_exception_tables+0x1a/0x34
 [<00005654>] buserr_c+0x2d4/0x610
 [<00003db0>] handle_kernel_fault+0x10/0x58
 [<00005654>] buserr_c+0x2d4/0x610
 [<000061b2>] send_fault_sig+0x5a/0xb8
 [<00046e3e>] update_rmtp+0x4e/0x68
 [<00034212>] search_exception_tables+0x1a/0x34
 [<00046e3e>] update_rmtp+0x4e/0x68
 [<00003db0>] handle_kernel_fault+0x10/0x58
 [<00046e3e>] update_rmtp+0x4e/0x68
 [<000061b2>] send_fault_sig+0x5a/0xb8
 [<000056b2>] buserr_c+0x332/0x610
 [<0000c350>] dnrm_lp+0x162/0x17e
 [<00047276>] hrtimer_nanosleep+0xdc/0x128
 [<00046e58>] hrtimer_wakeup+0x0/0x1e
 [<00010000>] stanh+0xd8/0x140
 [<000029a0>] do_signal_return+0x10/0x1a
 [<00002924>] syscall+0x8/0xc
 [<0008c00b>] ___cache_free+0xcd/0x13e

---[ end Kernel panic - not syncing: Aiee, killing interrupt handler!

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
