Return-Path: <SRS0=K2XS=UI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29C1DC28EBD
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 10:09:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D39DE20693
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 10:09:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="z05nsIep"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D39DE20693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1887B6B026A; Sun,  9 Jun 2019 06:09:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1158E6B026B; Sun,  9 Jun 2019 06:09:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE1DB6B026C; Sun,  9 Jun 2019 06:09:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 78BA36B026A
	for <linux-mm@kvack.org>; Sun,  9 Jun 2019 06:09:04 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id d18so1317314lfn.11
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 03:09:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=JjGSbXYSmI2Txw4mQvoTR75+oGXHH64lCXqV4geoUls=;
        b=lNA000W+TcIPZbXwpEFqFgiPp0t3i+GyjKmIfotPlPGtbpKfCbite2znOBqM4WEeOu
         0Jfd/liJ3YFDx3UUbvpS8RQ1soxOGfLKVrMmy4BkYfIaSHfi9W/Wx6KplTKXBNJwz57B
         ToXPnu7ottRaHCWvNnPc1+L46EvPieSZmhNmjpbnPsgzMmvrNF9XIt25AB2rZAd0uZ//
         eDykDsWNn8OqPhtMr4xPILqe2ouN0+l9SJcWQXYLRwE0Oxv89JJwwiTTbvf8BIS9aaxN
         ZHo5cu3sA22LDeNq9sQoMEKqqUPFaWqRbuCc7oHPfduXaHTM2dCedCRBW3ibNOt43D+7
         fYCg==
X-Gm-Message-State: APjAAAV2GfWRhwZF1pfFyCFyJg87iKjt8RjjHksLmpAHFI1z/j5BifL1
	ubU8AV9oiEWpYQ7RNIe18Gnt9f+CHA5TRb3G1mWX+FJxDN0TkFEFWhFj8wG73BtnjtKpu8piNxH
	HuHPUfnomvPDLV8nTz7U7i0XFL5ttem16VwjsbBb77KwWzRqFs+/xYmFI1uAAJACV4g==
X-Received: by 2002:a2e:1290:: with SMTP id 16mr13821683ljs.88.1560074943939;
        Sun, 09 Jun 2019 03:09:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwdGn3dA3NjRyLH3SPbKCFgiTwNe9sfsI1opLY/RIwDHO8+awFY/onct7AHIxb7xMcQDen1
X-Received: by 2002:a2e:1290:: with SMTP id 16mr13821655ljs.88.1560074943107;
        Sun, 09 Jun 2019 03:09:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560074943; cv=none;
        d=google.com; s=arc-20160816;
        b=iuhCkAnXiKql8MoC7uFx07eADb6Qvr1Rp0ZnHtcwRCBAFEmGfym+B/9HcOC+TuFA6G
         fa+rfEtQUWnS51SMyf2iGaHct0nZN5RB4rDqnfwFn80ekMYrarYzz1i8H+oamKrcrgvU
         zocW+DI1zi2Lsqgy8gum7truyvsxOrfYxk7He77ldFcYZRExZYQNV15ZbFfSeMTZ0Lk2
         snqNd004l4YWWrPz6DYeg9ODbUf5t3BUhMD0iKE+FpZiFl9UAjs83Y8VehZ46GNP/xaD
         afVcg8hKw7e3f/WoMytDpI9A+moV6JQiwPQbNRv/IYV+20x6jYP7bGANg5VxIKTPCGD9
         CnAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=JjGSbXYSmI2Txw4mQvoTR75+oGXHH64lCXqV4geoUls=;
        b=ZIq+uJNwaZQmRbHc9pcmkZ8nrt9CPmkYFd6c+59IO7m7y/HrsOeHMYZGd6XpYIp91w
         656YpKpFL52f5PHoI0ILli/ILHp/9TzuuQqbZUh7Yo58NkE6vH0PEUhMJEepXtgSTErl
         ycPS3lpBi6iJ+hcWEJz2YVt5bDy6ttDN23l6uZQv1nQV/chTbHpY9Wbv6bqR1Fs4HyU0
         PhfTh6gs9qSjzcqwxERMYigKWAlc72ybi+WLVkgDrCx5uTP/N/X8GUZvdvJ2O3SyoM/M
         Df/iBzgOfyvlMd26kz/p8tA2DYtIL2XfVFaqFqLVpB4i9iSMDasewmH1rHB65tH3u77v
         uHNA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=z05nsIep;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1o.mail.yandex.net (forwardcorp1o.mail.yandex.net. [2a02:6b8:0:1a2d::193])
        by mx.google.com with ESMTPS id m76si6371958lje.218.2019.06.09.03.09.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Jun 2019 03:09:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) client-ip=2a02:6b8:0:1a2d::193;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=z05nsIep;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp2j.mail.yandex.net (mxbackcorp2j.mail.yandex.net [IPv6:2a02:6b8:0:1619::119])
	by forwardcorp1o.mail.yandex.net (Yandex) with ESMTP id B8BB62E128E;
	Sun,  9 Jun 2019 13:09:02 +0300 (MSK)
