Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0DD816B004A
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 20:57:28 -0400 (EDT)
Message-ID: <4C818B5E.5080507@redhat.com>
Date: Fri, 03 Sep 2010 19:57:18 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] fix swapin race condition
References: <20100903153958.GC16761@random.random>
In-Reply-To: <20100903153958.GC16761@random.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 09/03/2010 11:39 AM, Andrea Arcangeli wrote:
> From: Andrea Arcangeli<aarcange@redhat.com>
>
> The pte_same check is reliable only if the swap entry remains pinned
> (by the page lock on swapcache). We've also to ensure the swapcache
> isn't removed before we take the lock as try_to_free_swap won't care
> about the page pin.
>
> Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

Andrew, one of the possible impacts of this patch is that a
KSM-shared page can point to the anon_vma of another process,
which could exit before the page is freed.

This can leave a page with a pointer to a recycled anon_vma
object, or worse, a pointer to something that is no longer
an anon_vma.

Backporting this patch to -stable is worthwhile, IMHO.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
