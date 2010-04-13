Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 076346B01E3
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 07:33:57 -0400 (EDT)
Date: Tue, 13 Apr 2010 21:34:45 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Kernel crash in xfs_iflush_cluster (was Somebody take a look
 please!...)
Message-ID: <20100413113445.GZ2493@dastard>
References: <20100404103701.GX3335@dastard>
 <2bd101cad4ec$5a425f30$0400a8c0@dcccs>
 <20100405224522.GZ3335@dastard>
 <3a5f01cad6c5$8a722c00$0400a8c0@dcccs>
 <20100408025822.GL11036@dastard>
 <11b701cad9c8$93212530$0400a8c0@dcccs>
 <20100412001158.GA2493@dastard>
 <18b101cadadf$5edbb660$0400a8c0@dcccs>
 <20100413083931.GW2493@dastard>
 <190201cadaeb$02ec22c0$0400a8c0@dcccs>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <190201cadaeb$02ec22c0$0400a8c0@dcccs>
Sender: owner-linux-mm@kvack.org
To: Janos Haar <janos.haar@netcenter.hu>
Cc: xiyou.wangcong@gmail.com, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, xfs@oss.sgi.com, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

On Tue, Apr 13, 2010 at 11:23:36AM +0200, Janos Haar wrote:
> >If you run:
> >
> >$ xfs_db -r -c "inode 474253940" -c p /dev/sdb2
> >
> >Then I can can confirm whether there is corruption on disk or not.
> >Probably best to sample multiple of the inode numbers from the above
> >list of bad inodes.
> 
> Here is the log:
> http://download.netcenter.hu/bughunt/20100413/debug.log

There are multiple fields in the inode that are corrupted.
I am really surprised that xfs-repair - even an old version - is not
picking up the corruption....

> The xfs_db does segmentation fault. :-)

Yup, it probably ran off into la-la land chasing corrupted
extent pointers.

> Btw memory corruption:
> In the beginnig of march, one of my bets was memory problem too, but
> the server was offline for 7 days, and all the time runs the
> memtest86 on the hw, and passed all the 8GB 74 times without any bit
> error.
> I don't think it is memory problem, additionally the server can
> create big size  .tar.gz files without crc problem.

Ok.

> If i force my mind to think to hw memory problem, i can think only
> for the raid card's cache memory, wich i can't test with memtest86.
> Or the cache of the HDD's pcb...

Yes, it could be something like that, too, but the only way to test
it is to swap out the card....

> In the other hand, i have seen more people reported memory
> corruption about these kernel versions, can we check this and surely
> select wich is the problem? (hw or sw)?

I haven't heard of any significant memory corruption problems in
2.6.32 or 2.6.33, but it is a possibility given the nature of the
corruption. However, I may have only happened once and be completely
unreproducable.

I'd suggest fixing the existing corruption first, and then seeing if
it re-appears. If it does reappear, then we know there's a
reproducable problem we need to dig out....

> I mean, if i am right, the hw memory problem makes only 1-2 bit
> corruption seriously, and the sw page handling problem makes bad
> memory pages, no?

RAM ECC guarantees correction of single bit errors and detection of
double bit errors (which cause the kernel to panic, IIRC). I can't
tell you what happens when larger errors occur, though...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
