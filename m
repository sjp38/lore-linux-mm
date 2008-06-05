From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 0/7] speculative page references, lockless pagecache, lockless gup
Date: Thu, 5 Jun 2008 21:53:11 +1000
References: <20080605094300.295184000@nick.local0.net>
In-Reply-To: <20080605094300.295184000@nick.local0.net>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200806052153.11841.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org
List-ID: <linux-mm.kvack.org>

On Thursday 05 June 2008 19:43, npiggin@suse.de wrote:
> Hi,
>
> I've decided to submit the speculative page references patch to get merged.
> I think I've now got enough reasons to get it merged. Well... I always
> thought I did, I just didn't think anyone else thought I did. If you know
> what I mean.
>
> cc'ing the powerpc guys specifically because everyone else who probably
> cares should be on linux-mm...
>
> So speculative page references are required to support lockless pagecache
> and lockless get_user_pages (on architectures that can't use the x86
> trick). Other uses for speculative page references could also pop up, it is
> a pretty useful concept. Doesn't need to be pagecache pages either.
>
> Anyway,
>
> lockless pagecache:
> - speeds up single threaded pagecache lookup operations significantly, by
>   avoiding atomic operations, memory barriers, and interrupts-off sections.
>   I just measured again on a few CPUs I have lying around here, and the
>   speedup is over 2x reduction in cycles on them all, closer to 3x in some
>   cases.
>
>    find_get_page takes:
>                 ppc970 (g5)     K10             P4 Nocona       Core2
>     vanilla     275 (cycles)    85              315             143
>     lockless    125             40              127             61
>
> - speeds up single threaded pagecache modification operations, by using
>   regular spinlocks rather than rwlocks and avoiding an atomic operation
>   on x86 for one. Also, most real paths which involve pagecache
> modification also involve pagecache lookups, so it is hard not to get a net
> speedup.
>
> - solves the rwlock starvation problem for pagecache operations. This is
>   being noticed on big SGI systems, but theoretically could happen on
>   relatively small systems (dozens of CPUs) due to the really nasty
>   writer starvation problem of rwlocks -- not even hardware fairness can
>   solve that.
>
> - improves pagecache scalability to operations on a single file. I
>   demonstrated page faults to a single file were improved in throughput
>   by 250x on a 64-way Altix several years ago. We now have systems with
>   thousands of CPUs in them.

Oh that's actually anothr thing I remember now that I posted the scalable
vmap code...

The lock I ended up hitting next in the XFS large directory workload that
improved so much with the vmap patches was tree_lock of the buffer cache.
So lockless pagecache gave a reasonable improvement there too IIRC :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
