Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id A5C586B0032
	for <linux-mm@kvack.org>; Sun, 28 Apr 2013 04:03:56 -0400 (EDT)
Received: by mail-ob0-f170.google.com with SMTP id eh20so4694546obb.1
        for <linux-mm@kvack.org>; Sun, 28 Apr 2013 01:03:55 -0700 (PDT)
Message-ID: <517CD7E4.9000902@gmail.com>
Date: Sun, 28 Apr 2013 16:03:48 +0800
From: Will Huck <will.huckk@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86: add phys addr validity check for /dev/mem mmap
References: <1364905733-23937-1-git-send-email-fhrbata@redhat.com> <517A0ED8.6000404@gmail.com> <20130426153502.GC3510@dhcp-26-164.brq.redhat.com> <517B777B.5020303@gmail.com> <20130427191349.GA3372@dhcp-26-164.brq.redhat.com> <517C94DA.9070002@gmail.com> <91ecff35-3b4d-4782-ab8e-b56488aac5b7@email.android.com>
In-Reply-To: <91ecff35-3b4d-4782-ab8e-b56488aac5b7@email.android.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Frantisek Hrbata <fhrbata@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, oleg@redhat.com, kamaleshb@in.ibm.com, hechjie@cn.ibm.com

Hi Peter,
On 04/28/2013 12:00 PM, H. Peter Anvin wrote:
> Not reserved page, reserved bits in the page tables (which includes all bits beyond the maximum physical address.)

Thanks for your clarify. When these reserved bits are set?

Another question, if configure UMA to fake numa can get benefit?

