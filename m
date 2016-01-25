Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 49CA56B0256
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 11:30:00 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id e65so84624693pfe.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 08:30:00 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id f65si34601004pff.29.2016.01.25.08.29.59
        for <linux-mm@kvack.org>;
        Mon, 25 Jan 2016 08:29:59 -0800 (PST)
Date: Mon, 25 Jan 2016 08:28:28 -0800
From: Jacob Pan <jacob.jun.pan@linux.intel.com>
Subject: Re: [PATCH v4 22/22] thermal/intel_powerclamp: Convert the kthread
 to kthread worker API
Message-ID: <20160125082828.3c219592@icelake>
In-Reply-To: <1453736711-6703-23-git-send-email-pmladek@suse.com>
References: <1453736711-6703-1-git-send-email-pmladek@suse.com>
	<1453736711-6703-23-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Zhang Rui <rui.zhang@intel.com>, Eduardo Valentin <edubezval@gmail.com>, linux-pm@vger.kernel.org, jacob.jun.pan@linux.intel.com

On Mon, 25 Jan 2016 16:45:11 +0100
Petr Mladek <pmladek@suse.com> wrote:

> Kthreads are currently implemented as an infinite loop. Each
> has its own variant of checks for terminating, freezing,
> awakening. In many cases it is unclear to say in which state
> it is and sometimes it is done a wrong way.
> 
> The plan is to convert kthreads into kthread_worker or workqueues
> API. It allows to split the functionality into separate operations.
> It helps to make a better structure. Also it defines a clean state
> where no locks are taken, IRQs blocked, the kthread might sleep
> or even be safely migrated.
> 
> The kthread worker API is useful when we want to have a dedicated
> single thread for the work. It helps to make sure that it is
> available when needed. Also it allows a better control, e.g.
> define a scheduling priority.
> 
> This patch converts the intel powerclamp kthreads into the kthread
> worker because they need to have a good control over the assigned
> CPUs.
> 
> IMHO, the most natural way is to split one cycle into two works.
> First one does some balancing and let the CPU work normal
> way for some time. The second work checks what the CPU has done
> in the meantime and put it into C-state to reach the required
> idle time ratio. The delay between the two works is achieved
> by the delayed kthread work.
> 
> The two works have to share some data that used to be local
> variables of the single kthread function. This is achieved
> by the new per-CPU struct kthread_worker_data. It might look
> as a complication. On the other hand, the long original kthread
> function was not nice either.
> 
> The patch tries to avoid extra init and cleanup works. All the
> actions might be done outside the thread. They are moved
> to the functions that create or destroy the worker. Especially,
> I checked that the timers are assigned to the right CPU.
> 
> The two works are queuing each other. It makes it a bit tricky to
> break it when we want to stop the worker. We use the global and
> per-worker "clamping" variables to make sure that the re-queuing
> eventually stops. We also cancel the works to make it faster.
> Note that the canceling is not reliable because the handling
> of the two variables and queuing is not synchronized via a lock.
> But it is not a big deal because it is just an optimization.
> The job is stopped faster than before in most cases.
> 
> Signed-off-by: Petr Mladek <pmladek@suse.com>
> CC: Zhang Rui <rui.zhang@intel.com>
> CC: Eduardo Valentin <edubezval@gmail.com>
> CC: Jacob Pan <jacob.jun.pan@linux.intel.com>
> CC: linux-pm@vger.kernel.org
Tested v3 for functionality and performance, v4 seems unchanged for
this patch according to changelog.

Acked-by: Jacob Pan <jacob.jun.pan@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
