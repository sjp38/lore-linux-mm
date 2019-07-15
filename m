Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1AF6AC76191
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 16:47:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A88FB206B8
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 16:47:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="YeBZBrSX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A88FB206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 076396B0005; Mon, 15 Jul 2019 12:47:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0272F6B0006; Mon, 15 Jul 2019 12:47:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E309C6B000A; Mon, 15 Jul 2019 12:47:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id C1DE96B0005
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 12:47:42 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id t196so14233376qke.0
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 09:47:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=uefiGP790QPlHmhELnOTMDg4Gfv1ldPwSxnEHTELlh4=;
        b=QKQwaHshCOFRTMrKciwmfVBtdWd/ofN7LiTR9lDvSKtZVoUSpAp9+VXTqIc3eyzhhB
         RgFQ9MN/j16OYH9I+ZaRYc3F9mOF3bQsIqKSinNAkKeHIm9x2wEsYLF/xeRerypvLC70
         q4cvvG79CLmh7BHgLb5jPfXcFziW2k4gkQIVbkBqVZN4TLc7qMLT79gDqx4StY3w/tjP
         HXT9XYTkdXGFuL8PjCKiPi90dBJmBRuWpIg3tZnWusmURQIugZaa/TzQMLpU6XjI6rkv
         YbAukBnajiMnCl2TbKBMxWVNt2jrJpWxK7Cw6lxHdMO2IFFMGd6hC+ogS2X42bXPQYZJ
         d4Bw==
X-Gm-Message-State: APjAAAWObH6DwBUz9F7blw6CB8F48hzcwnHoItES//xGo6+oX4grhE3I
	QjOZL+2zJ+Akl/nfAuQcjeYcZr8f32oaMMAlNbuZJODzSZGUGT/ZFiIfA0vAYEsX/g7UurosH54
	w0q4F3STMTUPXHRZ7HXzZj9DUEF9db94tOfuQknrArYZsnv+6eeg19wwTYedrB0NdHA==
X-Received: by 2002:a0c:d14e:: with SMTP id c14mr19701581qvh.206.1563209262531;
        Mon, 15 Jul 2019 09:47:42 -0700 (PDT)
