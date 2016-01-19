Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id B279F6B0005
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 18:38:29 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id n5so3055082wmn.0
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 15:38:29 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id v130si36577162wme.80.2016.01.19.15.38.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jan 2016 15:38:28 -0800 (PST)
Date: Tue, 19 Jan 2016 18:38:22 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] proc: revert /proc/<pid>/maps [stack:TID] annotation
Message-ID: <20160119233822.GA10788@cmpxchg.org>
References: <1453226559-17322-1-git-send-email-hannes@cmpxchg.org>
 <20160119141430.8ff9c464.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160119141430.8ff9c464.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shaohua Li <shli@fb.com>, Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Jan 19, 2016 at 02:14:30PM -0800, Andrew Morton wrote:
> On Tue, 19 Jan 2016 13:02:39 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > b764375 ("procfs: mark thread stack correctly in proc/<pid>/maps")
> > added [stack:TID] annotation to /proc/<pid>/maps. Finding the task of
> > a stack VMA requires walking the entire thread list, turning this into
> > quadratic behavior: a thousand threads means a thousand stacks, so the
> > rendering of /proc/<pid>/maps needs to look at a million threads. The
> > cost is not in proportion to the usefulness as described in the patch.
> > 
> > Drop the [stack:TID] annotation to make /proc/<pid>/maps (and
> > /proc/<pid>/numa_maps) usable again for higher thread counts.
> > 
> > The [stack] annotation inside /proc/<pid>/task/<tid>/maps is retained,
> > as identifying the stack VMA there is an O(1) operation.
> 
> Four years ago, ouch.
> 
> Any thoughts on the obvious back-compatibility concerns?  ie, why did
> Siddhesh implement this in the first place?  My bad for not ensuring
> that the changelog told us this.

I thought about storing the TID of the thread using the VMA as the
stack directly inside vm_area_struct; maybe using vm_private_data?
However, that's a bit of work and ugliness that I wouldn't want to
commit to until we know that people ended up using this in practice.

> I note that this patch is a partial revert - the smaps and numa_maps
> parts of b764375 remain in place.  What's up with that?

I left the stack annotations in the thread-specific files because that
sounds useful and is cheap enough - we only have to test the vma range
against that thread's stack pointer. The last changelog paragraph says
that for maps, I'll update it to include smaps and numa_maps.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
