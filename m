Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f53.google.com (mail-bk0-f53.google.com [209.85.214.53])
	by kanga.kvack.org (Postfix) with ESMTP id C611D6B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 18:04:14 -0500 (EST)
Received: by mail-bk0-f53.google.com with SMTP id r7so790543bkg.40
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 15:04:14 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id cm8si3794169bkc.163.2014.03.06.15.04.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 06 Mar 2014 15:04:13 -0800 (PST)
Date: Thu, 6 Mar 2014 18:04:04 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [merged]
 mm-page_alloc-reset-aging-cycle-with-gfp_thisnode-v2.patch removed from -mm
 tree
Message-ID: <20140306230404.GY6963@cmpxchg.org>
References: <5318dca5.AwhU/92X21JgbpdE%akpm@linux-foundation.org>
 <20140306214927.GB11171@cmpxchg.org>
 <20140306135635.6999d703429afb7fd3949304@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140306135635.6999d703429afb7fd3949304@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: stable@kernel.org, riel@redhat.com, mgorman@suse.de, jstancek@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Mar 06, 2014 at 01:56:35PM -0800, Andrew Morton wrote:
> On Thu, 6 Mar 2014 16:49:27 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > On Thu, Mar 06, 2014 at 12:37:57PM -0800, akpm@linux-foundation.org wrote:
> > > Subject: [merged] mm-page_alloc-reset-aging-cycle-with-gfp_thisnode-v2.patch removed from -mm tree
> > > To: hannes@cmpxchg.org,jstancek@redhat.com,mgorman@suse.de,riel@redhat.com,stable@kernel.org,mm-commits@vger.kernel.org
> > > From: akpm@linux-foundation.org
> > > Date: Thu, 06 Mar 2014 12:37:57 -0800
> > > 
> > > 
> > > The patch titled
> > >      Subject: mm: page_alloc: exempt GFP_THISNODE allocations from zone fairness
> > > has been removed from the -mm tree.  Its filename was
> > >      mm-page_alloc-reset-aging-cycle-with-gfp_thisnode-v2.patch
> > > 
> > > This patch was dropped because it was merged into mainline or a subsystem tree
> > 
> > Would it make sense to also merge
> > 
> > mm-fix-gfp_thisnode-callers-and-clarify.patch
> > 
> > at this point?  It's not as critical as the GFP_THISNODE exemption,
> > which is why I didn't tag it for stable, but it's a bugfix as well.
> 
> Changelog fail!
> 
> : GFP_THISNODE is for callers that implement their own clever fallback to
> : remote nodes, and so no direct reclaim is invoked.  There are many current
> : users that only want node exclusiveness but still want reclaim to make the
> : allocation happen.  Convert them over to __GFP_THISNODE and update the
> : documentation to clarify GFP_THISNODE semantics.
> 
> what bug does it fix and what are the user-visible effects??

Ok, maybe this is better?

---

GFP_THISNODE is for callers that implement their own clever fallback
to remote nodes.  It restricts the allocation to the specified node
and does not invoke reclaim, assuming that the caller will take care
of it when the fallback fails, e.g. through a subsequent allocation
request without GFP_THISNODE set.

However, many current GFP_THISNODE users only want the node exclusive
aspect of the flag, without actually implementing their own fallback
or triggering reclaim if necessary.  This results in things like page
migration failing prematurely even when there is easily reclaimable
memory available, unless kswapd happens to be running already or a
concurrent allocation attempt triggers the necessary reclaim.

Convert all callsites that don't implement their own fallback strategy
to __GFP_THISNODE.  This restricts the allocation a single node too,
but at the same time allows the allocator to enter the slowpath, wake
kswapd, and invoke direct reclaim if necessary, to make the allocation
happen when memory is full.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
