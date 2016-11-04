Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id CCDCB280260
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 03:29:57 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id v84so92291435oie.0
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 00:29:57 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id s75si10234347ios.102.2016.11.04.00.29.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Nov 2016 00:29:55 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id i88so7115393pfk.2
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 00:29:55 -0700 (PDT)
Date: Fri, 4 Nov 2016 18:29:42 +1100
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 2/2] mm: add PageWaiters bit to indicate waitqueue
 should be checked
Message-ID: <20161104182942.47c4d544@roar.ozlabs.ibm.com>
In-Reply-To: <20161104134049.6c7d394b@roar.ozlabs.ibm.com>
References: <20161102070346.12489-1-npiggin@gmail.com>
	<20161102070346.12489-3-npiggin@gmail.com>
	<CA+55aFxhxfevU1uKwHmPheoU7co4zxxcri+AiTpKz=1_Nd0_ig@mail.gmail.com>
	<20161103144650.70c46063@roar.ozlabs.ibm.com>
	<CA+55aFyzf8r2q-HLfADcz74H-My_GY-z15yLrwH-KUqd486Q0A@mail.gmail.com>
	<20161104134049.6c7d394b@roar.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Fri, 4 Nov 2016 13:40:49 +1100
Nicholas Piggin <npiggin@gmail.com> wrote:

> On Thu, 3 Nov 2016 08:49:14 -0700
> Linus Torvalds <torvalds@linux-foundation.org> wrote:
> 
> > On Wed, Nov 2, 2016 at 8:46 PM, Nicholas Piggin <npiggin@gmail.com> wrote:  
> > >
> > > If you don't have that, then a long-waiting waiter for some
> > > unrelated page can prevent other pages from getting back to
> > > the fastpath.
> > >
> > > Contention bit is already explicitly not precise with this patch
> > > (false positive possible), but in general the next wakeup will
> > > clean it up. Without page_match, that's not always possible.    
> > 
> > Do we care?
> > 
> > The point is, it's rare, and if there are no numbers to say that it's
> > an issue, we shouldn't create the complication. Numbers talk,
> > handwaving "this might be an issue" walks.  
> 
> Well you could have hundreds of waiters on pages with highly threaded
> IO (say, a file server), which will cause collisions in the hash table.
> I can just try to force that to happen and show up that 2.2% again.
> 
> Actaully it would be more than 2.2% with my patch as is, because it no
> longer does an unlocked waitqueue_active() check if the waiters bit was
> set (because with my approach the lock will always be required if only
> to clear the bit after checking the waitqueue). If we avoid clearing
> dangling bity there, we'll then have to reintroduce that test.
> 
> > That said, at least it isn't a big complexity that will hurt, and it's
> > very localized.  
> 
> I thought so :)
> 
> >   
> > >> Also, it would be lovely to get numbers against the plain 4.8
> > >> situation with the per-zone waitqueues. Maybe that used to help your
> > >> workload, so the 2.2% improvement might be partly due to me breaking
> > >> performance on your machine.    
> > >
> > > Oh yeah that'll hurt a bit. The hash will get spread over non-local
> > > nodes now. I think it was only a 2 socket system, but remote memory
> > > still takes a latency hit. Hmm, I think keeping the zone waitqueue
> > > just for pages would be reasonable, because they're a special case?    
> > 
> > HELL NO!
> > 
> > Christ. That zone crap may have helped some very few NUMA machines,
> > but it *hurt* normal machines.  
> 
> Oh I missed why they hurt small systems -- where did you see that
> slowdown? I agree that's a serious concern. I'll go back and read the
> thread again.

Oh, okay, the zone lookup. Well I am of the impression that most of the
cache misses are coming from the waitqueue hash table itself. On a small
system (or big system doing local operations), the zone lookup I thought
should be quite well cached. The zone waitqueue hashes were like 96KB each
in size, so a random access is almost certainly an L1 miss and probably L2
miss as well.

Anyway I'm still going to try to get numbers for this, but I wonder if
you saw the zone causing a lot of misses, or if it was the waitqueue?

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
