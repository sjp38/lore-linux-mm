Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A08306B025E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 19:32:58 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r202so977112wmd.1
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 16:32:58 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id t66si9759814wme.78.2017.10.10.16.32.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Oct 2017 16:32:55 -0700 (PDT)
Date: Wed, 11 Oct 2017 00:32:48 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
Message-ID: <20171010233248.GY21978@ZenIV.linux.org.uk>
References: <20171005222144.123797-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171005222144.123797-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Oct 05, 2017 at 03:21:44PM -0700, Shakeel Butt wrote:
> The allocations from filp and names kmem caches can be directly
> triggered by user space applications. A buggy application can
> consume a significant amount of unaccounted system memory. Though
> we have not noticed such buggy applications in our production
> but upon close inspection, we found that a lot of machines spend
> very significant amount of memory on these caches. So, these
> caches should be accounted to kmemcg.

IDGI...  Surely, it's not hard to come up with a syscall that can
allocate a page for the duration of syscall?  Just to pick a random
example: reading from /proc/self/cmdline does that.  So does
readlink of /proc/self/cwd, etc.

What does accounting for such temporary allocations (with fixed
limit per syscall, always freed by the end of syscall) buy you,
why is it needed and what makes it not needed for the examples
above (and a slew of similar ones)?

While we are at it, how much overhead does it add on syscall-heavy
loads?  As in, a whole lot of threads is calling something like
stat("/", &stbuf); in parallel?  Because outside of that kind of
loads it's completely pointless...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
