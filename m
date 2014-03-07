Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 521016B0031
	for <linux-mm@kvack.org>; Fri,  7 Mar 2014 15:48:34 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id md12so4645372pbc.23
        for <linux-mm@kvack.org>; Fri, 07 Mar 2014 12:48:34 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ha5si9441327pbc.300.2014.03.07.12.48.32
        for <linux-mm@kvack.org>;
        Fri, 07 Mar 2014 12:48:33 -0800 (PST)
Date: Fri, 7 Mar 2014 12:48:31 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 03/11] mm, mempolicy: remove per-process flag
Message-Id: <20140307124831.69b50f829ed34de8651fa461@linux-foundation.org>
In-Reply-To: <877g866i3c.fsf@tassilo.jf.intel.com>
References: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com>
	<alpine.DEB.2.02.1403041954420.8067@chino.kir.corp.google.com>
	<877g866i3c.fsf@tassilo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Tejun Heo <tj@kernel.org>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, Tim Hockin <thockin@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-doc@vger.kernel.org

On Fri, 07 Mar 2014 09:20:39 -0800 Andi Kleen <andi@firstfloor.org> wrote:

> David Rientjes <rientjes@google.com> writes:
> >
> > Per-process flags are a scarce resource so we should free them up
> > whenever possible and make them available.  We'll be using it shortly for
> > memcg oom reserves.
> 
> I'm not convinced TCP_RR is a meaningfull benchmark for slab.
> 
> The shortness seems like an artificial problem.
> 
> Just add another flag word to the task_struct? That would seem 
> to be the obvious way. People will need it sooner or later anyways.
> 

This is basically what the patch does:

@@ -3259,7 +3259,7 @@ __do_cache_alloc(struct kmem_cache *cach
 {
 	void *objp;
 
-	if (unlikely(current->flags & (PF_SPREAD_SLAB | PF_MEMPOLICY))) {
+	if (current->mempolicy || unlikely(current->flags & PF_SPREAD_SLAB)) {
 		objp = alternate_node_alloc(cache, flags);
 		if (objp)
 			goto out;

It runs when slab goes into the page allocator for backing store (ie:
relatively rarely).  It adds one test-n-branch when a mempolicy is
active and actually removes instructions when no mempolicy is active.

This patch won't be making any difference to anything.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
