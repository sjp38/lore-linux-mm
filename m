Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1B92C31E47
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 06:43:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B8609208C4
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 06:43:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmwopensource.org header.i=@vmwopensource.org header.b="eeOw22qy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B8609208C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=vmwopensource.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 420576B0007; Wed, 12 Jun 2019 02:43:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3AAD36B0008; Wed, 12 Jun 2019 02:43:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 298346B000A; Wed, 12 Jun 2019 02:43:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id B625C6B0007
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 02:43:30 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id f24so2386259lfj.17
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 23:43:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=nXeAn+b9rzfB9xUtBdzEuMbNYPo06z76iQWWf55VKQQ=;
        b=TxFL6w5GZNlhmj/32AV3bT9hSdmqes3ClPWlA1lHfypsroJnyZx6HashlSstkmgmOF
         l+1sHzcjZNSLIOqQDNSeO5FwjgTI3YvviP9uZ6tQwy1pBcLCNslJyKW4YD5WzIXVoyrd
         iIR0mb9U1cuMDUtNV3MKWJSYHT2TShO3u5G/D5ODJbynhDDOVVnriKNmlBdGmDuYsIfh
         bkBw8MdMd1nQwI7T2L4V6LhvteriiXa4hXMPXO8aDUm4dhurkX90cQXmDdsvCuK1/sG1
         QrXzQk4stm0Dewx/RhoWRP4dsbdWdndO7GOleSFqsjr81FPBVs7ZlU2xj0GwVOyRkWit
         bWfA==
X-Gm-Message-State: APjAAAVgoPEBia58bgQXlMkB8SXT9xwOxJ5aMwxF6b3+dBU6+gZy7b0s
	3aH4yf4eFFLgl9GoRS1AooQ7TWC6D8bDhxDg1boIi05CQfWDFbGMNyT+zpMzdNDM4Ia/ZIouoYB
	KIV6/9SbHEeV3YDUMh/idNuz4/RAlKoAO37Dq7HxNKgYzfju+vSakVJrQY3F8RpwC5w==
X-Received: by 2002:a2e:12c8:: with SMTP id 69mr31834028ljs.189.1560321810111;
        Tue, 11 Jun 2019 23:43:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxcOV/6C7tY66uWMQcCH0gn8As+oAqFrUULmxSfnDp2kXzb3ncHNywG4mLMhYrObEa/ijEK
X-Received: by 2002:a2e:12c8:: with SMTP id 69mr31833961ljs.189.1560321808956;
        Tue, 11 Jun 2019 23:43:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560321808; cv=none;
        d=google.com; s=arc-20160816;
        b=gPX+WNXem+kat4GW/23Kpxbqk3lv3m+ViMJH6vQFnRRY1htfXg6lCEnRjZTBjU4kWD
         SPiOyJI6ne9Fw+Dx+d0qoa7tEFxO6uLm86EafE3WsX05IGGn/n3vN3hH7VjjOsYaRXIB
         rhyOiCYQ4b5Iv5IyUPO8m52crSxhSbk8f97WpMBjPEZund7y2Fk7YCv1M+IjBjj2rCWm
         6bjKrrMBMPuGTdZP/Y3Av2LEeeqfdflFSosmI3NjiobtcaNSyiw62t6kzSfc571WcgJm
         GozScEh7bZ+5aln6BKEPE13HcI4Xf551uWBLCLqh8AZ2yytMbBU9IPBmyihfkD1wqsgr
         4LzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=nXeAn+b9rzfB9xUtBdzEuMbNYPo06z76iQWWf55VKQQ=;
        b=0fadF1nhjerSSBj+RE7SvWcI+eiDR63M4wzLiCYLq0eqHDJFRNbBemurh5htxbRsw0
         qQw9j3OnJ/b3zrrXy1/lYDYZtsHxfyCJ8kilx22e6rvJtkjhEAZzuS/1/5Na9aIOthgw
         EssWmQQj+Q4rDHsibHRKIQcTmfmPGV0LSF2WmJvMgAWgnYbz4PG9vnU5tkce5xW2foog
         IrJ49EojEoshE3yZp0Y9OpQHDhLFcaJx2OlofO08WMY//hQaC/HPP3qvHS1oYrorotuo
         /t3gD3ielnz7UHG6bGJx424fej7MvZ08x39jbk2ribY4pN5Zq/zKhRhatZ7IRq+XZR6J
         PtLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmwopensource.org header.s=mail header.b=eeOw22qy;
       spf=pass (google.com: domain of thellstrom@vmwopensource.org designates 213.80.101.71 as permitted sender) smtp.mailfrom=thellstrom@vmwopensource.org
Received: from ste-pvt-msa2.bahnhof.se (ste-pvt-msa2.bahnhof.se. [213.80.101.71])
        by mx.google.com with ESMTPS id e9si14562563ljk.132.2019.06.11.23.43.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 23:43:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of thellstrom@vmwopensource.org designates 213.80.101.71 as permitted sender) client-ip=213.80.101.71;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmwopensource.org header.s=mail header.b=eeOw22qy;
       spf=pass (google.com: domain of thellstrom@vmwopensource.org designates 213.80.101.71 as permitted sender) smtp.mailfrom=thellstrom@vmwopensource.org
Received: from localhost (localhost [127.0.0.1])
	by ste-pvt-msa2.bahnhof.se (Postfix) with ESMTP id 706333F771;
	Wed, 12 Jun 2019 08:43:10 +0200 (CEST)
