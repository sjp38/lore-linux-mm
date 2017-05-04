Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id EB0F3831F4
	for <linux-mm@kvack.org>; Thu,  4 May 2017 08:52:58 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id h65so1451787wmd.7
        for <linux-mm@kvack.org>; Thu, 04 May 2017 05:52:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e48si2319429wre.324.2017.05.04.05.52.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 May 2017 05:52:57 -0700 (PDT)
Date: Thu, 4 May 2017 14:52:50 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
Message-ID: <20170504125250.GH31540@dhcp22.suse.cz>
References: <20170419075242.29929-1-bsingharora@gmail.com>
 <20170502143608.GM14593@dhcp22.suse.cz>
 <1493875615.7934.1.camel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1493875615.7934.1.camel@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, arbab@linux.vnet.ibm.com, vbabka@suse.cz, cl@linux.com

On Thu 04-05-17 15:26:55, Balbir Singh wrote:
> On Tue, 2017-05-02 at 16:36 +0200, Michal Hocko wrote:
> > On Wed 19-04-17 17:52:38, Balbir Singh wrote:
[...]
> > > 2. kswapd reclaim
> > 
> > How is the memory reclaim handled then? How are users expected to handle
> > OOM situation?
> > 
> 
> 1. The fallback node list for coherent memory includes regular memory
>    nodes
> 2. Direct reclaim works, I've tested it

But the direct reclaim would be effective only _after_ all other nodes
are full.

I thought that kswapd reclaim is a problem because the HW doesn't
support aging properly but as the direct reclaim works then what is the
actual problem?
 
> > > The reason for exposing this device memory as NUMA is to simplify
> > > the programming model, where memory allocation via malloc() or
> > > mmap() for example would seamlessly work across both kinds of
> > > memory. Since we expect the size of device memory to be smaller
> > > than system RAM, we would like to control the allocation of such
> > > memory. The proposed mechanism reuses nodemasks and explicit
> > > specification of the coherent node in the nodemask for allocation
> > > from device memory. This implementation also allows for kernel
> > > level allocation via __GFP_THISNODE and existing techniques
> > > such as page migration to work.
> > 
> > so it basically resembles isol_cpus except for memory, right. I believe
> > scheduler people are more than unhappy about this interface...
> >
> 
> isol_cpus were for an era when timer/interrupts and other scheduler
> infrastructure present today was not around, but I don't mean to digress.

AFAIU, it has been added to _isolate_ some cpus from the scheduling domain
and have them available for the explicit affinity usage. You are
effectivelly proposing the same thing.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
