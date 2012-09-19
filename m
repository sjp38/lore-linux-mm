Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 974A16B005A
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 10:15:05 -0400 (EDT)
Message-ID: <5059D367.7020801@redhat.com>
Date: Wed, 19 Sep 2012 10:15:03 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: thp: fix pmd_present for split_huge_page and PROT_NONE
 with THP
References: <1348005959-4869-1-git-send-email-aarcange@redhat.com>
In-Reply-To: <1348005959-4869-1-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Johannes Weiner <jweiner@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>

On 09/18/2012 06:05 PM, Andrea Arcangeli wrote:
> In many places !pmd_present has been converted to pmd_none. For pmds
> that's equivalent and pmd_none is quicker so using pmd_none is
> better.
>
> However (unless we delete pmd_present) we should provide an accurate
> pmd_present too. This will avoid the risk of code thinking the pmd is
> non present because it's under __split_huge_page_map, see the
> pmd_mknotpresent there and the comment above it.
>
> If the page has been mprotected as PROT_NONE, it would also lead to a
> pmd_present false negative in the same way as the race with
> split_huge_page.
>
> Because the PSE bit stays on at all times (both during split_huge_page
> and when the _PAGE_PROTNONE bit get set), we could only check for the
> PSE bit, but checking the PROTNONE bit too is still good to remember
> pmd_present must always keep PROT_NONE into account.
 >
> This explains a not reproducible BUG_ON that was seldom reported on
> the lists.
>
> The same issue is in pmd_large, it would go wrong with both PROT_NONE
> and if it races with split_huge_page.
>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
