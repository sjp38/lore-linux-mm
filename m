Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id CE2956B18EF
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 07:58:28 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id q12-v6so6095700pgp.6
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 04:58:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w7-v6sor2065163pgb.24.2018.08.20.04.58.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 Aug 2018 04:58:27 -0700 (PDT)
Date: Mon, 20 Aug 2018 14:58:18 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 0/2] fix for "pathological THP behavior"
Message-ID: <20180820115818.mmeayjkplux2z6im@kshutemo-mobl1>
References: <20180820032204.9591-1-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180820032204.9591-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

On Sun, Aug 19, 2018 at 11:22:02PM -0400, Andrea Arcangeli wrote:
> Hello,
> 
> we detected a regression compared to older kernels, only happening
> with defrag=always or by using MADV_HUGEPAGE (and QEMU uses it).
> 
> I haven't bisected but I suppose this started since commit
> 5265047ac30191ea24b16503165000c225f54feb combined with previous
> commits that introduced the logic to not try to invoke reclaim for THP
> allocations in the remote nodes.
> 
> Once I looked into it the problem was pretty obvious and there are two
> possible simple fixes, one is not to invoke reclaim and stick to
> compaction in the local node only (still __GFP_THISNODE model).
> 
> This approach keeps the logic the same and prioritizes for NUMA
> locality over THP generation.
> 
> Then I'll send the an alternative that drops the __GFP_THISNODE logic
> if_DIRECT_RECLAIM is set. That however changes the behavior for
> MADV_HUGEPAGE and prioritizes THP generation over NUMA locality.
> 
> A possible incremental improvement for this __GFP_COMPACT_ONLY
> solution would be to remove __GFP_THISNODE (and in turn
> __GFP_COMPACT_ONLY) after checking the watermarks if there's no free
> PAGE_SIZEd memory in the local node. However checking the watermarks
> in mempolicy.c is not ideal so it would be a more messy change and
> it'd still need to use __GFP_COMPACT_ONLY as implemented here for when
> there's no PAGE_SIZEd free memory in the local node. That further
> improvement wouldn't be necessary if there's agreement to prioritize
> THP generation over NUMA locality (the alternative solution I'll send
> in a separate post).

I personally prefer to prioritize NUMA locality over THP
(__GFP_COMPACT_ONLY variant), but I don't know page-alloc/compaction good
enough to Ack it.

-- 
 Kirill A. Shutemov
