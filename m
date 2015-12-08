Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 137476B0253
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 12:13:20 -0500 (EST)
Received: by wmww144 with SMTP id w144so38368331wmw.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 09:13:19 -0800 (PST)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id y83si6171902wmb.27.2015.12.08.09.13.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 09:13:19 -0800 (PST)
Received: by wmww144 with SMTP id w144so38367735wmw.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 09:13:18 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH mmotm] memcg: Ignore partial THP when moving task
Date: Tue,  8 Dec 2015 18:13:09 +0100
Message-Id: <1449594789-15866-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

After "mm: rework mapcount accounting to enable 4k mapping of THPs"
it is possible to have a partial THP accessible via ptes. Memcg task
migration code is not prepared for this situation and uncharges the tail
page from the original memcg while the original THP is still charged via
the head page which is not mapped to the moved task. The page counter
of the origin memcg will underflow when the whole THP is uncharged later
on and lead to:
WARNING: CPU: 0 PID: 1340 at mm/page_counter.c:26 page_counter_cancel+0x34/0x40()
reported by Minchan Kim.

This patch prevents from the underflow by skipping any partial THP pages
in mem_cgroup_move_charge_pte_range. PageTransCompound is checked when
we do pte walk. This means that a process might leave a partial THP
behind in the original memcg if there is no other process mapping it via
pmd but this is considered acceptable because it shouldn't happen often
and this is not considered a memory leak because the original THP is
still accessible and reclaimable. Moreover the task migration has always
been racy and never guaranteed to move all pages.

Reported-by: Minchan Kim <minchan@kernel.org>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Hi,
this is a patch tested by Minchan in the original thread [1]. I have
only replaced PageCompound with PageTransCompound because other similar
fixes in mmotm used this one. The underlying implementation is the same.
Johannes, I have kept your a-b but let me know if you are not OK with the
changelog.

This is mmotm only material. It can be merged into the page which
has introduced the issue but maybe it is worth having on its own for
documentation purposes. I will leave the decision to you Andrew.

[1] http://lkml.kernel.org/r/20151201133455.GB27574@bbox

 mm/memcontrol.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 79a29d564bff..143c933f0b81 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4895,6 +4895,14 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 		switch (get_mctgt_type(vma, addr, ptent, &target)) {
 		case MC_TARGET_PAGE:
 			page = target.page;
+			/*
+			 * We can have a part of the split pmd here. Moving it
+			 * can be done but it would be too convoluted so simply
+			 * ignore such a partial THP and keep it in original
+			 * memcg. There should be somebody mapping the head.
+			 */
+			if (PageCompound(page))
+				goto put;
 			if (isolate_lru_page(page))
 				goto put;
 			if (!mem_cgroup_move_account(page, false,
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
