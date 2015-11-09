Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 79F6B6B0253
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 03:16:53 -0500 (EST)
Received: by wikq8 with SMTP id q8so62938066wik.1
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 00:16:53 -0800 (PST)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id s7si15284035wmd.28.2015.11.09.00.16.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 00:16:52 -0800 (PST)
Received: by wiby19 with SMTP id y19so10833799wib.0
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 00:16:52 -0800 (PST)
Date: Mon, 9 Nov 2015 09:16:50 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] jbd2: get rid of superfluous __GFP_REPEAT
Message-ID: <20151109081650.GA8916@dhcp22.suse.cz>
References: <1446740160-29094-4-git-send-email-mhocko@kernel.org>
 <1446826623-23959-1-git-send-email-mhocko@kernel.org>
 <563D526F.6030504@I-love.SAKURA.ne.jp>
 <20151108050802.GB3880@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151108050802.GB3880@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, john.johansen@canonical.com

On Sun 08-11-15 00:08:02, Theodore Ts'o wrote:
> On Sat, Nov 07, 2015 at 10:22:55AM +0900, Tetsuo Handa wrote:
> > All jbd2_alloc() callers seem to pass GFP_NOFS. Therefore, use of
> > vmalloc() which implicitly passes GFP_KERNEL | __GFP_HIGHMEM can cause
> > deadlock, can't it? This vmalloc(size) call needs to be replaced with
> > __vmalloc(size, flags).
> 
> jbd2_alloc is only passed in the bh->b_size, which can't be >
> PAGE_SIZE, so the code path that calls vmalloc() should never get
> called.  When we conveted jbd2_alloc() to suppor sub-page size
> allocations in commit d2eecb039368, there was an assumption that it
> could be called with a size greater than PAGE_SIZE, but that's
> certaily not true today.

Thanks for the clarification. Then the patch can be simplified even
more then.
---
