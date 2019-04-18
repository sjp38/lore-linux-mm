Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 666A2C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 13:50:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CBF920674
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 13:50:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CBF920674
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B3F36B0006; Thu, 18 Apr 2019 09:50:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 73C0B6B0008; Thu, 18 Apr 2019 09:50:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 607A86B000A; Thu, 18 Apr 2019 09:50:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0AA0C6B0006
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 09:50:57 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id o8so1273246edh.12
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 06:50:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=j13ppKnA5XOevfzHj/veY7J+stZTddhKz4lu9/wYA5o=;
        b=CzHlieDRozpd6S9dpT/E2CDIF/M/tdRycFfuOUKesMG9E3/Enkz6No9y0RQkdCkRkH
         Wc3PgR6CYY9Ps93r9dYDAz290t5c8lR2xeAXsC/nrPivOdqN7jedXkVjfRb902QkZzc3
         erVySVNvPJTT5YA5J6MWsmHUXLkzOFO1e+vRHFZVRUGWaXEB8xug/nUTXffsbzURoxf1
         JIgr9J6VenWtIyGNQMcsLG/WoS/cAQpvdR1cSJqHZd0sEsDBOIdy0xWy7FeZR+Jyfwnp
         ABSx9dDTW28h8zyHvcXOQC841BkhKMpm0/LltsqBpqjQW0RuqfZ+5TVvWa1EltoIHOP5
         fiZw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Gm-Message-State: APjAAAVklRN0rcfLT4OOnWvBljiiT5unIy4it5/JpnSFJ8rJhLWCBf//
	ge45A96TFnQVdexncc4+OVmhLD4na/gMSBPCF8H17pU4+W1yhDF7PqignZJsiwnsnNQMhloApBA
	Dw6929B7wWQAnQKpCt0BnNfeP7BuLe6o9SWVAmLNXXYP41PrjICGc2ABDw2OwSiTyeg==
X-Received: by 2002:a17:906:a85a:: with SMTP id dx26mr50804580ejb.206.1555595456516;
        Thu, 18 Apr 2019 06:50:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyr+LmsdU2R5FgmCwLKY8tCaxiR02qaE5oH2hou/PbcmnB2bNVPXCcI+AGRvLJO64jw/6z3
X-Received: by 2002:a17:906:a85a:: with SMTP id dx26mr50804543ejb.206.1555595455530;
        Thu, 18 Apr 2019 06:50:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555595455; cv=none;
        d=google.com; s=arc-20160816;
        b=iJ/w2FqgG00/gNko6VM/xm3hu0s67OMrh2hl6WnPui6v/QWF2S5PaujGPmtiLk0dZ2
         xZPJWpL60L430Uj346Up8fCTt2aRKnSoDUcvVjrD6IegvFqiebWvUC8zic4xLYYFbokV
         +KJmFmIkXvFRZLkSeCZq2m5mo7MyAW8t4API7cHrostqXSNbp23JIvh5UGPS0itqnwy4
         C5aMFT6q8h/QuyjLOrn1qbYylDG2o05Igz0ertDWrrJqkTYJ5M9RjNOmibS9ckN542UC
         52gVbIzbC0PACvCjBHgR+iThqrHJmzJpegL8VuCjyQ8mINmw6ibh50ChJt3HjyKK3drL
         etSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=j13ppKnA5XOevfzHj/veY7J+stZTddhKz4lu9/wYA5o=;
        b=wsG7V5muThPBAhr21yPOOebwA6KC7f5lEjtBhbcYq5XLs9K1Tlu+tDVM8dekUECkIQ
         58kayEkWI0FaCBXWyVklYcflfPt5SQDyFA4Tht/eAQopHdEVKZTUD9bSSTU0Xi3ho4eG
         msBs7BLegsNiRNvIM88lmR9DEq/5B5nHAdJCn05TyGgTCARjnT+fpMOnd+6P9MMCiy0Y
         FSZXlqzsW3X/BovXodtB16aTJ15RyW+PgOt7jHE6la2CnxXw0O3fKlg4IqEl70m8BdMT
         u33iNRMeQ/EZqp/BSF9PFaQpXsREfr3OGMbyu52QH3AM6XS3iFgUQmsnXC9OynDDbOcU
         uG7w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hb2si1012835ejb.291.2019.04.18.06.50.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 06:50:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A41E2B6A0;
	Thu, 18 Apr 2019 13:50:54 +0000 (UTC)
From: =?UTF-8?q?Michal=20Koutn=C3=BD?= <mkoutny@suse.com>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: mhocko@kernel.org,
	akpm@linux-foundation.org,
	arunks@codeaurora.org,
	brgl@bgdev.pl,
	geert+renesas@glider.be,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	mguzik@redhat.com,
	mkoutny@suse.com,
	rppt@linux.ibm.com,
	vbabka@suse.cz,
	Laurent Dufour <ldufour@linux.ibm.com>
Subject: [PATCH] prctl_set_mm: downgrade mmap_sem to read lock
Date: Thu, 18 Apr 2019 15:50:39 +0200
Message-Id: <20190418135039.19987-1-mkoutny@suse.com>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190417145548.GN5878@dhcp22.suse.cz>
References: <20190417145548.GN5878@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I learnt, it's, alas, too late to drop the non PRCTL_SET_MM_MAP calls
[1], so at least downgrade the write acquisition of mmap_sem as in the
patch below (that should be stacked on the previous one or squashed).

Cyrill, you mentioned lock changes in [1] but the link seems empty. Is
it supposed to be [2]? That could be an alternative to this patch after
some refreshments and clarifications.


[1] https://lore.kernel.org/lkml/20190417165632.GC3040@uranus.lan/
[2] https://lore.kernel.org/lkml/20180507075606.870903028@gmail.com/

========

Since commit 88aa7cc688d4 ("mm: introduce arg_lock to protect
arg_start|end and env_start|end in mm_struct") we use arg_lock for
boundaries modifications. Synchronize prctl_set_mm with this lock and
keep mmap_sem for reading only (analogous to what we already do in
prctl_set_mm_map).

Also, save few cycles by looking up VMA only after performing basic
arguments validation.

Signed-off-by: Michal Koutný <mkoutny@suse.com>
---
 kernel/sys.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/kernel/sys.c b/kernel/sys.c
index 12df0e5434b8..bbce0f26d707 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -2125,8 +2125,12 @@ static int prctl_set_mm(int opt, unsigned long addr,
 
 	error = -EINVAL;
 
-	down_write(&mm->mmap_sem);
-	vma = find_vma(mm, addr);
+	/*
+	 * arg_lock protects concurent updates of arg boundaries, we need mmap_sem for
+	 * a) concurrent sys_brk, b) finding VMA for addr validation.
+	 */
+	down_read(&mm->mmap_sem);
+	spin_lock(&mm->arg_lock);
 
 	prctl_map.start_code	= mm->start_code;
 	prctl_map.end_code	= mm->end_code;
@@ -2185,6 +2189,7 @@ static int prctl_set_mm(int opt, unsigned long addr,
 	if (error)
 		goto out;
 
+	vma = find_vma(mm, addr);
 	switch (opt) {
 	/*
 	 * If command line arguments and environment
@@ -2218,7 +2223,8 @@ static int prctl_set_mm(int opt, unsigned long addr,
 
 	error = 0;
 out:
-	up_write(&mm->mmap_sem);
+	spin_unlock(&mm->arg_lock);
+	up_read(&mm->mmap_sem);
 	return error;
 }
 
-- 
2.16.4

