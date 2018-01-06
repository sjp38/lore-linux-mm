Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1AF406B04A9
	for <linux-mm@kvack.org>; Sat,  6 Jan 2018 04:49:14 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id n62so6644022iod.17
        for <linux-mm@kvack.org>; Sat, 06 Jan 2018 01:49:14 -0800 (PST)
Received: from huawei.com ([45.249.212.35])
        by mx.google.com with ESMTPS id 24si5613477iol.258.2018.01.06.01.49.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 06 Jan 2018 01:49:12 -0800 (PST)
Subject: Re: [RFC patch] ioremap: don't set up huge I/O mappings when
 p4d/pud/pmd is zero
References: <1514460261-65222-1-git-send-email-guohanjun@huawei.com>
 <1515193319.2108.24.camel@hpe.com>
From: Hanjun Guo <guohanjun@huawei.com>
Message-ID: <e0fa1b52-86f5-687e-46b3-78ddd03565d8@huawei.com>
Date: Sat, 6 Jan 2018 17:46:58 +0800
MIME-Version: 1.0
In-Reply-To: <1515193319.2108.24.camel@hpe.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kani, Toshi" <toshi.kani@hpe.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linuxarm@huawei.com" <linuxarm@huawei.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "wxf.wang@hisilicon.com" <wxf.wang@hisilicon.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mark.rutland@arm.com" <mark.rutland@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "will.deacon@arm.com" <will.deacon@arm.com>, "Hocko, Michal" <MHocko@suse.com>, "hanjun.guo@linaro.org" <hanjun.guo@linaro.org>

On 2018/1/6 6:15, Kani, Toshi wrote:
> On Thu, 2017-12-28 at 19:24 +0800, Hanjun Guo wrote:
>> From: Hanjun Guo <hanjun.guo@linaro.org>
>>
>> When we using iounmap() to free the 4K mapping, it just clear the PTEs
>> but leave P4D/PUD/PMD unchanged, also will not free the memory of page
>> tables.
>>
>> This will cause issues on ARM64 platform (not sure if other archs have
>> the same issue) for this case:
>>
>> 1. ioremap a 4K size, valid page table will build,
>> 2. iounmap it, pte0 will set to 0;
>> 3. ioremap the same address with 2M size, pgd/pmd is unchanged,
>>    then set the a new value for pmd;
>> 4. pte0 is leaked;
>> 5. CPU may meet exception because the old pmd is still in TLB,
>>    which will lead to kernel panic.
>>
>> Fix it by skip setting up the huge I/O mappings when p4d/pud/pmd is
>> zero.
> 
> Hi Hanjun,
> 
> I tested the above steps on my x86 box, but was not able to reproduce
> your kernel panic.  On x86, a 4K vaddr gets allocated from a small
> fragmented free range, whereas a 2MB vaddr is from a larger free range. 
> Their addrs have different alignments (4KB & 2MB) as well.  So, the
> steps did not lead to use a same pmd entry.

Thanks for the testing, I can only reproduce this on my ARM64 platform
which the CPU will cache the PMD in TLB, from my knowledge, only Cortex-A75
will do this, so ARM64 platforms which are not A75 based can't be reproduced
either.

Catalin, Will, I can reproduce this issue in about 3 minutes with following
simplified test case [1], and can trigger panic as [2], could you take a look
as well?

> 
> However, I agree that zero'd pte entries will be leaked when a pmd map
> is set if they are present under the pmd.

Thanks for the confirm.

> 
> I also tested your patch on my x86 box.  Unfortunately, it effectively
> disabled 2MB mappings.  While a 2MB vaddr gets allocated from a larger
> free range, it sill comes from a free range covered by zero'd pte
> entries.  So, it ends up with 4KB mappings with your changes.
> 
> I think we need to come up with other approach.

Yes, As I said in my patch, this is just RFC, comments are welcomed :)

[1]:
#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/random.h>
#include <asm/io.h>


void pcie_io_remap_test(u32 times_ms)
{
	u64 phy_addr = 0xd0000000;
	unsigned long timeout = jiffies + msecs_to_jiffies(times_ms);
	int rand_type;
	u32 mem_size;
	void *vir_addr;

	do {
		get_random_bytes(&rand_type, sizeof(u32));

		rand_type %= 6;
		switch (rand_type) {
		case 0:
			mem_size = 0x1000;
			break;
		case 1:
			mem_size = 0x4000;
			break;
		case 2:
			mem_size = 0x200000;
			break;
		case 3:
			mem_size = 0x300000;
			break;
		case 4:
			mem_size = 0x400;
			break;
		case 5:
			mem_size = 0x400000;
			break;
		default:
			mem_size = 0x400;
			break;
		}

		vir_addr = ioremap(phy_addr, mem_size);
		readl(vir_addr);

		iounmap(vir_addr);
		schedule();

	} while (time_before(jiffies, timeout));
}

