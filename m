Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id B9D016B0032
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 15:41:09 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id b16so39018342igk.1
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 12:41:09 -0800 (PST)
Received: from mail-ie0-x229.google.com (mail-ie0-x229.google.com. [2607:f8b0:4001:c03::229])
        by mx.google.com with ESMTPS id rs7si7297098igb.46.2015.02.25.12.41.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Feb 2015 12:41:09 -0800 (PST)
Received: by iecar1 with SMTP id ar1so8454249iec.0
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 12:41:09 -0800 (PST)
Date: Wed, 25 Feb 2015 12:41:07 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -v2] mm, oom: do not fail __GFP_NOFAIL allocation if oom
 killer is disbaled
In-Reply-To: <20150225140826.GD26680@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1502251240150.18097@chino.kir.corp.google.com>
References: <1424801964-1602-1-git-send-email-mhocko@suse.cz> <20150224191127.GA14718@phnom.home.cmpxchg.org> <alpine.DEB.2.10.1502241220500.3855@chino.kir.corp.google.com> <20150225140826.GD26680@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, 25 Feb 2015, Michal Hocko wrote:

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2d224bbdf8e8..c2ff40a30003 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2363,7 +2363,8 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  			goto out;
>  	}
>  	/* Exhausted what can be done so it's blamo time */
> -	if (out_of_memory(ac->zonelist, gfp_mask, order, ac->nodemask, false))
> +	if (out_of_memory(ac->zonelist, gfp_mask, order, ac->nodemask, false)
> +			|| WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
>  		*did_some_progress = 1;
>  out:
>  	oom_zonelist_unlock(ac->zonelist, gfp_mask);

Eek, not sure we actually need to play any games with did_some_progress, 
it might be clearer just to do this

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2760,7 +2760,7 @@ retry:
 							&did_some_progress);
 			if (page)
 				goto got_pg;
-			if (!did_some_progress)
+			if (!did_some_progress && !(gfp_mask & __GFP_NOFAIL))
 				goto nopage;
 		}
 		/* Wait for some write requests to complete then retry */

Either way you decide, feel free to add my

Acked-by: David Rientjes <rientjes@gooogle.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
