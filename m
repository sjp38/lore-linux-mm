Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0031FC04E84
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 08:41:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A66A72082E
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 08:41:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="oDzJ6O4C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A66A72082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 977666B0269; Wed, 15 May 2019 04:41:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D8666B026A; Wed, 15 May 2019 04:41:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 707036B026B; Wed, 15 May 2019 04:41:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 02DA36B0269
	for <linux-mm@kvack.org>; Wed, 15 May 2019 04:41:26 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id n14so286359ljj.19
        for <linux-mm@kvack.org>; Wed, 15 May 2019 01:41:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=EuTSakk/W384FbrZL7W4VmC2fzsD5CQ2PPKONFosPBE=;
        b=ke2sqOugiqAR2RveYuhVJS+sovOuxOpvzWvQLajLTaZtFKMZNaKkvijjhlYMrWpf5I
         W9reF+OZ3aS9DKW9D5qf58uIXMXIuuoUPeUtDqRtSiCZ7AeTW/8E1K6XX7UTZ1YYZXxy
         Rre4Yt7+K2opnY1wiy3JCbm9uhccDJEert5u3mnLbHcCAywoz3AszzxlNHy2l96owgMJ
         NuO59QKzuqdao4pRQ39S67mEGbB8/4iLafiv+WuVAi9PZSVCrLdte5YR3FVr1jifg3H3
         6rsMTRdwS9c58EAJqgX7+bOIDDXPe5rbZO6rz4QweVPi9W8elZTRoghBCWohEaCgv10C
         2a0Q==
X-Gm-Message-State: APjAAAU2mdA4ckujtjc491D0x+IPBQNsBapl5hH0E4BwxVJZwIw5CKXQ
	P2SQ28WvmAG+WM9AW+eWZgENcu3XvIu4BB6G6qukQA6WWpUYxPCh4sm5lQAfowfnpjluxeSsohU
	hCZlrGWhT3YQWJFLvgmk4p0vXj/kimBVKirvGKzaGsibYreYguiqrADQ/KYFfcdi8nA==
X-Received: by 2002:a2e:5501:: with SMTP id j1mr19181833ljb.58.1557909685439;
        Wed, 15 May 2019 01:41:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwdABT+ga57UnGnytI798wJkRDk2+1BcLRldkCWEcFb/I3goGkB9lk9H6jGJ1avulbK/v/T
X-Received: by 2002:a2e:5501:: with SMTP id j1mr19181787ljb.58.1557909684301;
        Wed, 15 May 2019 01:41:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557909684; cv=none;
        d=google.com; s=arc-20160816;
        b=GFBwnv0dVOBEoxNmw9WccUkPQe/R1QHw50fpAULyuDkxgdo2WcVygBlCps+Wnocd/O
         O/jKxRucKCajMTOEP7L9yo0beE1rMH6nQkuPGMdRN2l7h3z2WYHx+qdTFx7LoNnzX9pO
         HtpKDVHB/coGzNKwJK4h4TF3by+me8md0THtvpHhB/9znR4bA4yZFt/SuFWw1rxxw8PS
         WPnB3Y8ycjzhgK+dgLL09RMO4cER7ndHJZh1kqpJszt0jVNUk45JlgVTnMFejLQY/cTH
         QnRLG07miFBXlmM4sXGAKpV+ORwW+aQEKpENyDaXk08eAbfMv+AJYRTz3bJ+vLAiXmLs
         rcIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=EuTSakk/W384FbrZL7W4VmC2fzsD5CQ2PPKONFosPBE=;
        b=qwNQwUmM36azDYVU0hWf+u3zSn23VAE7RWu34jXXFDtUTUrio1SwlYFe3JEwgUuCJD
         eSd6XkUQTOLiyeu9+xGa2lLgQRBHrsBY6C0agsuqBmT6yaLZSPBP0qxa9Pl11C37MKYD
         d06y/ZbJ1cWjgTj9IIOWQu6l9zP/OCOqmxeoKyIS1QFWsGBvCfOww9vB22hA5Cqoh8Ah
         lTOLuUPrr7OstGBISBXu8oNjbIOiu0A0hQRBrQ0G5FiXLG3eRrwlLhN2DzBb5EuI/aTS
         VVfQQNgOBHm3HnftB7PYpHc0nzlvchFt0pEpNMODE+u/lcD97ASa8am8XKgLMmvJIdef
         7PQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=oDzJ6O4C;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1472:2741:0:8b6:217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1p.mail.yandex.net (forwardcorp1p.mail.yandex.net. [2a02:6b8:0:1472:2741:0:8b6:217])
        by mx.google.com with ESMTP id g2si1052134lja.128.2019.05.15.01.41.24
        for <linux-mm@kvack.org>;
        Wed, 15 May 2019 01:41:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1472:2741:0:8b6:217 as permitted sender) client-ip=2a02:6b8:0:1472:2741:0:8b6:217;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=oDzJ6O4C;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1472:2741:0:8b6:217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1j.mail.yandex.net (mxbackcorp1j.mail.yandex.net [IPv6:2a02:6b8:0:1619::162])
	by forwardcorp1p.mail.yandex.net (Yandex) with ESMTP id 0AE4C2E1474;
	Wed, 15 May 2019 11:41:24 +0300 (MSK)
Received: from smtpcorp1o.mail.yandex.net (smtpcorp1o.mail.yandex.net [2a02:6b8:0:1a2d::30])
	by mxbackcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id EhUVTWkR5e-fNwi2wOO;
	Wed, 15 May 2019 11:41:24 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1557909684; bh=EuTSakk/W384FbrZL7W4VmC2fzsD5CQ2PPKONFosPBE=;
	h=In-Reply-To:Message-ID:References:Date:To:From:Subject:Cc;
	b=oDzJ6O4CIEQs5Ah2zbLrIQXVVTPf+lFiG0PinmnSVMh6ZGcHdOxvsjtOSKXzQl05R
	 WRiJfug3aYbM0VoEz3ChYfL2j4NwD+PRPmdHi4I2w5h0T489aSzr+2jzVFeIZpvTPB
	 WGdE7tWY9YJtH3HEBz2ssD0/jwALsw4gByyBquLM=
Authentication-Results: mxbackcorp1j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:ed19:3833:7ce1:2324])
	by smtpcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id qWdnaWaYI8-fNlaNIYK;
	Wed, 15 May 2019 11:41:23 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH 5/5] proc: use down_read_killable for /proc/pid/map_files
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 linux-kernel@vger.kernel.org
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, Kirill Tkhai <ktkhai@virtuozzo.com>,
 Al Viro <viro@zeniv.linux.org.uk>
Date: Wed, 15 May 2019 11:41:23 +0300
Message-ID: <155790968346.1319.5754627575519802426.stgit@buzz>
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

It seems ->d_revalidate() could return any error (except ECHILD) to
abort validation and pass error as result of lookup sequence.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
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
 

