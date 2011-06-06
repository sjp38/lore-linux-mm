Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C68936B00F2
	for <linux-mm@kvack.org>; Mon,  6 Jun 2011 01:37:20 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id p565bGQw005191
	for <linux-mm@kvack.org>; Sun, 5 Jun 2011 22:37:18 -0700
Received: from pzk26 (pzk26.prod.google.com [10.243.19.154])
	by kpbe11.cbf.corp.google.com with ESMTP id p565bCBA029811
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 5 Jun 2011 22:37:15 -0700
Received: by pzk26 with SMTP id 26so1700466pzk.10
        for <linux-mm@kvack.org>; Sun, 05 Jun 2011 22:37:12 -0700 (PDT)
Date: Sun, 5 Jun 2011 22:37:08 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 3/14] tmpfs: take control of its truncate_range
In-Reply-To: <20110603051609.GC16721@infradead.org>
Message-ID: <alpine.LSU.2.00.1106052206260.17330@sister.anvils>
References: <alpine.LSU.2.00.1105301726180.5482@sister.anvils> <alpine.LSU.2.00.1105301737040.5482@sister.anvils> <20110601003942.GB4433@infradead.org> <alpine.LSU.2.00.1106010940590.23468@sister.anvils> <20110603051609.GC16721@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 3 Jun 2011, Christoph Hellwig wrote:
> On Wed, Jun 01, 2011 at 09:58:18AM -0700, Hugh Dickins wrote:
> 
> > Fine, I'll add tmpfs PUNCH_HOLE later on.  And wire up madvise MADV_REMOVE
> > to fallocate PUNCH_HOLE, yes?
> 
> Yeah.  One thing I've noticed is that the hole punching doesn't seem
> to do the unmap_mapping_range.  It might be worth to audit that from the
> VM point of view.

I'd noticed that recently too.

At first I was alarmed, but it's actually an inefficiency rather than
a danger: because at some stage a safety unmap_mapping_range() call has
been added into truncate_inode_page().  I don't know what case that was
originally for, but it will cover fallocate() for now.

This is a call to unmap_mapping_range() with 0 for the even_cows arg
i.e. it will not remove COWed copies of the file page from private
mappings.  I think that's good semantics for hole punching (and it's
difficult to enforce the alternative, because we've neither i_size nor
page lock to prevent races); but it does differ from the (odd) POSIX
truncation behaviour, to unmap even the private COWs.

What do you think?  If you think we should unmap COWs, then it ought
to be corrrected sooner.  Otherwise I was inclined not to rush (I'm
also wondering about cleancache in truncation: that should be another
mail thread, but might call for passing down a flag useful here too).

You might notice that the alternate hole-punching's vmtruncate_range()
is passing even_cows 1: doesn't matter in practice, since that one has
been restricted to operating on shared writable mappings.  Oh, I
suppose there could also be a parallel private writable mapping,
whose COWs would get unmapped.  Hmm, worth worrying about if we
choose the opposite with fallocate hole punching?

> 
> > Would you like me to remove the ->truncate_range method from
> > inode_operations completely?
> 
> Doing that would be nice.  Do we always have the required file struct
> for ->fallocate in the callers?

Good point, but yes, no problem.

I'm carrying on using ->truncate_range for the moment, partly because
I don't want to get diverted by testing the ->fallocate alternative yet,
but also because removing ->truncate_range now would force an immediate
change on drm/i915: better use shmem_truncate_range() for the transition.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
