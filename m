Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7B14160080D
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 08:54:47 -0400 (EDT)
Date: Tue, 27 Jul 2010 13:54:28 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bug 16415] New: Show_Memory/Shift-ScrollLock triggers "unable
	to handle kernel paging request at 00021c6e"
Message-ID: <20100727125428.GY5300@csn.ul.ie>
References: <bug-16415-27@https.bugzilla.kernel.org/> <20100722153443.e266b2d6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100722153443.e266b2d6.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, tnimble@xs4all.nl, "Rafael J. Wysocki" <rjw@sisk.pl>, Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yinghai@kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 22, 2010 at 03:34:43PM -0700, Andrew Morton wrote:
> > This problem was first noticed after updating to kernel 2.6.34 (from 2.6.12.6).
> > Both kernels have been tested on multiple sets of hardware. The system is run
> > from compact flash disk and tmpfs for /tmp and /var/...
> > 
> 
> It's i386, highmem.
> 

tmpfs is a common element between both bugs but not sure if that is
relevant yet.

> > BUG: unable to handle kernel paging request at 00021c6e
> > IP: [<c01d124b>] show_mem+0xbf/0x15c
> > *pde = 00000000 
> > Oops: 0000 [#1] SMP 
> > last sysfs file: /sys/devices/platform/coretemp.0/temp1_input
> > Modules linked in: ipv6 nf_nat_irc nf_nat_ftp ipt_MASQUERADE ipt_REJECT
> > ipt_REDIRECT xt_state xt_limit ipt_LOG iptable_nat nf_nat iptable_mangle
> > iptable_filter nf_conntrack_irc nf_conntrack_ftp nf_conntrack_ipv4 nf_conntrack
> > nf_defrag_ipv4 ip_tables x_tables coretemp usbhid i2c_i801 ehci_hcd uhci_hcd
> > fan iTCO_wdt iTCO_vendor_support e1000e usbcore thermal button processor evdev
> > nls_iso8859_1
> > 
> > Pid: 0, comm: swapper Not tainted 2.6.34.1 #1 945GM/E-ITE8712/945GM/E-ITE8712
> > EIP: 0060:[<c01d124b>] EFLAGS: 00010002 CPU: 0
> > EIP is at show_mem+0xbf/0x15c
> > EAX: 00021c6a EBX: 00018020 ECX: 00000001 EDX: c1301400
> > ESI: 00018010 EDI: c03fbf80 EBP: c03d5ca0 ESP: c03d5c80
> >  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> > Process swapper (pid: 0, ti=c03d4000 task=c03e2ea0 task.ti=c03d4000)
> > Stack:
> >  00018010 0000147a ed0ff381 00000000 00000000 f700b000 00000046 c03ef203
> > <0> c03d5ca8 c022a4dd c03d5cb4 c0229a0c 00000002 c03d5ce8 c022ae51 f694cc00
> > <0> 020030b4 f700b000 f700b000 00000001 00000001 00000000 0000f203 f64a7d40
> > Call Trace:
> >  [<c022a4dd>] ? fn_show_mem+0x8/0xa
> >  [<c0229a0c>] ? k_spec+0x33/0x36
> >  [<c022ae51>] ? kbd_event+0x46f/0x4da
> >  [<c027891f>] ? input_pass_event+0x63/0x9e
> >  [<c012df0e>] ? mod_timer+0xe7/0xf2
> 
> Here it is:
> 
> : void show_mem(void)
> : {
> : 	pg_data_t *pgdat;
> : 	unsigned long total = 0, reserved = 0, shared = 0,
> : 		nonshared = 0, highmem = 0;
> : 
> : 	printk("Mem-Info:\n");
> : 	show_free_areas();
> : 
> : 	for_each_online_pgdat(pgdat) {
> : 		unsigned long i, flags;
> : 
> : 		pgdat_resize_lock(pgdat, &flags);
> : 		for (i = 0; i < pgdat->node_spanned_pages; i++) {
> : 			struct page *page;
> : 			unsigned long pfn = pgdat->node_start_pfn + i;
> : 
> : 			if (unlikely(!(i % MAX_ORDER_NR_PAGES)))
> : 				touch_nmi_watchdog();
> : 
> : 			if (!pfn_valid(pfn))
> : 				continue;
> : 
> : 			page = pfn_to_page(pfn);
> : 
> : 			if (PageHighMem(page))
> : 				highmem++;
> : 
> : 			if (PageReserved(page))
> : 				reserved++;
> : 			else if (page_count(page) == 1)
> : 				nonshared++;
> : 			else if (page_count(page) > 1)
> : 				shared += page_count(page) - 1;
> : 
> : 			total++;
> : 		}
> : 		pgdat_resize_unlock(pgdat, &flags);
> : 	}
> 
> afaict what happened was that the PageReserved() test survived somehow.
>  Then the page_count() test internally decided that it was a PageTail()
> page, then got itself a new page* and then tried to read that pointer's
> ->count field, and oopsed.
> 
> So probably that pfn_to_page() expression returned us some garbage
> which doesn't refer to a pageframe at all.
> 
> I attempted to cc people who work on these things.
> 

I was unable to reproduce this on qemu at least (my test machines are
all occupied). Test case was to force use of highmem (vmalloc=) and
mount tmpfs with a swapfile in place. A heavy mix off dd writing to
on-disk and tmpfs-files over the course of 15 minutes triggered nothing
out of the ordinary. So, whatever is going on here, it's not immediately
obvious and so I'm afraid I have to make wild stabs in the dark.
Relevant people cc'd.

Theory 1
--------
Can we eliminate bad hardware as an option? What modules are loaded in this
machine (lsmod and lspci -v)? Can memtest be run on this machine for a number
of hours to eliminate bad memory as a possibility? I recognise that 2.6.12.6
was fine on this machine but it's possible that 2.6.34.1 is stressing the
machine more for some reason.

Theory 2
--------
To catch early mistakes in the memory model, can the machine be booted with
mminit_loglevel=4 and CONFIG_DEBUG_VM set in .config? I am not optimistic
this is where the problem is though. If we were making mistakes in early
setup, I'd expect a large volume of bug reports on it.

Theory 3
--------
I see this message early in boot
Phoenix BIOS detected: BIOS may corrupt low RAM, working around it.

Is there any possibility that the wrong range of memory is being reserved
and in fact the BIOS is screwing with the region of memory memmap is stored in?

Theory 4
--------

with the early boot changes, is there any possibility that bootmem used the
low 64K? To test the theory, can the kernel be rebuilt with CONFIG_NO_BOOTMEM
*not* set to use the older bootmem logic?

Theory 5
--------
What are the consequences of the following message?

pcieport 0000:00:1c.0: Requesting control of PCIe PME from ACPI BIOS
pcieport 0000:00:1c.0: Failed to receive control of PCIe PME service: no _OSC support
pcie_pme: probe of 0000:00:1c.0:pcie01 failed with error -13
pcieport 0000:00:1c.1: Requesting control of PCIe PME from ACPI BIOS
pcieport 0000:00:1c.1: Failed to receive control of PCIe PME service: no _OSC support
pcie_pme: probe of 0000:00:1c.1:pcie01 failed with error -13
pcieport 0000:00:1c.2: Requesting control of PCIe PME from ACPI BIOS
pcieport 0000:00:1c.2: Failed to receive control of PCIe PME service: no _OSC support
pcie_pme: probe of 0000:00:1c.2:pcie01 failed with error -13
pcieport 0000:00:1c.3: Requesting control of PCIe PME from ACPI BIOS
pcieport 0000:00:1c.3: Failed to receive control of PCIe PME service: no _OSC support
pcie_pme: probe of 0000:00:1c.3:pcie01 failed with error -13

Is there any possibility when this fails that the device is writing to
some location in memory thinking the OS has taken proper control of it
and reserved those physicaly address? (reaching I know, but have to
eliminate it as a possibility)

Sorry to spread the possibilities all over the place but without a local
reproduction case, there isn't much to go on yet.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
