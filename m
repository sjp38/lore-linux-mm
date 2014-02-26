Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8B9406B0073
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 03:50:57 -0500 (EST)
Received: by mail-ie0-f175.google.com with SMTP id at1so408176iec.34
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 00:50:57 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id x4si520787icy.0.2014.02.26.00.50.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Feb 2014 00:50:56 -0800 (PST)
Date: Wed, 26 Feb 2014 09:50:48 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2] mm: per-thread vma caching
Message-ID: <20140226085048.GE18404@twins.programming.kicks-ass.net>
References: <1393352206.2577.36.camel@buesod1.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1393352206.2577.36.camel@buesod1.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Feb 25, 2014 at 10:16:46AM -0800, Davidlohr Bueso wrote:
> +void vmacache_invalidate_all(void)
> +{
> +	struct task_struct *g, *p;
> +
> +	rcu_read_lock();
> +	for_each_process_thread(g, p) {
> +		/*
> +		 * Only flush the vmacache pointers as the
> +		 * mm seqnum is already set and curr's will
> +		 * be set upon invalidation when the next
> +		 * lookup is done.
> +		 */
> +		memset(p->vmacache, 0, sizeof(p->vmacache));
> +	}
> +	rcu_read_unlock();
> +}

With all the things being said on this particular piece already; I
wanted to add that the iteration there is incomplete; we can clone()
using CLONE_VM without using CLONE_THREAD.

Its not common, but it can be done. In that case the above iteration
will miss a task that shares the same mm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
