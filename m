Return-Path: <SRS0=K2XS=UI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74406C2BCA1
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 10:09:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E8EC214DA
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 10:09:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="HEBN1BfE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E8EC214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6917F6B000C; Sun,  9 Jun 2019 06:08:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 643306B000D; Sun,  9 Jun 2019 06:08:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4BCD36B0010; Sun,  9 Jun 2019 06:08:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id D45226B000C
	for <linux-mm@kvack.org>; Sun,  9 Jun 2019 06:08:58 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id e143so1324013lfd.9
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 03:08:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=3rk+4uRwl46CAyP7ka3QhboNqPwEZHBXTQqkcXWKDZU=;
        b=crnvJNtABozoIgAIZ6neJ1P7kWVFL4ixX8r9stRv5bkJEX5NZ+Qu7nhgoEV5sX3/IW
         tuZDbYxzEkywqg0Nz08jvDH52t4PFAGDJod4dGXIPqkZc9lsv++zc3x/olTMfn+iO800
         EqBAS4yIawJ/xPfzuevklA+fw0otoOyaGgI/AYIXpl3KFvkpBB90f4WHyg+VRYELRsZO
         qOv+UlfvbHJAC/+LQ2v1LrderZls3z1zuufjhj7od1Rtym+lAI5x9kvikMZnP0c6qmob
         s7MlfE+Dq78rZ4WlI92neV9YmljT9hxhi8JwoNE2bzVbHblRrOA6NvBsCP5xiF9Er5pU
         YCVw==
X-Gm-Message-State: APjAAAWaPPuO5P+F+gI80Fhp52/zx8gNeaN3AS590ahn6mHKpb09wyaU
	mnIe7JfONyfGXSQ0kBqFdM+1KySMOs5C1XbpmIEGt4HkVc23MrPpeZRUNTpt4LgGnL7ONuX7Aqo
	PyRtXdb4uChY0x4zv9quggmT+JWry8HfOEDAo7ktg6n+FTa1i49sgnVDWtsjsu/ioVg==
X-Received: by 2002:ac2:546a:: with SMTP id e10mr31932564lfn.75.1560074938261;
        Sun, 09 Jun 2019 03:08:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqySnvdJD47onbR35uHKXAsdpD/7G7aebCow9GGY9v5KAVIInX7LtgxMAh4JzvdwrGMeGxkP
X-Received: by 2002:ac2:546a:: with SMTP id e10mr31932545lfn.75.1560074937487;
        Sun, 09 Jun 2019 03:08:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560074937; cv=none;
        d=google.com; s=arc-20160816;
        b=eTNnJKYsbnkTTc8w5nGdtMkhwxVOb1kIWQ5Lvv9vcgtZFFsa7+j0yz3sJwkQ6ol9dv
         gF6REnulglKXZDFB5cOFzQH7rlanVr+a/Uj29LzTBH3H8O99tgNNeY3IGyds9AvRHyNG
         IXnpuWMxB7ZBwpYfqb77lysD6AJpOQCejBkooO70xTvJYLj8jE+LJcZCIjZlNPGXFjJm
         pw2rQ0rArf3IxpQIQImKTgCLyU/A/Sb1+pq7Bu6mPtWY8ySIqJbqTJI64XHqjTKS9Pac
         7HDMloeqUslo9y4GA3Lnw45fpdFyEjlPm0hJfaNrudH/qNUVLnyYbFjEe675oWyXguwm
         GPyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=3rk+4uRwl46CAyP7ka3QhboNqPwEZHBXTQqkcXWKDZU=;
        b=kaqRcqnQd1cq2taVoet16DdaSO5egegWLTD1yLjTPdmaxPwR8/XW4Wb9FdxoWtyVhX
         e4tgWMLWpxoDMd0OuwDHr5+/4TFbt4yRJ1pJdqnO+FYQCNR/aBXRfIvUZeQcInxm+fY9
         GW9U4Wf0D0E6VE9+nDD3XtOoOFYlqFBrXkY2qvfE6xRFDMvsYr5o5yFFkxBSWSNWvX1z
         5PNfLDfx5qB9kmwxGv5O+J6H97dDgdCT4EZHZJXFSHIEdNXJ+P/X4Ys536IDmXPl0eYd
         jGTkAQihG8J2eYSXXcJGbDK6+kc/DHig56L1h+atPTEz6xAQArk5r1F2l+VduOzP0bw1
         lYTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=HEBN1BfE;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 5.45.199.163 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1j.mail.yandex.net (forwardcorp1j.mail.yandex.net. [5.45.199.163])
        by mx.google.com with ESMTPS id c6si5740128lfk.24.2019.06.09.03.08.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Jun 2019 03:08:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 5.45.199.163 as permitted sender) client-ip=5.45.199.163;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=HEBN1BfE;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 5.45.199.163 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp2j.mail.yandex.net (mxbackcorp2j.mail.yandex.net [IPv6:2a02:6b8:0:1619::119])
	by forwardcorp1j.mail.yandex.net (Yandex) with ESMTP id 265F52E097B;
	Sun,  9 Jun 2019 13:08:57 +0300 (MSK)
Received: from smtpcorp1o.mail.yandex.net (smtpcorp1o.mail.yandex.net [2a02:6b8:0:1a2d::30])
	by mxbackcorp2j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id pNBtwZTYyg-8udqp0pt;
	Sun, 09 Jun 2019 13:08:57 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1560074937; bh=3rk+4uRwl46CAyP7ka3QhboNqPwEZHBXTQqkcXWKDZU=;
	h=In-Reply-To:Message-ID:References:Date:To:From:Subject:Cc;
	b=HEBN1BfECtA+NWOl1NyhYjybz8lV9L5DriON81fOTee7qLzo9B1x324RjmVk79R1d
	 EPwmvCOgjHYCRKWT83RsO0l/Q9io6+Tangbs3bDwNXlFGnRXGUalmBWJ7ENrOSa5Rs
	 E5y5f08BToJC0UDl/kAKm5SjyMhHRX/j+Ms+1QrE=
Authentication-Results: mxbackcorp2j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:3d25:9e27:4f75:a150])
	by smtpcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id Qx30l6oFjQ-8uYGIqxH;
	Sun, 09 Jun 2019 13:08:56 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH v2 3/6] proc: use down_read_killable mmap_sem for
 /proc/pid/pagemap
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 linux-kernel@vger.kernel.org
Cc: Oleg Nesterov <oleg@redhat.com>, Matthew Wilcox <willy@infradead.org>,
 Michal Hocko <mhocko@kernel.org>, Cyrill Gorcunov <gorcunov@gmail.com>,
 Kirill Tkhai <ktkhai@virtuozzo.com>,
 Michal =?utf-8?q?Koutn=C3=BD?= <mkoutny@suse.com>,
 Al Viro <viro@zeniv.linux.org.uk>, Roman Gushchin <guro@fb.com>
Date: Sun, 09 Jun 2019 13:08:56 +0300
Message-ID: <156007493638.3335.4872164955523928492.stgit@buzz>
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
 fs/proc/task_mmu.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 781879a91e3b..78bed6adc62d 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1547,7 +1547,9 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
 		/* overflow ? */
 		if (end < start_vaddr || end > end_vaddr)
 			end = end_vaddr;
-		down_read(&mm->mmap_sem);
+		ret = down_read_killable(&mm->mmap_sem);
+		if (ret)
+			goto out_free;
 		ret = walk_page_range(start_vaddr, end, &pagemap_walk);
 		up_read(&mm->mmap_sem);
 		start_vaddr = end;

