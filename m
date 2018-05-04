Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id E86DE6B000C
	for <linux-mm@kvack.org>; Fri,  4 May 2018 12:03:32 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id o67so1004556qkf.21
        for <linux-mm@kvack.org>; Fri, 04 May 2018 09:03:32 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 41-v6si6275967qtb.110.2018.05.04.09.03.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 May 2018 09:03:31 -0700 (PDT)
Subject: Re: [v2] mm: access to uninitialized struct page
References: <20180426202619.2768-1-pasha.tatashin@oracle.com>
 <20180504082731.GA2782@outlook.office365.com>
 <CAGM2rebLfmWLybzNDPt-HTjZY2brkJ_8Bq37xVG_QDs=G+VuxQ@mail.gmail.com>
 <20180504160139.GA4693@outlook.office365.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Message-ID: <22c34b1b-15d9-6a28-d7f2-697bac42bde2@oracle.com>
Date: Fri, 4 May 2018 12:03:02 -0400
MIME-Version: 1.0
In-Reply-To: <20180504160139.GA4693@outlook.office365.com>
Content-Type: text/plain; charset=koi8-r
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrei Vagin <avagin@virtuozzo.com>
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, tglx@linutronix.de, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, mgorman@techsingularity.net, mingo@kernel.org, peterz@infradead.org, Steven Rostedt <rostedt@goodmis.org>, Fengguang Wu <fengguang.wu@intel.com>, Dennis Zhou <dennisszhou@gmail.com>

Thank you, I will try to figure out what is happening.

Pavel

