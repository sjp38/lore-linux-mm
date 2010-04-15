Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A714E6B01F9
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 02:44:54 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3F6iquu000907
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 15 Apr 2010 15:44:52 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 11C2345DE53
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 15:44:52 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D39F045DE4E
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 15:44:51 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id AFEB11DB805B
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 15:44:51 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 676F11DB803F
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 15:44:51 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
In-Reply-To: <20100415063219.GR2493@dastard>
References: <20100415133332.D183.A69D9226@jp.fujitsu.com> <20100415063219.GR2493@dastard>
Message-Id: <20100415154328.D18F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 15 Apr 2010 15:44:50 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> On Thu, Apr 15, 2010 at 01:35:17PM +0900, KOSAKI Motohiro wrote:
> > > Hi
> > > 
> > > > How about this? For now, we stop direct reclaim from doing writeback
> > > > only on order zero allocations, but allow it for higher order
> > > > allocations. That will prevent the majority of situations where
> > > > direct reclaim blows the stack and interferes with background
> > > > writeout, but won't cause lumpy reclaim to change behaviour.
> > > > This reduces the scope of impact and hence testing and validation
> > > > the needs to be done.
> > > 
> > > Tend to agree. but I would proposed slightly different algorithm for
> > > avoind incorrect oom.
> > > 
> > > for high order allocation
> > > 	allow to use lumpy reclaim and pageout() for both kswapd and direct reclaim
> > > 
> > > for low order allocation
> > > 	- kswapd:          always delegate io to flusher thread
> > > 	- direct reclaim:  delegate io to flusher thread only if vm pressure is low
> > > 
> > > This seems more safely. I mean Who want see incorrect oom regression?
> > > I've made some pathes for this. I'll post it as another mail.
> > 
> > Now, kernel compile and/or backup operation seems keep nr_vmscan_write==0.
> > Dave, can you please try to run your pageout annoying workload?
> 
> It's just as easy for you to run and observe the effects. Start with a VM
> with 1GB RAM and a 10GB scratch block device:
> 
> # mkfs.xfs -f /dev/<blah>
> # mount -o logbsize=262144,nobarrier /dev/<blah> /mnt/scratch
> 
> in one shell:
> 
> # while [ 1 ]; do dd if=/dev/zero of=/mnt/scratch/foo bs=1024k ; done
> 
> in another shell, if you have fs_mark installed, run:
> 
> # ./fs_mark -S0 -n 100000 -F -s 0 -d /mnt/scratch/0 -d /mnt/scratch/1 -d /mnt/scratch/3 -d /mnt/scratch/2 &
> 
> otherwise run a couple of these in parallel on different directories:
> 
> # for i in `seq 1 1 100000`; do echo > /mnt/scratch/0/foo.$i ; done

Thanks.

Unfortunately, I don't have unused disks. So, I'll try it at (probably)
next week.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
