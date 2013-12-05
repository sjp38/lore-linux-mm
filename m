Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f54.google.com (mail-yh0-f54.google.com [209.85.213.54])
	by kanga.kvack.org (Postfix) with ESMTP id B7FC46B0036
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 19:53:58 -0500 (EST)
Received: by mail-yh0-f54.google.com with SMTP id z12so12070345yhz.13
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 16:53:58 -0800 (PST)
Received: from mail-yh0-x233.google.com (mail-yh0-x233.google.com [2607:f8b0:4002:c01::233])
        by mx.google.com with ESMTPS id r46si48274052yhm.122.2013.12.04.16.53.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Dec 2013 16:53:57 -0800 (PST)
Received: by mail-yh0-f51.google.com with SMTP id c41so10579542yho.10
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 16:53:57 -0800 (PST)
Date: Wed, 4 Dec 2013 16:53:54 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 3/8] mm, mempolicy: remove per-process flag
In-Reply-To: <00000142be3633ba-2a459537-58fb-444b-a99f-33ff5e5b2aed-000000@email.amazonses.com>
Message-ID: <alpine.DEB.2.02.1312041651080.13608@chino.kir.corp.google.com>
References: <20131119131400.GC20655@dhcp22.suse.cz> <20131119134007.GD20655@dhcp22.suse.cz> <alpine.DEB.2.02.1311192352070.20752@chino.kir.corp.google.com> <20131120152251.GA18809@dhcp22.suse.cz> <alpine.DEB.2.02.1311201917520.7167@chino.kir.corp.google.com>
 <20131128115458.GK2761@dhcp22.suse.cz> <alpine.DEB.2.02.1312021504170.13465@chino.kir.corp.google.com> <alpine.DEB.2.02.1312032116440.29733@chino.kir.corp.google.com> <alpine.DEB.2.02.1312032117490.29733@chino.kir.corp.google.com>
 <00000142be3633ba-2a459537-58fb-444b-a99f-33ff5e5b2aed-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Wed, 4 Dec 2013, Christoph Lameter wrote:

> > PF_MEMPOLICY is an unnecessary optimization for CONFIG_SLAB users.
> > There's no significant performance degradation to checking
> > current->mempolicy rather than current->flags & PF_MEMPOLICY in the
> > allocation path, especially since this is considered unlikely().
> 
> The use of current->mempolicy increase the cache footprint since its in a
> rarely used cacheline. This performance issue would occur when memory
> policies are not used since that cacheline would then have to be touched
> regardless of memory policies be in effect or not. PF_MEMPOLICY was used
> to avoid touching the cacheline.
> 

Right, but it turns out not to matter in practice.  As one of the non-
default CONFIG_SLAB users, and PF_MEMPOLICY only does something for 
CONFIG_SLAB, this patch tested to not show any degradation for specjbb 
which stresses the allocator in terms of throughput:

	   with patch: 128761.54 SPECjbb2005 bops
	without patch: 127576.65 SPECjbb2005 bops

These per-process flags are a scarce resource so I don't think 
PF_MEMPOLICY warrants a bit when it's not shown to be advantageous in 
configurations without mempolicy usage where it's intended to optimize, 
especially for a non-default slab allocator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
