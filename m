Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3F1E06B01F1
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 04:39:51 -0400 (EDT)
Date: Tue, 13 Apr 2010 18:39:31 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Kernel crash in xfs_iflush_cluster (was Somebody take a look
 please!...)
Message-ID: <20100413083931.GW2493@dastard>
References: <20100402230905.GW3335@dastard>
 <22c901cad333$7a67db60$0400a8c0@dcccs>
 <20100404103701.GX3335@dastard>
 <2bd101cad4ec$5a425f30$0400a8c0@dcccs>
 <20100405224522.GZ3335@dastard>
 <3a5f01cad6c5$8a722c00$0400a8c0@dcccs>
 <20100408025822.GL11036@dastard>
 <11b701cad9c8$93212530$0400a8c0@dcccs>
 <20100412001158.GA2493@dastard>
 <18b101cadadf$5edbb660$0400a8c0@dcccs>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <18b101cadadf$5edbb660$0400a8c0@dcccs>
Sender: owner-linux-mm@kvack.org
To: Janos Haar <janos.haar@netcenter.hu>
Cc: xiyou.wangcong@gmail.com, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, xfs@oss.sgi.com, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

On Tue, Apr 13, 2010 at 10:00:17AM +0200, Janos Haar wrote:
> >On Mon, Apr 12, 2010 at 12:44:37AM +0200, Janos Haar wrote:
> >>Hi,
> >>
> >>Ok, here comes the funny part:
> >>I have got several messages from the kernel about one of my XFS
> >>(sdb2) have corrupted inodes, but my xfs_repair (v. 2.8.11) says the
> >>FS is clean and shine.
> >>Should i upgrade my xfs_repair, or this is another bug? :-)
> >
> >v2.8.11 is positively ancient. :/
> >
> >I'd upgrade (current is 3.1.1) and re-run repair again.
> 
> OK, i will get the new repair today.
> 
> btw
> Since i tested the FS with the 2.8.11, today morning i found this in
> the log:
> 
> ...
> Apr 12 00:41:10 alfa kernel: XFS mounting filesystem sdb2   # This
> was the point of check with xfs_repair v2.8.11
> Apr 13 03:08:33 alfa kernel: xfs_da_do_buf: bno 32768
> Apr 13 03:08:33 alfa kernel: dir: inode 474253931
> Apr 13 03:08:33 alfa kernel: Filesystem "sdb2": XFS internal error
> xfs_da_do_buf(1) at line 2020 of file fs/xfs/xfs_da_btree.c.  Caller
> 0xffffffff811c4fa6

A corrupted directory. There have been several different types of
directory corruption that 2.8.11 didn't detect that 3.1.1 does.

> The entire log is here:
> http://download.netcenter.hu/bughunt/20100413/messages

So the bad inodes are:

$ awk '/corrupt inode/ { print $10 } /dir: inode/ { print $8 }' messages | sort -n -u
474253931
474253936
474253937
474253938
474253939
474253940
474253941
474253943
474253945
474253946
474253947
474253948
474253949
474253950
474253951
673160704
673160708
673160712
673160713

It looks like the bad inodes are confined to two inode clusters. The
nature of the errors - bad block mappings and bad extent counts -
makes me think you might have bad memory in the machine:

$ awk '/xfs_da_do_buf: bno/ { printf "%x\n", $8 }' messages | sort -n -u
4d8000
5e0000
7f8001
8000
8001
10000
10001
20001
28001
38000
270001
370001
548001
568000
568001
600000
600001
618000
618001
628000
628001
650001

I think they should all be 0 or 1, and:

$ awk '/corrupt inode/ { split($13, a, ")"); printf "%x\n", a[1] }' messages | sort -n -u
fffffffffd000001
6b000001
1000001
75000001

I think they should all be 1, too.

I've seen this sort of error pattern before on a machine that had a
bad DIMM.  If the corruption is on disk then the buffers were
corrupted between the time that the CPU writes to them and being
written to disk. If there is no corruption on disk, then the CPU is
reading bad data from memory...

If you run:

$ xfs_db -r -c "inode 474253940" -c p /dev/sdb2

Then I can can confirm whether there is corruption on disk or not.
Probably best to sample multiple of the inode numbers from the above
list of bad inodes.

FWIW, I'd strongly suggest backing up everything you can first
before running an updated xfs_repair....

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
