Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id lBFAiubA011137
	for <linux-mm@kvack.org>; Sat, 15 Dec 2007 16:14:56 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBFAitgi491584
	for <linux-mm@kvack.org>; Sat, 15 Dec 2007 16:14:55 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id lBFAit7n030448
	for <linux-mm@kvack.org>; Sat, 15 Dec 2007 10:44:55 GMT
Date: Sat, 15 Dec 2007 16:14:34 +0530
From: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Subject: Re: 2.6.22-stable causes oomkiller to be invoked
Message-ID: <20071215104434.GA26325@linux.vnet.ibm.com>
Reply-To: Dhaval Giani <dhaval@linux.vnet.ibm.com>
References: <20071213175423.GA2977@linux.vnet.ibm.com> <476295FF.1040202@gmail.com> <20071214154711.GD23670@linux.vnet.ibm.com> <4762A721.7080400@gmail.com> <20071214161637.GA2687@linux.vnet.ibm.com> <20071214095023.b5327703.akpm@linux-foundation.org> <20071214182802.GC2576@linux.vnet.ibm.com> <20071214150533.aa30efd4.akpm@linux-foundation.org> <20071215035200.GA22082@linux.vnet.ibm.com> <20071214220030.325f82b8.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071214220030.325f82b8.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, clameter@sgi.com
Cc: htejun@gmail.com, gregkh@suse.de, stable@kernel.org, linux-kernel@vger.kernel.org, maneesh@linux.vnet.ibm.com, vatsa@linux.vnet.ibm.com, balbir@in.ibm.com, ego@in.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Dec 14, 2007 at 10:00:30PM -0800, Andrew Morton wrote:
> On Sat, 15 Dec 2007 09:22:00 +0530 Dhaval Giani <dhaval@linux.vnet.ibm.com> wrote:
> 
> > > Is it really the case that the bug only turns up when you run tests like
> > > 
> > > 	while echo; do cat /sys/kernel/kexec_crash_loaded; done
> > > and
> > > 	while echo; do cat /sys/kernel/uevent_seqnum ; done;
> > > 
> > > or will any fork-intensive workload also do it?  Say,
> > > 
> > > 	while echo ; do true ; done
> > > 
> > 
> > This does not leak, but having a simple text file and reading it in a
> > loop causes it.
> 
> hm.
> 
> > > ?
> > > 
> > > Another interesting factoid here is that after the oomkilling you slabinfo has
> > > 
> > > mm_struct             38     98    584    7    1 : tunables   32   16    8 : slabdata     14     14      0 : globalstat    2781    196    49   31 				   0    1    0    0    0 : cpustat 368800  11864 368920  11721
> > > 
> > > so we aren't leaking mm_structs.  In fact we aren't leaking anything from
> > > slab.   But we are leaking pgds.
> > > 
> > > iirc the most recent change we've made in the pgd_t area is the quicklist
> > > management which went into 2.6.22-rc1.  You say the bug was present in
> > > 2.6.22.  Can you test 2.6.21?  
> > 
> > Nope, leak is not present in 2.6.21.7
> 
> Could you try this debug patch please?
> 

Here is the dmesg with that patch,

use, ignoring.
PCI: Unable to reserve mem region #2:1000@edffe000 for device 0000:08:0a.1
aic7xxx: <Adaptec AIC-7899 Ultra 160/m SCSI host adapter> at PCI 8/10/1
aic7xxx: I/O ports already in use, ignoring.
megaraid cmm: 2.20.2.7 (Release Date: Sun Jul 16 00:01:03 EST 2006)
megaraid: 2.20.5.1 (Release Date: Thu Nov 16 15:32:35 EST 2006)
megasas: 00.00.03.16-rc1 Thu. Nov. 07 10:09:32 PDT 2007
st: Version 20070203, fixed bufsize 32768, s/g segs 256
osst :I: Tape driver with OnStream support version 0.99.4
osst :I: $Id: osst.c,v 1.73 2005/01/01 21:13:34 wriede Exp $
sd 1:0:0:0: [sda] 71096640 512-byte hardware sectors (36401 MB)
sd 1:0:0:0: [sda] Write Protect is off
sd 1:0:0:0: [sda] Mode Sense: cb 00 00 08
sd 1:0:0:0: [sda] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
sd 1:0:0:0: [sda] 71096640 512-byte hardware sectors (36401 MB)
sd 1:0:0:0: [sda] Write Protect is off
sd 1:0:0:0: [sda] Mode Sense: cb 00 00 08
sd 1:0:0:0: [sda] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
 sda: sda1
sd 1:0:0:0: [sda] Attached SCSI disk
sd 1:0:1:0: [sdb] 71096640 512-byte hardware sectors (36401 MB)
sd 1:0:1:0: [sdb] Write Protect is off
sd 1:0:1:0: [sdb] Mode Sense: cb 00 00 08
sd 1:0:1:0: [sdb] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
sd 1:0:1:0: [sdb] 71096640 512-byte hardware sectors (36401 MB)
sd 1:0:1:0: [sdb] Write Protect is off
sd 1:0:1:0: [sdb] Mode Sense: cb 00 00 08
sd 1:0:1:0: [sdb] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
 sdb: sdb1 sdb2 sdb3 sdb4
