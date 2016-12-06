Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 41C6A6B0069
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 14:19:09 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id j128so567300498pfg.4
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 11:19:09 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w17si20540434pgh.156.2016.12.06.11.19.08
        for <linux-mm@kvack.org>;
        Tue, 06 Dec 2016 11:19:08 -0800 (PST)
Date: Tue, 6 Dec 2016 19:18:20 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCHv4 08/10] mm/kasan: Switch to using __pa_symbol and
 lm_alias
Message-ID: <20161206191820.GK24177@leverpostej>
References: <1480445729-27130-1-git-send-email-labbott@redhat.com>
 <1480445729-27130-9-git-send-email-labbott@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1480445729-27130-9-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com

On Tue, Nov 29, 2016 at 10:55:27AM -0800, Laura Abbott wrote:
> @@ -94,7 +94,7 @@ static void __init zero_pud_populate(pgd_t *pgd, unsigned long addr,
>  
>  			pud_populate(&init_mm, pud, kasan_zero_pmd);

We also need to lm_alias()-ify kasan_zero_pmd here, or we'll get a
stream of warnings at boot (example below).

I should have spotted that. :/

With that fixed up, I'm able to boot Juno with both KASAN_INLINE and
DEBUG_VIRTUAL, without issued. With that, my previous Reviewed-by and Tested-by
stand.

Thanks,
Mark.

---->8----

[    0.000000] virt_to_phys used for non-linear address :ffff20000a367000
[    0.000000] ------------[ cut here ]------------
[    0.000000] WARNING: CPU: 0 PID: 0 at arch/arm64/mm/physaddr.c:13 __virt_to_phys+0x48/0x68
[    0.000000] Modules linked in:
[    0.000000] 
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.9.0-rc6-00012-gdcc0162-dirty #13
[    0.000000] Hardware name: ARM Juno development board (r1) (DT)
[    0.000000] task: ffff200009ec2200 task.stack: ffff200009eb0000
[    0.000000] PC is at __virt_to_phys+0x48/0x68
[    0.000000] LR is at __virt_to_phys+0x48/0x68
[    0.000000] pc : [<ffff2000080af310>] lr : [<ffff2000080af310>] pstate: 600000c5
[    0.000000] sp : ffff200009eb3c80
[    0.000000] x29: ffff200009eb3c80 x28: ffff20000abdd000 
[    0.000000] x27: ffff200009ce1000 x26: ffff047fffffffff 
[    0.000000] x25: ffff200009ce1000 x24: ffff20000a366100 
[    0.000000] x23: ffff048000000000 x22: ffff20000a366000 
[    0.000000] x21: ffff040080000000 x20: ffff040040000000 
[    0.000000] x19: ffff20000a367000 x18: 000000000000005c 
[    0.000000] x17: 00000009ffec20e0 x16: 00000000fefff4b0 
[    0.000000] x15: ffffffffffffffff x14: 302b646d705f6f72 
[    0.000000] x13: 657a5f6e6173616b x12: 2820303030373633 
[    0.000000] x11: ffff20000a376ca0 x10: 0000000000000010 
[    0.000000] x9 : 646461207261656e x8 : 696c2d6e6f6e2072 
[    0.000000] x7 : 6f66206465737520 x6 : ffff20000a3741e5 
[    0.000000] x5 : 1fffe4000146ee0e x4 : 1fffe400013de704 
[    0.000000] x3 : 1fffe400013d6003 x2 : 1fffe400013d6003 
[    0.000000] x1 : 0000000000000000 x0 : 0000000000000056 
[    0.000000] 
[    0.000000] ---[ end trace 0000000000000000 ]---
[    0.000000] Call trace:
[    0.000000] Exception stack(0xffff200009eb3a50 to 0xffff200009eb3b80)
[    0.000000] 3a40:                                   ffff20000a367000 0001000000000000
[    0.000000] 3a60: ffff200009eb3c80 ffff2000080af310 00000000600000c5 000000000000003d
[    0.000000] 3a80: ffff200009ce1000 ffff2000081c4720 0000000041b58ab3 ffff200009c6cd98
[    0.000000] 3aa0: ffff2000080818a0 ffff20000a366000 ffff048000000000 ffff20000a366100
[    0.000000] 3ac0: ffff200009ce1000 ffff047fffffffff ffff200009ce1000 ffff20000abdd000
[    0.000000] 3ae0: ffff0400013e3ccf ffff20000a3766c0 0000000000000000 0000000000000000
[    0.000000] 3b00: ffff200009eb3c80 ffff200009eb3c80 ffff200009eb3c40 00000000ffffffc8
[    0.000000] 3b20: ffff200009eb3b50 ffff2000082cbd3c ffff200009eb3c80 ffff200009eb3c80
[    0.000000] 3b40: ffff200009eb3c40 00000000ffffffc8 0000000000000056 0000000000000000
[    0.000000] 3b60: 1fffe400013d6003 1fffe400013d6003 1fffe400013de704 1fffe4000146ee0e
[    0.000000] [<ffff2000080af310>] __virt_to_phys+0x48/0x68
[    0.000000] [<ffff200009d734e8>] zero_pud_populate+0x88/0x138
[    0.000000] [<ffff200009d736f8>] kasan_populate_zero_shadow+0x160/0x18c
[    0.000000] [<ffff200009d5a048>] kasan_init+0x1f8/0x408
[    0.000000] [<ffff200009d54000>] setup_arch+0x314/0x948
[    0.000000] [<ffff200009d50c64>] start_kernel+0xb4/0x54c
[    0.000000] [<ffff200009d501e0>] __primary_switched+0x64/0x74

[mark@leverpostej:~/src/linux]% uselinaro 15.08 aarch64-linux-gnu-readelf -s vmlinux | grep ffff20000a367000
108184: ffff20000a367000  4096 OBJECT  GLOBAL DEFAULT   25 kasan_zero_pmd

[mark@leverpostej:~/src/linux]% uselinaro 15.08 aarch64-linux-gnu-addr2line -ife vmlinux ffff200009d734e8              
set_pud
/home/mark/src/linux/./arch/arm64/include/asm/pgtable.h:435
__pud_populate
/home/mark/src/linux/./arch/arm64/include/asm/pgalloc.h:47
pud_populate
/home/mark/src/linux/./arch/arm64/include/asm/pgalloc.h:52
zero_pud_populate
/home/mark/src/linux/mm/kasan/kasan_init.c:95

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
