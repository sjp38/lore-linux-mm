Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id ECA306B0038
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 08:19:13 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id u144so13293813wmu.1
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 05:19:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ek8si44278608wjd.74.2016.12.12.05.19.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Dec 2016 05:19:12 -0800 (PST)
Date: Mon, 12 Dec 2016 14:19:11 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161212131910.GC3185@dhcp22.suse.cz>
References: <20161208132714.GA26530@dhcp22.suse.cz>
 <201612092323.BGC65668.QJFVLtFFOOMOSH@I-love.SAKURA.ne.jp>
 <20161209144624.GB4334@dhcp22.suse.cz>
 <201612102024.CBB26549.SJFOOtOVMFFQHL@I-love.SAKURA.ne.jp>
 <20161212090702.GD18163@dhcp22.suse.cz>
 <201612122112.IBI64512.FOVOFQFLMJHOtS@I-love.SAKURA.ne.jp>
 <20161212125535.GA3185@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161212125535.GA3185@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, pmladek@suse.cz, sergey.senozhatsky@gmail.com

On Mon 12-12-16 13:55:35, Michal Hocko wrote:
> On Mon 12-12-16 21:12:06, Tetsuo Handa wrote:
> > Michal Hocko wrote:
[...]
> > > > I think this warn_alloc() is too much noise. When something went
> > > > wrong, multiple instances of Thread-2 tend to call warn_alloc()
> > > > concurrently. We don't need to report similar memory information.
> > > 
> > > That is why we have ratelimitting. It is needs a better tunning then
> > > just let's do it.
> > 
> > I think that calling show_mem() once per a series of warn_alloc() threads is
> > sufficient. Since the amount of output by dump_stack() and that by show_mem()
> > are nearly equals, we can save nearly 50% of output if we manage to avoid
> > the same show_mem() calls.
> 
> I do not mind such an update. Again, that is what we have the
> ratelimitting for. The fact that it doesn't throttle properly means that
> we should tune its parameters.

What about the following? Does this help?
---
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c52268786027..54348e5a5377 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3003,9 +3003,12 @@ static inline bool should_suppress_show_mem(void)
 	return ret;
 }
 
-static DEFINE_RATELIMIT_STATE(nopage_rs,
-		DEFAULT_RATELIMIT_INTERVAL,
-		DEFAULT_RATELIMIT_BURST);
+/*
+ * Do not swamp logs with allocation failures details
+ * Once per second should be more than enough to get an
+ * overview what is going on
+ */
+static DEFINE_RATELIMIT_STATE(nopage_rs, HZ, 1);
 
 void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
 {
@@ -3013,7 +3016,7 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
 	struct va_format vaf;
 	va_list args;
 
-	if ((gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs) ||
+	if ((gfp_mask & __GFP_NOWARN) ||
 	    debug_guardpage_minorder() > 0)
 		return;
 
@@ -3040,7 +3043,7 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
 	pr_cont(", mode:%#x(%pGg)\n", gfp_mask, &gfp_mask);
 
 	dump_stack();
-	if (!should_suppress_show_mem())
+	if (!should_suppress_show_mem() || __ratelimit(&nopage_rs))
 		show_mem(filter);
 }
 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
