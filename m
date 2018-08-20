Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 42FE06B1B9E
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 19:25:06 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id j9-v6so14779897qtn.22
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 16:25:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a205-v6si1206572qkc.68.2018.08.20.16.25.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Aug 2018 16:25:05 -0700 (PDT)
Date: Mon, 20 Aug 2018 19:24:59 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/2] fix for "pathological THP behavior"
Message-ID: <20180820232459.GE13047@redhat.com>
References: <20180820032204.9591-1-aarcange@redhat.com>
 <20180820115818.mmeayjkplux2z6im@kshutemo-mobl1>
 <CAHbLzkqU88GbwpdP3dX7psVKG7boy21F+3iM4qnn4qE1wMeVyg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHbLzkqU88GbwpdP3dX7psVKG7boy21F+3iM4qnn4qE1wMeVyg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <shy828301@gmail.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

Hello,

On Mon, Aug 20, 2018 at 12:06:11PM -0700, Yang Shi wrote:
> May the approach #1 break the setting of zone_reclaim_mode? Or it may
> behave like zone_reclaim_mode is set even though the knob is cleared?

Current MADV_HUGEPAGE THP default behavior is similar to
zone/node_reclaim_mode yes, the approach #1 won't change that.

The problem is that it behaved like the hardest kind of
zone/node_reclaim_mode. It wouldn't even try to stop unmap/writeback.
zone/node_reclaim_mode can stop that at least.

The approach #1 simply reduces the aggressiveness level from the
hardest kind of zone/node_reclaim_mode to something lither than any
reclaim would be (i.e. no reclaim and only compaction, which of course
only makes sense for order > 0 allocations).

If THP fails then the PAGE_SIZE allocation fallback kicks in and it'll
spread to all nodes and it will invoke reclaim if needed. If it
invokes reclaim, it'll behave according to node_reclaim_mode if
set. There's no change to that part.

When MADV_HUGEPAGE wasn't used or defrag wasn't set to "always", the
current code didn't even invoke compaction, but the whole point of
MADV_HUGEPAGE is to try to provide THP from the very first page fault,
so it's ok to pay the cost of compaction there because userland told
us those are long lived performance sensitive allocations.

What MADV_HUGEPAGE can't to is to trigger an heavy swapout of the
memory in the local node, despite there may be plenty of free memory
in all other nodes (even THP pages) and in the local node in PAGE_SIZE
fragments.

Thanks,
Andrea
