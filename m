Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 934886B0033
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 05:14:06 -0400 (EDT)
Message-ID: <51B98C9A.8020602@parallels.com>
Date: Thu, 13 Jun 2013 13:10:50 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: Change soft-dirty interface?
References: <20130613015329.GA3894@bbox>
In-Reply-To: <20130613015329.GA3894@bbox>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

On 06/13/2013 05:53 AM, Minchan Kim wrote:
> Hi all, 
> 
> Sorry for late interrupting to promote patchset to the mainline.
> I'd like to discuss our usecase so I'd like to change per-process
> interface with per-range interface.
> 
> Our usecase is following as,
> 
> A application allocates a big buffer(A) and makes backup buffer(B)
> for it and copy B from A.
> Let's assume A consists of subranges (A-1, A-2, A-3, A-4).
> As time goes by, application can modify anywhere of A.
> In this example, let's assume A-1 and A-2 are modified.
> When the time happen, we compare A-1 with B-1 to make
> diff of the range(On every iteration, we don't need all range's diff by design)
> and do something with diff, then we'd like to remark only the A-1 with
> soft-dirty, NOT A's all range of the process to track the A-1's
> further difference in future while keeping dirty information (A-2, A-3, A-4)
> because we will make A-2's diff in next iteration.
> 
> We can't do it by existing interface.

So you need to track changes not in the whole range, but in sub-ranges.
OK.

> So, I'd like to add [addr, len] argument with using proc
> 
>     echo 4 0x100000 0x3000 > /proc/self/clear_refs
> 
> It doesn't break anything but not sure everyone like the interface
> because recently I heard from akpm following comment.
> 
>         https://lkml.org/lkml/2013/5/21/529
> 
> Although per-process reclaim is another story with this,
> I feel he seems to hate doing something on proc interface with
> /proc/pid/maps like above range parameter.
> 
> If it's not allowed, another approach should be new system call.
> 
>         int sys_softdirty(pid_t pid, void *addr, size_t len);

This looks like existing sys_madvise() one.

> If we approach new system call, we don't need to maintain current
> proc interface and it would be very handy to get a information
> without pagemap (open/read/close) so we can add a parameter to
> get a dirty information easily.
> 
>         int sys_softdirty(pid_t pid, void *addr, size_t len, unsigned char *vec)
> 
> What do you think about it?
> 

This is OK for me, though there's another issue with this API I'd like
to mention -- consider your app is doing these tricks with soft-dirty
and at the same time CRIU tools live-migrate it using the soft-dirty bits
to optimize the freeze time.

In that case soft-dirty bits would be in wrong state for both -- you app
and CRIU, but with the proc API we could compare the ctime-s of the 
clear_refs file and find out, that someone spoiled the soft-dirty state
from last time we messed with it and handle it somehow (copy all the memory
in the worst case). Can we somehow handle this with your proposal?

Thanks,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
