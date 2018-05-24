Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2B6486B0269
	for <linux-mm@kvack.org>; Thu, 24 May 2018 07:43:54 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id s16-v6so837153pfm.1
        for <linux-mm@kvack.org>; Thu, 24 May 2018 04:43:54 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u5-v6si9124946pgc.335.2018.05.24.04.43.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 24 May 2018 04:43:52 -0700 (PDT)
Date: Thu, 24 May 2018 04:43:50 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH 0/5] kmalloc-reclaimable caches
Message-ID: <20180524114350.GA10323@bombadil.infradead.org>
References: <20180524110011.1940-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180524110011.1940-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Vijayanand Jitta <vjitta@codeaurora.org>

On Thu, May 24, 2018 at 01:00:06PM +0200, Vlastimil Babka wrote:
> Now for the issues a.k.a. why RFC:
> 
> - I haven't find any other obvious users for reclaimable kmalloc (yet)

Is that a problem?  This sounds like it's enough to solve Facebook's
problem.

> - the name of caches kmalloc-reclaimable-X is rather long

Yes; Christoph and I were talking about restricting slab names to 16 bytes
just to make /proc/slabinfo easier to read.  How about

kmalloc-rec-128k
1234567890123456

Just makes it ;-)

Of course, somebody needs to do the work to use k/M instead of 4194304.
We also need to bikeshed about when to switch; should it be:

kmalloc-rec-512
kmalloc-rec-1024
kmalloc-rec-2048
kmalloc-rec-4096
kmalloc-rec-8192
kmalloc-rec-16k

or should it be

kmalloc-rec-512
kmalloc-rec-1k
kmalloc-rec-2k
kmalloc-rec-4k
kmalloc-rec-8k
kmalloc-rec-16k

I slightly favour the latter as it'll be easier to implement.  Something like

	static const char suffixes[3] = ' kM';
	int idx = 0;

	while (size > 1024) {
		size /= 1024;
		idx++;
	}

	sprintf("%d%c", size, suffices[idx]);
