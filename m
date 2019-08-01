Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01D64C41514
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 15:24:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B255C217D4
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 15:24:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="JNZ/KgcY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B255C217D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 264078E0026; Thu,  1 Aug 2019 11:24:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FA628E0001; Thu,  1 Aug 2019 11:24:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 01A8C8E0026; Thu,  1 Aug 2019 11:24:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id C960F8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 11:24:48 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id d26so65065466qte.19
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 08:24:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=R6/SxEPTIzTdE6W1Hx7mOa8dC1CKLzuuI3rK/m6KyjA=;
        b=p/L3E3cMHYiALdavo14xpPHwX199NKQ9mM33RiogiLYGQoEZIVlO4FvWnQCF6Y394X
         dr1qGh3pGnXwRRqhoIa7dgtzOzd+GrnfcSops5pxzFfYyyAnaz2GWHQrtFSccM7U9l1z
         x3Midk7KNCrbtC2Jm9Qz+ayeUSWy3H9V3hzVghKiiLI51LN4utTFWf5bU38FrOjbBzEa
         eTEEYKmdZD81O8cKIBHbrmyXSzn4X+x9417++njeRQwgHBgl8g9gpCWPt9sSrOxkStkS
         oMxM1RF3QWniMb3tA+JZ8f7CjrwEOpys59wR9h/Z12xlH8FQAY7iexdBgbVr8e4Ec4ML
         /xdw==
X-Gm-Message-State: APjAAAVmbaTI6FMFLr5G/PbyMgM4dDG9TcRaVkUdAgEpDZPs6TcFJEaV
	cxkneiyoY2RlbzYN/AaGbBstdRF2bYzMGwtTtzKL0y0mUT7mVr4UOR4XQWTOLGSE7r9z821MSO3
	5gOyO8vs6AQgRRhZWV46N1OV38fJPC113nhvoKTZNYaoi0d9urVsTtKWuhXrUH++kWg==
X-Received: by 2002:a37:4b58:: with SMTP id y85mr87300545qka.8.1564673088582;
        Thu, 01 Aug 2019 08:24:48 -0700 (PDT)
X-Received: by 2002:a37:4b58:: with SMTP id y85mr87300474qka.8.1564673087630;
        Thu, 01 Aug 2019 08:24:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564673087; cv=none;
        d=google.com; s=arc-20160816;
        b=LdZzMehQd4g9v0n1pkHTBSjDo3qvLFUmX6GWjj7A00zpvR/JhLejJY9hlRff9FMme3
         1Cdb8qOuuHQ5HFjT4BUYSZmuC4FPZW4QemLHYAGL86c4a3T9AxGmHJGIdif2p3RIEZoI
         urGfgV0cRRX11KH8JPI5vGEpe/eAbFKHJyHhpzG1oiohnoWOChDCCKX9rsERa9vJxYg8
         Ce+FodxcD8tlrWH8h2U3Zka2YK/xWJadV+kpcO/6ZDHSg3a6SGRLyUoAVrZMzmlteDMw
         fIriNOKXig5/zwjRiBBW32OfI9nOveP2fQsahSPpzXcjciyC1EvV6X3WXMXKS1UU+kPm
         kDgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:dkim-signature;
        bh=R6/SxEPTIzTdE6W1Hx7mOa8dC1CKLzuuI3rK/m6KyjA=;
        b=uhB/s+zKkuD3A3oZslBmI6WEJv54WoaCyToUTT6dzjGTmra3m8MunJwxjEFIh2QgUA
         gjWBCdKHXeNLXKGIuZlrBrJxbhRx2a11ruiVLZnL6vzNrhflBKBADqUSKX7fuigBmG5H
         2yqhPcUaVJ2wsBpqEk/mziW7btjpglpai3xWfW3yQg/SMexVOLYJjBibY3dzprzvDK8D
         6AiIEODbR1FOW1TPvl0vQ2YGGIw5TTYfWCTs7TAYFGtcYHP7jE1YmrFEKjDu8hTXETYz
         xxwxujYkwcxfy2hW4qjkmFILdatsI2T90TdU50AH5CXzkn3Bj2mnqxDEquqadWTKA3/c
         fhgg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b="JNZ/KgcY";
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v12sor61370813qvj.22.2019.08.01.08.24.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 08:24:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b="JNZ/KgcY";
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=R6/SxEPTIzTdE6W1Hx7mOa8dC1CKLzuuI3rK/m6KyjA=;
        b=JNZ/KgcYfb4dNpim+k2MOWWLFaur4nKwhjsoOoTJ+D9swbQ7WakCBsSE79BZJK5VUd
         TjaR5Fn6DG/7FS5/YK0BwQFEPkSVX+wxFzBFXOJHef1uJRGPIeUsvsLHJfXvbd1LGc58
         jSLve3ailjdQ/fS1b0OEFemmlrJeEh9hMrTcExWeVX2lAEBSKx0SywyPQV1LbcXFN+Qh
         bYGCXdm6pxLTRxasMToe/hcej2jpVrw92NRmHdvnSvfeQnxY+fK8ThuKP47ARnpprP5N
         YVNaR7JIkuxX+NzvFrcGZfJzUE20a9ytsxMazVrOY+8n2NC9P0G+nZoK1RtL9Sk5qgaS
         P7cw==
