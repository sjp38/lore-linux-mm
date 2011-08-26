Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 61A8F6B016A
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 13:09:39 -0400 (EDT)
Received: by pzk6 with SMTP id 6so6860925pzk.36
        for <linux-mm@kvack.org>; Fri, 26 Aug 2011 10:09:37 -0700 (PDT)
Subject: Re: [PATCH 05/13] mm: convert shrinkers to use new API
From: Wanlong Gao <wanlong.gao@gmail.com>
Reply-To: wanlong.gao@gmail.com
In-Reply-To: <1314089786-20535-6-git-send-email-david@fromorbit.com>
References: <1314089786-20535-1-git-send-email-david@fromorbit.com>
	 <1314089786-20535-6-git-send-email-david@fromorbit.com>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 27 Aug 2011 01:09:30 +0800
Message-ID: <1314378570.1987.8.camel@Allen>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, khlebnikov@openvz.org

On Tue, 2011-08-23 at 18:56 +1000, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> Modify shrink_slab() to use the new .count_objects/.scan_objects API
> and implement the callouts for all the existing shrinkers.

> +static long
> +cifs_idmap_shrinker_scan(struct shrinker *shrink, struct shrink_control *sc)
>  {
> -	int nr_to_scan = sc->nr_to_scan;
> -	int nr_del = 0;
> -	int nr_rem = 0;
>  	struct rb_root *root;
> +	long freed;
>  
>  	root = &uidtree;
>  	spin_lock(&siduidlock);
> -	shrink_idmap_tree(root, nr_to_scan, &nr_rem, &nr_del);
> +	freed = shrink_idmap_tree(root, sc->nr_to_scan);
>  	spin_unlock(&siduidlock);
>  
>  	root = &gidtree;
>  	spin_lock(&sidgidlock);
> -	shrink_idmap_tree(root, nr_to_scan, &nr_rem, &nr_del);
> +	freed += shrink_idmap_tree(root, sc->nr_to_scan);
>  	spin_unlock(&sidgidlock);
>  
> -	return nr_rem;
> +	return freed;
> +}
> +
> +/*
> + * This still abuses the nr_to_scan == 0 trick to get the common code just to
> + * count objects. There neds to be an external count of the objects in the

			  ^^^^^?
Hi Dave:
Great work. a bit comments.
Thanks
-Wanlong Gao


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
