Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id DE24F6B0116
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 16:41:40 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id rp8so104827pbb.17
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 13:41:40 -0800 (PST)
Received: from psmtp.com ([74.125.245.147])
        by mx.google.com with SMTP id ph6si156824pbb.97.2013.11.06.13.41.38
        for <linux-mm@kvack.org>;
        Wed, 06 Nov 2013 13:41:39 -0800 (PST)
Subject: Re: [PATCH v3 4/5] MCS Lock: Make mcs_spinlock.h includable in
 other files
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <1383773832.11046.356.camel@schen9-DESK>
References: <cover.1383771175.git.tim.c.chen@linux.intel.com>
	 <1383773832.11046.356.camel@schen9-DESK>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 06 Nov 2013 13:41:33 -0800
Message-ID: <1383774093.11046.358.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, Will Deacon <will.deacon@arm.com>, "Figo.zhang" <figo1802@gmail.com>

On Wed, 2013-11-06 at 13:37 -0800, Tim Chen wrote:
> The following changes are made to enable mcs_spinlock.h file to be
> widely included in other files without causing problem:
> 
> 1) Include a number of prerequisite header files and define
>    arch_mutex_cpu_relax(), if not previously defined.
> 2) Make mcs_spin_unlock() an inlined function and
>    rename mcs_spin_lock() to _raw_mcs_spin_lock() which is also an
>    inlined function.
> 3) Create a new mcs_spinlock.c file to contain the non-inlined
>    mcs_spin_lock() function.
> 
> Signed-off-by: Waiman Long <Waiman.Long@hp.com>
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>

Should be Acked-by: Tim Chen <tim.c.chen@linux.intel.com>

> ---
>  include/linux/mcs_spinlock.h |   27 ++++++++++++++++++++++-----
>  kernel/Makefile              |    6 +++---
>  kernel/mcs_spinlock.c        |   21 +++++++++++++++++++++
>  3 files changed, 46 insertions(+), 8 deletions(-)
>  create mode 100644 kernel/mcs_spinlock.c
> 
> diff --git a/include/linux/mcs_spinlock.h b/include/linux/mcs_spinlock.h
> index 93d445d..f2c71e8 100644
> --- a/include/linux/mcs_spinlock.h
> +++ b/include/linux/mcs_spinlock.h
> @@ -12,11 +12,27 @@
>  #ifndef __LINUX_MCS_SPINLOCK_H
>  #define __LINUX_MCS_SPINLOCK_H
>  
> +/*
> + * asm/processor.h may define arch_mutex_cpu_relax().
> + * If it is not defined, cpu_relax() will be used.
> + */
> +#include <asm/barrier.h>
> +#include <asm/cmpxchg.h>
> +#include <asm/processor.h>
> +#include <linux/compiler.h>
> +
> +#ifndef arch_mutex_cpu_relax
> +# define arch_mutex_cpu_relax() cpu_relax()
> +#endif
> +
>  struct mcs_spinlock {
>  	struct mcs_spinlock *next;
>  	int locked; /* 1 if lock acquired */
>  };
>  
> +extern
> +void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node);
> +
>  /*
>   * In order to acquire the lock, the caller should declare a local node and
>   * pass a reference of the node to this function in addition to the lock.
> @@ -24,11 +40,11 @@ struct mcs_spinlock {
>   * on this node->locked until the previous lock holder sets the node->locked
>   * in mcs_spin_unlock().
>   *
> - * We don't inline mcs_spin_lock() so that perf can correctly account for the
> - * time spent in this lock function.
> + * The _raw_mcs_spin_lock() function should not be called directly. Instead,
> + * users should call mcs_spin_lock().
>   */
> -static noinline
> -void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
> +static inline
> +void _raw_mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
>  {
>  	struct mcs_spinlock *prev;
>  
> @@ -55,7 +71,8 @@ void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
>   * Releases the lock. The caller should pass in the corresponding node that
>   * was used to acquire the lock.
>   */
> -static void mcs_spin_unlock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
> +static inline
> +void mcs_spin_unlock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
>  {
>  	struct mcs_spinlock *next = ACCESS_ONCE(node->next);
>  
> diff --git a/kernel/Makefile b/kernel/Makefile
> index 1ce4755..2ad8454 100644
> --- a/kernel/Makefile
> +++ b/kernel/Makefile
> @@ -50,9 +50,9 @@ obj-$(CONFIG_SMP) += smp.o
>  ifneq ($(CONFIG_SMP),y)
>  obj-y += up.o
>  endif
> -obj-$(CONFIG_SMP) += spinlock.o
> -obj-$(CONFIG_DEBUG_SPINLOCK) += spinlock.o
> -obj-$(CONFIG_PROVE_LOCKING) += spinlock.o
> +obj-$(CONFIG_SMP) += spinlock.o mcs_spinlock.o
> +obj-$(CONFIG_DEBUG_SPINLOCK) += spinlock.o mcs_spinlock.o
> +obj-$(CONFIG_PROVE_LOCKING) += spinlock.o mcs_spinlock.o
>  obj-$(CONFIG_UID16) += uid16.o
>  obj-$(CONFIG_MODULES) += module.o
>  obj-$(CONFIG_MODULE_SIG) += module_signing.o modsign_pubkey.o modsign_certificate.o
> diff --git a/kernel/mcs_spinlock.c b/kernel/mcs_spinlock.c
> new file mode 100644
> index 0000000..3c55626
> --- /dev/null
> +++ b/kernel/mcs_spinlock.c
> @@ -0,0 +1,21 @@
> +/*
> + * MCS lock
> + *
> + * The MCS lock (proposed by Mellor-Crummey and Scott) is a simple spin-lock
> + * with the desirable properties of being fair, and with each cpu trying
> + * to acquire the lock spinning on a local variable.
> + * It avoids expensive cache bouncings that common test-and-set spin-lock
> + * implementations incur.
> + */
> +#include <linux/mcs_spinlock.h>
> +#include <linux/export.h>
> +
> +/*
> + * We don't inline mcs_spin_lock() so that perf can correctly account for the
> + * time spent in this lock function.
> + */
> +void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
> +{
> +	_raw_mcs_spin_lock(lock, node);
> +}
> +EXPORT_SYMBOL_GPL(mcs_spin_lock);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
