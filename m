Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1AAF86B01F2
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 06:23:26 -0400 (EDT)
Message-ID: <24dd01cadc85$b1d9ea10$0400a8c0@dcccs>
From: "Janos Haar" <janos.haar@netcenter.hu>
References: <20100408025822.GL11036@dastard> <11b701cad9c8$93212530$0400a8c0@dcccs> <20100412001158.GA2493@dastard> <18b101cadadf$5edbb660$0400a8c0@dcccs> <20100413083931.GW2493@dastard> <190201cadaeb$02ec22c0$0400a8c0@dcccs> <20100413113445.GZ2493@dastard> <1cd501cadb62$3a93e790$0400a8c0@dcccs> <20100414001615.GC2493@dastard> <233401cadc69$64c1f4f0$0400a8c0@dcccs> <20100415092330.GU2493@dastard>
Subject: Re: Kernel crash in xfs_iflush_cluster (was Somebody take a look please!...)
Date: Thu, 15 Apr 2010 12:23:26 +0200
MIME-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: xiyou.wangcong@gmail.com, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, xfs@oss.sgi.com, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>


----- Original Message ----- 
From: "Dave Chinner" <david@fromorbit.com>
To: "Janos Haar" <janos.haar@netcenter.hu>
Cc: <xiyou.wangcong@gmail.com>; <linux-kernel@vger.kernel.org>; 
<kamezawa.hiroyu@jp.fujitsu.com>; <linux-mm@kvack.org>; <xfs@oss.sgi.com>; 
<axboe@kernel.dk>
Sent: Thursday, April 15, 2010 11:23 AM
Subject: Re: Kernel crash in xfs_iflush_cluster (was Somebody take a look 
please!...)


> On Thu, Apr 15, 2010 at 09:00:49AM +0200, Janos Haar wrote:
>> Dave,
>>
>> The corruption + crash reproduced. (unfortunately)
>>
>> http://download.netcenter.hu/bughunt/20100413/messages-15
>>
>> Apr 14 01:06:33 alfa kernel: XFS mounting filesystem sdb2
>>
>> This was the point of the xfs_repair more times.
>
> OK, the inodes that are corrupted are different, so there's still
> something funky going on here. I still would suggest replacing the
> RAID controller to rule that out as the cause.

This was not a cheap card and i can't replace, because have only one, and 
the owner decided allready about i need to replace the entire server @ 
saturday.
I have only 2 day to get useful debug information when the server is online.
This is bad too for testing, becasue the workload will disappear, and we 
need to figure out something to reproduce the problem offline...

>
> FWIW, do you have any other servers with similar h/w, s/w and
> workloads? If so, are they seeing problems?

This is a web based game, wich generates a loooot of small files on the 
corrupted filesystem, and as far as i see, the corruption happens only @ 
writing, but not when reading.
Because i can copy multiple times big gz files across the partitions, and 
compare, and test for crc, and there is a cron-tester wich tests 12GB gz 
files hourly but can't find any problem, this shows me, the corruption only 
happens when writing, and not on the content, but on the FS.
This scores the RAID card problem more lower, am i right? :-)

Additionally in the last 3 days i have tried 2 times to cp -aR the entire 
partition to another, and both times the corruption appears ON THE SOURCE 
and finally the kernel crashed.

step 1. repair
step 2 run the game (files generated...)
step 3 start copy partition's data in background
step 4 corruption reported by kernel
step 5 kernel crashed during write

Can this be a race between read and write?

Btw i have 2 server with this game, the difference are these:

- The game's language
- The HW's structure similar, but totally different branded all the parts, 
except the Intel CPU. :-)
- The workload is lower on the stable server
- The stable server is not selected for replace. :-)

The important matches:
- The base OS is FC6 on both
- The actual kernel on the stable server is 2.6.28.10
(This kernel starts to crash @ the beginnig of Marc. month on which we are 
working on.)
- The FS and the internal structure is the same

>
> Can you recompile the kernel with CONFIG_XFS_DEBUG enabled and
> reboot into it before you repair and remount the filesystem again?

Yes, of course!
I will do it now, we have 2 days left to get useful infos....

> (i.e. so that we know that we have started with a clean filesystem
> and the debug kernel) I'm hoping that this will catch the corruption
> much sooner, perhaps before it gets to disk. Note that this will
> cause the machine to panic when corruption is detected, and it is
> much,much more careful about checking in memory structures so there
> is a CPU overhead involved as well.

not a problem.


>
> Cheers,
>
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
