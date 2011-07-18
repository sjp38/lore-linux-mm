Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DE7226B00FB
	for <linux-mm@kvack.org>; Mon, 18 Jul 2011 14:52:49 -0400 (EDT)
Date: Mon, 18 Jul 2011 11:52:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC v2] implement SL*B and stack usercopy runtime checks
Message-Id: <20110718115237.14d96c03.akpm@linux-foundation.org>
In-Reply-To: <20110718183951.GA3748@albatros>
References: <20110703111028.GA2862@albatros>
	<CA+55aFzXEoTyK0Sm-y=6xGmLMWzQiSQ7ELJ2-WL_PrP3r44MSg@mail.gmail.com>
	<20110718183951.GA3748@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasiliy Kulikov <segoon@openwall.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, kernel-hardening@lists.openwall.com, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Mon, 18 Jul 2011 22:39:51 +0400
Vasiliy Kulikov <segoon@openwall.com> wrote:

>   */
>  #define access_ok(type, addr, size) (likely(__range_not_ok(addr, size) == 0))
>  
> +#if defined(CONFIG_FRAME_POINTER)

#ifdef is conventional in this case

> +/*
> + * MUST be always_inline to correctly count stack frame numbers.
> + *
> + * low ----------------------------------------------> high
> + * [saved bp][saved ip][args][local vars][saved bp][saved ip]
> + *		       ^----------------^
> + *		  allow copies only within here
> +*/
> +#undef arch_check_object_on_stack_frame
> +inline static __attribute__((always_inline))

static inline __always_inline

> +bool arch_check_object_on_stack_frame(const void *stack,
> +	     const void *stackend, const void *obj, unsigned long len)
> +{
> +	const void *frame = NULL;
> +	const void *oldframe;
> +
> +	/*
> +	 * Get the kernel_access_ok() caller frame.
> +	 * __builtin_frame_address(0) returns kernel_access_ok() frame
> +	 * as arch_ and stack_ are inline and kernel_ is noinline.
> +	 */
> +	oldframe = __builtin_frame_address(0);
> +	if (oldframe)
> +		frame = __builtin_frame_address(1);
> +
> +	while (stack <= frame && frame < stackend) {
> +		/*
> +		 * If obj + len extends past the last frame, this
> +		 * check won't pass and the next frame will be 0,
> +		 * causing us to bail out and correctly report
> +		 * the copy as invalid.
> +		 */
> +		if (obj + len <= frame) {
> +			/* EBP + EIP */
> +			int protected_regs_size = 2*sizeof(void *);

size_t?

> +			if (obj >= oldframe + protected_regs_size)
> +				return true;
> +			return false;
> +		}
> +		oldframe = frame;
> +		frame = *(const void * const *)frame;
> +	}
> +	return false;
> +}
> +#endif
> +
>  /*
>   * The exception table consists of pairs of addresses: the first is the
>   * address of an instruction that is allowed to fault, and the second is
>
> ...
>
> @@ -205,11 +209,30 @@ static inline unsigned long __must_check copy_from_user(void *to,
>  {
>  	int sz = __compiletime_object_size(to);
>  
> -	if (likely(sz == -1 || sz >= n))
> -		n = _copy_from_user(to, from, n);
> -	else
> +	if (likely(sz == -1 || sz >= n)) {
> +		if (kernel_access_ok(to, n))
> +			n = _copy_from_user(to, from, n);
> +	} else {
>  		copy_from_user_overflow();
> +	}
> +
> +	return n;
> +}
> +
> +#undef copy_from_user_uncheched

typo

> +static inline unsigned long __must_check copy_from_user_uncheched(void *to,

typo

> +					  const void __user *from,
> +					  unsigned long n)
> +{
> +	return _copy_from_user(to, from, n);
> +}
>  
> +#undef copy_to_user_uncheched

typo

> +static inline unsigned long copy_to_user_unchecked(void __user *to,
> +     const void *from, unsigned long n)
> +{
> +	if (access_ok(VERIFY_WRITE, to, n))
> +		n = __copy_to_user(to, from, n);
>  	return n;
>  }
>  
> diff --git a/arch/x86/include/asm/uaccess_64.h b/arch/x86/include/asm/uaccess_64.h
> index 1c66d30..10c5a0a 100644
> --- a/arch/x86/include/asm/uaccess_64.h
> +++ b/arch/x86/include/asm/uaccess_64.h
> @@ -50,8 +50,10 @@ static inline unsigned long __must_check copy_from_user(void *to,
>  	int sz = __compiletime_object_size(to);

size_t? (ssize_t?)

>  	might_fault();
> -	if (likely(sz == -1 || sz >= n))
> -		n = _copy_from_user(to, from, n);
> +	if (likely(sz == -1 || sz >= n)) {
> +		if (kernel_access_ok(to, n))
> +			n = _copy_from_user(to, from, n);
> +	}
>  #ifdef CONFIG_DEBUG_VM
>  	else
>  		WARN(1, "Buffer overflow detected!\n");
>
> ...
>
> --- a/mm/maccess.c
> +++ b/mm/maccess.c
> @@ -3,8 +3,11 @@
>   */
>  #include <linux/module.h>
>  #include <linux/mm.h>
> +#include <linux/sched.h>
>  #include <linux/uaccess.h>
>  
> +extern bool slab_access_ok(const void *ptr, unsigned long len);

no externs in .c - use a header

> +
>  /**
>   * probe_kernel_read(): safely attempt to read from a location
>   * @dst: pointer to the buffer that shall take the data
> @@ -60,3 +63,56 @@ long __probe_kernel_write(void *dst, const void *src, size_t size)
>  	return ret ? -EFAULT : 0;
>  }
>  EXPORT_SYMBOL_GPL(probe_kernel_write);
> +
> +#ifdef CONFIG_DEBUG_RUNTIME_USER_COPY_CHECKS
> +/*
> + * stack_access_ok() checks whether object is on the stack and
> + * whether it fits in a single stack frame (in case arch allows
> + * to learn this information).
> + *
> + * Returns true in cases:
> + * a) object is not a stack object at all
> + * b) object is located on the stack and fits in a single frame
> + *
> + * MUST be inline not to confuse arch_check_object_on_stack_frame.
> + */
> +inline static bool __attribute__((always_inline))

__always_inline

> +stack_access_ok(const void *obj, unsigned long len)
> +{
> +	const void * const stack = task_stack_page(current);
> +	const void * const stackend = stack + THREAD_SIZE;
> +
> +	/* Does obj+len overflow vm space? */
> +	if (unlikely(obj + len < obj))
> +		return false;
> +
> +	/* Does [obj; obj+len) at least touch our stack? */
> +	if (unlikely(obj + len <= stack || stackend <= obj))
> +		return true;
> +
> +	/* Does [obj; obj+len) overflow/underflow the stack? */
> +	if (unlikely(obj < stack || stackend < obj + len))
> +		return false;
> +
> +	return arch_check_object_on_stack_frame(stack, stackend, obj, len);
> +}
> +
> +noinline bool __kernel_access_ok(const void *ptr, unsigned long len)

noinline seems unneeded

> +{
> +	if (!slab_access_ok(ptr, len)) {
> +		pr_alert("slab_access_ok failed, ptr = %p, length = %lu\n",
> +			ptr, len);
> +		dump_stack();
> +		return false;
> +	}
> +	if (!stack_access_ok(ptr, len)) {
> +		pr_alert("stack_access_ok failed, ptr = %p, length = %lu\n",
> +			ptr, len);
> +		dump_stack();
> +		return false;
> +	}
> +
> +	return true;
> +}
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
