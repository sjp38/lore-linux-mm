Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3FEB46B0033
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 08:19:09 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 190so18937108pgh.16
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 05:19:09 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id o88si19808539pfk.294.2017.11.15.05.19.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Nov 2017 05:19:07 -0800 (PST)
From: "Liuwenliang (Abbott Liu)" <liuwenliang@huawei.com>
Subject: Re: [PATCH 01/11] Initialize the mapping of KASan shadow memory
Date: Wed, 15 Nov 2017 13:16:36 +0000
Message-ID: <B8AC3E80E903784988AB3003E3E97330C0063587@dggemm510-mbs.china.huawei.com>
References: <20171011082227.20546-1-liuwenliang@huawei.com>
	<20171011082227.20546-2-liuwenliang@huawei.com>
	<227e2c6e-f479-849d-8942-1d5ff4ccd440@arm.com>
	<B8AC3E80E903784988AB3003E3E97330C0063172@dggemm510-mbs.china.huawei.com>
	<8e959f69-a578-793b-6c32-18b5b0cd08c2@arm.com>
	<B8AC3E80E903784988AB3003E3E97330C0063545@dggemm510-mbs.china.huawei.com>
 <87a7znsubp.fsf@on-the-bus.cambridge.arm.com>
In-Reply-To: <87a7znsubp.fsf@on-the-bus.cambridge.arm.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Zyngier <marc.zyngier@arm.com>
Cc: "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, "labbott@redhat.com" <labbott@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "cdall@linaro.org" <cdall@linaro.org>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "thgarnie@google.com" <thgarnie@google.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "mingo@kernel.org" <mingo@kernel.org>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "glider@google.com" <glider@google.com>, "dvyukov@google.com" <dvyukov@google.com>, "opendmb@gmail.com" <opendmb@gmail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jiazhenghua <jiazhenghua@huawei.com>, Dailei <dylix.dailei@huawei.com>, Zengweilin <zengweilin@huawei.com>, Heshaoliang <heshaoliang@huawei.com>

On 09/11/17  18:36 Marc Zyngier [mailto:marc.zyngier@arm.com] wrote:
>On Wed, Nov 15 2017 at 10:20:02 am GMT, "Liuwenliang (Abbott Liu)" <liuwen=
liang@huawei.com> wrote:
>> On 09/11/17 18:11, Marc Zyngier [mailto:marc.zyngier@arm.com] wrote:
>>>On 09/11/17 07:46, Liuwenliang (Abbott Liu) wrote:
>>>> diff --git a/arch/arm/mm/kasan_init.c b/arch/arm/mm/kasan_init.c
>>>> index 049ee0a..359a782 100644
>>>> --- a/arch/arm/mm/kasan_init.c
>>>> +++ b/arch/arm/mm/kasan_init.c
>>>> @@ -15,6 +15,7 @@
>>>>  #include <asm/proc-fns.h>
>>>>  #include <asm/tlbflush.h>
>>>>  #include <asm/cp15.h>
>>>> +#include <asm/kvm_hyp.h>
>>>
>>>No, please don't do that. You shouldn't have to include KVM stuff in
>>>unrelated code. Instead of adding stuff to kvm_hyp.h, move all the
>>>__ACCESS_CP15* to cp15.h, and it will be obvious to everyone that this
>>>is where new definition should be added.
>>
>> Thanks for your review.  You are right. It is better to move
>> __ACCESS_CP15* to cp15.h than to include kvm_hyp.h. But I don't think
>> it is a good idea to move registers definition which is used in
>> virtualization to cp15.h, Because there is no virtualization stuff in
>> cp15.h.
>
>It is not about virtualization at all.
>
>It is about what is a CP15 register and what is not. This file is called
>"cp15.h", not "cp15-except-virtualization-and-maybe-some-others.h". But
>at the end of the day, that's for Russell to decide.

Thanks for your review.
You are right, all __ACCESS_CP15* are cp15 registers. I splited normal cp15=
 register
