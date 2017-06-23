Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B9B6D6B0292
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 16:43:09 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v88so15695635wrb.1
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 13:43:09 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t70si4916421wme.143.2017.06.23.13.43.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 13:43:08 -0700 (PDT)
Date: Fri, 23 Jun 2017 13:43:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 6/6] mm, migration: do not trigger OOM killer when
 migrating memory
Message-Id: <20170623134305.4f59f673051120f95303fd89@linux-foundation.org>
In-Reply-To: <20170623085345.11304-7-mhocko@kernel.org>
References: <20170623085345.11304-1-mhocko@kernel.org>
	<20170623085345.11304-7-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, NeilBrown <neilb@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>

On Fri, 23 Jun 2017 10:53:45 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> Page migration (for memory hotplug, soft_offline_page or mbind) needs
> to allocate a new memory. This can trigger an oom killer if the target
> memory is depleated. Although quite unlikely, still possible, especially
> for the memory hotplug (offlining of memoery). Up to now we didn't
> really have reasonable means to back off. __GFP_NORETRY can fail just
> too easily and __GFP_THISNODE sticks to a single node and that is not
> suitable for all callers.
> 
> But now that we have __GFP_RETRY_MAYFAIL we should use it.  It is
> preferable to fail the migration than disrupt the system by killing some
> processes.

I'm not sure which tree this is against...

> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1492,7 +1492,8 @@ static struct page *new_page(struct page *p, unsigned long private, int **x)
>  
>  		return alloc_huge_page_node(hstate, nid);
>  	} else {
> -		return __alloc_pages_node(nid, GFP_HIGHUSER_MOVABLE, 0);
> +		return __alloc_pages_node(nid,
> +				GFP_HIGHUSER_MOVABLE | __GFP_RETRY_MAYFAIL, 0);
>  	}
>  }

new_page() is now

static struct page *new_page(struct page *p, unsigned long private, int **x)
{
	int nid = page_to_nid(p);

	return new_page_nodemask(p, nid, &node_states[N_MEMORY]);
}

and new_page_nodemask() uses __GFP_RETRY_MAYFAIL so I simply dropped
the above hunk.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
