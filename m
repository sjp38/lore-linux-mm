Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 32A2D6B0254
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 15:28:15 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id n186so2188511wmn.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 12:28:15 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id w126si545746wmb.120.2015.12.10.12.28.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Dec 2015 12:28:14 -0800 (PST)
Date: Thu, 10 Dec 2015 20:27:49 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v5] fs: clear file privilege bits when mmap writing
Message-ID: <20151210202749.GF20997@ZenIV.linux.org.uk>
References: <20151209225148.GA14794@www.outflux.net>
 <20151210070635.GC31922@1wt.eu>
 <CAGXu5jLZ8Ldv4vCjN6+QOa8v=GuUDU9t8sJsTNaQJGYtpdCayA@mail.gmail.com>
 <20151210181611.GB32083@1wt.eu>
 <20151210193351.GE20997@ZenIV.linux.org.uk>
 <CAGXu5jLF5-jbQ8tEHWnTZKqWj5_kmrqdKcJMb_B_HdN34RwCqA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jLF5-jbQ8tEHWnTZKqWj5_kmrqdKcJMb_B_HdN34RwCqA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Willy Tarreau <w@1wt.eu>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, yalin wang <yalin.wang2010@gmail.com>, "Eric W. Biederman" <ebiederm@xmission.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Dec 10, 2015 at 11:47:18AM -0800, Kees Cook wrote:

> In open, sure, but what about under mm/memory.c where we're trying to
> twiddle it from vma->file->f_flags as in my patch? That seemed like it
> would want atomic safety.

Sigh...  Again, I'm not at all convinced that this is the right approach,
but generally you need ->f_lock.  And in situations where the bit can
go only off->on, check it lockless, skip the whole thing entirely if it's
already set and grab the spinlock otherwise.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
