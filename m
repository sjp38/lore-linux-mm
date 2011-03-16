Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 011458D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 08:35:27 -0400 (EDT)
Date: Wed, 16 Mar 2011 13:35:14 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v6 8/9] memcg: check memcg dirty limits in page
 writeback
Message-ID: <20110316123514.GA4456@quack.suse.cz>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
 <1299869011-26152-9-git-send-email-gthelen@google.com>
 <20110314175408.GE31120@redhat.com>
 <20110314211002.GD4998@quack.suse.cz>
 <AANLkTikCt90o2qRV=0cJijtnA_W44dcUCBOmZ53Biv07@mail.gmail.com>
 <20110315231230.GC4995@quack.suse.cz>
 <AANLkTimLNxcLQ23SRtdeynC19Htxe_aBm7sLuax_fQTX@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTimLNxcLQ23SRtdeynC19Htxe_aBm7sLuax_fQTX@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Jan Kara <jack@suse.cz>, Vivek Goyal <vgoyal@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>

On Tue 15-03-11 19:35:26, Greg Thelen wrote:
> On Tue, Mar 15, 2011 at 4:12 PM, Jan Kara <jack@suse.cz> wrote:
> >  I found out I've already deleted the relevant email and thus have no good
> > way to reply to it. So in the end I'll write it here: As Vivek pointed out,
> > you try to introduce background writeback that honors per-cgroup limits but
> > the way you do it it doesn't quite work. To avoid livelocking of flusher
> > thread, any essentially unbounded work (and background writeback of bdi or
> > in your case a cgroup pages on the bdi is in principle unbounded) has to
> > give way to other work items in the queue (like a work submitted by
> > sync(1)). Thus wb_writeback() stops for_background works if there are other
> > works to do with the rationale that as soon as that work is finished, we
> > may happily return to background cleaning (and that other work works for
> > background cleaning as well anyway).
> >
> > But with your introduction of per-cgroup background writeback we are going
> > to loose the information in which cgroup we have to get below background
> > limit. And if we stored the context somewhere and tried to return to it
> > later, we'd have the above problems with livelocking and we'd have to
> > really carefully handle cases where more cgroups actually want their limits
> > observed.
> >
> > I'm not decided what would be a good solution for this. It seems that
> > a flusher thread should check all cgroups whether they are not exceeding
> > their background limit and if yes, do writeback. I'm not sure how practical
> > that would be but possibly we could have a list of cgroups with exceeded
> > limits and flusher thread could check that?
> 
> mem_cgroup_balance_dirty_pages() queues a bdi work item which already
> includes a memcg that is available to wb_writeback() in '[PATCH v6
> 9/9] memcg: make background writeback memcg aware'.  Background
> writeback checks the given memcg usage vs memcg limit rather than
> global usage vs global limit.
  Yes.

> If we amend this to requeue an interrupted background work to the end
> of the per-bdi work_list, then I think that would address the
> livelocking issue.
  Yes, that would work. But it would be nice (I'd find that cleaner design)
if we could keep just one type of background work and make sure that it
observes all the imposed memcg limits. For that we wouldn't explicitely
pass memcg to the flusher thread but rather make over_bground_thresh()
check all the memcg limits - or to make this more effective have some list
of memcgs which crossed the background limit. What do you think?

> To prevent a memcg writeback work item from writing irrelevant inodes
> (outside the memcg) then bdi writeback could call
> mem_cgroup_queue_io(memcg, bdi) to locate an inode to writeback for
> the memcg under dirty pressure.  mem_cgroup_queue_io() would scan the
> memcg lru for dirty pages belonging to the particular bdi.
  And similarly here, we could just loop over all relevant memcg's and
let each of them queue relevant inodes as they wish and after that we go
and write all the queued inodes... That would also solve the problem with
cgroups competing with each other on the same bdi (writeback thread makes
sure that all queued inodes get comparable amount of writeback). Does it
look OK? It seems cleaner to me than what you propose but maybe I miss
something...

> If mem_cgroup_queue_io() is unable to find any dirty inodes for the
> bdi, then it would return an empty set.  Then wb_writeback() would
> abandon background writeback because there is nothing useful to write
> back to that bdi.  In patch 9/9, wb_writeback() calls
> mem_cgroup_bg_writeback_done() when writeback completes.
> mem_cgroup_bg_writeback_done() could check that cgroup is still over
> background thresh and use the memcg lru to select another bdi to start
> per-memcg bdi writeback on.  This allows one queued per-memcg bdi
> background writeback work item to pass off to another bdi to continue
> per-memcg background writeback.
  Here I'd think that memcg_balance_dirty_pages() would check which memcgs
are over threshold on that bdi and add these to the list of relevant memcgs
for that bdi. Thinking about it it's rather similar to what you propose
just instead of queueing and requeueing work items (which are processed
sequentially, which isn't really what we want) we'd rather maintain a
separate list of memcgs which would be processed in parallel.

> Unfortunately the approach above would only queue a memcg's bg writes
> to one bdi at a time.  Another way to approach the problem would be to
> have a per-memcg flusher thread that is able to queue inodes to
> multiple bdis concurrently.
  Well, in principle there's no reason why memcg couldn't ask for writeback
(either via work items as you propose or via my mechanism) on several bdis
in parallel. I see no reason why a special flusher thread would be needed
for that...

									Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
