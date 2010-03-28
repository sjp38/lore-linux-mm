Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 520F66B01AC
	for <linux-mm@kvack.org>; Sun, 28 Mar 2010 12:29:58 -0400 (EDT)
Date: Sun, 28 Mar 2010 18:28:21 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] oom killer: break from infinite loop
Message-ID: <20100328162821.GA16765@redhat.com>
References: <1269447905-5939-1-git-send-email-anfei.zhou@gmail.com> <20100326150805.f5853d1c.akpm@linux-foundation.org> <20100326223356.GA20833@redhat.com> <20100328145528.GA14622@desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100328145528.GA14622@desktop>
Sender: owner-linux-mm@kvack.org
To: anfei <anfei.zhou@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, rientjes@google.com, kosaki.motohiro@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 03/28, anfei wrote:
>
> On Fri, Mar 26, 2010 at 11:33:56PM +0100, Oleg Nesterov wrote:
>
> > Off-topic, but we shouldn't use force_sig(), SIGKILL doesn't
> > need "force" semantics.
> >
> This may need a dedicated patch, there are some other places to
> force_sig(SIGKILL, ...) too.

Yes, yes, sure.

> > I'd wish I could understand the changelog ;)
> >
> Assume thread A and B are in the same group.  If A runs into the oom,
> and selects B as the victim, B won't exit because at least in exit_mm(),
> it can not get the mm->mmap_sem semaphore which A has already got.

I see. But still I can't understand. To me, the problem is not that
B can't exit, the problem is that A doesn't know it should exit. All
threads should exit and free ->mm. Even if B could exit, this is not
enough. And, to some extent, it doesn't matter if it holds mmap_sem
or not.

Don't get me wrong. Even if I don't understand oom_kill.c the patch
looks obviously good to me, even from "common sense" pov. I am just
curious.

So, my understanding is: we are going to kill the whole thread group
but TIF_MEMDIE is per-thread. Mark the whole thread group as TIF_MEMDIE
so that any thread can notice this flag and (say, __alloc_pages_slowpath)
fail asap.

Is my understanding correct?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
