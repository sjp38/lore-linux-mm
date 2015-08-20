Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 176E66B0253
	for <linux-mm@kvack.org>; Wed, 19 Aug 2015 20:00:25 -0400 (EDT)
Received: by padfo6 with SMTP id fo6so7604025pad.0
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 17:00:24 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id w12si4196035pbs.108.2015.08.19.17.00.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Aug 2015 17:00:24 -0700 (PDT)
Received: by pawq9 with SMTP id q9so13719905paw.3
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 17:00:24 -0700 (PDT)
Date: Wed, 19 Aug 2015 17:00:22 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Patch V3 2/9] kernel/profile.c: Replace cpu_to_mem() with
 cpu_to_node()
In-Reply-To: <55D42DE3.2040506@linux.intel.com>
Message-ID: <alpine.DEB.2.10.1508191657330.30666@chino.kir.corp.google.com>
References: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com> <1439781546-7217-3-git-send-email-jiang.liu@linux.intel.com> <alpine.DEB.2.10.1508171730260.5527@chino.kir.corp.google.com> <55D42DE3.2040506@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

On Wed, 19 Aug 2015, Jiang Liu wrote:

> On 2015/8/18 8:31, David Rientjes wrote:
> > On Mon, 17 Aug 2015, Jiang Liu wrote:
> > 
> >> Function profile_cpu_callback() allocates memory without specifying
> >> __GFP_THISNODE flag, so replace cpu_to_mem() with cpu_to_node()
> >> because cpu_to_mem() may cause suboptimal memory allocation if
> >> there's no free memory on the node returned by cpu_to_mem().
> >>
> > 
> > Why is cpu_to_node() better with regard to free memory and NUMA locality?
> Hi David,
> 	Thanks for review. This is a special case pointed out by Tejun.
> For the imagined topology, A<->B<->X<->C<->D, where A, B, C, D has
> memory and X is memoryless.
> Possible fallback lists are:
> B: [ B, A, C, D]
> X: [ B, C, A, D]
> C: [ C, D, B, A]
> 
> cpu_to_mem(X) will either return B or C. Let's assume it returns B.
> Then we will use "B: [ B, A, C, D]" to allocate memory for X, which
> is not the optimal fallback list for X. And cpu_to_node(X) returns
> X, and "X: [ B, C, A, D]" is the optimal fallback list for X.

Ok, that makes sense, but I would prefer that this 
alloc_pages_exact_node() change to alloc_pages_node() since, as you 
mention in your commit message, __GFP_THISNODE is not set.

In the longterm, if we setup both zonelists correctly (no __GFP_THISNODE 
and with __GFP_THISNODE), then I'm not sure there's any reason to ever use 
cpu_to_mem() for alloc_pages().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
