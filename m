Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABD5CC282CE
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 17:05:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DF6F20850
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 17:05:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="rb6/WYuD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DF6F20850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 918776B026A; Tue,  9 Apr 2019 13:05:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A3256B026B; Tue,  9 Apr 2019 13:05:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 681BE6B026C; Tue,  9 Apr 2019 13:05:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id F22776B026A
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 13:05:46 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id o17so4863711ljd.2
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 10:05:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=6qgQvOSzO1vWe084AgECBQ5jqQlvYy8rSaBhCMRlLSI=;
        b=OLntIxrwGSw+1UO0NVsOVjqFXTAhqcUfityC0npuvuyA7Q0fvXxX6DF9DwAMQg+BgX
         av97/Z+mSMDw76h8vd6bCyQ2Fja2VWw60KJiCDf7M+Xtl96lEQ/JhgGFQILIE7A8eOQa
         6m27lF0tTYcmk4WijFJQWfEH8kwYD3Hq0bAingc3Q2XtJzivWgsS66DFF08FCZYTyEUy
         MDIjtiWlbaZ6ZdBkbj6fXMwFerVQu9fFYH43PrfDR2GfX7Rvq+zehylX+9bJAUo2dLnl
         h+lvOeTyrc3viogBROn9YBGu61XdKbY9NIhTyJwlGyKG4OyJ+LyRdCFW2SlURpRz+CpZ
         H9wQ==
X-Gm-Message-State: APjAAAWVJHZazUTobyUrelYO2XBOhlfdlJCh2wHcvVVG7kjl63A32HDJ
	julpoctEXOv/X9UEfJcL/J9SP5H8ac1XG92BFEjuI2+VFhFkOi8JYeJPnbZG1vuQ/1tH+3RI20h
	29zd1a5T3maay0V1nigyQ/0Q3x6IqJ2VSiISlUs+pXwTCL+v6cpB8qdmNZ5/cSaSZ+Q==
X-Received: by 2002:a2e:88c5:: with SMTP id a5mr3341996ljk.5.1554829546359;
        Tue, 09 Apr 2019 10:05:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzaFdupmSkueMRKSncQRaGwvVZYupMNI/0SpPV3cHlQw49XJQNU29/gU2gW3XWhBqsvPmkt
X-Received: by 2002:a2e:88c5:: with SMTP id a5mr3341932ljk.5.1554829545034;
        Tue, 09 Apr 2019 10:05:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554829545; cv=none;
        d=google.com; s=arc-20160816;
        b=vAu2zni+isnEe+GNiR4Xl7c7Rsa/2Cukk44LKvVY+TYOs7p464SlqNlQSkfAghMm/3
         6HMoDzF29AbI29RkHzAFpgdfLmCb3xpXJFIEx3t5vnKGu9U6oTqrQvajKQX/5b70Pi4T
         FJbcSTo+zDuPa78ppl32dQ0XO5jx+k8uNxCvDCCdjkiN44YH5fomLSTZwmQObwaK0DJT
         KMGGTwKIuCrFdPcvD2c4UgsqhFEVjVOSY7hMJowLT0TLUyJpoj//8t1CQxf7dhJKVYEv
         m5BukgZAj4Qa7F9A4wuGqGtFRw0c6LsC4t/QEWnLl7cAtz5OAdKZEi2J6FQ/bTR5g2cn
         iNcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=6qgQvOSzO1vWe084AgECBQ5jqQlvYy8rSaBhCMRlLSI=;
        b=LeNNoqa9dyelEkBrFT7IagY//KwUJ1Mz0C8WRsSCdAM9uNANoRYApSctSGeVWH9aDQ
         DWhiowk2oGNSrbdzG6PC9vtICDOEzUBSXnPq2P2Zj0O0XukOA2/7V0VD2223KW9IT3Zl
         sc0MfViIB9NaO8Kw8A/ms2gn45Qj2TyzoKYVcO+UV5c6152kqgJi0heDSYcz33iRg2ge
         ewmE4ON9KGtjjS3rkcra66o0iItGMgeAO4QceRDlgSjXF6pErmCBuY5WR6aw95Z4OXkq
         1sTWB7aknOi0Tc+TK2ESUqhI/sseUWib5RPvsLPh6GALNcm/gXBleXezdrJMkj9w2W/c
         XKJg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b="rb6/WYuD";
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1619::183 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1j.mail.yandex.net (forwardcorp1j.mail.yandex.net. [2a02:6b8:0:1619::183])
        by mx.google.com with ESMTP id s82si24912884lja.155.2019.04.09.10.05.44
        for <linux-mm@kvack.org>;
        Tue, 09 Apr 2019 10:05:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1619::183 as permitted sender) client-ip=2a02:6b8:0:1619::183;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b="rb6/WYuD";
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1619::183 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp2j.mail.yandex.net (mxbackcorp2j.mail.yandex.net [IPv6:2a02:6b8:0:1619::119])
	by forwardcorp1j.mail.yandex.net (Yandex) with ESMTP id 595D12E137C;
	Tue,  9 Apr 2019 20:05:44 +0300 (MSK)
