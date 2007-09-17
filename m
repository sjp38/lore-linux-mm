Subject: Re: [PATCH/RFC 10/14] Reclaim Scalability:  track anon_vma
	"related vmas"
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <46EDEBDA.4030906@redhat.com>
References: <20070914205359.6536.98017.sendpatchset@localhost>
	 <20070914205506.6536.5170.sendpatchset@localhost>
	 <46EDEBDA.4030906@redhat.com>
Content-Type: text/plain
Date: Mon, 17 Sep 2007 11:52:24 -0400
Message-Id: <1190044345.5460.83.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Sun, 2007-09-16 at 22:52 -0400, Rik van Riel wrote:
> Lee Schermerhorn wrote:
> > PATCH/RFC 10/14 Reclaim Scalability:  track anon_vma "related vmas"
> > 
> > Against:  2.6.23-rc4-mm1
> > 
> > When a single parent forks a large number [thousands, 10s of thousands]
> > of children, the anon_vma list of related vmas becomes very long.  In
> > reclaim, this list must be traversed twice--once in page_referenced_anon()
> > and once in try_to_unmap_anon()--under a spin lock to reclaim the page.
> > Multiple cpus can end up spinning behind the same anon_vma spinlock and
> > traversing the lists.  This patch, part of the "noreclaim" series, treats
> > anon pages with list lengths longer than a tunable threshold as non-
> > reclaimable.
> 
> I do not agree with this approach and think it is somewhat
> dangerous.
> 
> If the threshold is set too high, this code has no effect.
> 
> If the threshold is too low, or an unexpectedly high number
> of processes get forked (hey, now we *need* to swap something
> out), the system goes out of memory.
> 
> I would rather we reduce the amount of work we need to do in
> selecting what to page out in a different way, eg. by doing
> SEQ replacement for anonymous pages.
> 
> I will cook up a patch implementing that other approach in a
> way that it will fit into your patch series, since the rest
> of the series (so far) looks good to me.
> 
> *takes out the chainsaw to cut up his patch*
> 

I do understand your revulsion to this patch.  In our testing [AIM7], it
behaves exactly as you say--instead of spinning trying to unmap the anon
pages whose anon_vma lists are "excessive"--the system starts killing
off tasks.  It would be nice to have a better way to handle these.

While you're thinking about it, a couple of things to consider:

1) I think we don't want vmscan to spend a lot of time trying to reclaim
these pages when/if there are other, more easily reclaimable pages on
the lists.  That is sort of my rationale for stuffing them on the
noreclaim list.  I think any approach should stick these pages aside
somewhere--maybe just back on the end of the list, but that's behavior
I'm trying to elimate/reduce--and only attempt to reclaim them as a last
resort.

2) If the system gets into enough trouble that these are the only
reclaimable pages, I think we're pretty close to totally hosed anyway.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
