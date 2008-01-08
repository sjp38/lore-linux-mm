From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 11 of 11] not-wait-memdie
Date: Tue, 8 Jan 2008 18:42:33 +1100
References: <504e981185254a12282d.1199326157@v2.random> <200801081425.31515.nickpiggin@yahoo.com.au> <alpine.DEB.0.9999.0801071929300.29897@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.0.9999.0801071929300.29897@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200801081842.33482.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <clameter@sgi.com>, Andrea Arcangeli <andrea@cpushare.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tuesday 08 January 2008 14:37, David Rientjes wrote:
> On Tue, 8 Jan 2008, Nick Piggin wrote:
> > The problem is the global reserve. Once you have a kernel that doesn't
> > need this handwavy global reserve for forward progress, a lot of little
> > problems go away.
>
> I'm specifically talking about TIF_MEMDIE here which gives access to that
> global reserve.

And I'm specifically talking about PF_MEMALLOC, which does the same.

> In OOM situations there is no easy way to guarantee that 
> a task will have enough memory to exit, but that is exactly what is needed
> to alleviate the condition.  Additionally, it is not guaranteed that a
> task that has been OOM killed and given access to the global reserve will
> exit after it has exhausted that reserve in its entirety.  That's when the
> system deadlocks.

I know all that ;) Your second point is the reason to have more than 1
MEMDIE process...


> So giving access to the global reserve to multiple tasks that share memory
> in at least one of their zones for simultaneous OOM killings is not a
> complete solution.  There should be a timeout on tasks when they are OOM
> killed; if they cannot exit for the duration of that period, they lose
> access to the reserves and only then is another task selected.

Hmm, OK I didn't realise you'd proposed that as an alternative. Maybe.
I don't know if the complexity would be worthwhile, given that there is
no sort of reentrancy limit on the global reserve pool anyway.


> > > That's only possible with my proposal of adding
> > >
> > > 	unsigned long oom_kill_jiffies;
> > >
> > > to struct task_struct.  We can't get away with a system-wide jiffies
> > > variable, nor can we get away with per-cgroup, per-cpuset, or
> > > per-mempolicy variable.  The only way to clear such a variable is in
> > > the exit path (by checking test_thread_flag(tsk, TIF_MEMDIE) in
> > > do_exit()) and fails miserably if there are simultaneous but
> > > zone-disjoint OOMs occurring.
> >
> > Why not just have a global frequency limit on OOM events. Then the panic
> > has this delay factored in...
>
> Because OOM killing is going to become more and more frequent with the
> introduction of the memory controller which uses it as a mechanism to
> enforce its policy.  And a global frequency limit does not work well for
> parallel cpuset, mempolicy, or memory controller OOM events.  That is why
> it is currently serialized by the triggering task's zonelist and not
> globally.

I don't think that's a very good reason for the complexity. If your
system is OOM-throughput-limited, then something's very wrong with
your wokload management. (and I don't buy the DoS security argument
either because the memory controller doesn't provide security last
time I looked).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
