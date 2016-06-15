Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 55A896B0268
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 17:26:30 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id b126so76798132ite.3
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 14:26:30 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id qo11si9850427pab.106.2016.06.15.14.26.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 14:26:29 -0700 (PDT)
Date: Wed, 15 Jun 2016 14:26:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mel:mm-vmscan-node-lru-v7r3 38/200] slub.c:undefined reference
 to `cache_random_seq_create'
Message-Id: <20160615142628.75bf404e7b48e239759f6994@linux-foundation.org>
In-Reply-To: <CAGXu5jJ-ga0pXVtkCFSS6tGnsuhhNxOOguexUU14_4fwa3Uaeg@mail.gmail.com>
References: <201606140353.WeDaHl1M%fengguang.wu@intel.com>
	<20160613141123.fcb245b6a7fd3199ae8a32d7@linux-foundation.org>
	<CAGXu5jLH+UzOhPfj5VkydHg=ZxbrQHQe6C1C-dbCBzsAmW9M2Q@mail.gmail.com>
	<CAGXu5jJ-ga0pXVtkCFSS6tGnsuhhNxOOguexUU14_4fwa3Uaeg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Mel Gorman <mgorman@suse.de>, Thomas Garnier <thgarnie@google.com>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, 15 Jun 2016 10:43:34 -0700 Kees Cook <keescook@chromium.org> wrote:

> >> I don't even get that far with that .config.  With gcc-4.4.4 I get
> >>
> >> init/built-in.o: In function `initcall_blacklisted':
> >> main.c:(.text+0x41): undefined reference to `__stack_chk_guard'
> >> main.c:(.text+0xbe): undefined reference to `__stack_chk_guard'
> >> init/built-in.o: In function `do_one_initcall':
> >> (.text+0xeb): undefined reference to `__stack_chk_guard'
> >> init/built-in.o: In function `do_one_initcall':
> >> (.text+0x22b): undefined reference to `__stack_chk_guard'
> >> init/built-in.o: In function `name_to_dev_t':
> >> (.text+0x320): undefined reference to `__stack_chk_guard'
> >> init/built-in.o:(.text+0x52e): more undefined references to `__stack_chk_guard'
> >
> > This, I don't. I'm scratching my head about how that's possible. The
> > __stack_chk_guard is a compiler alias on x86...
> >
> >> Kees touched it last :)
> >
> > I'll take a closer look tomorrow...
> 
> Stupid question: were you doing a build for x86?

Yes, x86_64.  Using Fengguang's .config.gz

> This error really
> shouldn't be possible since gcc defaults to tls for the guard on x86.
> I don't have gcc 4.4.4 easily available, but I don't think it even has
> the -mstack-protector-guard option to force this to change. (And I see
> no reference to this option in the kernel tree.) AFAICT this error
> should only happen when building with either
> -mstack-protector-guard=global or an architecture that forces that,
> along with some new code that triggers the stack protector but lacks
> the symbol at link time, which also seems impossible. :P

With gcc-4.8.4:

make V=1 init/main.o
...
  gcc -Wp,-MD,init/.main.o.d  -nostdinc -isystem /usr/lib/gcc/x86_64-linux-gnu/4.8/include -I./arch/x86/include -Iarch/x86/include/generated/uapi -Iarch/x86/include/generated  -Iinclude -I./arch/x86/include/uapi -Iarch/x86/include/generated/uapi -I./include/uapi -Iinclude/generated/uapi -include ./include/linux/kconfig.h -D__KERNEL__ -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -Werror-implicit-function-declaration -Wno-format-security -std=gnu89 -mno-sse -mno-mmx -mno-sse2 -mno-3dnow -mno-avx -m64 -falign-jumps=1 -falign-loops=1 -mno-80387 -mno-fp-ret-in-387 -mpreferred-stack-boundary=3 -mtune=generic -mno-red-zone -mcmodel=kernel -funit-at-a-time -maccumulate-outgoing-args -DCONFIG_X86_X32_ABI -DCONFIG_AS_CFI=1 -DCONFIG_AS_CFI_SIGNAL_FRAME=1 -DCONFIG_AS_CFI_SECTIONS=1 -DCONFIG_AS_FXSAVEQ=1 -DCONFIG_AS_SSSE3=1 -DCONFIG_AS_CRC32=1 -DCONFIG_AS_AVX=1 -DCONFIG_AS_AVX2=1 -DCONFIG_AS_SHA1_NI=1 -DCONFIG_AS_SHA256_NI=1 -pipe -Wno-sign-compare -fn
 o-asynchronous-unwind-tables -fno-delete-null-pointer-checks -O2 --param=allow-store-data-races=0 -fno-reorder-blocks -fno-ipa-cp-clone -fno-partial-inlining -Wframe-larger-than=2048 -fstack-protector -Wno-unused-but-set-variable -fno-omit-frame-pointer -fno-optimize-sibling-calls -fno-var-tracking-assignments -fno-inline-functions-called-once -Wdeclaration-after-statement -Wno-pointer-sign -fno-strict-overflow -fconserve-stack -Werror=implicit-int -Werror=strict-prototypes -DCC_HAVE_ASM_GOTO      -DKBUILD_BASENAME='"main"'  -DKBUILD_MODNAME='"main"' -c -o init/.tmp_main.o init/main.c

(note: -fstack-protector)

akpm3:/usr/src/25> nm init/main.o | grep chk
                 U __stack_chk_fail



With gcc-4.4.4:

  /opt/crosstool/gcc-4.4.4-nolibc/x86_64-linux/bin/x86_64-linux-gcc -Wp,-MD,init/.main.o.d  -nostdinc -isystem /opt/crosstool/gcc-4.4.4-nolibc/x86_64-linux/bin/../lib/gcc/x86_64-linux/4.4.4/include -I./arch/x86/include -Iarch/x86/include/generated/uapi -Iarch/x86/include/generated  -Iinclude -I./arch/x86/include/uapi -Iarch/x86/include/generated/uapi -I./include/uapi -Iinclude/generated/uapi -include ./include/linux/kconfig.h -D__KERNEL__ -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -Werror-implicit-function-declaration -Wno-format-security -std=gnu89 -mno-sse -mno-mmx -mno-sse2 -mno-3dnow -mno-avx -m64 -falign-jumps=1 -falign-loops=1 -mno-80387 -mno-fp-ret-in-387 -mtune=generic -mno-red-zone -mcmodel=kernel -funit-at-a-time -maccumulate-outgoing-args -DCONFIG_AS_CFI=1 -DCONFIG_AS_CFI_SIGNAL_FRAME=1 -DCONFIG_AS_CFI_SECTIONS=1 -DCONFIG_AS_FXSAVEQ=1 -DCONFIG_AS_SSSE3=1 -DCONFIG_AS_CRC32=1 -DCONFIG_AS_AVX=1 -pipe -Wno-sign-compare -fno-asynch
 ronous-unwind-tables -fno-delete-null-pointer-checks -O2 -fno-reorder-blocks -fno-ipa-cp-clone -Wframe-larger-than=2048 -fstack-protector -fno-omit-frame-pointer -fno-optimize-sibling-calls -fno-inline-functions-called-once -Wdeclaration-after-statement -Wno-pointer-sign -fno-strict-overflow -fconserve-stack -Werror=implicit-int -Werror=strict-prototypes      -DKBUILD_BASENAME='"main"'  -DKBUILD_MODNAME='"main"' -c -o init/.tmp_main.o init/main.c
arch/x86/Makefile:133: stack-protector enabled but compiler support broken
arch/x86/Makefile:148: CONFIG_X86_X32 enabled but no binutils support
Makefile:687: Cannot use CONFIG_KCOV: -fsanitize-coverage=trace-pc is not supported by compiler
Makefile:1041: "Cannot use CONFIG_STACK_VALIDATION, please install libelf-dev or elfutils-libelf-devel"

We still have -fstack-proector but at least we got a build-time warning
this time.

akpm3:/usr/src/25> nm init/main.o | grep chk
                 U __stack_chk_fail
                 U __stack_chk_guard

The build system should be handling this automatically - we shouldn't
be failing the build and then requiring the user to go fiddle Kconfig.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
