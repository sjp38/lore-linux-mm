Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id AA8CF6B066F
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 04:03:38 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id s21so556815oie.5
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 01:03:38 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z204si21389198oiz.14.2017.08.03.01.03.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Aug 2017 01:03:37 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm, oom: do not rely on TIF_MEMDIE for memory reserves access
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170727090357.3205-2-mhocko@kernel.org>
	<201708020030.ACB04683.JLHMFVOSFFOtOQ@I-love.SAKURA.ne.jp>
	<20170801165242.GA15518@dhcp22.suse.cz>
	<201708031039.GDG05288.OQJOHtLVFMSFFO@I-love.SAKURA.ne.jp>
	<20170803070606.GA12521@dhcp22.suse.cz>
In-Reply-To: <20170803070606.GA12521@dhcp22.suse.cz>
Message-Id: <201708031703.HGC35950.LSJFOHQFtFMOVO@I-love.SAKURA.ne.jp>
Date: Thu, 3 Aug 2017 17:03:20 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, guro@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> Look, I really appreciate your sentiment for for nommu platform but with
> an absolute lack of _any_ oom reports on that platform that I am aware
> of nor any reports about lockups during oom I am less than thrilled to
> add a code to fix a problem which even might not exist. Nommu is usually
> very special with a very specific workload running (e.g. no overcommit)
> so I strongly suspect that any OOM theories are highly academic.

If you believe that there is really no oom report, get rid of the OOM
killer completely.

> 
> All I do care about is to not regress nommu as much as possible. So can
> we get back to the proposed patch and updates I have done to address
> your review feedback please?

No unless we get rid of the OOM killer if CONFIG_MMU=n.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 170db4d..e931969 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3312,7 +3312,8 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 		goto out;
 
 	/* Exhausted what can be done so it's blamo time */
-	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
+	if ((IS_ENABLED(CONFIG_MMU) && out_of_memory(&oc)) ||
+		WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
 		*did_some_progress = 1;
 
 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
