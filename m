Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id AE2D96B01F1
	for <linux-mm@kvack.org>; Mon, 16 Aug 2010 02:03:38 -0400 (EDT)
Date: Mon, 16 Aug 2010 08:00:49 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch 2/2] oom: kill all threads sharing oom killed task's mm
Message-ID: <20100816060049.GB9498@redhat.com>
References: <alpine.DEB.2.00.1008142128050.31510@chino.kir.corp.google.com> <alpine.DEB.2.00.1008142130260.31510@chino.kir.corp.google.com> <20100815154531.GB3531@redhat.com> <alpine.DEB.2.00.1008151425271.8727@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1008151425271.8727@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 08/15, David Rientjes wrote:
>
> On Sun, 15 Aug 2010, Oleg Nesterov wrote:
>
> > Again, I do not know how the code looks without the patch, but
>
> Why not?  This series is based on Linus' tree.

OK, thanks...

> > > +	do_each_thread(g, q) {
> > > +		if (q->mm == mm && !same_thread_group(q, p))
> > > +			force_sig(SIGKILL, q);
> > > +	} while_each_thread(g, q);
> >
> > We can kill the wrong task. "q->mm == mm" doesn't necessarily mean
> > we found the task which shares ->mm with p (see above).
> >
> > This needs atomic_inc(mm_users). And please do not use do_each_thread.
>
> Instead of using mm_users to pin the mm, we could simply do this iteration
> with for_each_process() before sending the SIGKILL to p.

Yes, this should work too. (I'd prefer to not take ->siglock under
task->alloc_lock, but currently this is correct and happens anyway).

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
