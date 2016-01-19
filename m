Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 49EF66B0005
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 17:14:35 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id 65so182281756pff.2
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 14:14:35 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id id7si4040691pad.196.2016.01.19.14.14.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jan 2016 14:14:34 -0800 (PST)
Date: Tue, 19 Jan 2016 14:14:30 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] proc: revert /proc/<pid>/maps [stack:TID] annotation
Message-Id: <20160119141430.8ff9c464.akpm@linux-foundation.org>
In-Reply-To: <1453226559-17322-1-git-send-email-hannes@cmpxchg.org>
References: <1453226559-17322-1-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@fb.com>, Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, 19 Jan 2016 13:02:39 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:

> b764375 ("procfs: mark thread stack correctly in proc/<pid>/maps")
> added [stack:TID] annotation to /proc/<pid>/maps. Finding the task of
> a stack VMA requires walking the entire thread list, turning this into
> quadratic behavior: a thousand threads means a thousand stacks, so the
> rendering of /proc/<pid>/maps needs to look at a million threads. The
> cost is not in proportion to the usefulness as described in the patch.
> 
> Drop the [stack:TID] annotation to make /proc/<pid>/maps (and
> /proc/<pid>/numa_maps) usable again for higher thread counts.
> 
> The [stack] annotation inside /proc/<pid>/task/<tid>/maps is retained,
> as identifying the stack VMA there is an O(1) operation.

Four years ago, ouch.

Any thoughts on the obvious back-compatibility concerns?  ie, why did
Siddhesh implement this in the first place?  My bad for not ensuring
that the changelog told us this.

https://lkml.org/lkml/2012/1/14/25 has more info: 

: Memory mmaped by glibc for a thread stack currently shows up as a
: simple anonymous map, which makes it difficult to differentiate between
: memory usage of the thread on stack and other dynamic allocation. 
: Since glibc already uses MAP_STACK to request this mapping, the
: attached patch uses this flag to add additional VM_STACK_FLAGS to the
: resulting vma so that the mapping is treated as a stack and not any
: regular anonymous mapping.  Also, one may use vm_flags to decide if a
: vma is a stack.

But even that doesn't really tell us what the actual *value* of the
patch is to end-users.


I note that this patch is a partial revert - the smaps and numa_maps
parts of b764375 remain in place.  What's up with that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
