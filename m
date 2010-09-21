Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id EA9626B004A
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 05:04:22 -0400 (EDT)
Date: Tue, 21 Sep 2010 10:04:07 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Default zone_reclaim_mode = 1 on NUMA kernel is bad
	forfile/email/web servers
Message-ID: <20100921090407.GA11439@csn.ul.ie>
References: <1284349152.15254.1394658481@webmail.messagingengine.com> <20100916184240.3BC9.A69D9226@jp.fujitsu.com> <20100920093440.GD1998@csn.ul.ie> <52C8765522A740A4A5C027E8FDFFDFE3@jem>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <52C8765522A740A4A5C027E8FDFFDFE3@jem>
Sender: owner-linux-mm@kvack.org
To: Rob Mueller <robm@fastmail.fm>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Bron Gondwana <brong@fastmail.fm>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 21, 2010 at 09:41:21AM +1000, Rob Mueller wrote:
>> I don't think we will ever get the default value for this tunable right.
>> I would also worry that avoiding the reclaim_mode for file-backed
>> cache will hurt HPC applications that are dumping their data to disk
>> and depending on the existing default for zone_reclaim_mode to not
>> pollute other nodes.
>>
>> The ideal would be if distribution packages for mail, web servers
>> and others that are heavily IO orientated would prompt for a change
>> to the default value of zone_reclaim_mode in sysctl.
>
> I would argue that there's a lot more mail/web/file servers out there 
> than HPC machines. And HPC machines tend to have a team of people to  
> monitor/tweak them. I think it would be much more sane to default this to 
> 0 which works best for most people, and get the HPC people to change it.
>

No doubt this is true. The only real difference is that there are more NUMA
machines running mail/web/file servers now than there might have been in the
past. The default made sense once upon a time. Personally I wouldn't mind
the default changing but my preference would be that distribution packages
installing on NUMA machines would prompt if the default should be changed if it
is likely to be of benefit for that package (e.g. the mail, file and web ones).

> However there's still another question, why is this problem happening at 
> all for us? I know almost nothing about NUMA, but from other posts, it 
> sounds like the problem is the memory allocations are all happening on 
> one node?

Yes.

> But I don't understand why that would be happening.

Because in a situation where you have many NUMA-aware applications
running bound to CPUs, it performs better if they always allocate from
local nodes instead of accessing remote nodes. It's great for one type
of workload but not so much for mail/web/file.

> The machine 
> runs the cyrus IMAP server, which is a classic unix forking server with 
> 1000's of processes. Each process will mmap lots of different files to 
> access them. Why would that all be happening on one node, not spread 
> around?
>

Honestly, I don't know and I don't have such a machine to investigate
with. My guess is that there are a number of files that are hot and
accessed by multiple processes on different nodes and they are evicting
each other but it's only a guess.

> One thing is that the machine is vastly more IO loaded than CPU loaded, 
> in fact it uses very little CPU at all (a few % usually). Does the kernel 
> prefer to run processes on one particular node if it's available?

It prefers to run on the same node it ran previously. If they all
happened to start up on a small subset of nodes, they could be
continually getting running there.

> So if a 
> machine has very little CPU load, every process will generally end up  
> running on the same node?
>

It's possible they are running on a small subset. mpstat should be able
to give a basic idea of what the spread across CPUs is.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
