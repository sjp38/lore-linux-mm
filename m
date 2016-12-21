Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8BB146B03CF
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 13:40:50 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id a190so302681739pgc.0
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 10:40:50 -0800 (PST)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id p26si27593990pfk.183.2016.12.21.10.40.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Dec 2016 10:40:49 -0800 (PST)
Received: by mail-pf0-x241.google.com with SMTP id 127so1279534pfg.0
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 10:40:49 -0800 (PST)
Date: Thu, 22 Dec 2016 04:40:35 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [RFC][PATCH] make global bitlock waitqueues per-node
Message-ID: <20161222044035.164ae188@roar.ozlabs.ibm.com>
In-Reply-To: <CA+55aFx83JS4ZcZUmQLL+e1gzTQ-y_0n_xWtg=T8qtJ0_cA5GA@mail.gmail.com>
References: <20161219225826.F8CB356F@viggo.jf.intel.com>
	<20161221223056.17c37dd6@roar.ozlabs.ibm.com>
	<CA+55aFx83JS4ZcZUmQLL+e1gzTQ-y_0n_xWtg=T8qtJ0_cA5GA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andreas Gruenbacher <agruenba@redhat.com>, Bob Peterson <rpeterso@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Andrew Lutomirski <luto@kernel.org>, Steven Whitehouse <swhiteho@redhat.com>

On Wed, 21 Dec 2016 10:12:36 -0800
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Wed, Dec 21, 2016 at 4:30 AM, Nicholas Piggin <npiggin@gmail.com> wrote:
> >
> > I've been doing a bit of testing, and I don't know why you're seeing
> > this.
> >
> > I don't think I've been able to trigger any actual page lock contention
> > so nothing gets put on the waitqueue to really bounce cache lines around
> > that I can see.  
> 
> The "test is the waitqueue is empty" is going to cause cache misses
> even if there is no contention.
> 
> In fact, that's why I want the contention bit in the struct page - not
> because of any NUMA issues, but simply due to cache misses.
> 
> And yes, with no contention the bit waiting should hopefully be able
> to cache things shared - which should make the bouncing much less -
> but there's going to be a shitload of false sharing with any actual
> IO, so you will get bouncing due to that.

Well that's what I'm actually interested in, but I could not get it to
do much bouncing at all. There was a significant amount of writes going
through when having the backing store files on writeback filesystem,
but even that was not really triggering a lot of actual waiters.

Not that I don't believe it could happen, and Dave's system is a lot
bigger and faster and more NUMA than the one I was testing on. I'm
just curious.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
