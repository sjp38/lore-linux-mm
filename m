Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1733D6B0284
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 13:34:03 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id fu14so216008715pad.0
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 10:34:03 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id i5si8775499pfe.3.2016.09.23.10.34.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Sep 2016 10:34:02 -0700 (PDT)
Subject: Re: [PATCH] mm: warn about allocations which stall for too long
References: <20160923081555.14645-1-mhocko@kernel.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <57E56789.1070205@intel.com>
Date: Fri, 23 Sep 2016 10:34:01 -0700
MIME-Version: 1.0
In-Reply-To: <20160923081555.14645-1-mhocko@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 09/23/2016 01:15 AM, Michal Hocko wrote:
> +	/* Make sure we know about allocations which stall for too long */
> +	if (!(gfp_mask & __GFP_NOWARN) && time_after(jiffies, alloc_start + stall_timeout)) {
> +		pr_warn("%s: page alloction stalls for %ums: order:%u mode:%#x(%pGg)\n",
> +				current->comm, jiffies_to_msecs(jiffies-alloc_start),
> +				order, gfp_mask, &gfp_mask);
> +		stall_timeout += 10 * HZ;
> +		dump_stack();
> +	}

This would make an awesome tracepoint.  There's probably still plenty of
value to having it in dmesg, but the configurability of tracepoints is
hard to beat.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
