Date: Thu, 10 Jul 2003 00:59:27 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.74-mm3 - apm_save_cpus() Macro still bombs out
Message-ID: <20030710075927.GS15452@holomorphy.com>
References: <20030708223548.791247f5.akpm@osdl.org> <200307091106.00781.schlicht@uni-mannheim.de> <20030709021849.31eb3aec.akpm@osdl.org> <1057815890.22772.19.camel@www.piet.net> <20030710060841.GQ15452@holomorphy.com> <20030710071035.GR15452@holomorphy.com> <20030710001853.5a3597b7.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030710001853.5a3597b7.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: piet@www.piet.net, schlicht@uni-mannheim.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III <wli@holomorphy.com> wrote:
>>  -#define apm_save_cpus()	0
>>  +#define apm_save_cpus()	({ cpumask_t __mask__ = CPU_MASK_NONE; __mask__; })

On Thu, Jul 10, 2003 at 12:18:53AM -0700, Andrew Morton wrote:
> Taking a look at what the APM code is actually doing, I think using
> current->cpus_allowed just more sense in here.
> Not that it matters at all.

Going beyond pure substitution:


diff -prauN mm3-2.5.74-1/arch/i386/kernel/apm.c mm3-2.5.74-apm-1/arch/i386/kernel/apm.c
--- mm3-2.5.74-1/arch/i386/kernel/apm.c	2003-07-09 00:03:25.000000000 -0700
+++ mm3-2.5.74-apm-1/arch/i386/kernel/apm.c	2003-07-10 00:53:51.000000000 -0700
@@ -506,8 +506,6 @@ static void apm_error(char *str, int err
  * Lock APM functionality to physical CPU 0
  */
  
-#ifdef CONFIG_SMP
-
 static cpumask_t apm_save_cpus(void)
 {
 	cpumask_t x = current->cpus_allowed;
@@ -522,17 +520,6 @@ static inline void apm_restore_cpus(cpum
 	set_cpus_allowed(current, mask);
 }
 
-#else
-
-/*
- *	No CPU lockdown needed on a uniprocessor
- */
- 
-#define apm_save_cpus()	0
-#define apm_restore_cpus(x)	(void)(x)
-
-#endif
-
 /*
  * These are the actual BIOS calls.  Depending on APM_ZERO_SEGS and
  * apm_info.allow_ints, we are being really paranoid here!  Not only
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
