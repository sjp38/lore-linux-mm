Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 6EE8A828DE
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 14:56:45 -0500 (EST)
Received: by mail-ig0-f180.google.com with SMTP id z14so59893695igp.0
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 11:56:45 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id qo9si2025166igb.16.2016.01.07.11.56.44
        for <linux-mm@kvack.org>;
        Thu, 07 Jan 2016 11:56:44 -0800 (PST)
Date: Thu, 7 Jan 2016 11:55:31 -0800
From: Jacob Pan <jacob.jun.pan@linux.intel.com>
Subject: Re: [PATCH v3 22/22] thermal/intel_powerclamp: Convert the kthread
 to kthread worker API
Message-ID: <20160107115531.34279a9b@icelake>
In-Reply-To: <1447853127-3461-23-git-send-email-pmladek@suse.com>
References: <1447853127-3461-1-git-send-email-pmladek@suse.com>
	<1447853127-3461-23-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Zhang Rui <rui.zhang@intel.com>, Eduardo Valentin <edubezval@gmail.com>, linux-pm@vger.kernel.org, jacob.jun.pan@linux.intel.com

On Wed, 18 Nov 2015 14:25:27 +0100
Petr Mladek <pmladek@suse.com> wrote:

> From: Petr Mladek <pmladek@suse.com>
> To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov
> <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar
> <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org> Cc: Steven
> Rostedt <rostedt@goodmis.org>, "Paul E. McKenney"
> <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>,
> Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds
> <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>,
> Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>,
> linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>,
> linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek
> <pmladek@suse.com>, Zhang Rui <rui.zhang@intel.com>, Eduardo Valentin
> <edubezval@gmail.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>,
> linux-pm@vger.kernel.org Subject: [PATCH v3 22/22]
> thermal/intel_powerclamp: Convert the kthread to kthread worker API
> Date: Wed, 18 Nov 2015 14:25:27 +0100 X-Mailer: git-send-email 1.8.5.6
> 
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
I have tested this patchset and found no obvious issues in terms of
functionality, power and performance. Tested CPU online/offline,
suspend resume, freeze etc.
Power numbers are comparable too. e.g. on IVB 8C system. Inject idle
from 5 to 50% and read package power while running CPU bound workload.

Before:
IdlePct    Perf    RAPL    WallPower                               
5 256.28 16.50 0.0                                                 
10 248.86 15.64 0.0                                                
15 209.01 14.57 0.0                                                
20 176.17 13.88 0.0                                                
25 161.25 13.37 0.0                                                
30 165.62 13.38 0.0                                                
35 150.94 12.89 0.0                                                
40 137.45 12.47 0.0                                                
45 123.80 11.83 0.0                                                
50 137.59 11.80 0.0                                                

After:

(deb_chroot)root@ubuntu-jp-nfs:~/powercap-power# ./test.py -c 5
IdlePct	Perf	RAPL	WallPower
5 266.30 16.34 0.0
10 226.32 15.27 0.0
15 195.52 14.29 0.0
20 200.96 13.98 0.0
25 174.77 13.08 0.0
30 162.05 13.04 0.0
35 166.70 12.90 0.0
40 134.78 12.12 0.0
45 128.08 11.70 0.0
50 117.74 11.74 0.0    



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
I am not convinced this added complexity is necessary, here are my
concerns by breaking down into two work items.
- overhead of queuing, per cpu data as you already mentioned.
- since we need to have very tight timing control, two items may limit
  our turnaround time. Wouldn't it take one extra tick for the scheduler
  to run the balance work then add delay? as opposed to just
  schedule_timeout()?
- vulnerable to future changes of queuing work

Jacob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
