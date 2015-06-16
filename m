Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id B2FF26B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 16:22:40 -0400 (EDT)
Received: by qgf75 with SMTP id 75so8990971qgf.1
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 13:22:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g125si2087873qhc.41.2015.06.16.13.22.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jun 2015 13:22:40 -0700 (PDT)
Date: Tue, 16 Jun 2015 22:22:34 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [BUG] fs: inotify_handle_event() reading un-init memory
Message-ID: <20150616222234.3ebc6402@redhat.com>
In-Reply-To: <20150616135209.GD7038@quack.suse.cz>
References: <20150616113300.10621.35439.stgit@devil>
	<20150616135209.GD7038@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, brouer@redhat.com


On Tue, 16 Jun 2015 15:52:09 +0200 Jan Kara <jack@suse.cz> wrote:

> On Tue 16-06-15 13:33:18, Jesper Dangaard Brouer wrote:
> > Caught by kmemcheck.
> > 
> > Don't know the fix... just pointed at the bug.
> > 
> > Introduced in commit 7053aee26a3 ("fsnotify: do not share
> > events between notification groups").
> > ---
> >  fs/notify/inotify/inotify_fsnotify.c |    3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/fs/notify/inotify/inotify_fsnotify.c b/fs/notify/inotify/inotify_fsnotify.c
> > index 2cd900c2c737..370d66dc4ddb 100644
> > --- a/fs/notify/inotify/inotify_fsnotify.c
> > +++ b/fs/notify/inotify/inotify_fsnotify.c
> > @@ -96,11 +96,12 @@ int inotify_handle_event(struct fsnotify_group *group,
> >  	i_mark = container_of(inode_mark, struct inotify_inode_mark,
> >  			      fsn_mark);
> >  
> > +	// new object alloc here
> >  	event = kmalloc(alloc_len, GFP_KERNEL);
> >  	if (unlikely(!event))
> >  		return -ENOMEM;
> >  
> > -	fsn_event = &event->fse;
> > +	fsn_event = &event->fse; // This looks wrong!?! read from un-init mem?
> 
> Where is here any read? This is just a pointer arithmetics where we add
> offset of 'fse' entry to 'event' address.

I was kmemcheck that complained, perhaps it is a false-positive?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
