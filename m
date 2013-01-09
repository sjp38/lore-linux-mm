Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 3E18C6B005A
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 07:04:51 -0500 (EST)
Date: Wed, 9 Jan 2013 12:04:47 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: migrate: Check page_count of THP before migrating
 accounting fix
Message-ID: <20130109120447.GB13304@suse.de>
References: <20130107170815.GO3885@suse.de>
 <alpine.LNX.2.00.1301081931530.20504@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1301081931530.20504@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

As pointed out by Hugh Dickins, "mm: migrate: Check page_count of THP
before migrating" can leave nr_isolated_anon elevated, correct it. This
is a fix to mm-migrate-check-page_count-of-thp-before-migrating.patch

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/migrate.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index f466827..c387786 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1689,8 +1689,11 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	if (!isolated || page_count(page) != 2) {
 		count_vm_events(PGMIGRATE_FAIL, HPAGE_PMD_NR);
 		put_page(new_page);
-		if (isolated)
+		if (isolated) {
 			putback_lru_page(page);
+			isolated = 0;
+			goto out;
+		}
 		goto out_keep_locked;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
