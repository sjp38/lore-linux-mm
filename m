Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 49D0A6B025E
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 03:49:51 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id b82so6603301wmd.5
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 00:49:51 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e193si8949431wmf.133.2017.12.18.00.49.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Dec 2017 00:49:50 -0800 (PST)
Date: Mon, 18 Dec 2017 09:49:48 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: vmscan: make unregister_shrinker() safer
Message-ID: <20171218084948.GK16951@dhcp22.suse.cz>
References: <20171216192937.13549-1-akaraliou.dev@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171216192937.13549-1-akaraliou.dev@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aliaksei Karaliou <akaraliou.dev@gmail.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, minchan@kernel.org, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

On Sat 16-12-17 22:29:37, Aliaksei Karaliou wrote:
> unregister_shrinker() does not have any sanitizing inside so
> calling it twice will oops because of double free attempt or so.
> This patch makes unregister_shrinker() safer and allows calling
> it on resource freeing path without explicit knowledge of whether
> shrinker was successfully registered or not.

Tetsuo has made it half way to this already [1]. So maybe we should
fold shrinker->nr_deferred = NULL to his patch and finally merge it.

[1] http://lkml.kernel.org/r/1511523385-6433-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
> 
> Signed-off-by: Aliaksei Karaliou <akaraliou.dev@gmail.com>
> ---
>  mm/vmscan.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 65c4fa26abfa..7cb56db5e9ca 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -281,10 +281,14 @@ EXPORT_SYMBOL(register_shrinker);
>   */
>  void unregister_shrinker(struct shrinker *shrinker)
>  {
> +	if (!shrinker->nr_deferred)
> +		return;
> +
>  	down_write(&shrinker_rwsem);
>  	list_del(&shrinker->list);
>  	up_write(&shrinker_rwsem);
>  	kfree(shrinker->nr_deferred);
> +	shrinker->nr_deferred = NULL;
>  }
>  EXPORT_SYMBOL(unregister_shrinker);
>  
> -- 
> 2.11.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
