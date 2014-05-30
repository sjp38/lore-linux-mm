Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id D52256B0035
	for <linux-mm@kvack.org>; Fri, 30 May 2014 13:26:17 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id lj1so1926940pab.17
        for <linux-mm@kvack.org>; Fri, 30 May 2014 10:26:17 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id gu3si6336956pbb.232.2014.05.30.10.26.14
        for <linux-mm@kvack.org>;
        Fri, 30 May 2014 10:26:17 -0700 (PDT)
Message-ID: <5388BEDF.3000202@intel.com>
Date: Fri, 30 May 2014 10:24:47 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
References: <20140528223142.GO8554@dastard>	<CA+55aFyRk6_v6COPGVvu6hvt=i2A8-dPcs1X3Ydn1g24AxbPkg@mail.gmail.com>	<20140529013007.GF6677@dastard>	<CA+55aFzdq2V-Q3WUV7hQJG8jBSAvBqdYLVTNtbD4ObVZ5yDRmw@mail.gmail.com>	<20140529072633.GH6677@dastard>	<CA+55aFx+j4104ZFmA-YnDtyfmV4FuejwmGnD5shfY0WX4fN+Kg@mail.gmail.com>	<20140529235308.GA14410@dastard>	<20140530000649.GA3477@redhat.com>	<20140530002113.GC14410@dastard>	<20140530003219.GN10092@bbox>	<20140530013414.GF14410@dastard>	<5388A2D9.3080708@zytor.com>	<CA+55aFycqAw2AqQGv8aTPs_RxyKZqMdoyeSxWRSDk2N-PiBZeg@mail.gmail.com>	<5388A935.9050506@zytor.com> <CA+55aFwHS2xErW6TgBHGR9JP0QZW9W7GSLec5WzbV+GGYFUu6A@mail.gmail.com>
In-Reply-To: <CA+55aFwHS2xErW6TgBHGR9JP0QZW9W7GSLec5WzbV+GGYFUu6A@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Dave Chinner <david@fromorbit.com>, Minchan Kim <minchan@kernel.org>, Dave Jones <davej@redhat.com>, Jens Axboe <axboe@kernel.dk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, PJ Waskiewicz <pjwaskiewicz@gmail.com>

On 05/30/2014 09:06 AM, Linus Torvalds wrote:
> On Fri, May 30, 2014 at 8:52 AM, H. Peter Anvin <hpa@zytor.com> wrote:
>>> That said, it's still likely a non-production option due to the page
>>> table games we'd have to play at fork/clone time.
>>
>> Still, seems much more tractable.
> 
> We might be able to make it more attractive by having a small
> front-end cache of the 16kB allocations with the second page unmapped.
> That would at least capture the common "lots of short-lived processes"
> case without having to do kernel page table work.

If we want to use 4k mappings, we'd need to move the stack over to using
vmalloc() (or at least be out of the linear mapping) to avoid breaking
up the linear map's page tables too much.  Doing that, we'd actually not
_have_ to worry about fragmentation, and we could actually utilize the
per-cpu-pageset code since we'd could be back to using order-0 pages.
So it's at least not all a loss.  Although, I do remember playing with
4k stacks back in the 32-bit days and not getting much of a win with it.

We'd definitely that cache, if for no other reason than the vmalloc/vmap
code as-is isn't super-scalable.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
