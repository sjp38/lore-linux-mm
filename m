Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 852BC440321
	for <linux-mm@kvack.org>; Mon,  5 Oct 2015 06:08:03 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so106982897wic.1
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 03:08:03 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h2si29898950wjx.151.2015.10.05.03.08.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 05 Oct 2015 03:08:02 -0700 (PDT)
Date: Mon, 5 Oct 2015 12:07:58 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [RFC v2 07/18] kthread: Allow to cancel kthread work
Message-ID: <20151005100758.GK9603@pathway.suse.cz>
References: <1442840639-6963-1-git-send-email-pmladek@suse.com>
 <1442840639-6963-8-git-send-email-pmladek@suse.com>
 <20150922193513.GE17659@mtj.duckdns.org>
 <20150925112617.GA3122@pathway.suse.cz>
 <20150928170314.GF2589@mtj.duckdns.org>
 <20151002154336.GC3122@pathway.suse.cz>
 <20151002192453.GA7564@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151002192453.GA7564@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri 2015-10-02 15:24:53, Tejun Heo wrote:
> Hello,
> 
> On Fri, Oct 02, 2015 at 05:43:36PM +0200, Petr Mladek wrote:
> > IMHO, we need both locks. The worker manipulates more works and
> > need its own lock. We need work-specific lock because the work
> > might be assigned to different workers and we need to be sure
> > that the operations are really serialized, e.g. queuing.
> 
> I don't think we need per-work lock.  Do we have such usage in kernel
> at all?  If you're worried, let the first queueing record the worker
> and trigger warning if someone tries to queue it anywhere else.  This
> doesn't need to be full-on general like workqueue.  Let's make
> reasonable trade-offs where possible.

I actually thought about this simplification as well. But then I am
in doubts about the API. It would make sense to assign the worker
when the work is being initialized and avoid the duplicate information
when the work is being queued:

	init_kthread_work(work, fn, worker);
	queue_work(work);

Or would you prefer to keep the API similar to workqueues even when
it makes less sense here?


In each case, we need a way to switch the worker if the old one
is destroyed and a new one is started later. We would need
something like:

	reset_work(work, worker)
or
	reinit_work(work, fn, worker)


Thanks for feedback.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
