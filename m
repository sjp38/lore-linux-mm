Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 2F8D38D0006
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 13:01:57 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so4878203pbc.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2012 10:01:56 -0800 (PST)
Date: Thu, 6 Dec 2012 10:01:50 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch,v2] bdi: add a user-tunable cpu_list for the bdi flusher
 threads
Message-ID: <20121206180150.GQ19802@htj.dyndns.org>
References: <x49lidfnf0s.fsf@segfault.boston.devel.redhat.com>
 <50BE5988.3050501@fusionio.com>
 <x498v9dpnwu.fsf@segfault.boston.devel.redhat.com>
 <50BE5C99.6070703@fusionio.com>
 <x494nk1pi7h.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x494nk1pi7h.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Jens Axboe <jaxboe@fusionio.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Zach Brown <zab@redhat.com>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo <mingo@redhat.com>

Hello,

On Tue, Dec 04, 2012 at 05:26:26PM -0500, Jeff Moyer wrote:
> I think it's a bit more involved than that.  If you look at
> kthread_create_on_node, the node portion only applies to where the
> memory comes from, it says nothing of scheduling.  To whit:
> 
>                 /*                                                              
>                  * root may have changed our (kthreadd's) priority or CPU mask.
>                  * The kernel thread should not inherit these properties.       
>                  */
>                 sched_setscheduler_nocheck(create.result, SCHED_NORMAL, &param);
>                 set_cpus_allowed_ptr(create.result, cpu_all_mask);
> 
> So, if I were to make the change you suggested, I would be modifying the
> existing behaviour.  The way things stand, I think
> kthread_create_on_node violates the principal of least surprise.  ;-)  I
> would prefer a variant that affected scheduling behaviour as well as
> memory placement.  Tejun, Peter, Ingo, what are your opinions?

Hmmm... cpu binding usually is done by kthread_bind() or explicit
set_cpus_allowed_ptr() by the kthread itself.  The node part of the
API was added later because there was no way to control where the
stack is allocated and we often ended up with kthreads which are bound
to a CPU with stack on a remote node.

I don't know.  @node usually controls memory allocation and it could
be surprising for it to control cpu binding, especially because most
kthreads which are bound to CPU[s] require explicit affinity
management as CPUs go up and down.  I don't know.  Maybe I'm just too
used to the existing interface.

As for the original patch, I think it's a bit too much to expose to
userland.  It's probably a good idea to bind the flusher to the local
node but do we really need to expose an interface to let userland
control the affinity directly?  Do we actually have a use case at
hand?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
