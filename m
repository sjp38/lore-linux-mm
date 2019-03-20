Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04213C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 15:23:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B40F42184E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 15:23:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B40F42184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 12BA06B0003; Wed, 20 Mar 2019 11:23:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B7D66B0006; Wed, 20 Mar 2019 11:23:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E99C06B0007; Wed, 20 Mar 2019 11:23:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id B09156B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 11:23:47 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 14so2976012pgf.22
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 08:23:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=QSSH5mmyQj+orx4MDN6qDovVAFAP1JQVbmouvPf0A0w=;
        b=SIZzz3FfAm7soWstoUyfe6345RUgSwEubrgTPIaU2L+pfbUX6/ZMcDaSr9x6zdZveZ
         cTHJL86YuYStt4mYjr1JXk40A2jFwoNZh9M+7Bw+5wSdWCUyEuST03i+r7BbbiNf51xI
         B17EqK0gydVkl6rIG3CwFML4qbwyvTsGk6KxarIRaR/PgAkpfDAkiJ5f4zArS+jF1Jct
         3c+tUhkxFEtFBsrW6GkjCfa9Gw2/arq4QqL3dD7Vhr9Fr/XuMbQdvWdLtqXb4Sdy1985
         yi9eRnq/3UoRcPboVh/gewit3dwLCv9QpjrVGcIfs1u9bLtZ37HpwXHanp4kSnNcPfNr
         KJ0Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of thellstrom@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=thellstrom@vmware.com;       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAXR6vy0YMTsTUHNvFQ2szKjvaHDAM4i496lAjTFtufKyw5WW9nS
	urUPAWL5BUP7fYLFAhWokVkaBNvWewY/QJ0CDOQ6c5FIO/Iv3kYk5XDXidYK4lJTVO1AT06AEU1
	YFDpQi7nXxSXrAGpsHTevebCMBHoCdrzWThcq7PY3SNYq+NGro+9HXqS9FEJ+w2YWNw==
X-Received: by 2002:a63:4e5b:: with SMTP id o27mr4305385pgl.204.1553095427253;
        Wed, 20 Mar 2019 08:23:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzFCONFLzWerpCXnu+QEzABfnd8cbYBsEp/Kugyru1GaSBS+6l2t24/UmGqO7TSBA2j3G6j
X-Received: by 2002:a63:4e5b:: with SMTP id o27mr4305279pgl.204.1553095425984;
        Wed, 20 Mar 2019 08:23:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553095425; cv=none;
        d=google.com; s=arc-20160816;
        b=k9PO8IYty5UXBqBNLfG6SOM+u0A9d5NN90q6JrIpFdknmZlBJbDhfkf3LC/rJQrI8P
         HdxSf+Vg2qwyqcxDcas6/y13CTtsWQz2LyQJq476mgSRWqd+xHfI19D80Ddsm0r8g+7O
         h/e32HGEMv/NGWi3Lq8GKnFx4ioz+3VomerzN77c4fug2/ktQIkaWc3hrAT8a4LkROGg
         1Wz2YRfLatHqCkcoa03kPf68/rqbntV1gqtqYzOl0/WuPo37RSPByAstuwlyJ1RD0sMD
         66YvjXXsBls5A6sqaAMAnMp3o177El9nEYKhqKDcu4cBxx1IC/6ZY23z7dG4yHXrWrH8
         BEfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=QSSH5mmyQj+orx4MDN6qDovVAFAP1JQVbmouvPf0A0w=;
        b=PtPhNknAIRrqR1ixz5yevkNJjWRIUX7VoRBfVnFToJ09YMNqdu7SbtIUsdTysrURz7
         tyl1VwwspL2C/ntgLPs/zbKMceC7pyamytG/c7UI59xyJYFQNZtlmjkhMUJJzWGPJ371
         //d5O+A2NuA6HCTW2bI7F9bErETaLY7MH9Azyz55Hngyi+vF6XyEvgXjlglQI+hizWRS
         6pF5KNAuoTnmS/PEJ72J+19MFEBqRI4xJm/L7ePobaD26tfRRCvuHldaBskIovhDtB8A
         qYkBe9TPW5QZ2Uh/jqbCffB9xg93FNhQjRaOAahy+icBbHouSy9S5bP6R8B4sTirR3u+
         KbxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of thellstrom@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=thellstrom@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-002.vmware.com (ex13-edg-ou-002.vmware.com. [208.91.0.190])
        by mx.google.com with ESMTPS id j65si1502473plb.104.2019.03.20.08.23.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 20 Mar 2019 08:23:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of thellstrom@vmware.com designates 208.91.0.190 as permitted sender) client-ip=208.91.0.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of thellstrom@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=thellstrom@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost3.vmware.com (10.113.161.73) by
 EX13-EDG-OU-002.vmware.com (10.113.208.156) with Microsoft SMTP Server id
 15.0.1156.6; Wed, 20 Mar 2019 08:23:40 -0700
