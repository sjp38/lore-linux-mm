Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5D8896B004A
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 17:33:36 -0400 (EDT)
Date: Tue, 7 Jun 2011 14:33:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Fix assertion mapping->nrpages == 0 in
 end_writeback()
Message-Id: <20110607143301.7dbaf146.akpm@linux-foundation.org>
In-Reply-To: <1307425597.3649.61.camel@tucsk.pomaz.szeredi.hu>
References: <1306748258-4732-1-git-send-email-jack@suse.cz>
	<20110606151614.0037e236.akpm@linux-foundation.org>
	<1307425597.3649.61.camel@tucsk.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miklos Szeredi <mszeredi@suse.cz>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Al Viro <viro@ZenIV.linux.org.uk>, Jay <jinshan.xiong@whamcloud.com>, stable@kernel.org, Nick Piggin <npiggin@kernel.dk>

On Tue, 07 Jun 2011 07:46:37 +0200
Miklos Szeredi <mszeredi@suse.cz> wrote:

> > Either way, I don't think that the uglypatch expresses a full
> > understanding of te bug ;)
> 
> I don't see a better way, how would we make nrpages update atomically
> wrt the radix-tree while using only RCU?
> 
> The question is, does it matter that those two can get temporarily out
> of sync?
> 
> In case of inode eviction it does, not only because of that BUG_ON, but
> because page reclaim must be somehow synchronised with eviction.
> Otherwise it may access tree_lock on the mapping of an already freed
> inode.
> 
> In other cases?  AFAICS it doesn't matter.  Most ->nrpages accesses
> weren't under tree_lock before Nick's RCUification, so their use were
> just optimization.   

Gee, we've made a bit of a mess here.

Rather than bodging around particualr codesites where that mess exposes
itself, how about we step back and work out what our design is here,
then implement it and check that all sites comply with it?

What is the relationship between the radix-tree and nrpages?  What are
the locking rules?  Can anyone come up with a one-sentence proposal?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
