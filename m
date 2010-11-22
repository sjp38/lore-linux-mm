Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0A16B6B0071
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 20:22:44 -0500 (EST)
Date: Mon, 22 Nov 2010 08:01:04 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: Re: [5/8,v3] NUMA Hotplug Emulator: support cpu probe/release in
 x86
Message-ID: <20101122000104.GA7986@shaohui>
References: <20101117020759.016741414@intel.com>
 <20101117021000.776651300@intel.com>
 <20101121144511.GJ9099@hack>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20101121144511.GJ9099@hack>
Sender: owner-linux-mm@kvack.org
To: =?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Ingo Molnar <mingo@elte.hu>, Len Brown <len.brown@intel.com>, Yinghai Lu <Yinghai.Lu@Sun.COM>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Sun, Nov 21, 2010 at 10:45:11PM +0800, Americo Wang wrote:
> On Wed, Nov 17, 2010 at 10:08:04AM +0800, shaohui.zheng@intel.com wrote:
> >From: Shaohui Zheng <shaohui.zheng@intel.com>
> >
> >Add cpu interface probe/release under sysfs for x86. User can use this
> >interface to emulate the cpu hot-add process, it is for cpu hotplug 
> >test purpose. Add a kernel option CONFIG_ARCH_CPU_PROBE_RELEASE for this
> >feature.
> >
> >This interface provides a mechanism to emulate cpu hotplug with software
> > methods, it becomes possible to do cpu hotplug automation and stress
> >testing.
> >
> 
> Huh? We already have CPU online/offline...
> 
> Can you describe more about the difference?
> 
> Thanks.

Again, we already try to discribe the difference between logcial cpu
online/offline and physical cpu online/offline many times.

The following is the my reply on other threads.
-------------------------------------------------------------------------------------------
> 
> I don't get it. CPU hotplug can already be tested using echo 0/1 >
> online, and that works on 386. How is this different?
> 
> It seems to add some numa magic. Why is it important?

Pavel,
	it is not an easy thing to understand the full story since you may not work on this project
so you have such question. Let me do a simpe introductions about the background.

	We need to understand 2 differnets concepts if you wnat to know the reason why we develop 
the hotplug emulaor.

 - CPU logcial online/offline
	it is the existed feature which you mentioned, we can online/offline CPUs throu sysfs
interface /sys/device/system/cpu/cpuX/online (X is an integer, it stands for the CPU number)

	echo 0/1 > /sys/device/cpu/cpuX/online
	
	This is is logical CPU online/offline, when we do such operation, the CPU is already pluged
into the motherboard, and the OS initialized the CPU. the data structure and CPU entries on sysfs
are created, the CPU present mask and possible mask are setted, it does not refer to any physical
hardware. the CPU status becomes online from offline, and ready to schedule to run process by
scheduler.
	
	CPU online/offline is control by the kernel option CONFIG_HOTPLUG_CPU.

 - CPU hot-add/hot-remove

	This is physical CPU hot-add/hot-remove into motherboard, without shutdown the machine, after
the hot-add operation, the new CPU will be powered on, and the OS recognize the new CPUs throu SCI
interrupts, then OS intializes the new CPUs, create the related CPU structures, create sysfs entries
 for the new CPUs. Once all done, the CPU is ready to logcial online.

The process to hot-add CPU:
	 1) Physical CPU hot-add to motherboard when after the machine is powered on
	 2) the BIOS send SCI interrupts to notice the OS 
	 3) Linux hotplug handler parse the data from the acpi_handle data
	 4) hotplug handler initialize the CPU structure according the cpu ACPI data

Current situation:
	1) Provides developers an envronment
	 Only very few hardware can support CPU hot-add/hot-remove, we need create an working environment
	 for developers to write and debug hotplug code even through they do not has such hardward on hand.
	 It is what NUMA hotplug emulator does exactly. Physcial hotplug emuator should be a better name.

  	 We have 2 solutions to solve this problem, and this one is selected finally; if you want to know
	 more about the solutions, we can continue to on this thread.

	2) Offers an automation test inferface for Linux CPU hot-add/hot-remove code
	Linux hot-add/hot-remove code has obvious bugs, but we do not see any automation test suite for it,
	even in LTP project(LTP has hotplug suite for logical CPU online/offline).

	It is a know difficult work to test physcial hot-add/hot-remove code in automation way, but the hotplug
	emualtor does a good job for it. We reproduce all the major hotlug bugs against the internal emulator
	v2 and v3. 
	
We are sharing it to the community, wish more wisdoms and talents are included in it. We want to show an 
exmaple of software emualtion, and hopes more guys benifit from it, this is the purpose for this group
patches.
	
PowerPC supporting
	For ppc, it was added about half year ago by Nathan Fontenot, but x86 does not has such feature.
Thanks for lethal to mention it, we already did some researching about it,  I will reply it in another 
thread.

	commit 12633e803a2a556f6469e0933d08233d0844a2d9
	Author: Nathan Fontenot <nfont@austin.ibm.com>
	Date:   Wed Nov 25 17:23:25 2009 +0000

	commit 1a8061c46c46c960f715c597b9d279ea2ba42bd9
	Author: Nathan Fontenot <nfont@austin.ibm.com>
	Date:   Tue Nov 24 21:13:32 2009 +0000


We inherit the name style from ppc, CPU hot-add/hot-remove is called CPU probe/release in kernel, it was
control by kernel option CONFIG_ARCH_CPU_PROBE_RELEASE.
-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
