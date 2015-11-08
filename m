Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id 4BEEE6B0253
	for <linux-mm@kvack.org>; Sun,  8 Nov 2015 00:08:09 -0500 (EST)
Received: by ykdv3 with SMTP id v3so133993356ykd.0
        for <linux-mm@kvack.org>; Sat, 07 Nov 2015 21:08:09 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id w144si3798122ywd.67.2015.11.07.21.08.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Nov 2015 21:08:08 -0800 (PST)
Date: Sun, 8 Nov 2015 00:08:02 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH] jbd2: get rid of superfluous __GFP_REPEAT
Message-ID: <20151108050802.GB3880@thunk.org>
References: <1446740160-29094-4-git-send-email-mhocko@kernel.org>
 <1446826623-23959-1-git-send-email-mhocko@kernel.org>
 <563D526F.6030504@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <563D526F.6030504@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, john.johansen@canonical.com

On Sat, Nov 07, 2015 at 10:22:55AM +0900, Tetsuo Handa wrote:
> All jbd2_alloc() callers seem to pass GFP_NOFS. Therefore, use of
> vmalloc() which implicitly passes GFP_KERNEL | __GFP_HIGHMEM can cause
> deadlock, can't it? This vmalloc(size) call needs to be replaced with
> __vmalloc(size, flags).

jbd2_alloc is only passed in the bh->b_size, which can't be >
PAGE_SIZE, so the code path that calls vmalloc() should never get
called.  When we conveted jbd2_alloc() to suppor sub-page size
allocations in commit d2eecb039368, there was an assumption that it
could be called with a size greater than PAGE_SIZE, but that's
certaily not true today.

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
