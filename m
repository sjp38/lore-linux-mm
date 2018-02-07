Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id DF8316B0300
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 06:28:18 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id e4so458904qtb.14
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 03:28:18 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id d133si1293395qke.103.2018.02.07.03.28.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Feb 2018 03:28:17 -0800 (PST)
Date: Wed, 7 Feb 2018 19:28:08 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH 4.14 023/159] mm/sparsemem: Allocate mem_section at
 runtime for CONFIG_SPARSEMEM_EXTREME=y
Message-ID: <20180207112808.GA30270@localhost.localdomain>
References: <20171222084623.668990192@linuxfoundation.org>
 <20171222084625.007160464@linuxfoundation.org>
 <1515302062.6507.18.camel@gmx.de>
 <20180108160444.2ol4fvgqbxnjmlpg@gmail.com>
 <20180108174653.7muglyihpngxp5tl@black.fi.intel.com>
 <20180109001303.dy73bpixsaegn4ol@node.shutemov.name>
 <1515469448.6766.12.camel@gmx.de>
 <d71ba136-71ba-333a-f99b-b8283e2dc545@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d71ba136-71ba-333a-f99b-b8283e2dc545@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dou Liyang <douly.fnst@cn.fujitsu.com>
Cc: Mike Galbraith <efault@gmx.de>, "Kirill A. Shutemov" <kirill@shutemov.name>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@suse.de>, Dave Young <dyoung@redhat.com>, Vivek Goyal <vgoyal@redhat.com>

On 02/07/18 at 05:25pm, Dou Liyang wrote:
> Hi All,
> 
> I met the makedumpfile failed in the upstream kernel which contained
> this patch. Did I missed something else?

readmem: Can't convert a virtual address(ffff88007ffd7000) to physical

Should not related to this patch. Otherwise your code can't get to that
step. From message, ffff88007ffd7000 is the end of the last mem region,
seems a code bug. You are testing 5-level on makedumpfile, right?

The patches I posted to descrease the memmory cost on mem map allocation
has code bug, Fengguang's test robot sent a mail to me, I have updated
patches, try to write a good patch log. You might also need check the
5-level patches you posted to makedumpfile upstream.

