Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 822F06B0071
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 05:19:06 -0400 (EDT)
Date: Thu, 25 Mar 2010 09:18:45 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 02/11] mm,migration: Do not try to migrate unmapped
	anonymous pages
Message-ID: <20100325091845.GJ2024@csn.ul.ie>
References: <20100325095349.944E.A69D9226@jp.fujitsu.com> <20100325083235.GF2024@csn.ul.ie> <20100325175034.6C86.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100325175034.6C86.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 25, 2010 at 05:56:25PM +0900, KOSAKI Motohiro wrote:
> > On Thu, Mar 25, 2010 at 11:49:23AM +0900, KOSAKI Motohiro wrote:
> > > > On Fri, Mar 19, 2010 at 03:21:41PM +0900, KOSAKI Motohiro wrote:
> > > > > > > then, this logic depend on SLAB_DESTROY_BY_RCU, not refcount.
> > > > > > > So, I think we don't need your [1/11] patch.
> > > > > > > 
> > > > > > > Am I missing something?
> > > > > > > 
> > > > > > 
> > > > > > The refcount is still needed. The anon_vma might be valid, but the
> > > > > > refcount is what ensures that the anon_vma is not freed and reused.
> > > > > 
> > > > > please please why do we need both mechanism. now cristoph is very busy and I am
> > > > > de fact reviewer of page migration and mempolicy code. I really hope to understand
> > > > > your patch.
> > > > 
> > > > As in, why not drop the RCU protection of anon_vma altogeter? Mainly, because I
> > > > think it would be reaching too far for this patchset and it should be done as
> > > > a follow-up. Putting the ref-count everywhere will change the cache-behaviour
> > > > of anon_vma more than I'd like to slip into a patchset like this. Secondly,
> > > > Christoph mentions that SLAB_DESTROY_BY_RCU is used to keep anon_vma cache-hot.
> > > > For these reasons, removing RCU from these paths and adding the refcount
> > > > in others is a patch that should stand on its own.
> > > 
> > > Hmmm...
> > > I haven't understand your mention because I guess I was wrong.
> > > 
> > > probably my last question was unclear. I mean,
> > > 
> > > 1) If we still need SLAB_DESTROY_BY_RCU, why do we need to add refcount?
> > >     Which difference is exist between normal page migration and compaction?
> > 
> > The processes typically calling migration today own the page they are moving
> > and is not going to exit unexpectedly during migration.
> > 
> > > 2) If we added refcount, which race will solve?
> > > 
> > 
> > The process exiting and the last anon_vma being dropped while compaction
> > is running. This can be reliably triggered with compaction.
> > 
> > > IOW, Is this patch fix old issue or compaction specific issue?
> > 
> > Strictly speaking, it's an old issue but in practice it's impossible to
> > trigger because the process migrating always owns the page. Compaction
> > moves pages belonging to arbitrary processes.
> 
> Do you mean current memroy hotplug code is broken???

I hadn't considered the memory hotplug case but you're right, it's possible
it's at risk.

While compaction can trigger this problem reliably, it's not exactly easy
to trigger. I was triggering it under very heavy memory load with a large
number of very short lived processes (specifically, an excessive compile-based
load). It's possible that memory hotplug has not been tested under similar
situations.

> I think compaction need refcount, hotplug also need it. both they migrate another
> task's page.
> 
> but , I haven't seen hotplug failure. Am I  missing something? or the compaction
> have its specific race situation?
> 

It's worth double-checking.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
