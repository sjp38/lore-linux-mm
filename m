Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0AFFB6B0003
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 09:28:26 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id d21so3953328pll.12
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 06:28:26 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i12-v6sor852533plk.60.2018.02.23.06.28.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Feb 2018 06:28:24 -0800 (PST)
Subject: Re: [PATCH v2 04/13] Drop a bunch of metag references
References: <20180221233825.10024-5-jhogan@kernel.org>
 <20180223105323.6356-1-jhogan@kernel.org>
From: Guenter Roeck <linux@roeck-us.net>
Message-ID: <95ed23da-960b-8507-3cf8-dfc05143f8ac@roeck-us.net>
Date: Fri, 23 Feb 2018 06:28:20 -0800
MIME-Version: 1.0
In-Reply-To: <20180223105323.6356-1-jhogan@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Hogan <jhogan@kernel.org>, linux-metag@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>, linux-mm@kvack.org

On 02/23/2018 02:53 AM, James Hogan wrote:
> Now that arch/metag/ has been removed, drop a bunch of metag references
> in various codes across the whole tree:
>   - VM_GROWSUP and __VM_ARCH_PECIFIC_1.
>   - MT_METAG_* ELF note types.
>   - METAG Kconfig dependencies (FRAME_POINTER) and ranges
>     (MAX_STACK_SIZE_MB).
>   - metag cases in tools (checkstack.pl, recordmcount.c, perf).
> 
> Signed-off-by: James Hogan <jhogan@kernel.org>
> Acked-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
> Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
> Cc: Alexander Shishkin <alexander.shishkin@linux.intel.com>
> Cc: Jiri Olsa <jolsa@redhat.com>
> Cc: Namhyung Kim <namhyung@kernel.org>
> Cc: Guenter Roeck <linux@roeck-us.net>
> Cc: linux-mm@kvack.org
> Cc: linux-metag@vger.kernel.org

Reviewed-by: Guenter Roeck <linux@roeck-us.net>

