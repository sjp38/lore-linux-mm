Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 581B26B007E
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 12:24:56 -0500 (EST)
Date: Wed, 7 Mar 2012 18:24:53 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [Lsf-pc] [ATTEND] [LSF/MM TOPIC] Buffered writes throttling
Message-ID: <20120307172453.GA31803@quack.suse.cz>
References: <4F507453.1020604@suse.com>
 <20120302153322.GB26315@redhat.com>
 <20120305202330.GD11238@quack.suse.cz>
 <20120305214130.GG18546@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120305214130.GG18546@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, Andrea Righi <andrea@betterlinux.com>, Suresh Jayaraman <sjayaraman@suse.com>

On Mon 05-03-12 16:41:30, Vivek Goyal wrote:
> On Mon, Mar 05, 2012 at 09:23:30PM +0100, Jan Kara wrote:
> [..]
> > > Because filesystems are not cgroup aware, throtting IO below filesystem
> > > has dangers of IO of faster cgroups being throttled behind slower cgroup
> > > (journalling was one example and there could be others). Hence, I personally
> > > think that this problem should be solved at higher layer and that is when
> > > we are actually writting to the cache. That has the disadvantage of still
> > > seeing IO spikes at the device but I guess we live with that. Doing it
> > > at higher layer also allows to use the same logic for NFS too otherwise
> > > NFS buffered write will continue to be a problem.
> >   Well, I agree limiting of memory dirty rate has a value but if I look at
> > a natural use case where I have several cgroups and I want to make sure
> > disk time is fairly divided among them, then limiting dirty rate doesn't
> > quite do what I need.
> 
> Actually "proportional IO control" generally addresses the use case of
> disk time being fairly divided among cgroups. The "throttling/upper limit"
> I think is more targeted towards the cases where you have bandwidth but
> you don't want to give it to user as user has not paid for that kind
> of service. Though it could be used for other things like monitoring the
> system dynamically and throttling rates of a particular cgroup if admin
> thinks that particular cgroup is doing too much of IO. Or for things like,
> start a backup operation with an upper limit of say 50MB/s so that it
> does not affect other system activities too much.
  Well, I was always slightly sceptical that these absolute bandwidth
limits are that great thing. If some cgroup beats your storage with 10 MB/s
of random tiny writes, then it uses more of your resources than an
streaming 50 MB/s write. So although admins might be tempted to use
throughput limits at the first moment because they are easier to
understand, they might later find it's not quite what they wanted.

Specifically for the imagined use case where a customer pays just for a
given bandwidth, you can achieve similar (and IMHO more reliable) results
using proportional control. Say you have available 100 MB/s sequential IO
bandwidth and you would like to limit cgroup to 10 MB/s. Then you just
give it weight 10. Another cgroup paying for 20 MB/s would get weight 20
and so on. If you are a clever provider and pack your load so that machine
is well utilized, cgroups will get limited roughly at given bounds...

> > Because I'm interested in time it takes disk to
> > process the combination of reads, direct IO, and buffered writes the cgroup
> > generates. Having the limits for dirty rate and other IO separate means I
> > have to be rather pesimistic in setting the bounds so that combination of
> > dirty rate + other IO limit doesn't exceed the desired bound but this is
> > usually unnecessarily harsh...
> 
> Yes, seprating out the throttling limits for "reads + direct writes +
> certain wriththrough writes" and "buffered writes" is not ideal. But
> it might still have some value for specific use cases (writes over NFS,
> backup application, throttling a specific disk hog workload etc).
> 
> > 
> > We agree though (as we spoke together last year) that throttling at block
> > layer isn't really an option at least for some filesystems such as ext3/4.
> 
> Yes, because of jorunalling issues and ensuring serialization,
> throttling/upper limit at block/device level becomes less attractive.
> 
> > But what seemed like a plausible idea to me was that we'd account all IO
> > including buffered writes at block layer (there we'd need at least
> > approximate tracking of originator of the IO - tracking inodes as Greg did
> > in his patch set seemed OK) but throttle only direct IO & reads. Limitting
> > of buffered writes would then be achieved by
> >   a) having flusher thread choose inodes to write depending on how much
> > available disk time cgroup has and
> >   b) throttling buffered writers when cgroup has too many dirty pages.
> 
> I am trying to remember what we had discussed. There have been so many 
> ideas floated in this area, that now I get confused.
> 
> So lets take throttling/upper limit out of the picture for a moment and just
> focus on the use case of proportional IO (fare share of disk among cgroups).
> 
> - In that case yes, we probably can come up with some IO tracking
>   mechanism so that IO can be accounted to right cgroup (IO originator's
>   cgroup) at block layer. We could either store some info in "struct
>   page" or do some approximation as you mentioned like inode owner.
> 
> - With buffered IO accounted to right cgroup, CFQ should automatically
>   start providing cgroup its fair share (Well little changes will be
>   required). But there are still two more issues.
> 
> 	- Issue of making writeback cgroup aware. I am assuming that
> 	  this work will be taken forward by Greg.
> 
> 	- Breaking down request descriptors into some kind of per cgroup
>  	  notion so that one cgroup is not stuck behind other. (Or come
>  	  up with a different mechanism for per cgroup congestion).
> 
>  That way, if a cgroup is congested at CFQ, flusher should stop submitting
>  more IO for it, that will lead to increased dirty pages in memcg and that
>  should throttle the application.
> 
> So all of the aove seems to be proportional IO (fair shrae of disk). This
> should still be co-exist with "throttling/upper limit" implementation/knobs
> and one is not necessarily replacement for other?
  Well, I don't see a strict reason why the above won't work for "upper
limit" knobs. After all, these knobs just mean you don't want to submit
more that X MB of IO in 1 second. So you just need flusher thread to check
against such limit as well.

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
