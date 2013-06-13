Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 94A4E6B0033
	for <linux-mm@kvack.org>; Wed, 12 Jun 2013 21:53:31 -0400 (EDT)
Date: Thu, 13 Jun 2013 10:53:29 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Change soft-dirty interface?
Message-ID: <20130613015329.GA3894@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

Hi all, 

Sorry for late interrupting to promote patchset to the mainline.
I'd like to discuss our usecase so I'd like to change per-process
interface with per-range interface.

Our usecase is following as,

A application allocates a big buffer(A) and makes backup buffer(B)
for it and copy B from A.
Let's assume A consists of subranges (A-1, A-2, A-3, A-4).
As time goes by, application can modify anywhere of A.
In this example, let's assume A-1 and A-2 are modified.
When the time happen, we compare A-1 with B-1 to make
diff of the range(On every iteration, we don't need all range's diff by design)
and do something with diff, then we'd like to remark only the A-1 with
soft-dirty, NOT A's all range of the process to track the A-1's
further difference in future while keeping dirty information (A-2, A-3, A-4)
because we will make A-2's diff in next iteration.

We can't do it by existing interface.

So, I'd like to add [addr, len] argument with using proc

    echo 4 0x100000 0x3000 > /proc/self/clear_refs

It doesn't break anything but not sure everyone like the interface
because recently I heard from akpm following comment.

        https://lkml.org/lkml/2013/5/21/529

Although per-process reclaim is another story with this,
I feel he seems to hate doing something on proc interface with
/proc/pid/maps like above range parameter.

If it's not allowed, another approach should be new system call.

        int sys_softdirty(pid_t pid, void *addr, size_t len);

If we approach new system call, we don't need to maintain current
proc interface and it would be very handy to get a information
without pagemap (open/read/close) so we can add a parameter to
get a dirty information easily.

        int sys_softdirty(pid_t pid, void *addr, size_t len, unsigned char *vec)

What do you think about it?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
