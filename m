Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 1AE576B00EC
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 10:53:15 -0400 (EDT)
Message-ID: <4F8C3253.9030208@redhat.com>
Date: Mon, 16 Apr 2012 10:53:07 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] s390: mm: rmap: Transfer storage key to struct page
 under the page lock
References: <20120416141423.GD2359@suse.de>
In-Reply-To: <20120416141423.GD2359@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Hugh Dickins <hughd@google.com>, Linux-MM <linux-mm@kvack.org>, Linux-S390 <linux-s390@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On 04/16/2012 10:14 AM, Mel Gorman wrote:
> This patch is horribly ugly and there has to be a better way of doing
> it. I'm looking for suggestions on what s390 can do here that is not
> painful or broken.

I'm hoping the S390 arch maintainers have an idea.

Ugly or not, we'll need something to fix the bug.

> + * When the late PTE has gone, s390 must transfer the dirty flag from the
> + * storage key to struct page. We can usually skip this if the page is anon,
> + * so about to be freed; but perhaps not if it's in swapcache - there might
> + * be another pte slot containing the swap entry, but page not yet written to
> + * swap.
>    *
> - * The caller needs to hold the pte lock.
> + * set_page_dirty() is called while the page_mapcount is still postive and
> + * under the page lock to avoid races with the mapping being invalidated.
>    */
> -void page_remove_rmap(struct page *page)
> +static void propogate_storage_key(struct page *page, bool lock_required)

Do you mean "propAgate" ?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