(such as TTBR0/TTBR1/SCTLR and so on) and virtualizaton cp15 registers(such=
 as VTTBR/
CNTV_CVAL/HCR) because I didn't think we need use those virtualization cp15=
 registers
in non virtualization system.

But now I think all __ACCESS_CP15* move to cp15.h may be a better choise.=20

>>
>> Here is the code which I tested on vexpress_a15 and vexpress_a9:
>> diff --git a/arch/arm/include/asm/cp15.h b/arch/arm/include/asm/cp15.h
>> index dbdbce1..6db1f51 100644
>> --- a/arch/arm/include/asm/cp15.h
>> +++ b/arch/arm/include/asm/cp15.h
>> @@ -64,6 +64,43 @@
>>  #define __write_sysreg(v, r, w, c, t)  asm volatile(w " " c : : "r" ((t=
)(v)))
>>  #define write_sysreg(v, ...)           __write_sysreg(v, __VA_ARGS__)
>>
>> +#ifdef CONFIG_ARM_LPAE
>> +#define TTBR0           __ACCESS_CP15_64(0, c2)
>> +#define TTBR1           __ACCESS_CP15_64(1, c2)
>> +#define PAR             __ACCESS_CP15_64(0, c7)
>> +#else
>> +#define TTBR0           __ACCESS_CP15(c2, 0, c0, 0)
>> +#define TTBR1           __ACCESS_CP15(c2, 0, c0, 1)
>> +#define PAR             __ACCESS_CP15(c7, 0, c4, 0)
>> +#endif
>
>Again: there is no point in not having these register encodings
>cohabiting. They are both perfectly defined in the architecture. Just
>suffix one (or even both) with their respective size, making it obvious
>which one you're talking about.

I am sorry that I didn't point why I need to define TTBR0/ TTBR1/PAR in to =
different way
between CONFIG_ARM_LPAE and non CONFIG_ARM_LPAE.
The following description is the reason:
Here is the description come from DDI0406C2c_arm_architecture_reference_man=
ual.pdf:

B4.1.155 TTBR0, Translation Table Base Register 0, VMSA
...
The Multiprocessing Extensions change the TTBR0 32-bit register format.
The Large Physical Address Extension extends TTBR0 to a 64-bit register. In=
 an
implementation that includes the Large Physical Address Extension, TTBCR.EA=
E
determines which TTBR0 format is used:
EAE=3D=3D0 32-bit format is used. TTBR0[63:32] are ignored.
EAE=3D=3D1 64-bit format is used.

B4.1.156 TTBR1, Translation Table Base Register 1, VMSA
...
The Multiprocessing Extensions change the TTBR0 32-bit register format.
The Large Physical Address Extension extends TTBR1 to a 64-bit register. In=
 an
implementation that includes the Large Physical Address Extension, TTBCR.EA=
E
determines which TTBR1 format is used:
EAE=3D=3D0 32-bit format is used. TTBR1[63:32] are ignored.
EAE=3D=3D1 64-bit format is used.

B4.1.154 TTBCR, Translation Table Base Control Register, VMSA
...
EAE, bit[31], if implementation includes the Large Physical Address Extensi=
on
Extended Address Enable. The meanings of the possible values of this bit ar=
e:
0   Use the 32-bit translation system, with the Short-descriptor translatio=
n table format. In
this case, the format of the TTBCR is as described in this section.
1   Use the 40-bit translation system, with the Long-descriptor translation=
 table format. In
this case, the format of the TTBCR is as described in TTBCR format when usi=
ng the
Long-descriptor translation table format on page B4-1692.

B4.1.112 PAR, Physical Address Register, VMSA
If the implementation includes the Large Physical Address Extension, the PA=
R is extended
to be a 64-bit register and:
* The 64-bit PAR is used:
- when using the Long-descriptor translation table format
- in an implementation that includes the Virtualization Extensions, for the=
 result
of an ATS1Cxx operation performed from Hyp mode.
* The 32-bit PAR is used when using the Short-descriptor translation table =
format. In
this case, PAR[63:32] is UNK/SBZP.
Otherwise, the PAR is a 32-bit register.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
