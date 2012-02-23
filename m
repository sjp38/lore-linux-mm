Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 258C36B007E
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 19:45:02 -0500 (EST)
Received: by pbcwz17 with SMTP id wz17so930981pbc.14
        for <linux-mm@kvack.org>; Wed, 22 Feb 2012 16:45:01 -0800 (PST)
Date: Wed, 22 Feb 2012 16:44:58 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: add sysctl to enable slab memory dump
In-Reply-To: <20120222115320.GA3107@x61.redhat.com>
Message-ID: <alpine.DEB.2.00.1202221640420.14213@chino.kir.corp.google.com>
References: <20120222115320.GA3107@x61.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, Randy Dunlap <rdunlap@xenotime.net>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Josef Bacik <josef@redhat.com>, linux-kernel@vger.kernel.org

On Wed, 22 Feb 2012, Rafael Aquini wrote:

> Adds a new sysctl, 'oom_dump_slabs', that enables the kernel to produce a
> dump of all eligible system slab caches when performing an OOM-killing.
> Information includes per cache active objects, total objects, object size,
> cache name and cache size.
> 
> The eligibility for being reported is given by an auxiliary sysctl,
> 'oom_dump_slabs_ratio', which express (in percentage) the memory committed
> ratio between a particular cache size and the total slab size.
> 
> This, alongside with all other data dumped in OOM events, is very helpful
> information in diagnosing why there was an OOM condition specially when
> kernel code is under investigation.
> 

I don't like this because it duplicates what is given by /proc/slabinfo 
that can easily be read at the time of oom and is unnecessary to dump to 
the kernel log.  We display the meminfo (which includes the amount of 
slab, just not broken down by cache) because it's absolutely necessary to 
understand why the oom was triggered.  The tasklist dump is allowed 
because it's difficult to attain all that information easily and to 
determine which threads are eligible in the oom context (global, memcg, 
cpuset, mempolicy) so they matter to the oom condition.  The per-cache 
slabinfo fits neither of that criteria and just duplicates code in the 
slab allocators that is attainable elsewhere.

I think this also gives another usecase for a possible /dev/mem_notify in 
the future: userspace could easily poll on an eventfd and wait for an oom 
to occur and then cat /proc/slabinfo to attain all this.  In other words, 
if we had this functionality (which I think we undoubtedly will in the 
future), this patch would be obsoleted.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