sd 1:0:1:0: [sdb] Attached SCSI disk
sd 1:0:2:0: [sdc] 71096640 512-byte hardware sectors (36401 MB)
sd 1:0:2:0: [sdc] Write Protect is off
sd 1:0:2:0: [sdc] Mode Sense: cb 00 00 08
sd 1:0:2:0: [sdc] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
sd 1:0:2:0: [sdc] 71096640 512-byte hardware sectors (36401 MB)
sd 1:0:2:0: [sdc] Write Protect is off
sd 1:0:2:0: [sdc] Mode Sense: cb 00 00 08
sd 1:0:2:0: [sdc] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
 sdc: sdc1 sdc2
sd 1:0:2:0: [sdc] Attached SCSI disk
sd 1:0:3:0: [sdd] 71096640 512-byte hardware sectors (36401 MB)
sd 1:0:3:0: [sdd] Write Protect is off
sd 1:0:3:0: [sdd] Mode Sense: cb 00 00 08
sd 1:0:3:0: [sdd] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
sd 1:0:3:0: [sdd] 71096640 512-byte hardware sectors (36401 MB)
sd 1:0:3:0: [sdd] Write Protect is off
sd 1:0:3:0: [sdd] Mode Sense: cb 00 00 08
sd 1:0:3:0: [sdd] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
 sdd: sdd1 sdd2 sdd3
sd 1:0:3:0: [sdd] Attached SCSI disk
sd 1:0:4:0: [sde] 71096640 512-byte hardware sectors (36401 MB)
sd 1:0:4:0: [sde] Write Protect is off
sd 1:0:4:0: [sde] Mode Sense: cb 00 00 08
sd 1:0:4:0: [sde] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
sd 1:0:4:0: [sde] 71096640 512-byte hardware sectors (36401 MB)
sd 1:0:4:0: [sde] Write Protect is off
sd 1:0:4:0: [sde] Mode Sense: cb 00 00 08
sd 1:0:4:0: [sde] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
 sde: sde1
sd 1:0:4:0: [sde] Attached SCSI disk
sd 1:0:5:0: [sdf] 71096640 512-byte hardware sectors (36401 MB)
sd 1:0:5:0: [sdf] Write Protect is off
sd 1:0:5:0: [sdf] Mode Sense: b3 00 10 08
sd 1:0:5:0: [sdf] Write cache: disabled, read cache: enabled, supports DPO and FUA
sd 1:0:5:0: [sdf] 71096640 512-byte hardware sectors (36401 MB)
sd 1:0:5:0: [sdf] Write Protect is off
sd 1:0:5:0: [sdf] Mode Sense: b3 00 10 08
sd 1:0:5:0: [sdf] Write cache: disabled, read cache: enabled, supports DPO and FUA
 sdf: sdf1
