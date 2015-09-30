Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 1CE3D6B0278
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 18:22:55 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so52769892pad.1
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 15:22:54 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id fe1si3820463pab.169.2015.09.30.15.22.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Sep 2015 15:22:54 -0700 (PDT)
Received: by pacex6 with SMTP id ex6so52867804pac.0
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 15:22:54 -0700 (PDT)
Date: Wed, 30 Sep 2015 15:22:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 03/10] mm, page_alloc: Remove unnecessary taking of a
 seqlock when cpusets are disabled
In-Reply-To: <1442832762-7247-4-git-send-email-mgorman@techsingularity.net>
Message-ID: <alpine.DEB.2.10.1509301521380.23324@chino.kir.corp.google.com>
References: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net> <1442832762-7247-4-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 21 Sep 2015, Mel Gorman wrote:

> There is a seqcounter that protects against spurious allocation failures
> when a task is changing the allowed nodes in a cpuset. There is no need
> to check the seqcounter until a cpuset exists.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Christoph Lameter <cl@linux.com>
> Acked-by: David Rientjes <rientjes@google.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Michal Hocko <mhocko@suse.com>
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

I thought this was going to test nr_cpusets() <= 1?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
