Date: Sun, 17 Feb 2008 08:49:06 -0600
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 0/8][for -mm] mem_notify v6
Message-Id: <20080217084906.e1990b11.pj@sgi.com>
In-Reply-To: <2f11576a0802090719i3c08a41aj38504e854edbfeac@mail.gmail.com>
References: <2f11576a0802090719i3c08a41aj38504e854edbfeac@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, marcelo@kvack.org, daniel.spang@gmail.com, riel@redhat.com, akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk, linux-fsdevel@vger.kernel.org, pavel@ucw.cz, a1426z@gawab.com, jonathan@jonmasters.org, zlynx@acm.org
List-ID: <linux-mm.kvack.org>

I just noticed this patchset, kosaki-san.  It looks quite interesting;
my apologies for not commenting earlier.

I see mention somewhere that mem_notify is of particular interest to
embedded systems.

I have what seems, intuitively, a similar problem at the opposite
end of the world, on big-honkin NUMA boxes (hundreds or thousands of
CPUs, terabytes of main memory.)  The problem there is often best
resolved if we can kill the offending task, rather than shrink its
memory footprint.  The situation is that several compute intensive
multi-threaded jobs are running, each in their own dedicated cpuset.

If one of these jobs tries to use more memory than is available in
its cpuset, then

  (1) we quickly loose any hope of that job continuing at the excellent
      performance needed of it, and

  (2) we rapidly get increased risk of that job starting to swap and
      unintentionally impact shared resources (kernel locks, disk
      channels, disk heads).

So we like to identify such jobs as soon as they begin to swap,
and kill them very very quickly (before the direct reclaim code
in mm/vmscan.c can push more than a few pages to the swap device.)

For a much earlier, unsuccessful, attempt to accomplish this, see:

	[Patch] cpusets policy kill no swap
	http://lkml.org/lkml/2005/3/19/148

Now, it may well be that we are too far apart to share any part of
a solution; one seldom uses the same technology to build a Tour de
France bicycle as one uses to build a Lockheed C-5A Galaxy heavy
cargo transport.

One clear difference is the policy of what action we desire to take
when under memory pressure: do we invite user space to free memory so
as to avoid the wrath of the oom killer, or do we go to the opposite
extreme, seeking a nearly instantant killing, faster than the oom
killer can even begin its search for a victim.

Another clear difference is the use of cpusets, which are a major and
vital part of administering the big NUMA boxes, and I presume are not
even compiled into embedded kernels (correct?).  This difference maybe
unbridgeable ... these big NUMA systems require per-cpuset mechanisms,
whereas embedded may require builds without cpusets.

However ... there might be some useful cross pollination of ideas.

I see in the latest posts to your mem_notify patchset v6, responding
to comments by Andrew and Andi on Feb 12 and 13, that you decided to
think more about the design of this, so perhaps this is a good time
for some random ideas from myself, even though I'm clearly coming from
a quite different problem space in some ways.

1) You have a little bit of code in the kernel to throttle the
   thundering herd problem.  Perhaps this could be moved to user space
   ... one user daemon that is always notified of such memory pressure
   alarms, and in turn notifies interested applications.  This might
   avoid the need to add poll_wait_exclusive() to the kernel.  And it
   moves any fussy details of how to tame the thundering herd out of
   the kernel.

2) Another possible mechanism for communicating events from
   the kernel to user space is inotify.  For example, I added
   the line:

   	fsnotify_modify(dentry);   # dentry is current tasks cpuset

   at an interesting spot in vmscan.c, and using inotify-tools
   <inotify-tools.sourceforge.net/> could easily watch all cpusets
   for these events from one user space daemon.

   At this point, I have no idea whether this odd use of inotify
   is better or worse than what your patchset has.  However using
   inotify did require less new kernel code, and with such user space
   mechanisms as inotify-tools already well developed, it made the
   problem I had, of watching an entire hierarcy of special files
   (beneath /dev/cpuset) very easy to implement.  At least inotify
   also presents events on a file descriptor that can be consumed
   using a poll() loop.

3) Perhaps, instead of sending simple events, one could update
   a meter of the rate of recent such events, such as the per-cpuset
   'memory_pressure' mechanism does.  This might lead to addressing
   Andrew Morton's comment:

	If this feature is useful then I'd expect that some
	applications would want notification at different times, or at
	different levels of VM distress.  So this semi-randomly-chosen
	notification point just won't be strong enough in real-world
	use.

4) A place that I found well suited for my purposes (watching for
   swapping from direct reclaim) was just before the lines in the
   pageout() routine in mm/vmscan.c:

   	if (clear_page_dirty_for_io(page)) {
		...
		res = mapping->a_ops->writepage(page, &wbc);

   It seemed that testing "PageAnon(page)" here allowed me to easily
   distinguish between dirty pages going back to the file system, and
   pages going to swap (this detail is from work on a 2.6.16 kernel;
   things might have changed.)

   One possible advantage of the above hook in the direct reclaim
   code path in vmscan.c is that pressure in one cpuset did not cause
   any false alarms in other cpusets.  However even this hook does
   not take into account the constraints of mm/mempolicy (the NUMA
   memory policy that Andi mentioned) nor of cgroup memory controllers.

5) I'd be keen to find an agreeable way that you could have the
   system-wide, no cpuset, mechanism you need, while at the same
   time, I have a cpuset interface that is similar and depends on the
   same set of hooks.  This might involve a single set of hooks in
   the key places in the memory and swapping code, that (1) updated
   the system wide state you need, and (2) if cpusets were present,
   updated similar state for the tasks current cpuset.  The user
   visible API would present both the system-wide connector you need
   (the special file or whatever) and if cpusets are present, similar
   per-cpuset connectors.

Anyhow ... just some thoughts.  Perhaps one of them will be useful.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.940.382.4214

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
