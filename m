Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 711A76B002C
	for <linux-mm@kvack.org>; Sun, 16 Oct 2011 05:39:15 -0400 (EDT)
Received: by bkbzu5 with SMTP id zu5so5404487bkb.14
        for <linux-mm@kvack.org>; Sun, 16 Oct 2011 02:39:13 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 2/9] mm: alloc_contig_freed_pages() added
References: <1317909290-29832-1-git-send-email-m.szyprowski@samsung.com>
 <1317909290-29832-3-git-send-email-m.szyprowski@samsung.com>
 <20111014162933.d8fead58.akpm@linux-foundation.org>
 <op.v3fpwyxc3l0zgt@mpn-glaptop>
 <20111016013116.53032449.akpm@linux-foundation.org>
Date: Sun, 16 Oct 2011 11:39:10 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v3fufkaw3l0zgt@mpn-glaptop>
In-Reply-To: <20111016013116.53032449.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel
 Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd
 Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan
 Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

> On Sun, 16 Oct 2011 10:01:36 +0200 "Michal Nazarewicz" wrote:
>> Still, as I think of it now, maybe alloc_contig_free_range() would be
>> better?

On Sun, 16 Oct 2011 10:31:16 +0200, Andrew Morton wrote:
> Nope.  Of *course* the pages were free.  Otherwise we couldn't
> (re)allocate them.  I still think the "free" part is redundant.

Makes sense.

> What could be improved is the "alloc" part.  This really isn't an
> allocation operation.  The pages are being removed from buddy then
> moved into the free arena of a different memory manager from where they
> will _later_ be "allocated".

Not quite.  After alloc_contig_range() returns, the pages are passed with
no further processing to the caller.  Ie. the area is not later split into
several parts nor kept in CMA's pool unused.

alloc_contig_freed_pages() is a little different since it must be called on
a buddy page boundary and may return more then requested (because of the way
buddy system merges buddies) so there is a little processing after it returns
(namely freeing of the excess pages).

> So we should move away from the alloc/free naming altogether for this
> operation and think up new terms.  How about "claim" and "release"?
> claim_contig_pages, claim_contig_range, release_contig_pages, etc?
> Or we could use take/return.

Personally, I'm not convinced about changing the names of alloc_contig_range()
and free_contig_pages() but I see merit in changing alloc_contig_freed_pages()
to something else.

Since at the moment, it's used only by alloc_contig_range(), I'd lean
towards removing it from page-isolation.h, marking as static and renaming
to __alloc_contig_range().

> Also, if we have no expectation that anything apart from CMA will use
> these interfaces (?), the names could/should be prefixed with "cma_".

In Kamezawa's original patchset, he used those for a bit different
approach (IIRC, Kamezawa's patchset introduced a function that scanned memory
and tried to allocate contiguous memory where it could), so I can imagine that
someone will make use of those functions.  It may be used in any situation
where a range of pages is either free (ie. in buddy system) or movable and
one wants to allocate them for some reason.

-- 
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=./ `o
..o | Computer Science,  Michal "mina86" Nazarewicz    (o o)
ooo +--<mina86@mina86.com>---<mina86@jabber.org>---ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
