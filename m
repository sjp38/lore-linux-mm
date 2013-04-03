Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id E39106B0006
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 06:19:29 -0400 (EDT)
Date: Wed, 3 Apr 2013 11:19:25 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
Message-ID: <20130403101925.GA7341@suse.de>
References: <20130402142717.GH32241@suse.de>
 <20130402150651.GB31577@thunk.org>
 <20130402151436.GC31577@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130402151436.GC31577@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>

On Tue, Apr 02, 2013 at 11:14:36AM -0400, Theodore Ts'o wrote:
> On Tue, Apr 02, 2013 at 11:06:51AM -0400, Theodore Ts'o wrote:
> > 
> > Can you try 3.9-rc4 or later and see if the problem still persists?
> > There were a number of ext4 issues especially around low memory
> > performance which weren't resolved until -rc4.
> 
> Actually, sorry, I took a closer look and I'm not as sure going to
> -rc4 is going to help (although we did have some ext4 patches to fix a
> number of bugs that flowed in as late as -rc4).
> 

I'm running with -rc5 now. I have not noticed much interactivity problems
as such but the stall detection script reported that mutt stalled for
20 seconds opening an inbox and imapd blocked for 59 seconds doing path
lookups, imaps blocked again for 12 seconds doing an atime update, an RSS
reader blocked for 3.5 seconds writing a file. etc.

There has been no reclaim activity in the system yet and 2G is still free
so it's very unlikely to be a page or slab reclaim problem.

> Can you send us the patch that you used to get record these long stall
> times? 

No patch but it depends on systemtap which you are already aware is a wreck
to work with and frequently breaks between kernel versions for a variety of
reasons. Minimally, it is necessary to revert commit ba6fdda4 (profiling:
Remove unused timer hook) to get systemtap working.  I've reported this
problem to the patch author and the systemtap mailing list.

Other workarounds are necessary so I updated mmtests in git and at
http://www.csn.ul.ie/~mel/projects/mmtests/mmtests-0.10-mmtests-0.01.tar.gz
. Download and untar it

1. stap can be "fixed" by running bin/stap-fix.sh . It will try and run
   a one-liner stap script and if that fails it'll try very crude workarounds.
   Your milage may vary considerably

2. If you want to run the monitor script yourself, it's
   sudo monitors/watch-dstate.pl | tee /tmp/foo.log

   but be aware the log may be truncated due to buffeering.  Optionally you
   can avoid the buffered write problem by running mmtests as

   sudo ./run-mmtests.sh --config configs/config-monitor-interactive stall-debug

   and the log will be in work/log/dstate-stall-debug-monitor.gz

3. Summarise the report with

   cat /tmp/foo.log | subreport/stap-dstate-frequency

I'll be digging through other mmtests results shortly to see if I already
have a better reproduction case that is eligible for bisection but those
results are based on different machines so no guarantees of success.

> And I assume you're using a laptop drive?  5400RPM or 7200RPM?
> 

Yes, laptop drive, 7200RPM. CFQ scheduler. Drive queue depth is 32. 

/dev/sda:

ATA device, with non-removable media
	Model Number:       ST9320423AS                             
	Serial Number:      5VH5M0LY
	Firmware Revision:  0003LVM1
	Transport:          Serial
Standards:
	Used: unknown (minor revision code 0x0029) 
	Supported: 8 7 6 5 
	Likely used: 8
Configuration:
	Logical		max	current
	cylinders	16383	16383
	heads		16	16
	sectors/track	63	63
	--
	CHS current addressable sectors:   16514064
	LBA    user addressable sectors:  268435455
	LBA48  user addressable sectors:  625142448
	Logical  Sector size:                   512 bytes
	Physical Sector size:                   512 bytes
	device size with M = 1024*1024:      305245 MBytes
	device size with M = 1000*1000:      320072 MBytes (320 GB)
	cache/buffer size  = 16384 KBytes
	Nominal Media Rotation Rate: 7200
Capabilities:
	LBA, IORDY(can be disabled)
	Queue depth: 32
	Standby timer values: spec'd by Standard, no device specific minimum
	R/W multiple sector transfer: Max = 16	Current = 16
	Advanced power management level: 128
	Recommended acoustic management value: 254, current value: 0
	DMA: mdma0 mdma1 mdma2 udma0 udma1 udma2 udma3 udma4 *udma5 
	     Cycle time: min=120ns recommended=120ns
	PIO: pio0 pio1 pio2 pio3 pio4 
	     Cycle time: no flow control=120ns  IORDY flow control=120ns
Commands/features:
	Enabled	Supported:
	   *	SMART feature set
	    	Security Mode feature set
	   *	Power Management feature set
	   *	Write cache
	   *	Look-ahead
	   *	Host Protected Area feature set
	   *	WRITE_BUFFER command
	   *	READ_BUFFER command
	   *	DOWNLOAD_MICROCODE
	   *	Advanced Power Management feature set
	    	SET_MAX security extension
	   *	48-bit Address feature set
	   *	Device Configuration Overlay feature set
	   *	Mandatory FLUSH_CACHE
	   *	FLUSH_CACHE_EXT
	   *	SMART error logging
	   *	SMART self-test
	   *	General Purpose Logging feature set
	   *	64-bit World wide name
	   *	IDLE_IMMEDIATE with UNLOAD
	   *	Write-Read-Verify feature set
	   *	WRITE_UNCORRECTABLE_EXT command
	   *	{READ,WRITE}_DMA_EXT_GPL commands
	   *	Segmented DOWNLOAD_MICROCODE
	   *	Gen1 signaling speed (1.5Gb/s)
	   *	Gen2 signaling speed (3.0Gb/s)
	   *	Native Command Queueing (NCQ)
	   *	Phy event counters
	    	Device-initiated interface power management
	   *	Software settings preservation
	   *	SMART Command Transport (SCT) feature set
	   *	SCT Read/Write Long (AC1), obsolete
	   *	SCT Error Recovery Control (AC3)
	   *	SCT Features Control (AC4)
	   *	SCT Data Tables (AC5)
	    	unknown 206[12] (vendor specific)
Security: 
	Master password revision code = 65534
		supported
	not	enabled
	not	locked
		frozen
	not	expired: security count
		supported: enhanced erase
	70min for SECURITY ERASE UNIT. 70min for ENHANCED SECURITY ERASE UNIT. 
Logical Unit WWN Device Identifier: 5000c5002f2d395d
	NAA		: 5
	IEEE OUI	: 000c50
	Unique ID	: 02f2d395d
Checksum: correct

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
