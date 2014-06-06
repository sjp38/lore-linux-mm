Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id EEC5A6B0035
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 09:12:59 -0400 (EDT)
Received: by mail-wg0-f42.google.com with SMTP id y10so2740843wgg.13
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 06:12:59 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id y16si17373563wju.93.2014.06.06.06.12.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 06 Jun 2014 06:12:58 -0700 (PDT)
Date: Fri, 6 Jun 2014 09:12:51 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm/vmscan.c: avoid scanning the whole targets[*] when
 scan_balance equals SCAN_FILE/SCAN_ANON
Message-ID: <20140606131251.GB2878@cmpxchg.org>
References: <1402044866-15313-1-git-send-email-slaoub@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1402044866-15313-1-git-send-email-slaoub@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Yucong <slaoub@gmail.com>
Cc: mgorman@suse.de, mhocko@suse.cz, akpm@linux-foundation.org, linux-mm@kvack.org

Hi Chen,

On Fri, Jun 06, 2014 at 04:54:26PM +0800, Chen Yucong wrote:
> If (scan_balance == SCAN_FILE) is true for shrink_lruvec, then  the value of
> targets[LRU_INACTIVE_ANON] and targets[LRU_ACTIVE_ANON] will be zero. As a result,
> the value of 'percentage' will also be  zero, and the *whole* targets[LRU_INACTIVE_FILE]
> and targets[LRU_ACTIVE_FILE] will be scanned.
> 
> For (scan_balance == SCAN_ANON), there is the same conditions stated above.
> 
> But via https://lkml.org/lkml/2013/4/10/334, we can find that the kernel does not prefer
> reclaiming too many pages from the other LRU. So before recalculating the other LRU scan
> count based on its original scan targets and the percentage scanning already complete, we
> should need to check whether 'scan_balance' equals SCAN_FILE/SCAN_ANON.
> 
> Signed-off-by: Chen Yucong <slaoub@gmail.com>
> ---
>  mm/vmscan.c |    3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index d51f7e0..ca3f5f1 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2120,6 +2120,9 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
>  			percentage = nr_file * 100 / scan_target;
>  		}
>  
> +		if (targets[lru] == 0 && targets[lru + LRU_ACTIVE] == 0)
> +			break;

We have meanwhile included a change that bails out if nr_anon or
nr_file are zero, right before that percentage calculation, that
should cover the scenario you're describing.  It's called:

mm: vmscan: use proportional scanning during direct reclaim and full scan at DEF_PRIORITY

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
