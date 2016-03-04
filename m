Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6B7A06B007E
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 11:05:23 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id l68so26452713wml.0
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 08:05:23 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s6si4643568wju.74.2016.03.04.08.05.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 04 Mar 2016 08:05:22 -0800 (PST)
Date: Fri, 4 Mar 2016 17:05:19 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm,oom: Do not sleep with oom_lock held.
Message-ID: <20160304160519.GG31257@dhcp22.suse.cz>
References: <201603031941.CBC81272.OtLMSFVOFJHOFQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201603031941.CBC81272.OtLMSFVOFJHOFQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org

On Thu 03-03-16 19:42:00, Tetsuo Handa wrote:
> Michal, before we think about whether to add preempt_disable()/preempt_enable_no_resched()
> to oom_kill_process(), will you accept this patch?
> This is one of problems which annoy kmallocwd patch on CONFIG_PREEMPT_NONE=y kernels.

I dunno. It makes the code worse and it doesn't solve the underlying
problem (have a look at OOM notifiers which are blockable). Also
!PREEMPT only solution doesn't sound very useful as most of the
configurations will have PREEMPT enabled. I agree that having the OOM
killer preemptible is far from ideal, though, but this is harder than
just this sleep. Long term we should focus on making the oom context
not preemptible.

Anyway, wouldn't this be simpler?

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5d5eca9d6737..c84e7841007e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -901,15 +901,9 @@ bool out_of_memory(struct oom_control *oc)
 		dump_header(oc, NULL, NULL);
 		panic("Out of memory and no killable processes...\n");
 	}
-	if (p && p != (void *)-1UL) {
+	if (p && p != (void *)-1UL)
 		oom_kill_process(oc, p, points, totalpages, NULL,
 				 "Out of memory");
-		/*
-		 * Give the killed process a good chance to exit before trying
-		 * to allocate memory again.
-		 */
-		schedule_timeout_killable(1);
-	}
 	return true;
 }
 
@@ -944,4 +938,10 @@ void pagefault_out_of_memory(void)
 	}
 
 	mutex_unlock(&oom_lock);
+
+	/*
+	 * Give the killed process a good chance to exit before trying
+	 * to allocate memory again.
+	 */
+	schedule_timeout_killable(1);
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1993894b4219..496498c4c32c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2888,6 +2881,13 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	}
 out:
 	mutex_unlock(&oom_lock);
+	if (*did_some_progress) {
+		/*
+		 * Give the killed process a good chance to exit before trying
+		 * to allocate memory again.
+		 */
+		schedule_timeout_killable(1);
+	}
 	return page;
 }
 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
