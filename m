Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 16F926B0038
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 08:26:37 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id q25so8728675ioh.5
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 05:26:37 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id p135si4843588iop.329.2017.12.01.05.26.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Dec 2017 05:26:36 -0800 (PST)
Subject: Re: [PATCH] mm, oom: simplify alloc_pages_before_oomkill handling
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20171130152824.1591-1-guro@fb.com>
	<20171201091425.ekrpxsmkwcusozua@dhcp22.suse.cz>
In-Reply-To: <20171201091425.ekrpxsmkwcusozua@dhcp22.suse.cz>
Message-Id: <201712012226.JAC87573.FLtJVOOOFFSMQH@I-love.SAKURA.ne.jp>
Date: Fri, 1 Dec 2017 22:26:23 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, guro@fb.com
Cc: linux-mm@vger.kernel.org, vdavydov.dev@gmail.com, hannes@cmpxchg.org, rientjes@google.com, akpm@linux-foundation.org, tj@kernel.org, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Michal Hocko wrote:
> Recently added alloc_pages_before_oomkill gained new caller with this
> patchset and I think it just grown to deserve a simpler code flow.
> What do you think about this on top of the series?

I'm planning to post below patch in order to mitigate OOM lockup problem
caused by scheduling priority. But I'm OK with your patch because your patch
will not conflict with below patch.

----------
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b2746a7..ef6e951 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3332,13 +3332,14 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 	*did_some_progress = 0;
 
 	/*
-	 * Acquire the oom lock.  If that fails, somebody else is
-	 * making progress for us.
+	 * Acquire the oom lock. If that fails, give enough CPU time to the
+	 * owner of the oom lock in order to help reclaiming memory.
 	 */
-	if (!mutex_trylock(&oom_lock)) {
-		*did_some_progress = 1;
+	while (!mutex_trylock(&oom_lock)) {
+		page = alloc_pages_before_oomkill(oc);
+		if (page)
+			return page;
 		schedule_timeout_uninterruptible(1);
-		return NULL;
 	}
 
 	/* Coredumps can quickly deplete all memory reserves */
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
