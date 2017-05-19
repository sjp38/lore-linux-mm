Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 433902806DC
	for <linux-mm@kvack.org>; Fri, 19 May 2017 10:49:00 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id p134so15254895wmg.3
        for <linux-mm@kvack.org>; Fri, 19 May 2017 07:49:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 21si9290197eds.84.2017.05.19.07.48.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 May 2017 07:48:59 -0700 (PDT)
Date: Fri, 19 May 2017 16:48:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, vmstat: Fix NULL pointer dereference during
 pagetypeinfo print
Message-ID: <20170519144856.GK29839@dhcp22.suse.cz>
References: <20170519143936.21209-1-firogm@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170519143936.21209-1-firogm@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Firo Yang <firogm@gmail.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, hannes@cmpxchg.org, bigeasy@linutronix.de, iamjoonsoo.kim@lge.com, rientjes@google.com, hughd@google.com, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 19-05-17 22:39:36, Firo Yang wrote:
> During showing the pagetypeinfo, we forgot to save the found page
> and dereference a invalid page address from the stack.
> 
> To fix it, save and reference the page address returned by
> pfn_to_online_page().

Thanks for taking catching that and your fix. I have already posted a fix
http://lkml.kernel.org/r/20170519072225.GA13041@dhcp22.suse.cz earlier
today. Sorry about troubles

> Signed-off-by: Firo Yang <firogm@gmail.com>
> ---
>  mm/vmstat.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index c432e58..6dae6b2 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1223,7 +1223,8 @@ static void pagetypeinfo_showblockcount_print(struct seq_file *m,
>  	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
>  		struct page *page;
>  
> -		if (!pfn_to_online_page(pfn))
> +		page = pfn_to_online_page(pfn);
> +		if (!page)
>  			continue;
>  
>  		/* Watch for unexpected holes punched in the memmap */
> -- 
> 2.9.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
