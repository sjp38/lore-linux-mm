Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 564076B0092
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 03:59:27 -0500 (EST)
Date: Thu, 18 Nov 2010 19:59:21 +1100
From: Nick Piggin <npiggin@kernel.dk>
Subject: Re: [PATCH] Pass priority to shrink_slab
Message-ID: <20101118085921.GA11314@amd>
References: <1290054891-6097-1-git-send-email-yinghan@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1290054891-6097-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 17, 2010 at 08:34:51PM -0800, Ying Han wrote:
> Pass the reclaim priority down to the shrink_slab() which passes to the
> shrink_icache_memory() for inode cache. It helps the situation when
> shrink_slab() is being too agressive, it removes the inode as well as all
> the pages associated with the inode. Especially when single inode has lots
> of pages points to it. The application encounters performance hit when
> that happens.
> 
> The problem was observed on some workload we run, where it has small number
> of large files. Page reclaim won't blow away the inode which is pinned by
> dentry which in turn is pinned by open file descriptor. But if the application
> is openning and closing the fds, it has the chance to trigger the issue.
> 
> I have a script which reproduce the issue. The test is creating 1500 empty
> files and one big file in a cgroup. Then it starts adding memory pressure
> in the cgroup. Both before/after the patch we see the slab drops (inode) in
> slabinfo but the big file clean pages being preserves only after the change.

I was going to do this as a flag when nearing OOM. Is there a reason
to have it priority based? That seems a little arbitrary to me...

FWIW, we can just add this to the new shrinker API, and convert over
the users who care about it, so it doesn't have to be done in a big
patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
