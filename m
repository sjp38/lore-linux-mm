Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 83BC38D003B
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 16:18:33 -0500 (EST)
Date: Fri, 4 Feb 2011 22:18:25 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][PATCH 1/6] count transparent hugepage splits
Message-ID: <20110204211825.GJ30909@random.random>
References: <20110201003357.D6F0BE0D@kernel>
 <20110201003358.98826457@kernel>
 <alpine.DEB.2.00.1102031235100.453@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1102031235100.453@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>

On Thu, Feb 03, 2011 at 01:22:14PM -0800, David Rientjes wrote:
> i.e. no global locking, but we've accepted the occassional off-by-one 
> error (even though splitting of hugepages isn't by any means lightning 
> fast and the overhead of atomic ops would be negligible).

Agreed losing an increment is not a problem, but in very large systems
it will become a bottleneck. It's not super urgent, but I think it
needs to become a per-cpu counter sooner than later (not needed
immediately but I would appreciate an incremental patch soon to
address that). split_huge_page is already fully SMP scalable if the
rmap isn't shared (i.e. fully SMP scalable across different execve)
and I'd like it to stay that way because split_huge_page can run at
high frequency at times from different processes, so in very large
systems it may be measurable, with that cacheline bouncing around 1024
cpus. pages_collapsed is not a problem because it's only used by one
kernel thread so it can't be contended. Again not super urgent but
better to optimize it ;).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
