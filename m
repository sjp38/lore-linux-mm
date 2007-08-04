Date: Sat, 4 Aug 2007 23:03:51 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070804210351.GA9784@elte.hu>
References: <20070804070737.GA940@elte.hu> <20070804103347.GA1956@elte.hu> <alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org> <20070804163733.GA31001@elte.hu> <alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org> <46B4C0A8.1000902@garzik.org> <20070804191205.GA24723@lazybastard.org> <20070804192130.GA25346@elte.hu> <20070804211156.5f600d80@the-village.bc.nu> <20070804202830.GA4538@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070804202830.GA4538@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: J??rn Engel <joern@logfs.org>, Jeff Garzik <jeff@garzik.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

* Ingo Molnar <mingo@elte.hu> wrote:

> noatime,nodiratime gave 50% of wall-clock kernel rpm build performance 
> improvement for Dave Jones, on a beefy box. Unless i misunderstood 
> what you meant under 'fraction of a percent' your numbers are _WAY_ 
> off. Atime updates are a _huge everyday deal_, from laptops to 
> servers. Everywhere on the planet. Give me a Linux desktop anywhere 
> and i can tell you whether it has atimes on or off, just by clicking 
> around and using apps (without looking at the mount options). That's 
> how i notice it that i forgot to turn off atime on any newly installed 
> system - the system has weird desktop lags and unnecessary disk 
> trashing.

i cannot over-emphasise how much of a deal it is in practice. Atime 
updates are by far the biggest IO performance deficiency that Linux has 
today. Getting rid of atime updates would give us more everyday Linux 
performance than all the pagecache speedups of the past 10 years, 
_combined_.

it's also perhaps the most stupid Unix design idea of all times. Unix is 
really nice and well done, but think about this a bit:

   ' For every file that is read from the disk, lets do a ... write to
     the disk! And, for every file that is already cached and which we
     read from the cache ... do a write to the disk! '

tell that concept to any rookie programmer who knows nothing about 
kernels and the answer will be: 'huh, what? That's gross!'. And Linux 
does this unconditionally for everything, and no, it's not only done on 
some high-security servers that need all sorts of auditing enabled that 
logs every file read - no, it's done by 99% of the Linux desktops and 
servers. For the sake of some lazy mailers that could now be using 
inotify, and for the sake of ... nothing much, really - forensics 
software perhaps.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
