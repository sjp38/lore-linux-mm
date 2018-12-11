Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5C96F8E00C9
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 13:52:08 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id f24so15031873ioh.21
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 10:52:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 5sor4841972itx.25.2018.12.11.10.52.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 10:52:07 -0800 (PST)
Subject: Re: [PATCH] aio: Convert ioctx_table to XArray
References: <20181128183531.5139-1-willy@infradead.org>
 <x49va46e1p0.fsf@segfault.boston.devel.redhat.com>
 <x49pnuee1gm.fsf@segfault.boston.devel.redhat.com>
 <x49mupcm11r.fsf@segfault.boston.devel.redhat.com>
 <20181211175156.GF6830@bombadil.infradead.org>
 <x495zw0lz68.fsf@segfault.boston.devel.redhat.com>
 <0f77a532-0d88-78bc-b9cc-06bb203a0405@kernel.dk>
 <6b9a45c4-47a2-4c44-aa7e-6e5e90eff9df@kernel.dk>
 <20181211185105.GI6830@bombadil.infradead.org>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <d45b92ea-ee57-0228-a23f-419b5b72ed59@kernel.dk>
Date: Tue, 11 Dec 2018 11:52:05 -0700
MIME-Version: 1.0
In-Reply-To: <20181211185105.GI6830@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jeff Moyer <jmoyer@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Benjamin LaHaise <bcrl@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Carpenter <dan.carpenter@oracle.com>, kent.overstreet@gmail.com

On 12/11/18 11:51 AM, Matthew Wilcox wrote:
> On Tue, Dec 11, 2018 at 11:32:54AM -0700, Jens Axboe wrote:
>> Don't see any regressions. But if we're fiddling with it anyway, can't
>> we do something smarter? Make the fast path just index a table, and put
>> all the big hammers in setup/destroy. We're spending a non-substantial
>> amount of time doing lookups, that's really no different before and
>> after the patch.
> 
> Thanks for checking it out.
> 
> I think the fast path does just index a table.  Until you have more than
> 64 pointers in the XArray, it's just xa->head->slots[i].  And then up
> to 4096 pointers, it's xa->head->slots[i >> 6]->slots[i].  It has the
> advantage that if you only have one kioctx (which is surely many programs
> using AIO), it's just xa->head, so even better than a table lookup.
> 
> It'll start to deteriorate after 4096 kioctxs, with one extra indirection
> for every 6 bits, but by that point, we'd've been straining the memory
> allocator to allocate a large table anyway.

I agree, and nobody cares about 4k kioctxs, you're way into the weeds
at that point anyway.

So as the followup said, I think we're fine as-is for this particular
case.

-- 
Jens Axboe
