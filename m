Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C68196B0203
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 03:01:18 -0400 (EDT)
Message-ID: <233401cadc69$64c1f4f0$0400a8c0@dcccs>
From: "Janos Haar" <janos.haar@netcenter.hu>
References: <20100405224522.GZ3335@dastard> <3a5f01cad6c5$8a722c00$0400a8c0@dcccs> <20100408025822.GL11036@dastard> <11b701cad9c8$93212530$0400a8c0@dcccs> <20100412001158.GA2493@dastard> <18b101cadadf$5edbb660$0400a8c0@dcccs> <20100413083931.GW2493@dastard> <190201cadaeb$02ec22c0$0400a8c0@dcccs> <20100413113445.GZ2493@dastard> <1cd501cadb62$3a93e790$0400a8c0@dcccs> <20100414001615.GC2493@dastard>
Subject: Re: Kernel crash in xfs_iflush_cluster (was Somebody take a look please!...)
Date: Thu, 15 Apr 2010 09:00:49 +0200
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

Dave,

The corruption + crash reproduced. (unfortunately)

http://download.netcenter.hu/bughunt/20100413/messages-15

Apr 14 01:06:33 alfa kernel: XFS mounting filesystem sdb2

This was the point of the xfs_repair more times.

Regards,
Janos

----- Original Message ----- 
From: "Dave Chinner" <david@fromorbit.com>
To: "Janos Haar" <janos.haar@netcenter.hu>
Cc: <xiyou.wangcong@gmail.com>; <linux-kernel@vger.kernel.org>; 
<kamezawa.hiroyu@jp.fujitsu.com>; <linux-mm@kvack.org>; <xfs@oss.sgi.com>; 
<axboe@kernel.dk>
Sent: Wednesday, April 14, 2010 2:16 AM
Subject: Re: Kernel crash in xfs_iflush_cluster (was Somebody take a look 
please!...)


> On Wed, Apr 14, 2010 at 01:36:56AM +0200, Janos Haar wrote:
>> ----- Original Message ----- From: "Dave Chinner"
>> >On Tue, Apr 13, 2010 at 11:23:36AM +0200, Janos Haar wrote:
>> >>>If you run:
>> >>>
>> >>>$ xfs_db -r -c "inode 474253940" -c p /dev/sdb2
>> >>>
>> >>>Then I can can confirm whether there is corruption on disk or not.
>> >>>Probably best to sample multiple of the inode numbers from the above
>> >>>list of bad inodes.
>> >>
>> >>Here is the log:
>> >>http://download.netcenter.hu/bughunt/20100413/debug.log
>> >
>> >There are multiple fields in the inode that are corrupted.
>> >I am really surprised that xfs-repair - even an old version - is not
>> >picking up the corruption....
>>
>> I think i know now the reason....
>> My case starting to turn into more and more interesting.
>>
>> (Just a little note for remember: tuesday night, i have run the old
>> 2.8.11 xfs_repair on the partiton wich was reported as corrupt by
>> the kernel, but it was clean.
>> The system was not restarted!)
>>
>> Like you suggested, today, i have tried to make a backup from the data.
>> During the copy, the kernel reported a lot of corrupted entries
>> again, and finally the kernel crashed! (with the 19 patch pack)
>> Unfortunately the kernel can't write the debug info into the syslog.
>> The system restarted automatically, the service runs again, and i
>> can't do another backup attempt because force of the owner.
>> Today night, when the traffic was in the low period, i have stopped
>> the service, umount the partition, and repeat the xfs_repair on the
>> previously reported partition on more ways.
>>
>> Here you can see the results:
>> xfs_repair 2.8.11 run #1:
>> http://download.netcenter.hu/bughunt/20100413/repair2811-nr1.log
>
> So this successfully detected and repaired the corruption.  I don't
> think this is new corruption - the corrupted inode numbers are the
> same as you reported a few days back.
>
>> xfs_repair 2.8.11 run #2:
>> http://download.netcenter.hu/bughunt/20100413/repair2811-nr2.log
>>
>> echo 3 >/proc/sys/vm/drop_caches - performed
>>
>> xfs_repair 2.8.11 run #3:
>> http://download.netcenter.hu/bughunt/20100413/repair2811-nr3.log
>
> These two are clearing lost+found and rediscovering the
> diesconnected inodes that were discovered in the first pass. Nothing
> wrng here, that's just the way older repair versions behaved.
>
>> xfs_reapir 3.1.1 run #1:
>> http://download.netcenter.hu/bughunt/20100413/repair311-nr1.log
>
> And this detected nothing wrong, either.
>
>> For me, it looks like the FS gets corrupted between tuesday night
>> and today night.
>> Note: because i am expecting kernel crashes, the dirty data flush
>> was set for some miliseconds timeout only for prevent too much data
>> lost.
>> It was one kernel crash in this period, but the XFS have journal,
>> and should be cleaned correctly. (i don't think this is the problem)
>>
>> The other interesting thing is, why only this partition gets
>> corrupted? (again, and again?)
>
> Can you reporduce the corruption again now that the filesystem has
> been repaired? I want to know (if the corruption appears again)
> whether it appears in the same location as this one.
>
>> >>I mean, if i am right, the hw memory problem makes only 1-2 bit
>> >>corruption seriously, and the sw page handling problem makes bad
>> >>memory pages, no?
>> >
>> >RAM ECC guarantees correction of single bit errors and detection of
>> >double bit errors (which cause the kernel to panic, IIRC). I can't
>> >tell you what happens when larger errors occur, though...
>>
>> Yes, but this system have non-ECC ram unfortunately.
>
> If your hardware doesn't have ECC, then you can't rule out anything
> - even a dodgy power supply can cause this sort of transient
> problem. I'm not saying that this is the cause, but I've been
> assuming that you're actually running hardware with ECC on RAM,
> caches, buses, etc.
>
>> This makes me think this is sw problem, and not a simple memory
>> corruption, or the corruption can appear only for a short of time in
>> the hw.
>
> If you can take the performance hit, turn on the kernel memory leak
> detector and see if that catches anything.
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
