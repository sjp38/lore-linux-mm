Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id UAA27260
	for <linux-mm@kvack.org>; Thu, 12 Sep 2002 20:50:58 -0700 (PDT)
Message-ID: <3D81643C.4C4E862C@digeo.com>
Date: Thu, 12 Sep 2002 21:06:20 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [PATCH] per-zone kswapd process
References: <3D815C8C.4050000@us.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, William Lee Irwin III <wli@holomorphy.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> 
> This patch implements a kswapd process for each memory zone.

I still don't see why it's per zone and not per node.  It seems strange
that a wee little laptop would be running two kswapds?

kswapd can get a ton of work done in the development VM and one per
node would, I expect, suffice?

Also, I'm wondering why the individual kernel threads don't have
their affinity masks set to make them run on the CPUs to which the
zone (or zones) are local?

Isn't it the case that with this code you could end up with a kswapd
on node 0 crunching on node 1's pages while a kswapd on node 1 crunches
on node 0's pages?

If I'm not totally out to lunch on this, I'd have thought that a
better approach would be

	int sys_kswapd(int nid)
	{
		return kernel_thread(kswapd, ...);
	}

Userspace could then set up the CPU affinity based on some topology
or config information and would then parent a kswapd instance.  That
kswapd instance would then be bound to the CPUs which were on the
node identified by `nid'.

Or something like that?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
