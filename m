Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1DD266B00C4
	for <linux-mm@kvack.org>; Thu, 17 Oct 2013 16:23:53 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rr4so2778533pbb.20
        for <linux-mm@kvack.org>; Thu, 17 Oct 2013 13:23:52 -0700 (PDT)
Date: Thu, 17 Oct 2013 13:23:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] readahead: fix sequential read cache miss detection
Message-Id: <20131017132348.a89c6cb5222eda83fb0ce079@linux-foundation.org>
In-Reply-To: <1382033352-21225-1-git-send-email-damien.ramonda@intel.com>
References: <1382033352-21225-1-git-send-email-damien.ramonda@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Damien Ramonda <damien.ramonda@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, pierre.tardy@intel.com, fengguang.wu@intel.com, david.a.cohen@intel.com

On Thu, 17 Oct 2013 20:09:12 +0200 Damien Ramonda <damien.ramonda@intel.com> wrote:

> The kernel's readahead algorithm sometimes interprets random read
> accesses as sequential and triggers unnecessary data prefecthing
> from storage device (impacting random read average latency).
> 
> In order to identify sequential cache read misses, the readahead
> algorithm intends to check whether offset - previous offset == 1
> (trivial sequential reads) or offset - previous offset == 0
> (sequential reads not aligned on page boundary):
> 
> if (offset - (ra->prev_pos >> PAGE_CACHE_SHIFT) <= 1UL)
> 
> The current offset is stored in the "offset" variable of type
> "pgoff_t" (unsigned long), while previous offset is stored in
> "ra->prev_pos" of type "loff_t" (long long). Therefore,
> operands of the if statement are implicitly converted to type
> long long. Consequently, when previous offset > current offset
> (which happens on random pattern), the if condition is true
> and access is wrongly interpeted as sequential. An unnecessary
> data prefetching is triggered, impacting the average
> random read latency.
> 
> Storing the previous offset value in a "pgoff_t" variable
> (unsigned long) fixes the sequential read detection logic.

Do you have any performance testing results which would permit
people to understand the significance of this change?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
