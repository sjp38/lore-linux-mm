Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6219F6B006C
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 08:55:39 -0500 (EST)
Received: by wghl2 with SMTP id l2so33587715wgh.9
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 05:55:38 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ar2si22419969wjc.125.2015.03.02.05.55.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Mar 2015 05:55:35 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC 1/4] mm: Clarify __GFP_NOFAIL deprecation status
Date: Mon,  2 Mar 2015 14:54:40 +0100
Message-Id: <1425304483-7987-2-git-send-email-mhocko@suse.cz>
In-Reply-To: <1425304483-7987-1-git-send-email-mhocko@suse.cz>
References: <1425304483-7987-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Vipul Pandya <vipul@chelsio.com>, netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

__GFP_NOFAIL is documented as a deprecated flag since 478352e789f5 (mm:
add comment about deprecation of __GFP_NOFAIL). This has discouraged
people from using it but in some cases an opencoded endless loop around
allocator has been used instead. So the allocator is not aware of the
de facto __GFP_NOFAIL allocation because this information was not
communicated properly.

Let's make clear that if the allocation context really cannot effort
failure because there is no good failure policy then using __GFP_NOFAIL
is preferable to opencoding the loop outside of the allocator.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 include/linux/gfp.h | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 51bd1e72a917..0cf9c2772988 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -57,8 +57,10 @@ struct vm_area_struct;
  * _might_ fail.  This depends upon the particular VM implementation.
  *
  * __GFP_NOFAIL: The VM implementation _must_ retry infinitely: the caller
- * cannot handle allocation failures.  This modifier is deprecated and no new
- * users should be added.
+ * cannot handle allocation failures. New users should be evaluated carefuly
+ * (and the flag should be used only when there is no reasonable failure policy)
+ * but it is definitely preferable to use the flag rather than opencode endless
+ * loop around allocator.
  *
  * __GFP_NORETRY: The VM implementation must not retry indefinitely.
  *
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
