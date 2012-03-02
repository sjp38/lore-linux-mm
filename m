Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 23ADF6B004A
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 18:47:20 -0500 (EST)
Received: by dadv6 with SMTP id v6so2496334dad.14
        for <linux-mm@kvack.org>; Fri, 02 Mar 2012 15:47:19 -0800 (PST)
Date: Fri, 2 Mar 2012 15:47:17 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] cpuset: mm: Remove memory barrier damage from the page
 allocator
In-Reply-To: <1330723529.11248.237.camel@twins>
Message-ID: <alpine.DEB.2.00.1203021540040.18377@chino.kir.corp.google.com>
References: <20120302112358.GA3481@suse.de> <alpine.DEB.2.00.1203021018130.15125@router.home> <20120302174349.GB3481@suse.de> <1330723529.11248.237.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Mel Gorman <mgorman@suse.de>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Miao Xie <miaox@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 2 Mar 2012, Peter Zijlstra wrote:

> Also, for the write side it doesn't really matter, changing mems_allowed
> should be rare and is an 'expensive' operation anyway.
> 

It's very expensive even without memory barriers since the page allocator 
wraps itself in {get,put}_mems_allowed() until a page or NULL is returned 
and an update to current's set of allowed mems can stall indefinitely 
trying to change the nodemask during this time.  The thread changing 
cpuset.mems is holding cgroup_mutex the entire time which locks out 
changes, including adding additional nodes to current's set of allowed 
mems.  If direct reclaim takes a long time or an oom killed task fails to 
exit quickly (or the allocation is __GFP_NOFAIL and we just spin 
indefinitely holding get_mems_allowed()), then it's not uncommon to see a 
write to cpuset.mems taking minutes while holding the mutex, if it ever 
actually returns at all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