X-Google-Smtp-Source: APXvYqyqwg6VPHMO7J3bHZKnQ3bO0qH12fclYw4spACWNbJ1vUFrzBMweyq01CQXeNwF7FoAnD2faQ==
X-Received: by 2002:a0c:99e6:: with SMTP id y38mr92593639qve.42.1564673087348;
        Thu, 01 Aug 2019 08:24:47 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id o5sm30899952qkf.10.2019.08.01.08.24.46
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 08:24:46 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@soleen.com>
To: pasha.tatashin@soleen.com,
	jmorris@namei.org,
	sashal@kernel.org,
	ebiederm@xmission.com,
	kexec@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	corbet@lwn.net,
	catalin.marinas@arm.com,
	will@kernel.org,
	linux-arm-kernel@lists.infradead.org,
	marc.zyngier@arm.com,
	james.morse@arm.com,
	vladimir.murzin@arm.com,
	matthias.bgg@gmail.com,
	bhsharma@redhat.com,
	linux-mm@kvack.org
Subject: [PATCH v1 4/8] kexec: add machine_kexec_post_load()
Date: Thu,  1 Aug 2019 11:24:35 -0400
Message-Id: <20190801152439.11363-5-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190801152439.11363-1-pasha.tatashin@soleen.com>
References: <20190801152439.11363-1-pasha.tatashin@soleen.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It is the same as machine_kexec_prepare(), but is called after segments are
loaded. This way, can do processing work with already loaded relocation
segments. One such example is arm64: it has to have segments loaded in
order to create a page table, but it cannot do it during kexec time,
because at that time allocations won't be possible anymore.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
---
 kernel/kexec.c          | 4 ++++
 kernel/kexec_core.c     | 6 ++++++
 kernel/kexec_file.c     | 4 ++++
 kernel/kexec_internal.h | 2 ++
 4 files changed, 16 insertions(+)

diff --git a/kernel/kexec.c b/kernel/kexec.c
index 1b018f1a6e0d..27b71dc7b35a 100644
--- a/kernel/kexec.c
+++ b/kernel/kexec.c
@@ -159,6 +159,10 @@ static int do_kexec_load(unsigned long entry, unsigned long nr_segments,
 
 	kimage_terminate(image);
 
+	ret = machine_kexec_post_load(image);
+	if (ret)
+		goto out;
+
 	/* Install the new kernel and uninstall the old */
 	image = xchg(dest_image, image);
 
diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index 2c5b72863b7b..8360645d1bbe 100644
--- a/kernel/kexec_core.c
+++ b/kernel/kexec_core.c
@@ -587,6 +587,12 @@ static void kimage_free_extra_pages(struct kimage *image)
 	kimage_free_page_list(&image->unusable_pages);
 
 }
+
+int __weak machine_kexec_post_load(struct kimage *image)
+{
+	return 0;
+}
+
 void kimage_terminate(struct kimage *image)
 {
 	if (*image->entry != 0)
diff --git a/kernel/kexec_file.c b/kernel/kexec_file.c
index b8cc032d5620..cb531d768114 100644
--- a/kernel/kexec_file.c
+++ b/kernel/kexec_file.c
@@ -391,6 +391,10 @@ SYSCALL_DEFINE5(kexec_file_load, int, kernel_fd, int, initrd_fd,
 
 	kimage_terminate(image);
 
+	ret = machine_kexec_post_load(image);
+	if (ret)
+		goto out;
+
 	/*
 	 * Free up any temporary buffers allocated which are not needed
 	 * after image has been loaded
diff --git a/kernel/kexec_internal.h b/kernel/kexec_internal.h
index 48aaf2ac0d0d..39d30ccf8d87 100644
--- a/kernel/kexec_internal.h
+++ b/kernel/kexec_internal.h
@@ -13,6 +13,8 @@ void kimage_terminate(struct kimage *image);
 int kimage_is_destination_range(struct kimage *image,
 				unsigned long start, unsigned long end);
 
+int machine_kexec_post_load(struct kimage *image);
+
 extern struct mutex kexec_mutex;
 
 #ifdef CONFIG_KEXEC_FILE
-- 
2.22.0

