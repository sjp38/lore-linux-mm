Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CCE1C282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 23:32:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 105D020882
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 23:32:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 105D020882
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9FE28E0002; Tue, 29 Jan 2019 18:32:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4F3C8E0001; Tue, 29 Jan 2019 18:32:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 919548E0002; Tue, 29 Jan 2019 18:32:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 607958E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 18:32:29 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id 42so26398432qtr.7
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 15:32:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=9vDBEZLG4+YO5WeqcjfjQwEhDzv5QmaksQbvd29TOEo=;
        b=iEtzztPQQEYD5cFiARjm/16xImBLOC3HLdk9jdErI1mqFYpXiYRd6tuEZjR0vHWqrA
         ZctSVTRnt4z515k/AsXpSBOtZ/w1qk1/nCcBsnKUDiSB6zgQ/QKQRycKdv/mlt5GNFrm
         7WC2sbOKYpBaKb6NstnWhoAH23HBXdiZZORKVyClIoMGFR1Jx8yxjCh8sphr4TK4zGQH
         J66ZOLxF9SBYdnJeHhg0P/s1ZIBHtxbiuizocguh2SK/bBp8ZH0tKW2qOwRMuKVBt/vB
         FoFMd8/aTkSeOmgzWiGmo3zFjaQwOIO/wg1L7HLkJwcD1X94gm82qr3a2RgQfoqTCRQM
         JG0w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukf4MDWrt5JMUCjG8g+ciCWSs+oJ0D3s9gjjVtF8JzOogvRaRb1B
	z+rmT3ksyTh8sOi4Qev5vEKJNOgO/0eUcKZDQH3mqDFGNN7kGVHwoANoBEg2aUE8x4kgTFJTNLC
	hlGiTWiyfVGdvGgms1KzzUDI5beKxYpPLeXJfS7PJYoS0TkalUOwuuS9jUbNr0sr9dQ==
X-Received: by 2002:a37:bd5:: with SMTP id 204mr24483793qkl.242.1548804749139;
        Tue, 29 Jan 2019 15:32:29 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7E4CG400qlIZm1SChZBmjejUmPk8zCCwUc2NLPMi7yPVm+FyVNTHhA3zAZuASCwuWpy/HL
X-Received: by 2002:a37:bd5:: with SMTP id 204mr24483755qkl.242.1548804748403;
        Tue, 29 Jan 2019 15:32:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548804748; cv=none;
        d=google.com; s=arc-20160816;
        b=DDgoWdm94MnlODjKJBVg3khNvqXfuQYbKXxu6Io70yHAQT0YJSzRvTiv9Dd39ZVbHt
         GxbKy+JJ34TZsG3nSKzdf4tJAuzwjMY5RooG9XwdnU7aV/TiOnBkblkDrtI3DNGkkJke
         E8FUfviqR0vy9kNCozNMUhrnKisdEjhNh7bUGNJEciZllf/FB3sv8h4UOyTLR9+Vap+L
         ZaQbewz6OaCBNr5uB20SkWk3+79pIhJiUap04ToY5YsLlL9ut3Kbop0idTPRh10cgavv
         SDfcgOis0U88nnvslb7aEAKX/7sqCJFsy+WIQX/0wqQRdZCoyaEWC16eeyX8UNWJ1Ct+
         YGnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=9vDBEZLG4+YO5WeqcjfjQwEhDzv5QmaksQbvd29TOEo=;
        b=ZhCZ/kQ8yCYPfOBmgBfJYXcleI+ZLfh904WI7K5Br/7dG05dDRToKTue3SQ7zm2yAL
         YRuXNBAA19cAC4DnlQ06FcVmCBbQgtE3AYRNpHbn3nrg3d0Yv5UW6nejnB756QeVPl7Z
         eksPoNB8eUJZRRv7vrZ2aRGtsoBSpjBIo/zX3PwOuqVOVi4jkPATFbH2+oB7kdcdZ7AC
         GWcMR1Tw93rGeo58NJc0276146Uktzdmt0ADB+em5RSK3CW5lMyEPSgxrCa5U6TzFRJ1
         6/7p2xWGn2H6B9R9QIU/ztCnIdOzKb8EuBfXRln0+qOK+/Fe6wQFUbpMXaCVGn5DNstQ
         VaMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j62si8513279qtb.139.2019.01.29.15.32.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 15:32:28 -0800 (PST)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0D5AEC0CB577;
	Tue, 29 Jan 2019 23:32:27 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-48.ams2.redhat.com [10.36.116.48])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 567FB5C21A;
	Tue, 29 Jan 2019 23:32:18 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Jan Kara <jack@suse.cz>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Dominik Brodowski <linux@dominikbrodowski.net>,
	Matthew Wilcox <willy@infradead.org>,
	Vratislav Bendel <vbendel@redhat.com>,
	Rafael Aquini <aquini@redhat.com>,
	Konstantin Khlebnikov <k.khlebnikov@samsung.com>,
	Minchan Kim <minchan@kernel.org>,
	stable@vger.kernel.org
