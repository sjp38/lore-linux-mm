Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 56B616B00EE
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 03:41:32 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p7A7fOvn030062
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 00:41:28 -0700
Received: from qwk3 (qwk3.prod.google.com [10.241.195.131])
	by wpaz1.hot.corp.google.com with ESMTP id p7A7fMDs002120
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 00:41:22 -0700
Received: by qwk3 with SMTP id 3so520928qwk.5
        for <linux-mm@kvack.org>; Wed, 10 Aug 2011 00:41:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110809140421.GB6482@redhat.com>
References: <20110806084447.388624428@intel.com> <20110809020127.GA3700@redhat.com>
 <20110809055551.GP3162@dastard> <20110809140421.GB6482@redhat.com>
From: Greg Thelen <gthelen@google.com>
Date: Wed, 10 Aug 2011 00:41:00 -0700
Message-ID: <CAHH2K0bV3WPSOBn=Kob-kvw0FgchUhm_bA9HGVJGmsZgWf0dSg@mail.gmail.com>
Subject: Re: [PATCH 0/5] IO-less dirty throttling v8
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@lst.de>, LKML <linux-kernel@vger.kernel.org>, Andrea Righi <arighi@develer.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Aug 9, 2011 7:04 AM, "Vivek Goyal" <vgoyal@redhat.com> wrote:
>
> On Tue, Aug 09, 2011 at 03:55:51PM +1000, Dave Chinner wrote:
> > On Mon, Aug 08, 2011 at 10:01:27PM -0400, Vivek Goyal wrote:
> > > On Sat, Aug 06, 2011 at 04:44:47PM +0800, Wu Fengguang wrote:
> > > > Hi all,
> > > >
> > > > The _core_ bits of the IO-less balance_dirty_pages().
> > > > Heavily simplified and re-commented to make it easier to review.
> > > >
> > > > =A0 git://git.kernel.org/pub/scm/linux/kernel/git/wfg/writeback.git=
 dirty-throttling-v8
