Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id D5C6A6B0005
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 18:30:31 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id 123so111850674wmz.0
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 15:30:31 -0800 (PST)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id l141si36550718wmd.81.2016.01.19.15.30.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jan 2016 15:30:30 -0800 (PST)
Received: by mail-wm0-x230.google.com with SMTP id 123so111850386wmz.0
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 15:30:30 -0800 (PST)
Date: Wed, 20 Jan 2016 01:30:28 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] proc: revert /proc/<pid>/maps [stack:TID] annotation
Message-ID: <20160119233028.GA22867@node.shutemov.name>
References: <1453226559-17322-1-git-send-email-hannes@cmpxchg.org>
 <20160119141430.8ff9c464.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160119141430.8ff9c464.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@fb.com>, Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

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
> 
> https://lkml.org/lkml/2012/1/14/25 has more info: 
> 
> : Memory mmaped by glibc for a thread stack currently shows up as a
> : simple anonymous map, which makes it difficult to differentiate between
> : memory usage of the thread on stack and other dynamic allocation. 
> : Since glibc already uses MAP_STACK to request this mapping, the
> : attached patch uses this flag to add additional VM_STACK_FLAGS to the
> : resulting vma so that the mapping is treated as a stack and not any
> : regular anonymous mapping.  Also, one may use vm_flags to decide if a
> : vma is a stack.
> 
> But even that doesn't really tell us what the actual *value* of the
> patch is to end-users.

I doubt it can be very useful as it's unreliable: if two stacks are
allocated end-to-end (which is not good idea, but still) it can only
report [stack:XXX] for the first one as they are merged into one VMA.
Any other anon VMA merged with the stack will be also claimed as stack,
which is not always correct.

I think report the VMA as anon is the best we can know about it,
everything else just rather expensive guesses.

> I note that this patch is a partial revert - the smaps and numa_maps
> parts of b764375 remain in place.  What's up with that?
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
