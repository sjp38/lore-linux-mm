Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EC7606B01F0
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 19:36:59 -0400 (EDT)
Message-ID: <1cd501cadb62$3a93e790$0400a8c0@dcccs>
From: "Janos Haar" <janos.haar@netcenter.hu>
References: <20100404103701.GX3335@dastard> <2bd101cad4ec$5a425f30$0400a8c0@dcccs> <20100405224522.GZ3335@dastard> <3a5f01cad6c5$8a722c00$0400a8c0@dcccs> <20100408025822.GL11036@dastard> <11b701cad9c8$93212530$0400a8c0@dcccs> <20100412001158.GA2493@dastard> <18b101cadadf$5edbb660$0400a8c0@dcccs> <20100413083931.GW2493@dastard> <190201cadaeb$02ec22c0$0400a8c0@dcccs> <20100413113445.GZ2493@dastard>
Subject: Re: Kernel crash in xfs_iflush_cluster (was Somebody take a look please!...)
Date: Wed, 14 Apr 2010 01:36:56 +0200
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

----- Original Message ----- 
From: "Dave Chinner" <david@fromorbit.com>
To: "Janos Haar" <janos.haar@netcenter.hu>
Cc: <xiyou.wangcong@gmail.com>; <linux-kernel@vger.kernel.org>; 
<kamezawa.hiroyu@jp.fujitsu.com>; <linux-mm@kvack.org>; <xfs@oss.sgi.com>; 
<axboe@kernel.dk>
Sent: Tuesday, April 13, 2010 1:34 PM
Subject: Re: Kernel crash in xfs_iflush_cluster (was Somebody take a look 
please!...)


> On Tue, Apr 13, 2010 at 11:23:36AM +0200, Janos Haar wrote:
>> >If you run:
>> >
>> >$ xfs_db -r -c "inode 474253940" -c p /dev/sdb2
>> >
>> >Then I can can confirm whether there is corruption on disk or not.
>> >Probably best to sample multiple of the inode numbers from the above
>> >list of bad inodes.
>>
>> Here is the log:
>> http://download.netcenter.hu/bughunt/20100413/debug.log
>
> There are multiple fields in the inode that are corrupted.
> I am really surprised that xfs-repair - even an old version - is not
> picking up the corruption....

I think i know now the reason....
My case starting to turn into more and more interesting.

(Just a little note for remember: tuesday night, i have run the old 2.8.11 
xfs_repair on the partiton wich was reported as corrupt by the kernel, but 
it was clean.
The system was not restarted!)

Like you suggested, today, i have tried to make a backup from the data.
During the copy, the kernel reported a lot of corrupted entries again, and 
finally the kernel crashed! (with the 19 patch pack)
Unfortunately the kernel can't write the debug info into the syslog.
The system restarted automatically, the service runs again, and i can't do 
another backup attempt because force of the owner.
Today night, when the traffic was in the low period, i have stopped the 
service, umount the partition, and repeat the xfs_repair on the previously 
reported partition on more ways.

Here you can see the results:
xfs_repair 2.8.11 run #1:
http://download.netcenter.hu/bughunt/20100413/repair2811-nr1.log

xfs_repair 2.8.11 run #2:
http://download.netcenter.hu/bughunt/20100413/repair2811-nr2.log

echo 3 >/proc/sys/vm/drop_caches - performed

xfs_repair 2.8.11 run #3:
http://download.netcenter.hu/bughunt/20100413/repair2811-nr3.log

xfs_reapir 3.1.1 run #1:
http://download.netcenter.hu/bughunt/20100413/repair311-nr1.log

xfs_reapir 3.1.1 run #2:  sorry, i had no time to play more offline. :-(

For me, it looks like the FS gets corrupted between tuesday night and today 
night.
Note: because i am expecting kernel crashes, the dirty data flush was set 
for some miliseconds timeout only for prevent too much data lost.
It was one kernel crash in this period, but the XFS have journal, and should 
be cleaned correctly. (i don't think this is the problem)

The other interesting thing is, why only this partition gets corrupted? 
(again, and again?)
Note: this is a partition of 4 disk RAID10 (hw), and 3/4 hdd was replaced in 
the last 3 week because we are hunting this bug....
Note2: why not 4/4? Because the first 3 was fine, and was replaced bigger 
drives, and i don't know what will happen if all the drives will grow, i am 
not sure, about i can replace back the 300G raptors.

>
>> The xfs_db does segmentation fault. :-)
>
> Yup, it probably ran off into la-la land chasing corrupted
> extent pointers.
>
>> Btw memory corruption:
>> In the beginnig of march, one of my bets was memory problem too, but
>> the server was offline for 7 days, and all the time runs the
>> memtest86 on the hw, and passed all the 8GB 74 times without any bit
>> error.
>> I don't think it is memory problem, additionally the server can
>> create big size  .tar.gz files without crc problem.
>
> Ok.
>
>> If i force my mind to think to hw memory problem, i can think only
>> for the raid card's cache memory, wich i can't test with memtest86.
>> Or the cache of the HDD's pcb...
>
> Yes, it could be something like that, too, but the only way to test
> it is to swap out the card....

Yeah, but i don't have another. :-/

>
>> In the other hand, i have seen more people reported memory
>> corruption about these kernel versions, can we check this and surely
>> select wich is the problem? (hw or sw)?
>
> I haven't heard of any significant memory corruption problems in
> 2.6.32 or 2.6.33, but it is a possibility given the nature of the
> corruption. However, I may have only happened once and be completely
> unreproducable.

I have reported one strange bug, this was the first mail in this series, 
with the original title "somebody take a look please.....".
I can see this too in the kernel list: "[Bug #15585] [Bisected Regression in 
2.6.32.8] i915 with KMS enabledcauses memorycorruption when resuming from 
suspend-to-disk"
And another too: "Re: Memory corruption with 2.6.32.10, but not with 
2.6.34-rc3"
Note: i am reading only the titles, i have not too much time actually.

>
> I'd suggest fixing the existing corruption first, and then seeing if
> it re-appears. If it does reappear, then we know there's a
> reproducable problem we need to dig out....

I am on it. :-)

>
>> I mean, if i am right, the hw memory problem makes only 1-2 bit
>> corruption seriously, and the sw page handling problem makes bad
>> memory pages, no?
>
> RAM ECC guarantees correction of single bit errors and detection of
> double bit errors (which cause the kernel to panic, IIRC). I can't
> tell you what happens when larger errors occur, though...

Yes, but this system have non-ECC ram unfortunately.
But i am 99.999% sure, this corruption is not mobo-cpu-ram related.
This must be something else...

Now i am tried to copy in one 4.5GB .gz 3 times into this problematic 
partition, and gzip -v -t on all archives.
All was fine.
This makes me think this is sw problem, and not a simple memory corruption, 
or the corruption can appear only for a short of time in the hw.
This whould be really nasty.

Anyway, i have set up one cron script for test all the 4G .gz files on every 
hours a day, and write to log with dates.
Maybe useful for something....

Thanks again,
Janos

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
