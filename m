Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 145EF6B0069
	for <linux-mm@kvack.org>; Sun, 11 Dec 2016 06:24:05 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id n184so129260718oig.1
        for <linux-mm@kvack.org>; Sun, 11 Dec 2016 03:24:05 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id m16si19923398otb.176.2016.12.11.03.24.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 11 Dec 2016 03:24:03 -0800 (PST)
Subject: Re: [PATCH 2/2] mm, oom: do not enfore OOM killer for __GFP_NOFAIL automatically
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20161205141009.GJ30758@dhcp22.suse.cz>
	<201612061938.DDD73970.QFHOFJStFOLVOM@I-love.SAKURA.ne.jp>
	<20161206192242.GA10273@dhcp22.suse.cz>
	<201612082153.BHC81241.VtMFFHOLJOOFSQ@I-love.SAKURA.ne.jp>
	<20161208134718.GC26530@dhcp22.suse.cz>
In-Reply-To: <20161208134718.GC26530@dhcp22.suse.cz>
Message-Id: <201612112023.HBB57332.QOFFtJLOOMFSVH@I-love.SAKURA.ne.jp>
Date: Sun, 11 Dec 2016 20:23:47 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, vbabka@suse.cz, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Thu 08-12-16 21:53:44, Tetsuo Handa wrote:
> > If we could agree
> > with calling __alloc_pages_nowmark() before out_of_memory() if __GFP_NOFAIL
> > is given, we can avoid locking up while minimizing possibility of invoking
> > the OOM killer...
>
> I do not understand. We do __alloc_pages_nowmark even when oom is called
> for GFP_NOFAIL.

Where is that? I can find __alloc_pages_nowmark() after out_of_memory()
if __GFP_NOFAIL is given, but I can't find __alloc_pages_nowmark() before
out_of_memory() if __GFP_NOFAIL is given.

What I mean is below patch folded into
"[PATCH 1/2] mm: consolidate GFP_NOFAIL checks in the allocator slowpath".

--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3057,6 +3057,25 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
 }
 
 static inline struct page *
+__alloc_pages_nowmark(gfp_t gfp_mask, unsigned int order,
+                        const struct alloc_context *ac)
+{
+    struct page *page;
+
+    page = get_page_from_freelist(gfp_mask, order,
+            ALLOC_NO_WATERMARKS|ALLOC_CPUSET, ac);
+    /*
+     * fallback to ignore cpuset restriction if our nodes
+     * are depleted
+     */
+    if (!page)
+        page = get_page_from_freelist(gfp_mask, order,
+                ALLOC_NO_WATERMARKS, ac);
+
+    return page;
+}
+
+static inline struct page *
 __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
     const struct alloc_context *ac, unsigned long *did_some_progress)
 {
@@ -3118,21 +3137,8 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
             goto out;
     }
     /* Exhausted what can be done so it's blamo time */
-    if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
+    if (out_of_memory(&oc))
         *did_some_progress = 1;
-
-        if (gfp_mask & __GFP_NOFAIL) {
-            page = get_page_from_freelist(gfp_mask, order,
-                    ALLOC_NO_WATERMARKS|ALLOC_CPUSET, ac);
-            /*
-             * fallback to ignore cpuset restriction if our nodes
-             * are depleted
-             */
-            if (!page)
-                page = get_page_from_freelist(gfp_mask, order,
-                    ALLOC_NO_WATERMARKS, ac);
-        }
-    }
 out:
     mutex_unlock(&oom_lock);
     return page;
@@ -3738,6 +3744,19 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
          */
         WARN_ON_ONCE(order > PAGE_ALLOC_COSTLY_ORDER);
 
+        /*
+         * Help non-failing allocations by giving them access to memory
+         * reserves
+         */
+        page = __alloc_pages_nowmark(gfp_mask, order, ac);
+        if (page)
+            goto got_pg;
+
+        /* Memory reserves did not help. Start killing things. */
+        page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
+        if (page)
+            goto got_pg;
+
         cond_resched();
         goto retry;
     }

> > Therefore,
> >
> > > If you believe that my argumentation is incorrect then you are free to
> > > nak the patch with your reasoning. But please stop this nit picking on
> > > nonsense combination of flags.
> >
> > Nacked-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> >
> > on patch 2 unless "you explain these patches to __GFP_NOFAIL users and
> > provide a mean to invoke the OOM killer if someone chose possibility of
> > panic"
>
> I believe that the changelog contains my reasoning and so far I
> haven't heard any _argument_ from you why they are wrong. You just
> managed to nitpick on an impossible and pointless gfp_mask combination
> and some handwaving on possible lockups without any backing arguments.
> This is not something I would consider as a basis for a serious nack. So
> if you really hate this patch then do please start being reasonable and
> put some real arguments into your review without any off topics and/or
> strawman arguments without any relevance.
>

Are you aware that I'm not objecting to "change __GFP_NOFAIL not to invoke
the OOM killer". What I'm objecting is that you are trying to change
!__GFP_FS && !__GFP_NOFAIL allocation requests without offering transition
plan like below.

--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -1013,7 +1013,7 @@ bool out_of_memory(struct oom_control *oc)
      * make sure exclude 0 mask - all other users should have at least
      * ___GFP_DIRECT_RECLAIM to get here.
      */
-    if (oc->gfp_mask && !(oc->gfp_mask & (__GFP_FS|__GFP_NOFAIL)))
+    if (oc->gfp_mask && !(oc->gfp_mask & (__GFP_FS|__GFP_WANT_OOM_KILLER))
         return true;
 
     /*

If you do want to push

--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -1013,7 +1013,7 @@ bool out_of_memory(struct oom_control *oc)
      * make sure exclude 0 mask - all other users should have at least
      * ___GFP_DIRECT_RECLAIM to get here.
      */
-    if (oc->gfp_mask && !(oc->gfp_mask & (__GFP_FS|__GFP_NOFAIL)))
+    if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS))
         return true;
 
     /*

change, ask existing __GFP_NOFAIL users with explanations like below

  I believe that __GFP_NOFAIL should not imply invocation of the OOM killer.
  Therefore, I want to change __GFP_NOFAIL not to invoke the OOM killer.
  But since currently the OOM killer is not invoked unless either __GFP_FS or
  __GFP_NOFAIL is specified, changing __GFP_NOFAIL not to invoke the OOM
  killer introduces e.g. GFP_NOFS | __GFP_NOFAIL users a risk of livelocking
  by not invoking the OOM killer. Although I can't prove that this change
  never causes livelock, I don't want to provide an alternative flag like
  __GFP_WANT_OOM_KILLER. Therefore, all existing __GFP_NOFAIL users must
  agree with accepting the risk introduced by this change.

and confirm that all existing __GFP_NOFAIL users are willing to accept
the risk of livelocking by not invoking the OOM killer.

Unless you do this procedure, I continue:

Nacked-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

> > or "you accept kmallocwd".
>
> Are you serious? Are you really suggesting that your patch has to be
> accepted in order to have this one in?

I'm surprised you think my kmallocwd as a choice for applying this patch,
for I was assuming that you choose the procedure above which is super
straightforward.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
