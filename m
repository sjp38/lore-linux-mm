Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 4F4216B0070
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 08:55:44 -0500 (EST)
Received: by wivr20 with SMTP id r20so14982999wiv.2
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 05:55:44 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x3si7014424wie.105.2015.03.02.05.55.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Mar 2015 05:55:36 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC 3/4] sparc: remove __GFP_NOFAIL reuquirement
Date: Mon,  2 Mar 2015 14:54:42 +0100
Message-Id: <1425304483-7987-4-git-send-email-mhocko@suse.cz>
In-Reply-To: <1425304483-7987-1-git-send-email-mhocko@suse.cz>
References: <1425304483-7987-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Vipul Pandya <vipul@chelsio.com>, netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

mdesc_kmalloc is currently requiring __GFP_NOFAIL allocation although it
seems that the allocation failure is handled by all callers (via
mdesc_alloc). __GFP_NOFAIL is a strong liability for the memory
allocator and so the users are discouraged to use the flag unless the
allocation failure is really a nogo. Drop the flag here as this doesn't
seem to be the case.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 arch/sparc/kernel/mdesc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/sparc/kernel/mdesc.c b/arch/sparc/kernel/mdesc.c
index 99632a87e697..6801bd778af2 100644
--- a/arch/sparc/kernel/mdesc.c
+++ b/arch/sparc/kernel/mdesc.c
@@ -136,7 +136,7 @@ static struct mdesc_handle *mdesc_kmalloc(unsigned int mdesc_size)
 		       sizeof(struct mdesc_hdr) +
 		       mdesc_size);
 
-	base = kmalloc(handle_size + 15, GFP_KERNEL | __GFP_NOFAIL);
+	base = kmalloc(handle_size + 15, GFP_KERNEL);
 	if (base) {
 		struct mdesc_handle *hp;
 		unsigned long addr;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