> ---
> Changes in v2:
>   - Drop CPUHP_AP_PERF_METAG_STARTING too (Guenter).
> ---
>   include/linux/cpuhotplug.h     |  1 -
>   include/linux/mm.h             |  2 --
>   include/trace/events/mmflags.h |  2 +-
>   include/uapi/linux/elf.h       |  3 ---
>   lib/Kconfig.debug              |  2 +-
>   mm/Kconfig                     |  7 +++----
>   scripts/checkstack.pl          |  4 ----
>   scripts/recordmcount.c         | 20 --------------------
>   tools/perf/perf-sys.h          |  4 ----
>   9 files changed, 5 insertions(+), 40 deletions(-)
> 
> diff --git a/include/linux/cpuhotplug.h b/include/linux/cpuhotplug.h
> index 5172ad0daa7c..c7a950681f3a 100644
> --- a/include/linux/cpuhotplug.h
> +++ b/include/linux/cpuhotplug.h
> @@ -108,7 +108,6 @@ enum cpuhp_state {
>   	CPUHP_AP_PERF_X86_CQM_STARTING,
>   	CPUHP_AP_PERF_X86_CSTATE_STARTING,
>   	CPUHP_AP_PERF_XTENSA_STARTING,
> -	CPUHP_AP_PERF_METAG_STARTING,
>   	CPUHP_AP_MIPS_OP_LOONGSON3_STARTING,
>   	CPUHP_AP_ARM_SDEI_STARTING,
>   	CPUHP_AP_ARM_VFP_STARTING,
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index ad06d42adb1a..ccac10682ce5 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -241,8 +241,6 @@ extern unsigned int kobjsize(const void *objp);
>   # define VM_SAO		VM_ARCH_1	/* Strong Access Ordering (powerpc) */
>   #elif defined(CONFIG_PARISC)
>   # define VM_GROWSUP	VM_ARCH_1
> -#elif defined(CONFIG_METAG)
> -# define VM_GROWSUP	VM_ARCH_1
>   #elif defined(CONFIG_IA64)
>   # define VM_GROWSUP	VM_ARCH_1
>   #elif !defined(CONFIG_MMU)
> diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
> index dbe1bb058c09..a81cffb76d89 100644
> --- a/include/trace/events/mmflags.h
> +++ b/include/trace/events/mmflags.h
> @@ -115,7 +115,7 @@ IF_HAVE_PG_IDLE(PG_idle,		"idle"		)
>   #define __VM_ARCH_SPECIFIC_1 {VM_PAT,     "pat"           }
>   #elif defined(CONFIG_PPC)
>   #define __VM_ARCH_SPECIFIC_1 {VM_SAO,     "sao"           }
> -#elif defined(CONFIG_PARISC) || defined(CONFIG_METAG) || defined(CONFIG_IA64)
> +#elif defined(CONFIG_PARISC) || defined(CONFIG_IA64)
>   #define __VM_ARCH_SPECIFIC_1 {VM_GROWSUP,	"growsup"	}
>   #elif !defined(CONFIG_MMU)
>   #define __VM_ARCH_SPECIFIC_1 {VM_MAPPED_COPY,"mappedcopy"	}
> diff --git a/include/uapi/linux/elf.h b/include/uapi/linux/elf.h
> index 3bf73fb58045..e2535d6dcec7 100644
> --- a/include/uapi/linux/elf.h
> +++ b/include/uapi/linux/elf.h
> @@ -420,9 +420,6 @@ typedef struct elf64_shdr {
>   #define NT_ARM_HW_WATCH	0x403		/* ARM hardware watchpoint registers */
>   #define NT_ARM_SYSTEM_CALL	0x404	/* ARM system call number */
>   #define NT_ARM_SVE	0x405		/* ARM Scalable Vector Extension registers */
> -#define NT_METAG_CBUF	0x500		/* Metag catch buffer registers */
> -#define NT_METAG_RPIPE	0x501		/* Metag read pipeline state */
> -#define NT_METAG_TLS	0x502		/* Metag TLS pointer */
>   #define NT_ARC_V2	0x600		/* ARCv2 accumulator/extra registers */
>   
>   /* Note header in a PT_NOTE section */
> diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
> index 6088408ef26c..d1c523e408e9 100644
> --- a/lib/Kconfig.debug
> +++ b/lib/Kconfig.debug
> @@ -356,7 +356,7 @@ config FRAME_POINTER
>   	bool "Compile the kernel with frame pointers"
>   	depends on DEBUG_KERNEL && \
>   		(CRIS || M68K || FRV || UML || \
> -		 SUPERH || BLACKFIN || MN10300 || METAG) || \
> +		 SUPERH || BLACKFIN || MN10300) || \
>   		ARCH_WANT_FRAME_POINTERS
>   	default y if (DEBUG_INFO && UML) || ARCH_WANT_FRAME_POINTERS
>   	help
> diff --git a/mm/Kconfig b/mm/Kconfig
> index c782e8fb7235..abefa573bcd8 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -627,15 +627,14 @@ config GENERIC_EARLY_IOREMAP
>   config MAX_STACK_SIZE_MB
>   	int "Maximum user stack size for 32-bit processes (MB)"
>   	default 80
> -	range 8 256 if METAG
>   	range 8 2048
>   	depends on STACK_GROWSUP && (!64BIT || COMPAT)
>   	help
>   	  This is the maximum stack size in Megabytes in the VM layout of 32-bit
>   	  user processes when the stack grows upwards (currently only on parisc
> -	  and metag arch). The stack will be located at the highest memory
> -	  address minus the given value, unless the RLIMIT_STACK hard limit is
> -	  changed to a smaller value in which case that is used.
> +	  arch). The stack will be located at the highest memory address minus
> +	  the given value, unless the RLIMIT_STACK hard limit is changed to a
> +	  smaller value in which case that is used.
>   
>   	  A sane initial value is 80 MB.
>   
> diff --git a/scripts/checkstack.pl b/scripts/checkstack.pl
> index cb993801e4b2..eeb9ac8dbcfb 100755
> --- a/scripts/checkstack.pl
> +++ b/scripts/checkstack.pl
> @@ -64,10 +64,6 @@ my (@stack, $re, $dre, $x, $xs, $funcre);
>   		#    2b6c:       4e56 fb70       linkw %fp,#-1168
>   		#  1df770:       defc ffe4       addaw #-28,%sp
>   		$re = qr/.*(?:linkw %fp,|addaw )#-([0-9]{1,4})(?:,%sp)?$/o;
> -	} elsif ($arch eq 'metag') {
> -		#400026fc:       40 00 00 82     ADD       A0StP,A0StP,#0x8
> -		$re = qr/.*ADD.*A0StP,A0StP,\#(0x$x{1,8})/o;
> -		$funcre = qr/^$x* <[^\$](.*)>:$/;
>   	} elsif ($arch eq 'mips64') {
>   		#8800402c:       67bdfff0        daddiu  sp,sp,-16
>   		$re = qr/.*daddiu.*sp,sp,-(([0-9]{2}|[3-9])[0-9]{2})/o;
> diff --git a/scripts/recordmcount.c b/scripts/recordmcount.c
> index 16e086dcc567..8c9691c3329e 100644
> --- a/scripts/recordmcount.c
> +++ b/scripts/recordmcount.c
> @@ -33,20 +33,6 @@
>   #include <string.h>
>   #include <unistd.h>
>   
> -/*
> - * glibc synced up and added the metag number but didn't add the relocations.
> - * Work around this in a crude manner for now.
> - */
> -#ifndef EM_METAG
> -#define EM_METAG      174
> -#endif
> -#ifndef R_METAG_ADDR32
> -#define R_METAG_ADDR32                   2
> -#endif
> -#ifndef R_METAG_NONE
> -#define R_METAG_NONE                     3
> -#endif
> -
>   #ifndef EM_AARCH64
>   #define EM_AARCH64	183
>   #define R_AARCH64_NONE		0
> @@ -538,12 +524,6 @@ do_file(char const *const fname)
>   			gpfx = '_';
>   			break;
>   	case EM_IA_64:	 reltype = R_IA64_IMM64;   gpfx = '_'; break;
> -	case EM_METAG:	 reltype = R_METAG_ADDR32;
> -			 altmcount = "_mcount_wrapper";
> -			 rel_type_nop = R_METAG_NONE;
> -			 /* We happen to have the same requirement as MIPS */
> -			 is_fake_mcount32 = MIPS32_is_fake_mcount;
> -			 break;
>   	case EM_MIPS:	 /* reltype: e_class    */ gpfx = '_'; break;
>   	case EM_PPC:	 reltype = R_PPC_ADDR32;   gpfx = '_'; break;
>   	case EM_PPC64:	 reltype = R_PPC64_ADDR64; gpfx = '_'; break;
> diff --git a/tools/perf/perf-sys.h b/tools/perf/perf-sys.h
> index 36673f98d66b..3eb7a39169f6 100644
> --- a/tools/perf/perf-sys.h
> +++ b/tools/perf/perf-sys.h
> @@ -46,10 +46,6 @@
>   #define CPUINFO_PROC	{"Processor"}
>   #endif
>   
> -#ifdef __metag__
> -#define CPUINFO_PROC	{"CPU"}
> -#endif
> -
>   #ifdef __xtensa__
>   #define CPUINFO_PROC	{"core ID"}
>   #endif
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
