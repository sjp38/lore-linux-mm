Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 4F4476B00FB
	for <linux-mm@kvack.org>; Wed,  4 Apr 2012 15:19:28 -0400 (EDT)
Date: Wed, 4 Apr 2012 15:19:18 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [Lsf] [RFC] writeback and cgroup
Message-ID: <20120404191918.GK12676@redhat.com>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120404145134.GC12676@redhat.com>
 <CAH2r5mtwQa0Uu=_Yd2JywVJXA=OMGV43X_OUfziC-yeVy9BGtQ@mail.gmail.com>
 <20120404185605.GC29686@dhcp-172-17-108-109.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120404185605.GC29686@dhcp-172-17-108-109.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Steve French <smfrench@gmail.com>, ctalbott@google.com, rni@google.com, andrea@betterlinux.com, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, lsf@lists.linux-foundation.org, linux-mm@kvack.org, jmoyer@redhat.com, lizefan@huawei.com, linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org

On Wed, Apr 04, 2012 at 11:56:05AM -0700, Tejun Heo wrote:
> On Wed, Apr 04, 2012 at 10:36:04AM -0500, Steve French wrote:
> > > How do you take care of thorottling IO to NFS case in this model? Current
> > > throttling logic is tied to block device and in case of NFS, there is no
> > > block device.
> > 
> > Similarly smb2 gets congestion info (number of "credits") returned from
> > the server on every response - but not sure why congestion
> > control is tied to the block device when this would create
> > problems for network file systems
> 
> I hope the previous replies answered this.  It's about writeback
> getting pressure from bdi and isn't restricted to block devices.

So the controlling knobs for network filesystems will be very different
as current throttling knobs are per device (and not per bdi). So
presumably there will be some throttling logic in network layer (network
tc), and that should communicate the back pressure.

I have tried limiting network traffic on NFS using network controller
and tc but that did not help for variety of reasons.

- We again have the problem of losing submitter's context down the layer.

- We have interesting TCP/IP sequencing issues. I don't have the details
  but if you throttle traffic from one group, it kind of led to some 
  kind of multiple re-transmissions from server for ack due to some
  sequence number issues. Sorry, I am short on details as it was long back
  and nfs guys told me that pNFS might help here.

  The basic problem seemed to that that if you multiplex traffic from
  all cgroups on single tcp/ip session and then choke IO suddenly from
  one of them, that was leading to some sequence number issues and led
  to really sucky performance.

So something to keep in mind while coming up ways for how to implement
throttling for network file systems.

Thanks
Vivek 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