sd 1:0:5:0: [sdf] Attached SCSI disk
sd 1:0:0:0: Attached scsi generic sg0 type 0
sd 1:0:1:0: Attached scsi generic sg1 type 0
sd 1:0:2:0: Attached scsi generic sg2 type 0
sd 1:0:3:0: Attached scsi generic sg3 type 0
sd 1:0:4:0: Attached scsi generic sg4 type 0
sd 1:0:5:0: Attached scsi generic sg5 type 0
scsi 1:0:8:0: Attached scsi generic sg6 type 3
Fusion MPT base driver 3.04.06
Copyright (c) 1999-2007 LSI Corporation
Fusion MPT SPI Host driver 3.04.06
Fusion MPT FC Host driver 3.04.06
Fusion MPT SAS Host driver 3.04.06
Fusion MPT misc device (ioctl) driver 3.04.06
mptctl: Registered with Fusion MPT base driver
mptctl: /dev/mptctl @ (major,minor=10,220)
ieee1394: raw1394: /dev/raw1394 device initialized
PNP: PS/2 Controller [PNP0303:PS2K,PNP0f13:PS2M] at 0x64,0x60 irq 1,12
PNP: PS/2 controller has invalid data port 0x64; using default 0x60
PNP: PS/2 controller has invalid command port 0x60; using default 0x64
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mice: PS/2 mouse device common for all mice
device-mapper: ioctl: 4.13.0-ioctl (2007-10-18) initialised: dm-devel@redhat.com
oprofile: using NMI interrupt.
TCP cubic registered
NET: Registered protocol family 1
NET: Registered protocol family 17
p4-clockmod: P4/Xeon(TM) CPU On-Demand Clock Modulation available
Testing NMI watchdog ... OK.
Using IPI No-Shortcut mode
Freeing unused kernel memory: 240k freed
XXX sysfs_page_cnt=1
sd_mod: version magic '2.6.15.4 SMP PENTIUM4 REGPARM 4KSTACKS gcc-3.4' should be '2.6.24-rc5-mm1 SMP mod_unload PENTIUM4 '
aic7xxx: version magic '2.6.15.4 SMP PENTIUM4 REGPARM 4KSTACKS gcc-3.4' should be '2.6.24-rc5-mm1 SMP mod_unload PENTIUM4 '
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
XXX sysfs_page_cnt=1
warning: process `kmodule' used the deprecated sysctl system call with 1.23.
EXT3 FS on sdd1, internal journal
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sdd3, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sdf1, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
Adding 1863532k swap on /dev/sdb3.  Priority:-1 extents:1 across:1863532k
tg3: eth0: Link is up at 100 Mbps, full duplex.
tg3: eth0: Flow control is off for TX and off for RX.
XXX sysfs_page_cnt=1
XXX sysfs_page_cnt=1
eek: 1000
eek: 1000
eek: 1000
eek: 1000
eek: 1000
eek: 1000
eek: 1000
eek: 1000
eek: 1000
eek: 1000
eek: 1000
eek: 1000
eek: 1000
eek: 1000
eek: 1000
eek: 1000
eek: 1000
eek: 1000
eek: 1000
XXX sysfs_page_cnt=1
eek: 2000
eek: 2000
eek: 2000
eek: 2000
eek: 2000
eek: 2000
eek: 2000
eek: 2000
eek: 2000
eek: 2000
eek: 2000
XXX sysfs_page_cnt=1
eek: 3000
eek: 3000
eek: 3000
eek: 3000
eek: 3000
XXX sysfs_page_cnt=1
eek: 3000
eek: 3000
eek: 3000
eek: 3000
eek: 3000
eek: 3000
eek: 3000
eek: 4000
eek: 4000
eek: 4000
eek: 4000
eek: 4000
eek: 4000
XXX sysfs_page_cnt=1
eek: 4000
eek: 4000
eek: 4000
eek: 5000
eek: 5000
eek: 5000
eek: 5000
eek: 5000
eek: 5000
XXX sysfs_page_cnt=1
eek: 5000
eek: 5000
eek: 5000
eek: 5000
eek: 5000
eek: 5000
eek: 5000
eek: 5000
eek: 5000
eek: 5000
eek: 5000
eek: 5000
eek: 5000
eek: 5000
eek: 5000
eek: 5000
eek: 5000
eek: 6000
eek: 6000
eek: 6000
eek: 6000
eek: 6000
eek: 6000
XXX sysfs_page_cnt=1
eek: 6000
eek: 6000
eek: 6000
eek: 6000
eek: 6000
eek: 6000
eek: 6000
eek: 6000
eek: 6000
eek: 6000
eek: 6000
eek: 6000
eek: 6000
eek: 6000
eek: 6000
eek: 6000
eek: 6000
eek: 6000
eek: 6000
eek: 7000
eek: 7000
eek: 7000
eek: 7000
eek: 7000
XXX sysfs_page_cnt=1
eek: 8000
eek: 8000
eek: 8000
eek: 8000
eek: 7000
eek: 7000
eek: 7000
eek: 7000
eek: 7000
eek: 7000
eek: 7000
eek: 7000
eek: 8000
eek: 7000
eek: 7000
eek: 7000
eek: 7000
eek: 7000
eek: 7000
eek: 7000
XXX sysfs_page_cnt=1
eek: 9000
eek: 9000
eek: 9000
eek: 9000
eek: 9000
eek: 9000
eek: 8000
eek: 8000
eek: 8000
eek: 8000
eek: 8000
eek: 8000
eek: 8000
eek: 8000
eek: 8000
eek: 8000
eek: 8000
eek: 8000
eek: 8000
eek: 8000
eek: 8000
eek: 8000
eek: 8000
eek: 8000
eek: 8000
eek: 8000
eek: 8000
XXX sysfs_page_cnt=1
eek: 10000
eek: 10000
eek: 10000
eek: 10000
eek: 10000
eek: 10000
eek: 9000
eek: 9000
eek: 9000
eek: 9000
eek: 9000
eek: 9000
eek: 9000
eek: 9000
eek: 9000
XXX sysfs_page_cnt=1
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
XXX sysfs_page_cnt=1
eek: 10000
eek: 10000
eek: 10000
eek: 10000
eek: 10000
eek: 12000
eek: 12000
eek: 12000
eek: 12000
eek: 12000
XXX sysfs_page_cnt=1
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 11000
eek: 13000
eek: 13000
eek: 13000
eek: 13000
eek: 13000
eek: 13000
XXX sysfs_page_cnt=1
eek: 12000
eek: 12000
eek: 12000
eek: 12000
eek: 12000
eek: 12000
eek: 12000
eek: 12000
eek: 12000
eek: 14000
eek: 14000
eek: 14000
eek: 14000
eek: 14000
eek: 14000
XXX sysfs_page_cnt=1
eek: 15000
eek: 13000
eek: 13000
eek: 15000
eek: 15000
eek: 15000
eek: 15000
XXX sysfs_page_cnt=1
eek: 16000
eek: 16000
eek: 16000
eek: 16000
eek: 14000
eek: 14000
eek: 14000
eek: 14000
eek: 14000
eek: 14000
eek: 16000
eek: 16000
XXX sysfs_page_cnt=1
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 15000
eek: 15000
eek: 15000
eek: 15000
eek: 15000
eek: 15000
XXX sysfs_page_cnt=1
eek: 18000
eek: 18000
eek: 18000
eek: 18000
eek: 18000
XXX sysfs_page_cnt=1
eek: 16000
eek: 16000
eek: 16000
eek: 16000
eek: 16000
eek: 16000
eek: 19000
eek: 19000
eek: 19000
eek: 19000
eek: 19000
eek: 19000
XXX sysfs_page_cnt=1
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 17000
eek: 20000
eek: 20000
eek: 20000
eek: 20000
eek: 20000
eek: 20000
XXX sysfs_page_cnt=1
eek: 18000
eek: 18000
eek: 18000
eek: 18000
eek: 18000
eek: 18000
eek: 18000
eek: 18000
eek: 18000
eek: 18000
eek: 21000
eek: 21000
eek: 21000
eek: 21000
eek: 21000
eek: 21000
XXX sysfs_page_cnt=1
eek: 19000
eek: 19000
eek: 19000
eek: 19000
eek: 19000
eek: 19000
eek: 19000
eek: 22000
eek: 22000
eek: 22000
eek: 22000
eek: 22000
XXX sysfs_page_cnt=1
eek: 23000
eek: 23000
eek: 20000
eek: 20000
eek: 20000
eek: 20000
eek: 20000
eek: 20000
eek: 20000
eek: 20000
eek: 20000
eek: 20000
eek: 20000
eek: 20000
eek: 20000
eek: 20000
eek: 20000
eek: 20000
eek: 20000
eek: 20000
eek: 20000
eek: 20000
eek: 20000
eek: 20000
eek: 20000
eek: 20000
eek: 20000
eek: 20000
eek: 23000
eek: 23000
eek: 23000
eek: 23000
XXX sysfs_page_cnt=1
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 21000
eek: 21000
eek: 21000
eek: 21000
eek: 21000
eek: 21000
eek: 21000
eek: 21000
eek: 24000
eek: 24000
XXX sysfs_page_cnt=1
eek: 25000
eek: 25000
eek: 25000
eek: 25000
eek: 25000
eek: 25000
eek: 22000
eek: 22000
eek: 22000
eek: 22000
eek: 22000
eek: 22000
eek: 22000
eek: 22000
eek: 22000
eek: 22000
eek: 22000
eek: 22000
eek: 22000
eek: 22000
eek: 22000
XXX sysfs_page_cnt=1
eek: 26000
eek: 26000
eek: 26000
eek: 26000
eek: 26000
XXX sysfs_page_cnt=1
eek: 23000
eek: 23000
eek: 23000
eek: 23000
eek: 23000
eek: 23000
eek: 23000
eek: 23000
eek: 23000
eek: 23000
eek: 23000
eek: 23000
eek: 23000
eek: 23000
eek: 23000
eek: 23000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
XXX sysfs_page_cnt=1
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 24000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
XXX sysfs_page_cnt=1
eek: 25000
eek: 25000
eek: 25000
eek: 25000
eek: 25000
eek: 25000
eek: 25000
eek: 25000
eek: 25000
eek: 25000
eek: 25000
eek: 25000
eek: 25000
eek: 25000
eek: 25000
eek: 25000
eek: 25000
eek: 25000
eek: 25000
eek: 25000
eek: 25000
eek: 25000
eek: 25000
eek: 25000
eek: 25000
eek: 25000
eek: 29000
eek: 29000
eek: 29000
eek: 29000
eek: 29000
XXX sysfs_page_cnt=1
eek: 30000
eek: 30000
eek: 26000
eek: 26000
eek: 30000
eek: 30000
eek: 30000
eek: 30000
XXX sysfs_page_cnt=1
eek: 31000
eek: 31000
eek: 31000
eek: 31000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 27000
eek: 31000
eek: 31000
XXX sysfs_page_cnt=1
eek: 32000
eek: 32000
eek: 32000
eek: 32000
eek: 32000
eek: 32000
XXX sysfs_page_cnt=1
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 28000
eek: 33000
eek: 33000
eek: 33000
eek: 33000
eek: 33000
eek: 33000
XXX sysfs_page_cnt=1
eek: 29000
eek: 29000
eek: 29000
eek: 29000
eek: 29000
eek: 29000
eek: 29000
eek: 29000
eek: 29000
eek: 29000
eek: 29000
eek: 29000
eek: 34000
eek: 34000
eek: 34000
eek: 34000
eek: 34000
eek: 34000
XXX sysfs_page_cnt=1
eek: 30000
eek: 30000
eek: 30000
eek: 30000
eek: 30000
eek: 30000
eek: 30000
eek: 30000
eek: 30000
eek: 30000
eek: 30000
eek: 30000
eek: 30000
eek: 30000
eek: 30000
eek: 30000
eek: 30000
eek: 30000
eek: 30000
eek: 30000
eek: 30000
eek: 30000
eek: 30000
eek: 30000
eek: 30000
eek: 35000
eek: 35000
eek: 35000
eek: 35000
eek: 35000
eek: 35000
XXX sysfs_page_cnt=1
eek: 31000
eek: 31000
eek: 36000
eek: 36000
eek: 36000
XXX sysfs_page_cnt=1
eek: 36000
eek: 36000
eek: 37000
eek: 32000
eek: 32000
eek: 32000
eek: 32000
eek: 32000
eek: 32000
eek: 32000
eek: 32000
eek: 32000
eek: 32000
eek: 32000
eek: 32000
eek: 32000
eek: 32000
eek: 32000
eek: 37000
eek: 37000
XXX sysfs_page_cnt=1
eek: 37000
eek: 37000
eek: 38000
eek: 38000
eek: 38000
eek: 33000
eek: 33000
eek: 33000
eek: 33000
eek: 33000
eek: 33000
eek: 33000
eek: 33000
eek: 33000
eek: 33000
XXX sysfs_page_cnt=1
eek: 38000
eek: 38000
eek: 39000
eek: 39000
eek: 39000
eek: 39000
eek: 34000
eek: 34000
eek: 34000
eek: 34000
eek: 34000
eek: 34000
eek: 34000
eek: 34000
eek: 34000
eek: 34000
XXX sysfs_page_cnt=1
eek: 39000
eek: 39000
eek: 40000
eek: 40000
eek: 40000
eek: 40000
XXX sysfs_page_cnt=1
eek: 40000
eek: 40000
eek: 35000
eek: 35000
eek: 35000
eek: 35000
eek: 35000
eek: 41000
eek: 41000
eek: 41000
eek: 41000
XXX sysfs_page_cnt=1
eek: 41000
eek: 41000
eek: 36000
eek: 36000
eek: 36000
eek: 36000
eek: 36000
eek: 42000
eek: 42000
eek: 42000
eek: 42000
XXX sysfs_page_cnt=1
eek: 42000
eek: 42000
eek: 37000
eek: 37000
eek: 37000
eek: 43000
eek: 43000
eek: 43000
eek: 43000
XXX sysfs_page_cnt=1
eek: 43000
eek: 43000
eek: 38000
eek: 38000
eek: 38000
eek: 38000
eek: 38000
eek: 38000
eek: 38000
eek: 38000
eek: 38000
eek: 38000
eek: 38000
eek: 38000
eek: 38000
eek: 38000
eek: 38000
eek: 44000
eek: 44000
eek: 44000
eek: 44000
XXX sysfs_page_cnt=1
eek: 44000
eek: 44000
eek: 45000
eek: 45000
eek: 39000
eek: 39000
eek: 45000
eek: 45000
XXX sysfs_page_cnt=1
bash invoked oom-killer: gfp_mask=0x84d0, order=0, oomkilladj=0
Pid: 4434, comm: bash Not tainted 2.6.24-rc5-mm1 #9
 [<c010582a>] show_trace_log_lvl+0x12/0x22
 [<c0105847>] show_trace+0xd/0xf
 [<c0105959>] dump_stack+0x57/0x5e
 [<c015a0f3>] oom_kill_process+0x37/0xdb
 [<c015a300>] out_of_memory+0xbd/0xf1
 [<c015b977>] __alloc_pages+0x23f/0x2cc
 [<c011b6ca>] pte_alloc_one+0x15/0x3e
 [<c01632fc>] __pte_alloc+0x15/0xaf
 [<c016350b>] copy_pte_range+0x43/0x293
 [<c0163877>] copy_page_range+0x11c/0x154
 [<c0122ac9>] dup_mmap+0x1ab/0x20c
 [<c0122e72>] dup_mm+0x81/0xd1
 [<c0122f2a>] copy_mm+0x68/0x98
 [<c0123bdc>] copy_process+0x47d/0x9fd
 [<c0124279>] do_fork+0x8d/0x1d2
 [<c0103aba>] sys_clone+0x1f/0x21
 [<c01049fa>] sysenter_past_esp+0x5f/0xa5
 =======================
Mem-info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
CPU    2: hi:    0, btch:   1 usd:   0
CPU    3: hi:    0, btch:   1 usd:   0
CPU    4: hi:    0, btch:   1 usd:   0
CPU    5: hi:    0, btch:   1 usd:   0
CPU    6: hi:    0, btch:   1 usd:   0
CPU    7: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:  186, btch:  31 usd:  15
CPU    1: hi:  186, btch:  31 usd: 183
CPU    2: hi:  186, btch:  31 usd:  21
CPU    3: hi:  186, btch:  31 usd: 168
CPU    4: hi:  186, btch:  31 usd:   6
CPU    5: hi:  186, btch:  31 usd: 184
CPU    6: hi:  186, btch:  31 usd:  30
CPU    7: hi:  186, btch:  31 usd: 180
HighMem per-cpu:
CPU    0: hi:  186, btch:  31 usd:   8
CPU    1: hi:  186, btch:  31 usd: 181
CPU    2: hi:  186, btch:  31 usd:  24
CPU    3: hi:  186, btch:  31 usd: 155
CPU    4: hi:  186, btch:  31 usd:   8
CPU    5: hi:  186, btch:  31 usd: 178
CPU    6: hi:  186, btch:  31 usd:  12
CPU    7: hi:  186, btch:  31 usd: 167
Active:1938 inactive:1234 dirty:0 writeback:0 unstable:0
 free:986779 slab:2584 mapped:851 pagetables:120 bounce:0
DMA free:3496kB min:64kB low:80kB high:96kB active:0kB inactive:0kB present:16016kB pages_scanned:0 all_unreclaimable? yes
lowmem_reserve[]: 0 860 4989 4989
Normal free:3604kB min:3720kB low:4648kB high:5580kB active:0kB inactive:0kB present:880880kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 33033 33033
HighMem free:3940016kB min:512kB low:4976kB high:9440kB active:7808kB inactive:4936kB present:4228224kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 3*4kB 4*8kB 4*16kB 4*32kB 4*64kB 2*128kB 1*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 3564kB
Normal: 1*4kB 4*8kB 1*16kB 1*32kB 0*64kB 0*128kB 0*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3668kB
HighMem: 127*4kB 535*8kB 270*16kB 93*32kB 32*64kB 8*128kB 1*256kB 1*512kB 2*1024kB 1*2048kB 957*4096kB = 3939892kB
Swap cache: add 0, delete 0, find 0/0, race 0+0
Free swap  = 1863532kB
Total swap = 1863532kB
Free swap:       1863532kB
1310720 pages of RAM
1081344 pages of HIGHMEM
140255 reserved pages
3164 pages shared
0 pages swap cached
0 pages dirty
0 pages writeback
841 pages mapped
2584 pages slab
108 pages pagetables
Out of memory: kill process 3837 (slpd) score 897 or a child
Killed process 3837 (slpd)
bash invoked oom-killer: gfp_mask=0x84d0, order=0, oomkilladj=0
Pid: 4434, comm: bash Not tainted 2.6.24-rc5-mm1 #9
 [<c010582a>] show_trace_log_lvl+0x12/0x22
 [<c0105847>] show_trace+0xd/0xf
 [<c0105959>] dump_stack+0x57/0x5e
 [<c015a0f3>] oom_kill_process+0x37/0xdb
 [<c015a300>] out_of_memory+0xbd/0xf1
 [<c015b977>] __alloc_pages+0x23f/0x2cc
 [<c011b6ca>] pte_alloc_one+0x15/0x3e
 [<c01632fc>] __pte_alloc+0x15/0xaf
 [<c016350b>] copy_pte_range+0x43/0x293
 [<c0163877>] copy_page_range+0x11c/0x154
 [<c0122ac9>] dup_mmap+0x1ab/0x20c
 [<c0122e72>] dup_mm+0x81/0xd1
 [<c0122f2a>] copy_mm+0x68/0x98
 [<c0123bdc>] copy_process+0x47d/0x9fd
 [<c0124279>] do_fork+0x8d/0x1d2
 [<c0103aba>] sys_clone+0x1f/0x21
 [<c01049fa>] sysenter_past_esp+0x5f/0xa5
 =======================
Mem-info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
CPU    2: hi:    0, btch:   1 usd:   0
CPU    3: hi:    0, btch:   1 usd:   0
CPU    4: hi:    0, btch:   1 usd:   0
CPU    5: hi:    0, btch:   1 usd:   0
CPU    6: hi:    0, btch:   1 usd:   0
CPU    7: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:  186, btch:  31 usd:  25
CPU    1: hi:  186, btch:  31 usd: 163
CPU    2: hi:  186, btch:  31 usd:  20
CPU    3: hi:  186, btch:  31 usd: 170
CPU    4: hi:  186, btch:  31 usd:  30
CPU    5: hi:  186, btch:  31 usd: 156
CPU    6: hi:  186, btch:  31 usd:  30
CPU    7: hi:  186, btch:  31 usd: 164
HighMem per-cpu:
CPU    0: hi:  186, btch:  31 usd:  36
CPU    1: hi:  186, btch:  31 usd: 166
CPU    2: hi:  186, btch:  31 usd:   5
CPU    3: hi:  186, btch:  31 usd: 166
CPU    4: hi:  186, btch:  31 usd:   8
CPU    5: hi:  186, btch:  31 usd: 162
CPU    6: hi:  186, btch:  31 usd:  25
CPU    7: hi:  186, btch:  31 usd: 166
Active:1933 inactive:1266 dirty:0 writeback:0 unstable:0
 free:986883 slab:2560 mapped:826 pagetables:118 bounce:0
DMA free:3552kB min:64kB low:80kB high:96kB active:0kB inactive:0kB present:16016kB pages_scanned:0 all_unreclaimable? yes
lowmem_reserve[]: 0 860 4989 4989
Normal free:3964kB min:3720kB low:4648kB high:5580kB active:76kB inactive:128kB present:880880kB pages_scanned:4949 all_unreclaimable? yes
lowmem_reserve[]: 0 0 33033 33033
HighMem free:3940016kB min:512kB low:4976kB high:9440kB active:7656kB inactive:4936kB present:4228224kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 2*4kB 3*8kB 4*16kB 4*32kB 4*64kB 2*128kB 1*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 3552kB
Normal: 51*4kB 12*8kB 3*16kB 1*32kB 0*64kB 0*128kB 0*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3964kB
HighMem: 158*4kB 535*8kB 270*16kB 93*32kB 32*64kB 8*128kB 1*256kB 1*512kB 2*1024kB 1*2048kB 957*4096kB = 3940016kB
Swap cache: add 0, delete 0, find 0/0, race 0+0
Free swap  = 1863532kB
Total swap = 1863532kB
Free swap:       1863532kB
1310720 pages of RAM
1081344 pages of HIGHMEM
140255 reserved pages
3059 pages shared
0 pages swap cached
0 pages dirty
0 pages writeback
826 pages mapped
2560 pages slab
118 pages pagetables
Out of memory: kill process 3948 (xfs) score 817 or a child
Killed process 3948 (xfs)
bash invoked oom-killer: gfp_mask=0x84d0, order=0, oomkilladj=0
Pid: 4434, comm: bash Not tainted 2.6.24-rc5-mm1 #9
 [<c010582a>] show_trace_log_lvl+0x12/0x22
 [<c0105847>] show_trace+0xd/0xf
 [<c0105959>] dump_stack+0x57/0x5e
 [<c015a0f3>] oom_kill_process+0x37/0xdb
 [<c015a300>] out_of_memory+0xbd/0xf1
 [<c015b977>] __alloc_pages+0x23f/0x2cc
 [<c011b6ca>] pte_alloc_one+0x15/0x3e
 [<c01632fc>] __pte_alloc+0x15/0xaf
 [<c016350b>] copy_pte_range+0x43/0x293
 [<c0163877>] copy_page_range+0x11c/0x154
 [<c0122ac9>] dup_mmap+0x1ab/0x20c
 [<c0122e72>] dup_mm+0x81/0xd1
 [<c0122f2a>] copy_mm+0x68/0x98
 [<c0123bdc>] copy_process+0x47d/0x9fd
 [<c0124279>] do_fork+0x8d/0x1d2
 [<c0103aba>] sys_clone+0x1f/0x21
 [<c01049fa>] sysenter_past_esp+0x5f/0xa5
 =======================
Mem-info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
CPU    2: hi:    0, btch:   1 usd:   0
CPU    3: hi:    0, btch:   1 usd:   0
CPU    4: hi:    0, btch:   1 usd:   0
CPU    5: hi:    0, btch:   1 usd:   0
CPU    6: hi:    0, btch:   1 usd:   0
CPU    7: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:  186, btch:  31 usd:  17
CPU    1: hi:  186, btch:  31 usd: 179
CPU    2: hi:  186, btch:  31 usd:  27
CPU    3: hi:  186, btch:  31 usd: 157
CPU    4: hi:  186, btch:  31 usd:  30
CPU    5: hi:  186, btch:  31 usd: 180
CPU    6: hi:  186, btch:  31 usd:  13
CPU    7: hi:  186, btch:  31 usd: 165
HighMem per-cpu:
CPU    0: hi:  186, btch:  31 usd:  21
CPU    1: hi:  186, btch:  31 usd: 178
CPU    2: hi:  186, btch:  31 usd:  18
CPU    3: hi:  186, btch:  31 usd: 182
CPU    4: hi:  186, btch:  31 usd:  15
CPU    5: hi:  186, btch:  31 usd: 179
CPU    6: hi:  186, btch:  31 usd:  22
CPU    7: hi:  186, btch:  31 usd: 164
Active:1764 inactive:1234 dirty:0 writeback:0 unstable:0
 free:987022 slab:2560 mapped:769 pagetables:104 bounce:0
DMA free:3520kB min:64kB low:80kB high:96kB active:0kB inactive:0kB present:16016kB pages_scanned:0 all_unreclaimable? yes
lowmem_reserve[]: 0 860 4989 4989
Normal free:3808kB min:3720kB low:4648kB high:5580kB active:204kB inactive:0kB present:880880kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 33033 33033
HighMem free:3940760kB min:512kB low:4976kB high:9440kB active:6852kB inactive:4936kB present:4228224kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 2*4kB 3*8kB 4*16kB 5*32kB 5*64kB 1*128kB 1*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 3520kB
Normal: 56*4kB 15*8kB 6*16kB 1*32kB 0*64kB 0*128kB 0*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 4056kB
HighMem: 307*4kB 536*8kB 271*16kB 93*32kB 32*64kB 8*128kB 1*256kB 1*512kB 2*1024kB 1*2048kB 957*4096kB = 3940636kB
Swap cache: add 0, delete 0, find 0/0, race 0+0
Free swap  = 1863532kB
Total swap = 1863532kB
Free swap:       1863532kB
1310720 pages of RAM
1081344 pages of HIGHMEM
140255 reserved pages
2857 pages shared
0 pages swap cached
0 pages dirty
0 pages writeback
769 pages mapped
2560 pages slab
104 pages pagetables
Out of memory: kill process 3743 (portmap) score 418 or a child
Killed process 3743 (portmap)
bash invoked oom-killer: gfp_mask=0x84d0, order=0, oomkilladj=0
Pid: 4434, comm: bash Not tainted 2.6.24-rc5-mm1 #9
 [<c010582a>] show_trace_log_lvl+0x12/0x22
 [<c0105847>] show_trace+0xd/0xf
 [<c0105959>] dump_stack+0x57/0x5e
 [<c015a0f3>] oom_kill_process+0x37/0xdb
 [<c015a300>] out_of_memory+0xbd/0xf1
 [<c015b977>] __alloc_pages+0x23f/0x2cc
 [<c011b6ca>] pte_alloc_one+0x15/0x3e
 [<c01632fc>] __pte_alloc+0x15/0xaf
 [<c016350b>] copy_pte_range+0x43/0x293
 [<c0163877>] copy_page_range+0x11c/0x154
 [<c0122ac9>] dup_mmap+0x1ab/0x20c
 [<c0122e72>] dup_mm+0x81/0xd1
 [<c0122f2a>] copy_mm+0x68/0x98
 [<c0123bdc>] copy_process+0x47d/0x9fd
 [<c0124279>] do_fork+0x8d/0x1d2
 [<c0103aba>] sys_clone+0x1f/0x21
 [<c01049fa>] sysenter_past_esp+0x5f/0xa5
 =======================
Mem-info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
CPU    2: hi:    0, btch:   1 usd:   0
CPU    3: hi:    0, btch:   1 usd:   0
CPU    4: hi:    0, btch:   1 usd:   0
CPU    5: hi:    0, btch:   1 usd:   0
CPU    6: hi:    0, btch:   1 usd:   0
CPU    7: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:  186, btch:  31 usd:  24
CPU    1: hi:  186, btch:  31 usd: 166
CPU    2: hi:  186, btch:  31 usd:  18
CPU    3: hi:  186, btch:  31 usd: 162
CPU    4: hi:  186, btch:  31 usd:  21
CPU    5: hi:  186, btch:  31 usd: 184
CPU    6: hi:  186, btch:  31 usd:  13
CPU    7: hi:  186, btch:  31 usd: 168
HighMem per-cpu:
CPU    0: hi:  186, btch:  31 usd:  21
CPU    1: hi:  186, btch:  31 usd: 171
CPU    2: hi:  186, btch:  31 usd:  24
CPU    3: hi:  186, btch:  31 usd: 161
CPU    4: hi:  186, btch:  31 usd:  26
CPU    5: hi:  186, btch:  31 usd: 164
CPU    6: hi:  186, btch:  31 usd:  26
CPU    7: hi:  186, btch:  31 usd: 156
Active:1810 inactive:1234 dirty:0 writeback:0 unstable:0
 free:987085 slab:2523 mapped:758 pagetables:80 bounce:0
DMA free:3512kB min:64kB low:80kB high:96kB active:0kB inactive:0kB present:16016kB pages_scanned:0 all_unreclaimable? yes
lowmem_reserve[]: 0 860 4989 4989
Normal free:4048kB min:3720kB low:4648kB high:5580kB active:204kB inactive:0kB present:880880kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 33033 33033
HighMem free:3940780kB min:512kB low:4976kB high:9440kB active:7036kB inactive:4936kB present:4228224kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 2*4kB 2*8kB 4*16kB 5*32kB 5*64kB 1*128kB 1*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 3512kB
Normal: 46*4kB 22*8kB 6*16kB 1*32kB 0*64kB 0*128kB 0*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 4072kB
HighMem: 304*4kB 541*8kB 275*16kB 92*32kB 33*64kB 8*128kB 1*256kB 1*512kB 2*1024kB 1*2048kB 957*4096kB = 3940760kB
Swap cache: add 0, delete 0, find 0/0, race 0+0
Free swap  = 1863532kB
Total swap = 1863532kB
Free swap:       1863532kB
1310720 pages of RAM
1081344 pages of HIGHMEM
140255 reserved pages
2752 pages shared
0 pages swap cached
0 pages dirty
0 pages writeback
758 pages mapped
2523 pages slab
80 pages pagetables
Out of memory: kill process 4432 (sshd) score 145 or a child
Killed process 4434 (bash)

_

-- 
regards,
Dhaval

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
