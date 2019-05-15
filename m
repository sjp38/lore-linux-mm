Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DFE2C04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 08:21:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E314620862
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 08:21:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="fHGe8418"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E314620862
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7FB536B0005; Wed, 15 May 2019 04:21:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7AC0F6B0006; Wed, 15 May 2019 04:21:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E9EC6B0007; Wed, 15 May 2019 04:21:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0BCA16B0005
	for <linux-mm@kvack.org>; Wed, 15 May 2019 04:21:22 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id m2so282654ljj.13
        for <linux-mm@kvack.org>; Wed, 15 May 2019 01:21:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=rH/t30KXMBGr4dF0FJuUrEPHJpTL3NQhSuLj3xwva+0=;
        b=Oov+C4+0S2m8DXmq87u4K2Vy/vX8G/vSy7iiskiR1x0a3TZbrIidAiiVvGig1BCRMH
         HkY/xvNe2Ga7wH3Vk2EGqQGVDqWl7kYnziIAPBDrgjdSRrKJE4k4b3BTo5Sy/MEVwnLv
         770rzO2aZq6o+ySFR7jtD2kBm7tzlEKSaDLFwKefr8G7Juq3hUs2PYuBGLtLylsJSF1N
         S8/ybA2Ld24C570zl+dV0+/h2DB+/6xw2RSFDmJPl2/7Y3FjrVqZKKlRG2rsFbR2Wdio
         GVrDPz3b0jyPlOmF03rAnywQwB8yvuUbKck8rx9yN8xN33H9ihZD/oenlxdcjZNoLeD0
         KmzA==
X-Gm-Message-State: APjAAAUJhxe8NeDbMr6ThO15LR24+2DdKoTAtn9ciFEYbHkNbeDgDlJ3
	7ZDn5OC/tLFg6NJeO11I3jHRA+5MHVYDvcBd7TTdX/enZsOqOXEIdbXgjO+MsjV9TurzMYpsk3f
	Mgnj0dvYrVOoSBcXRRJJ5AS281okfVkDvJLjRUC7pGXOAUvFOTxlIXBl/uxhuAaQTeQ==
X-Received: by 2002:a2e:568d:: with SMTP id k13mr19127016lje.194.1557908481148;
        Wed, 15 May 2019 01:21:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz14bp+ySn+TmfvPSF4v4EKF5bGKzF5O+uXT5uh/MuuxiWxR+WJQw9/0njCZEZluquDy6er
X-Received: by 2002:a2e:568d:: with SMTP id k13mr19126972lje.194.1557908480306;
        Wed, 15 May 2019 01:21:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557908480; cv=none;
        d=google.com; s=arc-20160816;
        b=nN+EQ1ja/Z0yPPDqjseezE6fHNAdQROe2KG74BKQgp+Mj0JklQYb9KOowDkz4Sgbgw
         KyoBVDsTy48H1FIKryegqHUik/HAIczxumDXOra7USzSFDxy8kj3YSdZvgi+jGAeDtdw
         xtGJhJBBpq4P5yutDR1qvZhtoDehSu6i5ldzfXOIBCBzx5ghtbDezQIWMyZ0kL7MLnmc
         T0GSh0mvW64EsoBdMIPZxIttyq63YFnEXtQRCKp7w/EwZTG6TZ5qQC16M/OREkCsEAyV
         uZsF6dnMg7Yh84if1TpMYmIxcbzJsC3BBROo97U4TSwSGzEdzzA6D+q5w3G9DQRw47NV
         VrXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :to:from:subject:dkim-signature;
        bh=rH/t30KXMBGr4dF0FJuUrEPHJpTL3NQhSuLj3xwva+0=;
        b=aINiMQNhxa216eg+Aou4SO8TGHWVJs7rsYqwFVXzIPg/BVu1cAxELbUIahMx+9orxE
         EfuLm9zE54xag8TFqIarf6fLmtnnR/fkJaNjf7DMmpjAUntKYTSxOROjFazBlzp2SdJL
         AAXEO/08cooHoqb5gUVpCcYiCs0rI2p2PoQAStIofMMpcKJIDs2HtoVNQtPpxU5t5Frp
         6svF/hRGLjQUIKVpR1pwAPAXfe7I8ERmR4llTko/byVppwSudnZSwhYMYbw11C2qV4aN
         oQW1Znn0wce8iW0FR7VNfhe1HgSLmDLC116FFvFqGyJBKTjnM3cLHHJeX9H2BgSHL0ek
         TDgg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=fHGe8418;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 95.108.205.193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1o.mail.yandex.net (forwardcorp1o.mail.yandex.net. [95.108.205.193])
        by mx.google.com with ESMTP id p70si1033879ljp.7.2019.05.15.01.21.20
        for <linux-mm@kvack.org>;
        Wed, 15 May 2019 01:21:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 95.108.205.193 as permitted sender) client-ip=95.108.205.193;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=fHGe8418;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 95.108.205.193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1o.mail.yandex.net (mxbackcorp1o.mail.yandex.net [IPv6:2a02:6b8:0:1a2d::301])
	by forwardcorp1o.mail.yandex.net (Yandex) with ESMTP id A784B2E147B;
	Wed, 15 May 2019 11:21:19 +0300 (MSK)
Received: from smtpcorp1p.mail.yandex.net (smtpcorp1p.mail.yandex.net [2a02:6b8:0:1472:2741:0:8b6:10])
	by mxbackcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTP id DwA5FsojOl-LJ0GRkIN;
	Wed, 15 May 2019 11:21:19 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1557908479; bh=rH/t30KXMBGr4dF0FJuUrEPHJpTL3NQhSuLj3xwva+0=;
	h=Message-ID:Date:To:From:Subject;
	b=fHGe8418tN46yDfQFsQ6wSmHFaUCKDn9hk25OB75c5F8CZaDVuzJE3eqbZhBq6oTD
	 KIU4i3rNGp8X6ahgcORt5JIudN3gzYuTn/Q8xJy2ex/jLMfmHd5kABXrLZg/WNLYXo
	 n7e5PNwGicPSEkyRzqIMK5WMjAeFBYiNWrHhO/lE=
Authentication-Results: mxbackcorp1o.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:ed19:3833:7ce1:2324])
	by smtpcorp1p.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id fxC6AkQBIj-LJd0oVGu;
	Wed, 15 May 2019 11:21:19 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH] mm: use down_read_killable for locking mmap_sem in
 access_remote_vm
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>
Date: Wed, 15 May 2019 11:21:18 +0300
Message-ID: <155790847881.2798.7160461383704600177.stgit@buzz>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This function is used by ptrace and proc files like /proc/pid/cmdline and
/proc/pid/environ. Return 0 (bytes read) if current task is killed.

Mmap_sem could be locked for a long time or forever if something wrong.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 mm/memory.c |    4 +++-
 mm/nommu.c  |    3 ++-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 96f1d473c89a..2e6846d09023 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4348,7 +4348,9 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
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
index b492fd1fcf9f..cad8fb34088f 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1791,7 +1791,8 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 	struct vm_area_struct *vma;
 	int write = gup_flags & FOLL_WRITE;
 
-	down_read(&mm->mmap_sem);
+	if (down_read_killable(&mm->mmap_sem))
+		return 0;
 
 	/* the access must start within one of the target process's mappings */
 	vma = find_vma(mm, addr);

