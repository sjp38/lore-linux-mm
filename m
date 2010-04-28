Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2D6A26B01EE
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 05:39:58 -0400 (EDT)
Message-ID: <4BD80260.3050501@redhat.com>
Date: Wed, 28 Apr 2010 12:39:44 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: add context argument to shrinker callback
References: <1271118255-21070-1-git-send-email-david@fromorbit.com> <1271118255-21070-2-git-send-email-david@fromorbit.com>
In-Reply-To: <1271118255-21070-2-git-send-email-david@fromorbit.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

On 04/13/2010 03:24 AM, Dave Chinner wrote:
> From: Dave Chinner<dchinner@redhat.com>
>
> The current shrinker implementation requires the registered callback
> to have global state to work from. This makes it difficult to shrink
> caches that are not global (e.g. per-filesystem caches). Add a
> context argument to the shrinker callback so that it can easily be
> used in such situations.
>    

> @@ -995,7 +995,8 @@ static inline void sync_mm_rss(struct task_struct *task, struct mm_struct *mm)
>    * querying the cache size, so a fastpath for that case is appropriate.
>    */
>   struct shrinker {
> -	int (*shrink)(int nr_to_scan, gfp_t gfp_mask);
> +	int (*shrink)(void *ctx, int nr_to_scan, gfp_t gfp_mask);
> +	void *ctx;	/* user callback context */
>   	int seeks;	/* seeks to recreate an obj */
>    


It's nicer (and slightly cheaper) to have

   int (*shrink)(struct shrinker *shrinker, int nr_to_scan, gfp_t gfp_mask);
   /* no void *ctx; */

Clients can use container_of() to reach their context from the shrinker 
argument.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
