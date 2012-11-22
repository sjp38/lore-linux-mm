Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 46BDA6B002B
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 17:37:01 -0500 (EST)
Date: Thu, 22 Nov 2012 23:36:58 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: 3.7-rc6 soft lockup in kswapd0
Message-ID: <20121122223658.GB20326@quack.suse.cz>
References: <20121122175824.19604.qmail@science.horizon.com>
 <20121122220600.GA20326@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121122220600.GA20326@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@horizon.com>
Cc: linux-kernel@vger.kernel.org, mgorman@suse.de, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>

On Thu 22-11-12 23:06:00, Jan Kara wrote:
> On Thu 22-11-12 12:58:24, George Spelvin wrote:
> > I'm having an interesting issue with a uniprocessor Pentium 4 machine
> > locking up overnight.  3.6.5 didn't do that, but 3.7-rc6 is not doing
> > so well.
>   I've added some CCs which are hopefully relevant. Specifially I remember
> Mel fixing some -mm lockup recently although after googling for a while
> that is likely something different.
  Actually, https://lkml.org/lkml/2012/11/20/567 looks more relevant to
your problem...

> > It's kind of a funny lockup.  Some things work:
> > 
> > - TCP SYN handshake
> > - Alt-SysRq
> > 
> > And others don't:
> > 
> > - Caps lock
> > - Shift-PgUp
> > - Alt-Fn
> > - Screen unblanking
> > - Actually talking to a daemon
> > 
> > This is a "headless" machine that boots to a text console and has zero
> > console activity until the lockup.
> > 
> > This has happened overnight, three nights in a row.  I had to turn screen
> > blanking off to see anything on the screen.  Running the daily cron jobs
> > manually just now didn't trigger it, so I haven't found a proximate cause.
> > 
> > The *first* error has scrolled off the screen, but what I can see
> > an infinite stream (at about 20s intervals) of:
> > 
> > BUG: soft lockup - CPU#0 stuck for 22s! [kswapd0:317]
> > Pid: 317, comm: kswapd0 Not tainted 3.7.0-RC6 #224 HP Pavilion 04 P6319A-ABA 750N/P4B266LA
> > EIP: 0060:[<c10571f7>] EFLAGS: 00000202 CPU: 0
> > EIP is at __zone_watermark_ok+0x5f/7e, 0x67/7e, 0x6e/0x7e, or 0x74/7e
> > (Didn't type registers & stack)
> > Call Trace:
> >  [<c105774f>] ? zone_watermark_ok_safe+0x34/0x3a
> >  [<c105ec7e>] ? kswapd+0x2fa/0x6f6
> >  [<c105e984>] ? try_to_free_pages+0x4b8/0x4b8
> >  [<c103106b>] ? kthread+0x67/0x6c
> >  [<c12559b7>] ? ret_from_kernel_thread+0x1b/0x28
> >  [<c1031004>] ? -_kthread_parkme+0x4c.0x4c
> > Code: (didn't type in first line)
> >                                 5f                        67                     6e                  74                             7e
> >  c9 39 d6 7f 14 eb 1c 6b c1 2c <8b> 44 05 60 d3 e0 29 c6 <d1> fb 39 de 7e 09 41 <39> f9 7c ea b0 01 <eb> 02 31 c0 5a 5b 5e 5f 5d c3 01 14 85 7c 16
>   Taking picture of the screen with a digital camera can usually save you
> some typing :)
> 
> > The lack of scrollback limits me to 49 lines of SysRq output, and usually the most interesting
> > part disappears off the screen.  Two things I can see:
> > 
> > - SysRq-W shows no blocked tasks
> > - SysRq-M shows zero swap in use, and apparently adequate free memory
> > 	DMA: <various segments> = 9048kB
> > 	Normal: <various> = 116312kB
> > 	HighMem: <various> = 41660kB
> > 	416557 total pagecache pages
> > 	0 pages in swap cache
> > 	Swap cache stats: add 0, delete 0, find 0/0
> > 	Free swap  = 4883724kB
> > 	Total swap = 4883724kB
> > 	524260 pages RAM
> > 	296958 pages HighMem
> > 	5221 pages reserved
> > 	406417 pages shared
> > 	351419 pages non-shared
> > 
> > Does anyone have any debugging suggestions?  Waiting overnight to
> > make a good/bad decision makes bisecting pretty slow...
> 
> 							Honza
> -- 
> Jan Kara <jack@suse.cz>
> SUSE Labs, CR
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
