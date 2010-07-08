Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 855546B0248
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 06:30:39 -0400 (EDT)
Subject: Re: FYI: mmap_sem OOM patch
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100707231134.GA26555@google.com>
References: <20100707231134.GA26555@google.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 08 Jul 2010 12:30:09 +0200
Message-ID: <1278585009.1900.31.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Divyesh Shah <dpshah@google.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-07-07 at 16:11 -0700, Michel Lespinasse wrote:
> What happens is we end up with a single thread in the oom loop (T1)
> that ends up killing a sibling thread (T2).  That sibling thread will
> need to acquire the read side of the mmap_sem in the exit path.  It's
> possible however that yet a different thread (T3) is in the middle of
> a virtual address space operation (mmap, munmap) and is enqueue to
> grab the write side of the mmap_sem behind yet another thread (T4)
> that is stuck in the OOM loop (behind T1) with mmap_sem held for read
> (like allocating a page for pagecache as part of a fault.
>=20
>       T1              T2              T3              T4
>       .               .               .               .
>    oom:               .               .               .
>    oomkill            .               .               .
>       ^    \          .               .               .
>      /|\    ---->  do_exit:           .               .
>       |            sleep in           .               .
>       |            read(mmap_sem)     .               .
>       |                     \         .               .
>       |                      ----> mmap               .
>       |                            sleep in           .
>       |                            write(mmap_sem)    .
>       |                                     \         .
>       |                                      ----> fault
>       |                                            holding read(mmap_sem)
>       |                                            oom
>       |                                               |
>       |                                               /
>       \----------------------------------------------/=20

So what you do is use recursive locking to side-step a deadlock.
Recursive locking is poor taste and leads to very ill defined locking
rules.

One way to fix this is to have T4 wake from the oom queue and return an
allocation failure instead of insisting on going oom itself when T1
decides to take down the task.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
