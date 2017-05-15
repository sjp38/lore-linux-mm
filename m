Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 826186B02EE
	for <linux-mm@kvack.org>; Mon, 15 May 2017 04:47:20 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id n75so19585016pfh.0
        for <linux-mm@kvack.org>; Mon, 15 May 2017 01:47:20 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id d8si10264937pgn.60.2017.05.15.01.47.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 15 May 2017 01:47:19 -0700 (PDT)
Message-ID: <59196AB1.1090106@huawei.com>
Date: Mon, 15 May 2017 16:45:37 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3] arm64: fix the overlap between the kernel image and
 vmalloc address
References: <1494387440-51703-1-git-send-email-zhongjiang@huawei.com> <20170510085503.q374eqnt6f6rc2tv@localhost>
In-Reply-To: <20170510085503.q374eqnt6f6rc2tv@localhost>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: ard.biesheuvel@linaro.org, mark.rutland@arm.com, labbott@redhat.com, linux-arm-kernel@lists.infradead.org, tanxiaojun@huawei.com, linux-mm@kvack.org, Will Deacon <will.deacon@arm.com>, Peter Zijlstra <peterz@infradead.org>, thgarnie@google.com, tglx@linutronix.de, mingo@kernel.org

ping,

I have sent various version to solve the issue.  Unfortunately, it fails to receive
any comments for a long time. 

