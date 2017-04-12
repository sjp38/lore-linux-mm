Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 143A56B03A0
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 06:41:35 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id p64so18327538oif.0
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 03:41:35 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id d140si1406888oig.47.2017.04.12.03.41.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Apr 2017 03:41:34 -0700 (PDT)
Subject: Re: [PATCH] mm, page_alloc: Remove debug_guardpage_minorder() test in warn_alloc().
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1491910035-4231-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20170412102341.GA13958@redhat.com>
In-Reply-To: <20170412102341.GA13958@redhat.com>
Message-Id: <201704121941.IAC86936.MFOVOFLFHOStQJ@I-love.SAKURA.ne.jp>
Date: Wed, 12 Apr 2017 19:41:17 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sgruszka@redhat.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rjw@sisk.pl, aarcange@redhat.com, cl@linux-foundation.org, mgorman@suse.de, penberg@cs.helsinki.fi, mhocko@suse.com

Stanislaw Gruszka wrote:
> On Tue, Apr 11, 2017 at 08:27:15PM +0900, Tetsuo Handa wrote:
> > Commit c0a32fc5a2e470d0 ("mm: more intensive memory corruption debugging")
> > changed to check debug_guardpage_minorder() > 0 when reporting allocation
> > failures. But the patch description seems to lack why we want to check it.
> 
> When we use guard page to debug memory corruption, it shrinks available
> pages to 1/2, 1/4, 1/8 and so on, depending on parameter value.
> In such case memory allocation failures can be common and printing
> errors can flood dmesg. If sombody debug corruption, allocation
> failures are not the things he/she is interested about.

Nowadays we likely have a lot of memory where shrinking available pages to
1/2, 1/4, 1/8 and so on would not cause flooding of allocation failure messages.
Thus, I hope removing debug_guardpage_minorder() > 0 test affects only systems
with small memory. But

> 
> > Let's remove that check so that administrators can get some clue by
> > allowing warn_alloc() to report e.g. GFP_NOFS | __GFP_NOWARN allocations
> > are stalling.
> 
> This is ok for me, but perhaps move debug_guardpage_minorder() > 0
> check before calling warn_alloc() in buddy allocator when it fails,
> or move it before __ratelimit(), will be better option.

before proposing this patch, I proposed a patch at
http://lkml.kernel.org/r/1491825493-8859-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
that ignores debug_guardpage_minorder() > 0 only when reporting allocation stalls.
We can preserve debug_guardpage_minorder() > 0 test if we change to use
a different function for reporting allocation stalls.

Which patch do you prefer?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
