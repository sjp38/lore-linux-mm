Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EDF15C3A59D
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 09:49:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BCC0B22CF9
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 09:49:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BCC0B22CF9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB2C56B000C; Tue, 20 Aug 2019 05:49:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CED186B0269; Tue, 20 Aug 2019 05:49:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E03D6B000E; Tue, 20 Aug 2019 05:49:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0207.hostedemail.com [216.40.44.207])
	by kanga.kvack.org (Postfix) with ESMTP id 751EE6B000D
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 05:49:40 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 14E56181AC9B6
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:49:40 +0000 (UTC)
X-FDA: 75842334120.02.boys69_544bb53dec360
X-HE-Tag: boys69_544bb53dec360
X-Filterd-Recvd-Size: 4132
Received: from out30-42.freemail.mail.aliyun.com (out30-42.freemail.mail.aliyun.com [115.124.30.42])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:49:38 +0000 (UTC)
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R731e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04400;MF=alex.shi@linux.alibaba.com;NM=1;PH=DS;RN=16;SR=0;TI=SMTPD_---0TZzk.Bf_1566294574;
Received: from localhost(mailfrom:alex.shi@linux.alibaba.com fp:SMTPD_---0TZzk.Bf_1566294574)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 20 Aug 2019 17:49:34 +0800
From: Alex Shi <alex.shi@linux.alibaba.com>
To: cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Tejun Heo <tj@kernel.org>
Cc: Alex Shi <alex.shi@linux.alibaba.com>,
	Michal Hocko <mhocko@suse.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Hugh Dickins <hughd@google.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	David Rientjes <rientjes@google.com>,
	Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH 05/14] lru/huge_page: use per lruvec lock in __split_huge_page
Date: Tue, 20 Aug 2019 17:48:28 +0800
Message-Id: <1566294517-86418-6-git-send-email-alex.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
References: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Using lruvec lock to replace pgdat lru_lock.

Signed-off-by: Alex Shi <alex.shi@linux.alibaba.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/huge_memory.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 3a483deee807..9a96c0944b4d 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2529,7 +2529,7 @@ static void __split_huge_page(struct page *page, st=
ruct list_head *list,
 		xa_unlock(&head->mapping->i_pages);
 	}
=20
-	spin_unlock_irqrestore(&pgdat->lruvec.lru_lock, flags);
+	spin_unlock_irqrestore(&lruvec->lru_lock, flags);
=20
 	remap_page(head);
=20
@@ -2671,6 +2671,7 @@ int split_huge_page_to_list(struct page *page, stru=
ct list_head *list)
 	struct pglist_data *pgdata =3D NODE_DATA(page_to_nid(head));
 	struct anon_vma *anon_vma =3D NULL;
 	struct address_space *mapping =3D NULL;
+	struct lruvec *lruvec;
 	int count, mapcount, extra_pins, ret;
 	bool mlocked;
 	unsigned long flags;
@@ -2739,8 +2740,10 @@ int split_huge_page_to_list(struct page *page, str=
uct list_head *list)
 	if (mlocked)
 		lru_add_drain();
=20
+	lruvec =3D mem_cgroup_page_lruvec(head, pgdata);
 	/* prevent PageLRU to go away from under us, and freeze lru stats */
-	spin_lock_irqsave(&pgdata->lruvec.lru_lock, flags);
+	spin_lock_irqsave(&lruvec->lru_lock, flags);
+	sync_lruvec_pgdat(lruvec, pgdata);
=20
 	if (mapping) {
 		XA_STATE(xas, &mapping->i_pages, page_index(head));
@@ -2785,7 +2788,7 @@ int split_huge_page_to_list(struct page *page, stru=
ct list_head *list)
 		spin_unlock(&pgdata->split_queue_lock);
 fail:		if (mapping)
 			xa_unlock(&mapping->i_pages);
-		spin_unlock_irqrestore(&pgdata->lruvec.lru_lock, flags);
+		spin_unlock_irqrestore(&lruvec->lru_lock, flags);
 		remap_page(head);
 		ret =3D -EBUSY;
 	}
--=20
1.8.3.1