> > > >
> > > > Only the bare minimal algorithms are presented, so you will find so=
me rough
> > > > edges in the graphs below. But it's usable :)
> > > >
> > > > =A0 http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dir=
ty-throttling-v8/
> > > >
> > > > And an introduction to the (more complete) algorithms:
> > > >
> > > > =A0 http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/sli=
des/smooth-dirty-throttling.pdf
> > > >
> > > > Questions and reviews are highly appreciated!
> > >
> > > Hi Wu,
> > >
> > > I am going through the slide number 39 where you talk about it being
> > > future proof and it can be used for IO control purposes. You have lis=
ted
> > > following merits of this approach.
> > >
> > > * per-bdi nature, works on NFS and Software RAID
> > > * no delayed response (working at the right layer)
> > > * no page tracking, hence decoupled from memcg
> > > * no interactions with FS and CFQ
> > > * get proportional IO controller for free
> > > * reuse/inherit all the base facilities/functions
> > >
> > > I would say that it will also be a good idea to list the demerits of
> > > this approach in current form and that is that it only deals with
> > > controlling buffered write IO and nothing else.
> >
> > That's not a demerit - that is all it is designed to do.
>
> It is designed to improve the existing task throttling functionality and
> we are trying to extend the same to cgroups too. So if by design somethin=
g
> does not gel well with existing pieces, it is demerit to me. Atleast
> there should be a good explanation of design intention and how it is
> going to be useful.
>
> For example, how this thing is going to gel with existing IO controller?
> Are you going to create two separate mechianisms. One for control of
> writes while entering the cache and other for controlling the writes
> at device level?
>
> The fact that this mechanism does not know about any other IO in the
> system/cgroup is a limiting factor. From usability point of view, a
> user expects any kind of IO happening from a group.
>
> So are we planning to create a new controller? Or add additional files
> in existing controller to control the per cgroup write throttling
> behavior? Even if we create additional files, again then a user is
> forced to put separate write policies for buffered writes and direct
> writes. I was hoping a better interface would be that user puts a
> policy on writes and that takes affect and a user does not have to
> worry whether the applications inside the cgroup are doing buffered
> writes or direct writes.
>
> >
> > > So on the same block device, other direct writes might be going on
> > > from same group and in this scheme a user will not have any
> > > control.
> >
> > But it is taken into account by the IO write throttling.
>
> You mean blkio controller?
>
> It does. But my complain is that we are trying to control two separate
> knobs for two kind of IOs and I am trying to come up with a single
> knob.
>
> Current interface for write control in blkio controller looks like.
>
> blkio.throtl.write_bps_device
>
> Once can write to this file specifying the write limit of a cgroup
> on a particular device. I was hoping that buffered write limits
> will come out of same limit but with these pathes looks like we
> shall have to create a new interface altogether which just controls
> buffered writes and nothing else and user is supposed to know what
> his application is doing and try to configure the limits accordingly.
>
> So my concern is that how the overall interface would look like and
> how well it will work with existing controller and how a user is
> supposed to use it.
>
> In fact current IO controller does throttling at device level so
> interface is device specific. One is supposed to know the major
> and minor number of device to specify. I am not sure in this
> case what one is supposed to do as it is bdi specific and for
> NFS case there is no device. So one is supposed to speciy bdi or
> limits are going to be global (system wide, independent of bdi
> or block device)?
>
> >
> > > Another disadvantage is that throttling at page cache
> > > level does not take care of IO spikes at device level.
> >
> > And that is handled as well.
> >
> > How? By the indirect effect other IO and IO spikes have on the
> > writeback rate. That is, other IO reduces the writeback bandwidth,
> > which then changes the throttling parameters via feedback loops.
>
> Actually I was referring to effect of buffered writes on other IO
> going on the device. With control being on device level, one can
> tightly control the WRITEs flowing out of a cgroup to Lun and that
> can help a bit knowing how bad it will be for other reads going on
> the lun.
>
> With this scheme, flusher threads can suddenly throw tons of writes
> on lun and then no IO for another few seconds. So basically IO is
> bursty at device level and doing control at device level can make
> it more smooth.
>
> So we have two ways to control buffered writes.
>
> - Throttle them while entering the page cache
> - Throttle them at device and feedback loop in turn throttles them at
> =A0page cache level based on dirty ratio.
>
> Myself and Andrea had implemented first appraoch (same what Wu is
> suggesting now with a different mechanism) and following was your
> response.
>
> https://lkml.org/lkml/2011/6/28/494
>
> To me it looked like that at that point of time you preferred precise
> throttling at device level and now you seem to prefer precise throttling
> at page cache level?
>
> Again, I am not against cgroup parameter based throttling at page
> cache level. It simplifies the implementation and probably is good
> enough for lots of people. I am only worried about that the interface
> and how does it work with existing interfaces.
>
> In absolute throttling one does not have to care about feedback or
> what is the underlying bdi bandwidth. So to me these patches are
> good for work conserving IO control where we want to determine how
> fast we can write to device and then throttle tasks accordingly. But
> in absolute throttling one specifies the upper limit and there we
> don't need the mechanism to determine what the bdi badnwidth or
> how many dirty pages are there and throttle tasks accordingly.
>
> >
> > The buffered write throttle is designed to reduce the page cache
> > dirtying rate to the current cleaning rate of the backing device
> > is. Increase the cleaning rate (i.e. device is otherwise idle) and
> > it will throttle less. Decrease the cleaning rate (i.e. other IO
> > spikes or block IO throttle activates) and it will throttle more.
> >
> > We have to do vary buffered write throttling like this to adapt to
> > changing IO workloads (e.g. =A0someone starting a read-heavy workload
> > will slow down writeback rate, so we need to throttle buffered
> > writes more aggressively), so it has to be independent of any sort
> > of block layer IO controller.
> >
> > Simply put: the block IO controller still has direct control over
> > the rate at which buffered writes drain out of the system. The
> > IO-less write throttle simply limits the rate at which buffered
> > writes come into the system to match whatever the IO path allows to
> > drain out....
>
> Ok, this makes sense. So it goes back to the previous design where
> absolute cgroup based control happens at device level and IO less
> throttle implements the feedback loop to slow down the writes into
> page cache. That makes sense. But Wu's slides suggest that one can
> directly implement cgroup based IO control in IO less throttling
> and that's where I have concerns.
>
> Anyway this stuff shall have to be made cgroup aware so that tasks
> of different groups can see different throttling depending on how
> much IO that group is able to do at device level.
>
> >
> > > Now I think one could probably come up with more sophisticated scheme
> > > where throttling is done at bdi level but is also accounted at device
> > > level at IO controller. (Something similar I had done in the past but
> > > Dave Chinner did not like it).
> >
> > I don't like it because it is solution to a specific problem and
> > requires complex coupling across multiple layers of the system. We
> > are trying to move away from that throttling model. More
> > fundamentally, though, is that it is not a general solution to the
> > entire class of "IO writeback rate changed" problems that buffered
> > write throttling needs to solve.
> >
> > > Anyway, keeping track of per cgroup rate and throttling accordingly
> > > can definitely help implement an algorithm for per cgroup IO control.
> > > We probably just need to find a reasonable way to account all this
> > > IO to end device so that we have control of all kind of IO of a cgrou=
p.
> > > How do you implement proportional control here? From overall bdi band=
width
> > > vary per cgroup bandwidth regularly based on cgroup weight? Again the
> > > issue here is that it controls only buffered WRITES and nothing else =
and
> > > in this case co-ordinating with CFQ will probably be hard. So I guess
> > > usage of proportional IO just for buffered WRITES will have limited
> > > usage.
> >
> > The whole point of doing the throttling this way is that we don't
> > need any sort of special connection between block IO throttling and
> > page cache (buffered write) throttling. We significantly reduce the
> > coupling between the layers by relying on feedback-driven control
> > loops to determine the buffered write throttling thresholds
> > adaptively. IOWs, the IO-less write throttling at the page cache
> > will adjust automatically to whatever throughput the block IO
> > throttling allows async writes to achieve.
>
> This is good. But that's not the impression one gets from Wu's slides.
>
> >
> > However, before we have a "finished product", there is still another
> > piece of the puzzle to be put in place - memcg-aware buffered
> > writeback. That is, having a flusher thread do work on behalf of
> > memcg in the IO context of the memcg. Then the IO controller just
> > sees a stream of async writes in the context of the memcg the
> > buffered writes came from in the first place. The block layer
> > throttles them just like any other IO in the IO context of the
> > memcg...
>
> Yes that is still a piece remaining. I was hoping that Greg Thelen will
> be able to extend his patches to submit writes in the context of
> per cgroup flusher/worker threads and solve this problem.
>
> Thanks
> Vivek

Are you suggesting multiple flushers per bdi (one per cgroup)?=A0 I
thought the point of IO less was to one issue buffered writes from a
single thread.

Note: I have rebased the memcg writeback code to latest mmotm and am
testing it now.=A0 These patches do not introduce additional threads;
the existing bdi flusher threads are used with an optional memcg
filter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
