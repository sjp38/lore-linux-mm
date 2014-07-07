Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f174.google.com (mail-ve0-f174.google.com [209.85.128.174])
	by kanga.kvack.org (Postfix) with ESMTP id 76B716B0039
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 19:52:37 -0400 (EDT)
Received: by mail-ve0-f174.google.com with SMTP id jx11so4872686veb.19
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 16:52:37 -0700 (PDT)
Received: from mail-vc0-x234.google.com (mail-vc0-x234.google.com [2607:f8b0:400c:c03::234])
        by mx.google.com with ESMTPS id yr5si19393172vdb.14.2014.07.07.16.52.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 07 Jul 2014 16:52:36 -0700 (PDT)
Received: by mail-vc0-f180.google.com with SMTP id im17so4763056vcb.11
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 16:52:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140707230459.GF18735@two.firstfloor.org>
References: <20140707223001.GD18735@two.firstfloor.org>
	<53BB240C.30400@zytor.com>
	<20140707230459.GF18735@two.firstfloor.org>
Date: Mon, 7 Jul 2014 16:52:35 -0700
Message-ID: <CA+55aFxD4akfr3sc_y=F17Ak_9NqEHOu=vBz5x2kR75TkG8znA@mail.gmail.com>
Subject: Re: fallout of 16K stacks
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Jul 7, 2014 at 4:04 PM, Andi Kleen <andi@firstfloor.org> wrote:
>>
>> As in ENOMEM or does something worse happen?
>
> EAGAIN, then the workload stops. For an overnight stress
> test that's pretty catastrophic. It may have killed some stuff
> with the OOM killer too.

I don't think it's OOM.

We have long had the rule that order <= PAGE_ALLOC_COSTLY_ORDER (which
is 3) allocations imply __GFP_RETRY unless you explicitly ask it not
to.

And THREAD_SIZE_ORDER is still smaller than that.

Sure, if the system makes no progress at all, it will still oom for
allocations like that, but that's *not* going to happen for something
like a 32GB machine afaik.

And if it was the actual dup_task_struct() that failed (due to
alloc_thread_info_node() now failing), it should have returned ENOMEM
anyway.

So EAGAIN is due to something else.

The only cases for fork() returning EAGAIN I can find are the
RLIMIT_NPROC and max_threads checks.

And the thing is, the default value for RLIMIT_NPROC is actually
initialized based on THREAD_SIZE (which doubled), so maybe it's really
just that rlimit check that now triggers.

Hmm?

          Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
