Mime-Version: 1.0
Message-Id: <a05100301b791ed376e26@[192.168.239.101]>
In-Reply-To: 
        <Pine.LNX.4.33.0108040952460.1203-100000@penguin.transmeta.com>
References: <Pine.LNX.4.33.0108040952460.1203-100000@penguin.transmeta.com>
Date: Sat, 4 Aug 2001 21:54:54 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: [RFC][DATA] re "ongoing vm suckage"
Content-Type: text/plain; charset="us-ascii" ; format="flowed"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>  > I'm testing 2.4.8-pre4 -- MUCH better interactivity behavior now.
>
>Good.. However..
>
>>  I've been testing ext3/raid5 for several weeks now and this is usable now.
>>  My system is Dual 1Ghz/2GRam/4GSwap fibrechannel.
>>  But...the single thread i/o performance is down.
>
>Bad. And before we get too happy about the interactive thing, let's
>remember that sometimes interactivity comes at the expense of throughput,
>and maybe if we fix the throughput we'll be back where we started.

<snip>

>Rule of thumb: even on fast disks, the average seek time (and between
>requests you almost always have to seek) is on the order of a few
>milliseconds. With a large write-queue (256 total requests means 128 write
>requests) you can basically get single-request latencies of up to a
>second. Which is really bad.

Hard disks, no matter how new or old, tend to have 1/3-stroke seek 
times in the approximate range 5-20ms.  Virtually every other type of 
drive (mainly optical or removable-magnetic) has much slower seek 
times than that - typical new CD-ROM is 80ms+, MO ~100ms, old CD-ROM 
300ms+, dunno any stats for Zip or Jaz - but in general fewer 
processes will be accessing removable media at any one time.

A usable metric might be the amount of sequential I/O possible per 
seek time - this would give a better idea of how much batching to do. 
An interesting application of this is in the hardware of my 
PowerBook's DVD drive, which is capable of playing audio from one 
section of a CD-ROM while reading data from another (most drives will 
simply cancel audio playback on a data request).  It reads about 3 
seconds of audio at a high spinrate, then switches to the data track 
until the audio buffer is almost exhausted, then switches right back 
to the audio track.

I/O-per-seek values are very high for RAID arrays and for writing 
FLASH, high for new hard disks (about 150KB for one of mine), medium 
for new CD-ROM and removable drives, and low for certain classes of 
optical drive, old hard disks, reading FLASH, and instant-access 
media.  Clearing a 128-request queue by writing to a non-LIMDOW MO 
drive can take a very long time!  :)

>One partial solution may be the just make the read queue deeper than the
>write queue. That's a bit more complicated than just changing a single
>value, though - you'd need to make the batching threshold be dependent on
>read-write too etc. But it would probably not be a bad idea to change the
>"split requests evenly" to do even "split requests 2:1 to read:write".

I don't think this will make much of a difference.  The real problem 
could be that devices are plugged when the queue is empty, and not 
unplugged again until absolutely necessary - ie. if the queue is full 
or there is memory pressure.  Since changing the queue size made a 
difference, clearly the queue is filling up, processes are blocking 
on the full queue, and we get right back to good old scheduling 
latency.

I think devices should be unplugged periodically if there is 
*anything* on the queue.  By my book, once there are a few requests 
waiting, it starts being profitable to service them quickly and keep 
the queue moving at all times.  If requests are coming in quickly 
from several directions, they will be merged as and when needed - 
there is no point in waiting around forever for mergable requests 
that never arrive.

>  > I"m seeing a lot more CPU Usage for the 1st thread than previous tests --
>>  perhaps we've shortened the queue too much and it's throttling the read?
>  > Why would CPU usage go up and I/O go down?
>
>I'd guess it's calling the scheduler more. With fast disks and a queue
>that runs out, you'd probably go into a series of extremely short
>stop-start behaviour. Or something similar.

Maybe we need a per-process queue as well as a per-disk queue.  It 
doesn't need to be large - even 4 or 16 requests might help - but it 
would allow a process to submit requests and get it's foot in the 
door even when the per-disk queue is full.  Combining this with the 
shorter per-disk queue might keep the interactivity boost while 
restoring most of the throughput, especially in the multiple-process 
case.  I don't think merging or elevatoring will be needed for the 
per-process queues, which should simplify implementation.

BUT that would mean each per-process queue would have to be scanned 
every time the per-disk queues became non-full.  This might be 
expensive.

An alternative strategy might be to reserve a proportion of each 
per-disk queue for processes that don't already have a request in the 
queue.  This would have a similar effect, but it means extra storage 
per request (for the PID) and the whole queue must be scanned on each 
request-add to check whether it's allowed.  By the look of it, the 
request structure is reasonably large already and there's a fair 
amount of scanning of the queue done already (by the elevator), so 
this might be more acceptable.
-- 
--------------------------------------------------------------
from:     Jonathan "Chromatix" Morton
mail:     chromi@cyberspace.org  (not for attachments)
website:  http://www.chromatix.uklinux.net/vnc/
geekcode: GCS$/E dpu(!) s:- a20 C+++ UL++ P L+++ E W+ N- o? K? w--- O-- M++$
           V? PS PE- Y+ PGP++ t- 5- X- R !tv b++ DI+++ D G e+ h+ r++ y+(*)
tagline:  The key to knowledge is not to rely on people to teach you it.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
