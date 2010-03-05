Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 99F536B00AB
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 21:16:07 -0500 (EST)
Received: by iwn29 with SMTP id 29so1954043iwn.27
        for <linux-mm@kvack.org>; Thu, 04 Mar 2010 18:16:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <f875e2fe1003041811p5aa934ecob90836a8d0a6b605@mail.gmail.com>
References: <f875e2fe1003032052p944f32ayfe9fe8cfbed056d4@mail.gmail.com>
	 <20100303224245.ae8d1f7a.akpm@linux-foundation.org>
	 <87f94c371003040617t4a4fcd0dt1c9fc0f50e6002c4@mail.gmail.com>
	 <4B8FC6AC.4060801@teksavvy.com>
	 <f875e2fe1003040733h20d5523ex5d18b84f47fee8c7@mail.gmail.com>
	 <4B8FF2C3.1060808@teksavvy.com>
	 <f875e2fe1003041020t7cbab2c2x585df9b2dfc10dd2@mail.gmail.com>
	 <4B90655B.4000005@gmail.com>
	 <f875e2fe1003041811p5aa934ecob90836a8d0a6b605@mail.gmail.com>
Date: Thu, 4 Mar 2010 20:16:06 -0600
Message-ID: <51f3faa71003041816j427c5072ydd16d6e5b13f1545@mail.gmail.com>
Subject: Re: Linux kernel - Libata bad block error handling to user mode
	program
From: Robert Hancock <hancockrwd@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: s ponnusa <foosaa@gmail.com>
Cc: Mark Lord <kernel@teksavvy.com>, Greg Freemyer <greg.freemyer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, Jens Axboe <jens.axboe@oracle.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 4, 2010 at 8:11 PM, s ponnusa <foosaa@gmail.com> wrote:
>> There's nothing in libata which will cause the operation to eventually
>> return success if the drive keeps failing it (at least there definitely
>> should not be and I very much doubt there is). My guess is that somehow what
>> you think should be happening is not what the drive is actually doing (maybe
>> one of the retries you're seeing is actually succeeding in writing to the
>> disk, or at least the drive reports it was).
>>
>> You haven't posted any of the actual kernel output you're seeing, so it's
>> difficult to say exactly what's going on. However, attempting to scan for
>> disk errors using writes seems like a flawed strategy. As several people
>> have mentioned, drives can't necessarily detect errors on a write.
>>
>
> The scenario involves lots of bad drives with the known bad sectors
> locations. Take MHDD for example, it sends an ATA write command to one
> of the bad sectors, the drive returns failure / timeout, it tries
> again, the drive still says failure / timeout, program comes out and
> says failure. If we are not checking the errors during write process,
> and continue to reallocate the sector or retry the write again, what
> happens after all the available sectors are remapped? I still could
> not visualise it for some reasons.
>
> Consider this scenario:
> My write program says write passed. But when I used another
> verification program (replica of the erasure program but does only
> read / verify) it is unable to read the data and returns failure. No
> other program (for example a Windows based hex editor or DOS based
> disk editor) is able to read the information from that particular
> sector. So, obviously the data written by linux is corrupted and
> cannot be read back by any other means. And the program which wrote
> the data is unaware of the error that has happened at the lower level.
> But the error log clearly has the issue caught but is trying to handle
> differently.
>
> I've attached a part of sample dmesg log which was logged during the
> grinding of bad sector operation and eventually the write passed.

[ 7671.006928] ata1.00: exception Emask 0x0 SAct 0x0 SErr 0x0 action 0x0
[ 7671.006936] ata1.00: BMDMA stat 0x25
[ 7671.006943] ata1.00: cmd c8/00:08:a8:56:75/00:00:00:00:00/e5 tag 0
dma 4096 in
[ 7671.006945]          res 51/40:04:ac:56:75/10:02:05:00:00/e5 Emask
0x9 (media error)
[ 7671.006949] ata1.00: status: { DRDY ERR }
[ 7671.006951] ata1.00: error: { UNC }
[ 7671.028606] ata1.00: configured for UDMA/100
[ 7671.028617] ata1: EH complete

Command C8 is a read that's failing. It looks like almost all of the
failures in that log are from failed reads, I don't see any failed
writes. From what I can see it sounds like the drive is apparently
writing successfully but is unable to read the data back (the reads
being due to read-modify-write operations being done or for some other
reason).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
