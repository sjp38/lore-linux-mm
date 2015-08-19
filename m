Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 3EC466B0038
	for <linux-mm@kvack.org>; Wed, 19 Aug 2015 10:51:44 -0400 (EDT)
Received: by lbbsx3 with SMTP id sx3so4942700lbb.0
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 07:51:43 -0700 (PDT)
Received: from mail-lb0-x230.google.com (mail-lb0-x230.google.com. [2a00:1450:4010:c04::230])
        by mx.google.com with ESMTPS id j6si665536lbh.152.2015.08.19.07.51.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Aug 2015 07:51:42 -0700 (PDT)
Received: by lbbpu9 with SMTP id pu9so4913324lbb.3
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 07:51:41 -0700 (PDT)
Subject: Re: [PATCH v2 5/5] arm64: add KASan support
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
 <1431698344-28054-6-git-send-email-a.ryabinin@samsung.com>
 <CACRpkdaRJJjCXR=vK1M2YhR26JZfGoBB+jcqz8r2MhERfxRzqA@mail.gmail.com>
 <CAPAsAGy-r8Z2N09wKV+e0kLfbwxd-eWK6N5Xajsnqq9jfyWqcQ@mail.gmail.com>
 <CACRpkdZmHLMxosLXjyOPdkavo=UNzmTcHOLF5vV4cS1ULfbq6A@mail.gmail.com>
 <CAPAsAGw-iawTpjJh66rQN5fqBFT6UBZCcv2eKx7JTqCXzhzpsw@mail.gmail.com>
 <CACRpkdY2i2M27gP_fXawkFrC_GFgWaKr5rEn6d47refNPiEk=g@mail.gmail.com>
 <55AE56DB.4040607@samsung.com>
 <CACRpkdYaqK8upK-3b01JbO_y+sHnk4-Hm1MfvjSy0tKUkFREtQ@mail.gmail.com>
 <55AFD8D0.9020308@samsung.com>
 <CACRpkdaJVRuLTCh585rLEjua2TpnLsALhLdu0ma56TBA=C+EiQ@mail.gmail.com>
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Message-ID: <55D497FC.9060506@gmail.com>
Date: Wed, 19 Aug 2015 17:51:40 +0300
MIME-Version: 1.0
In-Reply-To: <CACRpkdaJVRuLTCh585rLEjua2TpnLsALhLdu0ma56TBA=C+EiQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Walleij <linus.walleij@linaro.org>, Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, David Keitel <dkeitel@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 08/19/2015 03:14 PM, Linus Walleij wrote:
> On Wed, Jul 22, 2015 at 7:54 PM, Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
> 
>> So here is updated version:
>>         git://github.com/aryabinin/linux.git kasan/arm_v0_1
>>
>> The code is still ugly in some places and it probably have some bugs.
>> Lightly tested on exynos 5410/5420.
> 
> I compiled this for various ARM platforms and tested to boot.
> I used GCC version 4.9.3 20150113 (prerelease) (Linaro).
> 
> I get these compilation warnings no matter what I compile,
> I chose to ignore them:
> 
> WARNING: vmlinux.o(.meminit.text+0x2c):
> Section mismatch in reference from the function kasan_pte_populate()
> to the function
> .init.text:kasan_alloc_block.constprop.7()
> The function __meminit kasan_pte_populate() references
> a function __init kasan_alloc_block.constprop.7().
> If kasan_alloc_block.constprop.7 is only used by kasan_pte_populate then
> annotate kasan_alloc_block.constprop.7 with a matching annotation.
> 
> WARNING: vmlinux.o(.meminit.text+0x98):
> Section mismatch in reference from the function kasan_pmd_populate()
> to the function
> .init.text:kasan_alloc_block.constprop.7()
> The function __meminit kasan_pmd_populate() references
> a function __init kasan_alloc_block.constprop.7().
> If kasan_alloc_block.constprop.7 is only used by kasan_pmd_populate then
> annotate kasan_alloc_block.constprop.7 with a matching annotation.
> 
> These KASan outline tests run fine:
> 
> kasan test: kmalloc_oob_right out-of-bounds to right
> kasan test: kmalloc_oob_left out-of-bounds to left
> kasan test: kmalloc_node_oob_right kmalloc_node(): out-of-bounds to right
> kasan test: kmalloc_large_oob_rigth kmalloc large allocation:
> out-of-bounds to right
> kasan test: kmalloc_oob_krealloc_more out-of-bounds after krealloc more
> kasan test: kmalloc_oob_krealloc_less out-of-bounds after krealloc less
> kasan test: kmalloc_oob_16 kmalloc out-of-bounds for 16-bytes access
> kasan test: kmalloc_oob_in_memset out-of-bounds in memset
> kasan test: kmalloc_uaf use-after-free
> kasan test: kmalloc_uaf_memset use-after-free in memset
> kasan test: kmalloc_uaf2 use-after-free after another kmalloc
> kasan test: kmem_cache_oob out-of-bounds in kmem_cache_alloc
> 
> These two tests seems to not trigger KASan BUG()s, and seemse to
> be like so on all hardware, so I guess it is this kind of test
> that requires GCC 5.0:
> 
> kasan test: kasan_stack_oob out-of-bounds on stack
> kasan test: kasan_global_oob out-of-bounds global variable
> 
> 
> Hardware test targets:
> 
> Ux500 (ARMv7):
> 
> On Ux500 I get a real slow boot (as exepected) and after
> enabling the test cases produce KASan warnings
> expectedly.
> 
> MSM APQ8060 (ARMv7):
> 
> Also a real slow boot and the expected KASan warnings when
> running the tests.
> 
> Integrator/AP (ARMv5):
> 
> This one mounted with an ARMv5 ARM926 tile. It boots nicely
> (but takes forever) with KASan and run all test cases (!) just like
> for the other platforms but before reaching userspace this happens:
> 

THREAD_SIZE hardcoded in act_mm macro.

This hack should help:

diff --git a/arch/arm/mm/proc-macros.S b/arch/arm/mm/proc-macros.S
index c671f34..b1765f2 100644
--- a/arch/arm/mm/proc-macros.S
+++ b/arch/arm/mm/proc-macros.S
@@ -32,6 +32,9 @@
 	.macro	act_mm, rd
 	bic	\rd, sp, #8128
 	bic	\rd, \rd, #63
+#ifdef CONFIG_KASAN
+	bic	\rd, \rd, #8192
+#endif
 	ldr	\rd, [\rd, #TI_TASK]
 	ldr	\rd, [\rd, #TSK_ACTIVE_MM]
 	.endm
---




> 
> I then tested on the Footbridge, another ARMv4 system, the oldest I have
> SA110-based. This passes decompression and then you may *think* it hangs.
> But it doesn't. It just takes a few minutes to boot with KASan
> instrumentation, then all tests run fine also on this hardware.
> The crash logs scroll by on the physical console.
> 
> They keep scrolling forever however, and are still scrolling as I
> write this. I suspect some real memory usage bugs to be causing it,
> as it is exercising some ages old code that didn't see much scrutiny
> in recent years.
> 

I would suspect some kasan bug here.

BTW, we probably need to introduce one-shot mode in kasan to prevent such report spam.
I mean print only the first report and ignore the rest. The first report is the most important usually,
next reports usually just noise.


> 
> Yours,
> Linus Walleij
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
