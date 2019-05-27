Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA639C072B1
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 21:11:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB73820815
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 21:11:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB73820815
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F0D426B027A; Mon, 27 May 2019 17:11:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF95D6B0285; Mon, 27 May 2019 17:11:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC8716B0283; Mon, 27 May 2019 17:11:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 649AF6B027A
	for <linux-mm@kvack.org>; Mon, 27 May 2019 17:11:26 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 205so7557162pfx.2
        for <linux-mm@kvack.org>; Mon, 27 May 2019 14:11:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=w5dZvxgBdocT15p6SjndgkxRawOH6YSVVyH0Y+kEA3k=;
        b=D2vhSJUqCehZAheScggl8H/IOg2JoQtd3vJzTHs1dBx+kbSb2nWlScM95xMSh4n5Nc
         FHFyStUOSsJeJtfwmWI1StGbiocENmsj763xEISAzKca/ARPlAGNDIqkczXDCN3Q1uez
         WRPJSaZRM7bvpRWs0oKgMHi2M2I6uqj5ymy3gKox57uk4dOHZPE37Ll6matMgWMCxo/b
         DoJTzad7s963R/Zrfbfy+1xL8578sq4oXgaP4F4zggJvbktsxcD/Q7inOG8Ivq9rtrur
         ZK+YcFoHWb/+cD0VrIPOWyj3njrKSS6qUP1yNLkfbMGJLFTAlKclS2qGaguCr7gZyWn1
         udRw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXLxdpq4TbMW9mJVviaafYuWsTTt/sYkq7c9CahjAmzHGoZIpet
	TftywrzD2TB/en3gIewW9WK3/DNcP6Og23nivQYRsLTfXWYKjhj3Y6qABM8C0lscM9leeCnw9Wm
	UzbmvH2sNrVxVO9KKsw0uTv88Gb8VAEQ6LTwVxhFGof5CO6La9w7Cv01Ymg5THkp4Eg==
X-Received: by 2002:a63:1212:: with SMTP id h18mr39557280pgl.266.1558991486013;
        Mon, 27 May 2019 14:11:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwNtCqBx4jndzn31LfNondCIiHy1Lz9Ls+vox3DKMMC2qF+rW36D2Fzn6glua/+SdkqEGD5
X-Received: by 2002:a63:1212:: with SMTP id h18mr39557223pgl.266.1558991485037;
        Mon, 27 May 2019 14:11:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558991485; cv=none;
        d=google.com; s=arc-20160816;
        b=QYrwLDyf2wpQ0g0DsYrtd+am0rIbIhOzhcd4173BVFD8eLDhUHajJw5tFF451wSoL5
         /M/MzXljOvHK8BpwN+d8cW4uxcv1mAdqiJcXRzjESG4onCVu1ClbdR0lRE/4OxpKXkkg
         Tv0H9KUsXAdF8y9a3LtAKD6N5Cx5Bg0QPz8XPrKdVHMsjc3s7tVZLj+IwRQ6YldgmJqj
         NaUDP+yMbivoDbrLYxIcoHPIS31Poot0HYZppU/SwNTyR40amnQxUuxugJDDrkGt17ZJ
         GUnEs+rlSpDAHB2I91bYhssKiYbQUcgT3iQrJEijzZd3e5Bh7Nu2AtSRV2VJdn79V41t
         OPww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=w5dZvxgBdocT15p6SjndgkxRawOH6YSVVyH0Y+kEA3k=;
        b=QJho09WQkYPYTwQbJwY9bxLqS5+wIQxTYb+9Jz7QxM54xlotjuWzVFK4NJum2kcZD1
         XW+e8mQ6QURK5noxepfWZfTzQBZV5UmwTYJz0op2CWk5Zvhr5o1BQbt3SVI4A5QZgW3R
         6mNbQbEvzUqnSEHWxmRH5vtEhGvubk87sg2vNIhkmBZEIz4ahlbAy+YdrJiviJ2ePknn
         ed9a9OmTUUnH0UDRQRNAcqZCgCiy4aMwqJWE8DD08X6Gzavvpb3Sxd1DS0JE1U1UpuBU
         8gs2fS6MPH+MakoEXg9HhOLd80Yo4ao33ktTq4WKbBcL1TUD8EWGsRxDOMHQriKr4pIo
         wfbw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id q33si502821pjb.30.2019.05.27.14.11.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 14:11:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 27 May 2019 14:11:24 -0700
X-ExtLoop1: 1
Received: from rpedgeco-mobl.amr.corp.intel.com (HELO localhost.intel.com) ([10.251.0.167])
  by orsmga008.jf.intel.com with ESMTP; 27 May 2019 14:11:24 -0700
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: linux-kernel@vger.kernel.org,
	peterz@infradead.org,
	sparclinux@vger.kernel.org,
	linux-mm@kvack.org,
	netdev@vger.kernel.org,
	luto@kernel.org
Cc: dave.hansen@intel.com,
	namit@vmware.com,
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Meelis Roos <mroos@linux.ee>,
	"David S. Miller" <davem@davemloft.net>,
	Borislav Petkov <bp@alien8.de>,
	Ingo Molnar <mingo@redhat.com>
Subject: [PATCH v5 2/2] vmalloc: Avoid rare case of flushing tlb with weird arguments
Date: Mon, 27 May 2019 14:10:58 -0700
Message-Id: <20190527211058.2729-3-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190527211058.2729-1-rick.p.edgecombe@intel.com>
References: <20190527211058.2729-1-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In a rare case, flush_tlb_kernel_range() could be called with a start
higher than the end.

In vm_remove_mappings(), in case page_address() returns 0 for all pages
(for example they were all in highmem), _vm_unmap_aliases() will be
called with start = ULONG_MAX, end = 0 and flush = 1.

If at the same time, the vmalloc purge operation is triggered by something
else while the current operation is between remove_vm_area() and
_vm_unmap_aliases(), then the vm mapping just removed will be already
purged. In this case the call of vm_unmap_aliases() may not find any other
mappings to flush and so end up flushing start = ULONG_MAX, end = 0. So
only set flush = true if we find something in the direct mapping that we
need to flush, and this way this can't happen.

Fixes: 868b104d7379 ("mm/vmalloc: Add flag for freeing of special permsissions")
Cc: Meelis Roos <mroos@linux.ee>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 mm/vmalloc.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 3ede9c064477..7f15a3ebcd74 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2125,6 +2125,7 @@ static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
 {
 	unsigned long start = ULONG_MAX, end = 0;
 	int flush_reset = area->flags & VM_FLUSH_RESET_PERMS;
+	int flush_dmap = 0;
 	int i;
 
 	/*
@@ -2164,6 +2165,7 @@ static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
 		if (addr) {
 			start = min(addr, start);
 			end = max(addr + PAGE_SIZE, end);
+			flush_dmap = 1;
 		}
 	}
 
@@ -2173,7 +2175,7 @@ static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
 	 * reset the direct map permissions to the default.
 	 */
 	set_area_direct_map(area, set_direct_map_invalid_noflush);
-	_vm_unmap_aliases(start, end, 1);
+	_vm_unmap_aliases(start, end, flush_dmap);
 	set_area_direct_map(area, set_direct_map_default_noflush);
 }
 
-- 
2.20.1