Subject: [PATCH v2] mm: migrate: don't rely on __PageMovable() of newpage after unlocking it
Date: Wed, 30 Jan 2019 00:32:17 +0100
Message-Id: <20190129233217.10747-1-david@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Tue, 29 Jan 2019 23:32:27 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We had a race in the old balloon compaction code before commit b1123ea6d3b3
("mm: balloon: use general non-lru movable page feature") refactored it
that became visible after backporting commit 195a8c43e93d
("virtio-balloon: deflate via a page list") without the refactoring.

The bug existed from commit d6d86c0a7f8d ("mm/balloon_compaction: redesign
ballooned pages management") till commit b1123ea6d3b3 ("mm: balloon: use
general non-lru movable page feature"). commit d6d86c0a7f8d
("mm/balloon_compaction: redesign ballooned pages management") was
backported to 3.12, so the broken kernels are stable kernels [3.12 - 4.7].

There was a subtle race between dropping the page lock of the newpage
in __unmap_and_move() and checking for
__is_movable_balloon_page(newpage).

Just after dropping this page lock, virtio-balloon could go ahead and
deflate the newpage, effectively dequeueing it and clearing PageBalloon,
in turn making __is_movable_balloon_page(newpage) fail.

This resulted in dropping the reference of the newpage via
putback_lru_page(newpage) instead of put_page(newpage), leading to
page->lru getting modified and a !LRU page ending up in the LRU lists.
With commit 195a8c43e93d ("virtio-balloon: deflate via a page list")
backported, one would suddenly get corrupted lists in
release_pages_balloon():
- WARNING: CPU: 13 PID: 6586 at lib/list_debug.c:59 __list_del_entry+0xa1/0xd0
- list_del corruption. prev->next should be ffffe253961090a0, but was dead000000000100

Nowadays this race is no longer possible, but it is hidden behind very
ugly handling of __ClearPageMovable() and __PageMovable().

__ClearPageMovable() will not make __PageMovable() fail, only
PageMovable(). So the new check (__PageMovable(newpage)) will still hold
even after newpage was dequeued by virtio-balloon.

If anybody would ever change that special handling, the BUG would be
introduced again. So instead, make it explicit and use the information
of the original isolated page before migration.

This patch can be backported fairly easy to stable kernels (in contrast
to the refactoring).

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Vratislav Bendel <vbendel@redhat.com>
Cc: Rafael Aquini <aquini@redhat.com>
Cc: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: stable@vger.kernel.org # 3.12 - 4.7
Fixes: d6d86c0a7f8d ("mm/balloon_compaction: redesign ballooned pages management")
Reported-by: Vratislav Bendel <vbendel@redhat.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Rafael Aquini <aquini@redhat.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/migrate.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 4512afab46ac..402198816d1a 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1135,10 +1135,13 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 	 * If migration is successful, decrease refcount of the newpage
 	 * which will not free the page because new page owner increased
 	 * refcounter. As well, if it is LRU page, add the page to LRU
-	 * list in here.
+	 * list in here. Use the old state of the isolated source page to
+	 * determine if we migrated a LRU page. newpage was already unlocked
+	 * and possibly modified by its owner - don't rely on the page
+	 * state.
 	 */
 	if (rc == MIGRATEPAGE_SUCCESS) {
-		if (unlikely(__PageMovable(newpage)))
+		if (unlikely(!is_lru))
 			put_page(newpage);
 		else
 			putback_lru_page(newpage);
-- 
2.17.2

