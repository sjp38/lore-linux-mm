Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id BDB7D6B0253
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 06:20:27 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so224114267wic.1
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 03:20:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j6si9594935wjf.167.2015.10.14.03.20.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 Oct 2015 03:20:26 -0700 (PDT)
Date: Wed, 14 Oct 2015 12:20:22 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [RFC v2 07/18] kthread: Allow to cancel kthread work
Message-ID: <20151014102022.GA2880@pathway.suse.cz>
References: <1442840639-6963-8-git-send-email-pmladek@suse.com>
 <20150922193513.GE17659@mtj.duckdns.org>
 <20150925112617.GA3122@pathway.suse.cz>
 <20150928170314.GF2589@mtj.duckdns.org>
 <20151002154336.GC3122@pathway.suse.cz>
 <20151002192453.GA7564@mtj.duckdns.org>
 <20151005100758.GK9603@pathway.suse.cz>
 <20151005110924.GL9603@pathway.suse.cz>
 <20151007092130.GD3122@pathway.suse.cz>
 <20151007142446.GA2012@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151007142446.GA2012@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 2015-10-07 07:24:46, Tejun Heo wrote:
>  At each turn, you come up with non-issues and declare that it needs to
> be full workqueue-like implementation but the issues you're raising
> seem all rather irrelevant.  Can you please try to take a step back
> and put some distance from the implementation details of workqueue?

JFYI, I do a step back and am trying to convert more kthreads to
the kthread worker API. It helps me to get better insight into
the problematic.

I am still not sure where you see the difference between
workqueues and the kthread worker API. My view is that
the main differences are:

Workqueues			Kthread worker

  + pool of kthreads		  + dedicated kthread

  + kthreads created and	  + kthread created and
    destroyed on demand		    destroyed with the worker

  + can proceed more works	  + one work is proceed at a time
    in parallel from one queue

Otherwise, similar basic set of operations would be useful:

  + create_worker
  + queue_work, queue_delayed_work
  + mod_delayed_work
  + cancel_work, cancel_delayed_work
  + flush_work
  + flush_worker
  + drain_worker
  + destroy_worker

, where queue, mod, cancel operations should work also from IRQ
context.

There are few potentially complicated and sensitive users of the
kthread workers API, e.g. handling nfs callbacks, some kthreads
used for handling network packets, eventually the rcu stuff.
Here the operations need to be secure and rather fast.

IMHO, it would be great if it is easy to convert between the
kthread worker and workqueues API. It will allow to choose
the most effective variant for a given purpose. IMHO, this is
sometimes hard to say without real life testing.

I wonder if I miss some important angle of view.


In each case, it is still not clear if the API will be acceptable
for the affected parties. Therefore I do not want to spend too
much time on perfectionalizing the API implementation at this
point. Is it OK, please?

Thanks for feedback.

Best Regards,
Petr


PS: I am not convinced that all my concerns were non-issues.
For example, I agree that a race when queuing the same work
to more kthread workers might look theoretical. On the other
hand, the API allows it and it might be hard to debug. IMHO,
it might be an acceptable trade off if the implementation is
much easier and more secure in other areas. But my draft
implementation did not suggested this.

For example, there were more situations when I needed to double
check that the work was still connected with the locked worker
after taking the lock. I know that it will not happen when
the API is used a reasonable way but...

Ah, I am back in the details. I have to stop it for now ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
