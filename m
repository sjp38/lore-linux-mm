Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id EE9BF6B19BA
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 11:19:12 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id o190-v6so12351977qkc.21
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 08:19:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e23-v6si2416319qta.54.2018.08.20.08.19.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Aug 2018 08:19:11 -0700 (PDT)
Date: Mon, 20 Aug 2018 11:19:05 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/2] fix for "pathological THP behavior"
Message-ID: <20180820151905.GB13047@redhat.com>
References: <20180820032204.9591-1-aarcange@redhat.com>
 <20180820115818.mmeayjkplux2z6im@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180820115818.mmeayjkplux2z6im@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

Hi Kirill,

On Mon, Aug 20, 2018 at 02:58:18PM +0300, Kirill A. Shutemov wrote:
> I personally prefer to prioritize NUMA locality over THP
> (__GFP_COMPACT_ONLY variant), but I don't know page-alloc/compaction good
> enough to Ack it.

If we go in this direction it'd be nice after fixing the showstopper
bug, if we could then proceed with an orthogonal optimization by
checking the watermarks and if the watermarks shows there are no
PAGE_SIZEd pages available in the local node we should remove both
__GFP_THISNODE and __GFP_COMPACT_ONLY.

If as opposed there's still PAGE_SIZEd free memory in the local node
(not possible to compact for whatever reason), we should stick to
__GFP_THISNODE | __GFP_COMPACT_ONLY.

It's orthogonal because the above addition would make sense also in
the current (buggy) code.

The main implementation issue is that the watermark checking is not
well done in mempolicy.c but the place to clear __GFP_THISNODE and
__GFP_COMPACT_ONLY currently is there.

The case that the local node gets completely full and has not even 4k
pages available should be totally common, because if you keep
allocating and you allocate more than the size of a NUMA node
eventually you will fill the local node with THP then consume all 4k
pages and then you get into the case where the current code is totally
unable to allocate THP from the other nodes and it would be totally
possible to fix with the removal of __GFP_THISNODE |
__GFP_COMPACT_ONLY, after the PAGE_SIZE watermark check.

I'm mentioning this optimization in this context, even if it's
orthogonal, because the alternative patch that prioritizes THP over
NUMA locality for MADV_HUGEPAGE and defer=always would solve that too
with a one liner and there would be no need of watermark checking and
flipping gfp bits whatsoever. Once the local node is full, THPs keeps
being provided as expected.

Thanks,
Andrea
