Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8314B6B0038
	for <linux-mm@kvack.org>; Fri,  5 May 2017 13:49:00 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id c28so4505687qta.8
        for <linux-mm@kvack.org>; Fri, 05 May 2017 10:49:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o71si5366698qke.72.2017.05.05.10.48.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 May 2017 10:48:59 -0700 (PDT)
Date: Fri, 5 May 2017 13:48:53 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
Message-ID: <20170505174851.GA6534@redhat.com>
References: <20170419075242.29929-1-bsingharora@gmail.com>
 <20170502143608.GM14593@dhcp22.suse.cz>
 <1493875615.7934.1.camel@gmail.com>
 <20170504125250.GH31540@dhcp22.suse.cz>
 <1493912961.25766.379.camel@kernel.crashing.org>
 <20170505145238.GE31461@dhcp22.suse.cz>
 <1493999822.25766.397.camel@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1493999822.25766.397.camel@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Michal Hocko <mhocko@suse.com>, Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, mgorman@techsingularity.net, arbab@linux.vnet.ibm.com, vbabka@suse.cz, cl@linux.com

On Fri, May 05, 2017 at 05:57:02PM +0200, Benjamin Herrenschmidt wrote:
> On Fri, 2017-05-05 at 16:52 +0200, Michal Hocko wrote:
> > 
> > This sounds pretty much like a HW specific details which is not the
> > right criterion to design general CDM around.
> 
> Which is why I don't see what's the problem with simply making this
> a hot-plugged NUMA node, since it's basically what it is with a
> "different" kind of CPU, possibly covered with a CMA, which provides
> both some isolation and the ability to do large physical allocations
> for applications who chose to use the legacy programming interfaces and
> manually control the memory.
> 
> Then, the "issues" with things like reclaim, autonuma can be handled
> with policy tunables. Possibly node attributes.
> 
> It seems to me that such a model fits well in the picture where we are
> heading not just with GPUs, but with OpenCAPI based memory, CCIX or
> other similar technologies that can provide memory possibly with co-
> located acceleration devices.
> 
> It also mostly already just work.
> 
> > So let me repeat the fundamental question. Is the only difference from
> > cpuless nodes the fact that the node should be invisible to processes
> > unless they specify an explicit node mask?
> 
> It would be *preferable* that it is.
> 
> It's not necessarily an absolute requirement as long as what lands
> there can be kicked out. However the system would potentially be
> performing poorly if too much unrelated stuff lands on the GPU memory
> as it has a much higher latency.
> 
> Due to the nature of GPUs (and possibly other such accelerators but not
> necessarily all of them), that memory is also more likely to fail. GPUs
> crash often. However that isn't necessarily true of OpenCAPI devices or
> CCIX.
> 
> This is the kind of attributes of the memory (quality ?) that can be
> provided by the driver that is putting it online. We can then
> orthogonally decide how we chose (or not) to take those into account,
> either in the default mm algorithms or from explicit policy mechanisms
> set from userspace, but the latter is often awkward and never done
> right.
> 
> >  If yes then we are talking
> > about policy in the kernel and that sounds like a big no-no to me.
> 
> It makes sense to expose a concept of "characteristics" of a given
> memory node that affect the various policies the user can set.
> 
> It makes sense to have "default" policy models selected.
> 
> Policies aren't always decided in the kernel indeed (though they are
> more often than not, face it, most of the time, leaving it to userspace
> results in things simply not working). However the mechanisms by which
> the policy is applied are in the kernel.
> 
> > Moreover cpusets already support exclusive numa nodes AFAIR.
> 
> Which implies that the user would have to do epxlciit cpuset
> manipulations for the system to work right ? Most user wouldn't and the
> rsult is that most user would have badly working systems. That's almost
> always what happens when we chose to bounce *all* policy decision to
> the user without the kernel attempting to have some kind of semi-sane
> default.
> 
> > I am either missing something important here, and the discussion so
> far
> > hasn't helped to be honest, or this whole CDM effort tries to build a
> > generic interface around a _specific_ piece of HW. 
> 
> No. You guys have just been sticking your head in the sand for month
> for reasons I can't quite understand completely :-)
> 
> There is a definite direction out there for devices to participate in
> cache coherency and to operate within user process MMU contexts. This
> is what the GPUs on P9 will be doing via nvlink, but this will also be
> possible with technologies like OpenCAPI, I believe CCIX, etc...
> 
> This is by no mean a special case.
> 
> > The matter is worse
> > by the fact that the described usecases are so vague that it is hard to
> > build a good picture whether this is generic enough that a new/different
> > HW will still fit into this picture.
> 
> The GPU use case is rather trivial.
> 
> The end goal is to simply have accelerators transparently operate in
> userspace context, along with the ability to migrate page to the memory
> that is the most efficient for a given operation.
> 
> Thus for example, mmap a large file (page cache) and have the program
> pass a pointer to that mmap to a GPU program that starts churning on
> it.
> 
> In the specific GPU case, we have HW on the link telling us the pages
> are pounded on remotely, allowing us to trigger migration toward GPU
> memory (but the other way works too).
> 
> The problem with the HMM based approach is that it is based on
> ZONE_DEVICE. This means "special" struct pages that aren't in LRU and
> implies, at least that's my understanding, piles of special cases all
> over the place to deal with them, along with various APIs etc... that
> don't work with such pages.
> 
> So it makes it difficult to be able to pickup anything mapped into a
> process address space, whether it is page cache pages, shared memory,
> etc... and migrate it to GPU pages.
> 
> At least, that's my understanding and Jerome somewhat confirmed it,
> we'd end up fighting an uphill battle dealing with all those special
> cases. HMM is well suited for non-coherent systems with a distinct MMU
> translation on the remote device.

Well there is _no_ migration issues with HMM (anonymous or file back
pages). What you don't get is thing like lru or numa balancing but i
believe you do not want either of those anyway.

Sure a carefull audit of all code path is needed to make sure that
such page does not end up in place it shouldn't (like put back on
lru).

Now you are also excluded of lot of thing, like for instance read
ahead would never use a ZONE_DEVICE page to read ahead a file. But
many of those thing are easy to add back if they are important to
you.

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
