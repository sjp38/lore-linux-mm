Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id EAE386B0254
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 06:43:23 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id p66so21172967wmp.1
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 03:43:23 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id em7si1313607wjd.150.2015.12.15.03.43.22
        for <linux-mm@kvack.org>;
        Tue, 15 Dec 2015 03:43:22 -0800 (PST)
Date: Tue, 15 Dec 2015 12:43:14 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCHV2 2/3] x86, ras: Extend machine check recovery code to
 annotated ring0 areas
Message-ID: <20151215114314.GD25973@pd.tnic>
References: <cover.1449861203.git.tony.luck@intel.com>
 <e8029c58c7d4b5094ec274c78dee01d390317d4d.1449861203.git.tony.luck@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <e8029c58c7d4b5094ec274c78dee01d390317d4d.1449861203.git.tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

On Thu, Dec 10, 2015 at 04:14:44PM -0800, Tony Luck wrote:
> Extend the severity checking code to add a new context IN_KERN_RECOV
> which is used to indicate that the machine check was triggered by code
> in the kernel with a fixup entry.
> 
> Add code to check for this situation and respond by altering the return
> IP to the fixup address and changing the regs->ax so that the recovery
> code knows the physical address of the error. Note that we also set bit
> 63 because 0x0 is a legal physical address.
> 
> Major re-work to the tail code in do_machine_check() to make all this
> readable/maintainable. One functional change is that tolerant=3 no longer
> stops recovery actions. Revert to only skipping sending SIGBUS to the
> current process.
> 
> Signed-off-by: Tony Luck <tony.luck@intel.com>
> ---
>  arch/x86/kernel/cpu/mcheck/mce-severity.c | 22 +++++++++-
>  arch/x86/kernel/cpu/mcheck/mce.c          | 69 ++++++++++++++++---------------
>  2 files changed, 55 insertions(+), 36 deletions(-)
> 
> diff --git a/arch/x86/kernel/cpu/mcheck/mce-severity.c b/arch/x86/kernel/cpu/mcheck/mce-severity.c
> index 9c682c222071..ac7fbb0689fb 100644
> --- a/arch/x86/kernel/cpu/mcheck/mce-severity.c
> +++ b/arch/x86/kernel/cpu/mcheck/mce-severity.c
> @@ -12,6 +12,7 @@
>  #include <linux/kernel.h>
>  #include <linux/seq_file.h>
>  #include <linux/init.h>
> +#include <linux/module.h>
>  #include <linux/debugfs.h>
>  #include <asm/mce.h>
>  
> @@ -29,7 +30,7 @@
>   * panic situations)
>   */
>  
> -enum context { IN_KERNEL = 1, IN_USER = 2 };
> +enum context { IN_KERNEL = 1, IN_USER = 2, IN_KERNEL_RECOV = 3 };
>  enum ser { SER_REQUIRED = 1, NO_SER = 2 };
>  enum exception { EXCP_CONTEXT = 1, NO_EXCP = 2 };
>  
> @@ -48,6 +49,7 @@ static struct severity {
>  #define MCESEV(s, m, c...) { .sev = MCE_ ## s ## _SEVERITY, .msg = m, ## c }
>  #define  KERNEL		.context = IN_KERNEL
>  #define  USER		.context = IN_USER
> +#define  KERNEL_RECOV	.context = IN_KERNEL_RECOV
>  #define  SER		.ser = SER_REQUIRED
>  #define  NOSER		.ser = NO_SER
>  #define  EXCP		.excp = EXCP_CONTEXT
> @@ -87,6 +89,10 @@ static struct severity {
>  		EXCP, KERNEL, MCGMASK(MCG_STATUS_RIPV, 0)
>  		),
>  	MCESEV(
> +		PANIC, "In kernel and no restart IP",
> +		EXCP, KERNEL_RECOV, MCGMASK(MCG_STATUS_RIPV, 0)
> +		),
> +	MCESEV(
>  		DEFERRED, "Deferred error",
>  		NOSER, MASK(MCI_STATUS_UC|MCI_STATUS_DEFERRED|MCI_STATUS_POISON, MCI_STATUS_DEFERRED)
>  		),
> @@ -123,6 +129,11 @@ static struct severity {
>  		MCGMASK(MCG_STATUS_RIPV|MCG_STATUS_EIPV, MCG_STATUS_RIPV)
>  		),
>  	MCESEV(
> +		AR, "Action required: data load error recoverable area of kernel",

						 ... in ...

> +		SER, MASK(MCI_STATUS_OVER|MCI_UC_SAR|MCI_ADDR|MCACOD, MCI_UC_SAR|MCI_ADDR|MCACOD_DATA),
> +		KERNEL_RECOV
> +		),
> +	MCESEV(
>  		AR, "Action required: data load error in a user process",
>  		SER, MASK(MCI_STATUS_OVER|MCI_UC_SAR|MCI_ADDR|MCACOD, MCI_UC_SAR|MCI_ADDR|MCACOD_DATA),
>  		USER
> @@ -170,6 +181,9 @@ static struct severity {
>  		)	/* always matches. keep at end */
>  };
>  
> +#define mc_recoverable(mcg) (((mcg) & (MCG_STATUS_RIPV|MCG_STATUS_EIPV)) == \
> +				(MCG_STATUS_RIPV|MCG_STATUS_EIPV))
> +
>  /*
>   * If mcgstatus indicated that ip/cs on the stack were
>   * no good, then "m->cs" will be zero and we will have
> @@ -183,7 +197,11 @@ static struct severity {
>   */
>  static int error_context(struct mce *m)
>  {
> -	return ((m->cs & 3) == 3) ? IN_USER : IN_KERNEL;
> +	if ((m->cs & 3) == 3)
> +		return IN_USER;
> +	if (mc_recoverable(m->mcgstatus) && search_mcexception_tables(m->ip))
> +		return IN_KERNEL_RECOV;
> +	return IN_KERNEL;
>  }
>  
>  /*
> diff --git a/arch/x86/kernel/cpu/mcheck/mce.c b/arch/x86/kernel/cpu/mcheck/mce.c
> index 9d014b82a124..f2f568ad6409 100644
> --- a/arch/x86/kernel/cpu/mcheck/mce.c
> +++ b/arch/x86/kernel/cpu/mcheck/mce.c
> @@ -31,6 +31,7 @@
>  #include <linux/types.h>
>  #include <linux/slab.h>
>  #include <linux/init.h>
> +#include <linux/module.h>
>  #include <linux/kmod.h>
>  #include <linux/poll.h>
>  #include <linux/nmi.h>
> @@ -958,6 +959,20 @@ static void mce_clear_state(unsigned long *toclear)
>  	}
>  }
>  
> +static int do_memory_failure(struct mce *m)
> +{
> +	int flags = MF_ACTION_REQUIRED;
> +	int ret;
> +
> +	pr_err("Uncorrected hardware memory error in user-access at %llx", m->addr);
> +	if (!(m->mcgstatus & MCG_STATUS_RIPV))
> +		flags |= MF_MUST_KILL;
> +	ret = memory_failure(m->addr >> PAGE_SHIFT, MCE_VECTOR, flags);
> +	if (ret)
> +		pr_err("Memory error not recovered");
> +	return ret;
> +}
> +
>  /*
>   * The actual machine check handler. This only handles real
>   * exceptions when something got corrupted coming in through int 18.
> @@ -995,8 +1010,6 @@ void do_machine_check(struct pt_regs *regs, long error_code)
>  	DECLARE_BITMAP(toclear, MAX_NR_BANKS);
>  	DECLARE_BITMAP(valid_banks, MAX_NR_BANKS);
>  	char *msg = "Unknown";
> -	u64 recover_paddr = ~0ull;
> -	int flags = MF_ACTION_REQUIRED;
>  	int lmce = 0;
>  
>  	ist_enter(regs);
> @@ -1123,22 +1136,13 @@ void do_machine_check(struct pt_regs *regs, long error_code)
>  	}
>  
>  	/*
> -	 * At insane "tolerant" levels we take no action. Otherwise
> -	 * we only die if we have no other choice. For less serious
> -	 * issues we try to recover, or limit damage to the current
> -	 * process.
> +	 * If tolerant is at an insane level we drop requests to kill
> +	 * processes and continue even when there is no way out
								^
								|
								. Fullstop here. 

>  	 */
> -	if (cfg->tolerant < 3) {
> -		if (no_way_out)
> -			mce_panic("Fatal machine check on current CPU", &m, msg);
> -		if (worst == MCE_AR_SEVERITY) {
> -			recover_paddr = m.addr;
> -			if (!(m.mcgstatus & MCG_STATUS_RIPV))
> -				flags |= MF_MUST_KILL;
> -		} else if (kill_it) {
> -			force_sig(SIGBUS, current);
> -		}
> -	}
> +	if (cfg->tolerant == 3)

