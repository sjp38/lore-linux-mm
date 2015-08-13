Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 7C1476B0038
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 20:16:55 -0400 (EDT)
Received: by pawu10 with SMTP id u10so24880388paw.1
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 17:16:55 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id qb10si680243pdb.150.2015.08.12.17.16.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Aug 2015 17:16:54 -0700 (PDT)
Received: by pacgr6 with SMTP id gr6so24763252pac.2
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 17:16:54 -0700 (PDT)
Date: Wed, 12 Aug 2015 17:16:50 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 04/10] mm, page_alloc: Remove unnecessary taking of a
 seqlock when cpusets are disabled
In-Reply-To: <1439376335-17895-5-git-send-email-mgorman@techsingularity.net>
Message-ID: <alpine.DEB.2.10.1508121714290.19264@chino.kir.corp.google.com>
References: <1439376335-17895-1-git-send-email-mgorman@techsingularity.net> <1439376335-17895-5-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 12 Aug 2015, Mel Gorman wrote:

> There is a seqcounter that protects against spurious allocation failures
> when a task is changing the allowed nodes in a cpuset. There is no need
> to check the seqcounter until a cpuset exists.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: David Rientjes <rientjes@google.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
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

This patch is an obvious improvement, but I think it's also possible to 
change this to be

	if (nr_cpusets() <= 1)
		return false;

and likewise in the existing cpusets_enabled() check in 
get_page_from_freelist().  A root cpuset may not exclude mems on the 
system so, even if mounted, there's no need to check or be worried about 
concurrent change when there is only one cpuset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
