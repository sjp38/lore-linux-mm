Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 015226B0069
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 05:50:44 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id n68so485025112itn.4
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 02:50:43 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id b186si793686itg.91.2017.01.05.02.50.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Jan 2017 02:50:43 -0800 (PST)
Subject: Re: [PATCH 0/3 -v3] GFP_NOFAIL cleanups
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170103084211.GB30111@dhcp22.suse.cz>
	<201701032338.EFH69294.VOMSHFLOFOtQFJ@I-love.SAKURA.ne.jp>
	<20170103204014.GA13873@dhcp22.suse.cz>
	<201701042322.EEG05759.FOMOVLSFJFHOQt@I-love.SAKURA.ne.jp>
	<20170104152043.GQ25453@dhcp22.suse.cz>
In-Reply-To: <20170104152043.GQ25453@dhcp22.suse.cz>
Message-Id: <201701051950.EAB48947.FFVSHOOQMJtLFO@I-love.SAKURA.ne.jp>
Date: Thu, 5 Jan 2017 19:50:23 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, rientjes@google.com, mgorman@suse.de, hillf.zj@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> > > Stop this! Seriously... This is just wasting time...
> > 
> > You are free to ignore me. But
> 
> my last reply in this subthread
> 

OK. You can ignore me; I just won't give my Acked-by: or Reviewed-by: to this series.

My understanding is that we changed to tolerate __GFP_NOFAIL usage because
allocation failure leads to unacceptable side effect (e.g. remounting
read-only, kernel panic) rather than allocation helps reclaiming memory.

  commit 647757197cd34fae ("mm: clarify __GFP_NOFAIL deprecation status")
  commit 277fb5fc177dc467 ("btrfs: use __GFP_NOFAIL in alloc_btrfs_bio")

I don't know whether __GFP_NOFAIL users are using __GFP_NOFAIL based on
whether it helps reclaiming memory rather than whether allocation failure
leads to unacceptable side effect, if we allow access to memory reserves
based on __GFP_NOFAIL.

  commit 7444a072c387a93e ("ext4: replace open coded nofail allocation in ext4_free_blocks()")
  commit adb7ef600cc9d9d1 ("ext4: use __GFP_NOFAIL in ext4_free_blocks()")
  commit c9af28fdd44922a6 ("ext4 crypto: don't let data integrity writebacks fail with ENOMEM")
  commit b32e4482aadfd132 ("fscrypto: don't let data integrity writebacks fail with ENOMEM")
  commit 80c545055dc7c1f7 ("f2fs: use __GFP_NOFAIL to avoid infinite loop")

If __GFP_NOFAIL users are using __GFP_NOFAIL based on whether allocation failure
leads to unacceptable side effect, allowing access to memory reserves based on
__GFP_NOFAIL might not help reclaiming memory; something like scope GFP_NOFS API
will be needed.

Anyway, I suggest merging description update shown below into this series and
getting confirmation from all existing __GFP_NOFAIL users. If all existing
__GFP_NOFAIL users are OK with this series (in other words, informed the risk
caused by this series), I'm also OK with this series.

--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -135,16 +135,24 @@
  * __GFP_REPEAT: Try hard to allocate the memory, but the allocation attempt
  *   _might_ fail.  This depends upon the particular VM implementation.
  *
- * __GFP_NOFAIL: The VM implementation _must_ retry infinitely: the caller
- *   cannot handle allocation failures. New users should be evaluated carefully
- *   (and the flag should be used only when there is no reasonable failure
- *   policy) but it is definitely preferable to use the flag rather than
- *   opencode endless loop around allocator.
- *
- * __GFP_NORETRY: The VM implementation must not retry indefinitely and will
- *   return NULL when direct reclaim and memory compaction have failed to allow
- *   the allocation to succeed.  The OOM killer is not called with the current
- *   implementation.
+ * __GFP_NOFAIL: The VM implementation must not give up even after direct
+ *   reclaim and memory compaction have failed to allow the allocation to
+ *   succeed. Note that since the OOM killer is not called with the current
+ *   implementation when direct reclaim and memory compaction have failed to
+ *   allow the allocation to succeed unless __GFP_FS is also used (and some
+ *   other conditions are met), e.g. GFP_NOFS | __GFP_NOFAIL allocation has
+ *   possibility of lockup. To reduce the possibility of lockup, __GFP_HIGH is
+ *   implicitly granted by the current implementation if __GFP_NOFAIL is used.
+ *   New users of __GFP_NOFAIL should be evaluated carefully (and __GFP_NOFAIL
+ *   should be used only when there is no reasonable failure policy) but it is
+ *   definitely preferable to use __GFP_NOFAIL rather than opencode endless
+ *   loop around allocator, for a stall detection check inside allocator will
+ *   likely be able to emit possible lockup warnings unless __GFP_NOWARN is
+ *   also used.
+ *
+ * __GFP_NORETRY: The VM implementation must give up as soon as direct reclaim
+ *   and memory compaction have failed to allow the allocation to succeed.
+ *   Therefore, __GFP_NORETRY cannot be used with __GFP_NOFAIL.
  */
 #define __GFP_IO	((__force gfp_t)___GFP_IO)
 #define __GFP_FS	((__force gfp_t)___GFP_FS)

I do not like "mm, oom: get rid of TIF_MEMDIE" series because you have not
gotten confirmation from all users who might be affected (e.g. start failing
inside do_exit() which currently do not fail) by that series. If you clarify
possible side effects and get confirmation from affected users (in case some
users might need to add __GFP_NOFAIL), I will be OK with that series as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
