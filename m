Return-Path: <SRS0=K2XS=UI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF43DC28EBD
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 10:09:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7018620693
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 10:09:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="W2Lns3hn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7018620693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 531016B0266; Sun,  9 Jun 2019 06:09:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E3506B0269; Sun,  9 Jun 2019 06:09:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 382DC6B026A; Sun,  9 Jun 2019 06:09:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id C80306B0266
	for <linux-mm@kvack.org>; Sun,  9 Jun 2019 06:09:02 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id p3so351297ljp.8
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 03:09:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=HTswKNZVinWlaXTKPwYUewNcuthjMB5ThiabC8k2HqI=;
        b=bSeyOSFBGnXJ40hzkCvFcpWYZ0ZnG9YPVxz1lSjs39Cg2GSKV4tHwg8J9bzovKcVn7
         ePwQegCQIYHYE0MH494fJZmXpIPgwsAMdOcWunLcK2w9bDXG2FfZtEi9Jh+YjEJazRPv
         qv5VfsM1YbNK8D+0IBpa3i6px18O6RD9PyN2ioc9XUSZNqUFFHzkySYurjnhuUotXP08
         IRcsV4DekNqKvD3pyBt1QKZRJ2lXNjNGqK8tMOV44gxsgqD27hrcqvnNi4dfgzfXd6VO
         RKJsSgZS1Wcc1RAHNUdnrDfJEoN731B1q0Pxb8niqLcpLa8pfb6KN4qcsBWUB+4TvlXK
         zZ6g==
X-Gm-Message-State: APjAAAW7+eDoRipTMo+pdkkDQ/fIAWYYutltKSAEF/pkhLOwedSRzEl1
	/Hlpa3/MlyofKf4ADCzzwc670+YJ74tabW0DxMh/PBkaB4cHtSMegOElr9TQqWcF1ToIuV5YXdL
	m7HC9QTuSgOrvpPePl9Mdx1kEwohTUFQIxT0ckBtiZi15RhoRoc8e9HpDlhsLAG0pDQ==
X-Received: by 2002:a2e:301a:: with SMTP id w26mr23037911ljw.76.1560074942200;
        Sun, 09 Jun 2019 03:09:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy8BnsF0d7PQOAEaKcPKKFYCm6ZrBlYvlVBeMEbyi+XGGeZh2mWvz8oq9q9Jp//SZh0pYAD
X-Received: by 2002:a2e:301a:: with SMTP id w26mr23037881ljw.76.1560074941341;
        Sun, 09 Jun 2019 03:09:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560074941; cv=none;
        d=google.com; s=arc-20160816;
        b=gl4QXLLTu5Hq7JkH3bb7SMXH/TGemaoMJbKKh0sU9zLYJUxYgcu0BKY8ZUkdN/pxOC
         0lPCz949eupYq2QQkWw0Pe32j7d/3cGkC7OJJ9DTtLRccZlGuVsgHw41fzO0o9PEwgvQ
         uFjOnxuMolUlRbpYV+f808JZ7NOyCnYkllqHk3P6ENFVZS+BqyMq+qOhofuwwoz+vh+2
         PFqu5YEdXBl3xq/6YQFExpVNf4onpVPL+LtV94yCDQzILW9KB/rZm/r3cYV/2s1/rD4E
         YZBo9tJ9YbtNuChxI0VU6PVblXhBy0VrPfbl7tSW8jaKnVrtcFp4yx3+//XAKOprHddP
         hM/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=HTswKNZVinWlaXTKPwYUewNcuthjMB5ThiabC8k2HqI=;
        b=doJh5o8XmeRouOImOki4s+YEBdVAc9BCiiw95HF1aG+nwRYfavF3UacYUzIVLXpY7Y
         wyLiFFPtZqqmx08xuVqMOfJbqEuIxMmZ6RGJ+iTfz5dsWPNMNRNW5EUbLfE7J8y9QDn/
         rfW/DlQ58qSpExPO+OBF3mBBRV2Kmhyv5dXHKdYtUoGyc5m2UMnzvP3g051PMI828Oto
         AqrHG8wOG7xDumLJvOYOR76hED9092Zog/Lrk3NZql7gxu3WB0dZOwEoxGB/1QN9Fjk3
         oTAQlvVkjAhML69YgmCW0c2lix1zBUVPorsfkkVgzzyKHSO9ZGzjBnJ5tpGbbxkhKoO/
         x70w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=W2Lns3hn;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1o.mail.yandex.net (forwardcorp1o.mail.yandex.net. [2a02:6b8:0:1a2d::193])
        by mx.google.com with ESMTPS id b24si6982002lji.187.2019.06.09.03.09.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Jun 2019 03:09:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) client-ip=2a02:6b8:0:1a2d::193;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=W2Lns3hn;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp2j.mail.yandex.net (mxbackcorp2j.mail.yandex.net [IPv6:2a02:6b8:0:1619::119])
	by forwardcorp1o.mail.yandex.net (Yandex) with ESMTP id DB53D2E1290;
	Sun,  9 Jun 2019 13:09:00 +0300 (MSK)
