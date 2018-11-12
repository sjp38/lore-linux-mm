Return-Path: <linux-kernel-owner@vger.kernel.org>
Content-Type: text/plain;
        charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.0 \(3445.100.39\))
Subject: Re: [PATCH] efi: permit calling efi_mem_reserve_persistent from
 atomic context
From: Qian Cai <cai@gmx.us>
In-Reply-To: <trinity-d366cf7f-4a38-4193-a636-b695d34d6c47-1541817914119@msvc-mesg-gmx024>
Date: Sun, 11 Nov 2018 21:45:48 -0500
Content-Transfer-Encoding: 8BIT
Message-Id: <E591C777-E2A6-4624-ABCE-C08251F7484A@gmx.us>
References: <20181108180511.30239-1-ard.biesheuvel@linaro.org>
 <trinity-d366cf7f-4a38-4193-a636-b695d34d6c47-1541817914119@msvc-mesg-gmx024>
Sender: linux-kernel-owner@vger.kernel.org
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-mm@kvack.org, linux-efi@vger.kernel.org, will.deacon@arm.com, linux kernel <linux-kernel@vger.kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>



> On Nov 9, 2018, at 9:45 PM, Qian Cai <cai@gmx.us> wrote:
> 
> 
> On 11/8/18 at 1:05 PM, Ard Biesheuvel wrote:
> 
>> Currently, efi_mem_reserve_persistent() may not be called from atomic
>> context, since both the kmalloc() call and the memremap() call may
>> sleep.
>> 
>> The kmalloc() call is easy enough to fix, but the memremap() call
>> needs to be moved into an init hook since we cannot control the
>> memory allocation behavior of memremap() at the call site.
>> 
>> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
>> ---
>> drivers/firmware/efi/efi.c | 31 +++++++++++++++++++------------
>> 1 file changed, 19 insertions(+), 12 deletions(-)
>> 
>> diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
>> index 249eb70691b0..cfc876e0b67b 100644
>> --- a/drivers/firmware/efi/efi.c
>> +++ b/drivers/firmware/efi/efi.c
>> @@ -963,36 +963,43 @@ bool efi_is_table_address(unsigned long phys_addr)
>> }
>> 
>> static DEFINE_SPINLOCK(efi_mem_reserve_persistent_lock);
>> +static struct linux_efi_memreserve *efi_memreserve_root __ro_after_init;
>> 
>> int efi_mem_reserve_persistent(phys_addr_t addr, u64 size)
>> {
>> -	struct linux_efi_memreserve *rsv, *parent;
>> +	struct linux_efi_memreserve *rsv;
>> 
>> -	if (efi.mem_reserve == EFI_INVALID_TABLE_ADDR)
>> +	if (!efi_memreserve_root)
>> 		return -ENODEV;
>> 
>> -	rsv = kmalloc(sizeof(*rsv), GFP_KERNEL);
>> +	rsv = kmalloc(sizeof(*rsv), GFP_ATOMIC);
>> 	if (!rsv)
>> 		return -ENOMEM;
>> 
>> -	parent = memremap(efi.mem_reserve, sizeof(*rsv), MEMREMAP_WB);
>> -	if (!parent) {
>> -		kfree(rsv);
>> -		return -ENOMEM;
>> -	}
>> -
>> 	rsv->base = addr;
>> 	rsv->size = size;
>> 
>> 	spin_lock(&efi_mem_reserve_persistent_lock);
>> -	rsv->next = parent->next;
>> -	parent->next = __pa(rsv);
>> +	rsv->next = efi_memreserve_root->next;
>> +	efi_memreserve_root->next = __pa(rsv);
>> 	spin_unlock(&efi_mem_reserve_persistent_lock);
>> 
>> -	memunmap(parent);
>> +	return 0;
>> +}
>> 
>> +static int __init efi_memreserve_root_init(void)
>> +{
>> +	if (efi.mem_reserve == EFI_INVALID_TABLE_ADDR)
>> +		return -ENODEV;
>> +
>> +	efi_memreserve_root = memremap(efi.mem_reserve,
>> +				       sizeof(*efi_memreserve_root),
>> +				       MEMREMAP_WB);
>> +	if (!efi_memreserve_root)
>> +		return -ENOMEM;
>> 	return 0;
>> }
>> +early_initcall(efi_memreserve_root_init);
>> 
>> #ifdef CONFIG_KEXEC
>> static int update_efi_random_seed(struct notifier_block *nb,
>> -- 
>> 2.19.1
> BTW, I won’t be able to apply this patch on top of this series [1]. After applied that series, the original BUG sleep from atomic is gone as well as two other GIC warnings. Do you think a new patch is needed here?
> 
> [1] https://www.spinics.net/lists/arm-kernel/msg685751.html
OK, I was able to apply this patch on top of latest mainline (ccda4af0f4b9)
which also include one patch (1/6) from the above series,

However, the efi-related patches from the series (4/6, 5/6, and 6/6) are no
longer able to be cleanly applied. 

As the results, the above patch did fix the original BUG: sleep from atomic,
but it introduces 2 new warnings.

[    0.000000] WARNING: CPU: 0 PID: 0 at drivers/irqchip/irq-gic-v3-its.c:1696 its_init+0x494/0x7e8
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.20.0-rc2+ #11
[    0.000000] pstate: 00000085 (nzcv daIf -PAN -UAO)
[    0.000000] pc : its_init+0x494/0x7e8
[    0.000000] lr : its_init+0x490/0x7e8
[    0.000000] sp : ffff20000a0c7a60
[    0.000000] x29: ffff20000a0c7a60 x28: 1fffe40001418f6e 
[    0.000000] x27: ffff20000a1061a8 x26: ffff8016c0fb0000 
[    0.000000] x25: ffff20000a3d2300 x24: ffff20000c542000 
[    0.000000] x23: 00000016c0fb0000 x22: ffff20000a1061a8 
[    0.000000] x21: 1fffe40001418f5e x20: ffff20000c542fa0 
[    0.000000] x19: ffff2000091c1be0 x18: 000000000000003f 
[    0.000000] x17: 00000000001bb6ad x16: 0000000000000000 
[    0.000000] x15: 0000000000007fff x14: 6166306336314020 
[    0.000000] x13: 736e6f697463656c x12: ffff1002d81f8000 
[    0.000000] x11: 1ffff002d81f7fff x10: ffff1002d81f7fff 
[    0.000000] x9 : 0000000000000000 x8 : ffff8016c0fc0000 
[    0.000000] x7 : a2a2a2a2a2a2a2a2 x6 : ffff8016c0fbffff 
[    0.000000] x5 : ffff1002d81f8000 x4 : dfff200000000000 
[    0.000000] x3 : 000000000000003f x2 : 000000000000ffff 
[    0.000000] x1 : 0000000000010000 x0 : 00000000ffffffed 
[    0.000000] Call trace:
[    0.000000]  its_init+0x494/0x7e8
[    0.000000]  gic_init_bases+0x2c0/0x2e0
[    0.000000]  gic_acpi_init+0x180/0x2ac
[    0.000000]  acpi_match_madt+0x5c/0x98
[    0.000000]  acpi_table_parse_entries_array+0x1e8/0x2ec
[    0.000000]  acpi_table_parse_entries+0xd8/0x10c
[    0.000000]  acpi_table_parse_madt+0x44/0x54
[    0.000000]  __acpi_probe_device_table+0xa8/0x10c
[    0.000000]  irqchip_init+0x38/0x40
[    0.000000]  init_IRQ+0xa0/0xdc
[    0.000000]  start_kernel+0x3b8/0x5a8
[    0.000000] irq event stamp: 0
[    0.000000] hardirqs last  enabled at (0): [<0000000000000000>]           (null)
[    0.000000] hardirqs last disabled at (0): [<0000000000000000>]           (null)
[    0.000000] softirqs last  enabled at (0): [<0000000000000000>]           (null)
[    0.000000] softirqs last disabled at (0): [<0000000000000000>]           (null)
[    0.000000] ---[ end trace 598902d30712b79b ]---
[    0.000000] GICv3: using LPI property table @0x00000016c0fb0000
[    0.000000] ITS: Using DirectLPI for VPE invalidation
[    0.000000] ITS: Enabling GICv4 support
[    0.000000] WARNING: CPU: 0 PID: 0 at drivers/irqchip/irq-gic-v3-its.c:2096 its_cpu_init_lpis+0x400/0x428
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G        W         4.20.0-rc2+ #11
[    0.000000] pstate: 00000085 (nzcv daIf -PAN -UAO)
[    0.000000] pc : its_cpu_init_lpis+0x400/0x428
[    0.000000] lr : its_cpu_init_lpis+0x3fc/0x428
[    0.000000] sp : ffff20000a0c7a30
[    0.000000] x29: ffff20000a0c7a30 x28: ffff2000095d8000 
[    0.000000] x27: ffff20000a0f9848 x26: ffff20000c600000 
[    0.000000] x25: ffff2000095d85e0 x24: ffff20000c542000 
[    0.000000] x23: ffff20000a0c7ac0 x22: ffff7fe005b03f00 
[    0.000000] x21: ffff20000c542fa0 x20: 1fffe40001418f54 
[    0.000000] x19: 00000016c0fc0000 x18: 000000000000003f 
[    0.000000] x17: 0000000000000000 x16: ffff20000a10efc0 
[    0.000000] x15: 0000000000007fff x14: ffff20000992701c 
[    0.000000] x13: ffff20000991fafc x12: ffff040001418e0b 
[    0.000000] x11: 1fffe40001418e0a x10: ffff040001418e0a 
[    0.000000] x9 : dfff200000000000 x8 : dfff200000000000 
[    0.000000] x7 : dfff200000000000 x6 : 00000000f2f2f204 
[    0.000000] x5 : 00000000f1f1f1f1 x4 : dfff200000000000 
[    0.000000] x3 : 0000000000000010 x2 : 000000000000ffff 
[    0.000000] x1 : 0000000000010000 x0 : 00000000ffffffed 
[    0.000000] Call trace:
[    0.000000]  its_cpu_init_lpis+0x400/0x428
[    0.000000]  its_cpu_init+0x12c/0x290
[    0.000000]  gic_init_bases+0x2c4/0x2e0
[    0.000000]  gic_acpi_init+0x180/0x2ac
[    0.000000]  acpi_match_madt+0x5c/0x98
[    0.000000]  acpi_table_parse_entries_array+0x1e8/0x2ec
[    0.000000]  acpi_table_parse_entries+0xd8/0x10c
[    0.000000]  acpi_table_parse_madt+0x44/0x54
[    0.000000]  __acpi_probe_device_table+0xa8/0x10c
[    0.000000]  irqchip_init+0x38/0x40
[    0.000000]  init_IRQ+0xa0/0xdc
[    0.000000]  start_kernel+0x3b8/0x5a8
[    0.000000] irq event stamp: 0
[    0.000000] hardirqs last  enabled at (0): [<0000000000000000>]           (null)
[    0.000000] hardirqs last disabled at (0): [<0000000000000000>]           (null)
[    0.000000] softirqs last  enabled at (0): [<0000000000000000>]           (null)
[    0.000000] softirqs last disabled at (0): [<0000000000000000>]           (null)
[    0.000000] ---[ end trace 598902d30712b79c ]---
