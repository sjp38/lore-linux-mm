Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 934206B000C
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 07:56:59 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id y19so1314783pgv.18
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 04:56:59 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z1si897798pgn.564.2018.03.14.04.56.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Mar 2018 04:56:58 -0700 (PDT)
Date: Wed, 14 Mar 2018 04:56:53 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH v19 0/8] mm: security: ro protection for dynamic data
Message-ID: <20180314115653.GD29631@bombadil.infradead.org>
References: <20180313214554.28521-1-igor.stoppa@huawei.com>
 <a9bfc57f-1591-21b6-1676-b60341a2fadd@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a9bfc57f-1591-21b6-1676-b60341a2fadd@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: keescook@chromium.org, david@fromorbit.com, rppt@linux.vnet.ibm.com, mhocko@kernel.org, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Wed, Mar 14, 2018 at 01:21:54PM +0200, Igor Stoppa wrote:
> > * @Kees Cook proposed to turn the self testing into modules.
> >   My answer was that the functionality is intentionally tested very early
> >   in the boot phase, to prevent unexplainable errors, should the feature
> >   really fail.
> 
> This could be workable, if it's acceptable that the early testing is
> performed only when the module is compiled in.
> I do not expect the module-based testing to bring much value, but it
> doesn't do harm. Is this acceptable?

Something I've been doing recently is building tests in both userspace and
kernel space.  Here's an example:
http://git.infradead.org/users/willy/linux-dax.git/commitdiff/717f2aa1d4040f65966bb9dab64035962576b0f9

Essentially, tools/ contains a reasonably good set of functions which
emulate kernel functions.  So you write your test suite as a kernel module
and then build it in userspace as well.

> > * @Matthew Wilcox proposed to use a different mechanism for the genalloc
> >   bitmap: 2 bitmaps, one for occupation and one for start.
> >   And possibly use an rbtree for the starts.
> >   My answer was that this solution is less optimized, because it scatters
> >   the data of one allocation across multiple words/pages, plus is not
> >   a transaction anymore. And the particular distribution of sizes of
> >   allocation is likely to eat up much more memory than the bitmap.
> 
> I think I can describe a scenario where the split bitmaps would not work
> (based on my understanding of the proposal), but I would appreciate a
> review. Here it is:

You misread my proposal.  I did not suggest storing the 'start', but the
'end'.

> * One allocation (let's call it allocation A) is already present in both
> bitmaps:
>   - its units of allocation are marked in the "space" bitmap
>   - its starting bit is marked in the "starts" bitmap
> 
> * Another allocation (let's call it allocation B) is undergoing:
>   - some of its units of allocation (starting from the beginning) are
>     marked in the "space" bitmap
>   - the starting bit is *not* yet marked in the "starts" bitmap
> 
> * B occupies the space immediately after A
> 
> * While B is being written, A is freed
> 
> * Having to determine the length of A, the "space" bitmap will be
>   searched, then the "starts" bitmap
> 
> 
> The space initially allocated for B will be wrongly accounted for A,
> because there is no empty gap in-between and the beginning of B is not
> yet marked.
> 
> The implementation which interleaves "space" and "start" does not suffer
> from this sort of races, because the alteration of the interleaved
> bitmaps is atomic.

This would be a bug in the allocator implementation.  Obviously it has to
maintain the integrity of its own data structures.

> Does this justification for the use of interleaved bitmaps (iow the
> current implementation) make sense?

I think you're making a mistake by basing the pmalloc allocator on
genalloc.  The page_frag allocator seems like a much better place to
start than genalloc.  It has a significantly lower overhead and is
much more suited to the kind of probably-identical-lifespan that the
pmalloc API is going to persuade its users to have.
