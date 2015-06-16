Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 920266B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 09:52:14 -0400 (EDT)
Received: by wigg3 with SMTP id g3so109559193wig.1
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 06:52:14 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ge8si24179474wib.104.2015.06.16.06.52.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 16 Jun 2015 06:52:13 -0700 (PDT)
Date: Tue, 16 Jun 2015 15:52:09 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [BUG] fs: inotify_handle_event() reading un-init memory
Message-ID: <20150616135209.GD7038@quack.suse.cz>
References: <20150616113300.10621.35439.stgit@devil>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150616113300.10621.35439.stgit@devil>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 16-06-15 13:33:18, Jesper Dangaard Brouer wrote:
> Caught by kmemcheck.
> 
> Don't know the fix... just pointed at the bug.
> 
> Introduced in commit 7053aee26a3 ("fsnotify: do not share
> events between notification groups").
> ---
>  fs/notify/inotify/inotify_fsnotify.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/notify/inotify/inotify_fsnotify.c b/fs/notify/inotify/inotify_fsnotify.c
> index 2cd900c2c737..370d66dc4ddb 100644
> --- a/fs/notify/inotify/inotify_fsnotify.c
> +++ b/fs/notify/inotify/inotify_fsnotify.c
> @@ -96,11 +96,12 @@ int inotify_handle_event(struct fsnotify_group *group,
>  	i_mark = container_of(inode_mark, struct inotify_inode_mark,
>  			      fsn_mark);
>  
> +	// new object alloc here
>  	event = kmalloc(alloc_len, GFP_KERNEL);
>  	if (unlikely(!event))
>  		return -ENOMEM;
>  
> -	fsn_event = &event->fse;
> +	fsn_event = &event->fse; // This looks wrong!?! read from un-init mem?

Where is here any read? This is just a pointer arithmetics where we add
offset of 'fse' entry to 'event' address.

								Honza

>  	fsnotify_init_event(fsn_event, inode, mask);
>  	event->wd = i_mark->wd;
>  	event->sync_cookie = cookie;
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
