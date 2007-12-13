Subject: Re: [PATCH 0/6] Use two zonelists per node instead of multiple
	zonelists v11r2
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20071213092338.8b10944c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071211202157.1961.27940.sendpatchset@skynet.skynet.ie>
	 <1197495172.5029.62.camel@localhost>
	 <20071213092338.8b10944c.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Thu, 13 Dec 2007 11:16:09 -0500
Message-Id: <1197562570.5031.44.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 2007-12-13 at 09:23 +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 12 Dec 2007 16:32:51 -0500
> Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> 
> > Just this afternoon, I hit a null pointer deref in
> > __mem_cgroup_remove_list() [called from mem_cgroup_uncharge() if I can
> > trust the stack trace] attempting to unmap a page for migration.  I'm
> > just starting to investigate this.
> > 
> > I'll replace the series I have [~V10] with V11r2 and continue testing in
> > anticipation of the day that we can get this into -mm.
> > 
> Hi, Lee-san.
> 
> Could you know what is the caller of page migration ?
> system call ? hot removal ? or some new thing ?

Kame-san:

I was testing with my out-of-tree automatic-lazy migration patches.  See
http://mirror.linux.org.au/pub/linux.conf.au/2007/video/talks/197.pdf
for an overview.  These patches arrange to unmap [remove ptes] for all
anon pages in a task's vmas with default/local policy [and with mapcount
below a tunable threshold] when the load balancer moves the task to a
different node.  Then, the pages will migrate on next touch/fault, if
they are misplaced relative to the policy--which is likely for many of
the pages, as the task is executing on a different node.  With respect
to file backed pages, automatic migration will only unmap the current
task's pte so that the task will take a fault on next touch and Nick
Piggin's pagecache replication patches will make, if necessary, or use
an existing local copy of the page.

The stack trace was:

try_to_unmap_one -> page_remove_rmap -> mem_cgroup_uncharge, with the
faulting instruction apparently in __mem_cgroup_remove_list().

> 
> Note: 2.6.24-rc4-mm1's cgroup/migration logic.
> 
> In 2.6.24-rc4-mm1, in page migration, mem_cgroup_prepare_migration() increments
> page_cgroup's refcnt before calling try_to_unmap(). This extra refcnt guarantees 
> the page_cgroup's refcnt will not drop to 0 in sequence of
> unmap_and_move() -> try_to_unmap() -> page_remove_rmap() -> mem_cgroup_unchage(). 

Yes, I've seen that code.  I'm working on page migration/replication in
the background, keeping the patches up to date and tested, so I haven't
had a lot of time to investigate.

I do have a heavy-handed instrumentation patch to try to trap any null
pointers or stale {page|mem}_cgroup pointers.  [I can send, if you're
interested.]  I restarted the stress test with that patch.  The test ran
quite a bit longer and then hit a different bug.  So, I have a race
somewhere.   If I can definitely pin it on the memory controller or an
iteraction of the memory controller with page migration/replication,
I'll let you know--and try to come up with a patch.  Otherwise, you
probably don't need to worry.

Lee
> 
> Thanks,
> -Kame
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
