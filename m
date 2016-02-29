Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 854256B0009
	for <linux-mm@kvack.org>; Sun, 28 Feb 2016 19:02:04 -0500 (EST)
Received: by mail-ob0-f182.google.com with SMTP id ts10so120958983obc.1
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 16:02:04 -0800 (PST)
Received: from mail-oi0-x235.google.com (mail-oi0-x235.google.com. [2607:f8b0:4003:c06::235])
        by mx.google.com with ESMTPS id cm10si19334429oec.84.2016.02.28.16.02.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Feb 2016 16:02:03 -0800 (PST)
Received: by mail-oi0-x235.google.com with SMTP id c203so2304755oia.2
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 16:02:03 -0800 (PST)
Date: Sun, 28 Feb 2016 16:02:00 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC PATCH] proc: do not include shmem and driver pages in
 /proc/meminfo::Cached
In-Reply-To: <CALYGNiMHAtaZfGovYeud65Eix8v0OSWSx8F=4K+pqF6akQah0A@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1602281558050.2997@eggly.anvils>
References: <1455827801-13082-1-git-send-email-hannes@cmpxchg.org> <alpine.LSU.2.11.1602181422550.2289@eggly.anvils> <CALYGNiMHAtaZfGovYeud65Eix8v0OSWSx8F=4K+pqF6akQah0A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kernel-team@fb.com

On Fri, 19 Feb 2016, Konstantin Khlebnikov wrote:
> On Fri, Feb 19, 2016 at 1:57 AM, Hugh Dickins <hughd@google.com> wrote:
> > On Thu, 18 Feb 2016, Johannes Weiner wrote:
> >
> >> Even before we added MemAvailable, users knew that page cache is
> >> easily convertible to free memory on pressure, and estimated their
> >> "available" memory by looking at the sum of MemFree, Cached, Buffers.
> >> However, "Cached" is calculated using NR_FILE_PAGES, which includes
> >> shmem and random driver pages inserted into the page tables; neither
> >> of which are easily reclaimable, or reclaimable at all. Reclaiming
> >> shmem requires swapping, which is slow. And unlike page cache, which
> >> has fairly conservative dirty limits, all of shmem needs to be written
> >> out before becoming evictable. Without swap, shmem is not evictable at
> >> all. And driver pages certainly never are.
> >>
> >> Calling these pages "Cached" is misleading and has resulted in broken
> >> formulas in userspace. They misrepresent the memory situation and
> >> cause either waste or unexpected OOM kills. With 64-bit and per-cpu
> >> memory we are way past the point where the relationship between
> >> virtual and physical memory is meaningful and users can rely on
> >> overcommit protection. OOM kills can not be avoided without wasting
> >> enormous amounts of memory this way. This shifts the management burden
> >> toward userspace, toward applications monitoring their environment and
> >> adjusting their operations. And so where statistics like /proc/meminfo
> >> used to be more informational, we have more and more software relying
> >> on them to make automated decisions based on utilization.
> >>
> >> But if userspace is supposed to take over responsibility, it needs a
> >> clear and accurate kernel interface to base its judgement on. And one
> >> of the requirements is certainly that memory consumers with wildly
> >> different reclaimability are not conflated. Adding MemAvailable is a
> >> good step in that direction, but there is software like Sigar[1] in
> >> circulation that might not get updated anytime soon. And even then,
> >> new users will continue to go for the intuitive interpretation of the
> >> Cached item. We can't blame them. There are years of tradition behind
> >> it, starting with the way free(1) and vmstat(8) have always reported
> >> free, buffers, cached. And try as we might, using "Cached" for
> >> unevictable memory is never going to be obvious.
> >>
> >> The semantics of Cached including shmem and kernel pages have been
> >> this way forever, dictated by the single-LRU implementation rather
> >> than optimal semantics. So it's an uncomfortable proposal to change it
> >> now. But what other way to fix this for existing users? What other way
> >> to make the interface more intuitive for future users? And what could
> >> break by removing it now? I guess somebody who already subtracts Shmem
> >> from Cached.
> >>
> >> What are your thoughts on this?
> >
> > My thoughts are NAK.  A misleading stat is not so bad as a
> > misleading stat whose meaning we change in some random kernel.
> >
> > By all means improve Documentation/filesystems/proc.txt on Cached.
> > By all means promote Active(file)+Inactive(file)-Buffers as often a
> > better measure (though Buffers itself is obscure to me - is it intended
> > usually to approximate resident FS metadata?).  By all means work on
> > /proc/meminfo-v2 (though that may entail dispiritingly long discussions).
> >
> > We have to assume that Cached has been useful to some people, and that
> > they've learnt to subtract Shmem from it, if slow or no swap concerns them.
> >
> > Added Konstantin to Cc: he's had valuable experience of people learning
> > to adapt to the numbers that we put out.
> >
> 
> I think everything will ok. Subtraction of shmem isn't widespread practice,
> more like secret knowledge. This wasn't documented and people who use
> this should be aware that this might stop working at any time. So, ACK.

I'll take your ACK as cancelling my NAK then; but I do still remain
uncomfortable with such a change - I think "we" would do much better
to add fields with the necessary missing information to /proc/meminfo,
than mess around with the meaning of existing fields.  But if I'm the
only one who thinks that way, ignore me.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
