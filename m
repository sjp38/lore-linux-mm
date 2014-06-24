Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id E8A8E6B0037
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 11:24:35 -0400 (EDT)
Received: by mail-we0-f174.google.com with SMTP id u57so579515wes.33
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 08:24:35 -0700 (PDT)
Received: from mail-wg0-x229.google.com (mail-wg0-x229.google.com [2a00:1450:400c:c00::229])
        by mx.google.com with ESMTPS id dr2si1652933wid.14.2014.06.24.08.24.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 24 Jun 2014 08:24:34 -0700 (PDT)
Received: by mail-wg0-f41.google.com with SMTP id a1so568591wgh.24
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 08:24:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140623141925.47507153d49f22ee5cca62e1@linux-foundation.org>
References: <1400958369-3588-1-git-send-email-ddstreet@ieee.org>
 <1401747586-11861-1-git-send-email-ddstreet@ieee.org> <1401747586-11861-2-git-send-email-ddstreet@ieee.org>
 <20140623141925.47507153d49f22ee5cca62e1@linux-foundation.org>
From: Dan Streetman <ddstreet@ieee.org>
Date: Tue, 24 Jun 2014 11:24:12 -0400
Message-ID: <CALZtONA59cwZYN+UHA8bPj-N3LgorZTbfJHX-OQAUpABpstSKw@mail.gmail.com>
Subject: Re: [PATCHv2 1/6] mm/zbud: zbud_alloc() minor param change
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>, Nitin Gupta <ngupta@vflare.org>, Bob Liu <bob.liu@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Mon, Jun 23, 2014 at 5:19 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Mon,  2 Jun 2014 18:19:41 -0400 Dan Streetman <ddstreet@ieee.org> wrote:
>
>> Change zbud to store gfp_t flags passed at pool creation to use for
>> each alloc; this allows the api to be closer to the existing zsmalloc
>> interface, and the only current zbud user (zswap) uses the same gfp
>> flags for all allocs.  Update zswap to use changed interface.
>
> This would appear to be a step backwards.  There's nothing wrong with
> requiring all callers to pass in a gfp_t and removing this option makes
> the API less usable.
>
> IMO the patch needs much better justification, or dropping.

Well, since zpool can be backed by either zsmalloc or zbud, those 2
apis have to be consistent, and currently zbud does use a per-malloc
gfp_t param while zsmalloc doesn't.  Does it make more sense to add a
gfp_t param to zsmalloc's alloc function?


I wonder though if allowing the caller to pass a gfp_t for each alloc
really does make sense, though.  Any memory alloc'ed isn't actually
controllable by the caller, and in fact it's currently impossible for
the caller to free memory alloc'ed by the backing pool - the caller
can invalidate specific handles, but that doesn't guarantee the memory
alloc'ed for that handle will then be freed - it could remain in use
with some other handle(s).  Additionally, there's no guarantee that
when the user creates a new handle, and new memory will be allocated -
a previous available handle could be used.

So I guess what I'm suggesting is that because 1) there is no
guarantee that a call to zpool_malloc() will actually call kmalloc()
with the provided gfp_t; previously kmalloc'ed memory with a different
gfp_t could be (and probably in many cases will be) used, and 2) the
caller has no way to free any memory kmalloc'ed with specific gfp_t
(so for example, using GFP_ATOMIC would be a bad idea, since the
caller couldn't then free that memory directly), it makes more sense
to me to keep all allocations in the pool using the same gfp_t flags.
If there was a need to be able to create pool handles using different
gfp_t flags, then it would be probably more effective to create
multiple pools, each one with the different desired gfp_t flags to
use.

However, from the implementation side, changing zsmalloc is trivial to
just add a gfp_t param to alloc, and update zpool_malloc to accept and
pass through the gfp_t param.  So if that still makes more sense to
you, I can update things to change the zsmalloc api to add the param,
instead of this patch which removes the param from its api.  Assuming
that Minchan and Nitin also have no problem with updating the zsmalloc
api - there should be no functional difference in the zram/zsmalloc
relationship, since zram would simply always pass the same gfp_t to
zsmalloc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
