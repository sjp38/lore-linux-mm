Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 34D256B0261
	for <linux-mm@kvack.org>; Sat, 18 Nov 2017 05:46:02 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id w205so2268197oig.7
        for <linux-mm@kvack.org>; Sat, 18 Nov 2017 02:46:02 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id t62si1973969oij.133.2017.11.18.02.45.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 18 Nov 2017 02:46:00 -0800 (PST)
From: "Liuwenliang (Abbott Liu)" <liuwenliang@huawei.com>
Subject: Re: [PATCH 01/11] Initialize the mapping of KASan shadow memory
Date: Sat, 18 Nov 2017 10:40:08 +0000
Message-ID: <B8AC3E80E903784988AB3003E3E97330C00638D4@dggemm510-mbs.china.huawei.com>
References: <8e959f69-a578-793b-6c32-18b5b0cd08c2@arm.com>
 <B8AC3E80E903784988AB3003E3E97330C0063545@dggemm510-mbs.china.huawei.com>
 <87a7znsubp.fsf@on-the-bus.cambridge.arm.com>
 <B8AC3E80E903784988AB3003E3E97330C0063587@dggemm510-mbs.china.huawei.com>
 <bbf43f92-3d0c-940d-b66b-68f92eb9b282@arm.com>
 <B8AC3E80E903784988AB3003E3E97330C00635F3@dggemm510-mbs.china.huawei.com>
 <87po8ir1kg.fsf@on-the-bus.cambridge.arm.com>
 <B8AC3E80E903784988AB3003E3E97330C006371B@dggemm510-mbs.china.huawei.com>
 <87375eqobb.fsf@on-the-bus.cambridge.arm.com>
 <B8AC3E80E903784988AB3003E3E97330C0063816@dggemm510-mbs.china.huawei.com>
 <20171117073556.GB28855@cbox>
In-Reply-To: <20171117073556.GB28855@cbox>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoffer Dall <cdall@linaro.org>
Cc: Marc Zyngier <marc.zyngier@arm.com>, "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, "labbott@redhat.com" <labbott@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "thgarnie@google.com" <thgarnie@google.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "mingo@kernel.org" <mingo@kernel.org>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "glider@google.com" <glider@google.com>, "dvyukov@google.com" <dvyukov@google.com>, "opendmb@gmail.com" <opendmb@gmail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jiazhenghua <jiazhenghua@huawei.com>, Dailei <dylix.dailei@huawei.com>, Zengweilin <zengweilin@huawei.com>, Heshaoliang <heshaoliang@huawei.com>

On Nov 17, 2017  15:36 Christoffer Dall [mailto:cdall@linaro.org]  wrote:
>If your processor does support LPAE (like a Cortex-A15 for example),
>then you have both the 32-bit accessors (MRC and MCR) and the 64-bit
>accessors (MRRC, MCRR), and using the 32-bit accessor will simply access
>the lower 32-bits of the 64-bit register.
>
>Hope this helps,
>-Christoffer

If you know the higher 32-bits of the 64-bits cp15's register is not useful=
 for your system,
then you can use the 32-bit accessor to get or set the 64-bit cp15's regist=
er.
But if the higher 32-bits of the 64-bits cp15's register is useful for your=
 system,
then you can't use the 32-bit accessor to get or set the 64-bit cp15's regi=
ster.

TTBR0/TTBR1/PAR's higher 32-bits is useful for CPU supporting LPAE.
The following description which comes from ARM(r) Architecture Reference
Manual ARMv7-A and ARMv7-R edition tell us the reason:

64-bit TTBR0 and TTBR1 format:
...
BADDR, bits[39:x] :=20
Translation table base address, bits[39:x]. Defining the translation table =
base address width on
page B4-1698 describes how x is defined.
The value of x determines the required alignment of the translation table, =
which must be aligned to
2x bytes.

Abbott Liu: Because BADDR on CPU supporting LPAE may be bigger than max val=
ue of 32-bit, so bits[39:32] may=20
be valid value which is useful for the system.

64-bit PAR format
...
PA[39:12]
Physical Address. The physical address corresponding to the supplied virtua=
l address. This field
returns address bits[39:12].

Abbott Liu: Because Physical Address on CPU supporting LPAE may be bigger t=
han max value of 32-bit,=20
so bits[39:32] may be valid value which is useful for the system.

Conclusion: Don't use 32-bit accessor to get or set TTBR0/TTBR1/PAR on CPU =
supporting LPAE,
if you do that, your system may run error.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
