Date: Fri, 21 Nov 2008 16:50:54 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH][V2] Make get_user_pages interruptible
In-Reply-To: <604427e00811211643w52d77197nc0d4e5e711d68933@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.0811211649470.22871@chino.kir.corp.google.com>
References: <604427e00811211605j20fd00bby1bac86b4cc3c380b@mail.gmail.com>  <alpine.DEB.2.00.0811211618160.20523@chino.kir.corp.google.com> <604427e00811211643w52d77197nc0d4e5e711d68933@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, akpm <akpm@linux-foundation.org>, Paul Menage <menage@google.com>, Rohit Seth <rohitseth@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Nov 2008, Ying Han wrote:

> >> index 164951c..5d3db5e 100644
> >> --- a/mm/memory.c
> >> +++ b/mm/memory.c
> >> @@ -1218,12 +1218,11 @@ int __get_user_pages(struct task_struct *tsk, struct m
> >>                       struct page *page;
> >>
> >>                       /*
> >> -                      * If tsk is ooming, cut off its access to large memory
> >> -                      * allocations. It has a pending SIGKILL, but it can't
> >> -                      * be processed until returning to user space.
> >> +                      * If we have a pending SIGKILL, don't keep
> >> +                      * allocating memory.
> >>                        */
> >> -                     if (unlikely(test_tsk_thread_flag(tsk, TIF_MEMDIE)))
> >> -                             return i ? i : -ENOMEM;
> >> +                     if (sigkill_pending(current))
> >> +                             return i ? i : -ERESTARTSYS;
> >>
> >>                       if (write)
> >>                               foll_flags |= FOLL_WRITE;
> >>
> >
> > We previously tested tsk for TIF_MEMDIE and not current (in fact, nothing
> > in __get_user_pages() operates on current).  So why are we introducing
> > this check on current and not tsk?
>    Initially, the patch is merely to cause a process stuck in mlock to
> honour a pending sigkill. And in mlock case, tsk==current.
> 

It doesn't matter, __get_user_pages() acts on tsk.

> > Do we want to avoid branch prediction now because there's data suggesting
> > tsk will be SIGKILL'd more frequently in this path other than by the oom
> > killer?
> >
> any specific example?
> 

I'm asking why you removed the unlikely() wrapper.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
