Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 9F82E90013D
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 05:35:24 -0400 (EDT)
Date: Tue, 23 Aug 2011 05:35:20 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 12/13] dcache: remove dentries from LRU before putting on
 dispose list
Message-ID: <20110823093520.GA4938@infradead.org>
References: <1314089786-20535-1-git-send-email-david@fromorbit.com>
 <1314089786-20535-13-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1314089786-20535-13-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, khlebnikov@openvz.org

> diff --git a/fs/dcache.c b/fs/dcache.c
> index b931415..79bf47c 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -269,10 +269,10 @@ static void dentry_lru_move_list(struct dentry *dentry, struct list_head *list)
>  	spin_lock(&dentry->d_sb->s_dentry_lru_lock);
>  	if (list_empty(&dentry->d_lru)) {
>  		list_add_tail(&dentry->d_lru, list);
> -		dentry->d_sb->s_nr_dentry_unused++;
> -		this_cpu_inc(nr_dentry_unused);
>  	} else {
>  		list_move_tail(&dentry->d_lru, list);
> +		dentry->d_sb->s_nr_dentry_unused--;
> +		this_cpu_dec(nr_dentry_unused);
>  	}
>  	spin_unlock(&dentry->d_sb->s_dentry_lru_lock);

I suspect at this point it might be more obvious to simply remove
dentry_lru_move_list.  Just call dentry_lru_del to remove it from the
lru, and then we can add it to the local dispose list without the need
of any locking, similar to how it is done for inodes already.

>  		if (dentry->d_count) {
> -			dentry_lru_del(dentry);
>  			spin_unlock(&dentry->d_lock);
>  			continue;
>  		}
> @@ -789,6 +794,8 @@ relock:
>  			spin_unlock(&dentry->d_lock);
>  		} else {
>  			list_move_tail(&dentry->d_lru, &tmp);
> +			this_cpu_dec(nr_dentry_unused);
> +			sb->s_nr_dentry_unused--;

It might be more obvious to use __dentry_lru_del + an opencoded list_add
here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
