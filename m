Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id E9BF76B0074
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 15:44:43 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id s7so2691567lbd.0
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 12:44:43 -0700 (PDT)
Received: from mail-la0-x233.google.com (mail-la0-x233.google.com [2a00:1450:4010:c03::233])
        by mx.google.com with ESMTPS id sk1si29016762lbb.65.2014.07.24.12.44.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Jul 2014 12:44:42 -0700 (PDT)
Received: by mail-la0-f51.google.com with SMTP id el20so2264902lab.24
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 12:44:41 -0700 (PDT)
Date: Thu, 24 Jul 2014 23:44:38 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [rfc 4/4] prctl: PR_SET_MM -- Introduce PR_SET_MM_MAP operation,
 v3
Message-ID: <20140724194438.GD17876@moon>
References: <20140724164657.452106845@openvz.org>
 <20140724165047.683455139@openvz.org>
 <CAGXu5jL9xMQ3G-pgVneUFqx=v6C7L0-7SBTJ0_bC2B5H0BfeDQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jL9xMQ3G-pgVneUFqx=v6C7L0-7SBTJ0_bC2B5H0BfeDQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andrew Vagin <avagin@openvz.org>, "Eric W. Biederman" <ebiederm@xmission.com>, "H. Peter Anvin" <hpa@zytor.com>, Serge Hallyn <serge.hallyn@canonical.com>, Pavel Emelyanov <xemul@parallels.com>, Vasiliy Kulikov <segoon@openwall.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michael Kerrisk-manpages <mtk.manpages@gmail.com>, Julien Tinnes <jln@google.com>

On Thu, Jul 24, 2014 at 12:31:54PM -0700, Kees Cook wrote:
...
> > +
> > +#ifdef CONFIG_STACK_GROWSUP
> > +       if (may_adjust_brk(rlimit(RLIMIT_STACK),
> > +                          stack_vma->vm_end,
> > +                          prctl_map->start_stack, 0, 0))
> > +#else
> > +       if (may_adjust_brk(rlimit(RLIMIT_STACK),
> > +                          prctl_map->start_stack,
> > +                          stack_vma->vm_start, 0, 0))
> > +#endif
> > +               goto out;
> 
> Ah! Sorry, I missed this use of may_adjust_brk here. Perhaps rename
> it, since we're not checking brk here, and pass the RLIMIT_* value to
> the function, which can look it up itself? "check_vma_rlimit" ?

Yeah, a name is a bit confusing, but I guess check_vma_rlimit() is not
much better ;-) What we do inside -- we test if a sum of two intervals
or arguments in this helper so that it won't care about the logical
context it been called from, but then realized that this would be a way
too much of unneeded complexity. So if noone else pop with better suggestion
on name i'll update it to check_vma_rlimit (because it's more general
in compare to may_adjust_brk :-).

> > +
> > +       /*
> > +        * Finally, make sure the caller has the rights to
> > +        * change /proc/pid/exe link: only local root should
> > +        * be allowed to.
> > +        */
> > +       if (prctl_map->exe_fd != (u32)-1) {
> > +               struct user_namespace *ns = current_user_ns();
> > +               const struct cred *cred = current_cred();
> > +
> > +               if (!uid_eq(cred->uid, make_kuid(ns, 0)) ||
> > +                   !gid_eq(cred->gid, make_kgid(ns, 0)))
> > +                       goto out;
> > +       }
> 
> I got tricked for a moment here. :) I see that even if we pass this
> check, prctl_set_mm_exe_file will still do the additional checks too
> during prctl_set_mm_map. Excellent!

Yeah.

> >
> > +#ifdef CONFIG_CHECKPOINT_RESTORE
> > +       if (opt == PR_SET_MM_MAP || opt == PR_SET_MM_MAP_SIZE)
> > +               return prctl_set_mm_map(opt, (const void __user *)addr, arg4);
> > +#endif
> > +
> >         if (!capable(CAP_SYS_RESOURCE))
> >                 return -EPERM;
> >
> >
> 
> I think this is looking good. Thanks for the refactoring!

Thanks a huge for comments!!!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
