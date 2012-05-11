Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id CE58C6B004D
	for <linux-mm@kvack.org>; Fri, 11 May 2012 01:03:45 -0400 (EDT)
Date: Fri, 11 May 2012 01:03:39 -0400 (EDT)
Message-Id: <20120511.010339.375923873885534514.davem@davemloft.net>
Subject: Re: [PATCH 13/17] netvm: Set PF_MEMALLOC as appropriate during SKB
 processing
From: David Miller <davem@davemloft.net>
In-Reply-To: <1336657510-24378-14-git-send-email-mgorman@suse.de>
References: <1336657510-24378-1-git-send-email-mgorman@suse.de>
	<1336657510-24378-14-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, neilb@suse.de, a.p.zijlstra@chello.nl, michaelc@cs.wisc.edu, emunson@mgebm.net

From: Mel Gorman <mgorman@suse.de>
Date: Thu, 10 May 2012 14:45:06 +0100

> In order to make sure pfmemalloc packets receive all memory
> needed to proceed, ensure processing of pfmemalloc SKBs happens
> under PF_MEMALLOC. This is limited to a subset of protocols that
> are expected to be used for writing to swap. Taps are not allowed to
> use PF_MEMALLOC as these are expected to communicate with userspace
> processes which could be paged out.
> 
> [a.p.zijlstra@chello.nl: Ideas taken from various patches]
> [jslaby@suse.cz: Lock imbalance fix]
> Signed-off-by: Mel Gorman <mgorman@suse.de>

This adds more code where we're modifying task->flags from software
interrupt context.  I'm not convinced that's safe.

Also, this starts to add new tests in the fast paths.

Most of the time they are not going to trigger at all.

Please use the static branch I asked you to add in a previous
patch to mitigate this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
