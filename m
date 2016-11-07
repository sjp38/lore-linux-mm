Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1CF2B6B0069
	for <linux-mm@kvack.org>; Sun,  6 Nov 2016 22:04:44 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id l66so42800482pfl.7
        for <linux-mm@kvack.org>; Sun, 06 Nov 2016 19:04:44 -0800 (PST)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id s65si29018775pgb.37.2016.11.06.19.04.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 06 Nov 2016 19:04:43 -0800 (PST)
Received: by mail-pf0-x244.google.com with SMTP id 144so6393588pfv.0
        for <linux-mm@kvack.org>; Sun, 06 Nov 2016 19:04:43 -0800 (PST)
Date: Mon, 7 Nov 2016 14:04:29 +1100
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 2/2] mm: add PageWaiters bit to indicate waitqueue
 should be checked
Message-ID: <20161107140429.15832544@roar.ozlabs.ibm.com>
In-Reply-To: <CA+55aFxoT82RocOCZ9+k7_NZ+KZNtCQrwzNd=reB0n03xDj4-A@mail.gmail.com>
References: <20161102070346.12489-1-npiggin@gmail.com>
	<20161102070346.12489-3-npiggin@gmail.com>
	<CA+55aFxhxfevU1uKwHmPheoU7co4zxxcri+AiTpKz=1_Nd0_ig@mail.gmail.com>
	<20161103144650.70c46063@roar.ozlabs.ibm.com>
	<CA+55aFyzf8r2q-HLfADcz74H-My_GY-z15yLrwH-KUqd486Q0A@mail.gmail.com>
	<20161104134049.6c7d394b@roar.ozlabs.ibm.com>
	<20161104182942.47c4d544@roar.ozlabs.ibm.com>
	<CA+55aFxoT82RocOCZ9+k7_NZ+KZNtCQrwzNd=reB0n03xDj4-A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Fri, 4 Nov 2016 08:59:15 -0700
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Fri, Nov 4, 2016 at 12:29 AM, Nicholas Piggin <npiggin@gmail.com> wrote:
> > Oh, okay, the zone lookup. Well I am of the impression that most of the
> > cache misses are coming from the waitqueue hash table itself.  
> 
> No.
> 
> Nick, stop this idiocy.
> 
> NUMBERS, Nick. NUMBERS.
> 
> I posted numbers in "page_waitqueue() considered harmful" on linux-mm.

No I understand that, and am in the process of getting numbers. I wasn't
suggesting re-adding it based on "impression", I was musing over your idea
that the zone lookup hurts small systems. I'm trying to find why that is
and measure it! It's no good me finding a vast NUMA system to show some
improvement on if it ends up hurting 1-2 socket systems, is it?

But I can't see 3 cache misses there, and even the loads I can't see how
they match your post. We have:
 page->flags
   pglist_data->node_zones[x].wait_table
     wait_table[x].task_list

Page flags is in cache. wait_table is a dependent load but I'd have
thought it would cache relatively well. About as well as bit_wait_table
pointer load, but even if you count that as a miss, it's 2 cache misses.

Also keep in mind this PG_waiters patch actually reintroduces the
load-after-store stall on x86 because the PG_waiters bit is tested after the
unlock. On my skylake it doesn't seem to matter about the operand size
mismatch because it isn't forwarding the atomic op to the load anyway (which
makes sense, because atomic ops cause a store queue drain). So if we have
this patch, there is no additional stall on the page_zone load there.

> And quite frankly, before _you_ start posting numbers, that zone crap
> IS NEVER COMING BACK.
> 
> What's so hard about this concept? We don't add crazy complexity
> without numbers. Numbers that I bet you will not be able to provide,
> because quiet frankly, even in your handwavy "what about lots of
> concurrent IO from hundreds of threads" situation, that wait-queue
> will NOT BE NOTICEABLE.

That particular handwaving was *not* in the context of the zone waitqueues,
it was in context of PG_waiters bit slowpath with waitqueue hash collisions.
Different issue, and per-zone waitqueues don't do anything to solve it.

> 
> So no "impressions". No "what abouts". No "threaded IO" excuses. The
> _only_ thing that matters is numbers. If you don't have them, don't
> bother talking about that zone patch.

I agree with you, and am trying to reproduce your numbers at the moment.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
