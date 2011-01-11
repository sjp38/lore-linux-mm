Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 059CA6B0092
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 15:35:48 -0500 (EST)
Message-ID: <4D2CBF00.1080706@redhat.com>
Date: Tue, 11 Jan 2011 15:35:12 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix migration hangs on anon_vma lock
References: <alpine.LSU.2.00.1101102259160.24988@sister.anvils>
In-Reply-To: <alpine.LSU.2.00.1101102259160.24988@sister.anvils>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 01/11/2011 02:08 AM, Hugh Dickins wrote:
> Increased usage of page migration in mmotm reveals that the anon_vma
> locking in unmap_and_move() has been deficient since 2.6.36 (or even
> earlier).  Review at the time of f18194275c39835cb84563500995e0d503a32d9a
> "mm: fix hang on anon_vma->root->lock" missed the issue here: the anon_vma
> to which we get a reference may already have been freed back to its slab
> (it is in use when we check page_mapped, but that can change), and so its
> anon_vma->root may be switched at any moment by reuse in anon_vma_prepare.
>
> Perhaps we could fix that with a get_anon_vma_unless_zero(), but let's not:
> just rely on page_lock_anon_vma() to do all the hard thinking for us, then
> we don't need any rcu read locking over here.
>
> In removing the rcu_unlock label: since PageAnon is a bit in page->mapping,
> it's impossible for a !page->mapping page to be anon; but insert VM_BUG_ON
> in case the implementation ever changes.
>
> Signed-off-by: Hugh Dickins<hughd@google.com>
> Cc: stable@kernel.org [2.6.37, 2.6.36]

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
