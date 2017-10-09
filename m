Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1D6C56B0268
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 11:50:07 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e26so47571391pfd.4
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 08:50:07 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0129.outbound.protection.outlook.com. [104.47.2.129])
        by mx.google.com with ESMTPS id u12si6838375plz.134.2017.10.09.08.50.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 09 Oct 2017 08:50:05 -0700 (PDT)
Subject: Re: [PATCH v2 2/3] Makefile: support flag
 -fsanitizer-coverage=trace-cmp
References: <20171009150521.82775-1-glider@google.com>
 <20171009150521.82775-2-glider@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <0e1d9dbe-6c09-979d-e0ba-c39368028cbf@virtuozzo.com>
Date: Mon, 9 Oct 2017 18:53:06 +0300
MIME-Version: 1.0
In-Reply-To: <20171009150521.82775-2-glider@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, akpm@linux-foundation.org, mark.rutland@arm.com, alex.popov@linux.com, quentin.casasnovas@oracle.com, dvyukov@google.com, andreyknvl@google.com, keescook@chromium.org, vegard.nossum@oracle.com
Cc: syzkaller@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 10/09/2017 06:05 PM, Alexander Potapenko wrote:

> v2: - updated KCOV_ENABLE_COMPARISONS description
> ---
>  Makefile             |  5 +++--
>  lib/Kconfig.debug    | 10 ++++++++++
>  scripts/Makefile.lib |  6 ++++++
>  3 files changed, 19 insertions(+), 2 deletions(-)
> 
> diff --git a/Makefile b/Makefile
> index 2835863bdd5a..c2a8e56df748 100644
> --- a/Makefile
> +++ b/Makefile
> @@ -374,7 +374,7 @@ AFLAGS_KERNEL	=
>  LDFLAGS_vmlinux =
>  CFLAGS_GCOV	:= -fprofile-arcs -ftest-coverage -fno-tree-loop-im $(call cc-disable-warning,maybe-uninitialized,)
>  CFLAGS_KCOV	:= $(call cc-option,-fsanitize-coverage=trace-pc,)
> -
> +CFLAGS_KCOV_COMPS := $(call cc-option,-fsanitize-coverage=trace-cmp,)
>  
>  # Use USERINCLUDE when you must reference the UAPI directories only.
>  USERINCLUDE    := \
> @@ -420,7 +420,7 @@ export MAKE AWK GENKSYMS INSTALLKERNEL PERL PYTHON UTS_MACHINE
>  export HOSTCXX HOSTCXXFLAGS LDFLAGS_MODULE CHECK CHECKFLAGS
>  
>  export KBUILD_CPPFLAGS NOSTDINC_FLAGS LINUXINCLUDE OBJCOPYFLAGS LDFLAGS
> -export KBUILD_CFLAGS CFLAGS_KERNEL CFLAGS_MODULE CFLAGS_GCOV CFLAGS_KCOV CFLAGS_KASAN CFLAGS_UBSAN
> +export KBUILD_CFLAGS CFLAGS_KERNEL CFLAGS_MODULE CFLAGS_GCOV CFLAGS_KCOV CFLAGS_KCOV_COMPS CFLAGS_KASAN CFLAGS_UBSAN
>  export KBUILD_AFLAGS AFLAGS_KERNEL AFLAGS_MODULE
>  export KBUILD_AFLAGS_MODULE KBUILD_CFLAGS_MODULE KBUILD_LDFLAGS_MODULE
>  export KBUILD_AFLAGS_KERNEL KBUILD_CFLAGS_KERNEL
> @@ -822,6 +822,7 @@ KBUILD_CFLAGS   += $(call cc-option,-Werror=designated-init)
>  KBUILD_ARFLAGS := $(call ar-option,D)
>  
>  include scripts/Makefile.kasan
> +include scripts/Makefile.kcov

scripts/Makefile.kcov doesn't exist.



> diff --git a/scripts/Makefile.lib b/scripts/Makefile.lib
> index 5e975fee0f5b..7ddd5932c832 100644
> --- a/scripts/Makefile.lib
> +++ b/scripts/Makefile.lib
> @@ -142,6 +142,12 @@ _c_flags += $(if $(patsubst n%,, \
>  	$(CFLAGS_KCOV))
>  endif
>  
> +ifeq ($(CONFIG_KCOV_ENABLE_COMPARISONS),y)
> +_c_flags += $(if $(patsubst n%,, \
> +	$(KCOV_INSTRUMENT_$(basetarget).o)$(KCOV_INSTRUMENT)$(CONFIG_KCOV_INSTRUMENT_ALL)), \
> +	$(CFLAGS_KCOV_COMPS))
> +endif
> +

Instead of this you could simply add -fsanitize-coverage=trace-cmp to CFLAGS_KCOV.


>  # If building the kernel in a separate objtree expand all occurrences
>  # of -Idir to -I$(srctree)/dir except for absolute paths (starting with '/').
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
