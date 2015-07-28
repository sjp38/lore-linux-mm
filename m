Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 1A4036B0253
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 08:32:14 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so177472718wic.0
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 05:32:13 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k4si20095835wif.101.2015.07.28.05.32.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jul 2015 05:32:12 -0700 (PDT)
Subject: Re: [PATCH 04/10] mm, page_alloc: Remove unnecessary taking of a
 seqlock when cpusets are disabled
References: <1437379219-9160-1-git-send-email-mgorman@suse.com>
 <1437379219-9160-5-git-send-email-mgorman@suse.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55B77649.5010301@suse.cz>
Date: Tue, 28 Jul 2015 14:32:09 +0200
MIME-Version: 1.0
In-Reply-To: <1437379219-9160-5-git-send-email-mgorman@suse.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.com>, Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

On 07/20/2015 10:00 AM, Mel Gorman wrote:
> From: Mel Gorman <mgorman@suse.de>
>
> There is a seqcounter that protects spurious allocation fails when a task
> is changing the allowed nodes in a cpuset. There is no need to check the
> seqcounter until a cpuset exists.

If cpusets become enabled betwen _begin and _retry, then it will retry 
due to comparing with 0, but not crash, so it's safe.

> Signed-off-by: Mel Gorman <mgorman@sujse.de>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   include/linux/cpuset.h | 6 ++++++
>   1 file changed, 6 insertions(+)
>
> diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
> index 1b357997cac5..6eb27cb480b7 100644
> --- a/include/linux/cpuset.h
> +++ b/include/linux/cpuset.h
> @@ -104,6 +104,9 @@ extern void cpuset_print_task_mems_allowed(struct task_struct *p);
>    */
>   static inline unsigned int read_mems_allowed_begin(void)
>   {
> +	if (!cpusets_enabled())
> +		return 0;
> +
>   	return read_seqcount_begin(&current->mems_allowed_seq);
>   }
>
> @@ -115,6 +118,9 @@ static inline unsigned int read_mems_allowed_begin(void)
>    */
>   static inline bool read_mems_allowed_retry(unsigned int seq)
>   {
> +	if (!cpusets_enabled())
> +		return false;
> +
>   	return read_seqcount_retry(&current->mems_allowed_seq, seq);
>   }
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
