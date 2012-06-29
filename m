Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 5D2326B0062
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 14:09:58 -0400 (EDT)
Received: by dakp5 with SMTP id p5so5775675dak.14
        for <linux-mm@kvack.org>; Fri, 29 Jun 2012 11:09:57 -0700 (PDT)
Message-ID: <4FEDEF68.6000708@gmail.com>
Date: Sat, 30 Jun 2012 02:09:44 +0800
From: Nai Xia <nai.xia@gmail.com>
Reply-To: nai.xia@gmail.com
MIME-Version: 1.0
Subject: Re: [PATCH 13/40] autonuma: CPU follow memory algorithm
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com> <1340888180-15355-14-git-send-email-aarcange@redhat.com> <1340894776.28750.44.camel@twins> <4FEDB797.3050804@gmail.com> <20120629163025.GP6676@redhat.com>
In-Reply-To: <20120629163025.GP6676@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>



On 2012a1'06ae??30ae?JPY 00:30, Andrea Arcangeli wrote:
> Hi Nai,
>
> On Fri, Jun 29, 2012 at 10:11:35PM +0800, Nai Xia wrote:
>> If one process do very intensive visit of a small set of pages in this
>> node, but occasional visit of a large set of pages in another node.
>> Will this algorithm do a very bad judgment? I guess the answer would
>> be: it's possible and this judgment depends on the racing pattern
>> between the process and your knuma_scand.
>
> Depending if the knuma_scand/scan_pass_sleep_millisecs is more or less
> occasional than the visit of a large set of pages it may behave
> differently correct.

I bet this racing is more subtle than this, but since you admit
this judgment is a racing problem. Then it doesn't matter how subtle
it would be.

>
> Note that every algorithm will have a limit on how smart it can be.
>
> Just to make a random example: if you lookup some pagecache a million
> times and some other pagecache a dozen times, their "aging"
> information in the pagecache will end up identical. Yet we know one
> set of pages is clearly higher priority than the other. We've only so
> many levels of lrus and so many referenced/active bitflags per
> page. Once you get at the top, then all is equal.
>
> Does this mean the "active" list working set detection is useless just
> because we can't differentiate a million of lookups on a few pages, vs
> a dozen of lookups on lots of pages?

I knew you will give us an example of LRU. ;D
But unfortunately the approximation of LRU can not justify your case:
There are cases when LRU approximation behaves very badly,
but enough research in history have told us that 90% of the workloads
conforms to this kind of approximation, and even every programmer has
been taught to write LRU conforming programs.

But we have no idea how well real world workloads will conforms to your
algo especially the racing pattern.


>
> Last but not the least, in the very example you mention it's not even
> clear that the process should be scheduled in the CPU where there is
> the small set of pages accessed frequently, or the CPU where there's
> the large set of pages accessed occasionally. If the small sets of
> pages fits in the 8MBytes of the L2 cache, then it's better to put the
> process in the other CPU where the large set of pages can't fit in the
> L2 cache. Lots of hardware details should be evaluated, to really know
> what's the right thing in such case even if it was you having to
> decide.

That's just why I think it more subtle and why I am feeling not confident
about your algo -- if the effectiveness of your algorithm depends on so
many uncertain things.

>
> But the real reason why the above isn't an issue and why we don't need
> to solve that problem perfectly: there's not just a CPU follow memory
> algorithm in AutoNUMA. There's also the memory follow CPU
> algorithm. AutoNUMA will do its best to change the layout of your
> example to one that has only one clear solution: the occasional lookup
> of the large set of pages, will make those eventually go in the node
> together with the small set of pages (or the other way around), and
> this is how it's solved.

Not sure to follow, if you fall back on this, then why all its complexity?
This fall back equals to "just group all the pages to the running" policy.


>
> In any case, whatever wrong decision it will take, it will at least be
> a better decision than the numa/sched where there's absolutely zero
> information about what pages the process is accessing. And best of all
> with AutoNUMA you also know which pages the _thread_ is accessing so
> it will also be able to take optimal decisions if there are more
> threads than CPUs in a node (as long as not all thread accesses are
> shared).

Yeah, we need the information. But how to make best of the information
is a big problem.
I feel you may not address my question only by word reasoning,
if you currently have in your hand no survey of the common page access
patterns of real world workloads.

Maybe the assumption of your algorithm is right, maybe not...


>
> Hope this explains things better.
> Andrea


Thanks,

Nai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
