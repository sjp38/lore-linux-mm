Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8C23D6B0069
	for <linux-mm@kvack.org>; Wed,  8 Oct 2014 15:10:50 -0400 (EDT)
Received: by mail-ig0-f172.google.com with SMTP id r2so8526776igi.5
        for <linux-mm@kvack.org>; Wed, 08 Oct 2014 12:10:50 -0700 (PDT)
Received: from relay.sgi.com (relay1.sgi.com. [192.48.180.66])
        by mx.google.com with ESMTP id rv1si33440658igb.2.2014.10.08.12.10.48
        for <linux-mm@kvack.org>;
        Wed, 08 Oct 2014 12:10:49 -0700 (PDT)
Date: Wed, 8 Oct 2014 14:10:50 -0500
From: Alex Thorlton <athorlton@sgi.com>
Subject: [BUG] mm, thp: khugepaged can't allocate on requested node when
 confined to a cpuset
Message-ID: <20141008191050.GK3778@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Bob Liu <lliubbo@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

Hey everyone,

I've run into a some frustrating behavior from the khugepaged thread,
that I'm hoping to get sorted out.  It appears that if you pin
khugepaged to a cpuset (i.e. node 0), and it begins scanning/collapsing
pages for a process on a cpuset that doesn't have any memory nodes in
common with kugepaged (i.e. node 1), then the collapsed pages will all
be allocated khugepaged's node (in this case node 0), clearly breaking
the cpuset boundary set up for the process in question.

I'm aware that there are some known issues with khugepaged performing
off-node allocations in certain situations, but I believe this is a bit
of a special circumstance since, in this situation, there's no way for
khugepaged to perform an allocation on the desired node.

The problem really stems from the way that we determine the allowed
memory nodes in get_page_from_freelist.  When we call down to
cpuset_zone_allowed_softwall, we check current->mems_allowed to
determine what nodes we're allowed on.  In the case of khugepaged, we'll
be making allocations for the mm of the process we're collapsing for,
but we'll be checking the mems_allowed of khugepaged, which can
obviously cause some problems.

Is this particular bug a known issue?  I've been trying to come up with
a simple way to fix the bug, but it's a bit difficult since we no longer
have a way to trace back to the task_struct that we're collapsing for
once we've reached get_page_from_freelist.  I'm wondering if we might
want to make the cpuset check higher up in the call-chain and then pass
that nodemask down instead of sending a NULL nodemask, as we end up
doing in many (most?) situations.  I can think of several problems with
that approach as well, but it's all I've come up with so far.

The obvious workaround is to not isolate khugepaged to a cpuset, but
since we're allowed to do so, I think the thread should probably behave
appropriately when pinned to a cpuset.

Any input on this issue is greatly appreciated.  Thanks, guys!

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
