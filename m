Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id 09E756B0035
	for <linux-mm@kvack.org>; Thu, 31 Jul 2014 11:27:19 -0400 (EDT)
Received: by mail-we0-f172.google.com with SMTP id x48so2985377wes.3
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 08:27:19 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id ft4si114540wic.90.2014.07.31.08.27.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 31 Jul 2014 08:27:14 -0700 (PDT)
Date: Thu, 31 Jul 2014 11:26:59 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/3] mm, oom: remove unnecessary check for NULL zonelist
Message-ID: <20140731152659.GB9952@cmpxchg.org>
References: <alpine.DEB.2.02.1407231814110.22326@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1407231815090.22326@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1407231815090.22326@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jul 23, 2014 at 06:16:32PM -0700, David Rientjes wrote:
> If the pagefault handler is modified to pass a non-NULL zonelist then an 
> unnecessary check for a NULL zonelist in constrained_alloc() can be removed.
>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/oom_kill.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -208,8 +208,6 @@ static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
>  	/* Default to all available memory */
>  	*totalpages = totalram_pages + total_swap_pages;
>  
> -	if (!zonelist)
> -		return CONSTRAINT_NONE;
>  	/*
>  	 * Reach here only when __GFP_NOFAIL is used. So, we should avoid
>  	 * to kill current.We have to random task kill in this case.
> @@ -696,7 +694,7 @@ void pagefault_out_of_memory(void)
>  
>  	zonelist = node_zonelist(first_memory_node, GFP_KERNEL);
>  	if (try_set_zonelist_oom(zonelist, GFP_KERNEL)) {
> -		out_of_memory(NULL, 0, 0, NULL, false);
> +		out_of_memory(zonelist, 0, 0, NULL, false);

out_of_memory() wants the zonelist that was used during allocation,
not just the random first node's zonelist that's simply picked to
serialize page fault OOM kills system-wide.

This would even change how panic_on_oom behaves for page fault OOMs
(in a completely unpredictable way) if we get CONSTRAINED_CPUSET.

This change makes no sense to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
