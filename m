Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 56C9C6B0002
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 17:47:01 -0500 (EST)
Date: Tue, 22 Jan 2013 14:46:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/6] mm: Fold page->_last_nid into page->flags where
 possible
Message-Id: <20130122144659.d512e05c.akpm@linux-foundation.org>
In-Reply-To: <1358874762-19717-6-git-send-email-mgorman@suse.de>
References: <1358874762-19717-1-git-send-email-mgorman@suse.de>
	<1358874762-19717-6-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Simon Jeons <simon.jeons@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 22 Jan 2013 17:12:41 +0000
Mel Gorman <mgorman@suse.de> wrote:

> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> 
> page->_last_nid fits into page->flags on 64-bit. The unlikely 32-bit NUMA
> configuration with NUMA Balancing will still need an extra page field.
> As Peter notes "Completely dropping 32bit support for CONFIG_NUMA_BALANCING
> would simplify things, but it would also remove the warning if we grow
> enough 64bit only page-flags to push the last-cpu out."

How much space remains in the 64-bit page->flags?

Was this the best possible use of the remaining space?

It's good that we can undo this later by flipping
LAST_NID_NOT_IN_PAGE_FLAGS.

> [mgorman@suse.de: Minor modifications]
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Several of these patches are missing signoffs (Peter and Hugh).

>
> ...
>
> +static inline int page_last_nid(struct page *page)
> +{
> +	return (page->flags >> LAST_NID_PGSHIFT) & LAST_NID_MASK;
> +}
> +
> +static inline int page_xchg_last_nid(struct page *page, int nid)
> +{
> +	unsigned long old_flags, flags;
> +	int last_nid;
> +
> +	do {
> +		old_flags = flags = page->flags;
> +		last_nid = page_last_nid(page);
> +
> +		flags &= ~(LAST_NID_MASK << LAST_NID_PGSHIFT);
> +		flags |= (nid & LAST_NID_MASK) << LAST_NID_PGSHIFT;
> +	} while (unlikely(cmpxchg(&page->flags, old_flags, flags) != old_flags));
> +
> +	return last_nid;
> +}
> +
> +static inline void reset_page_last_nid(struct page *page)
> +{
> +	page_xchg_last_nid(page, (1 << LAST_NID_SHIFT) - 1);
> +}

page_xchg_last_nid() and reset_page_last_nid() are getting nuttily
large.  Please investigate uninlining them?

reset_page_last_nid() is poorly named.  page_reset_last_nid() would be
better, and consistent.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
