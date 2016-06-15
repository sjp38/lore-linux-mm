Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0B1306B007E
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 18:37:51 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id l184so19132547lfl.3
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 15:37:50 -0700 (PDT)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id q69si7120727wmd.111.2016.06.15.15.37.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 15:37:49 -0700 (PDT)
Received: by mail-wm0-x22b.google.com with SMTP id m124so44163759wme.1
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 15:37:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160615142628.75bf404e7b48e239759f6994@linux-foundation.org>
References: <201606140353.WeDaHl1M%fengguang.wu@intel.com> <20160613141123.fcb245b6a7fd3199ae8a32d7@linux-foundation.org>
 <CAGXu5jLH+UzOhPfj5VkydHg=ZxbrQHQe6C1C-dbCBzsAmW9M2Q@mail.gmail.com>
 <CAGXu5jJ-ga0pXVtkCFSS6tGnsuhhNxOOguexUU14_4fwa3Uaeg@mail.gmail.com> <20160615142628.75bf404e7b48e239759f6994@linux-foundation.org>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 15 Jun 2016 15:37:48 -0700
Message-ID: <CAGXu5jLKS=cWJJozFOYyjzNuiBt5GTSBAfZCyFRXh3oVE5QE=g@mail.gmail.com>
Subject: Re: [mel:mm-vmscan-node-lru-v7r3 38/200] slub.c:undefined reference
 to `cache_random_seq_create'
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Mel Gorman <mgorman@suse.de>, Thomas Garnier <thgarnie@google.com>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, Jun 15, 2016 at 2:26 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 15 Jun 2016 10:43:34 -0700 Kees Cook <keescook@chromium.org> wrot=
e:
>
>> >> I don't even get that far with that .config.  With gcc-4.4.4 I get
>> >>
>> >> init/built-in.o: In function `initcall_blacklisted':
>> >> main.c:(.text+0x41): undefined reference to `__stack_chk_guard'
>> >> main.c:(.text+0xbe): undefined reference to `__stack_chk_guard'
>> >> init/built-in.o: In function `do_one_initcall':
>> >> (.text+0xeb): undefined reference to `__stack_chk_guard'
>> >> init/built-in.o: In function `do_one_initcall':
>> >> (.text+0x22b): undefined reference to `__stack_chk_guard'
>> >> init/built-in.o: In function `name_to_dev_t':
>> >> (.text+0x320): undefined reference to `__stack_chk_guard'
>> >> init/built-in.o:(.text+0x52e): more undefined references to `__stack_=
chk_guard'
>> >
>> > This, I don't. I'm scratching my head about how that's possible. The
>> > __stack_chk_guard is a compiler alias on x86...
>> >
>> >> Kees touched it last :)
>> >
>> > I'll take a closer look tomorrow...
>>
>> Stupid question: were you doing a build for x86?
>
> Yes, x86_64.  Using Fengguang's .config.gz

Okay, just wanted to double check since my head was spinning. :)

>> This error really
>> shouldn't be possible since gcc defaults to tls for the guard on x86.
>> I don't have gcc 4.4.4 easily available, but I don't think it even has
>> the -mstack-protector-guard option to force this to change. (And I see
>> no reference to this option in the kernel tree.) AFAICT this error
>> should only happen when building with either
>> -mstack-protector-guard=3Dglobal or an architecture that forces that,
>> along with some new code that triggers the stack protector but lacks
>> the symbol at link time, which also seems impossible. :P
>
> With gcc-4.8.4:
>
> make V=3D1 init/main.o
> ...
>   gcc -Wp,-MD,init/.main.o.d  -nostdinc -isystem /usr/lib/gcc/x86_64-linu=
x-gnu/4.8/include -I./arch/x86/include -Iarch/x86/include/generated/uapi -I=
arch/x86/include/generated  -Iinclude -I./arch/x86/include/uapi -Iarch/x86/=
include/generated/uapi -I./include/uapi -Iinclude/generated/uapi -include .=
/include/linux/kconfig.h -D__KERNEL__ -Wall -Wundef -Wstrict-prototypes -Wn=
o-trigraphs -fno-strict-aliasing -fno-common -Werror-implicit-function-decl=
aration -Wno-format-security -std=3Dgnu89 -mno-sse -mno-mmx -mno-sse2 -mno-=
3dnow -mno-avx -m64 -falign-jumps=3D1 -falign-loops=3D1 -mno-80387 -mno-fp-=
ret-in-387 -mpreferred-stack-boundary=3D3 -mtune=3Dgeneric -mno-red-zone -m=
cmodel=3Dkernel -funit-at-a-time -maccumulate-outgoing-args -DCONFIG_X86_X3=
2_ABI -DCONFIG_AS_CFI=3D1 -DCONFIG_AS_CFI_SIGNAL_FRAME=3D1 -DCONFIG_AS_CFI_=
SECTIONS=3D1 -DCONFIG_AS_FXSAVEQ=3D1 -DCONFIG_AS_SSSE3=3D1 -DCONFIG_AS_CRC3=
2=3D1 -DCONFIG_AS_AVX=3D1 -DCONFIG_AS_AVX2=3D1 -DCONFIG_AS_SHA1_NI=3D1 -DCO=
NFIG_AS_SHA256_NI=3D1 -pipe -Wno-sign-compare -fn
>  o-asynchronous-unwind-tables -fno-delete-null-pointer-checks -O2 --param=
=3Dallow-store-data-races=3D0 -fno-reorder-blocks -fno-ipa-cp-clone -fno-pa=
rtial-inlining -Wframe-larger-than=3D2048 -fstack-protector -Wno-unused-but=
-set-variable -fno-omit-frame-pointer -fno-optimize-sibling-calls -fno-var-=
tracking-assignments -fno-inline-functions-called-once -Wdeclaration-after-=
statement -Wno-pointer-sign -fno-strict-overflow -fconserve-stack -Werror=
=3Dimplicit-int -Werror=3Dstrict-prototypes -DCC_HAVE_ASM_GOTO      -DKBUIL=
D_BASENAME=3D'"main"'  -DKBUILD_MODNAME=3D'"main"' -c -o init/.tmp_main.o i=
nit/main.c
>
> (note: -fstack-protector)

This is correct (the .config specifies CONFIG_CC_STACKPROTECTOR_REGULAR).

> akpm3:/usr/src/25> nm init/main.o | grep chk
>                  U __stack_chk_fail

This is also correct: a stack protector was added, so on failure,
__stack_chk_fail is called. This is correctly putting the stack
protector guard into %gs (see arch/x86/include/asm/stackprotector.h
for the dark magic/details).

> With gcc-4.4.4:
>
>   /opt/crosstool/gcc-4.4.4-nolibc/x86_64-linux/bin/x86_64-linux-gcc -Wp,-=
MD,init/.main.o.d  -nostdinc -isystem /opt/crosstool/gcc-4.4.4-nolibc/x86_6=
4-linux/bin/../lib/gcc/x86_64-linux/4.4.4/include -I./arch/x86/include -Iar=
ch/x86/include/generated/uapi -Iarch/x86/include/generated  -Iinclude -I./a=
rch/x86/include/uapi -Iarch/x86/include/generated/uapi -I./include/uapi -Ii=
nclude/generated/uapi -include ./include/linux/kconfig.h -D__KERNEL__ -Wall=
 -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-commo=
n -Werror-implicit-function-declaration -Wno-format-security -std=3Dgnu89 -=
mno-sse -mno-mmx -mno-sse2 -mno-3dnow -mno-avx -m64 -falign-jumps=3D1 -fali=
gn-loops=3D1 -mno-80387 -mno-fp-ret-in-387 -mtune=3Dgeneric -mno-red-zone -=
mcmodel=3Dkernel -funit-at-a-time -maccumulate-outgoing-args -DCONFIG_AS_CF=
I=3D1 -DCONFIG_AS_CFI_SIGNAL_FRAME=3D1 -DCONFIG_AS_CFI_SECTIONS=3D1 -DCONFI=
G_AS_FXSAVEQ=3D1 -DCONFIG_AS_SSSE3=3D1 -DCONFIG_AS_CRC32=3D1 -DCONFIG_AS_AV=
X=3D1 -pipe -Wno-sign-compare -fno-asynch
>  ronous-unwind-tables -fno-delete-null-pointer-checks -O2 -fno-reorder-bl=
ocks -fno-ipa-cp-clone -Wframe-larger-than=3D2048 -fstack-protector -fno-om=
it-frame-pointer -fno-optimize-sibling-calls -fno-inline-functions-called-o=
nce -Wdeclaration-after-statement -Wno-pointer-sign -fno-strict-overflow -f=
conserve-stack -Werror=3Dimplicit-int -Werror=3Dstrict-prototypes      -DKB=
UILD_BASENAME=3D'"main"'  -DKBUILD_MODNAME=3D'"main"' -c -o init/.tmp_main.=
o init/main.c

Command line looks fine: -fstack-protector is present.

> arch/x86/Makefile:133: stack-protector enabled but compiler support broke=
n

Well that confirms what I was suspecting: the stack protector support
in your compiler is broken. :) This is the result of the check done in
scripts/gcc-x86_64-has-stack-protector.sh:

echo "int foo(void) { char X[200]; return 3; }" | $* -S -x c -c -O0
-mcmodel=3Dkernel -fstack-protector - -o - 2> /dev/null | grep -q "%gs"
if [ "$?" -eq "0" ] ; then
        echo y
else
        echo n
fi

where $* is from arch/x86/Makefile:

ifdef CONFIG_CC_STACKPROTECTOR
        cc_has_sp :=3D $(srctree)/scripts/gcc-x86_$(BITS)-has-stack-protect=
or.sh
        ifneq ($(shell $(CONFIG_SHELL) $(cc_has_sp) $(CC)
$(KBUILD_CPPFLAGS) $(biarch)),y)
                $(warning stack-protector enabled but compiler support brok=
en)
        endif
endif


> arch/x86/Makefile:148: CONFIG_X86_X32 enabled but no binutils support
> Makefile:687: Cannot use CONFIG_KCOV: -fsanitize-coverage=3Dtrace-pc is n=
ot supported by compiler
> Makefile:1041: "Cannot use CONFIG_STACK_VALIDATION, please install libelf=
-dev or elfutils-libelf-devel"
>
> We still have -fstack-protector but at least we got a build-time warning
> this time.
>
> akpm3:/usr/src/25> nm init/main.o | grep chk
>                  U __stack_chk_fail
>                  U __stack_chk_guard
>
> The build system should be handling this automatically - we shouldn't
> be failing the build and then requiring the user to go fiddle Kconfig.

Well... so, this is a similar problem to what I faced when adding
-fstack-protector-strong. I haven't found a way to reject a config
that isn't supported by the compiler without breaking the ability to
load the config at all. As such, the best that seems to be able to be
done is to emit a warning about WHY your build is about to fail, and
then letting the build fail.

It's not acceptable to just silently disable the CONFIG, as I outlined
in the CC_STACKPROTECTOR Makefile section:

# Additionally, we don't want to fallback and/or silently change which comp=
iler
# flags will be used, since that leads to producing kernels with different
# security feature characteristics depending on the compiler used. ("But I
# selected CC_STACKPROTECTOR_STRONG! Why did it build with _REGULAR?!")
#
# The middle ground is to warn here so that the failed option is obvious, b=
ut
# to let the build fail with bad compiler flags so that we can't produce a
# kernel when there is a CONFIG and compiler mismatch.

In this case, it's that your gcc-4.4.4 is producing a broken stack
protector, and the best the kernel can do is tell you it's broken and
let the build fail.

(Did your gcc-4.4.4 ever build with CONFIG_CC_STACKPROTECTOR enabled?)

-Kees

--=20
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
