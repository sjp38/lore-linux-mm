Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 35D0C6B0071
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 04:13:26 -0400 (EDT)
Received: by wgbhy7 with SMTP id hy7so30048563wgb.2
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 01:13:25 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t5si28600783wiy.114.2015.06.17.01.13.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Jun 2015 01:13:23 -0700 (PDT)
Date: Wed, 17 Jun 2015 10:13:19 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [BUG] fs: inotify_handle_event() reading un-init memory
Message-ID: <20150617081319.GA1614@quack.suse.cz>
References: <20150616113300.10621.35439.stgit@devil>
 <20150616135209.GD7038@quack.suse.cz>
 <20150616222234.3ebc6402@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150616222234.3ebc6402@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 16-06-15 22:22:34, Jesper Dangaard Brouer wrote:
> 
> On Tue, 16 Jun 2015 15:52:09 +0200 Jan Kara <jack@suse.cz> wrote:
> 
> > On Tue 16-06-15 13:33:18, Jesper Dangaard Brouer wrote:
> > > Caught by kmemcheck.
> > > 
> > > Don't know the fix... just pointed at the bug.
> > > 
> > > Introduced in commit 7053aee26a3 ("fsnotify: do not share
> > > events between notification groups").
> > > ---
> > >  fs/notify/inotify/inotify_fsnotify.c |    3 ++-
> > >  1 file changed, 2 insertions(+), 1 deletion(-)
> > > 
> > > diff --git a/fs/notify/inotify/inotify_fsnotify.c b/fs/notify/inotify/inotify_fsnotify.c
> > > index 2cd900c2c737..370d66dc4ddb 100644
> > > --- a/fs/notify/inotify/inotify_fsnotify.c
> > > +++ b/fs/notify/inotify/inotify_fsnotify.c
> > > @@ -96,11 +96,12 @@ int inotify_handle_event(struct fsnotify_group *group,
> > >  	i_mark = container_of(inode_mark, struct inotify_inode_mark,
> > >  			      fsn_mark);
> > >  
> > > +	// new object alloc here
> > >  	event = kmalloc(alloc_len, GFP_KERNEL);
> > >  	if (unlikely(!event))
> > >  		return -ENOMEM;
> > >  
> > > -	fsn_event = &event->fse;
> > > +	fsn_event = &event->fse; // This looks wrong!?! read from un-init mem?
> > 
> > Where is here any read? This is just a pointer arithmetics where we add
> > offset of 'fse' entry to 'event' address.
> 
> I was kmemcheck that complained, perhaps it is a false-positive?
  May be. What was the kmemcheck warning you saw? And can you also attach
disassembly of inotify_handle_event() from your kernel? Thanks!

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