Received: from smtpcorp1j.mail.yandex.net (smtpcorp1j.mail.yandex.net [2a02:6b8:0:1619::137])
	by mxbackcorp2j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id vQt4pPhvt0-5heaDZ2R;
	Tue, 09 Apr 2019 20:05:44 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1554829544; bh=6qgQvOSzO1vWe084AgECBQ5jqQlvYy8rSaBhCMRlLSI=;
	h=In-Reply-To:Message-ID:References:Date:To:From:Subject:Cc;
	b=rb6/WYuDxmOafj+ZyTuzPTaed3h/ak5Q8DKaH3rjAlwB8xsZqoWdTZeddsfwqQA0i
	 Xbw69h6RGxMA4WoAQAmfRxnrdF8nOZDjnZdZQk31mUg2hOCNghGO3O5riQvyk7zNLz
	 SITckdLHQa2mrDiDASwnPAHl1I4b74XtUPcHaxCE=
Authentication-Results: mxbackcorp2j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:f5ec:9361:ed45:768f])
	by smtpcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id jakIv8GFPk-5hkCns9R;
	Tue, 09 Apr 2019 20:05:43 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH 4.19.y 2/2] mm: hide incomplete nr_indirectly_reclaimable in
 sysfs
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: stable@vger.kernel.org
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>,
 Vlastimil Babka <vbabka@suse.cz>
Date: Tue, 09 Apr 2019 20:05:43 +0300
Message-ID: <155482954368.2823.12386748649541618609.stgit@buzz>
In-Reply-To: <155482954165.2823.13770062042177591566.stgit@buzz>
References: <155482954165.2823.13770062042177591566.stgit@buzz>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This fixes /sys/devices/system/node/node*/vmstat format:

...
nr_dirtied 6613155
nr_written 5796802
 11089216
...

In upstream branch this fixed by commit b29940c1abd7 ("mm: rename and
change semantics of nr_indirectly_reclaimable_bytes").

Cc: <stable@vger.kernel.org> # 4.19.y
Fixes: 7aaf77272358 ("mm: don't show nr_indirectly_reclaimable in /proc/vmstat")
Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Roman Gushchin <guro@fb.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
---
 drivers/base/node.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 1ac4c36e13bb..c3968e2d0a98 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -197,11 +197,16 @@ static ssize_t node_read_vmstat(struct device *dev,
 			     sum_zone_numa_state(nid, i));
 #endif
 
-	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
+	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++) {
+		/* Skip hidden vmstat items. */
+		if (*vmstat_text[i + NR_VM_ZONE_STAT_ITEMS +
+				 NR_VM_NUMA_STAT_ITEMS] == '\0')
+			continue;
 		n += sprintf(buf+n, "%s %lu\n",
 			     vmstat_text[i + NR_VM_ZONE_STAT_ITEMS +
 			     NR_VM_NUMA_STAT_ITEMS],
 			     node_page_state(pgdat, i));
+	}
 
 	return n;
 }