>
> Will Huck <will.huckk@gmail.com> wrote:
>
>> On 04/28/2013 03:13 AM, Frantisek Hrbata wrote:
>>> On Sat, Apr 27, 2013 at 03:00:11PM +0800, Will Huck wrote:
>>>> On 04/26/2013 11:35 PM, Frantisek Hrbata wrote:
>>>>> On Fri, Apr 26, 2013 at 01:21:28PM +0800, Will Huck wrote:
>>>>>> Hi Peter,
>>>>>> On 04/02/2013 08:28 PM, Frantisek Hrbata wrote:
>>>>>>> When CR4.PAE is set, the 64b PTE's are
>> used(ARCH_PHYS_ADDR_T_64BIT is set for
>>>>>>> X86_64 || X86_PAE). According to [1] Chapter 4 Paging, some
>> higher bits in 64b
>>>>>>> PTE are reserved and have to be set to zero. For example, for
>> IA-32e and 4KB
>>>>>>> page [1] 4.5 IA-32e Paging: Table 4-19, bits 51-M(MAXPHYADDR) are
>> reserved. So
>>>>>>> for a CPU with e.g. 48bit phys addr width, bits 51-48 have to be
>> zero. If one of
>>>>>>> the reserved bits is set, [1] 4.7 Page-Fault Exceptions, the #PF
>> is generated
>>>>>>> with RSVD error code.
>>>>>>>
>>>>>>> <quote>
>>>>>>> RSVD flag (bit 3).
>>>>>>> This flag is 1 if there is no valid translation for the linear
>> address because a
>>>>>>> reserved bit was set in one of the paging-structure entries used
>> to translate
>>>>>>> that address. (Because reserved bits are not checked in a
>> paging-structure entry
>>>>>>> whose P flag is 0, bit 3 of the error code can be set only if bit
>> 0 is also
>>>>>>> set.)
>>>>>>> </quote>
>>>>>>>
>>>>>>> In mmap_mem() the first check is valid_mmap_phys_addr_range(),
>> but it always
>>>>>>> returns 1 on x86. So it's possible to use any pgoff we want and
>> to set the PTE's
>>>>>>> reserved bits in remap_pfn_range(). Meaning there is a
>> possibility to use mmap
>>>>>> In this case, remap_pfn_range() setup the map and reserved bits
>> for
>>>>>> mmio memory, so the mmio memory is already populated, why trigger
>>>>>> #PF?
>>>>> Hi,
>>>>>
>>>>> I think this is described in the quote above for the RSVD flag.
>>>>>
>>>>> remap_pfn_range() => page present => touch page => tlb miss =>
>>>>> walk through paging structures => reserved bit set => #pf with rsvd
>> flag
>>>> Page present can also trigger #PF? why?
>>> Yes, please see
>>> Intel 64 and IA-32 Architectures Software Developer's Manual, Volume
>> 3A
>>> 4.7 PAGE-FAULT EXCEPTIONS
>>> <quote>
>>> A. RSVD flag (bit 3).
>>> This flag is 1 if there is no valid translation for the linear
>> address because
>>> a reserved bit was set in one of the paging-structure entries used to
>>> translate that address. (Because reserved bits are not checked in a
>>> paging-structure entry whose P flag is 0, bit 3 of the error code can
>> be set
>>> only if bit 0 is also set.) Bits reserved in the paging-structure
>> entries are
>>> reserved for future functionality. Software developers should be
>> aware that
>>> such bits may be used in the future and that a paging-structure entry
>> that
>>> causes a page-fault exception on one processor might not do so in the
>> future.
>>> </quote>
>>>
>>> I cannot tell you why. I guess this is more a question for some Intel
>> guys.
>>> Anyway this patch is trying to fix the following problem and
>>> the "Bad pagetable" oops.
>>>
>>>
>> ---------------------------------8<--------------------------------------
>>> #include <stdio.h>
>>> #include <unistd.h>
>>> #include <sys/types.h>
>>> #include <sys/stat.h>
>>> #include <fcntl.h>
>>> #include <err.h>
>>> #include <stdlib.h>
>>> #include <sys/mman.h>
>>>
>>> #define die(fmt, ...) err(1, fmt, ##__VA_ARGS__)
>>>
>>> /*
>>>      1) Find some non system ram in case the CONFIG_STRICT_DEVMEM is
>> defined
>>>      $ cat /proc/iomem | grep -v "\(System RAM\|reserved\)"
>>>
>>>      2) Find physical address width
>>>      $ cat /proc/cpuinfo | grep "address sizes"
>>>
>>>      PTE bits 51 - M are reserved, where M is physical address width
>> found 2)
>>>      Note: step 2) is actually not needed, we can always set just the
>> 51th bit
>>>      (0x8000000000000)
>> What's the meaning here? You trigger oops since the address is beyond
>> max address cpu supported or access to a reserved page? If the answer
>> is
>> the latter, I'm think it's not right. For example, the kernel code/data
>>
>> section is reserved in memory, kernel access it will trigger oops? I
>> don't think so.
>>
>>>      Set OFFSET macro to
>>>
>>>      (start of iomem range found in 1)) | (1 << 51)
>>>
>>>      for example
>>>      0x000a0000 | 0x8000000000000 = 0x80000000a0000
>>>
>>>      where 0x000a0000 is start of PCI BUS on my laptop
>>>
>>>    */
>>>
>>> #define OFFSET 0x80000000a0000LL
>>>
>>> int main(int argc, char *argv[])
>>> {
>>> 	int fd;
>>> 	long ps;
>>> 	long pgoff;
>>> 	char *map;
>>> 	char c;
>>>
>>> 	ps = sysconf(_SC_PAGE_SIZE);
>>> 	if (ps == -1)
>>> 		die("cannot get page size");
>>>
>>> 	fd = open("/dev/mem", O_RDONLY);
>>> 	if (fd == -1)
>>> 		die("cannot open /dev/mem");
>>>
>>> 	printf("%Lx\n", pgoff);
>>> 	pgoff = (OFFSET + (ps - 1)) & ~(ps - 1);
>>> 	printf("%Lx\n", pgoff);
>>>
>>> 	map = mmap(NULL, ps, PROT_READ, MAP_SHARED, fd, pgoff);
>>> 	if (map == MAP_FAILED)
>>> 		die("cannot mmap");
>>>
>>> 	c = map[0];
>>>
>>> 	if (munmap(map, ps) == -1)
>>> 		die("cannot munmap");
>>>
>>> 	if (close(fd) == -1)
>>> 		die("cannot close");
>>>
>>> 	return 0;
>>> }
>>>
>> ---------------------------------8<--------------------------------------
>>> Apr 27 19:52:29 dhcp-26-164 kernel: [ 6464.814860] pfrsvd: Corrupted
>> page table at address 7f34087c8000
>>> Apr 27 19:52:29 dhcp-26-164 kernel: [ 6464.817356] PGD 12d0b3067 PUD
>> 12d544067 PMD 12e29d067 PTE 80080000000a0225
>>> Apr 27 19:52:29 dhcp-26-164 kernel: [ 6464.820216] Bad pagetable:
>> 000d [#1] SMP
>>> Apr 27 19:52:29 dhcp-26-164 kernel: [ 6464.822821] Modules linked in:
>> fuse ebtable_nat xt_CHECKSUM bridge stp llc ipt_MASQUERADE
>> nf_conntrack_netbios_ns nf_conntrack_broadcast ip6table_mangle
>> ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 iptable_nat nf_nat_ipv4
>> nf_nat iptable_mangle nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack
>> nf_conntrack ebtable_filter ebtables ip6table_filter ip6_tables
>> be2iscsi iscsi_boot_sysfs bnx2i cnic uio cxgb4i cxgb4 cxgb3i cxgb3 mdio
>> libcxgbi ib_iser rdma_cm ib_addr iw_cm ib_cm ib_sa ib_mad ib_core
>> iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi rfcomm bnep arc4
>> iwldvm mac80211 snd_hda_codec_hdmi snd_hda_codec_conexant snd_hda_intel
>> snd_hda_codec uvcvideo snd_hwdep snd_seq snd_seq_device snd_pcm
>> iTCO_wdt videobuf2_vmalloc videobuf2_memops videobuf2_core videodev
>> btusb snd_page_alloc bluetooth snd_timer thinkpad_acpi iwlwifi media
>> snd i2c_i801 cfg80211 iTCO_vendor_support intel_ips e1000e coretemp
>> lpc_ich mfd_core soundcore rfkill mei microcode nfsd auth_rpcgss
>> nfs_acl lockd sunrpc vhost_net tun macvtap macvlan kvm_intel kvm
>> binfmt_misc uinput dm_crypt crc32c_intel i915 ghash_clmulni_intel
>> firewire_ohci i2c_algo_bit drm_kms_helper firewire_core sdhci_pci
>> crc_itu_t drm sdhci mmc_core i2c_core mxm_wmi video wmi
>>> Apr 27 19:52:29 dhcp-26-164 kernel: [ 6464.845686] CPU 3
>>> Apr 27 19:52:29 dhcp-26-164 kernel: [ 6464.845709] Pid: 8751, comm:
>> pfrsvd Not tainted 3.8.1-201.fc18.x86_64 #1 LENOVO 4384AV1/4384AV1
>>> Apr 27 19:52:29 dhcp-26-164 kernel: [ 6464.852876] RIP:
>> 0033:[<00000000004007db>]  [<00000000004007db>] 0x4007da
>>> Apr 27 19:52:29 dhcp-26-164 kernel: [ 6464.856587] RSP:
>> 002b:00007ffff5c12620  EFLAGS: 00010213
>>> Apr 27 19:52:29 dhcp-26-164 kernel: [ 6464.860296] RAX:
>> 00007f34087c8000 RBX: 0000000000000000 RCX: 00000030fd4eed6a
>>> Apr 27 19:52:29 dhcp-26-164 kernel: [ 6464.864061] RDX:
>> 0000000000000001 RSI: 0000000000001000 RDI: 0000000000000000
>>> Apr 27 19:52:29 dhcp-26-164 kernel: [ 6464.867878] RBP:
>> 00007ffff5c12660 R08: 0000000000000003 R09: 00080000000a0000
>>> Apr 27 19:52:29 dhcp-26-164 kernel: [ 6464.871706] R10:
>> 0000000000000001 R11: 0000000000000206 R12: 00000000004005f0
>>> Apr 27 19:52:29 dhcp-26-164 kernel: [ 6464.875566] R13:
>> 00007ffff5c12740 R14: 0000000000000000 R15: 0000000000000000
>>> Apr 27 19:52:29 dhcp-26-164 kernel: [ 6464.879490] FS:
>> 00007f34087a0740(0000) GS:ffff880137d80000(0000) knlGS:0000000000000000
>>> Apr 27 19:52:29 dhcp-26-164 kernel: [ 6464.883447] CS:  0010 DS: 0000
>> ES: 0000 CR0: 0000000080050033
>>> Apr 27 19:52:29 dhcp-26-164 kernel: [ 6464.887436] CR2:
>> 00007f34087c8000 CR3: 0000000107509000 CR4: 00000000000007e0
>>> Apr 27 19:52:29 dhcp-26-164 kernel: [ 6464.891495] DR0:
>> 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>>> Apr 27 19:52:29 dhcp-26-164 kernel: [ 6464.895603] DR3:
>> 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>>> Apr 27 19:52:29 dhcp-26-164 kernel: [ 6464.899739] Process pfrsvd
>> (pid: 8751, threadinfo ffff880104ea8000, task ffff88012d9e1760)
>>> Apr 27 19:52:29 dhcp-26-164 kernel: [ 6464.903944]
>>> Apr 27 19:52:29 dhcp-26-164 kernel: [ 6464.908169] RIP
>> [<00000000004007db>] 0x4007da
>>> Apr 27 19:52:29 dhcp-26-164 kernel: [ 6464.912447]  RSP
>> <00007ffff5c12620>
>>> Apr 27 19:52:29 dhcp-26-164 kernel: [ 6464.943802] ---[ end trace
>> 1113d12a53145197 ]---
>>> Please note the PTE value 80080000000a0225
>>>
>>> HTH
>>>
>>> Thank you
>>>>> I hope I didn't misunderstand your question.
>>>>>
>>>>> Thanks
>>>>>
>>>>>>> on /dev/mem and cause system panic. It's probably not that
>> serious, because
>>>>>>> access to /dev/mem is limited and the system has to have
>> panic_on_oops set, but
>>>>>>> still I think we should check this and return error.
>>>>>>>
>>>>>>> This patch adds check for x86 when ARCH_PHYS_ADDR_T_64BIT is set,
>> the same way
>>>>>>> as it is already done in e.g. ioremap. With this fix mmap returns
>> -EINVAL if the
>>>>>>> requested phys addr is bigger then the supported phys addr width.
>>>>>>>
>>>>>>> [1] Intel 64 and IA-32 Architectures Software Developer's Manual,
>> Volume 3A
>>>>>>> Signed-off-by: Frantisek Hrbata <fhrbata@redhat.com>
>>>>>>> ---
>>>>>>>    arch/x86/include/asm/io.h |  4 ++++
>>>>>>>    arch/x86/mm/mmap.c        | 13 +++++++++++++
>>>>>>>    2 files changed, 17 insertions(+)
>>>>>>>
>>>>>>> diff --git a/arch/x86/include/asm/io.h
>> b/arch/x86/include/asm/io.h
>>>>>>> index d8e8eef..39607c6 100644
>>>>>>> --- a/arch/x86/include/asm/io.h
>>>>>>> +++ b/arch/x86/include/asm/io.h
>>>>>>> @@ -242,6 +242,10 @@ static inline void flush_write_buffers(void)
>>>>>>>    #endif
>>>>>>>    }
>>>>>>> +#define ARCH_HAS_VALID_PHYS_ADDR_RANGE
>>>>>>> +extern int valid_phys_addr_range(phys_addr_t addr, size_t
>> count);
>>>>>>> +extern int valid_mmap_phys_addr_range(unsigned long pfn, size_t
>> count);
>>>>>>> +
>>>>>>>    #endif /* __KERNEL__ */
>>>>>>>    extern void native_io_delay(void);
>>>>>>> diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
>>>>>>> index 845df68..92ec31c 100644
>>>>>>> --- a/arch/x86/mm/mmap.c
>>>>>>> +++ b/arch/x86/mm/mmap.c
>>>>>>> @@ -31,6 +31,8 @@
>>>>>>>    #include <linux/sched.h>
>>>>>>>    #include <asm/elf.h>
>>>>>>> +#include "physaddr.h"
>>>>>>> +
>>>>>>>    struct __read_mostly va_alignment va_align = {
>>>>>>>    	.flags = -1,
>>>>>>>    };
>>>>>>> @@ -122,3 +124,14 @@ void arch_pick_mmap_layout(struct mm_struct
>> *mm)
>>>>>>>    		mm->unmap_area = arch_unmap_area_topdown;
>>>>>>>    	}
>>>>>>>    }
>>>>>>> +
>>>>>>> +int valid_phys_addr_range(phys_addr_t addr, size_t count)
>>>>>>> +{
>>>>>>> +	return addr + count <= __pa(high_memory);
>>>>>>> +}
>>>>>>> +
>>>>>>> +int valid_mmap_phys_addr_range(unsigned long pfn, size_t count)
>>>>>>> +{
>>>>>>> +	resource_size_t addr = (pfn << PAGE_SHIFT) + count;
>>>>>>> +	return phys_addr_valid(addr);
>>>>>>> +}
>>>>>> --
>>>>>> To unsubscribe from this list: send the line "unsubscribe
>> linux-kernel" in
>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>> Please read the FAQ at  http://www.tux.org/lkml/
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe
>> linux-kernel" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
