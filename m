Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B68BD8D0039
	for <linux-mm@kvack.org>; Sat, 26 Feb 2011 07:46:07 -0500 (EST)
Date: Sat, 26 Feb 2011 13:37:31 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 3/5] exec: unify compat_do_execve() code
Message-ID: <20110226123731.GC4416@redhat.com>
References: <20101130200129.GG11905@redhat.com> <compat-not-unlikely@mdm.bga.com> <20101201182747.GB6143@redhat.com> <20110225175202.GA19059@redhat.com> <20110225175314.GD19059@redhat.com> <AANLkTik8epq5cx8n=k6ocMUfbg9kkUAZ8KL7ZiG4UuoU@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTik8epq5cx8n=k6ocMUfbg9kkUAZ8KL7ZiG4UuoU@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, Milton Miller <miltonm@bga.com>

On 02/25, Linus Torvalds wrote:
>
> On Fri, Feb 25, 2011 at 9:53 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> > Teach get_arg_ptr() to handle compat = T case correctly.
>
> Does it?

I think it does.

> > +#ifdef CONFIG_COMPAT
> > +int compat_do_execve(char *filename,
> > +       compat_uptr_t __user *argv,
> > +       compat_uptr_t __user *envp,
> > +       struct pt_regs *regs)
> > +{
> > +       return do_execve_common(filename,
> > +                               (void __user *)argv, (void __user*)envp,
> > +                               regs, true);
> > +}
> > +#endif
>
> I really suspect this should be something like
>
>   typedef union {
>      compat_uptr_t compat;
>      const char __user *native;
>    } conditional_user_ptr_t;

Personally I don't really like this union, to me "void __user*" looks
better, but I won't insist.

>   int compat_do_execve(char *filename,
>                   compat_uptr_t argv,
>                   compat_uptr_t envp,
>    {
>              return do_execve_common(filename,
>                       compat_ptr(argv), compat_ptr(envp), regs);

Indeed! But, again, this has nothing to do with this series. We can
do this later and change the callers in arch/.

> where that 'do_execve_common()' takes it's arguments as
>
>     union conditional_user_ptr_t __user *argv,
>     union conditional_user_ptr_t __user *envp
>
> and then in get_arg_ptr() we do the proper union member dereference
> depending on the "compat" flag.

Once again, to me "void __user*" looks better (just simpler). In this
case get_arg_ptr() becomes (without const/__user for the clarity)

	void *get_arg_ptr(void **argv, int argc, bool compat)
	{
		char *ptr;

	#ifdef CONFIG_COMPAT
		if (unlikely(compat)) {
			compat_uptr_t *a = argv;
			compat_uptr_t p;

			if (get_user(p, a + argc))
				return ERR_PTR(-EFAULT);

			return compat_ptr(p);
		}
	#endif

		if (get_user(ptr, argv + argc))
			return ERR_PTR(-EFAULT);

		return ptr;
	}

Otherwise, get_arg_ptr() should return conditional_user_ptr_t as well,
this looks like the unnecessary complication to me, but of course this
is subjective.

So, what do you think?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
