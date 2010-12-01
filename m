Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 07F516B00A1
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 13:34:29 -0500 (EST)
Date: Wed, 1 Dec 2010 19:27:47 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: (No subject header)
Message-ID: <20101201182747.GB6143@redhat.com>
References: <20101130200129.GG11905@redhat.com> <compat-not-unlikely@mdm.bga.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <compat-not-unlikely@mdm.bga.com>
Sender: owner-linux-mm@kvack.org
To: Milton Miller <miltonm@bga.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>

On 12/01, Milton Miller wrote:
>
> On Tue, 30 Nov 2010 about 20:01:29 -0000, Oleg Nesterov wrote:
> > Teach get_arg_ptr() to handle compat = T case correctly.
>
> >  #include <asm/uaccess.h>
> >  #include <asm/mmu_context.h>
> > @@ -395,6 +396,18 @@ get_arg_ptr(const char __user * const __
> >  {
> >  	const char __user *ptr;
> >
> > +#ifdef CONFIG_COMPAT
> > +	if (unlikely(compat)) {
>
> This should not be marked unlikely.  Unlikely tells gcc the path
> with over 99% confidence and disables branch predictors on some
> architectures.  If called from a compat processes this will result
> in a mispredicted branch every iteration.  Just use if (compat)
> and let the hardware branch predictors do their job.

This applies to almost every likely/unlikely, and I think that compat
processes should fall into "unlikely category". But I don't really mind,
I can remove this hint, I added it mostly as documentation.

> > +#ifdef CONFIG_COMPAT
> > +int compat_do_execve(char * filename,
> > +	compat_uptr_t __user *argv,
> > +	compat_uptr_t __user *envp,
> > +	struct pt_regs * regs)
> > +{
> > +	return do_execve_common(filename,
> > +				(void __user*)argv, (void __user*)envp,
>
> Shouldn't these be compat_ptr(argv)?  (makes a difference on s390)

I'll recheck, but I don't think so. Please note that compat_ptr()
accepts "compat_uptr_t", not "compat_uptr_t *".

argv should be correct as a pointer to user-space, otherwise the
current code is buggy. For example, compat_do_execve() passes
argv to compat_count() which does get_user(argv) without any
conversion.

IOW, even if this should be fixed, I think this have nothing to
do with this patch. But I'll recheck, thanks.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
