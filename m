Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 523E96B0003
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 20:23:33 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id b67so2482440qkh.5
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 17:23:33 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id q45si531441qtg.307.2018.02.07.17.23.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Feb 2018 17:23:32 -0800 (PST)
Date: Thu, 8 Feb 2018 09:23:23 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH 4.14 023/159] mm/sparsemem: Allocate mem_section at
 runtime for CONFIG_SPARSEMEM_EXTREME=y
Message-ID: <20180208012323.GE30270@localhost.localdomain>
References: <d71ba136-71ba-333a-f99b-b8283e2dc545@cn.fujitsu.com>
 <20180207104111.sljc62bgkggmtio4@node.shutemov.name>
 <1518000336.29698.1.camel@gmx.de>
 <cd7e23ce-60a3-08ad-eb5d-21bb91df5937@cn.fujitsu.com>
 <20180207120827.GB30270@localhost.localdomain>
 <2945e12f-caab-b7e7-77e0-bd3971e784be@cn.fujitsu.com>
 <20180207122724.GC30270@localhost.localdomain>
 <0a2d5abe-3081-a784-dd85-70d34a0f60cc@cn.fujitsu.com>
 <20180207124519.GD30270@localhost.localdomain>
 <0988774f-9de0-b18f-1216-57d802502bb7@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0988774f-9de0-b18f-1216-57d802502bb7@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dou Liyang <douly.fnst@cn.fujitsu.com>
Cc: Takao Indoh <indou.takao@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Mike Galbraith <efault@gmx.de>, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Borislav Petkov <bp@suse.de>, Dave Young <dyoung@redhat.com>, Ingo Molnar <mingo@kernel.org>, Vivek Goyal <vgoyal@redhat.com>

On 02/08/18 at 09:14am, Dou Liyang wrote:
> Hi Baoquan,
> 
> At 02/07/2018 08:45 PM, Baoquan He wrote:
> > On 02/07/18 at 08:34pm, Dou Liyang wrote:
> > > 
> > > 
> > > At 02/07/2018 08:27 PM, Baoquan He wrote:
> > > > On 02/07/18 at 08:17pm, Dou Liyang wrote:
> > > > > Hi Baoquan,
> > > > > 
> > > > > At 02/07/2018 08:08 PM, Baoquan He wrote:
> > > > > > On 02/07/18 at 08:00pm, Dou Liyang wrote:
> > > > > > > Hi Kirill,Mike
> > > > > > > 
> > > > > > > At 02/07/2018 06:45 PM, Mike Galbraith wrote:
> > > > > > > > On Wed, 2018-02-07 at 13:41 +0300, Kirill A. Shutemov wrote:
> > > > > > > > > On Wed, Feb 07, 2018 at 05:25:05PM +0800, Dou Liyang wrote:
> > > > > > > > > > Hi All,
> > > > > > > > > > 
> > > > > > > > > > I met the makedumpfile failed in the upstream kernel which contained
> > > > > > > > > > this patch. Did I missed something else?
> > > > > > > > > 
> > > > > > > > > None I'm aware of.
> > > > > > > > > 
> > > > > > > > > Is there a reason to suspect that the issue is related to the bug this patch
> > > > > > > > > fixed?
> > > > > > > > 
> > > > > > > 
> > > > > > > I did a contrastive test by my colleagues Indoh's suggestion.
> > 
> > OK, I may get the reason. kaslr is enabled, right? You can try to
> 
> I add 'nokaslr' to disable the KASLR feature.
    ~~~added??
> 
> # cat /proc/cmdline
> BOOT_IMAGE=/vmlinuz-4.15.0+ root=UUID=10f10326-c923-4098-86aa-afed5c54ee0b
> ro crashkernel=512M rhgb console=tty0 console=ttyS0 nokaslr LANG=en_US.UTF-8
> 
> > disable kaslr and try them again. Because phys_base and kaslr_offset are
> > got from vmlinux, while these are generated at compiling time. Just a
> > guess.
> > 
> 
> Oh, I will recompile the kernel with KASLR disabled in .config.

Then it's not what I guessed. Need debug makedumpfile since using
vmlinux is another code path, few people use it usually.

