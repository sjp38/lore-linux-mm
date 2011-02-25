Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2B7FD8D003A
	for <linux-mm@kvack.org>; Fri, 25 Feb 2011 14:11:43 -0500 (EST)
Received: from mail-iw0-f169.google.com (mail-iw0-f169.google.com [209.85.214.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p1PJB6uH026057
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 25 Feb 2011 11:11:06 -0800
Received: by iwl42 with SMTP id 42so1822118iwl.14
        for <linux-mm@kvack.org>; Fri, 25 Feb 2011 11:11:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110225175314.GD19059@redhat.com>
References: <20101130200129.GG11905@redhat.com> <compat-not-unlikely@mdm.bga.com>
 <20101201182747.GB6143@redhat.com> <20110225175202.GA19059@redhat.com> <20110225175314.GD19059@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 25 Feb 2011 11:10:46 -0800
Message-ID: <AANLkTik8epq5cx8n=k6ocMUfbg9kkUAZ8KL7ZiG4UuoU@mail.gmail.com>
Subject: Re: [PATCH 3/5] exec: unify compat_do_execve() code
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, Milton Miller <miltonm@bga.com>

On Fri, Feb 25, 2011 at 9:53 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> Teach get_arg_ptr() to handle compat =3D T case correctly.

Does it?

> +#ifdef CONFIG_COMPAT
> +int compat_do_execve(char *filename,
> + =A0 =A0 =A0 compat_uptr_t __user *argv,
> + =A0 =A0 =A0 compat_uptr_t __user *envp,
> + =A0 =A0 =A0 struct pt_regs *regs)
> +{
> + =A0 =A0 =A0 return do_execve_common(filename,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (void __use=
r *)argv, (void __user*)envp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 regs, true)=
;
> +}
> +#endif

I really suspect this should be something like

  typedef union {
     compat_uptr_t compat;
     const char __user *native;
   } conditional_user_ptr_t;

  ...

  int compat_do_execve(char *filename,
                  compat_uptr_t argv,
                  compat_uptr_t envp,
                  struct pt_regs *regs)
   {
             return do_execve_common(filename,
                      compat_ptr(argv), compat_ptr(envp), regs);

where that 'do_execve_common()' takes it's arguments as

    union conditional_user_ptr_t __user *argv,
    union conditional_user_ptr_t __user *envp

and then in get_arg_ptr() we do the proper union member dereference
depending on the "compat" flag.

THAT would actually have the type system help us track what is
actually going on, and would clarify the rules. It would also make it
clear that "do_execve_common()" does *not* take some kind of random
pointer to user space (much less a "const char __user *const char
__user *"). It really does take a pointer to user space, but what that
pointer contains in turn depends on the "compat" flag.

IOW, it really acts as a pointer to a user-space union, and I think
we'd be better off having the type show that.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