Btw, I don't see where we limit the input values for that tolerant
setting, i.e., user could easily enter something > 3.

I think we should add a check in a separate patch to not allow anything
except [0-3].

> +		kill_it = 0;
> +	else if (no_way_out)
> +		mce_panic("Fatal machine check on current CPU", &m, msg);
>  
>  	if (worst > 0)
>  		mce_report_event(regs);
> @@ -1146,25 +1150,22 @@ void do_machine_check(struct pt_regs *regs, long error_code)
>  out:
>  	sync_core();
>  
> -	if (recover_paddr == ~0ull)
> -		goto done;
> +	/* Fault was in user mode and we need to take some action */
> +	if ((m.cs & 3) == 3 && (worst == MCE_AR_SEVERITY || kill_it)) {
> +		ist_begin_non_atomic(regs);
> +		local_irq_enable();
>  
> -	pr_err("Uncorrected hardware memory error in user-access at %llx",
> -		 recover_paddr);
> -	/*
> -	 * We must call memory_failure() here even if the current process is
> -	 * doomed. We still need to mark the page as poisoned and alert any
> -	 * other users of the page.
> -	 */
> -	ist_begin_non_atomic(regs);
> -	local_irq_enable();
> -	if (memory_failure(recover_paddr >> PAGE_SHIFT, MCE_VECTOR, flags) < 0) {
> -		pr_err("Memory error not recovered");
> -		force_sig(SIGBUS, current);
> +		if (kill_it || do_memory_failure(&m))
> +			force_sig(SIGBUS, current);
> +		local_irq_disable();
> +		ist_end_non_atomic();
>  	}
> -	local_irq_disable();
> -	ist_end_non_atomic();
> -done:
> +
> +	/* Fault was in recoverable area of the kernel */
> +	if ((m.cs & 3) != 3 && worst == MCE_AR_SEVERITY)
> +		if (!fixup_mcexception(regs, m.addr))
> +			mce_panic("Failed kernel mode recovery", &m, NULL);
				   ^^^^^^^^^^^^^^^^^^^^^^^^^^^

Does that always imply a failed kernel mode recovery? I don't see

	(m.cs == 0 and MCE_AR_SEVERITY)

MCEs always meaning that a recovery should be attempted there. I think
this should simply say

	mce_panic("Fatal machine check on current CPU", &m, msg);

Also, how about taking out that worst and kill_it check. It is a bit
more readable this way IMO:

---
out:
        sync_core();

        if (worst < MCE_AR_SEVERITY && !kill_it)
                goto out_ist;

        /* Fault was in user mode and we need to take some action */
        if ((m.cs & 3) == 3) {
                ist_begin_non_atomic(regs);
                local_irq_enable();

                if (kill_it || do_memory_failure(&m))
                        force_sig(SIGBUS, current);

                local_irq_disable();
                ist_end_non_atomic();
        } else {
                if (!fixup_mcexception(regs, m.addr))
                        mce_panic("Fatal machine check on current CPU", &m, NULL);
        }

out_ist:
        ist_exit(regs);
}
EXPORT_SYMBOL_GPL(do_machine_check);
---

Hmm...

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
