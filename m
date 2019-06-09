Return-Path: <SRS0=K2XS=UI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D301C28EBD
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 10:08:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D599F212F5
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 10:08:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="pqKvjzXt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D599F212F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2752D6B0008; Sun,  9 Jun 2019 06:08:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 13A976B000A; Sun,  9 Jun 2019 06:08:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ECC5E6B000C; Sun,  9 Jun 2019 06:08:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 810A56B0008
	for <linux-mm@kvack.org>; Sun,  9 Jun 2019 06:08:57 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id j27so1323663lfh.4
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 03:08:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=Osy1W1UXrB10pyCypodBWxUh9CNrVdsLdAgKLqVDe8Q=;
        b=Hi+KhBtp9Op9qEa5ZGVcOfpCQ/E3IjWE3L18k1v+z/XcGfIoiJuEYkDyb2vhCqqclt
         rCmOWSq4SS+Uzh4OWcDZNnPnP/J5qCs3q0LqBMyoQF3oVZv1OEJBIVd3aWuyUQ+tmZ4m
         gcXA5qbjMn81IMraV3/6d/2dBZQutbrl2cSAq1rem6Tj+mH6CwcZUMci/eVB5P1nR++N
         NkwESjiasn2w/Vw7JG0D7HYfOLJBx+OJ/EWLTIvQaz8D49P0K8dGHkNFYNlHSrxbtNQQ
         x09GdBHgS6YcqLWyrIfDqo29M8D4U9SVzjUqB0TTp4AbME0G3QBjqhi+m62u1jyHDzU9
         uPgQ==
X-Gm-Message-State: APjAAAV2xXQQV6WIKwHhF2f5y6QgrMKFtJLONLw742MyGUfFR4SdVPpK
	WbQdfRDmEyr1FcbGBhkRTc1cULHFcY8Ngrl9/FXB7rHgVijKQTiRwr5VEIv4CKODt4VLer3EBoI
	FGdsPNXG9m09Plzu0oa9WYy1lMkDwU+oRBMwg+ZOkrBSNfjwu9fiSROB15cs5r2pbzQ==
X-Received: by 2002:a2e:9919:: with SMTP id v25mr28605877lji.191.1560074936996;
        Sun, 09 Jun 2019 03:08:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqziODp980qQ/E2n4CXxCuhUmLtdKRKFx/fG4Ivx32z1nIPnQft1rdcWcgOc0HSmh7pAv/Ps
X-Received: by 2002:a2e:9919:: with SMTP id v25mr28605851lji.191.1560074936236;
        Sun, 09 Jun 2019 03:08:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560074936; cv=none;
        d=google.com; s=arc-20160816;
        b=rFhs9Msw4B/nVF21kJW2vCCdLoBEqzRcJahLnq+Y5cnRrj1ET+A20febwFZCMCNlHj
         DIAn+FjuuhPOcwzRkekYsYIuNIl8Gic9ldiJq7+d/deBQ8GxRpTSNILI300abXq+X1JP
         Xq/jrG3YsFDSYWa8MMSN2qYdqYI8fojM1j2SX9yv39HRf8YfufVr9YJ3ojuntB9XuScB
         yWpaxG+qpez0QGVrxQsj1YVz9G69zmhvWhd4uHp4w1R9H1HHbT6WjsGh458VXUd6k/1q
         sT4jBL7i2rtf1FzT8+hbU6pYukO1Jil1MK2oK7JCCQe5PIauZjzMVlk0LXESZWkChMI3
         /Jtw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=Osy1W1UXrB10pyCypodBWxUh9CNrVdsLdAgKLqVDe8Q=;
        b=YMVpouS2QzGLN1aFuQogO3NHoD1cB0bzl1iKSIijOh3aB/a5IfYHwidNMI5Z9FieMb
         Tmm10XzxGssfJsUhH+6QeFSkz+wkJfheHaUKqgx0ETY+/4Oi7lrH49MUrCsT+8mtlq6i
         5Fs9AViQk1zyZu+m3pfvJ1/ilj9Uam8Rr+4h3J1JDiQHrQve177vet+sCgrFxttHp+UI
         llkWC14wlEb/yCy1QXOZ0Euig/UK0KhaH31vtLOvYsBMz67mjjtzq+1uaiRglQ6TvBGn
         7lnXlkJ0jlWM37PFjrL45ImJF7TGlYQtvPRYEiAVgD2wa+zmw8MTXV+Vdut/COnUOgqK
         idzw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=pqKvjzXt;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 5.45.199.163 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1j.mail.yandex.net (forwardcorp1j.mail.yandex.net. [5.45.199.163])
        by mx.google.com with ESMTPS id t68si6625317lff.66.2019.06.09.03.08.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Jun 2019 03:08:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 5.45.199.163 as permitted sender) client-ip=5.45.199.163;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=pqKvjzXt;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 5.45.199.163 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1o.mail.yandex.net (mxbackcorp1o.mail.yandex.net [IPv6:2a02:6b8:0:1a2d::301])
	by forwardcorp1j.mail.yandex.net (Yandex) with ESMTP id 461142E0AC3;
	Sun,  9 Jun 2019 13:08:55 +0300 (MSK)
