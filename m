Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 51BA96B0038
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 07:52:46 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id n137so1507230iod.20
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 04:52:46 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w5sor4091034ita.140.2017.10.17.04.52.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Oct 2017 04:52:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <B8AC3E80E903784988AB3003E3E97330C005CAC2@dggemm510-mbx.china.huawei.com>
References: <20171011082227.20546-5-liuwenliang@huawei.com>
 <201710141957.mbxeZJHB%fengguang.wu@intel.com> <B8AC3E80E903784988AB3003E3E97330C005B9BF@dggemm510-mbx.china.huawei.com>
 <CAKv+Gu98M9PZk3qm0PYC8nQ3zMvLZmNmOn4=hNdFE7NTBuHbgg@mail.gmail.com> <B8AC3E80E903784988AB3003E3E97330C005CAC2@dggemm510-mbx.china.huawei.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Tue, 17 Oct 2017 12:52:44 +0100
Message-ID: <CAKv+Gu-+yOyAC4R_JNNy7NqWiSQ=HwfR=uTr1Ntt=2cDzAZ5nw@mail.gmail.com>
Subject: Re: [PATCH 04/11] Define the virtual space of KASan's shadow region
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liuwenliang (Lamb)" <liuwenliang@huawei.com>
Cc: kbuild test robot <lkp@intel.com>, "kbuild-all@01.org" <kbuild-all@01.org>, "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, "labbott@redhat.com" <labbott@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "cdall@linaro.org" <cdall@linaro.org>, "marc.zyngier@arm.com" <marc.zyngier@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "thgarnie@google.com" <thgarnie@google.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "mingo@kernel.org" <mingo@kernel.org>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "glider@google.com" <glider@google.com>, "dvyukov@google.com" <dvyukov@google.com>, "opendmb@gmail.com" <opendmb@gmail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jiazhenghua <jiazhenghua@huawei.com>, Dailei <dylix.dailei@huawei.com>, Zengweilin <zengweilin@huawei.com>, Heshaoliang <heshaoliang@huawei.com>

On 17 October 2017 at 12:27, Liuwenliang (Lamb) <liuwenliang@huawei.com> wrote:
> On 10/17/2017 12:40 AM, Abbott Liu wrote:
>> Ard Biesheuvel [ard.biesheuvel@linaro.org] wrote
>>This is unnecessary:
>>
>>ldr r1, =TASK_SIZE
>>
>>will be converted to a mov instruction by the assembler if the value of TASK_SIZE fits its 12-bit immediate field.
>>
>>So please remove the whole #ifdef, and just use ldr r1, =xxx
>
> Thanks for your review.
>
> The assembler on my computer don't convert ldr r1,=xxx into mov instruction.


What I said was

'if the value of TASK_SIZE fits its 12-bit immediate field'

and your value of TASK_SIZE is 0xb6e00000, which cannot be decomposed
in the right way.

If you build with KASAN disabled, it will generate a mov instruction instead.



> Here is the objdump for vmlinux:
>
> c0a3b100 <__irq_svc>:
> c0a3b100:       e24dd04c        sub     sp, sp, #76     ; 0x4c
> c0a3b104:       e31d0004        tst     sp, #4
> c0a3b108:       024dd004        subeq   sp, sp, #4
> c0a3b10c:       e88d1ffe        stm     sp, {r1, r2, r3, r4, r5, r6, r7, r8, r9, sl, fp, ip}
> c0a3b110:       e8900038        ldm     r0, {r3, r4, r5}
> c0a3b114:       e28d7030        add     r7, sp, #48     ; 0x30
> c0a3b118:       e3e06000        mvn     r6, #0
> c0a3b11c:       e28d204c        add     r2, sp, #76     ; 0x4c
> c0a3b120:       02822004        addeq   r2, r2, #4
> c0a3b124:       e52d3004        push    {r3}            ; (str r3, [sp, #-4]!)
> c0a3b128:       e1a0300e        mov     r3, lr
> c0a3b12c:       e887007c        stm     r7, {r2, r3, r4, r5, r6}
> c0a3b130:       e1a0972d        lsr     r9, sp, #14
> c0a3b134:       e1a09709        lsl     r9, r9, #14
> c0a3b138:       e5990008        ldr     r0, [r9, #8]
> ---c0a3b13c:       e59f1054        ldr     r1, [pc, #84]   ; c0a3b198 <__irq_svc+0x98>  //ldr r1, =TASK_SIZE
> c0a3b140:       e5891008        str     r1, [r9, #8]
> c0a3b144:       e58d004c        str     r0, [sp, #76]   ; 0x4c
> c0a3b148:       ee130f10        mrc     15, 0, r0, cr3, cr0, {0}
> c0a3b14c:       e58d0048        str     r0, [sp, #72]   ; 0x48
> c0a3b150:       e3a00051        mov     r0, #81 ; 0x51
> c0a3b154:       ee030f10        mcr     15, 0, r0, cr3, cr0, {0}
> ---c0a3b158:       e59f103c        ldr     r1, [pc, #60]   ; c0a3b19c <__irq_svc+0x9c>  //orginal irq_svc also used same instruction
> c0a3b15c:       e1a0000d        mov     r0, sp
> c0a3b160:       e28fe000        add     lr, pc, #0
> c0a3b164:       e591f000        ldr     pc, [r1]
> c0a3b168:       e5998004        ldr     r8, [r9, #4]
> c0a3b16c:       e5990000        ldr     r0, [r9]
> c0a3b170:       e3380000        teq     r8, #0
> c0a3b174:       13a00000        movne   r0, #0
> c0a3b178:       e3100002        tst     r0, #2
> c0a3b17c:       1b000007        blne    c0a3b1a0 <svc_preempt>
> c0a3b180:       e59d104c        ldr     r1, [sp, #76]   ; 0x4c
> c0a3b184:       e59d0048        ldr     r0, [sp, #72]   ; 0x48
> c0a3b188:       ee030f10        mcr     15, 0, r0, cr3, cr0, {0}
> c0a3b18c:       e5891008        str     r1, [r9, #8]
> c0a3b190:       e16ff005        msr     SPSR_fsxc, r5
> c0a3b194:       e8ddffff        ldm     sp, {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, sl, fp, ip, sp, lr, pc}^
> ---c0a3b198:       b6e00000        .word   0xb6e00000   //TASK_SIZE:0xb6e00000
> c0a3b19c:       c0ccccf0        .word   0xc0ccccf0
>
>
>
> Even "ldr r1, =TASK_SIZE"  won't be converted to a mov instruction by some assembler, I also think it is better
> to remove the whole #ifdef because the influence of performance by ldr is very limited.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