Received: from smtpcorp1j.mail.yandex.net (smtpcorp1j.mail.yandex.net [2a02:6b8:0:1619::137])
	by mxbackcorp2j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id HqcI3fm6pO-90dSh3UN;
	Sun, 09 Jun 2019 13:09:00 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1560074940; bh=HTswKNZVinWlaXTKPwYUewNcuthjMB5ThiabC8k2HqI=;
	h=In-Reply-To:Message-ID:References:Date:To:From:Subject:Cc;
	b=W2Lns3hnIOukrTVxWvIo0u6baEU21di7kha/doFaKrXcuN13asxGi1NnamvbmIL6R
	 GG523ZkU7z70oZvqhg6+jHvA2776ywAPGJ7zEEGZCR2c+jbDorSPrGnQHtLbI3fTER
	 zK40ISHd22/ieJqWF7T4KyXDg90PAatMcqztN+vk=
Authentication-Results: mxbackcorp2j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:3d25:9e27:4f75:a150])
	by smtpcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id 1wLN9D4DDw-90emhqeg;
	Sun, 09 Jun 2019 13:09:00 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH v2 5/6] proc: use down_read_killable mmap_sem for
 /proc/pid/map_files
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 linux-kernel@vger.kernel.org
Cc: Oleg Nesterov <oleg@redhat.com>, Matthew Wilcox <willy@infradead.org>,
 Michal Hocko <mhocko@kernel.org>, Cyrill Gorcunov <gorcunov@gmail.com>,
 Kirill Tkhai <ktkhai@virtuozzo.com>,
 Michal =?utf-8?q?Koutn=C3=BD?= <mkoutny@suse.com>,
 Al Viro <viro@zeniv.linux.org.uk>, Roman Gushchin <guro@fb.com>
Date: Sun, 09 Jun 2019 13:09:00 +0300
Message-ID: <156007493995.3335.9595044802115356911.stgit@buzz>
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

It seems ->d_revalidate() could return any error (except ECHILD) to
abort validation and pass error as result of lookup sequence.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Reviewed-by: Roman Gushchin <guro@fb.com>
Reviewed-by: Cyrill Gorcunov <gorcunov@gmail.com>
Reviewed-by: Kirill Tkhai <ktkhai@virtuozzo.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 fs/proc/base.c |   27 +++++++++++++++++++++------
 1 file changed, 21 insertions(+), 6 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 9c8ca6cd3ce4..515ab29c2adf 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1962,9 +1962,12 @@ static int map_files_d_revalidate(struct dentry *dentry, unsigned int flags)
 		goto out;
 
 	if (!dname_to_vma_addr(dentry, &vm_start, &vm_end)) {
-		down_read(&mm->mmap_sem);
-		exact_vma_exists = !!find_exact_vma(mm, vm_start, vm_end);
-		up_read(&mm->mmap_sem);
+		status = down_read_killable(&mm->mmap_sem);
+		if (!status) {
+			exact_vma_exists = !!find_exact_vma(mm, vm_start,
+							    vm_end);
+			up_read(&mm->mmap_sem);
+		}
 	}
 
 	mmput(mm);
@@ -2010,8 +2013,11 @@ static int map_files_get_link(struct dentry *dentry, struct path *path)
 	if (rc)
 		goto out_mmput;
 
+	rc = down_read_killable(&mm->mmap_sem);
+	if (rc)
+		goto out_mmput;
+
 	rc = -ENOENT;
-	down_read(&mm->mmap_sem);
 	vma = find_exact_vma(mm, vm_start, vm_end);
 	if (vma && vma->vm_file) {
 		*path = vma->vm_file->f_path;
@@ -2107,7 +2113,10 @@ static struct dentry *proc_map_files_lookup(struct inode *dir,
 	if (!mm)
 		goto out_put_task;
 
-	down_read(&mm->mmap_sem);
+	result = ERR_PTR(-EINTR);
+	if (down_read_killable(&mm->mmap_sem))
+		goto out_put_mm;
+
 	vma = find_exact_vma(mm, vm_start, vm_end);
 	if (!vma)
 		goto out_no_vma;
@@ -2118,6 +2127,7 @@ static struct dentry *proc_map_files_lookup(struct inode *dir,
 
 out_no_vma:
 	up_read(&mm->mmap_sem);
+out_put_mm:
 	mmput(mm);
 out_put_task:
 	put_task_struct(task);
@@ -2160,7 +2170,12 @@ proc_map_files_readdir(struct file *file, struct dir_context *ctx)
 	mm = get_task_mm(task);
 	if (!mm)
 		goto out_put_task;
-	down_read(&mm->mmap_sem);
+
+	ret = down_read_killable(&mm->mmap_sem);
+	if (ret) {
+		mmput(mm);
+		goto out_put_task;
+	}
 
 	nr_files = 0;
 

