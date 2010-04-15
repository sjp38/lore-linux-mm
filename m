Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D08D96B01EF
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 02:32:27 -0400 (EDT)
Date: Thu, 15 Apr 2010 16:32:19 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-ID: <20100415063219.GR2493@dastard>
References: <20100415013436.GO2493@dastard>
 <20100415130212.D16E.A69D9226@jp.fujitsu.com>
 <20100415133332.D183.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100415133332.D183.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 15, 2010 at 01:35:17PM +0900, KOSAKI Motohiro wrote:
> > Hi
> > 
> > > How about this? For now, we stop direct reclaim from doing writeback
> > > only on order zero allocations, but allow it for higher order
> > > allocations. That will prevent the majority of situations where
> > > direct reclaim blows the stack and interferes with background
> > > writeout, but won't cause lumpy reclaim to change behaviour.
> > > This reduces the scope of impact and hence testing and validation
> > > the needs to be done.
> > 
> > Tend to agree. but I would proposed slightly different algorithm for
> > avoind incorrect oom.
> > 
> > for high order allocation
> > 	allow to use lumpy reclaim and pageout() for both kswapd and direct reclaim
> > 
> > for low order allocation
> > 	- kswapd:          always delegate io to flusher thread
> > 	- direct reclaim:  delegate io to flusher thread only if vm pressure is low
> > 
> > This seems more safely. I mean Who want see incorrect oom regression?
> > I've made some pathes for this. I'll post it as another mail.
> 
> Now, kernel compile and/or backup operation seems keep nr_vmscan_write==0.
> Dave, can you please try to run your pageout annoying workload?

It's just as easy for you to run and observe the effects. Start with a VM
with 1GB RAM and a 10GB scratch block device:

# mkfs.xfs -f /dev/<blah>
# mount -o logbsize=262144,nobarrier /dev/<blah> /mnt/scratch

in one shell:

# while [ 1 ]; do dd if=/dev/zero of=/mnt/scratch/foo bs=1024k ; done

in another shell, if you have fs_mark installed, run:

# ./fs_mark -S0 -n 100000 -F -s 0 -d /mnt/scratch/0 -d /mnt/scratch/1 -d /mnt/scratch/3 -d /mnt/scratch/2 &

otherwise run a couple of these in parallel on different directories:

# for i in `seq 1 1 100000`; do echo > /mnt/scratch/0/foo.$i ; done

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
