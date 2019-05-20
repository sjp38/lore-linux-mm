Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BDBBC04E87
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 23:39:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD05A21479
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 23:39:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD05A21479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EDE446B0005; Mon, 20 May 2019 19:39:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E68AA6B0006; Mon, 20 May 2019 19:39:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C6D506B0007; Mon, 20 May 2019 19:39:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8F3FD6B0005
	for <linux-mm@kvack.org>; Mon, 20 May 2019 19:39:06 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 14so10759553pgo.14
        for <linux-mm@kvack.org>; Mon, 20 May 2019 16:39:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Ds3H9F2HKk2YdGjewRFDhvqdq1umWShX+MEkRxlhmj4=;
        b=e6D+AH45p3ZgPacH6qSl29QsP9jpcHbo85ZW+xGai2sWlFNuum+h0za+x72z42wV9p
         WX9PJyQaZokkPnSNF4FzEIuKjjOvJx5oN0fE+G0o4/XvG/G/ppZieXmEkZWGmSkzmVM+
         l1f9CBJDmB68qcxnXXZkrbMPhtdFztIVUj+u3fKkUR5RmiyteNEUTiyshhuKD1kEkbVc
         1YZ9HcdOtj/m2f6EEzuRz9kukggsBXDeFtEIRMfwDgO2auS4QnJEPSNQNUmTK+NUpY8z
         qd7eaoKf4lbE2qzHuYgRz9fZriWKuhdskcKghC1gUXvQod1EJpbCsrwy3jpdnQ/vaig/
         tnqw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXGYFlLLRd2gvl1YCqulhvYNz9JMUE9X1z3YTMGvsBCyNvdeGYQ
	qNDXll56y4cRAGvcbznqEXcUiknUAR3rSK9BAFaXaKHjLqw64bJqlJp7Hn1jkBykahowdT/K3a+
	tO/1hdNLQm9DiJn6CZMH8HyGKGKghBtRd7XQYmfULkFs3k1/uknWY3VL4/7RyLg3Rwg==
X-Received: by 2002:aa7:93bb:: with SMTP id x27mr82451172pff.104.1558395546249;
        Mon, 20 May 2019 16:39:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzGf2sWAM2EmfnX4cGKnoWnAl8nbP+qowp9O7iSbRBEAIdJZzGNaZFY6Hmpsab/+A4Bk0dQ
X-Received: by 2002:aa7:93bb:: with SMTP id x27mr82451116pff.104.1558395545424;
        Mon, 20 May 2019 16:39:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558395545; cv=none;
        d=google.com; s=arc-20160816;
        b=Y3P9X70aKa1am6RIqkOpcO+un73pfZLSwfvBDOp7x01NWbldTlRH0rFj1bJqnwaM3Q
         1mQqVroIJWZqNgXqx3M3413dfkzJlOnJw5TrbiDnNcUlnRiJYrMwlhsD66aslROs4PAK
         iN1DuC4s6xKhXaZ3vDMO5/P9UipLlQKVwTteNz4WDCs11wJbpYhD2+4MOfXAJ6O3UKpp
         1BFidXc2KfpIddJg0225vejT7kO4m81VBS6I/eP5vR6C4MweudTLN5o0dUYdGmYJckfA
         th6xFaHStrClfAuFcuZYxsRk8dbzJuKLRnVFNwAv/OQUHcwlYDDaO4aDMhfFfmDZf492
         igog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Ds3H9F2HKk2YdGjewRFDhvqdq1umWShX+MEkRxlhmj4=;
        b=rGVsneN9ABD3Jf2wYWHRu/FCKxTm88R7sokUXwGWACrXxw+QSGWK1HlTUhjQ426lV/
         Q9KIO8TGLzdAHo6NaWVnHTs1W0pKuTxHvdc+SZZNrCJNbcVaZBKHWb9jwgPJMhfWe9oQ
         4Td63RUBqOzu6/3+0chaggiX/xiXhie6XS/q7D5WEPvpDW/+1FTHczxyUaXY3VgVtQ46
         BRqga29XQhA3MywGyS1FtGeySrf8Cw2xL/gXqMjmxzEFzbocDc5T1ueHbUZVDrTHgkT6
         an9MisgMy2ZXONaTLJJwY7lOWyYPTbrbDcCQsz0dPemG70XuZwJKG+DzjEoZNUOsiJgJ
         stBg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id g90si19915577plb.140.2019.05.20.16.39.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 16:39:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 May 2019 16:39:05 -0700
X-ExtLoop1: 1
Received: from rpedgeco-mobl.amr.corp.intel.com (HELO localhost.intel.com) ([10.254.114.95])
  by fmsmga008.fm.intel.com with ESMTP; 20 May 2019 16:39:04 -0700
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: linux-kernel@vger.kernel.org,
	peterz@infradead.org,
	sparclinux@vger.kernel.org,
	linux-mm@kvack.org,
	netdev@vger.kernel.org,
	luto@amacapital.net
Cc: dave.hansen@intel.com,
	namit@vmware.com,
	davem@davemloft.net,
	Rick Edgecombe <redgecombe.lkml@gmail.com>,
	Meelis Roos <mroos@linux.ee>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v2 1/2] vmalloc: Fix calculation of direct map addr range
Date: Mon, 20 May 2019 16:38:40 -0700
Message-Id: <20190520233841.17194-2-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190520233841.17194-1-rick.p.edgecombe@intel.com>
References: <20190520233841.17194-1-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Rick Edgecombe <redgecombe.lkml@gmail.com>

The calculation of the direct map address range to flush was wrong.
This could cause problems on x86 if a RO direct map alias ever got loaded
into the TLB. This shouldn't normally happen, but it could cause the
permissions to remain RO on the direct map alias, and then the page
would return from the page allocator to some other component as RO and
cause a crash.

So fix fix the address range calculation so the flush will include the
direct map range.

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
 mm/vmalloc.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index c42872ed82ac..836888ae01f6 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2159,9 +2159,10 @@ static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
 	 * the vm_unmap_aliases() flush includes the direct map.
 	 */
 	for (i = 0; i < area->nr_pages; i++) {
-		if (page_address(area->pages[i])) {
+		addr = (unsigned long)page_address(area->pages[i]);
+		if (addr) {
 			start = min(addr, start);
-			end = max(addr, end);
+			end = max(addr + PAGE_SIZE, end);
 		}
 	}
 
-- 
2.20.1

