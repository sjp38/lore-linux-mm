Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 22405900117
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 18:01:49 -0400 (EDT)
Date: Tue, 14 Jun 2011 00:01:44 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: Fix assertion mapping->nrpages == 0 in
 end_writeback()
Message-ID: <20110613220144.GL4907@quack.suse.cz>
References: <1306748258-4732-1-git-send-email-jack@suse.cz>
 <20110606151614.0037e236.akpm@linux-foundation.org>
 <1307425597.3649.61.camel@tucsk.pomaz.szeredi.hu>
 <20110607143301.7dbaf146.akpm@linux-foundation.org>
 <20110608163643.GE5361@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110608163643.GE5361@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Miklos Szeredi <mszeredi@suse.cz>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Al Viro <viro@ZenIV.linux.org.uk>, Jay <jinshan.xiong@whamcloud.com>, stable@kernel.org, Nick Piggin <npiggin@kernel.dk>

On Wed 08-06-11 18:36:43, Jan Kara wrote:
> On Tue 07-06-11 14:33:01, Andrew Morton wrote:
> > On Tue, 07 Jun 2011 07:46:37 +0200
> > Miklos Szeredi <mszeredi@suse.cz> wrote:
> > 
> > > > Either way, I don't think that the uglypatch expresses a full
> > > > understanding of te bug ;)
> > > 
> > > I don't see a better way, how would we make nrpages update atomically
> > > wrt the radix-tree while using only RCU?
> > > 
> > > The question is, does it matter that those two can get temporarily out
> > > of sync?
> > > 
> > > In case of inode eviction it does, not only because of that BUG_ON, but
> > > because page reclaim must be somehow synchronised with eviction.
> > > Otherwise it may access tree_lock on the mapping of an already freed
> > > inode.
> > > 
> > > In other cases?  AFAICS it doesn't matter.  Most ->nrpages accesses
> > > weren't under tree_lock before Nick's RCUification, so their use were
> > > just optimization.   
> > 
> > Gee, we've made a bit of a mess here.
> > 
> > Rather than bodging around particualr codesites where that mess exposes
> > itself, how about we step back and work out what our design is here,
> > then implement it and check that all sites comply with it?
> > 
> > What is the relationship between the radix-tree and nrpages?  What are
> > the locking rules?  Can anyone come up with a one-sentence proposal?
> AFAIU, nrpages and radix-tree are consistent under tree_lock.
> 
> nrpages is only used (well, apart from shmfs and other filesystems which
> use the value as a guess how much should they expect to write or similar
> heuristics) to test mapping->nrpages == 0 and the test is performed without
> any synchronization which looks natural because we later do only
> rcu-protected lookups anyway. So it seems it's expected the test is
> unreliable and we just use it to make things faster. The same race as with
> nrpages test can happen during the radix tree lookup anyway...
> 
> I went through the tests and the only place which seems to really care
> about the races with __add_to_page_cache() or __delete_from_page_cache()
> is when the inode should be removed from memory. There we have to be
> careful. Races with __add_to_page_cache() cannot happen because there is
> noone who could trigger addition of new page to the inode being evicted.
> Races with __delete_from_page_cache() are possible though...
  Andrew, any opinion on this? I'd like to get the bug fixed... I'll
happily move the nrpages check in end_writeback() under the spinlock if
people find that nicer. That place really looks like the only one which
depends on nrpages being consistent and uptodate.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
