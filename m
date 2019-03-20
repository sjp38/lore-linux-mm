Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2266CC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 15:27:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E33D82183E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 15:27:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E33D82183E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 919D66B0280; Wed, 20 Mar 2019 11:27:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A70A6B0282; Wed, 20 Mar 2019 11:27:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 71C786B0283; Wed, 20 Mar 2019 11:27:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 35D316B0280
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 11:27:25 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id m32so1078948edd.9
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 08:27:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=YmyxWrR6WWxwmqwKqYh4PYOayYzEKEyOVSZJOVJzVBA=;
        b=p9PbCt5Cy5Swa3VUfKWO+nJMHo00oB4Zip6L3lar6lixmxN4q3VJlTiTHxC/T9zmN2
         aOZI4D9+i0A2DMYi1cLM3z+sfQkkj2enGB2lfCSOporrLnstH0CFaLGrbdmLT8+AuYlv
         WLpWAa22KG5aoyQypni5isMWrhyBsLNHyo5cOT2/0/L8JDDmV4nhIykVO+hPMkT1BPqH
         ke+AWbVCxds/XeAzjtPeqCl7xgCy+MZWOwBpCdk18rx1zayN1qSZfMnJOlckZxghgGah
         BdeRWG3eYxjFbdiEg6gJHFmVhTir/553CAn81o7+i/+7vdx2GMvSiSBL5W/NtMlUamXj
         dKhQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXsrjoqg4R/DabWT/7T0pAhEiw9LIOdyLuDSkY2Fx0tDF1XGDA/
	BEXiunPTYbaePm1zDD9UFfO0bYnDzswIKKesX1AXSbXn9t6LBQ1sa7ES23XJiosE4WdSY9B2Wjv
	u0K9+NCJWk/CG75L85Sz5B6SOxWMfQ9KkvtQ3wVhovCNS0ssvzd6MnnhhRQQ2tiSQVA==
X-Received: by 2002:a05:6402:750:: with SMTP id p16mr20520633edy.268.1553095644697;
        Wed, 20 Mar 2019 08:27:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxpBp33MOhJCwnNsuJnLkChWhuz8qy9kC9abndMnv8CZR7saz/TwxEsmuMZ88fyuuwstaVg
X-Received: by 2002:a05:6402:750:: with SMTP id p16mr20520594edy.268.1553095643880;
        Wed, 20 Mar 2019 08:27:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553095643; cv=none;
        d=google.com; s=arc-20160816;
        b=Hu4CYm/6psUP83JEm+d7w40oItKkvV0X+xUn/j6Rq0uyyabm6Q04v94VnX4GP2CRL7
         YH5Bf2GzQbdLeov9CH8cJmalRwIsNf5UZN6JAaySL4DltOxjwtp6DGk8oz+XDN4X/2BU
         p33vuJHYMMR5aRTBCIAQ853wpWTr9tMLkDmv82W3hSeYR3ikNpa6Mdlk8o690s1I7YN8
         ZTPzp4DNypZwxPE7rxBoXW4f8iwM9SEkcr+n3St0gMpsuFy0M5qEiTbVOwHx8ZuRBopy
         bPrgF0bceKTgU2/ZXJfhFNgDSC8z1otwP5phYI6VUIs2bMLdxYn6wy5Kj6lnB/DxX/Fr
         5Cuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=YmyxWrR6WWxwmqwKqYh4PYOayYzEKEyOVSZJOVJzVBA=;
        b=g/Q03lwlfdEAptsGLQ36/chH4ZaKSLpAxX78W9/iQlBppuUloczhhPaNVvEhbeBqfY
         Vtizc8LuTGbgJlxfldOLZftebTH9hh912kzGppkfJiZPyHtc7wngbqA23T8dQw1pzO4U
         rhCcDJN4ZY9rT1+Jm42Ip/VBuZnTIz6IWKJBSd7fwKnzGUzmuIh8ZSDjQEBqzv/29Qy2
         5IDckkMkNdb74XoPLB/ARuzmDcUnOB0fzdv2XgFYl9mcYCECS70oXQNN+Y2SiAQCSavE
         kP/PzfpzrrNJVJRZDs4u8mk7MR2FhSiK20ECh5HXZEY90XOmqpRoLZXnWzie+P60iMyd
         sHOA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id g18si20453edh.169.2019.03.20.08.27.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 08:27:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Wed, 20 Mar 2019 16:27:23 +0100
Received: from d104.suse.de (nwb-a10-snat.microfocus.com [10.120.13.202])
	by emea4-mta.ukb.novell.com with ESMTP (NOT encrypted); Wed, 20 Mar 2019 15:27:04 +0000
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com,
	david@redhat.com,
	mike.kravetz@oracle.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH resend 2/2] mm,memory_hotplug: Drop redundant hugepage_migration_supported check
Date: Wed, 20 Mar 2019 16:26:58 +0100
Message-Id: <20190320152658.10855-3-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
In-Reply-To: <20190320152658.10855-1-osalvador@suse.de>
References: <20190320152658.10855-1-osalvador@suse.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

has_unmovable_pages() does alreay check whether the hugetlb page supports
migration, so all non-migrateable hugetlb pages should have been caught there.
Let us drop the check from scan_movable_pages() as is redundant.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
Acked-by: Michal Hocko <mhocko@suse.com>
Reviewed-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 02283732544e..37a83a83e8f8 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1340,8 +1340,7 @@ static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
 		if (!PageHuge(page))
 			continue;
 		head = compound_head(page);
-		if (hugepage_migration_supported(page_hstate(head)) &&
-		    page_huge_active(head))
+		if (page_huge_active(head))
 			return pfn;
 		skip = (1 << compound_order(head)) - (page - head);
 		pfn += skip - 1;
-- 
2.13.7

