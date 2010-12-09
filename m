Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CDA856B0089
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 20:34:56 -0500 (EST)
Date: Thu, 9 Dec 2010 08:09:45 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: Re: [1/7,v8] NUMA Hotplug Emulator: documentation
Message-ID: <20101209000945.GA5798@shaohui>
References: <20101207010033.280301752@intel.com>
 <20101207010139.681125359@intel.com>
 <20101207182420.GA2038@mgebm.net>
 <20101207232000.GA5353@shaohui>
 <20101208174633.GA2086@mgebm.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101208174633.GA2086@mgebm.net>
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <emunson@mgebm.net>
Cc: Shaohui Zheng <shaohui.zheng@linux.intel.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, rientjes@google.com, dave@linux.vnet.ibm.com, gregkh@suse.de, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 08, 2010 at 10:46:33AM -0700, Eric B Munson wrote:
> Shaohui,
> 
> I have had some success.  I had run into confusion on the memory hotplug with 
> which files to be using to online memory.  The latest patch sorted it out for me
> and I can now online disabled memory in new nodes.  I still cannot online an offlined
> cpu.  Of the 12 available thread, I have 8 activated on boot with the kernel command line:
> 
> mem=8G numa=possible=12 maxcpus=8 cpu_hpe=on
> 
> I can offline a CPU just fine according to the kernel:
> root@bert:/sys/devices/system/cpu# echo 7 > release
> (dmesg)
> [  911.494852] offline cpu 7.
> [  911.694323] CPU 7 is now offline
> 
> But when I try and re-add it I get an error:
> root@bert:/sys/devices/system/cpu# echo 0 > probe
> (dmesg)
> Dec  8 10:41:55 bert kernel: [ 1190.095051] ------------[ cut here ]------------
> Dec  8 10:41:55 bert kernel: [ 1190.095056] WARNING: at fs/sysfs/dir.c:451 sysfs_add_one+0xce/0x180()
> Dec  8 10:41:55 bert kernel: [ 1190.095057] Hardware name: System Product Name
> Dec  8 10:41:55 bert kernel: [ 1190.095058] sysfs: cannot create duplicate filename '/devices/system/cpu/cpu7'
> Dec  8 10:41:55 bert kernel: [ 1190.095060] Modules linked in: nfs binfmt_misc lockd fscache nfs_acl auth_rpcgss sunrpc snd_hda_codec_hdmi snd_hda_codec_realtek radeon snd_hda_intel snd_hda_codec snd_cmipci gameport snd_pcm ttm snd_opl3_lib drm_kms_helper snd_hwdep snd_mpu401_uart drm uvcvideo snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq xhci_hcd snd_timer videodev snd_seq_device snd psmouse i7core_edac i2c_algo_bit edac_core joydev v4l1_compat shpchp snd_page_alloc v4l2_compat_ioctl32 soundcore hwmon_vid asus_atk0110 max6650 serio_raw hid_microsoft usbhid hid firewire_ohci firewire_core crc_itu_t ahci sky2 libahci
> Dec  8 10:41:55 bert kernel: [ 1190.095088] Pid: 2369, comm: bash Tainted: G        W   2.6.37-rc5-numa-test+ #3
> Dec  8 10:41:55 bert kernel: [ 1190.095089] Call Trace:
> Dec  8 10:41:55 bert kernel: [ 1190.095094]  [<ffffffff8105eb1f>] warn_slowpath_common+0x7f/0xc0
> Dec  8 10:41:55 bert kernel: [ 1190.095096]  [<ffffffff8105ec16>] warn_slowpath_fmt+0x46/0x50
> Dec  8 10:41:55 bert kernel: [ 1190.095098]  [<ffffffff811cf77e>] sysfs_add_one+0xce/0x180
> Dec  8 10:41:55 bert kernel: [ 1190.095100]  [<ffffffff811cf8b1>] create_dir+0x81/0xd0
> Dec  8 10:41:55 bert kernel: [ 1190.095102]  [<ffffffff811cf97d>] sysfs_create_dir+0x7d/0xd0
> Dec  8 10:41:55 bert kernel: [ 1190.095106]  [<ffffffff815a2b3d>] ? sub_preempt_count+0x9d/0xd0
> Dec  8 10:41:55 bert kernel: [ 1190.095109]  [<ffffffff812c9ffd>] kobject_add_internal+0xbd/0x200
> Dec  8 10:41:55 bert kernel: [ 1190.095111]  [<ffffffff812ca258>] kobject_add_varg+0x38/0x60
> Dec  8 10:41:55 bert kernel: [ 1190.095113]  [<ffffffff812ca2d3>] kobject_init_and_add+0x53/0x70
> Dec  8 10:41:55 bert kernel: [ 1190.095117]  [<ffffffff8139475f>] sysdev_register+0x6f/0xf0
> Dec  8 10:41:55 bert kernel: [ 1190.095121]  [<ffffffff81598f38>] register_cpu_node+0x32/0x88
> Dec  8 10:41:55 bert kernel: [ 1190.095123]  [<ffffffff8158207e>] arch_register_cpu_node+0x3e/0x40
> Dec  8 10:41:55 bert kernel: [ 1190.095127]  [<ffffffff8101220e>] arch_cpu_probe+0x10e/0x1f0
> Dec  8 10:41:55 bert kernel: [ 1190.095129]  [<ffffffff813989d4>] cpu_probe_store+0x14/0x20
> Dec  8 10:41:55 bert kernel: [ 1190.095131]  [<ffffffff81393ef0>] sysdev_class_store+0x20/0x30
> Dec  8 10:41:55 bert kernel: [ 1190.095133]  [<ffffffff811cd925>] sysfs_write_file+0xe5/0x170
> Dec  8 10:41:55 bert kernel: [ 1190.095137]  [<ffffffff811624c8>] vfs_write+0xc8/0x190
> Dec  8 10:41:55 bert kernel: [ 1190.095139]  [<ffffffff81162e61>] sys_write+0x51/0x90
> Dec  8 10:41:55 bert kernel: [ 1190.095142]  [<ffffffff8100c142>] system_call_fastpath+0x16/0x1b
> Dec  8 10:41:55 bert kernel: [ 1190.095144] ---[ end trace f615c2a524d318ea ]---
> Dec  8 10:41:55 bert kernel: [ 1190.095149] Pid: 2369, comm: bash Tainted: G        W   2.6.37-rc5-numa-test+ #3
> Dec  8 10:41:55 bert kernel: [ 1190.095150] Call Trace:
> Dec  8 10:41:55 bert kernel: [ 1190.095152]  [<ffffffff812ca09b>] kobject_add_internal+0x15b/0x200
> Dec  8 10:41:55 bert kernel: [ 1190.095154]  [<ffffffff812ca258>] kobject_add_varg+0x38/0x60
> Dec  8 10:41:55 bert kernel: [ 1190.095156]  [<ffffffff812ca2d3>] kobject_init_and_add+0x53/0x70
> Dec  8 10:41:55 bert kernel: [ 1190.095158]  [<ffffffff8139475f>] sysdev_register+0x6f/0xf0
> Dec  8 10:41:55 bert kernel: [ 1190.095160]  [<ffffffff81598f38>] register_cpu_node+0x32/0x88
> Dec  8 10:41:55 bert kernel: [ 1190.095162]  [<ffffffff8158207e>] arch_register_cpu_node+0x3e/0x40
> Dec  8 10:41:55 bert kernel: [ 1190.095164]  [<ffffffff8101220e>] arch_cpu_probe+0x10e/0x1f0
> Dec  8 10:41:55 bert kernel: [ 1190.095166]  [<ffffffff813989d4>] cpu_probe_store+0x14/0x20
> Dec  8 10:41:55 bert kernel: [ 1190.095168]  [<ffffffff81393ef0>] sysdev_class_store+0x20/0x30
> Dec  8 10:41:55 bert kernel: [ 1190.095170]  [<ffffffff811cd925>] sysfs_write_file+0xe5/0x170
> Dec  8 10:41:55 bert kernel: [ 1190.095172]  [<ffffffff811624c8>] vfs_write+0xc8/0x190
> Dec  8 10:41:55 bert kernel: [ 1190.095174]  [<ffffffff81162e61>] sys_write+0x51/0x90
> Dec  8 10:41:55 bert kernel: [ 1190.095176]  [<ffffffff8100c142>] system_call_fastpath+0x16/0x1b
> 
> Am I doing something wrong?
> 
> Thanks,
> Eric

Eric,
	I saw that you already get this issue solved in another email, that is good. I double check your step, and I did not find any problems.

the logic to do CPU release(arch_cpu_release),
1) offline the CPU if the CPU is online
2) unregister CPU

so even if the CPU is online, you can still release the CPU directly. I should check the return value after call cpu_down.

How about add the following checking?

--- arch/x86/kernel/topology.c-orig	2010-12-09 08:03:19.883331001 +0800
+++ arch/x86/kernel/topology.c	2010-12-09 08:01:35.993331000 +0800
@@ -158,7 +158,10 @@
 
 	if (cpu_online(cpu)) {
 		printk(KERN_DEBUG "offline cpu %d.\n", cpu);
-		cpu_down(cpu);
+		if (!cpu_down(cpu)){
+			printk(KERN_ERR "fail to offline cpu %d, give up.\n", cpu);
+			return -EPERM;
+		}
 	}
 
 	arch_unregister_cpu(cpu);

-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
