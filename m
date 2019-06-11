Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E73BC43218
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 12:25:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6AF222089E
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 12:25:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmwopensource.org header.i=@vmwopensource.org header.b="HpZERFbf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6AF222089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=vmwopensource.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D71D16B0269; Tue, 11 Jun 2019 08:25:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C5E246B0008; Tue, 11 Jun 2019 08:25:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB0516B0010; Tue, 11 Jun 2019 08:25:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3B7236B0008
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 08:25:31 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id h14so209616lja.9
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 05:25:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=nXeAn+b9rzfB9xUtBdzEuMbNYPo06z76iQWWf55VKQQ=;
        b=ESyhfc+Lej9XGqyXZjmmODcJ8VZ9rOF+vDlAKDwELSF8JYweSGHLL+rtvj3r3XuwB7
         tno8jJvEXEh1ARNvlfx4czgI20qPYr1cNkGXgCG/0G1QwIO/qfaCHuTt4MELE4uJY0i9
         gs47New+ecANmwoPkeRCrn22TO8zHUxgd2Hrl1Wj2HwQBNgwrD50ps72N6kGdPh+D2ms
         O0SEYny//4EeKW92POKIGfCkQTgSrVUwx7SF5us50HCsfQlDtkS8qZ73H/dOC2wCob2X
         /iCZ7/T8Ov3RalAk4IK12rqyojstHSFTpu0+2XyqOGcIjkHalS3l9nBRS2R11v0al1Bn
         zc9Q==
X-Gm-Message-State: APjAAAUu7gLlN94iduLwWce4xCSmFu32r02KSc2x0frBF2JrIgjQkX5h
	bfiElQLb8/SvQjPT7FG8yb3EjI9w8uTm9I6C+kwKzK4ZxvO1ZkNvScgxhRt1pJrmcYiSBJxvsJc
	EETFMOy8LSDiSkS73huUGaeh75uUJmqphxFuNmlIVfmP3/LJUf6DbL83wP2C/3I+OJg==
X-Received: by 2002:ac2:4ace:: with SMTP id m14mr29091135lfp.99.1560255930565;
        Tue, 11 Jun 2019 05:25:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzal8+5ebyH7Peq/Rv9Zm6tuVaz+jUTznumQnp9tDgYS2XV1/jc9gHPCY4zYgW1rh77lE7t
X-Received: by 2002:ac2:4ace:: with SMTP id m14mr29091079lfp.99.1560255929018;
        Tue, 11 Jun 2019 05:25:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560255929; cv=none;
        d=google.com; s=arc-20160816;
        b=IcEgXnUq0ZAHo5DDXYpGN47Ee89CCGTZYrYI8F4VN8KJuRdv40kjgAFcQXx0KTcwNj
         FggGhmwNoB34zJsGcsN9uN3/Etezvg2Az1UXMacrBJWl1++xgFYHus48wMonlF2uDre3
         TNUn59i8gSQn2RecjJQoVCFrtPK24StYxBmyhZslEetj1DIYLqMeN7+sb5pA+NXq+Yld
         RwZ9/BlAtxRFEgcKRV5P8A7UKPgeESYn0GH59teC1bkq0+glg38oZx06wE2T+rrctLs3
         RN2y0nMx02vn8eyCW1ihtUvWh50qI64dHZFPuZrUtuOOCkdl/YGrX5RX3v1baR4dv/Hg
         x6QA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=nXeAn+b9rzfB9xUtBdzEuMbNYPo06z76iQWWf55VKQQ=;
        b=dqPRv3iIqpnaoBVVFymoDxJsJBsYr7IWZdsmukrWshEmBORertOIY2O/6F7AsTiyv4
         XcDjUH0goN6iiSAfJoCzJJNlmPl/orbqx6f3QKCIJqrYyTHFCp4yDxWjU64gjv+OvpUJ
         8sFY/7vzIsspfdmCePyBUgIxnM/bxV3bfbX0RQRtf/IvURwrD3s+0YVbWmOkF52ksTQR
         lIDrPdgzQyeI6jIQ5nIMFfbDH1pzG4v/Mgj2rW0WIUubeZhOVeVttbwjjgXGqZUEnS8Q
         YZ4JEX2xrNvb9vEuJlUgJhyxTbqJhht1FUG0u/3qGE1p0eQbzW3yERgS/JK6KiezLyvn
         /2qw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmwopensource.org header.s=mail header.b=HpZERFbf;
       spf=pass (google.com: domain of thellstrom@vmwopensource.org designates 213.80.101.70 as permitted sender) smtp.mailfrom=thellstrom@vmwopensource.org
