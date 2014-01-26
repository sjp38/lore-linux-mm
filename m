Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f50.google.com (mail-bk0-f50.google.com [209.85.214.50])
	by kanga.kvack.org (Postfix) with ESMTP id 792E06B0035
	for <linux-mm@kvack.org>; Sat, 25 Jan 2014 22:12:42 -0500 (EST)
Received: by mail-bk0-f50.google.com with SMTP id w16so2117459bkz.37
        for <linux-mm@kvack.org>; Sat, 25 Jan 2014 19:12:41 -0800 (PST)
Received: from mail-bk0-x22b.google.com (mail-bk0-x22b.google.com [2a00:1450:4008:c01::22b])
        by mx.google.com with ESMTPS id ch10si8901117bkc.237.2014.01.25.19.12.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 25 Jan 2014 19:12:41 -0800 (PST)
Received: by mail-bk0-f43.google.com with SMTP id mx11so2110316bkb.16
        for <linux-mm@kvack.org>; Sat, 25 Jan 2014 19:12:41 -0800 (PST)
Date: Sat, 25 Jan 2014 19:12:35 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch for-3.14] mm, mempolicy: fix mempolicy printing in
 numa_maps
Message-ID: <alpine.DEB.2.02.1401251902180.3140@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

As a result of commit 5606e3877ad8 ("mm: numa: Migrate on reference 
policy"), /proc/<pid>/numa_maps prints the mempolicy for any <pid> as 
"prefer:N" for the local node, N, of the process reading the file.

This should only be printed when the mempolicy of <pid> is MPOL_PREFERRED 
for node N.

If the process is actually only using the default mempolicy for local node 
allocation, make sure "default" is printed as expected.

Reported-by: Robert Lippert <rlippert@google.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 This affects all 3.7+ kernels and is intended for stable but will need to
 be rebased after it's merged since mpol_to_str() has subsequently
 changed.  I'll rebase and propose it separately.

 mm/mempolicy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2926,7 +2926,7 @@ void mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol)
 	unsigned short mode = MPOL_DEFAULT;
 	unsigned short flags = 0;
 
-	if (pol && pol != &default_policy) {
+	if (pol && pol != &default_policy && !(pol->flags & MPOL_F_MORON)) {
 		mode = pol->mode;
 		flags = pol->flags;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