Received: from smtpcorp1p.mail.yandex.net (smtpcorp1p.mail.yandex.net [2a02:6b8:0:1472:2741:0:8b6:10])
	by mxbackcorp2j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id GPVqI98PV5-92dCP51C;
	Sun, 09 Jun 2019 13:09:02 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1560074942; bh=JjGSbXYSmI2Txw4mQvoTR75+oGXHH64lCXqV4geoUls=;
	h=In-Reply-To:Message-ID:References:Date:To:From:Subject:Cc;
	b=z05nsIep3y7fvuABy75loevMGYRGUtTHeQP1HW8df8+IXOW2u4oPs4rqs77tk3V1T
	 ySkTzZ5JZMrZYc4IRni1naQVfoWdJ/CQ7/qbULv2tO3ILPiMJ0Mts/9/h9VdWHIUQC
	 yK30fHdHJgvsU48poLX+VtrcTBd9hqYMjvZRVDaM=
Authentication-Results: mxbackcorp2j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:3d25:9e27:4f75:a150])
	by smtpcorp1p.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id RlV9qeaXk1-92gun05E;
	Sun, 09 Jun 2019 13:09:02 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH v2 6/6] mm: use down_read_killable for locking mmap_sem in
 access_remote_vm
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 linux-kernel@vger.kernel.org
Cc: Oleg Nesterov <oleg@redhat.com>, Matthew Wilcox <willy@infradead.org>,
 Michal Hocko <mhocko@kernel.org>, Cyrill Gorcunov <gorcunov@gmail.com>,
 Kirill Tkhai <ktkhai@virtuozzo.com>,
 Michal =?utf-8?q?Koutn=C3=BD?= <mkoutny@suse.com>,
 Al Viro <viro@zeniv.linux.org.uk>, Roman Gushchin <guro@fb.com>
Date: Sun, 09 Jun 2019 13:09:02 +0300
Message-ID: <156007494202.3335.16782303099589302087.stgit@buzz>
In-Reply-To: <156007465229.3335.10259979070641486905.stgit@buzz>
References: <156007465229.3335.10259979070641486905.stgit@buzz>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This function is used by ptrace and proc files like /proc/pid/cmdline and
/proc/pid/environ.

Access_remote_vm never returns error codes, all errors are ignored and
only size of successfully read data is returned. So, if current task was
killed we'll simply return 0 (bytes read).

Mmap_sem could be locked for a long time or forever if something wrong.
Killable lock allows to cleanup stuck tasks and simplifies investigation.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Reviewed-by: Michal Koutný <mkoutny@suse.com>
Acked-by: Oleg Nesterov <oleg@redhat.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 mm/memory.c |    4 +++-
 mm/nommu.c  |    3 ++-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index ddf20bd0c317..9a4401d21e94 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4349,7 +4349,9 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 	void *old_buf = buf;
 	int write = gup_flags & FOLL_WRITE;
 
-	down_read(&mm->mmap_sem);
+	if (down_read_killable(&mm->mmap_sem))
+		return 0;
+
 	/* ignore errors, just check how much was successfully transferred */
 	while (len) {
 		int bytes, ret, offset;
diff --git a/mm/nommu.c b/mm/nommu.c
index d8c02fbe03b5..b2823519f8cd 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1792,7 +1792,8 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 	struct vm_area_struct *vma;
 	int write = gup_flags & FOLL_WRITE;
 
-	down_read(&mm->mmap_sem);
+	if (down_read_killable(&mm->mmap_sem))
+		return 0;
 
 	/* the access must start within one of the target process's mappings */
 	vma = find_vma(mm, addr);