Received: from ste-pvt-msa1.bahnhof.se (ste-pvt-msa1.bahnhof.se. [213.80.101.70])
        by mx.google.com with ESMTPS id f15si12711310ljj.159.2019.06.11.05.25.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 05:25:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of thellstrom@vmwopensource.org designates 213.80.101.70 as permitted sender) client-ip=213.80.101.70;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmwopensource.org header.s=mail header.b=HpZERFbf;
       spf=pass (google.com: domain of thellstrom@vmwopensource.org designates 213.80.101.70 as permitted sender) smtp.mailfrom=thellstrom@vmwopensource.org
Received: from localhost (localhost [127.0.0.1])
	by ste-pvt-msa1.bahnhof.se (Postfix) with ESMTP id 2CC533F4E9;
	Tue, 11 Jun 2019 14:25:23 +0200 (CEST)
Authentication-Results: ste-pvt-msa1.bahnhof.se;
	dkim=pass (1024-bit key; unprotected) header.d=vmwopensource.org header.i=@vmwopensource.org header.b=HpZERFbf;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at bahnhof.se
Received: from ste-pvt-msa1.bahnhof.se ([127.0.0.1])
	by localhost (ste-pvt-msa1.bahnhof.se [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 5Yf27d0c83ds; Tue, 11 Jun 2019 14:25:09 +0200 (CEST)
Received: from mail1.shipmail.org (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	(Authenticated sender: mb878879)
	by ste-pvt-msa1.bahnhof.se (Postfix) with ESMTPA id 7AA2B3F4D4;
	Tue, 11 Jun 2019 14:25:08 +0200 (CEST)
Received: from localhost.localdomain.localdomain (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	by mail1.shipmail.org (Postfix) with ESMTPSA id 184593619C2;
	Tue, 11 Jun 2019 14:25:08 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=vmwopensource.org;
	s=mail; t=1560255908;
	bh=Yjmtl92sLAlEoB99F5XOnCklObajAbb4hpy0froOh7I=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=HpZERFbfctFUuY5BHsAZYFpqZOEK+RF4iSdbsPLxbQM3huaaTreM0SlaTqnbw9qkc
	 OhuLbs/xeGddT/D90s6VBlW7b6ICuwZpG+YTBb/kJw4eVsBTIrDhJ+6kfsWbHCfWEx
	 EYx9Koa+3No3QMUm+EmR+8Rwkdzmz9gfzQIfZV0s=
From: =?UTF-8?q?Thomas=20Hellstr=C3=B6m=20=28VMware=29?= <thellstrom@vmwopensource.org>
To: dri-devel@lists.freedesktop.org
Cc: linux-graphics-maintainer@vmware.com,
	pv-drivers@vmware.com,
	linux-kernel@vger.kernel.org,
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
Subject: [PATCH v4 1/9] mm: Allow the [page|pfn]_mkwrite callbacks to drop the mmap_sem
Date: Tue, 11 Jun 2019 14:24:46 +0200
Message-Id: <20190611122454.3075-2-thellstrom@vmwopensource.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190611122454.3075-1-thellstrom@vmwopensource.org>
References: <20190611122454.3075-1-thellstrom@vmwopensource.org>
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

