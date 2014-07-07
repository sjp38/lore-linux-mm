Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id D8492900003
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 15:02:22 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fb1so5913608pad.28
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 12:02:22 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id oq10si41721843pac.48.2014.07.07.12.02.20
        for <linux-mm@kvack.org>;
        Mon, 07 Jul 2014 12:02:21 -0700 (PDT)
Message-ID: <53BAEE95.50807@intel.com>
Date: Mon, 07 Jul 2014 12:01:41 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 1/3] mm: introduce fincore()
References: <1404756006-23794-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1404756006-23794-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1404756006-23794-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Rusty Russell <rusty@rustcorp.com.au>, David Miller <davem@davemloft.net>, Andres Freund <andres@2ndquadrant.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>, Kees Cook <kees@outflux.net>

> +/*
> + * You can control how the buffer in userspace is filled with this mode
> + * parameters:

I agree that we don't have any good mechanisms for looking at the page
cache from userspace.  I've hacked some things up using mincore() and
they weren't pretty, so I welcome _something_ like this.

But, is this trying to do too many things at once?  Do we have solid use
cases spelled out for each of these modes?  Have we thought out how they
will be used in practice?

The biggest question for me, though, is whether we want to start
designing these per-page interfaces to consider different page sizes, or
whether we're going to just continue to pretend that the entire world is
4k pages.  Using FINCORE_BMAP on 1GB hugetlbfs files would be a bit
silly, for instance.

> + * - FINCORE_BMAP:
> + *     the page status is returned in a vector of bytes.
> + *     The least significant bit of each byte is 1 if the referenced page
> + *     is in memory, otherwise it is zero.

I know this is consistent with mincore(), but it did always bother me
that mincore() was so sparse.  Seems like it is wasting 7/8 of its bits.

> + * - FINCORE_PGOFF:
> + *     if this flag is set, fincore() doesn't store any information about
> + *     holes. Instead each records per page has the entry of page offset,
> + *     using 8 bytes. This mode is useful if we handle a large file and
> + *     only few pages are on memory.

This bothers me a bit.  How would someone know how sparse file was
before calling this?  If it's not sparse, and they use this, they'll end
up using 8x the memory they would have using FINCORE_BMAP.  If it *is*
sparse, and they use FINCORE_BMAP, they will either waste tons of memory
on buffers, or have to make a ton of calls.

I guess this could also be used to do *searches*, which would let you
search out holes.  Let's say you have a 2TB file.  You could call this
with a buffer size of 1 entry and do searches, say 0->1TB.  If you get
your one entry back, you know it's not completely sparse.

But, that wouldn't work with it as-designed.  The length of the buffer
and the range of the file being checked are coupled together, so you
can't say:

	vec = malloc(sizeof(long));
	fincore(fd, 0, 1TB, FINCORE_PGOFF, vec, extra);

without overflowing vec.

Is it really right to say this is going to be 8 bytes?  Would we want it
to share types with something else, like be an loff_t?

> + * - FINCORE_PFN:
> + *     stores pfn, using 8 bytes.

These are all an unprivileged operations from what I can tell.  I know
we're going to a lot of trouble to hide kernel addresses from being seen
in userspace.  This seems like it would be undesirable for the folks
that care about not leaking kernel addresses, especially for
unprivileged users.

This would essentially tell userspace where in the kernel's address
space some user-controlled data will be.

> + * We can use multiple flags among the flags in FINCORE_LONGENTRY_MASK.
> + * For example, when the mode is FINCORE_PFN|FINCORE_PAGEFLAGS, the per-page
> + * information is stored like this:

Instead of specifying the ordering in the manpages alone, would it be
smarter to just say that the ordering of the items is dependent on the
ordering of the flags?  In other words if FINCORE_PFN <
FINCORE_PAGEFLAGS, then its field comes first?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
