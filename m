Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id CFCC36B0069
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 10:51:59 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id i187so28903368lfe.4
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 07:51:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j130si4997014lfe.268.2016.10.12.07.51.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Oct 2016 07:51:58 -0700 (PDT)
Subject: Re: [RFC 4/4] mm, page_alloc: disallow migratetype fallback in
 fastpath
References: <20160928014148.GA21007@cmpxchg.org>
 <20160929210548.26196-1-vbabka@suse.cz>
 <20160929210548.26196-5-vbabka@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <b80f63d4-f2d3-b73c-c7f8-5340e81ea6f5@suse.cz>
Date: Wed, 12 Oct 2016 16:51:48 +0200
MIME-Version: 1.0
In-Reply-To: <20160929210548.26196-5-vbabka@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On 09/29/2016 11:05 PM, Vlastimil Babka wrote:
> The previous patch has adjusted async compaction so that it helps against
> longterm fragmentation when compacting for a non-MOVABLE high-order allocation.
> The goal of this patch is to force such allocations go through compaction
> once before being allowed to fallback to a pageblock of different migratetype
> (e.g. MOVABLE). In contexts where compaction is not allowed (and for order-0
> allocations), this delayed fallback possibility can still help by trying a
> different zone where fallback might not be needed and potentially waking up
> kswapd earlier.
> 
> Not-yet-signed-off-by: Vlastimil Babka <vbabka@suse.cz>

I forgot that compaction itself also needs to be told to not allow fallback,
otherwise it finishes with COMPACT_SUCCESS without actually doing anything...
