Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 3B11A6B0257
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 04:33:10 -0500 (EST)
Received: by pfdd184 with SMTP id d184so62317984pfd.3
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 01:33:10 -0800 (PST)
Received: from e28smtp08.in.ibm.com (e28smtp08.in.ibm.com. [122.248.162.8])
        by mx.google.com with ESMTPS id cy6si4943026pad.242.2015.12.07.01.33.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Dec 2015 01:33:09 -0800 (PST)
Received: from localhost
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 7 Dec 2015 15:03:06 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 15935E005C
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 15:03:49 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tB79UsV6131452
	for <linux-mm@kvack.org>; Mon, 7 Dec 2015 15:00:55 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tB79UrNq029761
	for <linux-mm@kvack.org>; Mon, 7 Dec 2015 15:00:53 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] mm: thp: introduce thp_mmu_gather to pin tail pages during MMU gather
In-Reply-To: <1447938052-22165-2-git-send-email-aarcange@redhat.com>
References: <1447938052-22165-1-git-send-email-aarcange@redhat.com> <1447938052-22165-2-git-send-email-aarcange@redhat.com>
Date: Mon, 07 Dec 2015 15:00:53 +0530
Message-ID: <87wpsq7ghe.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: "\\\"Kirill A. Shutemov\\\"" <kirill@shutemov.name>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>

Andrea Arcangeli <aarcange@redhat.com> writes:

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

Will this be a problem after
http://article.gmane.org/gmane.linux.kernel.mm/139631  
"[PATCHv12 00/37] THP refcounting redesign" ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