Received: from fedoratest.localdomain (unknown [10.30.24.114])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id D58B94199D;
	Wed, 20 Mar 2019 08:23:41 -0700 (PDT)
From: Thomas Hellstrom <thellstrom@vmware.com>
To: <dri-devel@lists.freedesktop.org>
CC: <linux-graphics-maintainer@vmware.com>, Thomas Hellstrom
	<thellstrom@vmware.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew
 Wilcox <willy@infradead.org>, Will Deacon <will.deacon@arm.com>, Peter
 Zijlstra <peterz@infradead.org>, Rik van Riel <riel@surriel.com>, Minchan Kim
	<minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, Huang Ying
	<ying.huang@intel.com>, Souptick Joarder <jrdr.linux@gmail.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	<linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>
Subject: [RFC PATCH 1/3] mm: Allow the [page|pfn]_mkwrite callbacks to drop the mmap_sem
Date: Wed, 20 Mar 2019 16:23:13 +0100
Message-ID: <20190320152315.82758-2-thellstrom@vmware.com>
X-Mailer: git-send-email 2.19.0.rc1
In-Reply-To: <20190320152315.82758-1-thellstrom@vmware.com>
References: <20190320152315.82758-1-thellstrom@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Received-SPF: None (EX13-EDG-OU-002.vmware.com: thellstrom@vmware.com does not
 designate permitted sender hosts)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

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
---
 mm/memory.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index a52663c0612d..dcd80313cf10 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2144,7 +2144,7 @@ static vm_fault_t do_page_mkwrite(struct vm_fault *vmf)
 	ret = vmf->vma->vm_ops->page_mkwrite(vmf);
 	/* Restore original flags so that caller is not surprised */
 	vmf->flags = old_flags;
-	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
+	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_RETRY | VM_FAULT_NOPAGE)))
 		return ret;
 	if (unlikely(!(ret & VM_FAULT_LOCKED))) {
 		lock_page(page);
@@ -2419,7 +2419,7 @@ static vm_fault_t wp_pfn_shared(struct vm_fault *vmf)
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
 		vmf->flags |= FAULT_FLAG_MKWRITE;
 		ret = vma->vm_ops->pfn_mkwrite(vmf);
-		if (ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE))
+		if (ret & (VM_FAULT_ERROR | VM_FAULT_RETRY | VM_FAULT_NOPAGE))
 			return ret;
 		return finish_mkwrite_fault(vmf);
 	}
@@ -2440,7 +2440,8 @@ static vm_fault_t wp_page_shared(struct vm_fault *vmf)
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
 		tmp = do_page_mkwrite(vmf);
 		if (unlikely(!tmp || (tmp &
-				      (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
+				      (VM_FAULT_ERROR | VM_FAULT_RETRY |
+				       VM_FAULT_NOPAGE)))) {
 			put_page(vmf->page);
 			return tmp;
 		}
@@ -3472,7 +3473,8 @@ static vm_fault_t do_shared_fault(struct vm_fault *vmf)
 		unlock_page(vmf->page);
 		tmp = do_page_mkwrite(vmf);
 		if (unlikely(!tmp ||
-				(tmp & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
+				(tmp & (VM_FAULT_ERROR | VM_FAULT_RETRY |
+					VM_FAULT_NOPAGE)))) {
 			put_page(vmf->page);
 			return tmp;
 		}
-- 
2.19.0.rc1

