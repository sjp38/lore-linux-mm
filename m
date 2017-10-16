Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A50146B0033
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 07:51:08 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f4so9021667wme.21
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 04:51:08 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id o73si5348653wmi.45.2017.10.16.04.50.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Oct 2017 04:51:07 -0700 (PDT)
From: "Liuwenliang (Lamb)" <liuwenliang@huawei.com>
Subject: Re: [PATCH 04/11] Define the virtual space of KASan's shadow region
Date: Mon, 16 Oct 2017 11:42:05 +0000
Message-ID: <B8AC3E80E903784988AB3003E3E97330C005B9BF@dggemm510-mbx.china.huawei.com>
References: <20171011082227.20546-5-liuwenliang@huawei.com>
 <201710141957.mbxeZJHB%fengguang.wu@intel.com>
In-Reply-To: <201710141957.mbxeZJHB%fengguang.wu@intel.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: "kbuild-all@01.org" <kbuild-all@01.org>, "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, "labbott@redhat.com" <labbott@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "cdall@linaro.org" <cdall@linaro.org>, "marc.zyngier@arm.com" <marc.zyngier@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "thgarnie@google.com" <thgarnie@google.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "mingo@kernel.org" <mingo@kernel.org>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "glider@google.com" <glider@google.com>, "dvyukov@google.com" <dvyukov@google.com>, "opendmb@gmail.com" <opendmb@gmail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jiazhenghua <jiazhenghua@huawei.com>, Dailei <dylix.dailei@huawei.com>, Zengweilin <zengweilin@huawei.com>, Heshaoliang <heshaoliang@huawei.com>

On 10/16/2017 07:03 PM, Abbott Liu wrote:
>arch/arm/kernel/entry-armv.S:348: Error: selected processor does not suppo=
rt `movw r1,
  #:lower16:((((0xC0000000-0x01000000)>>3)+((0xC0000000-0x01000000)-(1<<29)=
)))' in ARM mode
>arch/arm/kernel/entry-armv.S:348: Error: selected processor does not suppo=
rt `movt r1,
  #:upper16:((((0xC0000000-0x01000000)>>3)+((0xC0000000-0x01000000)-(1<<29)=
)))' in ARM mode

Thanks for building test. This error can be solved by following code:
--- a/arch/arm/kernel/entry-armv.S
+++ b/arch/arm/kernel/entry-armv.S
@@ -188,8 +188,7 @@ ENDPROC(__und_invalid)
        get_thread_info tsk
        ldr     r0, [tsk, #TI_ADDR_LIMIT]
 #ifdef CONFIG_KASAN
-   movw r1, #:lower16:TASK_SIZE
-   movt r1, #:upper16:TASK_SIZE
+ ldr r1, =3DTASK_SIZE
 #else
        mov r1, #TASK_SIZE
 #endif
@@ -446,7 +445,12 @@ ENDPROC(__fiq_abt)
        @ if it was interrupted in a critical region.  Here we
        @ perform a quick test inline since it should be false
        @ 99.9999% of the time.  The rest is done out of line.
+#if CONFIG_KASAN
+ ldr r0, =3DTASK_SIZE
+ cmp r4, r0
+#else
        cmp     r4, #TASK_SIZE
+#endif
        blhs    kuser_cmpxchg64_fixup
 #endif
 #endif

movt,movw can only be used in ARMv6*, ARMv7 instruction set. But ldr can be=
 used in ARMv4*, ARMv5T*, ARMv6*, ARMv7.
Maybe the performance is going to fall down by using ldr, but I think the i=
nfluence of performance is very limited.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
