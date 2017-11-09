Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 01B40440CD7
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 09:28:53 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id n66so4274108qki.10
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 06:28:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v78sor4745963qka.164.2017.11.09.06.28.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 Nov 2017 06:28:51 -0800 (PST)
Date: Thu, 9 Nov 2017 09:28:50 -0500
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH 2/4] writeback: allow for dirty metadata accounting
Message-ID: <20171109142848.uikyp7w25chg42u7@destiny>
References: <1510167660-26196-1-git-send-email-josef@toxicpanda.com>
 <1510167660-26196-2-git-send-email-josef@toxicpanda.com>
 <20171109103246.GB9263@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171109103246.GB9263@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Josef Bacik <josef@toxicpanda.com>, hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, Josef Bacik <jbacik@fb.com>

On Thu, Nov 09, 2017 at 11:32:46AM +0100, Jan Kara wrote:
> On Wed 08-11-17 14:00:58, Josef Bacik wrote:
> > From: Josef Bacik <jbacik@fb.com>
> > 
> > Provide a mechanism for file systems to indicate how much dirty metadata they
> > are holding.  This introduces a few things
> > 
> > 1) Zone stats for dirty metadata, which is the same as the NR_FILE_DIRTY.
> > 2) WB stat for dirty metadata.  This way we know if we need to try and call into
> > the file system to write out metadata.  This could potentially be used in the
> > future to make balancing of dirty pages smarter.
> > 
> > Signed-off-by: Josef Bacik <jbacik@fb.com>
> ...
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 13d711dd8776..0281abd62e87 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -3827,7 +3827,8 @@ static unsigned long node_pagecache_reclaimable(struct pglist_data *pgdat)
> >  
> >  	/* If we can't clean pages, remove dirty pages from consideration */
> >  	if (!(node_reclaim_mode & RECLAIM_WRITE))
> > -		delta += node_page_state(pgdat, NR_FILE_DIRTY);
> > +		delta += node_page_state(pgdat, NR_FILE_DIRTY) +
> > +			node_page_state(pgdat, NR_METADATA_DIRTY);
> >  
> >  	/* Watch for any possible underflows due to delta */
> >  	if (unlikely(delta > nr_pagecache_reclaimable))
> 
> Do you expect your metadata pages to be accounted in NR_FILE_PAGES?
> Otherwise this doesn't make sense. And even if they would, this function is
> about kswapd / direct page reclaim and I don't think you've added smarts
> there to writeout metadata. So if your metadata pages are going to show up
> in NR_FILE_PAGES, you need to subtract NR_METADATA_DIRTY from reclaimable
> pages always. It would be good to see btrfs counterpart to these patches so
> that we can answer questions like this easily...
> 

Ah good point, this accounting doesn't belong here, I'll fix it up.  I haven't
been sending the btrfs patch because it's fucking huge, since untangling the
btree inode usage requires a lot of reworking all at once so it's actually
buildable, so it didn't seem useful for the larger non-btrfs audience.  You can
see it in my git tree here

https://git.kernel.org/pub/scm/linux/kernel/git/josef/btrfs-next.git/commit/?h=new-kill-btree-inode&id=5dfd4a0012c1253260da07bee3fa3d4c13aac616

I'll fix this up.  Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
