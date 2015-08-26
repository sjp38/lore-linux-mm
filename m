Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 3B3B96B0253
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 06:25:12 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so10714720wic.1
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 03:25:11 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id gh20si9007894wic.59.2015.08.26.03.25.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Aug 2015 03:25:10 -0700 (PDT)
Received: by wicja10 with SMTP id ja10so10714217wic.1
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 03:25:10 -0700 (PDT)
Date: Wed, 26 Aug 2015 12:25:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 03/12] mm, page_alloc: Remove unnecessary taking of a
 seqlock when cpusets are disabled
Message-ID: <20150826102508.GF25196@dhcp22.suse.cz>
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
 <1440418191-10894-4-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1440418191-10894-4-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 24-08-15 13:09:42, Mel Gorman wrote:
> There is a seqcounter that protects against spurious allocation failures
> when a task is changing the allowed nodes in a cpuset. There is no need
> to check the seqcounter until a cpuset exists.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Christoph Lameter <cl@linux.com>
> Acked-by: David Rientjes <rientjes@google.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/cpuset.h | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
> index 1b357997cac5..6eb27cb480b7 100644
> --- a/include/linux/cpuset.h
> +++ b/include/linux/cpuset.h
> @@ -104,6 +104,9 @@ extern void cpuset_print_task_mems_allowed(struct task_struct *p);
>   */
>  static inline unsigned int read_mems_allowed_begin(void)
>  {
> +	if (!cpusets_enabled())
> +		return 0;
> +
>  	return read_seqcount_begin(&current->mems_allowed_seq);
>  }
>  
> @@ -115,6 +118,9 @@ static inline unsigned int read_mems_allowed_begin(void)
>   */
>  static inline bool read_mems_allowed_retry(unsigned int seq)
>  {
> +	if (!cpusets_enabled())
> +		return false;
> +
>  	return read_seqcount_retry(&current->mems_allowed_seq, seq);
>  }
>  
> -- 
> 2.4.6

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
