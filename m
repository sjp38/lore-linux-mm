Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4C4696B01EE
	for <linux-mm@kvack.org>; Tue, 18 May 2010 03:44:27 -0400 (EDT)
Subject: Re: [RFC, 6/7] NUMA hotplug emulator
From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
In-Reply-To: <20100518054121.GA25298@shaohui>
References: <20100513120016.GG2169@shaohui> <20100513165603.GC25212@suse.de>
	 <1273773737.13285.7771.camel@nimitz> <20100513181539.GA26597@suse.de>
	 <1273776578.13285.7820.camel@nimitz>  <20100518054121.GA25298@shaohui>
Content-Type: text/plain
Date: Tue, 18 May 2010 00:44:20 -0700
Message-Id: <1274168660.7348.132.camel@haakon2.linux-iscsi.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@intel.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Greg KH <gregkh@suse.de>, akpm@linux-foundation.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andi Kleen <ak@linux.intel.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Tue, 2010-05-18 at 13:41 +0800, Shaohui Zheng wrote:
> On Thu, May 13, 2010 at 11:49:38AM -0700, Dave Hansen wrote:
> > On Thu, 2010-05-13 at 11:15 -0700, Greg KH wrote:
> > > >       echo "physical_address=0x40000000 numa_node=3" > memory/probe
> > > > 
> > > > I'd *GREATLY* prefer that over this new syntax.  The existing mechanism
> > > > is obtuse enough, and the ',3' makes it more so.
> > > > 
> > > > We should have the code around to parse arguments like that, too, since
> > > > we use it for the boot command-line.
> > > 
> > > If you are going to be doing something like this, please use configfs,
> > > that is what it is designed for, not sysfs.
> > 
> > That's probably a really good point, especially since configfs didn't
> > even exist when we made this 'probe' file thingy.  It never was a great
> > fit for sysfs anyway.
> > 
> > -- Dave
> 
> the configfs was introduced in 2005, you can refer to http://lwn.net/Articles/148973/.
> 
> I enabled the configfs, and I see that the configfs is not so popular as we expected,
> I mount configfs to /sys/kernel/config, I get an empty directory. It means that nobody is 
> using this file system, it is an interesting thing, is it means that configfs is deprecated?

Ohhhhhh, no.  ConfigFS is the evolution of the original SysFS design to
to allow for kernel data structure configuration to be driven by
userspace syscalls in a number of very significant ways.

> If so, it might not be nessarry to develop a configfs interface for hotplug.
> 

The usage of ConfigFS to provide a kernel <-> user configuration layout
really best depends on the protocol in question for particular data
structure state machine and parameter/attribute set.  Using ConfigFS
involves Linux/VFS representing dependencies between data structures
both on a inter and intra kernel module context containing struct
config_groups driven by userspace mkdir(2) and link(2) syscall ops.

> Dave & Greg,
> 	Can you provide an exmample to use configfs as interface in Linux kernel, I want to get
> a live demo, thanks.

The TCM 4.0 design brings fabric module independent >= SPC-3 compatible
SCSI WWN target ports and a generic set of struct config_groups and CPP
macros to individual storage backstores using TCM target mode fabric
plugins across Linux/SCSI, Linux/BLOCK, and Linux/VFS subsystems.  So
far, this has been implemented for SAS, FC, and iSCSI fabric protocols:

http://git.kernel.org/?p=linux/kernel/git/nab/lio-core-2.6.git;a=blob;f=drivers/target/target_core_configfs.c;hb=refs/heads/lio-4.0
http://git.kernel.org/?p=linux/kernel/git/nab/lio-core-2.6.git;a=blob;f=include/target/configfs_macros.h;hb=refs/heads/lio-4.0
http://git.kernel.org/?p=linux/kernel/git/nab/lio-core-2.6.git;a=blob;f=drivers/target/target_core_fabric_configfs.c;hb=refs/heads/lio-4.0
http://git.kernel.org/?p=linux/kernel/git/nab/lio-core-2.6.git;a=blob;f=include/target/target_core_fabric_configfs.h;hb=refs/heads/lio-4.0

http://git.kernel.org/?p=linux/kernel/git/nab/lio-core-2.6.git;a=blob;f=drivers/target/tcm_fc/tfc_conf.c;hb=refs/heads/lio-4.0
http://git.kernel.org/?p=linux/kernel/git/nab/lio-core-2.6.git;a=blob;f=drivers/target/tcm_loop/tcm_loop_configfs.c;hb=refs/heads/lio-4.0
http://git.kernel.org/?p=linux/kernel/git/nab/lio-core-2.6.git;a=blob;f=drivers/target/lio-target/iscsi_target_configfs.c;hb=refs/heads/lio-4.0

Best,

--nab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
