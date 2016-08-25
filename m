Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id DD66183093
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 16:30:37 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id r9so103422809ywg.0
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 13:30:37 -0700 (PDT)
Received: from mx04-000ceb01.pphosted.com (mx0b-000ceb01.pphosted.com. [67.231.152.126])
        by mx.google.com with ESMTPS id p135si11717787qka.197.2016.08.25.13.30.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Aug 2016 13:30:36 -0700 (PDT)
Subject: Re: OOM detection regressions since 4.7
References: <20160822093249.GA14916@dhcp22.suse.cz>
 <20160822093707.GG13596@dhcp22.suse.cz> <20160822100528.GB11890@kroah.com>
 <20160822105441.GH13596@dhcp22.suse.cz> <20160822133114.GA15302@kroah.com>
 <20160822134227.GM13596@dhcp22.suse.cz>
 <20160822150517.62dc7cce74f1af6c1f204549@linux-foundation.org>
 <20160823074339.GB23577@dhcp22.suse.cz>
From: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>
Message-ID: <5852cd26-e013-8313-30f0-68a92db02b8f@Quantum.com>
Date: Thu, 25 Aug 2016 13:30:23 -0700
MIME-Version: 1.0
In-Reply-To: <20160823074339.GB23577@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>
Cc: Greg KH <gregkh@linuxfoundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 23.08.2016 00:43, Michal Hocko wrote:
> OK, fair enough.
> I would really appreciate if the original reporters could retest with
> this patch on top of the current Linus tree. The stable backport posted
> earlier doesn't apply on the current master cleanly but the change is
> essentially same. mmotm tree then can revert this patch before Vlastimil
> series is applied because that code is touching the currently removed
> code.
> ---
>  From 90b6b282bede7966fb6c830a6d012d2239ac40e4 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Mon, 22 Aug 2016 10:52:06 +0200
> Subject: [PATCH] mm, oom: prevent pre-mature OOM killer invocation for high
>   order request
>
> There have been several reports about pre-mature OOM killer invocation
> in 4.7 kernel when order-2 allocation request (for the kernel stack)
> invoked OOM killer even during basic workloads (light IO or even kernel
> compile on some filesystems). In all reported cases the memory is
> fragmented and there are no order-2+ pages available. There is usually
> a large amount of slab memory (usually dentries/inodes) and further
> debugging has shown that there are way too many unmovable blocks which
> are skipped during the compaction. Multiple reporters have confirmed that
> the current linux-next which includes [1] and [2] helped and OOMs are
> not reproducible anymore.
>
> A simpler fix for the late rc and stable is to simply ignore the
> compaction feedback and retry as long as there is a reclaim progress
> and we are not getting OOM for order-0 pages. We already do that for
> CONFING_COMPACTION=n so let's reuse the same code when compaction is
> enabled as well.
>
> [1] https://urldefense.proofpoint.com/v2/url?u=http-3A__lkml.kernel.org_r_20160810091226.6709-2D1-2Dvbabka-40suse.cz&d=DQIBAg&c=8S5idjlO_n28Ko3lg6lskTMwneSC-WqZ5EBTEEvDlkg&r=yGQdEpZknbtYvR0TyhkCGu-ifLklIvXIf740poRFltQ&m=RnSShi4nOuCcTfoBOsx8P8OCPnA5R6zXLo9uZ2RBNjM&s=sJBmU_ySuE2OhXkEeFyTfUr05xjB-mO4aQ5yl4w8z1M&e=
> [2] https://urldefense.proofpoint.com/v2/url?u=http-3A__lkml.kernel.org_r_f7a9ea9d-2Dbb88-2Dbfd6-2De340-2D3a933559305a-40suse.cz&d=DQIBAg&c=8S5idjlO_n28Ko3lg6lskTMwneSC-WqZ5EBTEEvDlkg&r=yGQdEpZknbtYvR0TyhkCGu-ifLklIvXIf740poRFltQ&m=RnSShi4nOuCcTfoBOsx8P8OCPnA5R6zXLo9uZ2RBNjM&s=9oXRJsI8kr1rfMU9tAb9q0-8YlBCZO0XCCFRo0ASjlg&e=
>
> Fixes: 0a0337e0d1d1 ("mm, oom: rework oom detection")
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>   mm/page_alloc.c | 51 ++-------------------------------------------------
>   1 file changed, 2 insertions(+), 49 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 3fbe73a6fe4b..7791a03f8deb 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3137,54 +3137,6 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>   	return NULL;
>   }
>   
> -static inline bool
> -should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
> -		     enum compact_result compact_result,
> -		     enum compact_priority *compact_priority,
> -		     int compaction_retries)
> -{
> -	int max_retries = MAX_COMPACT_RETRIES;
> -
> -	if (!order)
> -		return false;
> -
> -	/*
> -	 * compaction considers all the zone as desperately out of memory
> -	 * so it doesn't really make much sense to retry except when the
> -	 * failure could be caused by insufficient priority
> -	 */
> -	if (compaction_failed(compact_result)) {
> -		if (*compact_priority > MIN_COMPACT_PRIORITY) {
> -			(*compact_priority)--;
> -			return true;
> -		}
> -		return false;
> -	}
> -
> -	/*
> -	 * make sure the compaction wasn't deferred or didn't bail out early
> -	 * due to locks contention before we declare that we should give up.
> -	 * But do not retry if the given zonelist is not suitable for
> -	 * compaction.
> -	 */
> -	if (compaction_withdrawn(compact_result))
> -		return compaction_zonelist_suitable(ac, order, alloc_flags);
> -
> -	/*
> -	 * !costly requests are much more important than __GFP_REPEAT
> -	 * costly ones because they are de facto nofail and invoke OOM
> -	 * killer to move on while costly can fail and users are ready
> -	 * to cope with that. 1/4 retries is rather arbitrary but we
> -	 * would need much more detailed feedback from compaction to
> -	 * make a better decision.
> -	 */
> -	if (order > PAGE_ALLOC_COSTLY_ORDER)
> -		max_retries /= 4;
> -	if (compaction_retries <= max_retries)
> -		return true;
> -
> -	return false;
> -}
>   #else
>   static inline struct page *
>   __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
> @@ -3195,6 +3147,8 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>   	return NULL;
>   }
>   
> +#endif /* CONFIG_COMPACTION */
> +
>   static inline bool
>   should_compact_retry(struct alloc_context *ac, unsigned int order, int alloc_flags,
>   		     enum compact_result compact_result,
> @@ -3221,7 +3175,6 @@ should_compact_retry(struct alloc_context *ac, unsigned int order, int alloc_fla
>   	}
>   	return false;
>   }
> -#endif /* CONFIG_COMPACTION */
>   
>   /* Perform direct synchronous page reclaim */
>   static int

This worked for me for about 12 hours of my torture test. Logs are at 
https://filebin.net/2rfah407nbhzs69e/OOM_4.8.0-rc2_p1.tar.bz2.


Ralf-Peter


----------------------------------------------------------------------
The information contained in this transmission may be confidential. Any disclosure, copying, or further distribution of confidential information is not permitted unless such privilege is explicitly granted in writing by Quantum. Quantum reserves the right to have electronic communications, including email and attachments, sent across its networks filtered through anti virus and spam software programs and retain such messages in order to comply with applicable data security and retention requirements. Quantum is not responsible for the proper and complete transmission of the substance of this communication or for any delay in its receipt.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
