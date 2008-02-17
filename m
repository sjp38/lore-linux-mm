Received: by rv-out-0910.google.com with SMTP id f1so832882rvb.26
        for <linux-mm@kvack.org>; Sat, 16 Feb 2008 22:22:17 -0800 (PST)
Message-ID: <86802c440802162222k47f5bebbhf42fef0f11ce3243@mail.gmail.com>
Date: Sat, 16 Feb 2008 22:22:17 -0800
From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: [PATCH 3/4] x86_64: Fold pda into per cpu area
In-Reply-To: <20080215201640.GA6200@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080201191414.961558000@sgi.com>
	 <20080201191415.450555000@sgi.com> <20080215201640.GA6200@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: travis@sgi.com, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Thomas Gleixner <tglx@linutronix.de>, Jeremy Fitzhardinge <jeremy@goop.org>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Feb 15, 2008 12:16 PM, Ingo Molnar <mingo@elte.hu> wrote:
>
> * travis@sgi.com <travis@sgi.com> wrote:
>
> >  include/asm-generic/vmlinux.lds.h |    2 +
> >  include/linux/percpu.h            |    9 ++++-
>
> couldnt these two generic bits be done separately (perhaps a preparatory
> but otherwise NOP patch pushed upstream straight away) to make
> subsequent patches only touch x86 architecture files?

this patch need to apply to mainline asap.

or you need revert to the patch about include/asm-x86/percpu.h

+#ifdef CONFIG_X86_64
+#include <linux/compiler.h>
+
+/* Same as asm-generic/percpu.h, except that we store the per cpu offset
+   in the PDA. Longer term the PDA and every per cpu variable
+   should be just put into a single section and referenced directly
+   from %gs */
+
+#ifdef CONFIG_SMP
+#include <asm/pda.h>
+
+#define __per_cpu_offset(cpu) (cpu_pda(cpu)->data_offset)
+#define __my_cpu_offset read_pda(data_offset)
+
+#define per_cpu_offset(x) (__per_cpu_offset(x))
+
 #endif
+#include <asm-generic/percpu.h>
+
+DECLARE_PER_CPU(struct x8664_pda, pda);
+
+#else /* CONFIG_X86_64 */

because current tree
in setup_per_cpu_areas will have
     cpu_pda(i)->data_offset = ptr - __per_cpu_start;

but at that time all APs will use cpu_pda for boot cpu...,and APs will
get their pda in do_boot_cpu()

the result is all cpu will have same data_offset, there will share one
per_cpu_data..that is totally wrong!!

that could explain a lot of strange panic ....recently about NUMA...

YH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
