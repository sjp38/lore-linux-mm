Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 71F6B6B0044
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 04:47:37 -0400 (EDT)
Message-ID: <4F97BA13.8060705@suse.com>
Date: Wed, 25 Apr 2012 14:17:15 +0530
From: Suresh Jayaraman <sjayaraman@suse.com>
MIME-Version: 1.0
Subject: Re: [Lsf] [RFC] writeback and cgroup
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com> <20120404145134.GC12676@redhat.com> <CAH2r5mtwQa0Uu=_Yd2JywVJXA=OMGV43X_OUfziC-yeVy9BGtQ@mail.gmail.com> <20120404185605.GC29686@dhcp-172-17-108-109.mtv.corp.google.com> <20120404191918.GK12676@redhat.com>
In-Reply-To: <20120404191918.GK12676@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Tejun Heo <tj@kernel.org>, Steve French <smfrench@gmail.com>, ctalbott@google.com, rni@google.com, andrea@betterlinux.com, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, lsf@lists.linux-foundation.org, linux-mm@kvack.org, jmoyer@redhat.com, lizefan@huawei.com, linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org

On 04/05/2012 12:49 AM, Vivek Goyal wrote:
> On Wed, Apr 04, 2012 at 11:56:05AM -0700, Tejun Heo wrote:
>> On Wed, Apr 04, 2012 at 10:36:04AM -0500, Steve French wrote:
>>>> How do you take care of thorottling IO to NFS case in this model? Current
>>>> throttling logic is tied to block device and in case of NFS, there is no
>>>> block device.
>>>
>>> Similarly smb2 gets congestion info (number of "credits") returned from
>>> the server on every response - but not sure why congestion
>>> control is tied to the block device when this would create
>>> problems for network file systems
>>
>> I hope the previous replies answered this.  It's about writeback
>> getting pressure from bdi and isn't restricted to block devices.
> 
> So the controlling knobs for network filesystems will be very different
> as current throttling knobs are per device (and not per bdi). So
> presumably there will be some throttling logic in network layer (network
> tc), and that should communicate the back pressure.

Tried to figure out potential use-case scenarios for controlling Network
I/O resource from netfs POV (which ideally should guide the interfaces).

- Is finer grained control of network I/O is desirable/useful or being
  able to control bandwidth at per server level is sufficient? Consider
  the case where there are different NFS volumes mounted from the same
  NFS/CIFS server,

    /backup
    /missioncritical_data
    /apps
    /documents

  admin being able to set bandwidth limits to the each of these
  mounts based on how important would be a useful feature. If we try to
  build the logic in the network layer using tc then this still
  wouldn't be possible to limit the tasks that are writing to more than
  one volumes? (need some logic in netfs as well?). Network filesystem
  clients typically are not bothered much about the actual device but
  about the exported share. So it appears that the controlling knobs
  could be different for netfs.

- Provide minimimum guarantees for the Network I/O to keep going
  irrespective of the overloaded workload situations. i.e. operations
  that are local to the machine should not hamper Network I/O or
  operations that are happening on one mount should not impact
  operations that are happening on another mount.

  IIRC, while we currently would be able to limit maximum usage, we
  don't guarantee the minimum quantity of the resource that would be
  available in general for all controllers. This might be important from
  QoS guarantee POV.

- What are the other use-cases where limiting Network I/O would be
  useful?

> I have tried limiting network traffic on NFS using network controller
> and tc but that did not help for variety of reasons.
> 

A quick look at the current net_tls implementation shows that it allows
setting priorities but doesn't seem to provide ways to limit the
throughput? Or is it still possible?
If not did you use a out-of-tree implementation to test this?

> - We again have the problem of losing submitter's context down the layer.

If the network layer is cgroup aware why this would be a problem?

> - We have interesting TCP/IP sequencing issues. I don't have the details
>   but if you throttle traffic from one group, it kind of led to some 
>   kind of multiple re-transmissions from server for ack due to some
>   sequence number issues. Sorry, I am short on details as it was long back
>   and nfs guys told me that pNFS might help here.
> 
>   The basic problem seemed to that that if you multiplex traffic from
>   all cgroups on single tcp/ip session and then choke IO suddenly from
>   one of them, that was leading to some sequence number issues and led
>   to really sucky performance.
> 
> So something to keep in mind while coming up ways for how to implement
> throttling for network file systems.
> 


Thanks
Suresh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
