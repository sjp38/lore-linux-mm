Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id DAD266B0279
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 18:48:47 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id l34so37057906wrc.12
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 15:48:47 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 18si2152031wmy.138.2017.06.29.15.48.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 15:48:46 -0700 (PDT)
Date: Thu, 29 Jun 2017 15:48:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 2/2] fs/dcache.c: fix spin lockup issue on nlru->lock
Message-Id: <20170629154828.5b4877348470c42352620f41@linux-foundation.org>
In-Reply-To: <1498707575-2472-1-git-send-email-stummala@codeaurora.org>
References: <20170628171854.t4sjyjv55j673qzv@esperanza>
	<1498707575-2472-1-git-send-email-stummala@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sahitya Tummala <stummala@codeaurora.org>
Cc: Alexander Polakov <apolyakov@beget.ru>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jan Kara <jack@suse.cz>, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Thu, 29 Jun 2017 09:09:35 +0530 Sahitya Tummala <stummala@codeaurora.org> wrote:

> __list_lru_walk_one() acquires nlru spin lock (nlru->lock) for
> longer duration if there are more number of items in the lru list.
> As per the current code, it can hold the spin lock for upto maximum
> UINT_MAX entries at a time. So if there are more number of items in
> the lru list, then "BUG: spinlock lockup suspected" is observed in
> the below path -
> 
> ...
>
> Fix this lockup by reducing the number of entries to be shrinked
> from the lru list to 1024 at once. Also, add cond_resched() before
> processing the lru list again.
> 
> ...
>
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -1133,11 +1133,12 @@ void shrink_dcache_sb(struct super_block *sb)
>  		LIST_HEAD(dispose);
>  
>  		freed = list_lru_walk(&sb->s_dentry_lru,
> -			dentry_lru_isolate_shrink, &dispose, UINT_MAX);
> +			dentry_lru_isolate_shrink, &dispose, 1024);
>  
>  		this_cpu_sub(nr_dentry_unused, freed);
>  		shrink_dentry_list(&dispose);
> -	} while (freed > 0);
> +		cond_resched();
> +	} while (list_lru_count(&sb->s_dentry_lru) > 0);
>  }
>  EXPORT_SYMBOL(shrink_dcache_sb);

I'll add a cc:stable to this one - a large dentry list is a relatively
common thing.

I'm assumng that [1/2] does not need to be backported, OK?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
