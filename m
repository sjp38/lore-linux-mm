From: "Petr Vandrovec" <VANDROVE@vc.cvut.cz>
Date: Wed, 9 Apr 2003 14:24:00 +0200
MIME-Version: 1.0
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7BIT
Subject: Re: 2.5.67-mm1 cause framebuffer crash at bootup
Message-ID: <11CB582A88@vcnet.vc.cvut.cz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Helge Hafting <helgehaf@aitel.hist.no>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jsimmons@infradead.org, akpm@digeo.com
List-ID: <linux-mm.kvack.org>

On  9 Apr 03 at 11:42, Helge Hafting wrote:
> 
> 2.5.67-mm1 works if I drop framebuffer support completely.

Now when you sent full backtrace - it looks to me like that fbdev
drivers are initialized before pci subsystem in -mm1. Unfortunately,
as proven by i2c, kobjects infrastructure does not like if you reference
non-existing bus type before it is registered. 

Can you try reverting _initcall changes? Although I see no reason
why it should matter, it is clear that pci subsystem is a bit unhappy.
Maybe it is caused by driver or device which is probed before fbdev?
                                                    Petr Vandrovec
                                                    vandrove@vc.cvut.cz

P.S.: And what about change in drivers/pci/probe.c, which does

-  if (base && base <= limit) {
+  if (base <= limit) {


> Here is the printed backtrace for the radeon case, the matrox case was 
> similiar:
> 
> <a few lines scrolled off screen>
> pcibios_enable_device
> pci_enable_device_bars
> pci_enable_device
> radeonfb_pci_register
> sysfs_new_inode
> pci_device_probe
> bus_match
> device_attach
> bus_add_device
> kobject_add
> device_add
> pci_bus_add_devices
> pci_bus_add_devices
> pci_scan_bus_parented
> pcibios_scan_root
> pci_legacy_init
> do_initcalls
> init_workqueues
> init+0x36
> init+0x00
> kernel_thread_helper
> code: Bad EIP value <0>Kernel panic:attempt to kill init!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
