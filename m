Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 003436B0002
	for <linux-mm@kvack.org>; Tue, 21 May 2013 09:29:44 -0400 (EDT)
Date: Tue, 21 May 2013 16:28:59 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 10/10] kernel: might_fault does not imply might_sleep
Message-ID: <20130521132859.GA3730@redhat.com>
References: <cover.1368702323.git.mst@redhat.com>
 <1f85dc8e6a0149677563a2dfb4cef9a9c7eaa391.1368702323.git.mst@redhat.com>
 <20130516184041.GP19669@dyad.programming.kicks-ass.net>
 <20130519093526.GD19883@redhat.com>
 <20130521115734.GA9554@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130521115734.GA9554@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, David Howells <dhowells@redhat.com>, Hirokazu Takata <takata@linux-m32r.org>, Michal Simek <monstr@monstr.eu>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Chris Metcalf <cmetcalf@tilera.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org, linux-m32r@ml.linux-m32r.org, linux-m32r-ja@ml.linux-m32r.org, microblaze-uclinux@itee.uq.edu.au, linux-am33-list@redhat.com, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, rostedt@goodmis.org

On Tue, May 21, 2013 at 01:57:34PM +0200, Peter Zijlstra wrote:
> On Sun, May 19, 2013 at 12:35:26PM +0300, Michael S. Tsirkin wrote:
> > > > --- a/include/linux/kernel.h
> > > > +++ b/include/linux/kernel.h
> > > > @@ -198,7 +198,6 @@ void might_fault(void);
> > > >  #else
> > > >  static inline void might_fault(void)
> > > >  {
> > > > -	might_sleep();
> > > 
> > > This removes potential resched points for PREEMPT_VOLUNTARY -- was that
> > > intentional?
> > 
> > No it's a bug. Thanks for pointing this out.
> > OK so I guess it should be might_sleep_if(!in_atomic())
> > and this means might_fault would have to move from linux/kernel.h to
> > linux/uaccess.h, since in_atomic() is in linux/hardirq.h
> > 
> > Makes sense?
> 
> So the only difference between PROVE_LOCKING and not should be the
> might_lock_read() thing; so how about something like this?

I was drafting something like this, yes.
There are a bunch of trivial fixes in all arches
to make this work, will post soon.

> ---
>  include/linux/kernel.h  |  7 ++-----
>  include/linux/uaccess.h | 26 ++++++++++++++++++++++++++
>  mm/memory.c             | 14 ++------------
>  3 files changed, 30 insertions(+), 17 deletions(-)
> 
> diff --git a/include/linux/kernel.h b/include/linux/kernel.h
> index e96329c..70812f4 100644
> --- a/include/linux/kernel.h
> +++ b/include/linux/kernel.h
> @@ -194,12 +194,9 @@ extern int _cond_resched(void);
>  	})
>  
>  #ifdef CONFIG_PROVE_LOCKING
> -void might_fault(void);
> +void might_fault_lockdep(void);
>  #else
> -static inline void might_fault(void)
> -{
> -	might_sleep();
> -}
> +static inline void might_fault_lockdep(void) { }
>  #endif
>  
>  extern struct atomic_notifier_head panic_notifier_list;
> diff --git a/include/linux/uaccess.h b/include/linux/uaccess.h
> index 5ca0951..50a2cc9 100644
> --- a/include/linux/uaccess.h
> +++ b/include/linux/uaccess.h
> @@ -38,6 +38,32 @@ static inline void pagefault_enable(void)
>  	preempt_check_resched();
>  }
>  
> +static inline bool __can_fault(void)
> +{
> +	/*
> +	 * Some code (nfs/sunrpc) uses socket ops on kernel memory while
> +	 * holding the mmap_sem, this is safe because kernel memory doesn't
> +	 * get paged out, therefore we'll never actually fault, and the
> +	 * below annotations will generate false positives.
> +	 */
> +	if (segment_eq(get_fs(), KERNEL_DS))
> +		return false;
> +
> +	if (in_atomic() /* || pagefault_disabled() */)
> +		return false;
> +
> +	return true;
> +}
> +
> +static inline void might_fault(void)
> +{
> +	if (!__can_fault())
> +		return;
> +
> +	might_sleep();
> +	might_fault_lockdep();
> +}
> +
>  #ifndef ARCH_HAS_NOCACHE_UACCESS
>  
>  static inline unsigned long __copy_from_user_inatomic_nocache(void *to,
> diff --git a/mm/memory.c b/mm/memory.c
> index 6dc1882..266610c 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -4211,19 +4211,9 @@ void print_vma_addr(char *prefix, unsigned long ip)
>  }
>  
>  #ifdef CONFIG_PROVE_LOCKING
> -void might_fault(void)
> +void might_fault_lockdep(void)
>  {
>  	/*
> -	 * Some code (nfs/sunrpc) uses socket ops on kernel memory while
> -	 * holding the mmap_sem, this is safe because kernel memory doesn't
> -	 * get paged out, therefore we'll never actually fault, and the
> -	 * below annotations will generate false positives.
> -	 */
> -	if (segment_eq(get_fs(), KERNEL_DS))
> -		return;
> -
> -	might_sleep();
> -	/*
>  	 * it would be nicer only to annotate paths which are not under
>  	 * pagefault_disable, however that requires a larger audit and
>  	 * providing helpers like get_user_atomic.
> @@ -4231,7 +4221,7 @@ void might_fault(void)
>  	if (!in_atomic() && current->mm)
>  		might_lock_read(&current->mm->mmap_sem);
>  }
> -EXPORT_SYMBOL(might_fault);
> +EXPORT_SYMBOL(might_fault_lockdep);
>  #endif
>  
>  #if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLBFS)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
