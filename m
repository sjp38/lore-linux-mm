Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id D26166B0035
	for <linux-mm@kvack.org>; Fri, 30 May 2014 11:55:07 -0400 (EDT)
Received: by mail-la0-f52.google.com with SMTP id gl10so1137878lab.39
        for <linux-mm@kvack.org>; Fri, 30 May 2014 08:55:06 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id ky5si6076238lab.32.2014.05.30.08.55.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 May 2014 08:55:05 -0700 (PDT)
Message-ID: <5388A935.9050506@zytor.com>
Date: Fri, 30 May 2014 08:52:21 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
References: <20140528223142.GO8554@dastard>	<CA+55aFyRk6_v6COPGVvu6hvt=i2A8-dPcs1X3Ydn1g24AxbPkg@mail.gmail.com>	<20140529013007.GF6677@dastard>	<CA+55aFzdq2V-Q3WUV7hQJG8jBSAvBqdYLVTNtbD4ObVZ5yDRmw@mail.gmail.com>	<20140529072633.GH6677@dastard>	<CA+55aFx+j4104ZFmA-YnDtyfmV4FuejwmGnD5shfY0WX4fN+Kg@mail.gmail.com>	<20140529235308.GA14410@dastard>	<20140530000649.GA3477@redhat.com>	<20140530002113.GC14410@dastard>	<20140530003219.GN10092@bbox>	<20140530013414.GF14410@dastard>	<5388A2D9.3080708@zytor.com> <CA+55aFycqAw2AqQGv8aTPs_RxyKZqMdoyeSxWRSDk2N-PiBZeg@mail.gmail.com>
In-Reply-To: <CA+55aFycqAw2AqQGv8aTPs_RxyKZqMdoyeSxWRSDk2N-PiBZeg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Minchan Kim <minchan@kernel.org>, Dave Jones <davej@redhat.com>, Jens Axboe <axboe@kernel.dk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>, PJ Waskiewicz <pjwaskiewicz@gmail.com>

On 05/30/2014 08:41 AM, Linus Torvalds wrote:
> On Fri, May 30, 2014 at 8:25 AM, H. Peter Anvin <hpa@zytor.com> wrote:
>>
>> If we removed struct thread_info from the stack allocation then one
>> could do a guard page below the stack.  Of course, we'd have to use IST
>> for #PF in that case, which makes it a non-production option.
> 
> We could just have the guard page in between the stack and the
> thread_info, take a double fault, and then just map it back in on
> double fault.
> 

Oh, duh.  Right, much better.  Similar to the espfix64 hack, too.

> That would give us 8kB of "normal" stack, with a very loud fault - and
> then an extra 7kB or so of stack (whatever the size of thread-info is)
> - after the first time it traps.
> 
> That said, it's still likely a non-production option due to the page
> table games we'd have to play at fork/clone time.

Still, seems much more tractable.

I would still like struct thread_info off the stack allocation for other
reasons (as we have discussed in the past.)

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
