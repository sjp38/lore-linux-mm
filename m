Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99E05C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 12:52:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 575B420449
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 12:52:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 575B420449
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B5E526B0007; Thu,  2 May 2019 08:52:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B369A6B0008; Thu,  2 May 2019 08:52:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B02B6B000A; Thu,  2 May 2019 08:52:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4D14A6B0007
	for <linux-mm@kvack.org>; Thu,  2 May 2019 08:52:18 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id e21so1000943edr.18
        for <linux-mm@kvack.org>; Thu, 02 May 2019 05:52:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=05duYDah7+aoFQu7zJfyawnp25zSjdLxSn5XdE6yKZI=;
        b=Wd/Y4etaMQavtsQ8b9ebwMu1QkVns7eXmhlKmbqQr8nK+7QznoAO07i14Mm2QlUvlT
         Br2kQc49u0GJka+PtmNNtZqMwjUjF0UEy0PxF8nF81PstEC784zLDrWNTcpvr6irLtf6
         D5pxwQ+1Rw/zYaVwlQm3ou6JZii6JuyEM8NyQ9bFTJdhAbomJy5nKHxtf33sEaMUZSv5
         cUZ+qjpplZWF2UaL/dlhqkV5pYphYczVslu5T/iIPaP+aF0G/JZxs1IwpTM+BuFt+STy
         Q5XdQGMcmghEXIm+S92WDh7YcTizoa1On6EzxFFx0JrOiHy9Ar+wO7uANVxsoOR8Hd/n
         2OOg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Gm-Message-State: APjAAAUvp/wZQUmViwaaWUgu9/j6Y29Gw1Dgmy8ouXKFt2WTrDyKrw9C
	NxBXdvpoUDyMi/ri/MExmyLuGZ92Gx68fJh50EQ2V+a/Zud5GFSBHbl/SrGGIRP4yIfQ7cGM7oK
	Au5eNz0AScGxNiYEkhs3WtG39CDCZqGTw5MER/cBtQY/xqdnW3yimjvI9GNPANDkqGA==
X-Received: by 2002:a17:906:7d43:: with SMTP id l3mr1745657ejp.81.1556801537853;
        Thu, 02 May 2019 05:52:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzpBFG/mYKFzmu0UL7CggvDzRKWmdMQWEum8Of4lT/24ReHJkczirA+ineyhJpb5SUDQ2V4
X-Received: by 2002:a17:906:7d43:: with SMTP id l3mr1745619ejp.81.1556801536966;
        Thu, 02 May 2019 05:52:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556801536; cv=none;
        d=google.com; s=arc-20160816;
        b=HdoCSEihYk+FQ5OsEi3ljJ9gcilRPzzSzPSFelMpZfN6WxftzV2qGwG9TxOClxTXup
         Lwo7cM8ARw9rWLxpfZ9kMzz76mUlJ0AShSHzQm0YNv4oVjjZNOxFDme3w2ghhT0imNaI
         LyroeLKaXpVWEqxHTb6Y2afDLNE1D5rdWbJTjVBYCDcG67PCne4+T5sfwXzKKhV+LzjX
         /bWTNuavYIvaGG5KnKfQidg5DTPRG+ZP635kjRmOfLVJH5nkUcD+iBVfrtvIQKMNAVlm
         pKSL1Kng9S6R496a9YQU6jPXpcvclX6eFMJXtWBjfJYm5CJBZhYhsFx2g9RpFqPLlnM6
         Cvdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=05duYDah7+aoFQu7zJfyawnp25zSjdLxSn5XdE6yKZI=;
        b=dG9S4isLJeOJsVAprGCtu147Jh10DDNdsaPUNVJ84bT+QopEOl1NGqlIPGmfrBnnan
         Dh6etUeFubsqlU/krChbh41l9DHxSMoYnHIlbz8dk6g55kM3alCH/y8epo8Mr53px0bQ
         wkOwAgtmNkW/3PEBtFENvsraxvVHmcPTxCmdVkOl3yqD3+PEyi2/r6o9rSpX7TNfcPhY
         RPWKaZDWPzMFcnrHRsXXBe8DYUZCQ5M5lhtgkuq4YDyW7nzKBCVHi36Hzq5r6p56apwL
         BEpWjisWKLbvo0uhcCnbZfMKFh3CarWU+cZvUeGbw5Fq8t0A1uBc1XDv0MmcFtjWE/Kt
         yhUw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q6si4453525edg.394.2019.05.02.05.52.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 May 2019 05:52:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mkoutny@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mkoutny@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 916A7AEDB;
	Thu,  2 May 2019 12:52:16 +0000 (UTC)
