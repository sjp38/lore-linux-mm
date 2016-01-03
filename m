Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3E99E6B0006
	for <linux-mm@kvack.org>; Sun,  3 Jan 2016 15:35:17 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id l65so143465650wmf.1
        for <linux-mm@kvack.org>; Sun, 03 Jan 2016 12:35:17 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id j204si47132941wma.115.2016.01.03.12.35.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 03 Jan 2016 12:35:16 -0800 (PST)
Date: Sun, 3 Jan 2016 20:35:14 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: __vmalloc() vs. GFP_NOIO/GFP_NOFS
Message-ID: <20160103203514.GN9938@ZenIV.linux.org.uk>
References: <20160103071246.GK9938@ZenIV.linux.org.uk>
 <20160103201233.GC6682@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160103201233.GC6682@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Ming Lei <ming.lei@canonical.com>

On Mon, Jan 04, 2016 at 07:12:33AM +1100, Dave Chinner wrote:

> That'd be a nice start, though it doesn't address callers of
> vm_map_ram() which also has hard-coded GFP_KERNEL allocation masks
> for various allocations.

... all 3 of them, that is - XFS, android/ion/ion_heap.c and
v4l2-core.  5 call sites total.  Adding a gfp_t argument to those
shouldn't be an issue...

BTW, far scarier one is not GFP_NOFS or GFP_IO - there's a weird
caller passing GFP_ATOMIC to __vmalloc(), for no reason I can guess.

_That_ really couldn't be handled without passing gfp_t to page allocation
primitives, but I very much doubt that it's needed there at all; it's in
alloc_large_system_hash() and I really cannot imagine a situation when
it would be used in e.g. a nonblocking context.

Folks, what is that one for?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
