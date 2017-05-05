Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7FB426B02EE
	for <linux-mm@kvack.org>; Fri,  5 May 2017 10:52:41 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y106so1019644wrb.14
        for <linux-mm@kvack.org>; Fri, 05 May 2017 07:52:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 68si6742063wra.23.2017.05.05.07.52.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 May 2017 07:52:40 -0700 (PDT)
Date: Fri, 5 May 2017 16:52:38 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
Message-ID: <20170505145238.GE31461@dhcp22.suse.cz>
References: <20170419075242.29929-1-bsingharora@gmail.com>
 <20170502143608.GM14593@dhcp22.suse.cz>
 <1493875615.7934.1.camel@gmail.com>
 <20170504125250.GH31540@dhcp22.suse.cz>
 <1493912961.25766.379.camel@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1493912961.25766.379.camel@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, arbab@linux.vnet.ibm.com, vbabka@suse.cz, cl@linux.com

On Thu 04-05-17 17:49:21, Benjamin Herrenschmidt wrote:
> On Thu, 2017-05-04 at 14:52 +0200, Michal Hocko wrote:
> > But the direct reclaim would be effective only _after_ all other nodes
> > are full.
> > 
> > I thought that kswapd reclaim is a problem because the HW doesn't
> > support aging properly but as the direct reclaim works then what is the
> > actual problem?
> 
> Ageing isn't isn't completely broken. The ATS MMU supports
> dirty/accessed just fine.
> 
> However the TLB invalidations are quite expensive with a GPU so too
> much harvesting is detrimental, and the GPU tends to check pages out
> using a special "read with intend to write" mode, which means it almost
> always set the dirty bit if the page is writable to begin with.

This sounds pretty much like a HW specific details which is not the
right criterion to design general CDM around.

So let me repeat the fundamental question. Is the only difference from
cpuless nodes the fact that the node should be invisible to processes
unless they specify an explicit node mask? If yes then we are talking
about policy in the kernel and that sounds like a big no-no to me.
Moreover cpusets already support exclusive numa nodes AFAIR.

I am either missing something important here, and the discussion so far
hasn't helped to be honest, or this whole CDM effort tries to build a
generic interface around a _specific_ piece of HW. The matter is worse
by the fact that the described usecases are so vague that it is hard to
build a good picture whether this is generic enough that a new/different
HW will still fit into this picture.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
