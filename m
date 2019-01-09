Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id B06708E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 14:27:33 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id m13so4723524pls.15
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 11:27:33 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t3si12089107plo.69.2019.01.09.11.27.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 11:27:32 -0800 (PST)
Date: Wed, 9 Jan 2019 11:27:31 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, compaction: Use free lists to quickly locate a
 migration target -fix
Message-Id: <20190109112731.7d189ba6a606ca8f84dc5fa2@linux-foundation.org>
In-Reply-To: <20190109111344.GU31517@techsingularity.net>
References: <20190104125011.16071-1-mgorman@techsingularity.net>
	<20190109111344.GU31517@techsingularity.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, kirill@shutemov.name, Linux-MM <linux-mm@kvack.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On Wed, 9 Jan 2019 11:13:44 +0000 Mel Gorman <mgorman@techsingularity.net> wrote:

> Full compaction of a node passes in negative orders which can lead to array
> boundary issues. While it could be addressed in the control flow of the
> primary loop, it would be fragile so explicitly check for the condition.
> This is a fix for the mmotm patch
> broken-out/mm-compaction-use-free-lists-to-quickly-locate-a-migration-target.patch
> 
> ...
>
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1206,6 +1206,10 @@ fast_isolate_freepages(struct compact_control *cc)
>  	bool scan_start = false;
>  	int order;
>  
> +	/* Full compaction passes in a negative order */
> +	if (order <= 0)
> +		return cc->free_pfn;
> +
>  	/*
>  	 * If starting the scan, use a deeper search and use the highest
>  	 * PFN found if a suitable one is not found.

`order' is uninitialized.
