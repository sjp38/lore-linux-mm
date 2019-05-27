Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22B8BC072B1
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 21:11:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DED6520815
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 21:11:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DED6520815
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE04B6B0281; Mon, 27 May 2019 17:11:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B39BA6B027A; Mon, 27 May 2019 17:11:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7902D6B0285; Mon, 27 May 2019 17:11:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3DC736B027C
	for <linux-mm@kvack.org>; Mon, 27 May 2019 17:11:26 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id s8so12482371pgk.0
        for <linux-mm@kvack.org>; Mon, 27 May 2019 14:11:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=b3226PH7PRCZmcNx7tUIpSLCrCW28QSuOlDUSEjkY8M=;
        b=XPiH0R15WhXBtHs0Sd2MIKZYQHp5ON9M0lDQMUJo0eZfBYV0vBrKPTk98n6IWd6E7/
         5S/fjCKSmVATuEHYEsySGu12rDVPfLbgUmHKhy7HSFMKjW0ZHAq0iWwD3Va+CIkpnyfs
         CxcT1kpalpZAVOfbNYNH9FHoFeF2pqbpWoKul2VqnLIeEmRY93xPacSVvhefXYOkRjRn
         LSgIxZdWOY0xmsrlY44JgBDSguGdje+Y2ci472aAUNLfoRgWhtGVc7j7jQY1dTWfHKzo
         0xBT4aG1bCxgOXUrL9dfh+3DoB7OYYj4p14LTPB/GKD0FBt2mlZPNZRlXkMFvxWJu+Jf
         IJCg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVzAs6rh7llGRE9H4EED289F1AdSiBj2vwOCMhS4P9+gSVr3WXy
	hLRwfu0a+xlDTM0HrZwGX2kwJ0b3unDWBjbCUpuF+zTMJMVVp8RBDT/S3o/TmjMm8a+zmFLQA9k
	wYyj9jddqr7kCYAyew8xjIzeK6foHiKUr+Mg65ATZa0wewr8irdsAHvHlfH1euj+X4g==
X-Received: by 2002:a17:902:9a43:: with SMTP id x3mr4739583plv.35.1558991485701;
        Mon, 27 May 2019 14:11:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzF+PBEx9GQZT0IJq/OSK8eM9WW8ox8gFx9q79ssYSMZu9icUbs9asnDmq52bInHKiNokGY
X-Received: by 2002:a17:902:9a43:: with SMTP id x3mr4739527plv.35.1558991484843;
        Mon, 27 May 2019 14:11:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558991484; cv=none;
        d=google.com; s=arc-20160816;
        b=ktBUwJcpRNqmobE8J1IhacM7s3RLG8q9+KNeF3KNEthJNbSFZQULizaeg9dTZhL18S
         fnqqyAYyurvyZ/xsVVIBvNkIoc6dLIpCXbKN86EQN5UpKCGai3d3cQROWZS47dX4vLwp
         Ko8ooDA88aZZVl1Zkp/q1GfS0rlG2yYWQdGGhhwRhaWq9VkylA0THdIxPgUDUYmJLFGj
         XaO3D16VU7N+f7CXu6zHhkiXAiqw5jSNrNzpk0ee5r6ux+d3znh4mR5yosg+3xKIBtmF
         Eo5zD+18XXjv5zdenvwebEo6Pk7fL16/wzqHzQm1I6ala5HBzQGbnjSd05a0smyVTC1v
         mPJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=b3226PH7PRCZmcNx7tUIpSLCrCW28QSuOlDUSEjkY8M=;
        b=I3f+/fsaQgExaOu1G0LwAqdWxQu286yoreAD4sGxHZF1T2w9WvxWLhNxyJ7D5SU5Rv
         bCNCjsq3t746MUAdEuLFc+/tlPWk0/8Y85xeJGPxRMa1W5ZmlhvVBPSr6c52V1tlc9Nz
         /GTV2Q11drZRKcDog8FXN9GWTNyBSekKVuZeK46I5s9PADi+bGBElq87HoxzBnv08OHl
         VmJDCS373iYOQicaCRo29ifIQU1ijVoxw7zF3JfCWbUeR4mv3pXQqmIS40TblysoDir+
         9ouIq+t6dWnPtSkTU/uRrQToDFge+uUdWTpoo8xJMHIelZu/x+7TPQJupTByokJKXlUE
         6ghw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id q33si502821pjb.30.2019.05.27.14.11.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 14:11:24 -0700 (PDT)
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
Subject: [PATCH v5 1/2] vmalloc: Fix calculation of direct map addr range
Date: Mon, 27 May 2019 14:10:57 -0700
Message-Id: <20190527211058.2729-2-rick.p.edgecombe@intel.com>
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

The calculation of the direct map address range to flush was wrong.
This could cause the RO direct map alias to not get flushed. Today
this shouldn't be a problem because this flush is only needed on x86
right now and the spurious fault handler will fix cached RO->RW
translations. In the future though, it could cause the permissions
to remain RO in the TLB for the direct map alias, and then the page
would return from the page allocator to some other component as RO
and cause a crash.

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
 mm/vmalloc.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 233af6936c93..3ede9c064477 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2123,7 +2123,6 @@ static inline void set_area_direct_map(const struct vm_struct *area,
 /* Handle removing and resetting vm mappings related to the vm_struct. */
 static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
 {
-	unsigned long addr = (unsigned long)area->addr;
 	unsigned long start = ULONG_MAX, end = 0;
 	int flush_reset = area->flags & VM_FLUSH_RESET_PERMS;
 	int i;
@@ -2135,8 +2134,8 @@ static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
 	 * execute permissions, without leaving a RW+X window.
 	 */
 	if (flush_reset && !IS_ENABLED(CONFIG_ARCH_HAS_SET_DIRECT_MAP)) {
-		set_memory_nx(addr, area->nr_pages);
-		set_memory_rw(addr, area->nr_pages);
+		set_memory_nx((unsigned long)area->addr, area->nr_pages);
+		set_memory_rw((unsigned long)area->addr, area->nr_pages);
 	}
 
 	remove_vm_area(area->addr);
@@ -2160,9 +2159,11 @@ static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
 	 * the vm_unmap_aliases() flush includes the direct map.
 	 */
 	for (i = 0; i < area->nr_pages; i++) {
-		if (page_address(area->pages[i])) {
+		unsigned long addr =
+				(unsigned long)page_address(area->pages[i]);
+		if (addr) {
 			start = min(addr, start);
-			end = max(addr, end);
+			end = max(addr + PAGE_SIZE, end);
 		}
 	}
 
-- 
2.20.1