Received: from smtpcorp1p.mail.yandex.net (smtpcorp1p.mail.yandex.net [2a02:6b8:0:1472:2741:0:8b6:10])
	by mxbackcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTP id ZSzqn1Ame6-8so4F2el;
	Sun, 09 Jun 2019 13:08:55 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1560074935; bh=Osy1W1UXrB10pyCypodBWxUh9CNrVdsLdAgKLqVDe8Q=;
	h=In-Reply-To:Message-ID:References:Date:To:From:Subject:Cc;
	b=pqKvjzXtUBzAVSiDKLbZCOSS0t9ehWEZtZgDrRcDhRw3G6lZWgub6Zjydb5S4yDbp
	 Y87xvNUR9I4izI0As/UKXeINdYRzMYShRSbiWoSq5onG4qSdj8aplmkyAH+PrEzyrS
	 Bldyua8BJ063+uyN4eyxD7D8yN7XWfiVpmf6hmEg=
Authentication-Results: mxbackcorp1o.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:3d25:9e27:4f75:a150])
	by smtpcorp1p.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id eNXLUmhNGx-8sga6Q9F;
	Sun, 09 Jun 2019 13:08:54 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH v2 2/6] proc: use down_read_killable mmap_sem for
 /proc/pid/smaps_rollup
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 linux-kernel@vger.kernel.org
Cc: Oleg Nesterov <oleg@redhat.com>, Matthew Wilcox <willy@infradead.org>,
 Michal Hocko <mhocko@kernel.org>, Cyrill Gorcunov <gorcunov@gmail.com>,
 Kirill Tkhai <ktkhai@virtuozzo.com>,
 Michal =?utf-8?q?Koutn=C3=BD?= <mkoutny@suse.com>,
 Al Viro <viro@zeniv.linux.org.uk>, Roman Gushchin <guro@fb.com>
Date: Sun, 09 Jun 2019 13:08:54 +0300
Message-ID: <156007493429.3335.14666825072272692455.stgit@buzz>
In-Reply-To: <156007465229.3335.10259979070641486905.stgit@buzz>
References: <156007465229.3335.10259979070641486905.stgit@buzz>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Do not stuck forever if something wrong.
Killable lock allows to cleanup stuck tasks and simplifies investigation.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Reviewed-by: Roman Gushchin <guro@fb.com>
Reviewed-by: Cyrill Gorcunov <gorcunov@gmail.com>
Reviewed-by: Kirill Tkhai <ktkhai@virtuozzo.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 fs/proc/task_mmu.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 2bf210229daf..781879a91e3b 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -832,7 +832,10 @@ static int show_smaps_rollup(struct seq_file *m, void *v)
 
 	memset(&mss, 0, sizeof(mss));
 
-	down_read(&mm->mmap_sem);
+	ret = down_read_killable(&mm->mmap_sem);
+	if (ret)
+		goto out_put_mm;
+
 	hold_task_mempolicy(priv);
 
 	for (vma = priv->mm->mmap; vma; vma = vma->vm_next) {
@@ -849,8 +852,9 @@ static int show_smaps_rollup(struct seq_file *m, void *v)
 
 	release_task_mempolicy(priv);
 	up_read(&mm->mmap_sem);
-	mmput(mm);
 
+out_put_mm:
+	mmput(mm);
 out_put_task:
 	put_task_struct(priv->task);
 	priv->task = NULL;

