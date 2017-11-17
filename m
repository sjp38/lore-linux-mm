Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2A4C86B0253
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 02:35:51 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id s8so972685wrc.16
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 23:35:51 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i76sor788225wmd.31.2017.11.16.23.35.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 Nov 2017 23:35:49 -0800 (PST)
Date: Fri, 17 Nov 2017 08:35:56 +0100
From: Christoffer Dall <cdall@linaro.org>
Subject: Re: [PATCH 01/11] Initialize the mapping of KASan shadow memory
Message-ID: <20171117073556.GB28855@cbox>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <B8AC3E80E903784988AB3003E3E97330C0063816@dggemm510-mbs.china.huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liuwenliang (Abbott Liu)" <liuwenliang@huawei.com>
Cc: Marc Zyngier <marc.zyngier@arm.com>, "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, "labbott@redhat.com" <labbott@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "thgarnie@google.com" <thgarnie@google.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "mingo@kernel.org" <mingo@kernel.org>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "glider@google.com" <glider@google.com>, "dvyukov@google.com" <dvyukov@google.com>, "opendmb@gmail.com" <opendmb@gmail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jiazhenghua <jiazhenghua@huawei.com>, Dailei <dylix.dailei@huawei.com>, Zengweilin <zengweilin@huawei.com>, Heshaoliang <heshaoliang@huawei.com>

On Fri, Nov 17, 2017 at 07:18:45AM +0000, Liuwenliang (Abbott Liu) wrote:
> On 16/11/17  22:41 Marc Zyngier [mailto:marc.zyngier@arm.com] wrote:
> >No, it doesn't. It cannot work, because Cortex-A9 predates the invention
> >of the 64bit accessor. I suspect that you are testing stuff in QEMU,
> >which is giving you a SW model that always supports LPAE. I suggest you
> >test this code on *real* HW, and not only on QEMU.
> 
> I am sorry. My test is fault. I only defined TTBR0 as __ACCESS_CP15_64,
> but I don't use the definition TTBR0 as __ACCESS_CP15_64. 
> 
> Now I use the definition TTBR0 as __ACCESS_CP15_64 on CPU supporting
> LPAE(vexpress_a9)

What does a "CPU supporting LPAE(vexpress_a9) mean?  As Marc pointed
out, a Cortex-A9 doesn't support LPAE.  If you configure your kernel
with LPAE it's not going to work on a Cortex-A9.

> I find it doesn't work and report undefined instruction error
> when execute "mrrc" instruction.
> 
> So, you are right that 64bit accessor of TTBR0 cannot work on LPAE.
> 

It's the other way around.  It doesn't work WITHOUT LPAE, it only works
WITH LPAE.

The ARM ARM explains this quite clearly:

"Accessing TTBR0

To access TTBR0 in an implementation that does not include the Large
Physical Address Extension, or bits[31:0] of TTBR0 in an implementation
that includes the Large Physical Address Extension, software reads or
writes the CP15 registers with <opc1> set to 0, <CRn> set to c2, <CRm>
set to c0, and <opc2> set to 0. For example:

MRC p15, 0, <Rt>, c2, c0, 0
  ; Read 32-bit TTBR0 into Rt
MCR p15, 0, <Rt>, c2, c0, 0
  ; Write Rt to 32-bit TTBR0

In an implementation that includes the Large Physical Address Extension,
to access all 64 bits of TTBR0, software performs a 64-bit read or write
of the CP15 registers with <CRm> set to c2 and <opc1> set to 0. For
example:

MRRC p15, 0, <Rt>, <Rt2>, c2
  ; Read 64-bit TTBR0 into Rt (low word) and Rt2 (high word)
MCRR p15, 0, <Rt>, <Rt2>, c2
  ; Write Rt (low word) and Rt2 (high word) to 64-bit TTBR0

In these MRRC and MCRR instructions, Rt holds the least-significant word
of TTBR0, and Rt2 holds the most-significant word."

That is, if your processor (like the Cortex-A9) does NOT support LPAE,
all you have is the 32-bit accessors (MRC and MCR).

If your processor does support LPAE (like a Cortex-A15 for example),
then you have both the 32-bit accessors (MRC and MCR) and the 64-bit
accessors (MRRC, MCRR), and using the 32-bit accessor will simply access
the lower 32-bits of the 64-bit register.

Hope this helps,
-Christoffer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
