Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id E97A76B0038
	for <linux-mm@kvack.org>; Fri, 10 Oct 2014 05:20:59 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so1407923pab.2
        for <linux-mm@kvack.org>; Fri, 10 Oct 2014 02:20:59 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id fs3si2988343pbb.213.2014.10.10.02.20.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Oct 2014 02:20:58 -0700 (PDT)
Date: Fri, 10 Oct 2014 11:20:52 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [BUG] mm, thp: khugepaged can't allocate on requested node when
 confined to a cpuset
Message-ID: <20141010092052.GU4750@worktop.programming.kicks-ass.net>
References: <20141008191050.GK3778@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141008191050.GK3778@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Bob Liu <lliubbo@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On Wed, Oct 08, 2014 at 02:10:50PM -0500, Alex Thorlton wrote:

> Is this particular bug a known issue?

Its not unexpected for me.

> I've been trying to come up with
> a simple way to fix the bug, but it's a bit difficult since we no longer
> have a way to trace back to the task_struct that we're collapsing for
> once we've reached get_page_from_freelist.  I'm wondering if we might
> want to make the cpuset check higher up in the call-chain and then pass
> that nodemask down instead of sending a NULL nodemask, as we end up
> doing in many (most?) situations.  I can think of several problems with
> that approach as well, but it's all I've come up with so far.
> 
> The obvious workaround is to not isolate khugepaged to a cpuset, but
> since we're allowed to do so, I think the thread should probably behave
> appropriately when pinned to a cpuset.
> 
> Any input on this issue is greatly appreciated.  Thanks, guys!

So for the numa thing we do everything from the affected tasks context.
There was a lot of arguments early on that that could never really work,
but here we are.

Should we convert khugepaged to the same? Drive the whole thing from
task_work? That would make this issue naturally go away.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
