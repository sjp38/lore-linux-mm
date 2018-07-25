Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C3EA56B026F
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 03:40:13 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r9-v6so2743934edh.14
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 00:40:13 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a24-v6si340134eda.125.2018.07.25.00.40.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jul 2018 00:40:12 -0700 (PDT)
Date: Wed, 25 Jul 2018 09:40:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] [PATCH] mm: disable preemption before swapcache_free
Message-ID: <20180725074009.GU28386@dhcp22.suse.cz>
References: <2018072514375722198958@wingtech.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2018072514375722198958@wingtech.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "zhaowuyun@wingtech.com" <zhaowuyun@wingtech.com>
Cc: mgorman <mgorman@techsingularity.net>, akpm <akpm@linux-foundation.org>, minchan <minchan@kernel.org>, vinmenon <vinmenon@codeaurora.org>, hannes <hannes@cmpxchg.org>, "hillf.zj" <hillf.zj@alibaba-inc.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Wed 25-07-18 14:37:58, zhaowuyun@wingtech.com wrote:
[...]
> Change-Id: I36d9df7ccff77c589b7157225410269c675a8504

What is this?

> Signed-off-by: zhaowuyun <zhaowuyun@wingtech.com>
> ---
> mm/vmscan.c | 9 +++++++++
> 1 file changed, 9 insertions(+)
>  
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 2740973..acede002 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -674,6 +674,12 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
> BUG_ON(!PageLocked(page));
> BUG_ON(mapping != page_mapping(page));
> + /*
> + * preemption must be disabled to protect current task preempted before
> + * swapcache_free(swap) invoked by the task which do the
> + * __read_swap_cache_async job on the same page
> + */
> + preempt_disable();
> spin_lock_irqsave(&mapping->tree_lock, flags);

Hmm, but spin_lock_irqsave already implies the disabled preemption.
-- 
Michal Hocko
SUSE Labs
