Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 196DF6B0031
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 10:54:39 -0400 (EDT)
Date: Tue, 9 Jul 2013 10:54:30 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH RFC] fsio: filesystem io accounting cgroup
Message-ID: <20130709145430.GB2237@redhat.com>
References: <20130708175607.GB18600@mtj.dyndns.org>
 <51DBC99F.4030301@openvz.org>
 <20130709125734.GA2478@htj.dyndns.org>
 <51DC0CE2.2050906@openvz.org>
 <20130709131605.GB2478@htj.dyndns.org>
 <20130709131646.GC2478@htj.dyndns.org>
 <51DC136E.6020901@openvz.org>
 <20130709134558.GD2478@htj.dyndns.org>
 <20130709141833.GA2237@redhat.com>
 <20130709142908.GE2478@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130709142908.GE2478@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Sha Zhengju <handai.szj@gmail.com>, devel@openvz.org, Jens Axboe <axboe@kernel.dk>

On Tue, Jul 09, 2013 at 07:29:08AM -0700, Tejun Heo wrote:
> On Tue, Jul 09, 2013 at 10:18:33AM -0400, Vivek Goyal wrote:
> > For implementing throttling one as such does not have to do time
> > slice management on the queue.  For providing constructs like IOPS
> > or bandwidth throttling, one just need to put one throttling knob 
> > in the cgroup pipe irrespective of time slice management on the
> > backing device/network.
> 
> We should be providing a comprehensive mechanism to be used from
> userland, not something which serves pieces of specialized
> requirements here and there.  blkio is already a mess with the
> capability changing depending on which elevator is in use and
> blk-throttle counting bios instead of merged requests making iops
> control a bit silly.  We need to clean that up, not add more mess on
> top.

It is not clear whether counting bio or counting request is right
thing to do here. It depends where you are trying to throttle. For
bio based drivers there is request and they need throttling mechanism
too. So keeping it common for both, kind of makes sense.

> 
> > Also time slice management is one way of managing the backend resource.
> > CFQ did that and it works only for slow devices. For faster devices
> > we anyway need some kind of token mechanism instead of keeping track
> > of time.
> 
> No, it is the *right* resource to manage for rotating devices if you
> want any sort of meaningful proportional resource distribution.  It's
> not something one dreams up out of blue but something which arises
> from the fundamental operating characteristics of the device.  For
> SSDs, iops is good enough as their latency profile is consistent
> enough but doing so with rotating disks doesn't yield anything useful.

Ok, so first of all you agree that time slice management is not a
requirement for fast devices.

Secondly, even for slow devices, time slice management practically works
only if NCQ is not implemented in device or NCQ is not being used because
CFQ is not dispatching more requests.

So even in CFQ, time slice accounting works only for sequential IO.
Anybody doing random IO, there is no notion of time slice. We allow
dispatching requests from multiple queues at the same time and then
we don't have a way to count time.

So time slice management is a problem even on slow devices which implement
NCQ. IIRC, in the beginning even CFQ as doing some kind of request
management (and not time slice management). And later it switched to
time slice management in an effort to provide better fairness (If somebody
is doing random IO and seek takes more time the process should be
accounted for it).

But ideal time slice accounting requires driving a queue depth of 1
and for any non-sequential IO, it kills performance.

> 
> > So I don't think trying to manage time slice is the requirement here.
> 
> For a cgroup resource controller, it *is* a frigging requirement to
> control the right fundamental resource at the right place where the
> resource resides and can be fully controlled.  Nobody should have any
> other impression.

Seriously, time slice accounting is one way of managing resource. Same
disk resource can be divided proportionally by counting either iops
or by counting amount of IO done (bandwidth).

If we count iops or bandwidth, it might not be most fair way of doing
things on rotational media but it also should provide more accurate
results in case of NCQ. When multiple requests have been dispatched
to disk we have no idea which request consumed how much of disk time.
So there is no way to account it properly. Iops or bandwidth based
accounting will work just fine even with NCQ.

> 
> > > and by the time you implemented proper hierarchy support and
> > > proportional contnrol, yours isn't gonna be that simple either.
> > 
> > I suspect he is not plannnig to do any proportional control at that
> > layer. Just throttling mechanism.
> 
> blkio should be able to do proportional control in general.  The fact
> that we aren't able to do that except when cfq-iosched is in use is a
> problem which needs to be fixed.  It's not a free-for-all pass for
> creating more broken stuff.

So you want this generic block layer proportional implementation to
do time slice management?

I thought we talked about this implementation to use some kind of token
based mechanism so that it scales better on faster devices. And on slower
devices one will continue to use CFQ.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
