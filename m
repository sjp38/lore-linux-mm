Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 27D926B0038
	for <linux-mm@kvack.org>; Tue, 17 Nov 2015 09:58:53 -0500 (EST)
Received: by wmww144 with SMTP id w144so157479956wmw.1
        for <linux-mm@kvack.org>; Tue, 17 Nov 2015 06:58:52 -0800 (PST)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [207.82.80.143])
        by mx.google.com with ESMTPS id l69si33604191wmb.75.2015.11.17.06.58.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 17 Nov 2015 06:58:52 -0800 (PST)
Subject: Re: [PATCH v7 0/4] KASAN for arm64
References: <1444665180-301-1-git-send-email-ryabinin.a.a@gmail.com>
 <20151013083432.GG6320@e104818-lin.cambridge.arm.com>
 <5649BAFD.6030005@arm.com> <5649F783.40109@gmail.com>
From: "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>
Message-ID: <564B40A7.1000206@arm.com>
Date: Tue, 17 Nov 2015 14:58:47 +0000
MIME-Version: 1.0
In-Reply-To: <5649F783.40109@gmail.com>
Content-Type: text/plain; charset=WINDOWS-1252; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Yury <yury.norov@gmail.com>, Alexey Klimov <klimov.linux@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Andrey Konovalov <andreyknvl@google.com>, Linus Walleij <linus.walleij@linaro.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-kernel@vger.kernel.org, kasan-dev <kasan-dev@googlegroups.com>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>

On 16/11/15 15:34, Andrey Ryabinin wrote:
> On 11/16/2015 02:16 PM, Suzuki K. Poulose wrote:
>> On 13/10/15 09:34, Catalin Marinas wrote:
>>> On Mon, Oct 12, 2015 at 06:52:56PM +0300, Andrey Ryabinin wrote:

>> Hi,
>>
>> I get the following failure with KASAN + 16K_PAGES + 48BIT_VA, with 4.4-=
rc1:
>>
>>
>> arch/arm64/mm/kasan_init.c: In function =91kasan_early_init=92:
>> include/linux/compiler.h:484:38: error: call to =91__compiletime_assert_=
95=92 declared with attribute error: BUILD_BUG_ON failed: !IS_ALIGNED(KASAN=
_SHADOW_END, PGDIR_SIZE)
>>    _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
>>                                        ^

...

>
> Yes, it's really needed, because some code relies on this (e.g.  clear_pg=
s() and kasan_init()).
> But it should be possible to get rid of this requirement.

And the other important point I missed mentioning was that, my tool chain d=
oesn't
support KASAN. But still the KASAN support files are still compiled and gen=
erates
the above error. Shouldn't we disable it at build time if we detect that co=
mpiler
doesn't support it ? Something like we do for LSE_ATOMICS.


commit c09d6a04d17d730b0463207a26ece082772b59ee
Author: Will Deacon <will.deacon@arm.com>
Date:   Tue Feb 3 16:14:13 2015 +0000

     arm64: atomics: patch in lse instructions when supported by the CPU
    =20
     On CPUs which support the LSE atomic instructions introduced in ARMv8.=
1,
     it makes sense to use them in preference to ll/sc sequences.
    =20
...

diff --git a/arch/arm64/Makefile b/arch/arm64/Makefile
index 0953a97..15ff5b4 100644
--- a/arch/arm64/Makefile
+++ b/arch/arm64/Makefile
@@ -17,7 +17,18 @@ GZFLAGS              :=3D-9
 =20
  KBUILD_DEFCONFIG :=3D defconfig
 =20
-KBUILD_CFLAGS  +=3D -mgeneral-regs-only
+# Check for binutils support for specific extensions
+lseinstr :=3D $(call as-instr,.arch_extension lse,-DCONFIG_AS_LSE=3D1)
+
+ifeq ($(CONFIG_ARM64_LSE_ATOMICS), y)
+  ifeq ($(lseinstr),)
+$(warning LSE atomics not supported by binutils)
+  endif
+endif
+
+KBUILD_CFLAGS  +=3D -mgeneral-regs-only $(lseinstr)
+KBUILD_AFLAGS  +=3D $(lseinstr)
+



Thanks
Suzuki

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
