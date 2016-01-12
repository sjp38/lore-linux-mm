Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id B982C680F80
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 21:20:20 -0500 (EST)
Received: by mail-pf0-f170.google.com with SMTP id q63so55819089pfb.1
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 18:20:20 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id 27si32521353pfp.194.2016.01.11.18.20.19
        for <linux-mm@kvack.org>;
        Mon, 11 Jan 2016 18:20:20 -0800 (PST)
Date: Mon, 11 Jan 2016 18:17:18 -0800
From: Jacob Pan <jacob.jun.pan@linux.intel.com>
Subject: Re: [PATCH v3 22/22] thermal/intel_powerclamp: Convert the kthread
 to kthread worker API
Message-ID: <20160111181718.0ace4a58@yairi>
In-Reply-To: <20160108164931.GT3178@pathway.suse.cz>
References: <1447853127-3461-1-git-send-email-pmladek@suse.com>
	<1447853127-3461-23-git-send-email-pmladek@suse.com>
	<20160107115531.34279a9b@icelake>
	<20160108164931.GT3178@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Zhang Rui <rui.zhang@intel.com>, Eduardo Valentin <edubezval@gmail.com>, linux-pm@vger.kernel.org, jacob.jun.pan@linux.intel.com

On Fri, 8 Jan 2016 17:49:31 +0100
Petr Mladek <pmladek@suse.com> wrote:

> Is the __preempt_schedule() a problem? It allows to switch the process
> when needed. I thought that it was safe because try_to_freeze() might
> have slept as well.
> 
not a problem. i originally thought queue_kthread_work() may add
delay but it doesn't since there is no other work on this kthread.
> 
> > - vulnerable to future changes of queuing work  
> 
> The question is if it is safe to sleep, freeze, or even migrate
> the system between the works. It looks like because of the
> try_to_freeze() and schedule_interrupt() calls in the original code.
> 
> BTW: I wonder if the original code correctly handle freezing after
> the schedule_timeout(). It does not call try_to_freeze()
> there and the forced idle states might block freezing.
> I think that the small overhead of kthread works is worth
> solving such bugs. It makes it easier to maintain these
> sleeping states.
it is in a while loop, so try_to_freeze() gets called. Am I missing
something?

Thanks,

Jacob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
