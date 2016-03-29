Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id A3AF16B0005
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 18:13:57 -0400 (EDT)
Received: by mail-pf0-f170.google.com with SMTP id e128so3992313pfe.3
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 15:13:57 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id qx12si1184893pab.169.2016.03.29.15.13.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Mar 2016 15:13:56 -0700 (PDT)
Received: by mail-pa0-x232.google.com with SMTP id td3so23899293pab.2
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 15:13:56 -0700 (PDT)
Date: Tue, 29 Mar 2016 15:13:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH] mm, oom: move GFP_NOFS check to out_of_memory
In-Reply-To: <1459258055-1173-1-git-send-email-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.10.1603291510560.11705@chino.kir.corp.google.com>
References: <1459258055-1173-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, 29 Mar 2016, Michal Hocko wrote:

> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 86349586eacb..1c2b7a82f0c4 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -876,6 +876,10 @@ bool out_of_memory(struct oom_control *oc)
>  		return true;
>  	}
>  
> +	/* The OOM killer does not compensate for IO-less reclaim. */
> +	if (!(oc->gfp_mask & __GFP_FS))
> +		return true;
> +
>  	/*
>  	 * Check if there were limitations on the allocation (only relevant for
>  	 * NUMA) that may require different handling.

I don't object to this necessarily, but I think we need input from those 
that have taken the time to implement their own oom notifier to see if 
they agree.  In the past, they would only be called if reclaim has 
completely failed; now, they can be called in low memory situations when 
reclaim has had very little chance to be successful.  Getting an ack from 
them would be helpful.

I also think we have discussed this before, but I think the oom notifier 
handling should be in done in the page allocator proper, i.e. in 
__alloc_pages_may_oom().  We can leave out_of_memory() for a clear defined 
purpose: to kill a process when all reclaim has failed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