Thanks
zhongjiang
On 2017/5/10 16:55, Catalin Marinas wrote:
> Given that there are a lot more mm changes than arm64, cc'ing linux-mm
> as well.
>
> Patch below:
>
> On Wed, May 10, 2017 at 11:37:20AM +0800, zhongjiang wrote:
>> Recently, xiaojun report the following issue.
>>
>> [ 4544.984139] Unable to handle kernel paging request at virtual address ffff804392800000
>> [ 4544.991995] pgd = ffff80096745f000
>> [ 4544.995369] [ffff804392800000] *pgd=0000000000000000
>> [ 4545.000297] Internal error: Oops: 96000005 [#1] PREEMPT SMP
>> [ 4545.005815] Modules linked in:
>> [ 4545.008843] CPU: 1 PID: 8976 Comm: cat Not tainted 4.11.0-rc6 #1
>> [ 4545.014790] Hardware name: ARM Juno development board (r1) (DT)
>> [ 4545.020653] task: ffff8009753fdb00 task.stack: ffff80097533c000
>> [ 4545.026520] PC is at __memcpy+0x100/0x180
>> [ 4545.030491] LR is at vread+0x144/0x280
>> [ 4545.034202] pc : [<ffff0000083a1000>] lr : [<ffff0000081c126c>] pstate: 20000145
>> [ 4545.041530] sp : ffff80097533fcb0
>> [ 4545.044811] x29: ffff80097533fcb0 x28: ffff800962d24000
>> [ 4545.050074] x27: 0000000000001000 x26: ffff8009753fdb00
>> [ 4545.055337] x25: ffff000008200000 x24: ffff800977801380
>> [ 4545.060600] x23: ffff8009753fdb00 x22: ffff800962d24000
>> [ 4545.065863] x21: 0000000000001000 x20: ffff000008200000
>> [ 4545.071125] x19: 0000000000001000 x18: 0000ffffefa323c0
>> [ 4545.076387] x17: 0000ffffa9c87440 x16: ffff0000081fdfd0
>> [ 4545.081649] x15: 0000ffffa9d01588 x14: 72a77346b2407be7
>> [ 4545.086911] x13: 5299400690000000 x12: b0000001f9001a79
>> [ 4545.092173] x11: 97fc098d91042260 x10: 0000000000000000
>> [ 4545.097435] x9 : 0000000000000000 x8 : 9110626091260021
>> [ 4545.102698] x7 : 0000000000001000 x6 : ffff800962d24000
>> [ 4545.107960] x5 : ffff8009778013b0 x4 : 0000000000000000
>> [ 4545.113222] x3 : 0400000000000001 x2 : 0000000000000f80
>> [ 4545.118484] x1 : ffff804392800000 x0 : ffff800962d24000
>> [ 4545.123745]
>> [ 4545.125220] Process cat (pid: 8976, stack limit = 0xffff80097533c000)
>> [ 4545.131598] Stack: (0xffff80097533fcb0 to 0xffff800975340000)
>> [ 4545.137289] fca0:                                   ffff80097533fd30 ffff000008270f64
>> [ 4545.145049] fcc0: 000000000000e000 000000003956f000 ffff000008f950d0 ffff80097533feb8
>> [ 4545.152809] fce0: 0000000000002000 ffff8009753fdb00 ffff800962d24000 ffff000008e8d3d8
>> [ 4545.160568] fd00: 0000000000001000 ffff000008200000 0000000000001000 ffff800962d24000
>> [ 4545.168327] fd20: 0000000000001000 ffff000008e884a0 ffff80097533fdb0 ffff00000826340c
>> [ 4545.176086] fd40: ffff800976bf2800 fffffffffffffffb 000000003956d000 ffff80097533feb8
>> [ 4545.183846] fd60: 0000000060000000 0000000000000015 0000000000000124 000000000000003f
>> [ 4545.191605] fd80: ffff000008962000 ffff8009753fdb00 ffff8009753fdb00 ffff8009753fdb00
>> [ 4545.199364] fda0: 0000000300000124 0000000000002000 ffff80097533fdd0 ffff0000081fb83c
>> [ 4545.207123] fdc0: 0000000000010000 ffff80097514f900 ffff80097533fe50 ffff0000081fcb28
>> [ 4545.214883] fde0: 0000000000010000 ffff80097514f900 0000000000000000 0000000000000000
>> [ 4545.222642] fe00: ffff80097533fe30 ffff0000081fca1c ffff80097514f900 0000000000000000
>> [ 4545.230401] fe20: 000000003956d000 ffff80097533feb8 ffff80097533fe50 ffff0000081fcb04
>> [ 4545.238160] fe40: 0000000000010000 ffff80097514f900 ffff80097533fe80 ffff0000081fe014
>> [ 4545.245919] fe60: ffff80097514f900 ffff80097514f900 000000003956d000 0000000000010000
>> [ 4545.253678] fe80: 0000000000000000 ffff000008082f30 0000000000000000 0000800977146000
>> [ 4545.261438] fea0: ffffffffffffffff 0000ffffa9c8745c 0000000000000124 0000000008202000
>> [ 4545.269197] fec0: 0000000000000003 000000003956d000 0000000000010000 0000000000000000
>> [ 4545.276956] fee0: 0000000000011011 0000000000000001 0000000000000011 0000000000000002
>> [ 4545.284715] ff00: 000000000000003f 1f3c201f7372686b 00000000ffffffff 0000000000000030
>> [ 4545.292474] ff20: 0000000000000038 0000000000000000 0000ffffa9bcca94 0000ffffa9d01588
>> [ 4545.300233] ff40: 0000000000000000 0000ffffa9c87440 0000ffffefa323c0 0000000000010000
>> [ 4545.307993] ff60: 000000000041a310 000000003956d000 0000000000000003 000000007fffe000
>> [ 4545.315751] ff80: 00000000004088d0 0000000000010000 0000000000000000 0000000000000000
>> [ 4545.323511] ffa0: 0000000000010000 0000ffffefa32690 0000000000404dcc 0000ffffefa32690
>> [ 4545.331270] ffc0: 0000ffffa9c8745c 0000000060000000 0000000000000003 000000000000003f
>> [ 4545.339029] ffe0: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
>> [ 4545.346786] Call trace:
>> [ 4545.349207] Exception stack(0xffff80097533fae0 to 0xffff80097533fc10)
>> [ 4545.355586] fae0: 0000000000001000 0001000000000000 ffff80097533fcb0 ffff0000083a1000
>> [ 4545.363345] fb00: 000000003957c000 ffff80097533fc00 0000000020000145 0000000000000025
>> [ 4545.371105] fb20: ffff800962d24000 ffff000008e8d3d8 0000000000001000 ffff8009753fdb00
>> [ 4545.378864] fb40: 0000000000000000 0000000000000002 ffff80097533fd30 ffff000008082604
>> [ 4545.386623] fb60: 0000000000001000 0001000000000000 ffff80097533fd30 ffff0000083a0a90
>> [ 4545.394382] fb80: ffff800962d24000 ffff804392800000 0000000000000f80 0400000000000001
>> [ 4545.402140] fba0: 0000000000000000 ffff8009778013b0 ffff800962d24000 0000000000001000
>> [ 4545.409899] fbc0: 9110626091260021 0000000000000000 0000000000000000 97fc098d91042260
>> [ 4545.417658] fbe0: b0000001f9001a79 5299400690000000 72a77346b2407be7 0000ffffa9d01588
>> [ 4545.425416] fc00: ffff0000081fdfd0 0000ffffa9c87440
>> [ 4545.430248] [<ffff0000083a1000>] __memcpy+0x100/0x180
>> [ 4545.435253] [<ffff000008270f64>] read_kcore+0x21c/0x3b0
>> [ 4545.440429] [<ffff00000826340c>] proc_reg_read+0x64/0x90
>> [ 4545.445691] [<ffff0000081fb83c>] __vfs_read+0x1c/0x108
>> [ 4545.450779] [<ffff0000081fcb28>] vfs_read+0x80/0x130
>> [ 4545.455696] [<ffff0000081fe014>] SyS_read+0x44/0xa0
>> [ 4545.460528] [<ffff000008082f30>] el0_svc_naked+0x24/0x28
>> [ 4545.465790] Code: d503201f d503201f d503201f d503201f (a8c12027)
>> [ 4545.471852] ---[ end trace 4d1897f94759f461 ]---
>> [ 4545.476435] note: cat[8976] exited with preempt_count 2
>>
>> I find the issue is introduced when applying commit f9040773b7bb
>> ("arm64: move kernel image to base of vmalloc area"). This patch
>> make the kernel image overlap with vmalloc area. It will result in
>> vmalloc area have the huge page table. but the vmalloc_to_page is
>> not realize the change. and the function is public to any arch.
>>
>> I fix it by adding the another kernel image condition in vmalloc_to_page
>> to make it keep the accordance with previous vmalloc mapping.
>>
>> Fixes: f9040773b7bb ("arm64: move kernel image to base of vmalloc area")
>> Reported-by: tan xiaojun <tanxiaojun@huawei.com>
>> Signed-off-by: zhongjiang <zhongjiang@huawei.com>
>> ---
>>  arch/arm64/mm/mmu.c     |  2 +-
>>  include/linux/vmalloc.h |  1 +
>>  mm/vmalloc.c            | 35 ++++++++++++++++++++++++++++-------
>>  3 files changed, 30 insertions(+), 8 deletions(-)
>>
>> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
>> index 0c429ec..2265c39 100644
>> --- a/arch/arm64/mm/mmu.c
>> +++ b/arch/arm64/mm/mmu.c
>> @@ -509,7 +509,7 @@ static void __init map_kernel_segment(pgd_t *pgd, void *va_start, void *va_end,
>>  	vma->addr	= va_start;
>>  	vma->phys_addr	= pa_start;
>>  	vma->size	= size;
>> -	vma->flags	= VM_MAP;
>> +	vma->flags	= VM_KERNEL;
>>  	vma->caller	= __builtin_return_address(0);
>>  
>>  	vm_area_add_early(vma);
>> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
>> index 0328ce0..c9245af 100644
>> --- a/include/linux/vmalloc.h
>> +++ b/include/linux/vmalloc.h
>> @@ -17,6 +17,7 @@
>>  #define VM_ALLOC		0x00000002	/* vmalloc() */
>>  #define VM_MAP			0x00000004	/* vmap()ed pages */
>>  #define VM_USERMAP		0x00000008	/* suitable for remap_vmalloc_range */
>> +#define VM_KERNEL		0x00000010	/* kernel pages */
>>  #define VM_UNINITIALIZED	0x00000020	/* vm_struct is not fully initialized */
>>  #define VM_NO_GUARD		0x00000040      /* don't add guard page */
>>  #define VM_KASAN		0x00000080      /* has allocated kasan shadow memory */
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index 1dda6d8..601d940 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -1967,11 +1967,28 @@ void *vmalloc_32_user(unsigned long size)
>>  EXPORT_SYMBOL(vmalloc_32_user);
>>  
>>  /*
>> + * kernel image overlap with the valloc area in arm64,it
>> + * will make the huge talbe page existence, if we walk the
>> + * all page talbe, it may be result in the panic.
>> + */
>> +static inline struct page *aligned_get_page(char *addr, struct vm_struct *vm)
>> +{
>> +	struct page *p = NULL;
>> +
>> +	if (vm->flags & VM_KERNEL)
>> +		p = virt_to_page(lm_alias(addr));
>> +	else
>> +		p = vmalloc_to_page(addr);
>> +
>> +	return p;
>> +}
>> +
>> +/*
>>   * small helper routine , copy contents to buf from addr.
>>   * If the page is not present, fill zero.
>>   */
>> -
>> -static int aligned_vread(char *buf, char *addr, unsigned long count)
>> +static int aligned_vread(char *buf, char *addr, unsigned long count,
>> +					struct vm_struct *vm)
>>  {
>>  	struct page *p;
>>  	int copied = 0;
>> @@ -1983,7 +2000,7 @@ static int aligned_vread(char *buf, char *addr, unsigned long count)
>>  		length = PAGE_SIZE - offset;
>>  		if (length > count)
>>  			length = count;
>> -		p = vmalloc_to_page(addr);
>> +		p = aligned_get_page(addr, vm);
>>  		/*
>>  		 * To do safe access to this _mapped_ area, we need
>>  		 * lock. But adding lock here means that we need to add
>> @@ -2010,7 +2027,8 @@ static int aligned_vread(char *buf, char *addr, unsigned long count)
>>  	return copied;
>>  }
>>  
>> -static int aligned_vwrite(char *buf, char *addr, unsigned long count)
>> +static int aligned_vwrite(char *buf, char *addr, unsigned long count,
>> +					struct vm_struct *vm)
>>  {
>>  	struct page *p;
>>  	int copied = 0;
>> @@ -2022,7 +2040,7 @@ static int aligned_vwrite(char *buf, char *addr, unsigned long count)
>>  		length = PAGE_SIZE - offset;
>>  		if (length > count)
>>  			length = count;
>> -		p = vmalloc_to_page(addr);
>> +		p = aligned_get_page(addr, vm);
>>  		/*
>>  		 * To do safe access to this _mapped_ area, we need
>>  		 * lock. But adding lock here means that we need to add
>> @@ -2109,7 +2127,7 @@ long vread(char *buf, char *addr, unsigned long count)
>>  		if (n > count)
>>  			n = count;
>>  		if (!(vm->flags & VM_IOREMAP))
>> -			aligned_vread(buf, addr, n);
>> +			aligned_vread(buf, addr, n, vm);
>>  		else /* IOREMAP area is treated as memory hole */
>>  			memset(buf, 0, n);
>>  		buf += n;
>> @@ -2190,7 +2208,7 @@ long vwrite(char *buf, char *addr, unsigned long count)
>>  		if (n > count)
>>  			n = count;
>>  		if (!(vm->flags & VM_IOREMAP)) {
>> -			aligned_vwrite(buf, addr, n);
>> +			aligned_vwrite(buf, addr, n, vm);
>>  			copied++;
>>  		}
>>  		buf += n;
>> @@ -2710,6 +2728,9 @@ static int s_show(struct seq_file *m, void *p)
>>  	if (v->flags & VM_USERMAP)
>>  		seq_puts(m, " user");
>>  
>> +	if (v->flags & VM_KERNEL)
>> +		seq_puts(m, " kernel");
>> +
>>  	if (is_vmalloc_addr(v->pages))
>>  		seq_puts(m, " vpages");
>>  
>> -- 
>> 1.7.12.4
>>
>>
>> _______________________________________________
>> linux-arm-kernel mailing list
>> linux-arm-kernel@lists.infradead.org
>> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> .
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