> 
> In fedora27 host:
> 
> [douly@localhost code]$ ./makedumpfile -d 31 --message-level 31 -x
> vmlinux_4.15+ vmcore_4.15+_from_cp_command vmcore_4.15+
> 
> sadump: does not have partition header
> sadump: read dump device as unknown format
> sadump: unknown format
> LOAD (0)
>   phys_start : 1000000
>   phys_end   : 2a86000
>   virt_start : ffffffff81000000
>   virt_end   : ffffffff82a86000
> LOAD (1)
>   phys_start : 1000
>   phys_end   : 9fc00
>   virt_start : ffff880000001000
>   virt_end   : ffff88000009fc00
> LOAD (2)
>   phys_start : 100000
>   phys_end   : 13000000
>   virt_start : ffff880000100000
>   virt_end   : ffff880013000000
> LOAD (3)
>   phys_start : 33000000
>   phys_end   : 7ffd7000
>   virt_start : ffff880033000000
>   virt_end   : ffff88007ffd7000
> Linux kdump
> page_size    : 4096
> 
> max_mapnr    : 7ffd7
> 
> Buffer size for the cyclic mode: 131061
> The kernel version is not supported.
> The makedumpfile operation may be incomplete.
> 
> num of NODEs : 1
> 
> 
> Memory type  : SPARSEMEM_EX
> 
> mem_map (0)
>   mem_map    : ffff88007ff26000
>   pfn_start  : 0
>   pfn_end    : 8000
> mem_map (1)
>   mem_map    : 0
>   pfn_start  : 8000
>   pfn_end    : 10000
> mem_map (2)
>   mem_map    : 0
>   pfn_start  : 10000
>   pfn_end    : 18000
> mem_map (3)
>   mem_map    : 0
>   pfn_start  : 18000
>   pfn_end    : 20000
> mem_map (4)
>   mem_map    : 0
>   pfn_start  : 20000
>   pfn_end    : 28000
> mem_map (5)
>   mem_map    : 0
>   pfn_start  : 28000
>   pfn_end    : 30000
> mem_map (6)
>   mem_map    : 0
>   pfn_start  : 30000
>   pfn_end    : 38000
> mem_map (7)
>   mem_map    : 0
>   pfn_start  : 38000
>   pfn_end    : 40000
> mem_map (8)
>   mem_map    : 0
>   pfn_start  : 40000
>   pfn_end    : 48000
> mem_map (9)
>   mem_map    : 0
>   pfn_start  : 48000
>   pfn_end    : 50000
> mem_map (10)
>   mem_map    : 0
>   pfn_start  : 50000
>   pfn_end    : 58000
> mem_map (11)
>   mem_map    : 0
>   pfn_start  : 58000
>   pfn_end    : 60000
> mem_map (12)
>   mem_map    : 0
>   pfn_start  : 60000
>   pfn_end    : 68000
> mem_map (13)
>   mem_map    : 0
>   pfn_start  : 68000
>   pfn_end    : 70000
> mem_map (14)
>   mem_map    : 0
>   pfn_start  : 70000
>   pfn_end    : 78000
> mem_map (15)
>   mem_map    : 0
>   pfn_start  : 78000
>   pfn_end    : 7ffd7
> mmap() is available on the kernel.
> Checking for memory holes                         : [100.0 %] |         STEP
> [Checking for memory holes  ] : 0.000060 seconds
> __vtop4_x86_64: Can't get a valid pte.
> readmem: Can't convert a virtual address(ffff88007ffd7000) to physical
> address.
> readmem: type_addr: 0, addr:ffff88007ffd7000, size:32768
> __exclude_unnecessary_pages: Can't read the buffer of struct page.
> create_2nd_bitmap: Can't exclude unnecessary pages.
> Checking for memory holes                         : [100.0 %] \         STEP
> [Checking for memory holes  ] : 0.000010 seconds
> Checking for memory holes                         : [100.0 %] -         STEP
> [Checking for memory holes  ] : 0.000004 seconds
> __vtop4_x86_64: Can't get a valid pte.
> readmem: Can't convert a virtual address(ffff88007ffd7000) to physical
> address.
> readmem: type_addr: 0, addr:ffff88007ffd7000, size:32768
> __exclude_unnecessary_pages: Can't read the buffer of struct page.
> create_2nd_bitmap: Can't exclude unnecessary pages.
> 
> Thanks,
> 	dou
> At 01/09/2018 11:44 AM, Mike Galbraith wrote:
> > On Tue, 2018-01-09 at 03:13 +0300, Kirill A. Shutemov wrote:
> > > 
> > > Mike, could you test this? (On top of the rest of the fixes.)
> > 
> > homer:..crash/2018-01-09-04:25 # ll
> > total 1863604
> > -rw------- 1 root root      66255 Jan  9 04:25 dmesg.txt
> > -rw-r--r-- 1 root root        182 Jan  9 04:25 README.txt
> > -rw-r--r-- 1 root root    2818240 Jan  9 04:25 System.map-4.15.0.gb2cd1df-master
> > -rw------- 1 root root 1832914928 Jan  9 04:25 vmcore
> > -rw-r--r-- 1 root root   72514993 Jan  9 04:25 vmlinux-4.15.0.gb2cd1df-master.gz
> > 
> > Yup, all better.
> > 
> > > Sorry for the mess.
> > 
> > (why, developers not installing shiny new bugs is a whole lot worse:)
> > 
> > >  From 100fd567754f1457be94732046aefca204c842d2 Mon Sep 17 00:00:00 2001
> > > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > > Date: Tue, 9 Jan 2018 02:55:47 +0300
> > > Subject: [PATCH] kdump: Write a correct address of mem_section into vmcoreinfo
> > > 
> > > Depending on configuration mem_section can now be an array or a pointer
> > > to an array allocated dynamically. In most cases, we can continue to refer
> > > to it as 'mem_section' regardless of what it is.
> > > 
> > > But there's one exception: '&mem_section' means "address of the array" if
> > > mem_section is an array, but if mem_section is a pointer, it would mean
> > > "address of the pointer".
> > > 
> > > We've stepped onto this in kdump code. VMCOREINFO_SYMBOL(mem_section)
> > > writes down address of pointer into vmcoreinfo, not array as we wanted.
> > > 
> > > Let's introduce VMCOREINFO_ARRAY() that would handle the situation
> > > correctly for both cases.
> > > 
> > > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > Fixes: 83e3c48729d9 ("mm/sparsemem: Allocate mem_section at runtime for CONFIG_SPARSEMEM_EXTREME=y")
> > > ---
> > >   include/linux/crash_core.h | 2 ++
> > >   kernel/crash_core.c        | 2 +-
> > >   2 files changed, 3 insertions(+), 1 deletion(-)
> > > 
> > > diff --git a/include/linux/crash_core.h b/include/linux/crash_core.h
> > > index 06097ef30449..83ae04950269 100644
> > > --- a/include/linux/crash_core.h
> > > +++ b/include/linux/crash_core.h
> > > @@ -42,6 +42,8 @@ phys_addr_t paddr_vmcoreinfo_note(void);
> > >   	vmcoreinfo_append_str("PAGESIZE=%ld\n", value)
> > >   #define VMCOREINFO_SYMBOL(name) \
> > >   	vmcoreinfo_append_str("SYMBOL(%s)=%lx\n", #name, (unsigned long)&name)
> > > +#define VMCOREINFO_ARRAY(name) \
> > > +	vmcoreinfo_append_str("SYMBOL(%s)=%lx\n", #name, (unsigned long)name)
> > >   #define VMCOREINFO_SIZE(name) \
> > >   	vmcoreinfo_append_str("SIZE(%s)=%lu\n", #name, \
> > >   			      (unsigned long)sizeof(name))
> > > diff --git a/kernel/crash_core.c b/kernel/crash_core.c
> > > index b3663896278e..d4122a837477 100644
> > > --- a/kernel/crash_core.c
> > > +++ b/kernel/crash_core.c
> > > @@ -410,7 +410,7 @@ static int __init crash_save_vmcoreinfo_init(void)
> > >   	VMCOREINFO_SYMBOL(contig_page_data);
> > >   #endif
> > >   #ifdef CONFIG_SPARSEMEM
> > > -	VMCOREINFO_SYMBOL(mem_section);
> > > +	VMCOREINFO_ARRAY(mem_section);
> > >   	VMCOREINFO_LENGTH(mem_section, NR_SECTION_ROOTS);
> > >   	VMCOREINFO_STRUCT_SIZE(mem_section);
> > >   	VMCOREINFO_OFFSET(mem_section, section_mem_map);
> > 
> > _______________________________________________
> > kexec mailing list
> > kexec@lists.infradead.org
> > http://lists.infradead.org/mailman/listinfo/kexec
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
