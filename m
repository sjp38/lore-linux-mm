Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C5A356B004D
	for <linux-mm@kvack.org>; Sun, 16 Aug 2009 13:28:49 -0400 (EDT)
Message-ID: <4A8841D7.10506@rtr.ca>
Date: Sun, 16 Aug 2009 13:28:55 -0400
From: Mark Lord <liml@rtr.ca>
MIME-Version: 1.0
Subject: Re: Discard support (was Re: [PATCH] swap: send callback when swap
 slot is freed)
References: <3e8340490908131354q167840fcv124ec56c92bbb830@mail.gmail.com> <4A85E0DC.9040101@rtr.ca> <f3177b9e0908141621j15ea96c0s26124d03fc2b0acf@mail.gmail.com> <20090814234539.GE27148@parisc-linux.org> <f3177b9e0908141719s658dc79eye92ab46558a97260@mail.gmail.com> <1250341176.4159.2.camel@mulgrave.site> <4A86B69C.7090001@rtr.ca> <1250344518.4159.4.camel@mulgrave.site> <20090816150530.2bae6d1f@lxorguk.ukuu.org.uk> <20090816083434.2ce69859@infradead.org> <20090816154430.GE17958@mit.edu>
In-Reply-To: <20090816154430.GE17958@mit.edu>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Theodore Tso <tytso@mit.edu>, Arjan van de Ven <arjan@infradead.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, James Bottomley <James.Bottomley@suse.de>, Mark Lord <liml@rtr.ca>, Chris Worley <worleys@gmail.com>, Matthew Wilcox <matthew@wil.cx>, Bryan Donlan <bdonlan@gmail.com>, david@lang.hm, Greg Freemyer <greg.freemyer@gmail.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nitin Gupta <ngupta@vflare.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, Linux RAID <linux-raid@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Theodore Tso wrote:
..
> Mark Lord has claimed that the currently shipping SSD's take "hundreds
> of milliseconds" for a TRIM, command.
..

Here's some data to support that claim.

First, here are a series of TRIM commands for single-extents
of varying lengths.

The measures include the printk() timestamp, plus I had libata itself
use rdtsc() before/after each TRIM.  This is with a T7400 CPU booted
using maxcpus=1, and locked at 2.16GHz using "performance" CPU policy.

The first set of data, is from individual single-extent TRIMs,
with a "sleep 1 ; sync" between each successive TRIM:

Beginning TRIM operations..
Trimming 1 free extents encompassing 656 sectors (0 MB)
Trimming 1 free extents encompassing 30 sectors (0 MB)
Trimming 1 free extents encompassing 194 sectors (0 MB)
Trimming 1 free extents encompassing 42 sectors (0 MB)
Trimming 1 free extents encompassing 1574 sectors (1 MB)
Trimming 1 free extents encompassing 612 sectors (0 MB)
Trimming 1 free extents encompassing 862 sectors (0 MB)
Trimming 1 free extents encompassing 1344 sectors (1 MB)
Trimming 1 free extents encompassing 822 sectors (0 MB)
Trimming 1 free extents encompassing 672 sectors (0 MB)
Trimming 1 free extents encompassing 226 sectors (0 MB)
Trimming 1 free extents encompassing 860 sectors (0 MB)
Trimming 1 free extents encompassing 638 sectors (0 MB)
Trimming 1 free extents encompassing 1020 sectors (0 MB)
Trimming 1 free extents encompassing 12286 sectors (6 MB)
Trimming 1 free extents encompassing 1964 sectors (1 MB)
Done.
[ 1083.768460] ata_qc_issue: ATA_CMD_DSM starting
[ 1083.768672] trim_completed: ATA_CMD_DSM took 438841 cycles
[ 1084.794304] ata_qc_issue: ATA_CMD_DSM starting
[ 1084.794469] trim_completed: ATA_CMD_DSM took 338065 cycles
[ 1085.823605] ata_qc_issue: ATA_CMD_DSM starting
[ 1085.823791] trim_completed: ATA_CMD_DSM took 382317 cycles
[ 1086.852989] ata_qc_issue: ATA_CMD_DSM starting
[ 1086.853166] trim_completed: ATA_CMD_DSM took 352248 cycles
[ 1087.882825] ata_qc_issue: ATA_CMD_DSM starting
[ 1087.883127] trim_completed: ATA_CMD_DSM took 624546 cycles
[ 1088.915833] ata_qc_issue: ATA_CMD_DSM starting
[ 1088.916056] trim_completed: ATA_CMD_DSM took 455299 cycles
[ 1089.941946] ata_qc_issue: ATA_CMD_DSM starting
[ 1089.942181] trim_completed: ATA_CMD_DSM took 485615 cycles
[ 1090.968793] ata_qc_issue: ATA_CMD_DSM starting
[ 1090.969062] trim_completed: ATA_CMD_DSM took 562042 cycles
[ 1091.994441] ata_qc_issue: ATA_CMD_DSM starting
[ 1091.994672] trim_completed: ATA_CMD_DSM took 479219 cycles
[ 1093.023576] ata_qc_issue: ATA_CMD_DSM starting
[ 1093.023799] trim_completed: ATA_CMD_DSM took 463398 cycles
[ 1094.053545] ata_qc_issue: ATA_CMD_DSM starting
[ 1094.053731] trim_completed: ATA_CMD_DSM took 385229 cycles
[ 1095.083131] ata_qc_issue: ATA_CMD_DSM starting
[ 1095.083356] trim_completed: ATA_CMD_DSM took 458328 cycles
[ 1096.113146] ata_qc_issue: ATA_CMD_DSM starting
[ 1096.113356] trim_completed: ATA_CMD_DSM took 423670 cycles
[ 1097.144211] ata_qc_issue: ATA_CMD_DSM starting
[ 1097.144464] trim_completed: ATA_CMD_DSM took 524706 cycles
[ 1098.174457] ata_qc_issue: ATA_CMD_DSM starting
[ 1098.175619] trim_completed: ATA_CMD_DSM took 2491138 cycles
[ 1099.209218] ata_qc_issue: ATA_CMD_DSM starting
[ 1099.209539] trim_completed: ATA_CMD_DSM took 674752 cycles

