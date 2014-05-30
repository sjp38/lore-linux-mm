Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id AC4726B0035
	for <linux-mm@kvack.org>; Fri, 30 May 2014 14:14:55 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id r20so1555737wiv.15
        for <linux-mm@kvack.org>; Fri, 30 May 2014 11:14:52 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id lb4si10122469wjb.84.2014.05.30.11.14.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 May 2014 11:14:50 -0700 (PDT)
Message-ID: <5388C9F9.3000105@zytor.com>
Date: Fri, 30 May 2014 11:12:09 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
References: <20140528223142.GO8554@dastard>	<CA+55aFyRk6_v6COPGVvu6hvt=i2A8-dPcs1X3Ydn1g24AxbPkg@mail.gmail.com>	<20140529013007.GF6677@dastard>	<CA+55aFzdq2V-Q3WUV7hQJG8jBSAvBqdYLVTNtbD4ObVZ5yDRmw@mail.gmail.com>	<20140529072633.GH6677@dastard>	<CA+55aFx+j4104ZFmA-YnDtyfmV4FuejwmGnD5shfY0WX4fN+Kg@mail.gmail.com>	<20140529235308.GA14410@dastard>	<20140530000649.GA3477@redhat.com>	<20140530002113.GC14410@dastard>	<20140530003219.GN10092@bbox>	<20140530013414.GF14410@dastard>	<5388A2D9.3080708@zytor.com>	<CA+55aFycqAw2AqQGv8aTPs_RxyKZqMdoyeSxWRSDk2N-PiBZeg@mail.gmail.com>	<5388A935.9050506@zytor.com> <CA+55aFwHS2xErW6TgBHGR9JP0QZW9W7GSLec5WzbV+GGYFUu6A@mail.gmail.com> <5388BEDF.3000202@intel.com>
In-Reply-To: <5388BEDF.3000202@intel.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Minchan Kim <minchan@kernel.org>, Dave Jones <davej@redhat.com>, Jens Axboe <axboe@kernel.dk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, PJ Waskiewicz <pjwaskiewicz@gmail.com>

On 05/30/2014 10:24 AM, Dave Hansen wrote:
> On 05/30/2014 09:06 AM, Linus Torvalds wrote:
>> On Fri, May 30, 2014 at 8:52 AM, H. Peter Anvin <hpa@zytor.com> wrote:
>>>> That said, it's still likely a non-production option due to the page
>>>> table games we'd have to play at fork/clone time.
>>>
>>> Still, seems much more tractable.
>>
>> We might be able to make it more attractive by having a small
>> front-end cache of the 16kB allocations with the second page unmapped.
>> That would at least capture the common "lots of short-lived processes"
>> case without having to do kernel page table work.
> 
> If we want to use 4k mappings, we'd need to move the stack over to using
> vmalloc() (or at least be out of the linear mapping) to avoid breaking
> up the linear map's page tables too much.  Doing that, we'd actually not
> _have_ to worry about fragmentation, and we could actually utilize the
> per-cpu-pageset code since we'd could be back to using order-0 pages.
> So it's at least not all a loss.  Although, I do remember playing with
> 4k stacks back in the 32-bit days and not getting much of a win with it.
> 
> We'd definitely that cache, if for no other reason than the vmalloc/vmap
> code as-is isn't super-scalable.
> 

I don't think we want to use 4K mappings for production...

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
