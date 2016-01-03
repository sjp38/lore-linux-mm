Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 075F86B0005
	for <linux-mm@kvack.org>; Sun,  3 Jan 2016 11:56:17 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id f206so184064662wmf.0
        for <linux-mm@kvack.org>; Sun, 03 Jan 2016 08:56:16 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id c76si56658822wmh.30.2016.01.03.08.56.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 03 Jan 2016 08:56:15 -0800 (PST)
Date: Sun, 3 Jan 2016 16:56:13 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: __vmalloc() vs. GFP_NOIO/GFP_NOFS
Message-ID: <20160103165613.GL9938@ZenIV.linux.org.uk>
References: <20160103071246.GK9938@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160103071246.GK9938@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Dave Chinner <david@fromorbit.com>, Ming Lei <ming.lei@canonical.com>

On Sun, Jan 03, 2016 at 07:12:47AM +0000, Al Viro wrote:

> Allocation page tables doesn't have gfp argument at all.  Trying to propagate
> it down there could be done, but it's not attractive.

While we are at it, is there ever a reason to _not_ pass __GFP_HIGHMEM in
__vmalloc() flags?  After all, we explicitly put the pages we'd allocated
into the page table at vmalloc range we'd grabbed and these are the
addresses visible to caller.  Is there any point in having another alias
for those pages?

vmalloc() itself passes __GFP_HIGHMEM and so does a lot of __vmalloc()
callers; in fact, most of those that do not look like a result of
"we want vmalloc(), but we want to avoid it going into fs code and possibly
deadlocking us; vmalloc() has no gfp_t argument, so let's use __vmalloc()
and give it GFP_NOFS".  

Another very weird thing is the use of GFP_ATOMIC by alloc_large_system_hash();
if we want _that_ honoured, we'd probably have to pass gfp_t to alloc_one_pmd()
and friends, but I'm not sure what exactly is that caller requesting.
Confused...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