> 
> 
> Thanks,
> 	dou.
> > > > > > > 
> > > > > > > Revert your two commits:
> > > > > > > 
> > > > > > > commit 83e3c48729d9ebb7af5a31a504f3fd6aff0348c4
> > > > > > > Author: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > > > > > Date:   Fri Sep 29 17:08:16 2017 +0300
> > > > > > > 
> > > > > > > commit 629a359bdb0e0652a8227b4ff3125431995fec6e
> > > > > > > Author: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > > > > > Date:   Tue Nov 7 11:33:37 2017 +0300
> > > > > > > 
> > > > > > > ...and keep others unchanged, the makedumpfile works well.
> > > > > > > 
> > > > > > > > Still works fine for me with .today.  Box is only 16GB desktop box though.
> > > > > > > > 
> > > > > > > Btw, In the upstream kernel which contained this patch, I did two tests:
> > > > > > > 
> > > > > > >     1) use the makedumpfile as core_collector in /etc/kdump.conf, then
> > > > > > > trigger the process of kdump by echo 1 >/proc/sysrq-trigger, the
> > > > > > > makedumpfile works well and I can get the vmcore file.
> > > > > > > 
> > > > > > >         ......It is OK
> > > > > > > 
> > > > > > >     2) use cp as core_collector, do the same operation to get the vmcore file.
> > > > > > > then use makedumpfile to do like above:
> > > > > > > 
> > > > > > >        [douly@localhost code]$ ./makedumpfile -d 31 --message-level 31 -x
> > > > > > > vmlinux_4.15+ vmcore_4.15+_from_cp_command vmcore_4.15+
> > > > > > 
> > > > > > Oh, then please ignore my previous comment. Adding '-D' can give more
> > > > > > debugging message.
> > > > > 
> > > > > I added '-D', Just like before, no more debugging message:
> > > > > 
> > > > > BTW, I use crash to analyze the vmcore file created by 'cp' command.
> > > > > 
> > > > >      ./crash ../makedumpfile/code/vmcore_4.15+_from_cp_command
> > > > > ../makedumpfile/code/vmlinux_4.15+
> > > > > 
> > > > > the crash works well, It's so interesting.
> > > > > 
> > > > > Thanks,
> > > > > 	dou.
> > > > > 
> > > > > The debugging message with '-D':
> > > > 
> > > > And what's the debugging printing when trigger crash by sysrq?
> > > > 
> > > 
> > > kdump: dump target is /dev/vda2
> > > kdump: saving to /sysroot//var/crash/127.0.0.1-2018-02-07-07:31:56/
> > > [    2.751352] EXT4-fs (vda2): re-mounted. Opts: data=ordered
> > > kdump: saving vmcore-dmesg.txt
> > > kdump: saving vmcore-dmesg.txt complete
> > > kdump: saving vmcore
> > > sadump: does not have partition header
> > > sadump: read dump device as unknown format
> > > sadump: unknown format
> > > LOAD (0)
> > >    phys_start : 1000000
> > >    phys_end   : 2a86000
> > >    virt_start : ffffffff81000000
> > >    virt_end   : ffffffff82a86000
> > > LOAD (1)
> > >    phys_start : 1000
> > >    phys_end   : 9fc00
> > >    virt_start : ffff880000001000
> > >    virt_end   : ffff88000009fc00
> > > LOAD (2)
> > >    phys_start : 100000
> > >    phys_end   : 13000000
> > >    virt_start : ffff880000100000
> > >    virt_end   : ffff880013000000
> > > LOAD (3)
> > >    phys_start : 33000000
> > >    phys_end   : 7ffd7000
> > >    virt_start : ffff880033000000
> > >    virt_end   : ffff88007ffd7000
> > > Linux kdump
> > > page_size    : 4096
> > > 
> > > max_mapnr    : 7ffd7
> > > 
> > > Buffer size for the cyclic mode: 131061
> > > 
> > > num of NODEs : 1
> > > 
> > > 
> > > Memory type  : SPARSEMEM_EX
> > > 
> > > mem_map (0)
> > >    mem_map    : ffffea0000000000
> > >    pfn_start  : 0
> > >    pfn_end    : 8000
> > > mem_map (1)
> > >    mem_map    : ffffea0000200000
> > >    pfn_start  : 8000
> > >    pfn_end    : 10000
> > > mem_map (2)
> > >    mem_map    : ffffea0000400000
> > >    pfn_start  : 10000
> > >    pfn_end    : 18000
> > > mem_map (3)
> > >    mem_map    : ffffea0000600000
> > >    pfn_start  : 18000
> > >    pfn_end    : 20000
> > > mem_map (4)
> > >    mem_map    : ffffea0000800000
> > >    pfn_start  : 20000
> > >    pfn_end    : 28000
> > > mem_map (5)
> > >    mem_map    : ffffea0000a00000
> > >    pfn_start  : 28000
> > >    pfn_end    : 30000
> > > mem_map (6)
> > >    mem_map    : ffffea0000c00000
> > >    pfn_start  : 30000
> > >    pfn_end    : 38000
> > > mem_map (7)
> > >    mem_map    : ffffea0000e00000
> > >    pfn_start  : 38000
> > >    pfn_end    : 40000
> > > mem_map (8)
> > >    mem_map    : ffffea0001000000
> > >    pfn_start  : 40000
> > >    pfn_end    : 48000
> > > mem_map (9)
> > >    mem_map    : ffffea0001200000
> > >    pfn_start  : 48000
> > >    pfn_end    : 50000
> > > mem_map (10)
> > >    mem_map    : ffffea0001400000
> > >    pfn_start  : 50000
> > >    pfn_end    : 58000
> > > mem_map (11)
> > >    mem_map    : ffffea0001600000
> > >    pfn_start  : 58000
> > >    pfn_end    : 60000
> > > mem_map (12)
> > >    mem_map    : ffffea0001800000
> > >    pfn_start  : 60000
> > >    pfn_end    : 68000
> > > mem_map (13)
> > >    mem_map    : ffffea0001a00000
> > >    pfn_start  : 68000
> > >    pfn_end    : 70000
> > > mem_map (14)
> > >    mem_map    : ffffea0001c00000
> > >    pfn_start  : 70000
> > >    pfn_end    : 78000
> > > mem_map (15)
> > >    mem_map    : ffffea0001e00000
> > >    pfn_start  : 78000
> > >    pfn_end    : 7ffd7
> > > mmap() is available on the kernel.
> > > Copying data                                      : [100.0 %] -  eta: 0s
> > > Writing erase info...
> > > offset_eraseinfo: 9567fb0, size_eraseinfo: 0
> > > kdump: saving vmcore complete
> > > 
> > > Thanks,
> > > 	dou
> > > 
> > > > > 
> > > > > [douly@localhost code]$ ./makedumpfile -D -d 31 --message-level 31 -x
> > > > > vmlinux_4.15+  vmcore_4.15+_from_cp_command vmcore_4.15+
> > > > > sadump: does not have partition header
> > > > > sadump: read dump device as unknown format
> > > > > sadump: unknown format
> > > > > LOAD (0)
> > > > >     phys_start : 1000000
> > > > >     phys_end   : 2a86000
> > > > >     virt_start : ffffffff81000000
> > > > >     virt_end   : ffffffff82a86000
> > > > > LOAD (1)
> > > > >     phys_start : 1000
> > > > >     phys_end   : 9fc00
> > > > >     virt_start : ffff880000001000
> > > > >     virt_end   : ffff88000009fc00
> > > > > LOAD (2)
> > > > >     phys_start : 100000
> > > > >     phys_end   : 13000000
> > > > >     virt_start : ffff880000100000
> > > > >     virt_end   : ffff880013000000
> > > > > LOAD (3)
> > > > >     phys_start : 33000000
> > > > >     phys_end   : 7ffd7000
> > > > >     virt_start : ffff880033000000
> > > > >     virt_end   : ffff88007ffd7000
> > > > > Linux kdump
> > > > > page_size    : 4096
> > > > > 
> > > > > max_mapnr    : 7ffd7
> > > > > 
> > > > > Buffer size for the cyclic mode: 131061
> > > > > The kernel version is not supported.
> > > > > The makedumpfile operation may be incomplete.
> > > > > 
> > > > > num of NODEs : 1
> > > > > 
> > > > > 
> > > > > Memory type  : SPARSEMEM_EX
> > > > > 
> > > > > mem_map (0)
> > > > >     mem_map    : ffff88007ff26000
> > > > >     pfn_start  : 0
> > > > >     pfn_end    : 8000
> > > > > mem_map (1)
> > > > >     mem_map    : 0
> > > > >     pfn_start  : 8000
> > > > >     pfn_end    : 10000
> > > > > mem_map (2)
> > > > >     mem_map    : 0
> > > > >     pfn_start  : 10000
> > > > >     pfn_end    : 18000
> > > > > mem_map (3)
> > > > >     mem_map    : 0
> > > > >     pfn_start  : 18000
> > > > >     pfn_end    : 20000
> > > > > mem_map (4)
> > > > >     mem_map    : 0
> > > > >     pfn_start  : 20000
> > > > >     pfn_end    : 28000
> > > > > mem_map (5)
> > > > >     mem_map    : 0
> > > > >     pfn_start  : 28000
> > > > >     pfn_end    : 30000
> > > > > mem_map (6)
> > > > >     mem_map    : 0
> > > > >     pfn_start  : 30000
> > > > >     pfn_end    : 38000
> > > > > mem_map (7)
> > > > >     mem_map    : 0
> > > > >     pfn_start  : 38000
> > > > >     pfn_end    : 40000
> > > > > mem_map (8)
> > > > >     mem_map    : 0
> > > > >     pfn_start  : 40000
> > > > >     pfn_end    : 48000
> > > > > mem_map (9)
> > > > >     mem_map    : 0
> > > > >     pfn_start  : 48000
> > > > >     pfn_end    : 50000
> > > > > mem_map (10)
> > > > >     mem_map    : 0
> > > > >     pfn_start  : 50000
> > > > >     pfn_end    : 58000
> > > > > mem_map (11)
> > > > >     mem_map    : 0
> > > > >     pfn_start  : 58000
> > > > >     pfn_end    : 60000
> > > > > mem_map (12)
> > > > >     mem_map    : 0
> > > > >     pfn_start  : 60000
> > > > >     pfn_end    : 68000
> > > > > mem_map (13)
> > > > >     mem_map    : 0
> > > > >     pfn_start  : 68000
> > > > >     pfn_end    : 70000
> > > > > mem_map (14)
> > > > >     mem_map    : 0
> > > > >     pfn_start  : 70000
> > > > >     pfn_end    : 78000
> > > > > mem_map (15)
> > > > >     mem_map    : 0
> > > > >     pfn_start  : 78000
> > > > >     pfn_end    : 7ffd7
> > > > > mmap() is available on the kernel.
> > > > > Checking for memory holes                         : [100.0 %] |         STEP
> > > > > [Checking for memory holes  ] : 0.000014 seconds
> > > > > __vtop4_x86_64: Can't get a valid pte.
> > > > > readmem: Can't convert a virtual address(ffff88007ffd7000) to physical
> > > > > address.
> > > > > readmem: type_addr: 0, addr:ffff88007ffd7000, size:32768
> > > > > __exclude_unnecessary_pages: Can't read the buffer of struct page.
> > > > > create_2nd_bitmap: Can't exclude unnecessary pages.
> > > > > Checking for memory holes                         : [100.0 %] \         STEP
> > > > > [Checking for memory holes  ] : 0.000006 seconds
> > > > > Checking for memory holes                         : [100.0 %] -         STEP
> > > > > [Checking for memory holes  ] : 0.000004 seconds
> > > > > __vtop4_x86_64: Can't get a valid pte.
> > > > > readmem: Can't convert a virtual address(ffff88007ffd7000) to physical
> > > > > address.
> > > > > readmem: type_addr: 0, addr:ffff88007ffd7000, size:32768
> > > > > __exclude_unnecessary_pages: Can't read the buffer of struct page.
> > > > > create_2nd_bitmap: Can't exclude unnecessary pages.
> > > > > 
> > > > > makedumpfile Failed.
> > > > > 
> > > > > > 
> > > > > > > 
> > > > > > >        ......It causes makedumpfile failed.
> > > > > > > 
> > > > > > > 
> > > > > > > Thanks,
> > > > > > > 	dou.
> > > > > > > 
> > > > > > > > 	-Mike
> > > > > > > > 
> > > > > > > > 
> > > > > > > > 
> > > > > > > 
> > > > > > > 
> > > > > > 
> > > > > > 
> > > > > > 
> > > > > 
> > > > > 
> > > > 
> > > > 
> > > > 
> > > 
> > > 
> > 
> > 
> > 
> 
> 
> 
> _______________________________________________
> kexec mailing list
> kexec@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/kexec

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
