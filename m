Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C46A96B004D
	for <linux-mm@kvack.org>; Mon, 17 Aug 2009 12:31:18 -0400 (EDT)
Message-ID: <4A8985B6.30103@tmr.com>
Date: Mon, 17 Aug 2009 12:30:46 -0400
From: Bill Davidsen <davidsen@tmr.com>
MIME-Version: 1.0
Subject: Re: Discard support (was Re: [PATCH] swap: send callback when swap
 slot is freed)
References: <3e8340490908131354q167840fcv124ec56c92bbb830@mail.gmail.com> <4A85E0DC.9040101@rtr.ca> <f3177b9e0908141621j15ea96c0s26124d03fc2b0acf@mail.gmail.com> <20090814234539.GE27148@parisc-linux.org> <f3177b9e0908141719s658dc79eye92ab46558a97260@mail.gmail.com> <1250341176.4159.2.camel@mulgrave.site> <4A86B69C.7090001@rtr.ca> <1250344518.4159.4.camel@mulgrave.site> <20090816150530.2bae6d1f@lxorguk.ukuu.org.uk> <20090816083434.2ce69859@infradead.org> <20090816154430.GE17958@mit.edu> <4A8841D7.10506@rtr.ca> <4A8843C3.3020409@rtr.ca>
In-Reply-To: <4A8843C3.3020409@rtr.ca>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mark Lord <liml@rtr.ca>
Cc: Theodore Tso <tytso@mit.edu>, Arjan van de Ven <arjan@infradead.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, James Bottomley <James.Bottomley@suse.de>, Chris Worley <worleys@gmail.com>, Matthew Wilcox <matthew@wil.cx>, Bryan Donlan <bdonlan@gmail.com>, david@lang.hm, Greg Freemyer <greg.freemyer@gmail.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nitin Gupta <ngupta@vflare.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, Linux RAID <linux-raid@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Mark Lord wrote:
> Mark Lord wrote:
> ..
>> As you can see, we're now into the 100 millisecond range
>> for successive TRIM-followed-by-TRIM commands.
>>
>> Those are all for single extents.  I will follow-up with a small
>> amount of similar data for TRIMs with multiple extents.
> ..
>
> Here's the exact same TRIM ranges, but issued with *two* extents
> per TRIM command, and again *without* the "sleep 1" between them:
>
> Beginning TRIM operations..
> Trimming 2 free extents encompassing 686 sectors (0 MB)
> Trimming 2 free extents encompassing 236 sectors (0 MB)
> Trimming 2 free extents encompassing 2186 sectors (1 MB)
> Trimming 2 free extents encompassing 2206 sectors (1 MB)
> Trimming 2 free extents encompassing 1494 sectors (1 MB)
> Trimming 2 free extents encompassing 1086 sectors (1 MB)
> Trimming 2 free extents encompassing 1658 sectors (1 MB)
> Trimming 2 free extents encompassing 14250 sectors (7 MB)
> Done.
> [ 1528.761626] ata_qc_issue: ATA_CMD_DSM starting
> [ 1528.761825] trim_completed: ATA_CMD_DSM took 419952 cycles
> [ 1528.807158] ata_qc_issue: ATA_CMD_DSM starting
> [ 1528.919035] trim_completed: ATA_CMD_DSM took 241772908 cycles
> [ 1528.956048] ata_qc_issue: ATA_CMD_DSM starting
> [ 1529.068536] trim_completed: ATA_CMD_DSM took 243085505 cycles
> [ 1529.156661] ata_qc_issue: ATA_CMD_DSM starting
> [ 1529.266377] trim_completed: ATA_CMD_DSM took 237098927 cycles
> [ 1529.367212] ata_qc_issue: ATA_CMD_DSM starting
> [ 1529.464676] trim_completed: ATA_CMD_DSM took 210619370 cycles
> [ 1529.518619] ata_qc_issue: ATA_CMD_DSM starting
> [ 1529.630444] trim_completed: ATA_CMD_DSM took 241654712 cycles
> [ 1529.739335] ata_qc_issue: ATA_CMD_DSM starting
> [ 1529.829826] trim_completed: ATA_CMD_DSM took 195545233 cycles
> [ 1529.958442] ata_qc_issue: ATA_CMD_DSM starting
> [ 1530.028356] trim_completed: ATA_CMD_DSM took 151077251 cycles
>
> Next, with *four* extents per TRIM:
>
> Beginning TRIM operations..
> Trimming 4 free extents encompassing 922 sectors (0 MB)
> Trimming 4 free extents encompassing 4392 sectors (2 MB)
> Trimming 4 free extents encompassing 2580 sectors (1 MB)
> Trimming 4 free extents encompassing 15908 sectors (8 MB)
> Done.
> [ 1728.923119] ata_qc_issue: ATA_CMD_DSM starting
> [ 1728.923343] trim_completed: ATA_CMD_DSM took 460590 cycles
> [ 1728.975082] ata_qc_issue: ATA_CMD_DSM starting
> [ 1729.087266] trim_completed: ATA_CMD_DSM took 242429200 cycles
> [ 1729.170167] ata_qc_issue: ATA_CMD_DSM starting
> [ 1729.282718] trim_completed: ATA_CMD_DSM took 243229428 cycles
> [ 1729.382328] ata_qc_issue: ATA_CMD_DSM starting
> [ 1729.481364] trim_completed: ATA_CMD_DSM took 214012942 cycles
>
> And with *eight* extents per TRIM:
> Beginning TRIM operations..
> Trimming 8 free extents encompassing 5314 sectors (3 MB)
> Trimming 8 free extents encompassing 18488 sectors (9 MB)
> Done.
> [ 1788.289669] ata_qc_issue: ATA_CMD_DSM starting
> [ 1788.290247] trim_completed: ATA_CMD_DSM took 1228539 cycles
> [ 1788.327223] ata_qc_issue: ATA_CMD_DSM starting
> [ 1788.440490] trim_completed: ATA_CMD_DSM took 244773243 cycles
>
> And finally, with everything in a single TRIM:
>
> Beginning TRIM operations..
> Trimming 16 free extents encompassing 23802 sectors (12 MB)
> Done.
> [ 1841.561147] ata_qc_issue: ATA_CMD_DSM starting
> [ 1841.563217] trim_completed: ATA_CMD_DSM took 4458480 cycles
>
> Notice how the first TRIM of each group above shows an artificially
> short completion time, because the firmware seems to return "done"
> before it's really done.  Subsequent TRIMs seem to have to wait
> for the previous one to really complete, and thus give more reliable
> timing data for our purposes.

I assume that it really is artificial, rather than the device really 
being ready for another operation (other than another TRIM). I lack the 
hardware, but the test would be the time to complete a read, trim and 
read, and two trim and read operations. Just my thought that the TRIM in 
progress may only block the next TRIM, rather than other operations.

-- 
bill davidsen <davidsen@tmr.com>
  CTO TMR Associates, Inc

"You are disgraced professional losers. And by the way, give us our money back."
    - Representative Earl Pomeroy,  Democrat of North Dakota
on the A.I.G. executives who were paid bonuses  after a federal bailout.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
