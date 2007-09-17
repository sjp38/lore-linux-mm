Message-ID: <46EDEBDA.4030906@redhat.com>
Date: Sun, 16 Sep 2007 22:52:10 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH/RFC 10/14] Reclaim Scalability:  track anon_vma "related
 vmas"
References: <20070914205359.6536.98017.sendpatchset@localhost> <20070914205506.6536.5170.sendpatchset@localhost>
In-Reply-To: <20070914205506.6536.5170.sendpatchset@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

Lee Schermerhorn wrote:
> PATCH/RFC 10/14 Reclaim Scalability:  track anon_vma "related vmas"
> 
> Against:  2.6.23-rc4-mm1
> 
> When a single parent forks a large number [thousands, 10s of thousands]
> of children, the anon_vma list of related vmas becomes very long.  In
> reclaim, this list must be traversed twice--once in page_referenced_anon()
> and once in try_to_unmap_anon()--under a spin lock to reclaim the page.
> Multiple cpus can end up spinning behind the same anon_vma spinlock and
> traversing the lists.  This patch, part of the "noreclaim" series, treats
> anon pages with list lengths longer than a tunable threshold as non-
> reclaimable.

I do not agree with this approach and think it is somewhat
dangerous.

If the threshold is set too high, this code has no effect.

If the threshold is too low, or an unexpectedly high number
of processes get forked (hey, now we *need* to swap something
out), the system goes out of memory.

I would rather we reduce the amount of work we need to do in
selecting what to page out in a different way, eg. by doing
SEQ replacement for anonymous pages.

I will cook up a patch implementing that other approach in a
way that it will fit into your patch series, since the rest
of the series (so far) looks good to me.

*takes out the chainsaw to cut up his patch*

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
