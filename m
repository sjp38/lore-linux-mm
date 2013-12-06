Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id 27C6D6B0039
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 07:21:51 -0500 (EST)
Received: by mail-qc0-f171.google.com with SMTP id c9so396028qcz.30
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 04:21:50 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id e10si420601qas.21.2013.12.06.04.21.49
        for <linux-mm@kvack.org>;
        Fri, 06 Dec 2013 04:21:50 -0800 (PST)
Date: Fri, 6 Dec 2013 10:21:43 -0200
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [QUESTION] balloon page isolation needs LRU lock?
Message-ID: <20131206122142.GC26883@localhost.localdomain>
References: <20131206085331.GA24706@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131206085331.GA24706@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 06, 2013 at 05:53:31PM +0900, Joonsoo Kim wrote:
> Hello, Rafael.
> 
> I looked at some compaction code and found that some oddity about
> balloon compaction. In isolate_migratepages_range(), if we meet
> !PageLRU(), we check whether this page is for balloon compaction.
> In this case, code needs locked. Is the lock really needed? I can't find
> any relationship between balloon compaction and LRU lock.
> 
> Second question is that in above case if we don't hold a lock, we
> skip this page. I guess that if we meet balloon page repeatedly, there
> is no change to run isolation. Am I missing?
> 
> Please let me know what I am missing.
> 
> Thanks in advance.

Howdy Joonsoo, thanks for your question.

The major reason I left the 'locked' case in place when isolating balloon pages
was to keep consistency with the other isolation cases. Among all page types we
isolate for compaction balloon pages are an exception as, you noticed, they're
not on LRU lists. So, we (specially) fake balloon pages as LRU to isolate/compact them, 
withouth having to sort to drastic surgeries into kernel code to implement
exception cases for isolating/compacting balloon pages.

As others pages we isolate for compaction are isolated while holding the
zone->lru_lock, I left the same condition placed for balloon pages as a
safeguard for consistency. If we hit a balloon page while scanning page blocks
and we do not have the lru lock held, then the balloon page will be treated 
by the scanning mechanism just as what it is: a !PageLRU() case, and life will
go on as described by the algorithm.

OTOH, there's no direct relationship between the balloon page and the LRU lock,
other than this consistency one I aforementioned. I've never seen any major
trouble on letting the lock requirement in place during my tests on workloads
that mix balloon pages and compaction. However, if you're seeing any trouble and
that lru lock requirement is acting as an overkill or playing a bad role on your
tests, you can get rid of it easily, IMHO.

Regards,
-- Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
