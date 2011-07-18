Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8CC616B00FE
	for <linux-mm@kvack.org>; Mon, 18 Jul 2011 15:33:46 -0400 (EDT)
Received: by ewy9 with SMTP id 9so2568435ewy.14
        for <linux-mm@kvack.org>; Mon, 18 Jul 2011 12:33:43 -0700 (PDT)
Date: Mon, 18 Jul 2011 23:33:38 +0400
From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [kernel-hardening] Re: [RFC v2] implement SL*B and stack
 usercopy runtime checks
Message-ID: <20110718193337.GB4489@albatros>
References: <20110703111028.GA2862@albatros>
 <CA+55aFzXEoTyK0Sm-y=6xGmLMWzQiSQ7ELJ2-WL_PrP3r44MSg@mail.gmail.com>
 <20110718183951.GA3748@albatros>
 <20110718115237.14d96c03.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110718115237.14d96c03.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Mon, Jul 18, 2011 at 11:52 -0700, Andrew Morton wrote:
> On Mon, 18 Jul 2011 22:39:51 +0400
> Vasiliy Kulikov <segoon@openwall.com> wrote:
> 
> >   */
> >  #define access_ok(type, addr, size) (likely(__range_not_ok(addr, size) == 0))
> >  
> > +#if defined(CONFIG_FRAME_POINTER)
> 
> #ifdef is conventional in this case

OK.

> > +/*
> > + * MUST be always_inline to correctly count stack frame numbers.
> > + *
> > + * low ----------------------------------------------> high
> > + * [saved bp][saved ip][args][local vars][saved bp][saved ip]
> > + *		       ^----------------^
> > + *		  allow copies only within here
> > +*/
> > +#undef arch_check_object_on_stack_frame
> > +inline static __attribute__((always_inline))
> 
> static inline __always_inline

OK.

> > +bool arch_check_object_on_stack_frame(const void *stack,
> > +	     const void *stackend, const void *obj, unsigned long len)
> > +{
> > +	const void *frame = NULL;
> > +	const void *oldframe;
> > +
> > +	/*
> > +	 * Get the kernel_access_ok() caller frame.
> > +	 * __builtin_frame_address(0) returns kernel_access_ok() frame
> > +	 * as arch_ and stack_ are inline and kernel_ is noinline.
> > +	 */
> > +	oldframe = __builtin_frame_address(0);
> > +	if (oldframe)
> > +		frame = __builtin_frame_address(1);
> > +
> > +	while (stack <= frame && frame < stackend) {
> > +		/*
> > +		 * If obj + len extends past the last frame, this
> > +		 * check won't pass and the next frame will be 0,
> > +		 * causing us to bail out and correctly report
> > +		 * the copy as invalid.
> > +		 */
> > +		if (obj + len <= frame) {
> > +			/* EBP + EIP */
> > +			int protected_regs_size = 2*sizeof(void *);
> 
> size_t?

Yes, it looks better here.

> > +static inline unsigned long __must_check copy_from_user_uncheched(void *to,
> 
> typo

Oops, sure.

> > diff --git a/arch/x86/include/asm/uaccess_64.h b/arch/x86/include/asm/uaccess_64.h
> > index 1c66d30..10c5a0a 100644
> > --- a/arch/x86/include/asm/uaccess_64.h
> > +++ b/arch/x86/include/asm/uaccess_64.h
> > @@ -50,8 +50,10 @@ static inline unsigned long __must_check copy_from_user(void *to,
> >  	int sz = __compiletime_object_size(to);
> 
> size_t? (ssize_t?)

It doesn't touch my patch, however, ssize_t seems reasonable here.

> >  	might_fault();
> > -	if (likely(sz == -1 || sz >= n))
> > -		n = _copy_from_user(to, from, n);
> > +	if (likely(sz == -1 || sz >= n)) {
> > +		if (kernel_access_ok(to, n))
> > +			n = _copy_from_user(to, from, n);
> > +	}
> >  #ifdef CONFIG_DEBUG_VM
> >  	else
> >  		WARN(1, "Buffer overflow detected!\n");
> >
> > ...
> >
> > --- a/mm/maccess.c
> > +++ b/mm/maccess.c
> > @@ -3,8 +3,11 @@
> >   */
> >  #include <linux/module.h>
> >  #include <linux/mm.h>
> > +#include <linux/sched.h>
> >  #include <linux/uaccess.h>
> >  
> > +extern bool slab_access_ok(const void *ptr, unsigned long len);
> 
> no externs in .c - use a header

I thought it would make less noise.  OK, will do.

> > +noinline bool __kernel_access_ok(const void *ptr, unsigned long len)
> 
> noinline seems unneeded

It is needed here because arch_check_object_on_stack_frame() needs the
precise number of frames it should skip.


Thank you!

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