[2]:

[ 2062.300139] Unable to handle kernel paging request at virtual address ffff000018600000
[ 2062.300139] Unable to handle kernel paging request at virtual address ffff000018600000
[ 2062.327051] Mem abort info:
[ 2062.327051] Mem abort info:
[ 2062.337134]   Exception class = DABT (current EL), IL = 32 bits
[ 2062.337134]   Exception class = DABT (current EL), IL = 32 bits
[ 2062.354614]   SET = 0, FnV = 0
[ 2062.354614]   SET = 0, FnV = 0
[ 2062.363818]   EA = 0, S1PTW = 0
[ 2062.363818]   EA = 0, S1PTW = 0
[ 2062.373131] Data abort info:
[ 2062.373131] Data abort info:
[ 2062.381671]   ISV = 0, ISS = 0x00000007
[ 2062.381671]   ISV = 0, ISS = 0x00000007
[ 2062.393099]   CM = 0, WnR = 0
[ 2062.393099]   CM = 0, WnR = 0
[ 2062.402155] swapper pgtable: 4k pages, 48-bit VAs, pgd = ffff000009cf6000
[ 2062.402155] swapper pgtable: 4k pages, 48-bit VAs, pgd = ffff000009cf6000
[ 2062.421477] [ffff000018600000] *pgd=00000021ffffe003, *pud=00000021ffffd003, *pmd=00e80000d0000705
[ 2062.421477] [ffff000018600000] *pgd=00000021ffffe003, *pud=00000021ffffd003, *pmd=00e80000d0000705
[ 2062.447913] Internal error: Oops: 96000007 [#1] SMP
[ 2062.447913] Internal error: Oops: 96000007 [#1] SMP
[ 2062.540141] CPU: 1 PID: 2149 Comm: unibsp.out Tainted: P           OEL  4.14.0 #1
[ 2062.540141] CPU: 1 PID: 2149 Comm: unibsp.out Tainted: P           OEL  4.14.0 #1
[ 2062.560853] task: ffff8021e6f8a100 task.stack: ffff000010aa0000
[ 2062.560853] task: ffff8021e6f8a100 task.stack: ffff000010aa0000
[ 2062.580070] PC is at pcie_io_remap_test+0x9c/0x228
[ 2062.580070] PC is at pcie_io_remap_test+0x9c/0x228
[ 2062.597307] LR is at pcie_io_remap_test+0x9c/0x228
[ 2062.597307] LR is at pcie_io_remap_test+0x9c/0x228
[ 2062.613720] pc : [<ffff0000010a5e74>] lr : [<ffff0000010a5e74>] pstate: 60400149
[ 2062.613720] pc : [<ffff0000010a5e74>] lr : [<ffff0000010a5e74>] pstate: 60400149
[ 2062.634012] sp : ffff000010aa3bb0
[ 2062.634012] sp : ffff000010aa3bb0
[ 2062.643202] x29: ffff000010aa3bb0 x28: ffff8021e6f8a100
[ 2062.643202] x29: ffff000010aa3bb0 x28: ffff8021e6f8a100
[ 2062.658122] x27: ffff000008c91000 x26: 000000000000001d
[ 2062.658122] x27: ffff000008c91000 x26: 000000000000001d
[ 2062.672948] x25: 0000000000000124 x24: 0000000000000003
[ 2062.672948] x25: 0000000000000124 x24: 0000000000000003
[ 2062.687841] x23: ffff0000093a9c88 x22: ffff0000010a88f0
[ 2062.687841] x23: ffff0000093a9c88 x22: ffff0000010a88f0
[ 2062.702658] x21: 000000002aaaaaab x20: ffff0000093a6a80
[ 2062.702658] x21: 000000002aaaaaab x20: ffff0000093a6a80
[ 2062.717535] x19: 0000000100085de7 x18: 0000000000000040
[ 2062.717535] x19: 0000000100085de7 x18: 0000000000000040
[ 2062.732292] x17: 0000000098b401b6 x16: 00000000af415618
[ 2062.732292] x17: 0000000098b401b6 x16: 00000000af415618
[ 2062.747048] x15: 000000000eed33f7 x14: 0140000000000000
[ 2062.747048] x15: 000000000eed33f7 x14: 0140000000000000
[ 2062.761863] x13: ffff0000093bd000 x12: 0000000000000000
[ 2062.761863] x13: ffff0000093bd000 x12: 0000000000000000
[ 2062.776589] x11: 0400000000000001 x10: 0000000000000001
[ 2062.776589] x11: 0400000000000001 x10: 0000000000000001
[ 2062.791482] x9 : 0040000000000001 x8 : ffff008018600000
[ 2062.791482] x9 : 0040000000000001 x8 : ffff008018600000
[ 2062.806166] x7 : ffff8021ffffd620 x6 : ffff000058600000
[ 2062.806166] x7 : ffff8021ffffd620 x6 : ffff000058600000
[ 2062.820842] x5 : ffff000018800000 x4 : 0000000000000000
[ 2062.820842] x5 : ffff000018800000 x4 : 0000000000000000
[ 2062.835538] x3 : 00e8000000000707 x2 : 00e8000000000707
[ 2062.835538] x3 : 00e8000000000707 x2 : 00e8000000000707
[ 2062.850273] x1 : 00000000d0000000 x0 : ffff000018600000
[ 2062.850273] x1 : 00000000d0000000 x0 : ffff000018600000
[ 2062.865258] Process unibsp.out (pid: 2149, stack limit = 0xffff000010aa0000)
[ 2062.865258] Process unibsp.out (pid: 2149, stack limit = 0xffff000010aa0000)
[ 2062.884578] Call trace:
[ 2062.884578] Call trace:
[ 2062.891581] Exception stack(0xffff000010aa3a70 to 0xffff000010aa3bb0)
[ 2062.891581] Exception stack(0xffff000010aa3a70 to 0xffff000010aa3bb0)
[ 2062.909389] 3a60:                                   ffff000018600000 00000000d0000000
[ 2062.909389] 3a60:                                   ffff000018600000 00000000d0000000
[ 2062.930931] 3a80: 00e8000000000707 00e8000000000707 0000000000000000 ffff000018800000
[ 2062.930931] 3a80: 00e8000000000707 00e8000000000707 0000000000000000 ffff000018800000
[ 2062.952554] 3aa0: ffff000058600000 ffff8021ffffd620 ffff008018600000 0040000000000001
[ 2062.952554] 3aa0: ffff000058600000 ffff8021ffffd620 ffff008018600000 0040000000000001
[ 2062.974189] 3ac0: 0000000000000001 0400000000000001 0000000000000000 ffff0000093bd000
[ 2062.974189] 3ac0: 0000000000000001 0400000000000001 0000000000000000 ffff0000093bd000
[ 2062.995645] 3ae0: 0140000000000000 000000000eed33f7 00000000af415618 0000000098b401b6
[ 2062.995645] 3ae0: 0140000000000000 000000000eed33f7 00000000af415618 0000000098b401b6
[ 2063.017204] 3b00: 0000000000000040 0000000100085de7 ffff0000093a6a80 000000002aaaaaab
[ 2063.017204] 3b00: 0000000000000040 0000000100085de7 ffff0000093a6a80 000000002aaaaaab
[ 2063.038889] 3b20: ffff0000010a88f0 ffff0000093a9c88 0000000000000003 0000000000000124
[ 2063.038889] 3b20: ffff0000010a88f0 ffff0000093a9c88 0000000000000003 0000000000000124
[ 2063.060433] 3b40: 000000000000001d ffff000008c91000 ffff8021e6f8a100 ffff000010aa3bb0
[ 2063.060433] 3b40: 000000000000001d ffff000008c91000 ffff8021e6f8a100 ffff000010aa3bb0
[ 2063.081744] 3b60: ffff0000010a5e74 ffff000010aa3bb0 ffff0000010a5e74 0000000060400149
[ 2063.081744] 3b60: ffff0000010a5e74 ffff000010aa3bb0 ffff0000010a5e74 0000000060400149
[ 2063.102974] 3b80: ffff000010aa3bb0 ffff0000010a5e74 0001000000000000 ffff0000093a6a80
[ 2063.102974] 3b80: ffff000010aa3bb0 ffff0000010a5e74 0001000000000000 ffff0000093a6a80
[ 2063.124379] 3ba0: ffff000010aa3bb0 ffff0000010a5e74
[ 2063.124379] 3ba0: ffff000010aa3bb0 ffff0000010a5e74
[ 2063.138959] [<ffff0000010a5e74>] pcie_io_remap_test+0x9c/0x228
[ 2063.138959] [<ffff0000010a5e74>] pcie_io_remap_test+0x9c/0x228
[ 2063.159168] [<ffff000000d38700>] MCSS_ioctl+0x118/0x218 [unibsp]
[ 2063.159168] [<ffff000000d38700>] MCSS_ioctl+0x118/0x218 [unibsp]
[ 2063.176220] [<ffff0000082c16bc>] do_vfs_ioctl+0xc4/0x7a4
[ 2063.176220] [<ffff0000082c16bc>] do_vfs_ioctl+0xc4/0x7a4
[ 2063.190966] [<ffff0000082c1e2c>] SyS_ioctl+0x90/0xa4
[ 2063.190966] [<ffff0000082c1e2c>] SyS_ioctl+0x90/0xa4
[ 2063.204706] Exception stack(0xffff000010aa3ec0 to 0xffff000010aa4000)
[ 2063.204706] Exception stack(0xffff000010aa3ec0 to 0xffff000010aa4000)
[ 2063.222471] 3ec0: 0000000000000003 00000000000bc006 0000ffffd8c3d698 0000000000000010
[ 2063.222471] 3ec0: 0000000000000003 00000000000bc006 0000ffffd8c3d698 0000000000000010
[ 2063.243921] 3ee0: 6572ffffffffffff 0000000000000000 0000ffffd8c3d6aa 65725f6f695f6569
[ 2063.243921] 3ee0: 6572ffffffffffff 0000000000000000 0000ffffd8c3d6aa 65725f6f695f6569
[ 2063.265403] 3f00: 000000000000001d 2f2f2f2f2f34feff 0000000000000000 0000ffff8310dcb0
[ 2063.265403] 3f00: 000000000000001d 2f2f2f2f2f34feff 0000000000000000 0000ffff8310dcb0
[ 2063.286856] 3f20: 0000000000000000 0000000000000509 0000ffff82ea2e64 0000000000000000
[ 2063.286856] 3f20: 0000000000000000 0000000000000509 0000ffff82ea2e64 0000000000000000
[ 2063.308332] 3f40: 0000ffff82f60680 0000000000415540 0000000000000000 0000ffffd8c3d960
[ 2063.308332] 3f40: 0000ffff82f60680 0000000000415540 0000000000000000 0000ffffd8c3d960
[ 2063.329809] 3f60: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
[ 2063.329809] 3f60: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
[ 2063.351309] 3f80: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
[ 2063.351309] 3f80: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
[ 2063.372763] 3fa0: 0000000000000000 0000ffffd8c3d640 0000000000401b98 0000ffffd8c3d640
[ 2063.372763] 3fa0: 0000000000000000 0000ffffd8c3d640 0000000000401b98 0000ffffd8c3d640
[ 2063.394311] 3fc0: 0000ffff82f6068c 0000000080000000 0000000000000003 000000000000001d
[ 2063.394311] 3fc0: 0000ffff82f6068c 0000000080000000 0000000000000003 000000000000001d
[ 2063.415922] 3fe0: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
[ 2063.415922] 3fe0: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
[ 2063.437650] [<ffff0000080837b0>] el0_svc_naked+0x24/0x28
[ 2063.437650] [<ffff0000080837b0>] el0_svc_naked+0x24/0x28
[ 2063.452308] Code: d280e0e2 d2ba0000 f2e01d02 95bfdf0d (b9400001)
[ 2063.452308] Code: d280e0e2 d2ba0000 f2e01d02 95bfdf0d (b9400001)
[ 2063.469741] ---[ end trace 36d530c5bf5fea7d ]---
[ 2063.469741] ---[ end trace 36d530c5bf5fea7d ]---
[ 2063.482519] Kernel panic - not syncing: Fatal exception
[ 2063.482519] Kernel panic - not syncing: Fatal exception
[ 2063.497131] SMP: stopping secondary CPUs
[ 2063.497131] SMP: stopping secondary CPUs
[ 2063.508593] Kernel Offset: disabled
[ 2063.508593] Kernel Offset: disabled
[ 2063.518572] CPU features: 0x000a18
[ 2063.518572] CPU features: 0x000a18
[ 2063.528209] Memory Limit: none
[ 2063.528209] Memory Limit: none
[ 2063.537067] ---[ end Kernel panic - not syncing: Fatal exception
[ 2063.537067] ---[ end Kernel panic - not syncing: Fatal exception


Thanks
Hanjun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
