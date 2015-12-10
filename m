Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2C8376B0038
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 14:47:19 -0500 (EST)
Received: by igcto18 with SMTP id to18so23177665igc.0
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 11:47:19 -0800 (PST)
Received: from mail-io0-x22b.google.com (mail-io0-x22b.google.com. [2607:f8b0:4001:c06::22b])
        by mx.google.com with ESMTPS id bf10si343876igb.49.2015.12.10.11.47.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 11:47:18 -0800 (PST)
Received: by ioc74 with SMTP id 74so103765065ioc.2
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 11:47:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151210193351.GE20997@ZenIV.linux.org.uk>
References: <20151209225148.GA14794@www.outflux.net>
	<20151210070635.GC31922@1wt.eu>
	<CAGXu5jLZ8Ldv4vCjN6+QOa8v=GuUDU9t8sJsTNaQJGYtpdCayA@mail.gmail.com>
	<20151210181611.GB32083@1wt.eu>
	<20151210193351.GE20997@ZenIV.linux.org.uk>
Date: Thu, 10 Dec 2015 11:47:18 -0800
Message-ID: <CAGXu5jLF5-jbQ8tEHWnTZKqWj5_kmrqdKcJMb_B_HdN34RwCqA@mail.gmail.com>
Subject: Re: [PATCH v5] fs: clear file privilege bits when mmap writing
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Willy Tarreau <w@1wt.eu>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, yalin wang <yalin.wang2010@gmail.com>, "Eric W. Biederman" <ebiederm@xmission.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Dec 10, 2015 at 11:33 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Thu, Dec 10, 2015 at 07:16:11PM +0100, Willy Tarreau wrote:
>
>> > Is f_flags safe to write like this without holding a lock?
>>
>> Unfortunately I have no idea. I've seen places where it's written without
>> taking a lock such as in blkdev_open() and I don't think that this one is
>> called with a lock held.
>
> In any ->open() we obviously have nobody else able to find that struct file,
> let alone modify it, so there the damn thing is essentially caller-private
> and no locking is needed.

In open, sure, but what about under mm/memory.c where we're trying to
twiddle it from vma->file->f_flags as in my patch? That seemed like it
would want atomic safety.

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