Authentication-Results: ste-pvt-msa2.bahnhof.se;
	dkim=pass (1024-bit key; unprotected) header.d=vmwopensource.org header.i=@vmwopensource.org header.b=eeOw22qy;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at bahnhof.se
Authentication-Results: ste-ftg-msa2.bahnhof.se (amavisd-new);
	dkim=pass (1024-bit key) header.d=vmwopensource.org
Received: from ste-pvt-msa2.bahnhof.se ([127.0.0.1])
	by localhost (ste-ftg-msa2.bahnhof.se [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id eN_KM0t7dhF0; Wed, 12 Jun 2019 08:42:56 +0200 (CEST)
Received: from mail1.shipmail.org (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	(Authenticated sender: mb878879)
	by ste-pvt-msa2.bahnhof.se (Postfix) with ESMTPA id 780233F708;
	Wed, 12 Jun 2019 08:42:55 +0200 (CEST)
Received: from localhost.localdomain.localdomain (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	by mail1.shipmail.org (Postfix) with ESMTPSA id E0884361B6A;
	Wed, 12 Jun 2019 08:42:54 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=vmwopensource.org;
	s=mail; t=1560321775;
	bh=Yjmtl92sLAlEoB99F5XOnCklObajAbb4hpy0froOh7I=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=eeOw22qyp5zCYVRoM/flnXFq8CVLDiTHGne8tBYD5h07U6ysR3JsuLgcA17isFPZK
	 L287x8k3sc6DRFwmYDPnxXTZMr03rF/Y4LtPDq4v5PRWhisSkqsidnDs4iiubpxtZR
	 NQ7I0hIgw0DO0H2J//GflKMp0Tz7Xoxsxk+S6F9Y=
From: =?UTF-8?q?Thomas=20Hellstr=C3=B6m=20=28VMware=29?= <thellstrom@vmwopensource.org>
To: dri-devel@lists.freedesktop.org
Cc: linux-graphics-maintainer@vmware.com,
	pv-drivers@vmware.com,
	linux-kernel@vger.kernel.org,
	nadav.amit@gmail.com,
	Thomas Hellstrom <thellstrom@vmware.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>,
	Will Deacon <will.deacon@arm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Rik van Riel <riel@surriel.com>,
	Minchan Kim <minchan@kernel.org>,
	Michal Hocko <mhocko@suse.com>,
	Huang Ying <ying.huang@intel.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	linux-mm@kvack.org,
	Ralph Campbell <rcampbell@nvidia.com>
Subject: [PATCH v5 1/9] mm: Allow the [page|pfn]_mkwrite callbacks to drop the mmap_sem
Date: Wed, 12 Jun 2019 08:42:35 +0200
Message-Id: <20190612064243.55340-2-thellstrom@vmwopensource.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190612064243.55340-1-thellstrom@vmwopensource.org>
References: <20190612064243.55340-1-thellstrom@vmwopensource.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Thomas Hellstrom <thellstrom@vmware.com>

Driver fault callbacks are allowed to drop the mmap_sem when expecting
long hardware waits to avoid blocking other mm users. Allow the mkwrite
callbacks to do the same by returning early on VM_FAULT_RETRY.

In particular we want to be able to drop the mmap_sem when waiting for
a reservation object lock on a GPU buffer object. These locks may be
held while waiting for the GPU.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@surriel.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Huang Ying <ying.huang@intel.com>
Cc: Souptick Joarder <jrdr.linux@gmail.com>
Cc: "Jérôme Glisse" <jglisse@redhat.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Signed-off-by: Thomas Hellstrom <thellstrom@vmware.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
---
 mm/memory.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index ddf20bd0c317..168f546af1ad 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2238,7 +2238,7 @@ static vm_fault_t do_page_mkwrite(struct vm_fault *vmf)
 	ret = vmf->vma->vm_ops->page_mkwrite(vmf);
 	/* Restore original flags so that caller is not surprised */
 	vmf->flags = old_flags;
-	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
+	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 	if (unlikely(!(ret & VM_FAULT_LOCKED))) {
 		lock_page(page);
@@ -2515,7 +2515,7 @@ static vm_fault_t wp_pfn_shared(struct vm_fault *vmf)
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
 		vmf->flags |= FAULT_FLAG_MKWRITE;
 		ret = vma->vm_ops->pfn_mkwrite(vmf);
-		if (ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE))
+		if (ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY))
 			return ret;
 		return finish_mkwrite_fault(vmf);
 	}
@@ -2536,7 +2536,8 @@ static vm_fault_t wp_page_shared(struct vm_fault *vmf)
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
 		tmp = do_page_mkwrite(vmf);
 		if (unlikely(!tmp || (tmp &
-				      (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
+				      (VM_FAULT_ERROR | VM_FAULT_NOPAGE |
+				       VM_FAULT_RETRY)))) {
 			put_page(vmf->page);
 			return tmp;
 		}
@@ -3601,7 +3602,8 @@ static vm_fault_t do_shared_fault(struct vm_fault *vmf)
 		unlock_page(vmf->page);
 		tmp = do_page_mkwrite(vmf);
 		if (unlikely(!tmp ||
-				(tmp & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
+				(tmp & (VM_FAULT_ERROR | VM_FAULT_NOPAGE |
+					VM_FAULT_RETRY)))) {
 			put_page(vmf->page);
 			return tmp;
 		}
-- 
2.20.1

