Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2F25C6B0003
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 03:30:55 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id l126so58186456wml.1
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 00:30:55 -0800 (PST)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id kd10si47613981wjc.145.2015.12.21.00.30.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Dec 2015 00:30:53 -0800 (PST)
Received: by mail-wm0-f43.google.com with SMTP id p187so57756478wmp.0
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 00:30:53 -0800 (PST)
Date: Mon, 21 Dec 2015 09:30:52 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: initiallize all new zap_details fields before
 use
Message-ID: <20151221083051.GA11089@dhcp22.suse.cz>
References: <1450487091-7822-1-git-send-email-sasha.levin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1450487091-7822-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 18-12-15 20:04:51, Sasha Levin wrote:
> Commit "mm, oom: introduce oom reaper" forgot to initialize the two new fields
> of struct zap_details in unmap_mapping_range(). This caused using stack garbage
> on the call to unmap_mapping_range_tree().
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Thanks for catching that.
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memory.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 206c8cd..0e32993 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2431,6 +2431,7 @@ void unmap_mapping_range(struct address_space *mapping,
>  	details.last_index = hba + hlen - 1;
>  	if (details.last_index < details.first_index)
>  		details.last_index = ULONG_MAX;
> +	details.check_swap_entries = details.ignore_dirty = false;
>  
>  
>  	/* DAX uses i_mmap_lock to serialise file truncate vs page fault */
> -- 
> 1.7.10.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
