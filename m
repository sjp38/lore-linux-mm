Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88008C04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 08:41:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A19A2082E
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 08:41:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="aNjr5SR1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A19A2082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE5146B0266; Wed, 15 May 2019 04:41:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B95516B0269; Wed, 15 May 2019 04:41:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C2F66B026A; Wed, 15 May 2019 04:41:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1987D6B0266
	for <linux-mm@kvack.org>; Wed, 15 May 2019 04:41:25 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id 17so432417lfr.14
        for <linux-mm@kvack.org>; Wed, 15 May 2019 01:41:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=DXKTyv1Zt0cbjxS03oPn1lBJLs878fkqtHSHT6TGUvY=;
        b=eL7MZ7LBZYyjNt3lHWhwFWFao99PbTCnPHVdCqrnyWf/6I9HflP2kO9Nr2BIZmbgRN
         x0+fZW4VHvmHWSR+MPPgwfZGro67NLF0OcKcztE3uqEyZwyrpexdAUH36jEJUEjr7QST
         t9Au2kln4Gbh2ZYMEygXrwAPEpCgy3yGGJ7bdyfzqvnqhkBoDcDEumo1k59AOaLwlv53
         iMCzuAJdIW/JCPcF6Tnw62S3m2GM3tX83FjZm4v11ED86lsVRL2jmhyJ8Vcjg0Kj5UAe
         qvM04FWraKwOZJnva7iLRbgpHw0xljQxXBGz0/O1JgSL/0nkhjGmpqWaZd2Vil5/j9tR
         2lsQ==
X-Gm-Message-State: APjAAAUt7QnZMWj+AS+7yTgYEw+gx60ynJeOfX+NNaKck5p9SBnOOy++
	Oc2VEtyxSRW2C6DDvj5XU5269PAB0qoo5PSBTrwlvZ186mH7bb28KTQSa24yttcRzNUScfDuSD3
	GaoI3yYkeE3BsqUPy2KB8F/vPiHDjwLxnECgc4ixGWBOv6oEkHCQaj/evdLvMeCacpw==
X-Received: by 2002:a2e:7f13:: with SMTP id a19mr19572942ljd.35.1557909684560;
        Wed, 15 May 2019 01:41:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5RQt8XzHJldgerEhqKGBPr7MVyaexmrIQPq87mcm5M6O4EEl2wihM84+Kn9wkDqrDkm+j
X-Received: by 2002:a2e:7f13:: with SMTP id a19mr19572866ljd.35.1557909682676;
        Wed, 15 May 2019 01:41:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557909682; cv=none;
        d=google.com; s=arc-20160816;
        b=ojakKdS5ORJpReWxTiBmVtiq7YLdvIuvaSAPseHlV5MFkobHg4XWAdmht3AO/MHFCF
         6/O9HPAec+E/hrmfPVzNxikPTc3R9kxExz0IAJnljj/jC8QZwgy5SutaL8sZJvYs2Mgg
         7FYxyMJbTbI0H1i0GEPQhje/MKdZuSAAg/a390lGBFwZno/5l8B1sowi6avyv4UkuVUt
         7K2KGdw5Vl9PvuURZC2PND6thKTZfKHgSy7cgGQM5BlWohfKWiZ77RfcavE5ora8WhyF
         4OmC2lpqQezrWzimnTnpTEKiNKglAPZ7K27aCPzJ5+zkmUnZhN6Ay6bsjtvtyN8ufoNJ
         RjCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=DXKTyv1Zt0cbjxS03oPn1lBJLs878fkqtHSHT6TGUvY=;
        b=r2L+cgnsx21jefXbc0Q/MszzoWV3TqI8Nh9A0KMIHEtppM16Ke9+0R6dsTdRRj2k5m
         e1wcxWIdj6jqMLUVMdu21jnxyaMwiJrlLYlqSnj7LSghaSPRCD93wgqaGwXWxkvFKrlB
         x+nU9+2aO6qjYD7sozObEFTJN4E1ILx6OZxoOJHaI0TZdyHL9vytE0N9u/J3isouf7Li
         NNl1GxKaCK6TUSIm2P+riS7uFbkJfo0sUjl7d1u8EtWjTvT8AZ5BPwj0Cg64HEph8aKn
         tByni6UIyvBOqcyUKBsBxCvNk4S26G02mMvu0SGipeeio31BZknvVMsRbJfhVZIoEK7S
         I6xw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=aNjr5SR1;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1472:2741:0:8b6:217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1p.mail.yandex.net (forwardcorp1p.mail.yandex.net. [2a02:6b8:0:1472:2741:0:8b6:217])
        by mx.google.com with ESMTP id h25si940565ljk.170.2019.05.15.01.41.22
        for <linux-mm@kvack.org>;
        Wed, 15 May 2019 01:41:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1472:2741:0:8b6:217 as permitted sender) client-ip=2a02:6b8:0:1472:2741:0:8b6:217;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=aNjr5SR1;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1472:2741:0:8b6:217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp2j.mail.yandex.net (mxbackcorp2j.mail.yandex.net [IPv6:2a02:6b8:0:1619::119])
	by forwardcorp1p.mail.yandex.net (Yandex) with ESMTP id 658F52E146D;
	Wed, 15 May 2019 11:41:22 +0300 (MSK)
Received: from smtpcorp1o.mail.yandex.net (smtpcorp1o.mail.yandex.net [2a02:6b8:0:1a2d::30])
	by mxbackcorp2j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id 9zoT92Owie-fL0uKV6u;
	Wed, 15 May 2019 11:41:22 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1557909682; bh=DXKTyv1Zt0cbjxS03oPn1lBJLs878fkqtHSHT6TGUvY=;
	h=In-Reply-To:Message-ID:References:Date:To:From:Subject:Cc;
	b=aNjr5SR1VzkHw+xEMkDZjfNamwaILWaRolaTmyWU5+xXDFs9RbvV8LmC1+fXO4YCP
	 dm2PkDwHYBgEKcdaXOl1syN8qZ/el2BXO6s9Bno/cJUjP8agzdxS8NqjpxZqkvdF5P
	 GFMlg9fUgmB31B3VVcLdRfMkfsf1X2zY9luH43kk=
Authentication-Results: mxbackcorp2j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:ed19:3833:7ce1:2324])
	by smtpcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id wNdlQeZj5Y-fLl0uD8T;
	Wed, 15 May 2019 11:41:21 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH 4/5] proc: use down_read_killable for /proc/pid/clear_refs
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 linux-kernel@vger.kernel.org
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, Kirill Tkhai <ktkhai@virtuozzo.com>,
 Al Viro <viro@zeniv.linux.org.uk>
Date: Wed, 15 May 2019 11:41:21 +0300
Message-ID: <155790968147.1319.10247444846354273332.stgit@buzz>
In-Reply-To: <155790967258.1319.11531787078240675602.stgit@buzz>
References: <155790967258.1319.11531787078240675602.stgit@buzz>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Replace the only unkillable mmap_sem lock in clear_refs_write.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 fs/proc/task_mmu.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 78bed6adc62d..7f84d1477b5b 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1140,7 +1140,10 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 			goto out_mm;
 		}
 
-		down_read(&mm->mmap_sem);
+		if (down_read_killable(&mm->mmap_sem)) {
+			count = -EINTR;
+			goto out_mm;
+		}
 		tlb_gather_mmu(&tlb, mm, 0, -1);
 		if (type == CLEAR_REFS_SOFT_DIRTY) {
 			for (vma = mm->mmap; vma; vma = vma->vm_next) {

