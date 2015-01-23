Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id 4915D6B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 17:05:19 -0500 (EST)
Received: by mail-qa0-f52.google.com with SMTP id x12so7829762qac.11
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 14:05:19 -0800 (PST)
Received: from bear.ext.ti.com (bear.ext.ti.com. [192.94.94.41])
        by mx.google.com with ESMTPS id e9si3642642qgf.109.2015.01.23.14.05.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 23 Jan 2015 14:05:18 -0800 (PST)
Date: Fri, 23 Jan 2015 16:05:05 -0600
From: Nishanth Menon <nm@TI.COM>
Subject: Re: [next-20150119]regression (mm)?
Message-ID: <20150123220505.GA17421@kahuna>
References: <54BD33DC.40200@ti.com>
 <20150119174317.GK20386@saruman>
 <20150120001643.7D15AA8@black.fi.intel.com>
 <20150120114555.GA11502@n2100.arm.linux.org.uk>
 <20150120140546.DDCB8D4@black.fi.intel.com>
 <20150123172736.GA15392@kahuna>
 <CANMBJr7w2jZBwRDEsVNvL3XrDZ2ttwFz7qBf4zySAMMmcgAxiw@mail.gmail.com>
 <20150123183706.GA15791@kahuna>
 <20150123202229.GA9038@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150123202229.GA9038@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Tyler Baker <tyler.baker@linaro.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Felipe Balbi <balbi@TI.COM>, linux-mm@kvack.org, linux-next <linux-next@vger.kernel.org>, linux-omap <linux-omap@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On 22:22-20150123, Kirill A. Shutemov wrote:
> On Fri, Jan 23, 2015 at 12:37:06PM -0600, Nishanth Menon wrote:
> > On 09:39-20150123, Tyler Baker wrote:
> > > Hi,
> > > 
> > > On 23 January 2015 at 09:27, Nishanth Menon <nm@ti.com> wrote:
> > > > On 16:05-20150120, Kirill A. Shutemov wrote:
> > > > [..]
> > > >> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > >> Reported-by: Nishanth Menon <nm@ti.com>
> > > > Just to close on this thread:
> > > > https://github.com/nmenon/kernel-test-logs/tree/next-20150123 looks good
> > > > and back to old status. Thank you folks for all the help.
> > > 
> > > I just reviewed the boot logs for next-20150123 and there still seems
> > > to be a related issue. I've been boot testing
> > > multi_v7_defconfig+CONFIG_ARM_LPAE=y kernel configurations which still
> > > seem broken.
> > > 
> > > For example here are two boots with exynos5250-arndale, one with
> > > multi_v7_defconfig+CONFIG_ARM_LPAE=y [1] and the other with
> > > multi_v7_defconfig[2]. You can see the kernel configurations with
> > > CONFIG_ARM_LPAE=y show the splat:
> > > 
> > > [   14.605950] ------------[ cut here ]------------
> > > [   14.609163] WARNING: CPU: 1 PID: 63 at ../mm/mmap.c:2858
> > > exit_mmap+0x1b8/0x224()
> > > [   14.616548] Modules linked in:
> > > [   14.619553] CPU: 1 PID: 63 Comm: init Not tainted 3.19.0-rc5-next-20150123 #1
> > > [   14.626713] Hardware name: SAMSUNG EXYNOS (Flattened Device Tree)
> > > [   14.632830] [] (unwind_backtrace) from [] (show_stack+0x10/0x14)
> > > [   14.640473] [] (show_stack) from [] (dump_stack+0x78/0x94)
> > > [   14.647678] [] (dump_stack) from [] (warn_slowpath_common+0x74/0xb0)
> > > [   14.655744] [] (warn_slowpath_common) from [] (warn_slowpath_null+0x1c/0x24)
> > > [   14.664510] [] (warn_slowpath_null) from [] (exit_mmap+0x1b8/0x224)
> > > [   14.672497] [] (exit_mmap) from [] (mmput+0x40/0xf8)
> > > [   14.679180] [] (mmput) from [] (flush_old_exec+0x328/0x604)
> > > [   14.686471] [] (flush_old_exec) from [] (load_elf_binary+0x26c/0x11f4)
> > > [   14.694715] [] (load_elf_binary) from [] (search_binary_handler+0x98/0x244)
> > > [   14.703395] [] (search_binary_handler) from []
> > > (do_execveat_common+0x4dc/0x5bc)
> > > [   14.712421] [] (do_execveat_common) from [] (do_execve+0x28/0x30)
> > > [   14.720235] [] (do_execve) from [] (ret_fast_syscall+0x0/0x34)
> > > [   14.727782] ---[ end trace 5e3ca48b454c7e0a ]---
> > > [   14.733758] ------------[ cut here ]------------
> > > 
> > > Has anyone else tested with CONFIG_ARM_LPAE=y that can confirm my findings?
> > Uggh... I missed since i was looking at non LPAE omap2plus_defconfig.
> > 
> > Dual A15 OMAP5432 with multi_v7_defconfig + CONFIG_ARM_LPAE=y
> > https://github.com/nmenon/kernel-test-logs/blob/next-20150123/multi_lpae_defconfig/omap5-evm.txt
> > 
> > Dual A15 DRA7/AM572x with same configuration as above.
> > https://raw.githubusercontent.com/nmenon/kernel-test-logs/next-20150123/multi_lpae_defconfig/dra7xx-evm.txt
> > https://github.com/nmenon/kernel-test-logs/blob/next-20150123/multi_lpae_defconfig/am57xx-evm.txt
> > 
> > Single A15 DRA72 with same configuration as above:
> > https://raw.githubusercontent.com/nmenon/kernel-test-logs/next-20150123/multi_lpae_defconfig/dra72x-evm.txt
> > 
> > You are right. the issue re-appears with LPAE on :(
> > Apologies on missing that.
> 
> Guys, could you instrument mm_{inc,dec}_nr_pmds() with dump_stack() +
> printk() of the counter and add printk() on mmap_exit() then run a simple
> program which triggers the issue?

The simplest program I think we are all running is "boot to shell" - I
mean, have'nt spend more time digging at it as I am not in a familiar
territory here. :( is there any instrumentation patch you want us to try?

-- 
Regards,
Nishanth Menon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
