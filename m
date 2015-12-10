Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id C99ED6B0038
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 16:45:10 -0500 (EST)
Received: by igbxm8 with SMTP id xm8so25719935igb.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 13:45:10 -0800 (PST)
Received: from mail-io0-x22e.google.com (mail-io0-x22e.google.com. [2607:f8b0:4001:c06::22e])
        by mx.google.com with ESMTPS id y37si22675437ioi.7.2015.12.10.13.45.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 13:45:10 -0800 (PST)
Received: by ioir85 with SMTP id r85so107381149ioi.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 13:45:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151210202749.GF20997@ZenIV.linux.org.uk>
References: <20151209225148.GA14794@www.outflux.net>
	<20151210070635.GC31922@1wt.eu>
	<CAGXu5jLZ8Ldv4vCjN6+QOa8v=GuUDU9t8sJsTNaQJGYtpdCayA@mail.gmail.com>
	<20151210181611.GB32083@1wt.eu>
	<20151210193351.GE20997@ZenIV.linux.org.uk>
	<CAGXu5jLF5-jbQ8tEHWnTZKqWj5_kmrqdKcJMb_B_HdN34RwCqA@mail.gmail.com>
	<20151210202749.GF20997@ZenIV.linux.org.uk>
Date: Thu, 10 Dec 2015 13:45:09 -0800
Message-ID: <CAGXu5jLAK8SYDcrCbJhb4jRtLVW9xjaNi-k68-QV-8_FqZrdqA@mail.gmail.com>
Subject: Re: [PATCH v5] fs: clear file privilege bits when mmap writing
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Willy Tarreau <w@1wt.eu>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, yalin wang <yalin.wang2010@gmail.com>, "Eric W. Biederman" <ebiederm@xmission.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Dec 10, 2015 at 12:27 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Thu, Dec 10, 2015 at 11:47:18AM -0800, Kees Cook wrote:
>
>> In open, sure, but what about under mm/memory.c where we're trying to
>> twiddle it from vma->file->f_flags as in my patch? That seemed like it
>> would want atomic safety.
>
> Sigh...  Again, I'm not at all convinced that this is the right approach,

I'm open to any suggestions. Every path I've tried has been ultimately
blocked by mmap_sem. :(

> but generally you need ->f_lock.  And in situations where the bit can
> go only off->on, check it lockless, skip the whole thing entirely if it's
> already set and grab the spinlock otherwise.

And I can take f_lock safely under mmap_sem?

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
