Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9651A6B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 10:27:55 -0400 (EDT)
Date: Thu, 28 Apr 2011 22:27:49 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 00/12] IO-less dirty throttling v7
Message-ID: <20110428142749.GA11068@localhost>
References: <20110416132546.765212221@intel.com>
 <20110426171954.GD9414@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110426171954.GD9414@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

Hi Vivek,

On Wed, Apr 27, 2011 at 01:19:54AM +0800, Vivek Goyal wrote:
> On Sat, Apr 16, 2011 at 09:25:46PM +0800, Wu Fengguang wrote:
> > Andrew,
> > 
> > This revision undergoes a number of simplifications, cleanups and fixes.
> > Independent patches are separated out. The core patches (07, 08) now have
> > easier to understand changelog. Detailed rationals can be found in patch 08.
> > 
> > In response to the complexity complaints, an introduction document is
> > written explaining the rationals, algorithm and visual case studies:
> > 
> > http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/slides/smooth-dirty-throttling.pdf
> > 
> 
> Hi Fenguang,
> 
> I went quickly browsed through above document and am trying to understand
> the meaning of following lines and see how does it fit into the framework
> of existing IO conroller.

Thanks for taking the look! Regarding this diff:

http://git.kernel.org/?p=linux/kernel/git/wfg/writeback.git;a=blobdiff;f=mm/page-writeback.c;h=0b579e7fd338fd1f59cc36bf15fda06ff6260634;hp=34dff9f0d28d0f4f0794eb41187f71b4ade6b8a2;hb=1a58ad99ce1f6a9df6618a4b92fa4859cc3e7e90;hpb=5b6fcb3125ea52ff04a2fad27a51307842deb1a0

> - task IO controller endogenous

Normally the bandwidth the current task to be throttled at (referred
to as task_bw below) is runtime calculated, however if there is an
interface (the patch reuses current->signal->rlim[RLIMIT_RSS].rlim_cur),
then it can just use that bandwidth to throttle the current task. No
extra code is needed.  In this sense, it has the endogenous capability
to do per-task async write IO controller.

> - proportional IO controller endogenous

Sorry, "priority" could be more accurate than "proportional".
When task_bw is calculated in the normal way, you may further do

        task_bw *= 2;

to grant it doubled bandwidth than the other tasks. Or do

        task_bw *= current->async_write_priority;

to give it whatever configurable async write priority. When you do
this, the base bandwidth is smart enough to adapt to the new balance
point.  In this sense, exact priority control is also endogenous.

> - cgroup IO controller well integrated

The async write cgroup IO controller is implemented in the same way as
the "global IO controller", in that it's also based on the "base
bandwidth" concept and is calculated with the same algorithm.

> You had sent me a link where you had prepared a patch to control the
> async IO completely. So because this code is all about measuring the
> bdi writeback rate and then coming up task ratelimit accoridingly, it
> will never know about other IO going on in the cgroup. READS and direct
> IO.

Right.

> So IIUC, to make use of above logic for cgroup throttling, one shall have
> to come up with explicity notion of async bandwidth per cgroup which does
> not control other writes. Currently we have following when it comes to
> throttling.
> 
> blkio.throttle_read_bps
> blkio.throttle_write_bps
> 
> The intention is to be able to control the WRITE bandwidth of cgroup and
> it could be any kind of WRITE (be it buffered WRITE or direct WRITES). 
> Currently we control only direct WRITES and question of how to also
> control buffered writes is still on the table.
> 
> Because your patch does not know about other WRITES happening in the
> system, one needs to create a way so that buffered WRITES and direct
> WRITES can be accounted together against a group and throttled
> accordingly.

Basically it is now possible to also send DIRECT writes to the new
balance_dirty_pages(), because it's RATE based rather than THRESHOLD
based. The DIRECT writes have nothing to do with dirty THRESHOLD, so
the legacy balance_dirty_pages() was not able to handle them at all.

Then there is the danger that DIRECT writes be double throttled --
explicitly in balance_dirty_pages() and implicitly in
get_request_wait().  But as long as the latter do not sleep for too
long time (< 500ms for now), it will be compensated in
balance_dirty_pages() (aka. think time compensation).

Or even safer, we may let DIRECT writes enter balance_dirty_pages()
only if it's to be cgroup throttled. The cgroup IO controller can be
enhanced to do "leak" control that can effectively account for all
get_request_wait() latencies.

> What does "proportional IO controller endogenous" mean? Currently we do
> all proportional IO division in CFQ. So are you proposing that for 
> buffered WRITES we come up with a different policy altogether in writeback
> layer or somehow it is integrating with CFQ mechanism?

See above. It's not related to CFQ and totally within the scope of
(async) writes.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
