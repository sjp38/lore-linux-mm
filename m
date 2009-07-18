Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6EAF86B004F
	for <linux-mm@kvack.org>; Sat, 18 Jul 2009 06:58:23 -0400 (EDT)
Date: Sat, 18 Jul 2009 10:57:35 GMT
From: tip-bot for Mel Gorman <mel@csn.ul.ie>
Reply-To: mingo@redhat.com, hpa@zytor.com, acme@redhat.com,
        linux-kernel@vger.kernel.org, mel@csn.ul.ie, davem@davemloft.net,
        akpm@linux-foundation.org, htd@fancy-poultry.org, tglx@linutronix.de,
        kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, mingo@elte.hu
In-Reply-To: <1247656992-19846-3-git-send-email-mel@csn.ul.ie>
References: <1247656992-19846-3-git-send-email-mel@csn.ul.ie>
Subject: [tip:tracing/urgent] profile: Suppress warning about large allocations when profile=1 is specified
Message-ID: <tip-e5d490b252423605a77c54b2e35b10ea663763df@git.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-tip-commits@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, acme@redhat.com, hpa@zytor.com, mingo@redhat.com, mel@csn.ul.ie, davem@davemloft.net, akpm@linux-foundation.org, htd@fancy-poultry.org, tglx@linutronix.de, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

Commit-ID:  e5d490b252423605a77c54b2e35b10ea663763df
Gitweb:     http://git.kernel.org/tip/e5d490b252423605a77c54b2e35b10ea663763df
Author:     Mel Gorman <mel@csn.ul.ie>
AuthorDate: Wed, 15 Jul 2009 12:23:11 +0100
Committer:  Ingo Molnar <mingo@elte.hu>
CommitDate: Sat, 18 Jul 2009 12:55:28 +0200

profile: Suppress warning about large allocations when profile=1 is specified

When profile= is used, a large buffer is allocated early at
boot. This can be larger than what the page allocator can
provide so it prints a warning. However, the caller is able to
handle the situation so this patch suppresses the warning.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>
Cc: Heinz Diehl <htd@fancy-poultry.org>
Cc: David Miller <davem@davemloft.net>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>
LKML-Reference: <1247656992-19846-3-git-send-email-mel@csn.ul.ie>
Signed-off-by: Ingo Molnar <mingo@elte.hu>


---
 kernel/profile.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/kernel/profile.c b/kernel/profile.c
index 69911b5..419250e 100644
--- a/kernel/profile.c
+++ b/kernel/profile.c
@@ -117,11 +117,12 @@ int __ref profile_init(void)
 
 	cpumask_copy(prof_cpu_mask, cpu_possible_mask);
 
-	prof_buffer = kzalloc(buffer_bytes, GFP_KERNEL);
+	prof_buffer = kzalloc(buffer_bytes, GFP_KERNEL|__GFP_NOWARN);
 	if (prof_buffer)
 		return 0;
 
-	prof_buffer = alloc_pages_exact(buffer_bytes, GFP_KERNEL|__GFP_ZERO);
+	prof_buffer = alloc_pages_exact(buffer_bytes,
+					GFP_KERNEL|__GFP_ZERO|__GFP_NOWARN);
 	if (prof_buffer)
 		return 0;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
