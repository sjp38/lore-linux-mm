Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 1F02A6B0034
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 10:48:58 -0400 (EDT)
Date: Thu, 20 Jun 2013 14:48:56 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: Revert pinned_vm braindamage
In-Reply-To: <20130620114943.GB12125@gmail.com>
Message-ID: <0000013f620f4699-f484f28e-3d12-4560-adfe-3b00af995fd9-000000@email.amazonses.com>
References: <20130606124351.GZ27176@twins.programming.kicks-ass.net> <0000013f1ad00ec0-9574a936-3a75-4ccc-a84c-4a12a7ea106e-000000@email.amazonses.com> <20130607110344.GA27176@twins.programming.kicks-ass.net> <0000013f1f1f79d1-2cf8cb8c-7e63-4e83-9f2b-7acc0e0638a1-000000@email.amazonses.com>
 <20130617110832.GP3204@twins.programming.kicks-ass.net> <0000013f536c60ee-9a1ca9da-b798-416a-a32e-c896813d3bac-000000@email.amazonses.com> <20130620114943.GB12125@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, akpm@linux-foundation.org, torvalds@linux-foundation.org, roland@kernel.org, tglx@linutronix.de, kosaki.motohiro@gmail.com, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-rdma@vger.kernel.org

On Thu, 20 Jun 2013, Ingo Molnar wrote:

> Peter clearly pointed it out that in the perf case it's user-space that
> initiates the pinned memory mapping which is resource-controlled via
> RLIMIT_MEMLOCK - and this was implemented that way before your commit
> broke the code.

There is no way that user space can initiate a page pin right now. Perf is
pinning the page from the kernel. Similarly the IB subsystem pins memory
meeded for device I/O.

> You seem to be hell bent on defining 'memory pinning' only as "the thing
> done via the mlock*() system calls", but that is a nonsensical distinction
> that actively and incorrectly ignores other system calls that can and do
> pin memory legitimately.

Nope. I have said that Memory pinning is done by increasing the refcount
which is different from mlock which sets a page flag.

I have consistently argued that these are two different things. And I am
a
bit surprised that this point has not been understood after all these
repetitions.

Memory pinning these days is done as a side effect of kernel / driver
needs. I.e. the memory registration done through the IB subsystem and
elsewhere.

> int can_do_mlock(void)
> {
>         if (capable(CAP_IPC_LOCK))
>                 return 1;
>         if (rlimit(RLIMIT_MEMLOCK) != 0)
>                 return 1;
>         return 0;
> }
> EXPORT_SYMBOL(can_do_mlock);
>
> Q.E.D.

Argh. Just checked the apps. True. They did set the rlimit to 0 at some
point in order to make this work. Then they monitor the number of locked
pages and create alerts so that action can be taking if a system uses too
many mlocked pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
