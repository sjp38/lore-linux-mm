Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 642E0C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 08:45:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 295A220657
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 08:45:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 295A220657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A0B138E000A; Mon, 11 Mar 2019 04:45:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BB6F8E0002; Mon, 11 Mar 2019 04:45:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 884108E000A; Mon, 11 Mar 2019 04:45:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2E1BF8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 04:45:44 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k6so1744035edq.3
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 01:45:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=CRwrzvFCP/gAtJsI4OcG6DNqhrPASf9RA/g3N+hWg4o=;
        b=Lp8/FuagTbIM4SFEufstGv0hErQBxL8oHi+BV4hR+2Gdnu9NGtDHXx96eG1nukHoZk
         9cVhPOK95F2vJS2awTwFIcqNN7Nn2ezYL7GupRP0H/tW+ixY5Ar+hhVa+9BI7m1z40vd
         UHbHJvf5hoS+rfrxopLtjygdEZSsCjHuOewqM/zec2+OoFb/IlmiQI1tV2CCaHL3cyqE
         mhvc9T7J+5ruhgGWItCj802YaI7cTb67S57zHazvMt5yn0rb+b3bXxseGxok1xDfinO9
         uR1KvhDVb05QtuvLZjfV1zSmehqjhKJM0o05W+G3cyz77c7GDkYHRjniRRKUaWK3giiF
         Y83A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAVZvAc4Tzg69lc29SRExGrCKqsbJBEtIMaqhZEapIOCPtIXTf89
	3rJcS2RNoyTrYQ2X7nsoXtvTMZ7IKppmaAJHBdvSkdCA9ktxwGk4HQe9l1PsBmt9H10UTCXOQjF
	5CNFB79tgpRIJ0MpKMwByCMMKaEm7re+YdncFZ8JehOSLR6VDDSfoEBM9ZSFfUxST7Q==
X-Received: by 2002:a17:906:3050:: with SMTP id d16mr21336271ejd.200.1552293943541;
        Mon, 11 Mar 2019 01:45:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzkRVRMJ84e6oz+FJtvDqjubKBQmkulI7Vd4boIxHmMZUN8irAYk7rvghW67zyN+rOkaMIY
X-Received: by 2002:a17:906:3050:: with SMTP id d16mr21336216ejd.200.1552293942136;
        Mon, 11 Mar 2019 01:45:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552293942; cv=none;
        d=google.com; s=arc-20160816;
        b=vNNjf5NUBxOfJv4VuiqFK6Jo96mMGcgCcK4hTLoQAmUOFJmg9M5BMavNGxDVxyDlCb
         gI1h/CSFn0XMx/t2kvjWjdyfKHUCud6m44tJC86n1VfI7vFLWfn7cy6C1EJhZr1s0ivZ
         2ismST4BYBsF/FaUbeGVumEKXZ1pTPKKQkHkFpPfviAnqD8LKwCmUdIslGJA+XfgFVPJ
         hu3dvZ2lx4Vw88fVXUZvvsCvmr8d+5OinO50lh5tUy6fj4iUNqnEZQqpMtPtOHsQqgoo
         Xnspoq6OEbZC59in5FUZUOtjUc6pPxtPr5brNP05s0FERqcutAMHouRTRoYs63gbHf5P
         jKjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=CRwrzvFCP/gAtJsI4OcG6DNqhrPASf9RA/g3N+hWg4o=;
        b=gDiLcEjaBc7KeMvfAKxJm7q7Z4/+Ti4WwcSsENorewxjfg7Pu61EQ0vgIMrcV6ny8X
         3qQ8RRg23ELv7VgZM1jO/kfkFgh/PR7uXMfedklaCaki10r4k9iIEF9tYssgzU0bpqmE
         a87zDxqfHeldqniXVOlZsCN72Q1FdQS76VjSqorUXn8lN5ba9vGMnBOjIm8PiqArhfOj
         moLMTokqvtIh3/Skkn70oEymUucGu6RybuUDLMR9t7Fwv1HrTiwzbg9itVJSeYNN4egq
         iA72c3SIi6XBO/GdBLh1xjbDPANpOm53sY+bYuvs7Bn3n/GU8THW8tbnTqsq9A4PXm+R
         Fcew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m15si2239545ejk.107.2019.03.11.01.45.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 01:45:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 91C18AF6E;
	Mon, 11 Mar 2019 08:45:41 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 8D4141E4241; Mon, 11 Mar 2019 09:45:41 +0100 (CET)
From: Jan Kara <jack@suse.cz>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: <linux-mm@kvack.org>,
	Dan Williams <dan.j.williams@intel.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Chandan Rajendra <chandan@linux.ibm.com>,
	Jan Kara <jack@suse.cz>,
	stable@vger.kernel.org
Subject: [PATCH] mm: Fix modifying of page protection by insert_pfn()
Date: Mon, 11 Mar 2019 09:45:37 +0100
Message-Id: <20190311084537.16029-1-jack@suse.cz>
X-Mailer: git-send-email 2.16.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Aneesh has reported that PPC triggers the following warning when
excercising DAX code:

[c00000000007610c] set_pte_at+0x3c/0x190
LR [c000000000378628] insert_pfn+0x208/0x280
Call Trace:
[c0000002125df980] [8000000000000104] 0x8000000000000104 (unreliable)
[c0000002125df9c0] [c000000000378488] insert_pfn+0x68/0x280
[c0000002125dfa30] [c0000000004a5494] dax_iomap_pte_fault.isra.7+0x734/0xa40
[c0000002125dfb50] [c000000000627250] __xfs_filemap_fault+0x280/0x2d0
[c0000002125dfbb0] [c000000000373abc] do_wp_page+0x48c/0xa40
[c0000002125dfc00] [c000000000379170] __handle_mm_fault+0x8d0/0x1fd0
[c0000002125dfd00] [c00000000037a9b0] handle_mm_fault+0x140/0x250
[c0000002125dfd40] [c000000000074bb0] __do_page_fault+0x300/0xd60
[c0000002125dfe20] [c00000000000acf4] handle_page_fault+0x18

Now that is WARN_ON in set_pte_at which is

        VM_WARN_ON(pte_hw_valid(*ptep) && !pte_protnone(*ptep));

The problem is that on some architectures set_pte_at() cannot cope with
a situation where there is already some (different) valid entry present.

Use ptep_set_access_flags() instead to modify the pfn which is built to
deal with modifying existing PTE.

CC: stable@vger.kernel.org
Fixes: b2770da64254 "mm: add vm_insert_mixed_mkwrite()"
Reported-by: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/memory.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 47fe250307c7..ab650c21bccd 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1549,10 +1549,12 @@ static vm_fault_t insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 				WARN_ON_ONCE(!is_zero_pfn(pte_pfn(*pte)));
 				goto out_unlock;
 			}
-			entry = *pte;
-			goto out_mkwrite;
-		} else
-			goto out_unlock;
+			entry = pte_mkyoung(*pte);
+			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+			if (ptep_set_access_flags(vma, addr, pte, entry, 1))
+				update_mmu_cache(vma, addr, pte);
+		}
+		goto out_unlock;
 	}
 
 	/* Ok, finally just insert the thing.. */
@@ -1561,7 +1563,6 @@ static vm_fault_t insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 	else
 		entry = pte_mkspecial(pfn_t_pte(pfn, prot));
 
-out_mkwrite:
 	if (mkwrite) {
 		entry = pte_mkyoung(entry);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-- 
2.16.4

