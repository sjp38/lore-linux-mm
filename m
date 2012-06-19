Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id A5B1E6B0062
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 02:26:49 -0400 (EDT)
Received: by dakp5 with SMTP id p5so9851347dak.14
        for <linux-mm@kvack.org>; Mon, 18 Jun 2012 23:26:48 -0700 (PDT)
Date: Mon, 18 Jun 2012 23:26:47 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] mm, oom: do not schedule if current has been killed
In-Reply-To: <CAHGf_=pq_UJfr22kYC=vCyEDRKx75zt5eZ27+VcqFZFqc-KHTw@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1206182321160.27620@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1206181807060.13281@chino.kir.corp.google.com> <4FDFDCA7.8060607@jp.fujitsu.com> <alpine.DEB.2.00.1206181918390.13293@chino.kir.corp.google.com> <alpine.DEB.2.00.1206181930550.13293@chino.kir.corp.google.com>
 <CAHGf_=pq_UJfr22kYC=vCyEDRKx75zt5eZ27+VcqFZFqc-KHTw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397155492-112725172-1340087208=:27620"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397155492-112725172-1340087208=:27620
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 19 Jun 2012, KOSAKI Motohiro wrote:

> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -746,10 +746,11 @@ out:
> >        read_unlock(&tasklist_lock);
> >
> >        /*
> > -        * Give "p" a good chance of killing itself before we
> > +        * Give "p" a good chance of exiting before we
> >         * retry to allocate memory unless "p" is current
> >         */
> > -       if (killed && !test_thread_flag(TIF_MEMDIE))
> > +       if (killed && !fatal_signal_pending(current) &&
> > +                     !(current->flags & PF_EXITING))
> >                schedule_timeout_uninterruptible(1);
> >  }
> 
> Why don't check gfp_flags? I think the rule is,
> 
> 1) a thread of newly marked as TIF_MEMDIE
>     -> now it has a capability to access reseve memory. let's immediately retry.
> 2) allocation for GFP_HIGHUSER_MOVABLE
>     -> we can fail to allocate it safely. let's immediately fail.
>         (I suspect we need to change page allocator too)
> 3) GFP_KERNEL and PF_EXITING
>     -> don't retry immediately. It shall fail again. let's wait until
> killed process
>         is exited.
> 

The killed process may exit but it does not guarantee that its memory will 
be freed if it's shared with current.  This is the case that the patch is 
addressing, where right now we unnecessarily schedule if current has been 
killed or is already along the exit path.  We want to retry as soon as 
possible so that either the allocation now succeeds or we can recall the 
oom killer as soon as possible and get TIF_MEMDIE set because we have a 
fatal signal so current may exit in a timely way as well.  The point is 
that if current has either a SIGKILL or is already exiting as it returns 
from the oom killer, it does no good to continue to stall and prevent that 
memory freeing.
--397155492-112725172-1340087208=:27620--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
