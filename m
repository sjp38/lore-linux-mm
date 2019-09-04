Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4DC0BC3A5A7
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 13:53:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 10D0E23401
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 13:53:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="Z4jm5Q2L"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10D0E23401
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3426F6B000E; Wed,  4 Sep 2019 09:53:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F25C6B0010; Wed,  4 Sep 2019 09:53:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 084096B0266; Wed,  4 Sep 2019 09:53:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0027.hostedemail.com [216.40.44.27])
	by kanga.kvack.org (Postfix) with ESMTP id D904D6B000E
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 09:53:26 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 7DC73180AD802
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 13:53:26 +0000 (UTC)
X-FDA: 75897380412.18.mouth01_1dfcd9e79b751
X-HE-Tag: mouth01_1dfcd9e79b751
X-Filterd-Recvd-Size: 3282
Received: from forwardcorp1o.mail.yandex.net (forwardcorp1o.mail.yandex.net [95.108.205.193])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 13:53:25 +0000 (UTC)
Received: from mxbackcorp1g.mail.yandex.net (mxbackcorp1g.mail.yandex.net [IPv6:2a02:6b8:0:1402::301])
	by forwardcorp1o.mail.yandex.net (Yandex) with ESMTP id 182CE2E1AF9;
	Wed,  4 Sep 2019 16:53:23 +0300 (MSK)
Received: from smtpcorp1p.mail.yandex.net (smtpcorp1p.mail.yandex.net [2a02:6b8:0:1472:2741:0:8b6:10])
	by mxbackcorp1g.mail.yandex.net (nwsmtp/Yandex) with ESMTP id aEmyyOzLzc-rMC8F2bH;
	Wed, 04 Sep 2019 16:53:23 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1567605203; bh=tOkluSvMOilQtaQgeVN/jbLnmLXdvX3Fp9s5Z6P8s1g=;
	h=In-Reply-To:Message-ID:References:Date:To:From:Subject:Cc;
	b=Z4jm5Q2LTUYVSo8olrY0Quoi7AQsTBhZjF73yqtYmYod1nau/phdgy6bQwtVIC7rj
	 788ePHQp13uvQW1vUeIf1xWUaY30sg+qS9qy1od1dkNufOcq1HIh0Z6xLrECdoAQoF
	 GlBmDVdNCEbC2tjP/Z03EJTXlxSojcqYxr6uTv9Y=
Authentication-Results: mxbackcorp1g.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:c142:79c2:9d86:677a])
	by smtpcorp1p.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id wlKkVkryLz-rMDao1Sr;
	Wed, 04 Sep 2019 16:53:22 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH v1 7/7] mm/mlock: recharge mlocked pages at culling by vmscan
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org
Cc: Michal Hocko <mhocko@suse.com>, Roman Gushchin <guro@fb.com>,
 Johannes Weiner <hannes@cmpxchg.org>
Date: Wed, 04 Sep 2019 16:53:22 +0300
Message-ID: <156760520240.6560.4933207338618527335.stgit@buzz>
In-Reply-To: <156760509382.6560.17364256340940314860.stgit@buzz>
References: <156760509382.6560.17364256340940314860.stgit@buzz>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

If mlock cannot catch page in LRU then it isn't moved into unevictable lru.
These pages are 'culled' by reclaimer and moved into unevictable lru.
It seems pages locked with MLOCK_ONFAULT always go through this path.

Reclaimer calls try_to_unmap for already isolated pages, thus on this path
we could freely change page to owner of any mlock vma we found in rmap.

This patch passes flag TTU_LRU_ISOLATED into try_to_ummap to move pages
in mmlock_vma_page().

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 mm/vmscan.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index bf7a05e8a717..2060f254dd6b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1345,7 +1345,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * processes. Try to unmap it here.
 		 */
 		if (page_mapped(page)) {
-			enum ttu_flags flags = ttu_flags | TTU_BATCH_FLUSH;
+			enum ttu_flags flags = ttu_flags | TTU_BATCH_FLUSH |
+					       TTU_LRU_ISOLATED;
 
 			if (unlikely(PageTransHuge(page)))
 				flags |= TTU_SPLIT_HUGE_PMD;


