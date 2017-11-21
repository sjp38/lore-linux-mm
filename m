Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 352916B0033
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 09:56:05 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id x63so1176520wmf.2
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 06:56:05 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x27si2816951edb.73.2017.11.21.06.56.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 21 Nov 2017 06:56:04 -0800 (PST)
Date: Tue, 21 Nov 2017 15:56:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,vmscan: Make unregister_shrinker() no-op if
 register_shrinker() failed.
Message-ID: <20171121145602.vac2u3fw5cax22nm@dhcp22.suse.cz>
References: <1511265853-15654-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1511265853-15654-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

On Tue 21-11-17 21:04:13, Tetsuo Handa wrote:
> There are users calling unregister_shrinker() when register_shrinker()
> failed. Add sanity check to unregister_shrinker().
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  mm/vmscan.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c02c850..9e100cc 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -297,6 +297,8 @@ int register_shrinker(struct shrinker *shrinker)
>   */
>  void unregister_shrinker(struct shrinker *shrinker)
>  {
> +	if (!shrinker->nr_deferred)
> +		return;

make it WARN_ON(), we really want to know about those, because something
is clearly wrong with them.

>  	down_write(&shrinker_rwsem);
>  	list_del(&shrinker->list);
>  	up_write(&shrinker_rwsem);
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
