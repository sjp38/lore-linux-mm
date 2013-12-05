Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1BB916B0039
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 14:05:48 -0500 (EST)
Received: by mail-qc0-f169.google.com with SMTP id r5so5224893qcx.14
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 11:05:47 -0800 (PST)
Received: from a9-113.smtp-out.amazonses.com (a9-113.smtp-out.amazonses.com. [54.240.9.113])
        by mx.google.com with ESMTP id k3si44860119qao.10.2013.12.05.11.05.43
        for <linux-mm@kvack.org>;
        Thu, 05 Dec 2013 11:05:45 -0800 (PST)
Date: Thu, 5 Dec 2013 19:05:41 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch 3/8] mm, mempolicy: remove per-process flag
In-Reply-To: <alpine.DEB.2.02.1312041651080.13608@chino.kir.corp.google.com>
Message-ID: <00000142c426b81a-45e6815b-bde4-483c-975e-ce1eea42a753-000000@email.amazonses.com>
References: <20131119131400.GC20655@dhcp22.suse.cz> <20131119134007.GD20655@dhcp22.suse.cz> <alpine.DEB.2.02.1311192352070.20752@chino.kir.corp.google.com> <20131120152251.GA18809@dhcp22.suse.cz> <alpine.DEB.2.02.1311201917520.7167@chino.kir.corp.google.com>
 <20131128115458.GK2761@dhcp22.suse.cz> <alpine.DEB.2.02.1312021504170.13465@chino.kir.corp.google.com> <alpine.DEB.2.02.1312032116440.29733@chino.kir.corp.google.com> <alpine.DEB.2.02.1312032117490.29733@chino.kir.corp.google.com>
 <00000142be3633ba-2a459537-58fb-444b-a99f-33ff5e5b2aed-000000@email.amazonses.com> <alpine.DEB.2.02.1312041651080.13608@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Wed, 4 Dec 2013, David Rientjes wrote:

>
> Right, but it turns out not to matter in practice.  As one of the non-
> default CONFIG_SLAB users, and PF_MEMPOLICY only does something for
> CONFIG_SLAB, this patch tested to not show any degradation for specjbb
> which stresses the allocator in terms of throughput:
>
> 	   with patch: 128761.54 SPECjbb2005 bops
> 	without patch: 127576.65 SPECjbb2005 bops

Specjbb? What does Java have to do with this?
Can you run the synthetic in kernel slab benchmark.

Like this one https://lkml.org/lkml/2009/10/13/459

> These per-process flags are a scarce resource so I don't think
> PF_MEMPOLICY warrants a bit when it's not shown to be advantageous in
> configurations without mempolicy usage where it's intended to optimize,
> especially for a non-default slab allocator.

PF_MEMPOLICY was advantageous when Paul Jackson introduced and benchmarked
it.

SLUB supports mempolicies through allocate_pages but it will allocate all
objects out of one slab pages before retrieving another page following the
policy. Thats why PF_MEMPOLICY and the other per object handling can be
avoided in its fastpath. Thus PF_MEMPOLICY is not that important there.

However, SLAB is still the allocator in use for RHEL which puts some
importance on still supporting SLAB.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
