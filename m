Date: Wed, 25 Jul 2007 15:05:09 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: -mm merge plans for 2.6.23
Message-Id: <20070725150509.4d80a85e.pj@sgi.com>
In-Reply-To: <20070725113401.GA23341@elte.hu>
References: <46A58B49.3050508@yahoo.com.au>
	<2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>
	<46A6CC56.6040307@yahoo.com.au>
	<46A6D7D2.4050708@gmail.com>
	<Pine.LNX.4.64.0707242211210.2229@asgard.lang.hm>
	<46A6DFFD.9030202@gmail.com>
	<30701.1185347660@turing-police.cc.vt.edu>
	<46A7074B.50608@gmail.com>
	<20070725082822.GA13098@elte.hu>
	<46A70D37.3060005@gmail.com>
	<20070725113401.GA23341@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: rene.herman@gmail.com, Valdis.Kletnieks@vt.edu, david@lang.hm, nickpiggin@yahoo.com.au, ray-lk@madrabbit.org, jesper.juhl@gmail.com, akpm@linux-foundation.org, ck@vds.kolivas.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> and the fact is: updatedb discards a considerable portion of the cache 
> completely unnecessarily: on a reasonably complex box no way do all the 

I'm wondering how much of this updatedb problem is due to poor layout
of swap and other file systems across disk spindles.

I'll wager that those most impacted by updatedb have just one disk.

I have the following three boxes - three different setups, each with
different updatedb behaviour:

    The first box, with 1 GB ram, becomes dog slow as soon as it
    breaths on the swap device.  Updatedb and backups are painful
    intrusions on any interactive work on that system.  I sometimes
    wait a half minute for a response from an interactive application
    anytime it has to go to disk.  This box has a single disk spindle,
    on an old cheap slow disk, with swap on the opposite end of the
    disk from root and the main usr partition.  It's a worst case
    disk seek test device.

    The second box, also with 1 GB ram, has multiple disk spindles,
    and swap on its own spindle.  I can still notice updatedb and
    backup, but it's far far less painful.

    The third box has dual CPU cores and 4 GB ram.  Updatedb runs
    over the entire system in perhaps 30 seconds with no perceptible
    impact at all on interactive uses.  Everything is still in memory
    from the previous updatedb run; the disk is just used to write
    out new stuff.  Swap is never used on this (sweet) rig.

I'd think that prefetch would help in the single disk spindle
configuration, because it does the swap accesses separately, instead
of intermingling them with root or usr partition accesses, which
would require alot of disk head seeking.

Pretty much anytime that ordinary desktop users complain about
performance as much as they have about this one, it's either disk
head seeks or network delays.  Nothing else is -that- slow, to be so
noticeable to so many users just doing ordinary work.

Question:
  Could those who have found this prefetch helps them alot say how
  many disks they have?  In particular, is their swap on the same
  disk spindle as their root and user files?

Answer - for me:
  On my system where updatedb is a big problem, I have one, slow, disk.
  On my system where updatedb is a small problem, swap is on a separate
    spindle.
  On my system where updatedb is -no- problem, I have so much memory
    I never use swap.

I'd expect the laptop crowd to mostly have a single, slow, disk, and
hence to find updatedb more painful.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
