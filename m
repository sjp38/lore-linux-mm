Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id C0F556B0044
	for <linux-mm@kvack.org>; Sat, 24 Mar 2012 12:22:58 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so4408388bkw.14
        for <linux-mm@kvack.org>; Sat, 24 Mar 2012 09:22:56 -0700 (PDT)
Date: Sat, 24 Mar 2012 20:21:52 +0400
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [PATCH 10/10] oom: Make find_lock_task_mm() sparse-aware
Message-ID: <20120324162151.GA3640@lizard>
References: <20120324102609.GA28356@lizard>
 <20120324103127.GJ29067@lizard>
 <1332593574.16159.31.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1332593574.16159.31.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Russell King <linux@arm.linux.org.uk>, Mike Frysinger <vapier@gentoo.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Richard Weinberger <richard@nod.at>, Paul Mundt <lethal@linux-sh.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, John Stultz <john.stultz@linaro.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Sat, Mar 24, 2012 at 01:52:54PM +0100, Peter Zijlstra wrote:
[...]
> > p.s. I know Peter Zijlstra detest the __cond_lock() stuff, but untill
> >      we have anything better in sparse, let's use it. This particular
> >      patch helped me to detect one bug that I myself made during
> >      task->mm fixup series. So, it is useful.
> 
> Yeah, so Nacked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> 
> Also, why didn't lockdep catch it?

Because patch authors test their patches on architectures they own
(well, sometimes I do check patches on exotic architectures w/ qemu,
but it is less convenient than just build/sparse-test the patch w/
a cross compiler).

And since lockdep is a runtime checker, it is not very useful.

Sparse is a build-time checker, so it is even better in the sense
that it is able to catch bugs even in code that is executed rarely.

> Fix sparse already instead of smearing ugly all over.

Just wonder how do you see the feature implemented?

Something like this?

#define __ret_cond_locked(l, c)	__attribute__((ret_cond_locked(l, c)))
#define __ret_value		__attribute__((ret_value))
#define __ret_locked_nonnull(l)	__ret_cond_locked(l, __ret_value);

extern struct task_struct *find_lock_task_mm(struct task_struct *p)
	__ret_locked_nonnull(&__ret_value->alloc_lock);

Thanks,

-- 
Anton Vorontsov
Email: cbouatmailru@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
