Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f169.google.com (mail-vc0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0302D6B0035
	for <linux-mm@kvack.org>; Fri, 30 May 2014 11:41:00 -0400 (EDT)
Received: by mail-vc0-f169.google.com with SMTP id ij19so2317583vcb.0
        for <linux-mm@kvack.org>; Fri, 30 May 2014 08:41:00 -0700 (PDT)
Received: from mail-vc0-x22f.google.com (mail-vc0-x22f.google.com [2607:f8b0:400c:c03::22f])
        by mx.google.com with ESMTPS id b1si3345351vei.91.2014.05.30.08.41.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 May 2014 08:41:00 -0700 (PDT)
Received: by mail-vc0-f175.google.com with SMTP id id10so2258926vcb.6
        for <linux-mm@kvack.org>; Fri, 30 May 2014 08:41:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5388A2D9.3080708@zytor.com>
References: <20140528223142.GO8554@dastard>
	<CA+55aFyRk6_v6COPGVvu6hvt=i2A8-dPcs1X3Ydn1g24AxbPkg@mail.gmail.com>
	<20140529013007.GF6677@dastard>
	<CA+55aFzdq2V-Q3WUV7hQJG8jBSAvBqdYLVTNtbD4ObVZ5yDRmw@mail.gmail.com>
	<20140529072633.GH6677@dastard>
	<CA+55aFx+j4104ZFmA-YnDtyfmV4FuejwmGnD5shfY0WX4fN+Kg@mail.gmail.com>
	<20140529235308.GA14410@dastard>
	<20140530000649.GA3477@redhat.com>
	<20140530002113.GC14410@dastard>
	<20140530003219.GN10092@bbox>
	<20140530013414.GF14410@dastard>
	<5388A2D9.3080708@zytor.com>
Date: Fri, 30 May 2014 08:41:00 -0700
Message-ID: <CA+55aFycqAw2AqQGv8aTPs_RxyKZqMdoyeSxWRSDk2N-PiBZeg@mail.gmail.com>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Dave Chinner <david@fromorbit.com>, Minchan Kim <minchan@kernel.org>, Dave Jones <davej@redhat.com>, Jens Axboe <axboe@kernel.dk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

On Fri, May 30, 2014 at 8:25 AM, H. Peter Anvin <hpa@zytor.com> wrote:
>
> If we removed struct thread_info from the stack allocation then one
> could do a guard page below the stack.  Of course, we'd have to use IST
> for #PF in that case, which makes it a non-production option.

We could just have the guard page in between the stack and the
thread_info, take a double fault, and then just map it back in on
double fault.

That would give us 8kB of "normal" stack, with a very loud fault - and
then an extra 7kB or so of stack (whatever the size of thread-info is)
- after the first time it traps.

That said, it's still likely a non-production option due to the page
table games we'd have to play at fork/clone time.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
