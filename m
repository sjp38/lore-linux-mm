Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 37FC86B0169
	for <linux-mm@kvack.org>; Wed, 24 Aug 2011 05:32:10 -0400 (EDT)
Date: Wed, 24 Aug 2011 17:32:05 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: slow performance on disk/network i/o full speed after
 drop_caches
Message-ID: <20110824093205.GA5214@localhost>
References: <4E5494D4.1050605@profihost.ag>
 <CAOJsxLEFYW0eDbXQ0Uixf-FjsxHZ_1nmnovNx1CWj=m-c-_vJw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAOJsxLEFYW0eDbXQ0Uixf-FjsxHZ_1nmnovNx1CWj=m-c-_vJw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Jens Axboe <jaxboe@fusionio.com>, Linux Netdev List <netdev@vger.kernel.org>

On Wed, Aug 24, 2011 at 02:20:07PM +0800, Pekka Enberg wrote:
> On Wed, Aug 24, 2011 at 9:06 AM, Stefan Priebe - Profihost AG
> <s.priebe@profihost.ag> wrote:
> > i hope this is the correct list to write to if it would be nice to give me a
> > hint where i can ask.
> >
> > Kernel: 2.6.38
> >
> > I'm seeing some strange problems on some of our servers after upgrading to
> > 2.6.38.
> >
> > I'm copying a 1GB file via scp from Machine A to Machine B. When B is
> > freshly booted the file transfer is done with about 80 to 85 Mb/s. I can
> > repeat that various times to performance degrease.
> >
> > Then after some days copying is only done with about 900kb/s up to 3Mb/s
> > going up and down while transfering the file.
> >
> > When i then do drop_caches it works again on 80Mb/s.
> >
> > sync && echo 3 >/proc/sys/vm/drop_caches && sleep 2 && echo 0
> >>/proc/sys/vm/drop_caches
> >
> > Attached is also an output of meminfo before and after drop_caches.
> >
> > What's going on here? MemFree is pretty high.
> >
> > Please CC me i'm not on list.
> 
> Interesting. I can imagine one or more of the following to be
> involved: networking, vmscan, block, and writeback. Lets CC all of
> them!
> 
> > # before drop_caches
> >
> > # cat /proc/meminfo
> > MemTotal: A  A  A  A 8185544 kB
> > MemFree: A  A  A  A  6670292 kB
> > Buffers: A  A  A  A  A 105164 kB
> > Cached: A  A  A  A  A  166672 kB
> > SwapCached: A  A  A  A  A  A 0 kB
> > Active: A  A  A  A  A  728308 kB
> > Inactive: A  A  A  A  567428 kB
> > Active(anon): A  A  639204 kB
> > Inactive(anon): A  394932 kB
> > Active(file): A  A  A 89104 kB
> > Inactive(file): A  172496 kB
> > Unevictable: A  A  A  A 2976 kB
> > Mlocked: A  A  A  A  A  A 2992 kB
> > SwapTotal: A  A  A  1464316 kB
> > SwapFree: A  A  A  A 1464316 kB
> > Dirty: A  A  A  A  A  A  A  A 52 kB
> > Writeback: A  A  A  A  A  A  0 kB

Since dirty/writeback pages are low, it seems not being throttled by
balance_dirty_pages().

Stefan, would you please run this several times on the server?

ps -eo user,pid,tid,class,rtprio,ni,pri,psr,pcpu,vsz,rss,pmem,stat,wchan:28,cmd | grep scp

It will show where the scp task is blocked (the wchan field). Hope it helps.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
