Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 5E4406B0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 14:35:43 -0400 (EDT)
Date: Tue, 9 Jul 2013 14:35:35 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH RFC] fsio: filesystem io accounting cgroup
Message-ID: <20130709183534.GE2237@redhat.com>
References: <51DBC99F.4030301@openvz.org>
 <20130709125734.GA2478@htj.dyndns.org>
 <51DC0CE2.2050906@openvz.org>
 <20130709131605.GB2478@htj.dyndns.org>
 <20130709131646.GC2478@htj.dyndns.org>
 <51DC136E.6020901@openvz.org>
 <20130709134558.GD2478@htj.dyndns.org>
 <51DC1FCA.3060904@openvz.org>
 <20130709150605.GC2237@redhat.com>
 <51DC4BA1.3000403@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51DC4BA1.3000403@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Sha Zhengju <handai.szj@gmail.com>, devel@openvz.org, Jens Axboe <axboe@kernel.dk>

On Tue, Jul 09, 2013 at 09:42:57PM +0400, Konstantin Khlebnikov wrote:

[..]
> >So what kind of priority inversion you are facing with blkcg and how would
> >you avoid it with your implementation?
> >
> >I know that serialization can happen at filesystem level while trying
> >to commit journal. But I think same thing will happen with your
> >implementation too.
> 
> Yes, metadata changes are serialized and and they depends on data commits,
> thus block layer cannot delay write requests without introducing nasty priority
> inversions.

Tejun had some thoughts about this on how to solve this problem. I don't
remember the details though. Tejun?

> Cached read requests cannot be delayed at all.

Who wants to delay the reads which are coming out of cache. That sounds
like a mis-feature.

> All solutions either
> breaks throttling or adds PI. So block layer is just wrong place for this.

Well implmenting throttling at block layer can allow you to cache writes
so that application does not see the dealye for small writes at the same
time it protects against that burst being visible on device and it
impacting other IO going device.

Not sure how much does it matter but atleast this was one discussion
point in the past. Implementing it at device level provides better
control when it comes to avoiding interference from bursty buffered
writes.

> 
> >
> >One simple way of avoiding that will be to throttle IO even earlier
> >but that means we do not take advantage of writeback cache and buffered
> >writes will slow down.
> 
> If we want to control writeback speed we also must control size of dirty set.
> There are several possibilities: we either can start writeback earlier,
> or when dirty set exceeds some threshold we will start charging that dirty
> memory into throttler and slow down all tasks who generates this dirty memory.
> Because dirty memory is charged and accounted we can write it without delays.

Ok, so this is equivalent to allowing bursty IO. Admit bunch of IO burst
(dirty set) and then apply throttling rules. Dirty set can be flushed
without throttling if sync requires that but future admission of IO will
be delayed. That can avoid PI problems due arising due to file system
journaling.

We have discussed implementing throttling at higher layer in the past
too.  Various proof of concept implementations had been posted to do
throttling in higher layer.

blk-throttle: Throttle buffered WRITEs in balance_dirty_pages()
https://lkml.org/lkml/2011/6/28/243

buffered write IO controller in balance_dirty_pages()
https://lkml.org/lkml/2012/3/28/275

Andrea Righi had posted some proof of concept implementations too.

None of these implementations ever made any progress. Tejun always
liked the idea of doing throttling at lower layers and then generating
back pressure on bdi which in turn controls the size of dirty set.

To me sovling the issue of Priority inversion in file systems is
important one. If we can't solve that reasonably with existing mechanism
it does make a case that why throttling at higher level might be
interesting.

> 
> >
> >So I am curious how would you take care of these serialization issue.
> >
> >Also the throttlers you are planning to implement, what kind of throttling
> >do they provide. Is it throttling rate per cgroup or per file per cgroup
> >or rules will be per bdi per cgroup or something else.
> 
> Currently I'm thinking about per-cgroup X per-tier. Each bdi will be assigned
> to some tier. It's flexible enough and solves chicken-and-egg problem:
> when disk appears it will be assigned to default tier and can be reassigned.

Ok, this is completely orthogonal issue. It has nothing to do with whether
to apply throttling at block layer or at higher leayer.

To solve the chicken and egg problem we need to take help of user space
here and not rely on kernel storing the rules and apply these when devices
show up.

Also how would you create rules for assigning a bdi to a tier. How would
you identify a bdi uniquely in a persistent manner.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
