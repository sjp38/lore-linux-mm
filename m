Date: Thu, 10 Jul 2003 00:10:35 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.74-mm3 - apm_save_cpus() Macro still bombs out
Message-ID: <20030710071035.GR15452@holomorphy.com>
References: <20030708223548.791247f5.akpm@osdl.org> <200307091106.00781.schlicht@uni-mannheim.de> <20030709021849.31eb3aec.akpm@osdl.org> <1057815890.22772.19.camel@www.piet.net> <20030710060841.GQ15452@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030710060841.GQ15452@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Piet Delaney <piet@www.piet.net>, Andrew Morton <akpm@osdl.org>, Thomas Schlichter <schlicht@uni-mannheim.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 09, 2003 at 10:44:50PM -0700, Piet Delaney wrote:
>> I'll settle for Matt Mackall <mpm@selenic.com> fix for now:
>>     +#define apm_save_cpus()        (current->cpus_allowed)
>> I wonder why other, like Thomas Schlichter <schlicht@uni-mannheim.de>,
>> had no problem with the CPU_MASK_NONE fix.
>> I tried adding the #include <linux/cpumask.h> that Marc-Christian
>> Petersen <m.c.p@wolk-project.de> sugested but it didn't help. Looks
>> like Jan De Luyck <lkml@kcore.org> had a similar result. 

On Wed, Jul 09, 2003 at 11:08:41PM -0700, William Lee Irwin III wrote:
> Ugh. Fixing.


diff -prauN mm3-2.5.74-1/arch/i386/kernel/apm.c mm3-2.5.74-apm-1/arch/i386/kernel/apm.c
--- mm3-2.5.74-1/arch/i386/kernel/apm.c	2003-07-09 00:03:25.000000000 -0700
+++ mm3-2.5.74-apm-1/arch/i386/kernel/apm.c	2003-07-10 00:03:31.000000000 -0700
@@ -528,7 +528,7 @@ static inline void apm_restore_cpus(cpum
  *	No CPU lockdown needed on a uniprocessor
  */
  
-#define apm_save_cpus()	0
+#define apm_save_cpus()	({ cpumask_t __mask__ = CPU_MASK_NONE; __mask__; })
 #define apm_restore_cpus(x)	(void)(x)
 
 #endif
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
