Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21198C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 00:19:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC66F2166E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 00:19:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC66F2166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6FE046B0003; Thu,  8 Aug 2019 20:19:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6AE646B0006; Thu,  8 Aug 2019 20:19:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5CD196B0007; Thu,  8 Aug 2019 20:19:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2778B6B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 20:19:55 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 71so56424692pld.1
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 17:19:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=9IxSCGNP7YnWW08jgcgzec4ZRDn59yn7Kohgyr8xIg8=;
        b=j8TH1sGIqmxML27/GLalmFzAp6VxqXSsGIrKYOcVAg+BVUkKqmC2S4f1ATIHCL8IFK
         JQipLlMI1RIQU0Yk7S0zWaXOmgJa048dRCMeGRDIrUzrzEv/UU/SqAwHVY6K4JgZgz2n
         nMeBZt4i0L5d58nah12QlsskZx01V1qj1luadvKKDYcA444kBXrDeI8KZplpVl3hi2ub
         FHYtuk7ZOKlR6FO/nQBk5Jx9NHYnF00FL2m4hCSxoSdtsrK1OGl1ztVxNtHervnWcMms
         8MMDHdmpwcW3gt2Xgn7xf77Gx0i0bVpHrERjg/TV9TH+27LAN59YM6nVH/muCrJJ0Ryg
         zSxw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUL1nA/yDBn4kekvtwxC0nvx+FwFFnbSksrlg1Z7XQyn/RmuMYp
	OXe2lJLPsbp99UXjsMdWBWIwjwIP4hLCdEhqV7p7pdD/SNwCbjmkbtpclcNNkzpm2rQc8lBBIvv
	tGJHDInO1mEKlcUKjludFrcgIWrZ6kcPQ0oZb9dy6sM0y5A78jHrhqA32EtHYLkq1ZA==
X-Received: by 2002:a65:6891:: with SMTP id e17mr15328065pgt.305.1565309994770;
        Thu, 08 Aug 2019 17:19:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxABKFMziL9p20VFzqTrcuLLDPBjBDXwrKoptuEQKG4zAtC5c6pUjJmXy2pLbqTE6Tbi1F0
X-Received: by 2002:a65:6891:: with SMTP id e17mr15328005pgt.305.1565309993835;
        Thu, 08 Aug 2019 17:19:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565309993; cv=none;
        d=google.com; s=arc-20160816;
        b=r9BMc2CwEDdNh2rvhiddJP355IROkIyJpXzP8GZUhlBHqUcGt/ESLqaS7nW1DNyMJ8
         MSUah3rVPyJrgPH79JKfNwQNJGlebhaXxoUzLJjM0EndbvzCUXq/LdCvQAPVEmCTSVmn
         jfrzvZSOiJyDy7eB2qvnr1rXVrlMeD+TRW7iI+ha4BgN5d6N76NPHEIbyyjkyHSeIXgc
         rD9x5R1CbtscgEFThlyY4tMeTEaiIevw3xYygB8o942sKwK2JTV3UMHUiUYg6zj87cxY
         PmgA6H9Jl1xegUJsKybHBf+FVV/CEMrowTb/mGiA8O5br3wrsLt6kCmZg9sePTkoztc1
         3Icw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=9IxSCGNP7YnWW08jgcgzec4ZRDn59yn7Kohgyr8xIg8=;
        b=jvvvxFWd8uQeqPdEiKVnI3QkYNFVh/QlYWI0vhdttjQqatTC/n1ItmI/sF5wXhbHQ7
         zR08PvwT0nbv+RBRVSTNiqLcNoJk1WUwDFhB6xzdxuzkuhLqTax/NrFCRfRrFmW3Muwp
         vcOvN0m9esgO4iQtIaqegBfBLyFE/EkXyurwNAWiuClcY5D71PBV+l/K4qhDm0GxFr7i
         7sypiM0IQIkK2GMazyvB92aJ5EpX8IWORPJZ4pgfhN8HkDRDCxljKchohF9mbEmp+n/I
         /z9KXrDw7L1r81FyF4O9+tJn5w4ktkMZcJwATGjSnAqWz2DswNgwd6PneyGq8j+QRoQg
         R8uQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id q13si16705560pgt.232.2019.08.08.17.19.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 17:19:53 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 Aug 2019 17:19:53 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,363,1559545200"; 
   d="scan'208";a="169158764"
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by orsmga008.jf.intel.com with ESMTP; 08 Aug 2019 17:19:51 -0700
From: Wei Yang <richardw.yang@linux.intel.com>
To: akpm@linux-foundation.org,
	mhocko@suse.com,
	vbabka@suse.cz,
	kirill.shutemov@linux.intel.com
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Wei Yang <richardw.yang@linux.intel.com>
Subject: [PATCH v2] mm/mmap.c: refine find_vma_prev with rb_last
Date: Fri,  9 Aug 2019 08:19:28 +0800
Message-Id: <20190809001928.4950-1-richardw.yang@linux.intel.com>
X-Mailer: git-send-email 2.17.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When addr is out of the range of the whole rb_tree, pprev will points to
the right-most node. rb_tree facility already provides a helper
function, rb_last, to do this task. We can leverage this instead of
re-implement it.

This patch refines find_vma_prev with rb_last to make it a little nicer
to read.

Signed-off-by: Wei Yang <richardw.yang@linux.intel.com>

---
v2: leverage rb_last
---
 mm/mmap.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 7e8c3e8ae75f..f7ed0afb994c 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2270,12 +2270,9 @@ find_vma_prev(struct mm_struct *mm, unsigned long addr,
 	if (vma) {
 		*pprev = vma->vm_prev;
 	} else {
-		struct rb_node *rb_node = mm->mm_rb.rb_node;
-		*pprev = NULL;
-		while (rb_node) {
-			*pprev = rb_entry(rb_node, struct vm_area_struct, vm_rb);
-			rb_node = rb_node->rb_right;
-		}
+		struct rb_node *rb_node = rb_last(&mm->mm_rb);
+		*pprev = !rb_node ? NULL :
+			 rb_entry(rb_node, struct vm_area_struct, vm_rb);
 	}
 	return vma;
 }
-- 
2.17.1

