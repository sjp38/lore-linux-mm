Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 619E56B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 19:23:00 -0500 (EST)
Received: by wmdw130 with SMTP id w130so817158wmd.0
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 16:22:59 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id xs8si14734172wjc.98.2015.11.19.16.22.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 16:22:59 -0800 (PST)
Date: Thu, 19 Nov 2015 16:22:55 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm: thp: introduce thp_mmu_gather to pin tail pages
 during MMU gather
Message-Id: <20151119162255.b73e9db832501b40e1850c1a@linux-foundation.org>
In-Reply-To: <1447938052-22165-2-git-send-email-aarcange@redhat.com>
References: <1447938052-22165-1-git-send-email-aarcange@redhat.com>
	<1447938052-22165-2-git-send-email-aarcange@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, "\\\"Kirill A. Shutemov\\\"" <kirill@shutemov.name>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>

On Thu, 19 Nov 2015 14:00:51 +0100 Andrea Arcangeli <aarcange@redhat.com> wrote:

> This theoretical SMP race condition was found with source review. No
> real life app could be affected as the result of freeing memory while
> accessing it is either undefined or it's a workload the produces no
> information.
> 
> For something to go wrong because the SMP race condition triggered,
> it'd require a further tiny window within the SMP race condition
> window. So nothing bad is happening in practice even if the SMP race
> condition triggers. It's still better to apply the fix to have the
> math guarantee.
> 
> The fix just adds a thp_mmu_gather atomic_t counter to the THP pages,
> so split_huge_page can elevate the tail page count accordingly and
> leave the tail page freeing task to whoever elevated thp_mmu_gather.
> 

This is a pretty nasty patch :( We now have random page*'s with bit 0
set floating around in mmu_gather.__pages[].  It assumes/requires that
nobody uses those pages until they hit release_pages().  And the tlb
flushing code is pretty twisty, with various Kconfig and arch dependent
handlers.

Is there no nicer way?

> +/*
> + * free_trans_huge_page_list() is used to free the pages returned by
> + * trans_huge_page_release() (if still PageTransHuge()) in
> + * release_pages().
> + */

There is no function trans_huge_page_release().

> +extern void free_trans_huge_page_list(struct list_head *list);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
