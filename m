Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id CAFC26B0253
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 10:47:32 -0500 (EST)
Received: by wmww144 with SMTP id w144so27765932wmw.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 07:47:32 -0800 (PST)
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id m10si50906615wmg.110.2015.12.03.07.47.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Dec 2015 07:47:31 -0800 (PST)
Received: by wmww144 with SMTP id w144so27765083wmw.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 07:47:31 -0800 (PST)
Date: Thu, 3 Dec 2015 16:47:29 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: memcg uncharge page counter mismatch
Message-ID: <20151203154729.GI9264@dhcp22.suse.cz>
References: <20151201133455.GB27574@bbox>
 <20151202101643.GC25284@dhcp22.suse.cz>
 <20151203013404.GA30779@bbox>
 <20151203021006.GA31041@bbox>
 <20151203085451.GC9264@dhcp22.suse.cz>
 <20151203125950.GA1428@bbox>
 <20151203133719.GF9264@dhcp22.suse.cz>
 <20151203134326.GG9264@dhcp22.suse.cz>
 <20151203145850.GH9264@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151203145850.GH9264@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 03-12-15 15:58:50, Michal Hocko wrote:
[....]
> Warning, this looks ugly as hell.

I was thinking about it some more and it seems that we should rather not
bother with partial thp at all and keep it in the original memcg
instead. It is way much less code and I do not think this will be too
disruptive. Somebody should be holding the thp head, right?

Minchan, does this fix the issue you are seeing.
---
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
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
