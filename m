Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 417E68E00C9
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 13:51:09 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id v11so11188485ply.4
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 10:51:09 -0800 (PST)
Date: Tue, 11 Dec 2018 10:51:05 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] aio: Convert ioctx_table to XArray
Message-ID: <20181211185105.GI6830@bombadil.infradead.org>
References: <20181128183531.5139-1-willy@infradead.org>
 <x49va46e1p0.fsf@segfault.boston.devel.redhat.com>
 <x49pnuee1gm.fsf@segfault.boston.devel.redhat.com>
 <x49mupcm11r.fsf@segfault.boston.devel.redhat.com>
 <20181211175156.GF6830@bombadil.infradead.org>
 <x495zw0lz68.fsf@segfault.boston.devel.redhat.com>
 <0f77a532-0d88-78bc-b9cc-06bb203a0405@kernel.dk>
 <6b9a45c4-47a2-4c44-aa7e-6e5e90eff9df@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6b9a45c4-47a2-4c44-aa7e-6e5e90eff9df@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Jeff Moyer <jmoyer@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Benjamin LaHaise <bcrl@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Carpenter <dan.carpenter@oracle.com>, kent.overstreet@gmail.com

On Tue, Dec 11, 2018 at 11:32:54AM -0700, Jens Axboe wrote:
> Don't see any regressions. But if we're fiddling with it anyway, can't
> we do something smarter? Make the fast path just index a table, and put
> all the big hammers in setup/destroy. We're spending a non-substantial
> amount of time doing lookups, that's really no different before and
> after the patch.

Thanks for checking it out.

I think the fast path does just index a table.  Until you have more than
64 pointers in the XArray, it's just xa->head->slots[i].  And then up
to 4096 pointers, it's xa->head->slots[i >> 6]->slots[i].  It has the
advantage that if you only have one kioctx (which is surely many programs
using AIO), it's just xa->head, so even better than a table lookup.

It'll start to deteriorate after 4096 kioctxs, with one extra indirection
for every 6 bits, but by that point, we'd've been straining the memory
allocator to allocate a large table anyway.