X-Received: by 2002:a0c:d14e:: with SMTP id c14mr19701530qvh.206.1563209261668;
        Mon, 15 Jul 2019 09:47:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563209261; cv=none;
        d=google.com; s=arc-20160816;
        b=xd2sKZ4V8RqtP42ZnwBUywuRbv4WoUEah0yrlY6vB/W07Wu15QPWzSZ7tNudApqBY/
         WQxBSg5HAPO4EgcgGxfePMukebAIVmS1rvN0LU7MO+0OZ5QBXLQ2ogCd3W6Y58CW/MHa
         AX49IW2cSobF8DMPwX/EbH7fp1tsVHJHZK/3uF3o4OLYULS0H7MEbh1TskRWJ2G07NUR
         T6iD7mfDQj4UefWz/b6pwg/suavTWHdOPl15jk/XjVL/B7fbafmMMYt8DwJW/mwvL8/R
         wfBkFrfuI2bt6gX+fERwCbOXQTTrPzJjpnyaDIRkDAfWZLGNszG2RFE7tjoHdPv0Nl+0
         ewRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=uefiGP790QPlHmhELnOTMDg4Gfv1ldPwSxnEHTELlh4=;
        b=sWYQaekKBkBrWorFcL/YxPPiHuso0+KqWpUIX3uGvzrT/8wc/JW3rYhqSNvZnOygfn
         AUdXcHBo1w8DffWaVhTnwo9A1MfXv8ks/wLnBCYc2TQGkrfCQhAsCw4DAn+e43Z7Fcli
         2xFFqiHOv6nxqJ/210JwJroJ48SwxOB+E4A6xxV/T3al7NaE3RCMGwbrojQQy7ZRt6+d
         zXD0GblRuyM8uuQMoo5FJAxdVtxyBWVqjMfXHkKbDlyVRhBjo0gQSb40ReqxX0QnMFVS
         Q87mAjggM66t2D3eLhl1M3/VzQMYDNLVKfRzfOA26ff6/vnzDDtuYpW8UpluX5czk2Tc
         ADHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=YeBZBrSX;
       spf=pass (google.com: domain of 3la4sxqokccwpmvzgjczvaowwotm.kwutqvcf-uusdiks.wzo@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3La4sXQoKCCwPMVZgJcZVaOWWOTM.KWUTQVcf-UUSdIKS.WZO@flex--henryburns.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id m8sor10252900qkk.66.2019.07.15.09.47.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jul 2019 09:47:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3la4sxqokccwpmvzgjczvaowwotm.kwutqvcf-uusdiks.wzo@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=YeBZBrSX;
       spf=pass (google.com: domain of 3la4sxqokccwpmvzgjczvaowwotm.kwutqvcf-uusdiks.wzo@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3La4sXQoKCCwPMVZgJcZVaOWWOTM.KWUTQVcf-UUSdIKS.WZO@flex--henryburns.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=uefiGP790QPlHmhELnOTMDg4Gfv1ldPwSxnEHTELlh4=;
        b=YeBZBrSXtK9i0HJSVVv2OwHsZlDPNrQA38z/OP0Renlqzd0x8ogg6n9oOCOxRZ/qJX
         2AFyJyFpg1T1qww+sFCfX4m+DLyS53IgMyeu1hTMwdzvac1reuMswpgPAbjchx8I44XD
         fTWAXvuAXFBDzH4LdWpWN5jKmuC0JAYcMKLII//xrW7oz2dgVjc34ys4nbJDLcGFLFg6
         hbJD7DHbO3okpeMb0YQw1fsqgya5/i7c5TpasVmFLqZuZZFs9wUa/O7K2vxk3tAXzORg
         +TBEy4PIZSjdM5zWz8MjB1WoK2H5ny25+wl5R6aKGS+eF9K8N/Y14yXFkgTIXR1hGUPR
         THYQ==
X-Google-Smtp-Source: APXvYqxhV21lnl98vfMuXVfbZYtgXl89P2Xqlu5YAtnRRfAoENjqyw61PjICMmXKSWQSqVMA9ImLdH2rX49JwDhR
X-Received: by 2002:a37:a343:: with SMTP id m64mr17595893qke.75.1563209261293;
 Mon, 15 Jul 2019 09:47:41 -0700 (PDT)
Date: Mon, 15 Jul 2019 09:47:05 -0700
Message-Id: <20190715164705.220693-1-henryburns@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.510.g264f2c817a-goog
Subject: [PATCH] mm/z3fold.c: Reinitialize zhdr structs after migration
From: Henry Burns <henryburns@google.com>
To: Vitaly Wool <vitalywool@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vitaly Vul <vitaly.vul@sony.com>, Shakeel Butt <shakeelb@google.com>, 
	Jonathan Adams <jwadams@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Henry Burns <henryburns@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

z3fold_page_migration() calls memcpy(new_zhdr, zhdr, PAGE_SIZE).
However, zhdr contains fields that can't be directly coppied over (ex:
list_head, a circular linked list). We only need to initialize the
linked lists in new_zhdr, as z3fold_isolate_page() already ensures
that these lists are empty.

Additionally it is possible that zhdr->work has been placed in a
workqueue. In this case we shouldn't migrate the page, as zhdr->work
references zhdr as opposed to new_zhdr.

Fixes: bba4c5f96ce4 ("mm/z3fold.c: support page migration")
Signed-off-by: Henry Burns <henryburns@google.com>
---
 mm/z3fold.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 42ef9955117c..9da471bcab93 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -1352,12 +1352,22 @@ static int z3fold_page_migrate(struct address_space *mapping, struct page *newpa
 		z3fold_page_unlock(zhdr);
 		return -EBUSY;
 	}
+	if (work_pending(&zhdr->work)) {
+		z3fold_page_unlock(zhdr);
+		return -EAGAIN;
+	}
 	new_zhdr = page_address(newpage);
 	memcpy(new_zhdr, zhdr, PAGE_SIZE);
 	newpage->private = page->private;
 	page->private = 0;
 	z3fold_page_unlock(zhdr);
 	spin_lock_init(&new_zhdr->page_lock);
+	INIT_WORK(&new_zhdr->work, compact_page_work);
+	/*
+	 * z3fold_page_isolate() ensures that this list is empty, so we only
+	 * have to reinitialize it.
+	 */
+	INIT_LIST_HEAD(&new_zhdr->buddy);
 	new_mapping = page_mapping(page);
 	__ClearPageMovable(page);
 	ClearPagePrivate(page);
-- 
2.22.0.510.g264f2c817a-goog

