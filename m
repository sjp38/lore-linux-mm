Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 42A8C6B0253
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 08:56:07 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id z8so56107783ybh.1
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 05:56:07 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id e16si3731148ybh.287.2016.09.29.05.56.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 05:56:06 -0700 (PDT)
Received: by mail-pa0-x229.google.com with SMTP id dw4so14001175pac.1
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 05:56:06 -0700 (PDT)
Date: Thu, 29 Sep 2016 22:55:44 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: page_waitqueue() considered harmful
Message-ID: <20160929225544.70a23dac@roar.ozlabs.ibm.com>
In-Reply-To: <20160929080130.GJ3318@worktop.controleur.wifipass.org>
References: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
 <20160927073055.GM2794@worktop>
 <20160927085412.GD2838@techsingularity.net>
 <20160929080130.GJ3318@worktop.controleur.wifipass.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

On Thu, 29 Sep 2016 10:01:30 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> On Tue, Sep 27, 2016 at 09:54:12AM +0100, Mel Gorman wrote:
> > On Tue, Sep 27, 2016 at 09:30:55AM +0200, Peter Zijlstra wrote:
> > Simple is relative unless I drastically overcomplicated things and it
> > wouldn't be the first time. 64-bit only side-steps the page flag issue
> > as long as we can live with that.  
> 
> So one problem with the 64bit only pageflags is that they do eat space
> from page-flags-layout, we do try and fit a bunch of other crap in
> there, and at some point that all will not fit anymore and we'll revert
> to worse.
> 
> I've no idea how far away from that we are for distro kernels. I suppose
> they have fairly large NR_NODES and NR_CPUS.

I know it's not fashionable to care about them anymore, but it's sad if
32-bit architectures miss out fundamental optimisations like this because
we're out of page flags. It would also be sad to increase the size of
struct page because we're too lazy to reduce flags. There's some that
might be able to be removed.

PG_reserved - We should have killed this years ago. More users have crept
back in.

PG_mappedtodisk - Rarely used, to slightly shortcut some mapping lookups.
Possible for filesystems to derive this some other way, e.g.,
PG_private == 1 && ->private == NULL, or another filesystem private bit.
We should really kill this before more users spring up and it gets stuck
forever. 

PG_swapcache - can this be replaced with ane of the private bits, I wonder?

PG_uncached - this is PG_arch_2 really, but unfortunately x86 uses both.
Still, that and PG_arch_1 could be removed from most architectures, so
many of the 32-bit ones could use the extra flags.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
