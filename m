Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id E79E66B0074
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 21:00:43 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so9954200ghr.14
        for <linux-mm@kvack.org>; Thu, 05 Jul 2012 18:00:43 -0700 (PDT)
Message-ID: <4FF638AD.9040308@gmail.com>
Date: Fri, 06 Jul 2012 09:00:29 +0800
From: Nai Xia <nai.xia@gmail.com>
Reply-To: nai.xia@gmail.com
MIME-Version: 1.0
Subject: Re: [PATCH 13/40] autonuma: CPU follow memory algorithm
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com> <1340888180-15355-14-git-send-email-aarcange@redhat.com> <1340895238.28750.49.camel@twins> <CAJd=RBA+FPgB9iq07YG0Pd=tN65SGK1ifmj98tomBDbYeKOE-Q@mail.gmail.com> <20120629125517.GD32637@gmail.com> <4FEDDD0C.60609@redhat.com> <1340995986.28750.114.camel@twins> <CAPQyPG4R34bi0fXHBspSpR1+gDLj2PGYpPXNLPTTTBmrRL=m4g@mail.gmail.com> <4FF5D7CA.5020301@redhat.com>
In-Reply-To: <4FF5D7CA.5020301@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, dlaor@redhat.com, Ingo Molnar <mingo@kernel.org>, Hillf Danton <dhillf@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>



On 2012a1'07ae??06ae?JPY 02:07, Rik van Riel wrote:
> On 06/29/2012 04:01 PM, Nai Xia wrote:
>
>> Hey guys, Can I say NAK to these patches ?
>
> Not necessarily the patches, but thinking about your
> points some more, I thought of a much more serious
> potential problem with Andrea's code.
>
>> Now I aware that this sampling algorithm is completely broken, if we take
>> a few seconds to see what it is trying to solve:
>
>> Andrea's patch can only approximate the pages_accessed number in a
>> time unit(scan interval),
>> I don't think it can catch even 1% of average_page_access_frequence
>> on a busy workload.
>
> It is much more "interesting" than that.
>
> Once the first thread gets a NUMA pagefault on a
> particular page, the page is made present in the
> page tables and NO OTHER THREAD will get NUMA
> page faults.
>
> That means when trying to compare the weighting
> of NUMA accesses between different threads in a
> 10 second interval, we only know THE FIRST FAULT.
>
> We have no information on whether any other threads
> tried to access the same page, because we do not
> get faults more frequently.
>
> Not only do we not get use frequency information,
> we may not get the information on which threads use
> which memory, at all.
>
> Somehow Andrea's code still seems to work.

On this point alone, I agree with Andrea's reasoning:
1. This information get averaged in noise.
2. If a thread statistically get more faults than others
then it may deserve to be biased.

Note, I mean only reasoning, I don't have enough
confidence if Andrea's coding is really working like
this, since I didn't do micro benchmarks on this part
of code.

>
> It would be very interesting to know why.

Note my personal experience tells me that
sometimes you wrote a complex system, it works
like a charm. And later you cut out 30% of its
code, it's still working like a charm.

Sometimes a part of a system just is not that
relevant to the output of the whole benchmark,
and this fact may make it seemingly have good
resistance to false negatives/positives.
It's time to look inside with benchmarks, IMO.

Again, I have no intension or benefit in
disabling this algorithm. I am only curious
about the truth. Hope nobody will get offended.


Thanks,

Nai

>
> How much sense does the following code still make,
> considering we may never get all the info on which
> threads use which memory?
>
> + /*
> + * Generate the w_nid/w_cpu_nid from the
> + * pre-computed mm/task_numa_weight[] and
> + * compute w_other using the w_m/w_t info
> + * collected from the other process.
> + */
> + if (mm == p->mm) {
> + if (w_t > w_t_t)
> + w_t_t = w_t;
> + w_other = w_t*AUTONUMA_BALANCE_SCALE/w_t_t;
> + w_nid = task_numa_weight[nid];
> + w_cpu_nid = task_numa_weight[cpu_nid];
> + w_type = W_TYPE_THREAD;
>
> Andrea, what is the real reason your code works?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
