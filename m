Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id DD7B46B0070
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 16:07:52 -0400 (EDT)
Date: Thu, 5 Jul 2012 22:07:32 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 09/40] autonuma: introduce kthread_bind_node()
Message-ID: <20120705200732.GP25422@redhat.com>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
 <1340888180-15355-10-git-send-email-aarcange@redhat.com>
 <4FEDCB7A.1060007@redhat.com>
 <20120629163820.GQ6676@redhat.com>
 <4FEDDE99.2090105@redhat.com>
 <20120705130902.GF7881@cmpxchg.org>
 <4FF5DDFF.70900@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FF5DDFF.70900@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Hi Johannes and Glauber,

> On 07/05/2012 05:09 PM, Johannes Weiner wrote:
> > In the very first review iteration of AutoNUMA, Peter argued that the
> > scheduler people want to use this flag in other places where they rely
> > on this thing meaning a single cpu, not a group of them (check out the
> > cpumask test in debug_smp_processor_id() in lib/smp_processor_id.c).

I already suggested to add a new bitflag for that future optimization,
when adding the future code, if that optimization is so worth it.

> > 
> > He also argued that preventing root from rebinding the numa daemons is
> > not critical to this feature at all.  And I have to agree.

It's not critical indeed, it was just a minor reliability
improvement just like it is right now for all other usages.

On Thu, Jul 05, 2012 at 10:33:35PM +0400, Glauber Costa wrote:
> Despite not being a scheduler expert, I'll have to side with that as
> well. The thing I have in mind is: We have people whose usecase depend
> on completely isolating cpus, with nothing but a specialized task
> running on it. For those people, even the hard binding between cpu0 and
> the timer interrupt is a big problem.
> 
> If you force a per-node binding of a kthread, you are basically saying
> that those people are unable to isolate a node. Or else, that they have
> to choose between that, and AutoNUMA. Both are suboptimal choices, to
> say the least.

I'm afraid AutoNUMA in those nanosecond latency setups will be
disabled, so knuma_migrated won't ever have a chance to run in the
first place. I doubt they want to risk to hit on a migration fault,
even if the migration is async with AutoNUMA there's still a chance
for userland to hit on a migration pte. Plus who starts to alter CPU
binding on kernel daemon and remove irqs from cpus, is likely to be
using hard bindings on the userland app too, so not needing AutoNUMA.

However we cannot fell for sure I agree, so your argument of wanting
to isolate the CPU while leaving AutoNUMA enabled is the most
convincing argument so far in favour of stopping setting the flag on
knuma_migrated.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
