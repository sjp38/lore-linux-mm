Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 471EB6B0038
	for <linux-mm@kvack.org>; Sun, 22 Oct 2017 08:18:50 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id e123so15713395oig.14
        for <linux-mm@kvack.org>; Sun, 22 Oct 2017 05:18:50 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [45.249.212.187])
        by mx.google.com with ESMTPS id r1si1611580otr.486.2017.10.22.05.18.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 22 Oct 2017 05:18:48 -0700 (PDT)
From: "Liuwenliang (Lamb)" <liuwenliang@huawei.com>
Subject: Re: [PATCH 04/11] Define the virtual space of KASan's shadow region
Date: Sun, 22 Oct 2017 12:12:58 +0000
Message-ID: <B8AC3E80E903784988AB3003E3E97330C005CED4@dggemm510-mbx.china.huawei.com>
References: <20171011082227.20546-5-liuwenliang@huawei.com>
 <201710141957.mbxeZJHB%fengguang.wu@intel.com>
 <B8AC3E80E903784988AB3003E3E97330C005B9BF@dggemm510-mbx.china.huawei.com>
 <CAKv+Gu98M9PZk3qm0PYC8nQ3zMvLZmNmOn4=hNdFE7NTBuHbgg@mail.gmail.com>
 <B8AC3E80E903784988AB3003E3E97330C005CAC2@dggemm510-mbx.china.huawei.com>
 <20171019124357.GY20805@n2100.armlinux.org.uk>
In-Reply-To: <20171019124357.GY20805@n2100.armlinux.org.uk>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, kbuild test robot <lkp@intel.com>, "kbuild-all@01.org" <kbuild-all@01.org>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, "labbott@redhat.com" <labbott@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "cdall@linaro.org" <cdall@linaro.org>, "marc.zyngier@arm.com" <marc.zyngier@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "thgarnie@google.com" <thgarnie@google.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "mingo@kernel.org" <mingo@kernel.org>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "glider@google.com" <glider@google.com>, "dvyukov@google.com" <dvyukov@google.com>, "opendmb@gmail.com" <opendmb@gmail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jiazhenghua <jiazhenghua@huawei.com>, Dailei <dylix.dailei@huawei.com>, Zengweilin <zengweilin@huawei.com>, Heshaoliang <heshaoliang@huawei.com>

On Tue, Oct 19, 2017 at 20:41 17PM +0000, Russell King - ARM Linux:
>On Mon, Oct 16, 2017 at 11:42:05AM +0000, Liuwenliang (Lamb) wrote:
>> On 10/16/2017 07:03 PM, Abbott Liu wrote:
> >arch/arm/kernel/entry-armv.S:348: Error: selected processor does not sup=
port `movw r1,
>>   #:lower16:((((0xC0000000-0x01000000)>>3)+((0xC0000000-0x01000000)-(1<<=
29))))' in ARM mode
>> >arch/arm/kernel/entry-armv.S:348: Error: selected processor does not su=
pport `movt r1,
>>   #:upper16:((((0xC0000000-0x01000000)>>3)+((0xC0000000-0x01000000)-(1<<=
29))))' in ARM mode
>>=20
>> Thanks for building test. This error can be solved by following code:
>> --- a/arch/arm/kernel/entry-armv.S
>> +++ b/arch/arm/kernel/entry-armv.S
>> @@ -188,8 +188,7 @@ ENDPROC(__und_invalid)
>>         get_thread_info tsk
>>         ldr     r0, [tsk, #TI_ADDR_LIMIT]
>>  #ifdef CONFIG_KASAN
>> -   movw r1, #:lower16:TASK_SIZE
>> -   movt r1, #:upper16:TASK_SIZE
>> + ldr r1, =3DTASK_SIZE
>>  #else
>>         mov r1, #TASK_SIZE
>>  #endif
>
>We can surely do better than this with macros and condition support -
>we can build-time test in the assembler whether TASK_SIZE can fit in a
>normal "mov", whether we can use the movw/movt instructions, or fall
>back to ldr if necessary.  I'd rather we avoided "ldr" here where
>possible.

Thanks for your review.
I don't know why we need to avoided "ldr". The "ldr" maybe cause the=20
performance fall down, but it will be very limited, and as we know the=20
performance of kasan version is lower than the normal version. And usually
we don't use kasan version in our product, we only use kasan version when=20
we want to debug some memory corruption problem in laboratory(not not in
commercial product) because the performance of kasan version is lower than
normal version.

So I think we can accept the influence of the performance by using "ldr" he=
re.=20




On Tue, Oct 19, 2017 at 20:44 17PM +0000, Russell King - ARM Linux:
>On Tue, Oct 17, 2017 at 11:27:19AM +0000, Liuwenliang (Lamb) wrote:
>> ---c0a3b198:       b6e00000        .word   0xb6e00000   //TASK_SIZE:0xb6=
e00000
>
>It's probably going to be better all round to round TASK_SIZE down
>to something that fits in an 8-bit rotated constant anyway (like
>we already guarantee) which would mean this patch is not necessary.

Thanks for you review.
If we enable CONFIG_KASAN, we need steal 130MByte(0xb6e00000 ~ 0xbf000000) =
from user space.
If we change to steal 130MByte(0xb6000000 ~ 0xbe200000) , the 14MB of user =
space is going to be=20
wasted. I think it is better to to use "ldr" whose influence to the system =
are very limited than to waste=20
14MB user space by chaned TASK_SIZE from 0xb6e00000 from 0xb6000000.


If TASK_SIZE is an 8-bit rotated constant, the compiler can convert "ldr rx=
,=3DTASK_SIZE" into mov rx, #TASK_SIZE
If TASK_SIZE is not an 8-bit rotated constant, the compiler can convert "ld=
r rx,=3DTASK_SIZE" into ldr rx, [pc,xxx],
So we can use ldr to replace mov. Here is the code which is tested by me:

diff --git a/arch/arm/kernel/entry-armv.S b/arch/arm/kernel/entry-armv.S
index f9efea3..00a1833 100644
--- a/arch/arm/kernel/entry-armv.S
+++ b/arch/arm/kernel/entry-armv.S
@@ -187,12 +187,7 @@ ENDPROC(__und_invalid)

        get_thread_info tsk
        ldr     r0, [tsk, #TI_ADDR_LIMIT]
-#ifdef CONFIG_KASAN
-   movw r1, #:lower16:TASK_SIZE
-   movt r1, #:upper16:TASK_SIZE
-#else
-   mov r1, #TASK_SIZE
-#endif
+ ldr r1, =3DTASK_SIZE
        str     r1, [tsk, #TI_ADDR_LIMIT]
        str     r0, [sp, #SVC_ADDR_LIMIT]

@@ -446,7 +441,8 @@ ENDPROC(__fiq_abt)
        @ if it was interrupted in a critical region.  Here we
        @ perform a quick test inline since it should be false
        @ 99.9999% of the time.  The rest is done out of line.
-   cmp     r4, #TASK_SIZE
+ ldr r0, =3DTASK_SIZE
+ cmp r4, r0
        blhs    kuser_cmpxchg64_fixup
 #endif
 #endif


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
