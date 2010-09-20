Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 84A306B004A
	for <linux-mm@kvack.org>; Mon, 20 Sep 2010 19:41:32 -0400 (EDT)
Message-ID: <52C8765522A740A4A5C027E8FDFFDFE3@jem>
From: "Rob Mueller" <robm@fastmail.fm>
References: <1284349152.15254.1394658481@webmail.messagingengine.com> <20100916184240.3BC9.A69D9226@jp.fujitsu.com> <20100920093440.GD1998@csn.ul.ie>
Subject: Re: Default zone_reclaim_mode = 1 on NUMA kernel is bad forfile/email/web servers
Date: Tue, 21 Sep 2010 09:41:21 +1000
MIME-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-15";
	reply-type=original
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Bron Gondwana <brong@fastmail.fm>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> I don't think we will ever get the default value for this tunable right.
> I would also worry that avoiding the reclaim_mode for file-backed
> cache will hurt HPC applications that are dumping their data to disk
> and depending on the existing default for zone_reclaim_mode to not
> pollute other nodes.
>
> The ideal would be if distribution packages for mail, web servers
> and others that are heavily IO orientated would prompt for a change
> to the default value of zone_reclaim_mode in sysctl.

I would argue that there's a lot more mail/web/file servers out there than 
HPC machines. And HPC machines tend to have a team of people to 
monitor/tweak them. I think it would be much more sane to default this to 0 
which works best for most people, and get the HPC people to change it.

However there's still another question, why is this problem happening at all 
for us? I know almost nothing about NUMA, but from other posts, it sounds 
like the problem is the memory allocations are all happening on one node? 
But I don't understand why that would be happening. The machine runs the 
cyrus IMAP server, which is a classic unix forking server with 1000's of 
processes. Each process will mmap lots of different files to access them. 
Why would that all be happening on one node, not spread around?

One thing is that the machine is vastly more IO loaded than CPU loaded, in 
fact it uses very little CPU at all (a few % usually). Does the kernel 
prefer to run processes on one particular node if it's available? So if a 
machine has very little CPU load, every process will generally end up 
running on the same node?

Rob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
