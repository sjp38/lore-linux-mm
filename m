Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 2B8CE6B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 04:39:34 -0400 (EDT)
Date: Tue, 16 Oct 2012 09:39:27 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: compaction: Correct the nr_strict_isolated check for CMA
Message-ID: <20121016083927.GG29125@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>, QEMU-devel <qemu-devel@nongnu.org>, KVM <kvm@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Arm Kernel Mailing List <linux-arm-kernel@lists.infradead.org>

Thierry reported that the "iron out" patch for isolate_freepages_block()
had problems due to the strict check being too strict with "mm: compaction:
Iron out isolate_freepages_block() and isolate_freepages_range() -fix1".
It's possible that more pages than necessary are isolated but the check
still fails and I missed that this fix was not picked up before RC1. This
same problem has been identified in 3.7-RC1 by Tony Prisk and should be
addressed by the following patch.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Tested-by: Tony Prisk <linux@prisktech.co.nz>
---
 mm/compaction.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 2c4ce17..9eef558 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -346,7 +346,7 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 	 * pages requested were isolated. If there were any failures, 0 is
 	 * returned and CMA will fail.
 	 */
-	if (strict && nr_strict_required != total_isolated)
+	if (strict && nr_strict_required > total_isolated)
 		total_isolated = 0;
 
 	if (locked)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
