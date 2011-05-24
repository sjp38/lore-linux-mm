Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D71916B0023
	for <linux-mm@kvack.org>; Tue, 24 May 2011 16:24:31 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id p4OKOQwD010438
	for <linux-mm@kvack.org>; Tue, 24 May 2011 13:24:26 -0700
Received: from pvc12 (pvc12.prod.google.com [10.241.209.140])
	by hpaq5.eem.corp.google.com with ESMTP id p4OKO9Zh013950
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 24 May 2011 13:24:25 -0700
Received: by pvc12 with SMTP id 12so3266381pvc.28
        for <linux-mm@kvack.org>; Tue, 24 May 2011 13:24:25 -0700 (PDT)
Date: Tue, 24 May 2011 13:24:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH resend^2] mm: increase RECLAIM_DISTANCE to 30
In-Reply-To: <20110524130700.079b09e8.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1105241311260.14396@chino.kir.corp.google.com>
References: <20110411172004.0361.A69D9226@jp.fujitsu.com> <1302557371.7286.16607.camel@nimitz> <20110412100129.43F1.A69D9226@jp.fujitsu.com> <1302575241.7286.17853.camel@nimitz> <20110524130700.079b09e8.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris McDermott <lcm@linux.vnet.ibm.com>

On Tue, 24 May 2011, Andrew Morton wrote:

> How's that digging coming along?
> 
> I'm pretty wobbly about this patch.  Perhaps we should set
> RECLAIM_DISTANCE to pi/2 or something, to force people to correctly set
> the dang thing in initscripts.
> 

I think RECLAIM_DISTANCE as a constant is the wrong approach to begin 
with.

The distance between nodes as specified by the SLIT imply that a node with 
a distance of 30 has a relative distance of 3x than a local memory access.  
That's not the same as implying the latency is 3x greater, though, since 
the SLIT is based on relative distances according to ACPI 3.0.  In other 
words, it's perfectly legitimate for node 0 to have a distance of 20 and 
30 to nodes 1 and 2, respectively, if their memory access latencies are 5x 
and 10x greater, while the SLIT would remain unchanged if the latencies 
were 2x and 3x.

So basing zone reclaim by default off of a relative distance specified in 
the SLIT is wrong to begin with, and that's probably why we notice that 
the old value of 20 doesn't suffice on some machines anymore.

As I suggested earlier, I think it would be far better to actually measure 
the memory access latency to remote nodes at boot to determine whether to 
prefer zone reclaim or not rather than basing it off a false SLIT 
assumption.

Notice also that the machines that this patch was proposed for probably 
also didn't have a custom SLIT to begin with and so remote nodes get a 
default value of REMOTE_DISTANCE, which equaled RECLAIM_DISTANCE.  The 
same effect would have been achieved if you had decreased REMOTE_DISTANCE 
to 15.

We probably shouldn't be using SLIT distances at all within the kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