From: =?UTF-8?q?Michal=20Koutn=C3=BD?= <mkoutny@suse.com>
To: gorcunov@gmail.com
Cc: akpm@linux-foundation.org,
	arunks@codeaurora.org,
	brgl@bgdev.pl,
	geert+renesas@glider.be,
	ldufour@linux.ibm.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	mguzik@redhat.com,
	mhocko@kernel.org,
	mkoutny@suse.com,
	rppt@linux.ibm.com,
	vbabka@suse.cz,
	ktkhai@virtuozzo.com
Subject: [PATCH v3 2/2] prctl_set_mm: downgrade mmap_sem to read lock
Date: Thu,  2 May 2019 14:52:03 +0200
Message-Id: <20190502125203.24014-3-mkoutny@suse.com>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190502125203.24014-1-mkoutny@suse.com>
References: <0a48e0a2-a282-159e-a56e-201fbc0faa91@virtuozzo.com>
 <20190502125203.24014-1-mkoutny@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The commit a3b609ef9f8b ("proc read mm's {arg,env}_{start,end} with mmap
semaphore taken.") added synchronization of reading argument/environment
boundaries under mmap_sem. Later commit 88aa7cc688d4 ("mm: introduce
arg_lock to protect arg_start|end and env_start|end in mm_struct")
avoided the coarse use of mmap_sem in similar situations. But there
still remained two places that (mis)use mmap_sem.

get_cmdline should also use arg_lock instead of mmap_sem when it reads the
boundaries.

The second place that should use arg_lock is in prctl_set_mm. By
protecting the boundaries fields with the arg_lock, we can downgrade
mmap_sem to reader lock (analogous to what we already do in
prctl_set_mm_map).

v2: call find_vma without arg_lock held
v3: squashed get_cmdline arg_lock patch

Fixes: 88aa7cc688d4 ("mm: introduce arg_lock to protect arg_start|end and env_start|end in mm_struct")
Cc: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Mateusz Guzik <mguzik@redhat.com>
CC: Cyrill Gorcunov <gorcunov@gmail.com>
Co-developed-by: Laurent Dufour <ldufour@linux.ibm.com>
Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
Signed-off-by: Michal Koutný <mkoutny@suse.com>
---
 kernel/sys.c | 10 ++++++++--
 mm/util.c    |  4 ++--
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/kernel/sys.c b/kernel/sys.c
index 5e0a5edf47f8..14be57840511 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -2122,9 +2122,14 @@ static int prctl_set_mm(int opt, unsigned long addr,
 
 	error = -EINVAL;
 
-	down_write(&mm->mmap_sem);
+	/*
+	 * arg_lock protects concurent updates of arg boundaries, we need mmap_sem for
+	 * a) concurrent sys_brk, b) finding VMA for addr validation.
+	 */
+	down_read(&mm->mmap_sem);
 	vma = find_vma(mm, addr);
 
+	spin_lock(&mm->arg_lock);
 	prctl_map.start_code	= mm->start_code;
 	prctl_map.end_code	= mm->end_code;
 	prctl_map.start_data	= mm->start_data;
@@ -2212,7 +2217,8 @@ static int prctl_set_mm(int opt, unsigned long addr,
 
 	error = 0;
 out:
-	up_write(&mm->mmap_sem);
+	spin_unlock(&mm->arg_lock);
+	up_read(&mm->mmap_sem);
 	return error;
 }
 
diff --git a/mm/util.c b/mm/util.c
index 43a2984bccaa..5cf0e84a0823 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -758,12 +758,12 @@ int get_cmdline(struct task_struct *task, char *buffer, int buflen)
 	if (!mm->arg_end)
 		goto out_mm;	/* Shh! No looking before we're done */
 
-	down_read(&mm->mmap_sem);
+	spin_lock(&mm->arg_lock);
 	arg_start = mm->arg_start;
 	arg_end = mm->arg_end;
 	env_start = mm->env_start;
 	env_end = mm->env_end;
-	up_read(&mm->mmap_sem);
+	spin_unlock(&mm->arg_lock);
 
 	len = arg_end - arg_start;
 
-- 
2.16.4

