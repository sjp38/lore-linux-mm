Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9F47A28024E
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 12:52:27 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c84so38860755pfj.2
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 09:52:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id z5si3417090pae.151.2016.09.27.09.52.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Sep 2016 09:52:26 -0700 (PDT)
Date: Tue, 27 Sep 2016 18:52:21 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: page_waitqueue() considered harmful
Message-ID: <20160927165221.GP5016@twins.programming.kicks-ass.net>
References: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
 <20160927083104.GC2838@techsingularity.net>
 <20160928005318.2f474a70@roar.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160928005318.2f474a70@roar.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Will Deacon <will.deacon@arm.com>

On Wed, Sep 28, 2016 at 12:53:18AM +1000, Nicholas Piggin wrote:
> The more interesting is the ability to avoid the barrier between fastpath
> clearing a bit and testing for waiters.
> 
> unlock():                        lock() (slowpath):
> clear_bit(PG_locked)             set_bit(PG_waiter)
> test_bit(PG_waiter)              test_bit(PG_locked)
> 
> If this was memory ops to different words, it would require smp_mb each
> side.. Being the same word, can we avoid them? 

Ah, that is the reason I put that smp_mb__after_atomic() there. You have
a cute point on them being to the same word though. Need to think about
that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
