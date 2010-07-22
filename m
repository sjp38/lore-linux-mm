Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E46296B02A3
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 18:36:01 -0400 (EDT)
Date: Thu, 22 Jul 2010 15:34:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 16415] New: Show_Memory/Shift-ScrollLock triggers
 "unable to handle kernel paging request at 00021c6e"
Message-Id: <20100722153443.e266b2d6.akpm@linux-foundation.org>
In-Reply-To: <bug-16415-27@https.bugzilla.kernel.org/>
References: <bug-16415-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: bugzilla-daemon@bugzilla.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, tnimble@xs4all.nl
List-ID: <linux-mm.kvack.org>



(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

Thanks for the report.

On Mon, 19 Jul 2010 11:18:46 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=16415
> 
>            Summary: Show_Memory/Shift-ScrollLock triggers "unable to
>                     handle kernel paging request at 00021c6e"
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 2.6.34.1
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: akpm@linux-foundation.org
>         ReportedBy: tnimble@xs4all.nl
>         Regression: No
> 
> 
> Created an attachment (id=27147)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=27147)
> Kernel startup output
> 
> When doing a show_memory the following trace is outputted and the box freezes.
> A reboot is then initiated by the wachtdog timer after about a minute.
> 
> The show_registers (altr-scrollock) functions just fine.
> 
> This problem might be related to other memory related issues. This as when
> cached memory usage increases of when a large file is allocated on a tmpfs the
> system also freezes after pagefaults / panics
> 
> This problem was first noticed after updating to kernel 2.6.34 (from 2.6.12.6).
> Both kernels have been tested on multiple sets of hardware. The system is run
> from compact flash disk and tmpfs for /tmp and /var/...
> 

It's i386, highmem.

> 
> BUG: unable to handle kernel paging request at 00021c6e
> IP: [<c01d124b>] show_mem+0xbf/0x15c
> *pde = 00000000 
> Oops: 0000 [#1] SMP 
> last sysfs file: /sys/devices/platform/coretemp.0/temp1_input
> Modules linked in: ipv6 nf_nat_irc nf_nat_ftp ipt_MASQUERADE ipt_REJECT
> ipt_REDIRECT xt_state xt_limit ipt_LOG iptable_nat nf_nat iptable_mangle
> iptable_filter nf_conntrack_irc nf_conntrack_ftp nf_conntrack_ipv4 nf_conntrack
> nf_defrag_ipv4 ip_tables x_tables coretemp usbhid i2c_i801 ehci_hcd uhci_hcd
> fan iTCO_wdt iTCO_vendor_support e1000e usbcore thermal button processor evdev
> nls_iso8859_1
> 
> Pid: 0, comm: swapper Not tainted 2.6.34.1 #1 945GM/E-ITE8712/945GM/E-ITE8712
> EIP: 0060:[<c01d124b>] EFLAGS: 00010002 CPU: 0
> EIP is at show_mem+0xbf/0x15c
> EAX: 00021c6a EBX: 00018020 ECX: 00000001 EDX: c1301400
> ESI: 00018010 EDI: c03fbf80 EBP: c03d5ca0 ESP: c03d5c80
>  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> Process swapper (pid: 0, ti=c03d4000 task=c03e2ea0 task.ti=c03d4000)
> Stack:
>  00018010 0000147a ed0ff381 00000000 00000000 f700b000 00000046 c03ef203
> <0> c03d5ca8 c022a4dd c03d5cb4 c0229a0c 00000002 c03d5ce8 c022ae51 f694cc00
> <0> 020030b4 f700b000 f700b000 00000001 00000001 00000000 0000f203 f64a7d40
> Call Trace:
>  [<c022a4dd>] ? fn_show_mem+0x8/0xa
>  [<c0229a0c>] ? k_spec+0x33/0x36
>  [<c022ae51>] ? kbd_event+0x46f/0x4da
>  [<c027891f>] ? input_pass_event+0x63/0x9e
>  [<c012df0e>] ? mod_timer+0xe7/0xf2

Here it is:

: void show_mem(void)
: {
: 	pg_data_t *pgdat;
: 	unsigned long total = 0, reserved = 0, shared = 0,
: 		nonshared = 0, highmem = 0;
: 
: 	printk("Mem-Info:\n");
: 	show_free_areas();
: 
: 	for_each_online_pgdat(pgdat) {
: 		unsigned long i, flags;
: 
: 		pgdat_resize_lock(pgdat, &flags);
: 		for (i = 0; i < pgdat->node_spanned_pages; i++) {
: 			struct page *page;
: 			unsigned long pfn = pgdat->node_start_pfn + i;
: 
: 			if (unlikely(!(i % MAX_ORDER_NR_PAGES)))
: 				touch_nmi_watchdog();
: 
: 			if (!pfn_valid(pfn))
: 				continue;
: 
: 			page = pfn_to_page(pfn);
: 
: 			if (PageHighMem(page))
: 				highmem++;
: 
: 			if (PageReserved(page))
: 				reserved++;
: 			else if (page_count(page) == 1)
: 				nonshared++;
: 			else if (page_count(page) > 1)
: 				shared += page_count(page) - 1;
: 
: 			total++;
: 		}
: 		pgdat_resize_unlock(pgdat, &flags);
: 	}

afaict what happened was that the PageReserved() test survived somehow.
 Then the page_count() test internally decided that it was a PageTail()
page, then got itself a new page* and then tried to read that pointer's
->count field, and oopsed.

So probably that pfn_to_page() expression returned us some garbage
which doesn't refer to a pageframe at all.

I attempted to cc people who work on these things.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
