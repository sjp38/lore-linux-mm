Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9DCD88D003A
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 16:47:49 -0500 (EST)
Message-ID: <4D642F03.5040800@linux.intel.com>
Date: Tue, 22 Feb 2011 13:47:47 -0800
From: Andi Kleen <ak@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/8] Add __GFP_OTHER_NODE flag
References: <1298315270-10434-1-git-send-email-andi@firstfloor.org> <1298315270-10434-7-git-send-email-andi@firstfloor.org> <alpine.DEB.2.00.1102221333100.5929@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1102221333100.5929@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, lwoodman@redhat.com

On 2/22/2011 1:42 PM, David Rientjes wrote:
>
> This makes the accounting worse, NUMA_LOCAL is defined as "allocation from
> local node," meaning it's local to the allocating cpu, not local to the
> node being targeted.

Local to the process really (and I defined it originally ...)  That is 
what I'm implementing

I don't think "local to some random kernel daemon which changes mappings 
on behalf of others"
makes any sense as semantics.

> Further, preferred_zone has taken on a much more significant meaning other
> than just statistics: it impacts the behavior of memory compaction and how
> long congestion timeouts are, if a timeout is taken at all, depending on
> the I/O being done on behalf of the zone.
>
> A better way to address the issue is by making sure preferred_zone is
> actually correct by using the appropriate zonelist to be passed into the
> allocator in the first place

That is what is done already (well for THP together with my other patches)
The problem is just that local_hit/miss still uses numa_node_id() and 
not the preferred zone
to do the accounting.  In most cases that's fine and intended, just not 
for these
special daemons.


-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
