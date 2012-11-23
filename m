Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 8AEF56B006C
	for <linux-mm@kvack.org>; Fri, 23 Nov 2012 03:51:42 -0500 (EST)
Date: Fri, 23 Nov 2012 08:51:37 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: 3.7-rc6 soft lockup in kswapd0
Message-ID: <20121123085137.GA646@suse.de>
References: <20121122175824.19604.qmail@science.horizon.com>
 <20121122220600.GA20326@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121122220600.GA20326@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@horizon.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>

On Thu, Nov 22, 2012 at 11:06:00PM +0100, Jan Kara wrote:
> On Thu 22-11-12 12:58:24, George Spelvin wrote:
> > I'm having an interesting issue with a uniprocessor Pentium 4 machine

heh, those P4s are great for keeping the room warm in winter. Legacy
high five?

Joking aside, the UP aspect of this is the most relevant.

> > locking up overnight.  3.6.5 didn't do that, but 3.7-rc6 is not doing
> > so well.
>   I've added some CCs which are hopefully relevant. Specifially I remember
> Mel fixing some -mm lockup recently although after googling for a while
> that is likely something different.
> 

Thanks Jan.

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

So basically interrupts work but the machine has otherwise locked up. On
a uniprocessor, it's possible it is infinite looping in kswapd and
nothing else is getting the chance to run if it never hits a
cond_resched().

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

Ok, is there any chance you can capture more of sysrq+m, particularly the
bits that say how much free memory there is and many pages of each order
that is free? If you can't, it's ok. I ask because my kernel bug dowsing
rod is twitching in the direction of the recent free page accounting bug
Dave Hansen identified and fixed -- https://lkml.org/lkml/2012/11/21/504

You might have a machine that is able to hit this particular bug faster. It's
not a memory leak as such, but it acts like one. The kernel would think
the watermarks are not met because it's using NR_FREE_PAGES instead of
checking the free lists.

Can you try that patch out please?

> > The lack of scrollback limits me to 49 lines of SysRq output, and usually the most interesting
> > part disappears off the screen.  Two things I can see:
> > 
> > - SysRq-W shows no blocked tasks
> > - SysRq-M shows zero swap in use, and apparently adequate free memory
> > 	DMA: <various segments> = 9048kB

The interesting information in this case is further up. First look for
the line that looks kinda like this

[2322019.463089]  free:83907 slab_reclaimable:89351 slab_unreclaimable:17263

That's the number of free pages. Further down is the free list contents
and looks kinda like this

[2322019.463159] Node 0 DMA: 0*4kB 0*8kB 0*16kB 1*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15904kB
[2322019.463180] Node 0 DMA32: 11398*4kB 7805*8kB 2186*16kB 3*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 143104kB
[2322019.463201] Node 0 Normal: 28595*4kB 7807*8kB 2*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 176868kB

The free page counter and these free lists should be close together. If
there is a big gap then it's almost certainly the bug Dave identified.

There is another potential infinite loop in kswapd that Johannes has
identified and it could also be that. However, lets rule out Dave's bug
first.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
