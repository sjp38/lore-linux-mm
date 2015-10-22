Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id B46786B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 18:47:10 -0400 (EDT)
Received: by pasz6 with SMTP id z6so98437249pas.2
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 15:47:10 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id my1si24346292pbc.186.2015.10.22.15.47.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 15:47:09 -0700 (PDT)
Received: by pacfv9 with SMTP id fv9so103117525pac.3
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 15:47:09 -0700 (PDT)
Date: Fri, 23 Oct 2015 07:47:01 +0900
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for
 zone_reclaimable()checks
Message-ID: <20151022224701.GA5442@mtj.duckdns.org>
References: <20151022151528.GG30579@mtj.duckdns.org>
 <20151022153559.GF26854@dhcp22.suse.cz>
 <20151022153703.GA3899@mtj.duckdns.org>
 <20151022154922.GG26854@dhcp22.suse.cz>
 <20151022184226.GA19289@mtj.duckdns.org>
 <201510230642.HDF57807.QJtSOVFFOMLHOF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201510230642.HDF57807.QJtSOVFFOMLHOF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

Hello,

On Fri, Oct 23, 2015 at 06:42:43AM +0900, Tetsuo Handa wrote:
> Then, isn't below change easier to backport which will also alleviate
> needlessly burning CPU cycles?
> 
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3385,6 +3385,7 @@ retry:
>  	((gfp_mask & __GFP_REPEAT) && pages_reclaimed < (1 << order))) {
>  		/* Wait for some write requests to complete then retry */
>  		wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC, HZ/50);
> +		schedule_timeout_uninterruptible(1);
>  		goto retry;
>  	}

Yeah, that works too.  It should still be put on a dedicated wq with
MEM_RECLAIM tho.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
