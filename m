Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 2C0966B0035
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 19:05:40 -0400 (EDT)
Received: by mail-ie0-f177.google.com with SMTP id at20so1535515iec.8
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 16:05:40 -0700 (PDT)
Received: from mail-ie0-x22e.google.com (mail-ie0-x22e.google.com [2607:f8b0:4001:c03::22e])
        by mx.google.com with ESMTPS id ms7si9777286icc.78.2014.07.23.16.05.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Jul 2014 16:05:39 -0700 (PDT)
Received: by mail-ie0-f174.google.com with SMTP id rp18so1613834iec.33
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 16:05:39 -0700 (PDT)
Date: Wed, 23 Jul 2014 16:05:36 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [BUG] THP allocations escape cpuset when defrag is off
In-Reply-To: <20140723225742.GU8578@sgi.com>
Message-ID: <alpine.DEB.2.02.1407231600110.1389@chino.kir.corp.google.com>
References: <20140723220538.GT8578@sgi.com> <alpine.DEB.2.02.1407231516570.23495@chino.kir.corp.google.com> <20140723225742.GU8578@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, riel@redhat.com, kirill.shutemov@linux.intel.com, mingo@kernel.org, hughd@google.com, lliubbo@gmail.com, hannes@cmpxchg.org, srivatsa.bhat@linux.vnet.ibm.com, dave.hansen@linux.intel.com, dfults@sgi.com, hedi@sgi.com

On Wed, 23 Jul 2014, Alex Thorlton wrote:

> > It's also been a long-standing issue that cpusets and mempolicies are 
> > ignored by khugepaged that allows memory to be migrated remotely to nodes 
> > that are not allowed by a cpuset's mems or a mempolicy's nodemask.  Even 
> > with this issue fixed, you may find that some memory is migrated remotely, 
> > although it may be negligible, by khugepaged.
> 
> A bit here and there is manageable.  There is, of course, some work to
> be done there, but for now we're mainly concerned with a job that's
> supposed to be confined to a cpuset spilling out and soaking up all the
> memory on a machine.
> 

You may find my patch[*] in -mm to be helpful if you enable 
zone_reclaim_mode.  It changes khugepaged so that it is not allowed to 
migrate any memory to a remote node where the distance between the nodes 
is greater than RECLAIM_DISTANCE.

These issues are still pending and we've encountered a couple of them in 
the past weeks ourselves.  The definition of RECLAIM_DISTANCE, currently 
at 30 for x86, is relying on the SLIT to define when remote access is 
costly and there are cases where people need to alter the BIOS to 
workaround this definition.

We can hope that NUMA balancing will solve a lot of these problems for us, 
but there's always a chance that the VM does something totally wrong which 
you've undoubtedly encountered already.

 [*] http://ozlabs.org/~akpm/mmots/broken-out/mm-thp-only-collapse-hugepages-to-nodes-with-affinity-for-zone_reclaim_mode.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