Those TRIMs look fine, in the single millisecond range.
But.. the "sleep 1" hides some drive firmware evils..
Here is exactly the same run again, but without the "sleep 1":

Beginning TRIM operations..
Trimming 1 free extents encompassing 656 sectors (0 MB)
Trimming 1 free extents encompassing 30 sectors (0 MB)
Trimming 1 free extents encompassing 194 sectors (0 MB)
Trimming 1 free extents encompassing 42 sectors (0 MB)
Trimming 1 free extents encompassing 1574 sectors (1 MB)
Trimming 1 free extents encompassing 612 sectors (0 MB)
Trimming 1 free extents encompassing 862 sectors (0 MB)
Trimming 1 free extents encompassing 1344 sectors (1 MB)
Trimming 1 free extents encompassing 822 sectors (0 MB)
Trimming 1 free extents encompassing 672 sectors (0 MB)
Trimming 1 free extents encompassing 226 sectors (0 MB)
Trimming 1 free extents encompassing 860 sectors (0 MB)
Trimming 1 free extents encompassing 638 sectors (0 MB)
Trimming 1 free extents encompassing 1020 sectors (0 MB)
Trimming 1 free extents encompassing 12286 sectors (6 MB)
Trimming 1 free extents encompassing 1964 sectors (1 MB)
Done.
[ 1258.206379] ata_qc_issue: ATA_CMD_DSM starting
[ 1258.206587] trim_completed: ATA_CMD_DSM took 426088 cycles
[ 1258.254513] ata_qc_issue: ATA_CMD_DSM starting
[ 1258.366141] trim_completed: ATA_CMD_DSM took 241231523 cycles
[ 1258.411749] ata_qc_issue: ATA_CMD_DSM starting
[ 1258.524047] trim_completed: ATA_CMD_DSM took 242676590 cycles
[ 1258.600184] ata_qc_issue: ATA_CMD_DSM starting
[ 1258.711766] trim_completed: ATA_CMD_DSM took 241136519 cycles
[ 1258.813515] ata_qc_issue: ATA_CMD_DSM starting
[ 1258.910599] trim_completed: ATA_CMD_DSM took 209803152 cycles
[ 1259.027253] ata_qc_issue: ATA_CMD_DSM starting
[ 1259.108916] trim_completed: ATA_CMD_DSM took 176473453 cycles
[ 1259.239549] ata_qc_issue: ATA_CMD_DSM starting
[ 1259.306640] trim_completed: ATA_CMD_DSM took 144968694 cycles
[ 1259.452978] ata_qc_issue: ATA_CMD_DSM starting
[ 1259.505017] trim_completed: ATA_CMD_DSM took 112440172 cycles
[ 1259.552393] ata_qc_issue: ATA_CMD_DSM starting
[ 1259.664739] trim_completed: ATA_CMD_DSM took 242778861 cycles
[ 1259.775724] ata_qc_issue: ATA_CMD_DSM starting
[ 1259.861318] trim_completed: ATA_CMD_DSM took 184955732 cycles
[ 1259.989289] ata_qc_issue: ATA_CMD_DSM starting
[ 1260.059963] trim_completed: ATA_CMD_DSM took 152713730 cycles
[ 1260.211066] ata_qc_issue: ATA_CMD_DSM starting
[ 1260.257474] trim_completed: ATA_CMD_DSM took 100279998 cycles
[ 1260.306277] ata_qc_issue: ATA_CMD_DSM starting
[ 1260.417770] trim_completed: ATA_CMD_DSM took 240932835 cycles
[ 1260.464049] ata_qc_issue: ATA_CMD_DSM starting
[ 1260.575418] trim_completed: ATA_CMD_DSM took 240673134 cycles
[ 1260.650624] ata_qc_issue: ATA_CMD_DSM starting
[ 1260.763510] trim_completed: ATA_CMD_DSM took 243952865 cycles
[ 1260.810454] ata_qc_issue: ATA_CMD_DSM starting
[ 1260.921433] trim_completed: ATA_CMD_DSM took 239832996 cycles

As you can see, we're now into the 100 millisecond range
for successive TRIM-followed-by-TRIM commands.

Those are all for single extents.  I will follow-up with a small
amount of similar data for TRIMs with multiple extents.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
