Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id A69FC6B0269
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 09:08:08 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id e69-v6so976406ote.17
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 06:08:08 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g202-v6si9336474oib.234.2018.10.09.06.08.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 06:08:07 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm: thp: relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
References: <20180925120326.24392-1-mhocko@kernel.org>
 <20180925120326.24392-2-mhocko@kernel.org>
 <alpine.DEB.2.21.1810041302330.16935@chino.kir.corp.google.com>
 <20181005073854.GB6931@suse.de>
 <alpine.DEB.2.21.1810051320270.202739@chino.kir.corp.google.com>
 <20181005232155.GA2298@redhat.com>
 <alpine.DEB.2.21.1810081303060.221006@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <19684def-0ab4-6ca6-767d-2364cc459740@suse.cz>
Date: Tue, 9 Oct 2018 15:08:03 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1810081303060.221006@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 10/8/18 10:41 PM, David Rientjes wrote:
> +			/*
> +			 * If faulting a hugepage, it is very unlikely that
> +			 * thrashing the zonelist is going to assist compaction
> +			 * in freeing an entire pageblock.  There are no
> +			 * guarantees memory compaction can free an entire
> +			 * pageblock under such memory pressure that it is
> +			 * better to simply fail and fallback to native pages.
> +			 */
> +			if (order == pageblock_order &&
> +					!(current->flags & PF_KTHREAD))
> +				goto nopage;

After we got rid of similar hardcoded heuristics, I would be very
unhappy to start adding them back. A new gfp flag is also unfortunate,
but more acceptable to me.

> +
>  			/*
>  			 * Looks like reclaim/compaction is worth trying, but
>  			 * sync compaction could be very expensive, so keep
> 
