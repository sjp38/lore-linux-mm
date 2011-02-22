Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7A7948D003F
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 16:42:14 -0500 (EST)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id p1MLg8Oe015681
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 13:42:09 -0800
Received: from pzk12 (pzk12.prod.google.com [10.243.19.140])
	by kpbe13.cbf.corp.google.com with ESMTP id p1MLg3c1006449
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 13:42:07 -0800
Received: by pzk12 with SMTP id 12so432530pzk.29
        for <linux-mm@kvack.org>; Tue, 22 Feb 2011 13:42:03 -0800 (PST)
Date: Tue, 22 Feb 2011 13:42:00 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 6/8] Add __GFP_OTHER_NODE flag
In-Reply-To: <1298315270-10434-7-git-send-email-andi@firstfloor.org>
Message-ID: <alpine.DEB.2.00.1102221333100.5929@chino.kir.corp.google.com>
References: <1298315270-10434-1-git-send-email-andi@firstfloor.org> <1298315270-10434-7-git-send-email-andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, lwoodman@redhat.com, Andi Kleen <ak@linux.intel.com>

On Mon, 21 Feb 2011, Andi Kleen wrote:

> From: Andi Kleen <ak@linux.intel.com>
> 
> Add a new __GFP_OTHER_NODE flag to tell the low level numa statistics
> in zone_statistics() that an allocation is on behalf of another thread.
> This way the local and remote counters can be still correct, even
> when background daemons like khugepaged are changing memory
> mappings.
> 
> This only affects the accounting, but I think it's worth doing that
> right to avoid confusing users.
> 

This makes the accounting worse, NUMA_LOCAL is defined as "allocation from 
local node," meaning it's local to the allocating cpu, not local to the 
node being targeted.

Further, preferred_zone has taken on a much more significant meaning other 
than just statistics: it impacts the behavior of memory compaction and how 
long congestion timeouts are, if a timeout is taken at all, depending on 
the I/O being done on behalf of the zone.

A better way to address the issue is by making sure preferred_zone is 
actually correct by using the appropriate zonelist to be passed into the 
allocator in the first place.

> I first tried to just pass down the right node, but this required
> a lot of changes to pass down this parameter and at least one
> addition of a 10th argument to a 9 argument function. Using
> the flag is a lot less intrusive.
> 

And adding a branch to every successful page allocation for statistics 
isn't intrusive?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
