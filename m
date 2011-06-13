Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2CC526B004A
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 18:59:29 -0400 (EDT)
Date: Mon, 13 Jun 2011 15:58:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Fix assertion mapping->nrpages == 0 in
 end_writeback()
Message-Id: <20110613155853.d10d3ff4.akpm@linux-foundation.org>
In-Reply-To: <20110613224924.GM4907@quack.suse.cz>
References: <1306748258-4732-1-git-send-email-jack@suse.cz>
	<20110606151614.0037e236.akpm@linux-foundation.org>
	<1307425597.3649.61.camel@tucsk.pomaz.szeredi.hu>
	<20110607143301.7dbaf146.akpm@linux-foundation.org>
	<20110608163643.GE5361@quack.suse.cz>
	<20110613220144.GL4907@quack.suse.cz>
	<20110613151401.51b539a0.akpm@linux-foundation.org>
	<20110613224924.GM4907@quack.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Miklos Szeredi <mszeredi@suse.cz>, linux-mm@kvack.org, Al Viro <viro@ZenIV.linux.org.uk>, Jay <jinshan.xiong@whamcloud.com>, stable@kernel.org, Nick Piggin <npiggin@kernel.dk>

On Tue, 14 Jun 2011 00:49:24 +0200
Jan Kara <jack@suse.cz> wrote:

> > > people find that nicer. That place really looks like the only one which
> > > depends on nrpages being consistent and uptodate.
> > 
> > That seems a cleaner way of avoiding one manifestation of the bug.
>   OK.
> 
> > But what *is* the bug?  That we've made nrpages incoherent with the
> > state of the tree?  Or is it simply that the rule has always been "you
> > must hold tree_lock to access nrpages", and the rcuification exposed
> > that?
> > 
> > I want to actually fix this stuff up and get a good clear design which
> > we can describe and understand.  No band-aids, please.  Not in here.
>   OK, I belive the rule is "you must hold tree_lock to access nrpages" but
> there are plenty of places which don't hold tree_lock and still peek at
> nrpages to see if they have anything to do (and they were there even before
> radix tree was rcuified). These are inherently racy and usually they don't
> care - but possibly each such place should carry a comment explaining why
> this racy check does not matter...

OK, but it's weird and unexpected that a call to
truncate_inode_pages(everything) can return with nrpages non-zero. 
Worth documenting this somewhere?  And mention the
behaviour/requirement at the nrpages definition site?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
