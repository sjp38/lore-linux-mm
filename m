Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 438156B0033
	for <linux-mm@kvack.org>; Thu, 16 May 2013 14:44:36 -0400 (EDT)
Date: Thu, 16 May 2013 20:40:41 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 10/10] kernel: might_fault does not imply might_sleep
Message-ID: <20130516184041.GP19669@dyad.programming.kicks-ass.net>
References: <cover.1368702323.git.mst@redhat.com>
 <1f85dc8e6a0149677563a2dfb4cef9a9c7eaa391.1368702323.git.mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1f85dc8e6a0149677563a2dfb4cef9a9c7eaa391.1368702323.git.mst@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-kernel@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, David Howells <dhowells@redhat.com>, Hirokazu Takata <takata@linux-m32r.org>, Michal Simek <monstr@monstr.eu>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Chris Metcalf <cmetcalf@tilera.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org, linux-m32r@ml.linux-m32r.org, linux-m32r-ja@ml.linux-m32r.org, microblaze-uclinux@itee.uq.edu.au, linux-am33-list@redhat.com, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, rostedt@goodmis.org

On Thu, May 16, 2013 at 02:16:10PM +0300, Michael S. Tsirkin wrote:
> There are several ways to make sure might_fault
> calling function does not sleep.
> One is to use it on kernel or otherwise locked memory - apparently
> nfs/sunrpc does this. As noted by Ingo, this is handled by the
> migh_fault() implementation in mm/memory.c but not the one in
> linux/kernel.h so in the current code might_fault() schedules
> differently depending on CONFIG_PROVE_LOCKING, which is an undesired
> semantical side effect.
> 
> Another is to call pagefault_disable: in this case the page fault
> handler will go to fixups processing and we get an error instead of
> sleeping, so the might_sleep annotation is a false positive.
> vhost driver wants to do this now in order to reuse socket ops
> under a spinlock (and fall back on slower thread handler
> on error).

Are you using the assumption that spin_lock() implies preempt_disable() implies
pagefault_disable()? Note that this assumption isn't valid for -rt where the
spinlock becomes preemptible but we'll not disable pagefaults.

> Address both issues by:
> 	- dropping the unconditional call to might_sleep
> 	  from the fast might_fault code in linux/kernel.h
> 	- checking for pagefault_disable() in the
> 	  CONFIG_PROVE_LOCKING implementation
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  include/linux/kernel.h |  1 -
>  mm/memory.c            | 14 +++++++++-----
>  2 files changed, 9 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/kernel.h b/include/linux/kernel.h
> index e96329c..322b065 100644
> --- a/include/linux/kernel.h
> +++ b/include/linux/kernel.h
> @@ -198,7 +198,6 @@ void might_fault(void);
>  #else
>  static inline void might_fault(void)
>  {
> -	might_sleep();

This removes potential resched points for PREEMPT_VOLUNTARY -- was that
intentional?

>  }
>  #endif
>  
> diff --git a/mm/memory.c b/mm/memory.c
> index 6dc1882..1b8327b 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -4222,13 +4222,17 @@ void might_fault(void)
>  	if (segment_eq(get_fs(), KERNEL_DS))
>  		return;
>  
> -	might_sleep();
>  	/*
> -	 * it would be nicer only to annotate paths which are not under
> -	 * pagefault_disable, however that requires a larger audit and
> -	 * providing helpers like get_user_atomic.
> +	 * It would be nicer to annotate paths which are under preempt_disable
> +	 * but not under pagefault_disable, however that requires a new flag
> +	 * for differentiating between the two.

-rt has this, pagefault_disable() doesn't change the preempt count but pokes
at task_struct::pagefault_disable.

>  	 */
> -	if (!in_atomic() && current->mm)
> +	if (in_atomic())
> +		return;
> +
> +	might_sleep();
> +
> +	if (current->mm)
>  		might_lock_read(&current->mm->mmap_sem);
>  }
>  EXPORT_SYMBOL(might_fault);
> -- 
> MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