On 05/04/2018 12:01 PM, Andrei Vagin wrote:
> On Fri, May 04, 2018 at 12:47:53PM +0000, Pavel Tatashin wrote:
>> Hi Andrei,
>>
>> Could you please provide me with scripts to reproduce this issue?
> 
> I boot this kernel in a kvm virtual machine. The kernel is built without
> modules. A config file is attahced.
> 
> Here is a qemu command line what I use to reproduce the problem:
> 
> qemu-kvm -kernel /home/avagin/git/linux-next/arch/x86/boot/bzImage      \
>         -append 'root=/dev/vda2 ro debug console=ttyS0,115200 LANG=en_US.UTF-8 slub_debug=FZP raid=noautodetect selinux=0 earlyprintk=serial,ttyS0,115200' \
>         -boot c \
>         -smp 2,sockets=2,cores=1,threads=1 \
>         -drive file=/home/vms/fc22.img,format=raw,if=none,id=drive-virtio-disk0 \
>         --display none \
>         -serial telnet:127.0.0.1:4444,server,nowait -cpu Skylake-Client-IBRS,ss=on,hypervisor=on,tsc_adjust=on,clflushopt=on,xsaves=on,pdpe1gb=on,ibpb=on \
>         -m 4096 \
>         -realtime mlock=off \
>         -machine pc-i440fx-2.3,accel=kvm,usb=off,dump-guest-core=off \
>         -device ich9-usb-ehci1,id=usb,bus=pci.0,addr=0x6.0x7 -device ich9-usb-uhci1,masterbus=usb.0,firstport=0,bus=pci.0,multifunction=on,addr=0x6 \
>         -device ich9-usb-uhci2,masterbus=usb.0,firstport=2,bus=pci.0,addr=0x6.0x1 \
>         -device ich9-usb-uhci3,masterbus=usb.0,firstport=4,bus=pci.0,addr=0x6.0x2 \
>         -device virtio-blk-pci,scsi=off,bus=pci.0,addr=0x7,drive=drive-virtio-disk0,id=virtio-disk0,bootindex=1 -device virtio-balloon-pci,id=balloon0,bus=pci.0,addr=0x8 -msg timestamp=on
> 
> 
> [avagin@laptop linux-next]$ cat /proc/cpuinfo 
> processor	: 0
> vendor_id	: GenuineIntel
> cpu family	: 6
> model		: 78
> model name	: Intel(R) Core(TM) i5-6300U CPU @ 2.40GHz
> stepping	: 3
> microcode	: 0xc2
> cpu MHz		: 1213.986
> cache size	: 3072 KB
> physical id	: 0
> siblings	: 4
> core id		: 0
> cpu cores	: 2
> apicid		: 0
> initial apicid	: 0
> fpu		: yes
> fpu_exception	: yes
> cpuid level	: 22
> wp		: yes
> flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault epb invpcid_single pti tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1 hle avx2 smep bmi2 erms invpcid rtm mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves ibpb ibrs stibp dtherm ida arat pln pts hwp hwp_notify hwp_act_window hwp_epp
> bugs		: cpu_meltdown spectre_v1 spectre_v2
> bogomips	: 4992.00
> clflush size	: 64
> cache_alignment	: 64
> address sizes	: 39 bits physical, 48 bits virtual
> power management:
> 
>>
>> Thank you,
>> Pavel
>> On Fri, May 4, 2018 at 4:27 AM Andrei Vagin <avagin@virtuozzo.com> wrote:
>>
>>> Hello,
>>
>>> We have a robot which runs criu tests on linux-next kernels.
>>
>>> All tests passed on 4.17.0-rc3-next-20180502.
>>
>>> But the 4.17.0-rc3-next-20180504 kernel didn't boot.
>>
>>> git bisect points on this patch.
>>
>>> On Thu, Apr 26, 2018 at 04:26:19PM -0400, Pavel Tatashin wrote:
>>>> The following two bugs were reported by Fengguang Wu:
>>>>
>>>> kernel reboot-without-warning in early-boot stage, last printk:
>>>> early console in setup code
>>>>
>>>>
>> http://lkml.kernel.org/r/20180418135300.inazvpxjxowogyge@wfg-t540p.sh.intel.com
>>
>>> The problem looks similar with this one.
>>
>>> [    5.596975] devtmpfs: mounted
>>> [    5.855754] Freeing unused kernel memory: 1704K
>>> [    5.858162] Write protecting the kernel read-only data: 18432k
>>> [    5.860772] Freeing unused kernel memory: 2012K
>>> [    5.861838] Freeing unused kernel memory: 160K
>>> [    5.862572] rodata_test: all tests were successful
>>> [    5.866857] random: fast init done
>>> early console in setup code
>>> [    0.000000] Linux version 4.17.0-rc3-00023-g7c4cc2d022a1
>>> (avagin@laptop) (gcc version 8.0.1 20180324 (Red Hat 8.0.1-0.20) (GCC))
>>> #13 SMP Fri May 4 01:10:51 PDT 2018
>>> [    0.000000] Command line: root=/dev/vda2 ro debug
>>> console=ttyS0,115200 LANG=en_US.UTF-8 slub_debug=FZP raid=noautodetect
>>> selinux=0 earlyprintk=serial,ttyS0,115200
>>> [    0.000000] x86/fpu: Supporting XSAVE feature 0x001: 'x87 floating
>>> point registers'
>>> [    0.000000] x86/fpu: Supporting XSAVE feature 0x002: 'SSE registers'
>>> [    0.000000] x86/fpu: Supporting XSAVE feature 0x004: 'AVX registers'
>>> [    0.000000] x86/fpu: Supporting XSAVE feature 0x008: 'MPX bounds
>>> registers'
>>
>>> $ git describe HEAD
>>> v4.17-rc3-23-g7c4cc2d022a1
>>
>>> [avagin@laptop linux-next]$ git log --pretty=oneline  | head -n 1
>>> 7c4cc2d022a1fd56eb2ee555533b8666bc780f1e mm: access to uninitialized
>> struct page
>>
>>
>>>>
>>>> And, also:
>>>> [per_cpu_ptr_to_phys] PANIC: early exception 0x0d
>>>> IP 10:ffffffffa892f15f error 0 cr2 0xffff88001fbff000
>>>>
>>>>
>> http://lkml.kernel.org/r/20180419013128.iurzouiqxvcnpbvz@wfg-t540p.sh.intel.com
>>>>
>>>> Both of the problems are due to accessing uninitialized struct page from
>>>> trap_init(). We must first do mm_init() in order to initialize allocated
>>>> struct pages, and than we can access fields of any struct page that
>> belongs
>>>> to memory that's been allocated.
>>>>
>>>> Below is explanation of the root cause.
>>>>
>>>> The issue arises in this stack:
>>>>
>>>> start_kernel()
>>>>  trap_init()
>>>>   setup_cpu_entry_areas()
>>>>    setup_cpu_entry_area(cpu)
>>>>     get_cpu_gdt_paddr(cpu)
>>>>      per_cpu_ptr_to_phys(addr)
>>>>       pcpu_addr_to_page(addr)
>>>>        virt_to_page(addr)
>>>>         pfn_to_page(__pa(addr) >> PAGE_SHIFT)
>>>> The returned "struct page" is sometimes uninitialized, and thus
>>>> failing later when used. It turns out sometimes is because it depends
>>>> on KASLR.
>>>>
>>>> When boot is failing we have this when  pfn_to_page() is called:
>>>> kasrl: 0x000000000d600000
>>>>  addr: ffffffff83e0d000
>>>>     pa: 1040d000
>>>>    pfn: 1040d
>>>> page: ffff88001f113340
>>>> page->flags ffffffffffffffff <- Uninitialized!
>>>>
>>>> When boot is successful:
>>>> kaslr: 0x000000000a800000
>>>>  addr: ffffffff83e0d000
>>>>      pa: d60d000
>>>>     pfn: d60d
>>>>  page: ffff88001f05b340
>>>> page->flags 280000000000 <- Initialized!
>>>>
>>>> Here are physical addresses that BIOS provided to us:
>>>> e820: BIOS-provided physical RAM map:
>>>> BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
>>>> BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
>>>> BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
>>>> BIOS-e820: [mem 0x0000000000100000-0x000000001ffdffff] usable
>>>> BIOS-e820: [mem 0x000000001ffe0000-0x000000001fffffff] reserved
>>>> BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
>>>> BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
>>>>
>>>> In both cases, working and non-working the real physical address is
>>>> the same:
>>>>
>>>> pa - kasrl = 0x2E0D000
>>>>
>>>> The only thing that is different is PFN.
>>>>
>>>> We initialize struct pages in four places:
>>>>
>>>> 1. Early in boot a small set of struct pages is initialized to fill
>>>> the first section, and lower zones.
>>>> 2. During mm_init() we initialize "struct pages" for all the memory
>>>> that is allocated, i.e reserved in memblock.
>>>> 3. Using on-demand logic when pages are allocated after mm_init call
>>>> 4. After smp_init() when the rest free deferred pages are initialized.
>>>>
>>>> The above path happens before deferred memory is initialized, and thus
>>>> it must be covered either by 1, 2 or 3.
>>>>
>>>> So, lets check what PFNs are initialized after (1).
>>>>
>>>> memmap_init_zone() is called for pfn ranges:
>>>> 1 - 1000, and 1000 - 1ffe0, but it quits after reaching pfn 0x10000,
>>>> as it leaves the rest to be initialized as deferred pages.
>>>>
>>>> In the working scenario pfn ended up being below 1000, but in the
>>>> failing scenario it is above. Hence, we must initialize this page in
>>>> (2). But trap_init() is called before mm_init().
>>>>
>>>> The bug was introduced by "mm: initialize pages on demand during boot"
>>>> because we lowered amount of pages that is initialized in the step
>>>> (1). But, it still could happen, because the number of initialized
>>>> pages was a guessing.
>>>>
>>>> The current fix moves trap_init() to be called after mm_init, but as
>>>> alternative, we could increase pgdat->static_init_pgcnt:
>>>> In free_area_init_node we can increase:
>>>>        pgdat->static_init_pgcnt = min_t(unsigned long,
>> PAGES_PER_SECTION,
>>>>                                         pgdat->node_spanned_pages);
>>>> Instead of one PAGES_PER_SECTION, set several, so the text is
>>>> covered for all KASLR offsets. But, this would still be guessing.
>>>> Therefore, I prefer the current fix.
>>>>
>>>> Fixes: c9e97a1997fb ("mm: initialize pages on demand during boot")
>>>>
>>>> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
>>>> Reviewed-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
>>>> ---
>>>>  init/main.c | 2 +-
>>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>>
>>>> diff --git a/init/main.c b/init/main.c
>>>> index b795aa341a3a..870f75581cea 100644
>>>> --- a/init/main.c
>>>> +++ b/init/main.c
>>>> @@ -585,8 +585,8 @@ asmlinkage __visible void __init start_kernel(void)
>>>>       setup_log_buf(0);
>>>>       vfs_caches_init_early();
>>>>       sort_main_extable();
>>>> -     trap_init();
>>>>       mm_init();
>>>> +     trap_init();
>>>>
>>>>       ftrace_init();
>>>>
