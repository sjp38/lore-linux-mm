Return-Path: <SRS0=K2XS=UI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3186C28EBD
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 10:09:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B84FB2146E
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 10:09:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="bl8dIOKj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B84FB2146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AAF246B0010; Sun,  9 Jun 2019 06:09:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A37E36B0266; Sun,  9 Jun 2019 06:09:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 904FF6B0269; Sun,  9 Jun 2019 06:09:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 21C306B0010
	for <linux-mm@kvack.org>; Sun,  9 Jun 2019 06:09:01 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id r1so1314199lfi.22
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 03:09:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=5oPoVSty0sBJvPoO4vjO+ps4MIrwZ8U/WIc8bNJraZs=;
        b=RInnCwYU5r82AyLmK3rkx/AAFW/u1dW9UU7UlZArES5ZS6FLgwfqrRD2Uuo97Hc5lZ
         M7vZ+BshiHZmDwTCSxCORBfoSlpSi/ydD3HOj4dx+UaIA1uccbFgwK/mQtrTcX4wFTgi
         onoWSpd5IWe6888Zfh1QPJ1VXsQAWckjMKW282bP+WAyZgp7rKgGK5hdqEcDhLRItnoK
         XM9AFg9nOFx7dKzPOWOJ7ybXxPs+EGsHr8vK8INGVXTB8r13yKGcHLNsMKs97AnmHP1B
         n8bahjuUCFXLFN7PV/Rm+3GJE2AXN0dQZkCN/T6/9FmCA0YNqPMG3wqktAWsRE/TPNMc
         IucA==
X-Gm-Message-State: APjAAAWckOFY8pU7T4uQAZgGMrPNG9VoLjhB0TQiKgSljYB0iYggtlsP
	aWdHejQEBOylPS1A7cqT34pvjYPqwfGOulPR5TlAsN4YVpRU31LZzZ6WeDar315gyQdmJYkVkCv
	NMtMxdXHIlZNDlgkAuu3DJlS9gJ6rgmBMUaDgQzkdzK6TYGUFGLwa9dThd/6K1g8r4Q==
X-Received: by 2002:a2e:81c4:: with SMTP id s4mr21314327ljg.182.1560074940539;
        Sun, 09 Jun 2019 03:09:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxLWoEiaJV4+hGTQEYGyCGqInPbfCAr8GQIgIgc4WnTahiHN4fUBRdW1+AATPxbr/jhgP/c
X-Received: by 2002:a2e:81c4:: with SMTP id s4mr21314291ljg.182.1560074939626;
        Sun, 09 Jun 2019 03:08:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560074939; cv=none;
        d=google.com; s=arc-20160816;
        b=eYcmJZZwxxGNdVVgf5fqG09Tc4TJoTCwwa9CdJVZvHFUhGxdMt5eb9ZUAbAhOLPD/1
         mLMLKqfTPsTIwYI0qRarViCIF3If4nSPXfA2+u78dV+sDif7qERnvcm1RKujgC5CcpAy
         bwy2nBbvSFK7JpNEx12q/0R0HlJiwbuPEuxkaWOLhPkWCxssUy9T3uucQwxHmWnW18tO
         gLQOwt9JQRzvy+5qDpLsdwruufNNk8+HVpD9gBlDVfD6aV6iJYYQJrLmaH9eVTMz6Lib
         cuvvYZGfi/e8nUbWxMrES/jMgc2QhxugLYWCTo9TYnlSNbO22ooDR5P7sE2nw2O8En60
         FT9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=5oPoVSty0sBJvPoO4vjO+ps4MIrwZ8U/WIc8bNJraZs=;
        b=b9umhttai8WOi6k8jClfjvI/28GQs3njs2pTXc5iY43z4+/n2CUT5vJEd8moAwQcod
         HiY3AYXEZm8w+uNEYVrPHIdCekqkDvGuQcudFxKPzpj5+J0ICGNNX2JJNCmfrjdDvgox
         Cq8bJH3qt2pw0O2aPW+rSTYY9lBGVvt1pzc6eHcQcqp96qXYu6qFEkATbVgz/2qa56D0
         pS3yMMILKr/TTmsZPPo12XaFgBWbr3WKVD4/mrQ1Rt9mjfsAK+gt0qdvCaVifXNQaXE5
         ssSsSq41nl/zcP+L4ERkKQ6AppecAXxDCWEP4hO28RJpeSiwImDa09uo4vL9Lsp2k2y6
         K8jQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=bl8dIOKj;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1o.mail.yandex.net (forwardcorp1o.mail.yandex.net. [2a02:6b8:0:1a2d::193])
        by mx.google.com with ESMTPS id h24si6033050ljk.98.2019.06.09.03.08.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Jun 2019 03:08:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) client-ip=2a02:6b8:0:1a2d::193;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=bl8dIOKj;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1o.mail.yandex.net (mxbackcorp1o.mail.yandex.net [IPv6:2a02:6b8:0:1a2d::301])
	by forwardcorp1o.mail.yandex.net (Yandex) with ESMTP id D53742E097D;
	Sun,  9 Jun 2019 13:08:58 +0300 (MSK)
Received: from smtpcorp1j.mail.yandex.net (smtpcorp1j.mail.yandex.net [2a02:6b8:0:1619::137])
	by mxbackcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTP id aqxL9ERVQN-8wo4pCl9;
	Sun, 09 Jun 2019 13:08:58 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1560074938; bh=5oPoVSty0sBJvPoO4vjO+ps4MIrwZ8U/WIc8bNJraZs=;
	h=In-Reply-To:Message-ID:References:Date:To:From:Subject:Cc;
	b=bl8dIOKjahwvfOSIMeuXLJZ3DGuX1mY6urGZHD7TNwpHIYw/EZtMJRInwuXfRDpaP
	 KaGwlhJdz94/rIAPtPcXo1usMXoEfqZ8CJRTWILKXsK+PMAp4WbdDKBo3NPiGG/Pmv
	 I2Fr92CzQXy5SPCtr6oJDxF+RkbyZMinoo/7lDuo=
Authentication-Results: mxbackcorp1o.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:3d25:9e27:4f75:a150])
	by smtpcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id QIBPtRbp96-8weawET3;
	Sun, 09 Jun 2019 13:08:58 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH v2 4/6] proc: use down_read_killable mmap_sem for
 /proc/pid/clear_refs
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 linux-kernel@vger.kernel.org
Cc: Oleg Nesterov <oleg@redhat.com>, Matthew Wilcox <willy@infradead.org>,
 Michal Hocko <mhocko@kernel.org>, Cyrill Gorcunov <gorcunov@gmail.com>,
 Kirill Tkhai <ktkhai@virtuozzo.com>,
 Michal =?utf-8?q?Koutn=C3=BD?= <mkoutny@suse.com>,
 Al Viro <viro@zeniv.linux.org.uk>, Roman Gushchin <guro@fb.com>
Date: Sun, 09 Jun 2019 13:08:58 +0300
Message-ID: <156007493826.3335.5424884725467456239.stgit@buzz>
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

Replace the only unkillable mmap_sem lock in clear_refs_write.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Reviewed-by: Roman Gushchin <guro@fb.com>
Reviewed-by: Cyrill Gorcunov <gorcunov@gmail.com>
Reviewed-by: Kirill Tkhai <ktkhai@virtuozzo.com>
Acked-by: Michal Hocko <mhocko@suse.com>
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

