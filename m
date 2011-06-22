Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 137EE900185
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 08:15:19 -0400 (EDT)
Date: Wed, 22 Jun 2011 08:15:16 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] mm: Do not keep page locked during page fault while
 charging it for memcg
Message-ID: <20110622121516.GA28359@infradead.org>
References: <20110622120635.GB14343@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110622120635.GB14343@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>

> +
> +			/* We have to drop the page lock here because memcg
> +			 * charging might block for unbound time if memcg oom
> +			 * killer is disabled.
> +			 */
> +			unlock_page(vmf.page);
> +			ret = mem_cgroup_newpage_charge(page, mm, GFP_KERNEL);
> +			lock_page(vmf.page);

This introduces a completely poinless unlock/lock cycle for non-memcg
pagefaults.  Please make sure it only happens when actually needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
