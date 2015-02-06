Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id D29A86B0038
	for <linux-mm@kvack.org>; Fri,  6 Feb 2015 12:45:27 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id rd3so18556844pab.9
        for <linux-mm@kvack.org>; Fri, 06 Feb 2015 09:45:27 -0800 (PST)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id rb8si11022082pbc.185.2015.02.06.09.45.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 06 Feb 2015 09:45:26 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJD004N02UANU70@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 06 Feb 2015 17:49:22 +0000 (GMT)
Message-id: <54D4FDAC.60203@samsung.com>
Date: Fri, 06 Feb 2015 20:45:16 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [mmotm:master 409/551] WARNING:
 arch/x86/kernel/cpu/microcode/microcode.o(.data+0x1cf0): Section mismatch in
 reference from the variable microcode_mutex to the variable
 .init.rodata:__mod_x86cpu__microcode_id_device_table
References: <201502050342.47w5t7vH%fengguang.wu@intel.com>
In-reply-to: <201502050342.47w5t7vH%fengguang.wu@intel.com>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

On 02/04/2015 10:24 PM, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   f03806f9a6908743ed1902389be1a4a6198852be
> commit: 7bc18a57df7c27948b9d93fa4eefc20e3e200512 [409/551] kasan: enable instrumentation of global variables
> config: x86_64-allmodconfig (attached as .config)
> reproduce:
>   git checkout 7bc18a57df7c27948b9d93fa4eefc20e3e200512
>   # save the attached .config to linux build tree
>   make ARCH=x86_64 
> 
> All warnings:
> 
>>> WARNING: arch/x86/kernel/cpu/microcode/microcode.o(.data+0x1cf0): Section mismatch in reference from the variable microcode_mutex to the variable .init.rodata:__mod_x86cpu__microcode_id_device_table
>    The variable microcode_mutex references
>    the variable __initconst __mod_x86cpu__microcode_id_device_table


Obviously 'microcode_mutex' doesn't reference '__mod_x86cpu__microcode_id_device_table'.
Actually this is struct kasan_global describing '__mod_x86cpu__microcode_id_device_table'
variable references it.

Normally GCC doesn't instrument globals in user-specified sections.
So we shouldn't have kasan_global struct for '__mod_x86cpu__microcode_id_device_table',
because this symbol doesn't have redzone.

'__mod_x86cpu__microcode_id_device_table' is an alias to 'microcode_id' symbol and
alias declared without specifying section.
It seems that GCC looks only on declaration, and it thinks that __mod_x86cpu__microcode_id_device_table
is in default section.
So we poison redzone for microcode_id symbol, which don't have redzone. IOW we poison some valid memory.

This bug already fixed in trunk GCC, but it present in 4.9.2.

I think the best option here is just disable globals instrumentation for 4.9.2.
In addition to patch bellow, 'kernel-add-support-for-init_array-constructors.patch' patch
could be dropped, as we needed it only for 4.9.2 GCC.

----
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: kasan-enable-instrumentation-of-global-variables-fix-2

Disable broken globals instrumentation for GCC 4.9.2

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 scripts/Makefile.kasan | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/scripts/Makefile.kasan b/scripts/Makefile.kasan
index 72a40bb..631619b 100644
--- a/scripts/Makefile.kasan
+++ b/scripts/Makefile.kasan
@@ -5,7 +5,7 @@ else
 	call_threshold := 0
 endif

-CFLAGS_KASAN_MINIMAL := -fsanitize=kernel-address --param asan-globals=1
+CFLAGS_KASAN_MINIMAL := -fsanitize=kernel-address

 CFLAGS_KASAN := $(call cc-option, -fsanitize=kernel-address \
 		-fasan-shadow-offset=$(CONFIG_KASAN_SHADOW_OFFSET) \
-- 
2.2.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
