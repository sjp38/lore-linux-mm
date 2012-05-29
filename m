Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id EE9186B0068
	for <linux-mm@kvack.org>; Tue, 29 May 2012 09:57:02 -0400 (EDT)
Message-ID: <4FC4D513.7010700@redhat.com>
Date: Tue, 29 May 2012 09:54:27 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 12/35] autonuma: CPU follow memory algorithm
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>  <1337965359-29725-13-git-send-email-aarcange@redhat.com> <1338296453.26856.68.camel@twins>
In-Reply-To: <1338296453.26856.68.camel@twins>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On 05/29/2012 09:00 AM, Peter Zijlstra wrote:
> On Fri, 2012-05-25 at 19:02 +0200, Andrea Arcangeli wrote:
>> @@ -3274,6 +3268,8 @@ need_resched:
>>
>>          post_schedule(rq);
>>
>> +       sched_autonuma_balance();
>> +
>>          sched_preempt_enable_no_resched();
>>          if (need_resched())
>>                  goto need_resched;
>
>
>
>> +void sched_autonuma_balance(void)
>> +{
>
>> +       for_each_online_node(nid) {
>> +       }
>
>> +       for_each_online_node(nid) {
>> +               for_each_cpu_and(cpu, cpumask_of_node(nid), allowed) {
>
>
>> +               }
>> +       }
>
>> +       stop_one_cpu(this_cpu, migration_cpu_stop,&arg);
>> +}
>
> NAK
>
> You do _NOT_ put a O(nr_cpus) or even O(nr_nodes) loop in the middle of
> schedule().
>
> I see you've made it conditional, but schedule() taking that long --
> even occasionally -- is just not cool.
>
> schedule() calling schedule() is also an absolute abomination.
>
> You were told to fix this several times..

Do you have any suggestions for how Andrea could fix this?

Pairwise comparisons with a busy CPU/node?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
