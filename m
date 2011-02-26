Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8ED3D8D0039
	for <linux-mm@kvack.org>; Sat, 26 Feb 2011 07:43:57 -0500 (EST)
Date: Sat, 26 Feb 2011 13:35:22 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 0/4 RESEND] exec: unify compat/non-compat code
Message-ID: <20110226123522.GA4416@redhat.com>
References: <20101130200129.GG11905@redhat.com> <compat-not-unlikely@mdm.bga.com> <20101201182747.GB6143@redhat.com> <20110225175202.GA19059@redhat.com> <AANLkTimv6=QuK2+ye=OFCdRN_285GsNc4CnWEQf8OY26@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTimv6=QuK2+ye=OFCdRN_285GsNc4CnWEQf8OY26@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, Milton Miller <miltonm@bga.com>

On 02/25, Linus Torvalds wrote:
>
> On Fri, Feb 25, 2011 at 9:52 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> >> On 12/01, Milton Miller wrote:
> >> >
> >> > > +#ifdef CONFIG_COMPAT
> >> > > +int compat_do_execve(char * filename,
> >> > > + compat_uptr_t __user *argv,
> >> > > + compat_uptr_t __user *envp,
> >> > > + struct pt_regs * regs)
> >> > > +{
> >> > > + return do_execve_common(filename,
> >> > > +                         (void __user*)argv, (void __user*)envp,
> >> >
> >> > Shouldn't these be compat_ptr(argv)?  (makes a difference on s390)
>
> Indeed. The "compat_uptr_t __user *argv" is wrong, and it should be just
>
>     compat_uptr_t argv;
>
> and then every time you turn it into a pointer, it should use
> "compat_ptr(argv)".

Oh, perhaps, and I was thinking about this too. But this is another
issue, no? Or I misunderstood.

First of all, I agree that perhaps it makes sense to change the
signature of compat_do_execve()

	-	compat_do_execve(compat_uptr_t __user *argv)
	+	compat_do_execve(compat_uptr_t argv)

but this has nothing to do with this series. We can do this before
or after ("after" seems simpler").

>  - user passes "compat_uptr_t"

Yes,

>  - the kernel can turn that into "compat_uptr_t __user *" by doing
>
>        compat_uptr_t __user *pptr;
>        pptr = compat_ptr(argv);

Yes! and the kernel already does this before it calls compat_do_execve(),
iow compat_do_execve() gets the result of compat_ptr(compat_ptr_from_user).

>  - the kernel needs to fetch the individual entries with
>
>        compat_uptr_t cuptr = get_user(pptr);
>
>  - the kernel can then turn _those_ into the actual pointers to the string with
>
>        const char __user *str = compat_ptr(cuptr);

Yes, and this is exactly what get_arg_ptr(compat => true) does.

> > So, once again, this should not (and can not) be compat_ptr(argv) afaics.
>
> It can be, and probably should.

Only if we change the signature of compat_do_execve(). With the current
code yet another compat_ptr() is not needed and it is simply wrong, this
is what I meant when I replied to Milton.

> But the low-level s390 wrapper
> function may have done one of the levels already. It probably
> shouldn't, and we _should_ do the "compat_ptr()" thing a the generic C
> level.

Agreed, but currently this compat_ptr() thing belongs to the caller.

IOW. Lets look at the current code. arch/ calls
compat_do_execve(compat_uptr_t __user *argv)->compat_count(argv) which
does get_user(argv) without any conversion, because argv was already
converted or arch/ is buggy.

Both do_execve() and compat_do_execve() accept the valid pointer
which does not need any conversion. But this pointer points to different
things, either to "char*" of "compat_uptr_t".

However, please see my reply to 2-3/5, I agree that this is confusing
and can be cleanuped.

Or do you think I missed something else?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
