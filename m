Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 6E95A6B0062
	for <linux-mm@kvack.org>; Tue, 29 May 2012 16:44:24 -0400 (EDT)
Message-ID: <4FC534B0.2000505@redhat.com>
Date: Tue, 29 May 2012 16:42:24 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 13/35] autonuma: add page structure fields
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com> <1337965359-29725-14-git-send-email-aarcange@redhat.com> <1338297385.26856.74.camel@twins> <20120529163849.GF21339@redhat.com> <CA+55aFwmhM2a2HjB_MEjVDDL-AP4j-t202ozmHgT0azSptjnoA@mail.gmail.com>
In-Reply-To: <CA+55aFwmhM2a2HjB_MEjVDDL-AP4j-t202ozmHgT0azSptjnoA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On 05/29/2012 01:38 PM, Linus Torvalds wrote:
> On Tue, May 29, 2012 at 9:38 AM, Andrea Arcangeli<aarcange@redhat.com>  wrote:
>> On Tue, May 29, 2012 at 03:16:25PM +0200, Peter Zijlstra wrote:
>>> 24 bytes per page.. or ~0.6% of memory gone. This is far too great a
>>> price to pay.
>>
>> I don't think it's too great, memcg uses for half of that and yet
>> nobody is booting with cgroup_disable=memory even on not-NUMA servers
>> with less RAM.
>
> A big fraction of one percent is absolutely unacceptable.

Andrea, here is a quick back of the envelope idea.

In every zone, we keep an array of pointers to pages and
other needed info for knumad.  We do not need as many as
we have pages in a zone, because we do not want to move
all that memory across anyway (especially in larger systems).
Maybe the number of entries can scale up with the square
root of the zone size?

struct numa_pq_entry {
	struct page *page;
	pg_data_t *destination;
};

For each zone, we can have a numa queueing struct

struct numa_queue {
	struct numa_pq_entry *current_knumad;
	struct numa_pq_entry *current_queue;
	struct numa_pq_entry[];
};

Pages can get added to the knumad queue by filling
in a pointer and a destination node, and by setting
a page flag indicating that this page should be
moved to another NUMA node.

If something happens to the page that would cancel
the queuing, we simply clear that page flag.

When knumad gets around to an entry in the array,
it will check to see if the "should migrate" page
flag is still set. If it is not, it skips the entry.

The current_knumad and current_queue entries can
be used to simply keep circular buffer semantics.

Does this look reasonable?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
