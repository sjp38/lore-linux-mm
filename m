Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 54D906B04EA
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 06:16:50 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id v84so413973000oie.0
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 03:16:50 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id y127si8064626oia.57.2016.11.21.03.16.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 21 Nov 2016 03:16:49 -0800 (PST)
Subject: Re: [PATCH] mm/page_alloc: Don't fail costly __GFP_NOFAIL allocations.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1479387004-5998-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20161121060313.GB29816@dhcp22.suse.cz>
In-Reply-To: <20161121060313.GB29816@dhcp22.suse.cz>
Message-Id: <201611212016.GGG52176.LSOVtOHJFMQFFO@I-love.SAKURA.ne.jp>
Date: Mon, 21 Nov 2016 20:16:40 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, stable@vger.kernel.org

Michal Hocko wrote:
> On Thu 17-11-16 21:50:04, Tetsuo Handa wrote:
> > Filesystem code might request costly __GFP_NOFAIL !__GFP_REPEAT GFP_NOFS
> > allocations. But commit 0a0337e0d1d13446 ("mm, oom: rework oom detection")
> > overlooked that __GFP_NOFAIL allocation requests need to invoke the OOM
> > killer and retry even if order > PAGE_ALLOC_COSTLY_ORDER && !__GFP_REPEAT.
> > The caller will crash if such allocation request failed.
>
> Could you point to such an allocation request please? Costly GFP_NOFAIL
> requests are a really high requirement and I am even not sure we should
> support them. buffered_rmqueue already warns about order > 1 NOFAIL
> allocations.

That question is pointless. You are simply lucky that you see only order 0 or
order 1. There are many __GFP_NOFAIL allocations where order is determined at
runtime. There is no guarantee that order 2 and above never happens.
http://lkml.kernel.org/r/56F8F5DA.6040206@kyup.com is a case where an XFS user
had trouble due to order 4 and order 5 allocations because XFS uses opencoded
endless loop around allocator than __GFP_NOFAIL.

There is WARN_ON_ONCE((gfp_flags & __GFP_NOFAIL) && (order > 1)); in
buffered_rmqueue(), but there is no guarantee that the caller hits this
warning. It is theoretically possible that order > PAGE_ALLOC_COSTLY_ORDER &&
__GFP_NOFAIL && !__GFP_REPEAT allocation requests fail to call buffered_rmqueue()
 from get_page_from_freelist() due to "continue;" statements around zone
watermark checks. It is possible that an order == 2 && __GFP_NOFAIL allocation
reuest hit this WARN_ON_ONCE() and subsequent order > PAGE_ALLOC_COSTLY_ORDER &&
__GFP_NOFAIL && !__GFP_REPEAT allocation requests no longer hits this WARN_ON_ONCE().

So, you want to mess up the definition of __GFP_NOFAIL like below?
I think my patch is better than below change.

--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -138,9 +138,16 @@
  * __GFP_NOFAIL: The VM implementation _must_ retry infinitely: the caller
  *   cannot handle allocation failures. New users should be evaluated carefully
  *   (and the flag should be used only when there is no reasonable failure
  *   policy) but it is definitely preferable to use the flag rather than
- *   opencode endless loop around allocator.
+ *   opencode endless loop around allocator. However, the VM implementation
+ *   is allowed to fail if order > PAGE_ALLOC_COSTLY_ORDER but __GFP_REPEAT
+ *   is not set. That is, all users which specify __GFP_NOFAIL with order
+ *   determined at runtime (e.g. sizeof(struct) * num_elements) had better
+ *   specify __GFP_REPEAT as well, for the VM implementation does not invoke
+ *   the OOM killer unless __GFP_REPEAT is also specified and the caller has
+ *   to be prepared for allocation failures using opencode endless loop
+ *   around allocator.
  *
  * __GFP_NORETRY: The VM implementation must not retry indefinitely and will
  *   return NULL when direct reclaim and memory compaction have failed to allow
  *   the allocation to succeed.  The OOM killer is not called with the current

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
