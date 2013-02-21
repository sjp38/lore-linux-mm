Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 013D36B0008
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 09:53:28 -0500 (EST)
Date: Thu, 21 Feb 2013 09:53:16 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/7] mm,ksm: swapoff might need to copy
Message-ID: <20130221145316.GA23767@cmpxchg.org>
References: <alpine.LNX.2.00.1302210013120.17843@eggly.anvils>
 <alpine.LNX.2.00.1302210023350.17843@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1302210023350.17843@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Feb 21, 2013 at 12:25:40AM -0800, Hugh Dickins wrote:
> Before establishing that KSM page migration was the cause of my
> WARN_ON_ONCE(page_mapped(page))s, I suspected that they came from the
> lack of a ksm_might_need_to_copy() in swapoff's unuse_pte() - which
> in many respects is equivalent to faulting in a page.
> 
> In fact I've never caught that as the cause: but in theory it does
> at least need the KSM_RUN_UNMERGE check in ksm_might_need_to_copy(),
> to avoid bringing a KSM page back in when it's not supposed to be.

Maybe I am mistaken, maybe it was just too obvious to you to mention,
but the main reason for me would be that this can break eviction,
migration, etc. of that page when there is no rmap_item representing
the vma->anon_vma (the cross-anon_vma merge case), no?

> I intended to copy how it's done in do_swap_page(), but have a strong
> aversion to how "swapcache" ends up being used there: rework it with
> "page != swapcache".
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
