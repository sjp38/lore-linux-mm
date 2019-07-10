Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73D51C74A36
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 21:32:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 141CA208E4
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 21:32:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="MlbQLz+2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 141CA208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6AF7E8E0096; Wed, 10 Jul 2019 17:32:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6605B8E0032; Wed, 10 Jul 2019 17:32:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 54E4A8E0096; Wed, 10 Jul 2019 17:32:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1E78A8E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 17:32:50 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id o19so2211393pgl.14
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 14:32:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=D4vxIycjAa/oRBETN9HeGCijuet8TadWyyhq7cpzL/s=;
        b=U+yIhcIT63y6qJiivhOMCu6e0eIEBvWIyQwFNOb7QpgQ5B/2Ax0/iYdMho5m15bTCH
         xI8byYf5OV7fVMSIB8krOnDhVQxEOJFTg1cf3y+F+r0wesZ6AQH8SWNVUAqanRYVhClV
         2Ubo/UrWUKbJjYBHvYsrUtVDXxJrxMb70bvWBR+jVsFfVvCdqnCU/Bi9W8dXsAqzpMpL
         srHxaXe7eQqgjNpEdtk/iD8Q3ReYmb3ld4QRnWFrM6tM1NzGzfkWI62XUCFE0wDCqBgq
         HDuLu4yzfY3eC2Uz9eimzTQ/6LTa8h6e91M3dhOAjX+DWee+TLcRYQ4xgDLE7ynXw3Xh
         CN/Q==
X-Gm-Message-State: APjAAAX2W0ICmL1DG097qOrcSreORbjMoz80NVfKMHDa5Ac6QqUf0pj+
	e8XdvqrYXmKtiJVjtxIejqeyZyQymiYw8ZD5vCQG2vksHfGyyMo8aCM5p5lV4zfy1+WuBGs1tvi
	R/CTrc0m8HkBnT7kml5e99XA/oYLLEhuw2Z9u0/er4wiHxZ5deCZ6fmQdLXGEC1gURA==
X-Received: by 2002:a17:90a:ad93:: with SMTP id s19mr579698pjq.36.1562794369708;
        Wed, 10 Jul 2019 14:32:49 -0700 (PDT)
X-Received: by 2002:a17:90a:ad93:: with SMTP id s19mr579644pjq.36.1562794368891;
        Wed, 10 Jul 2019 14:32:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562794368; cv=none;
        d=google.com; s=arc-20160816;
        b=PJy9AC/RCEUQ1DCNXwDNu0mnb8mR0tHi1bowdByz8zG/xkhsuHXLr8A9aFoWEzpGar
         YZKdxF0ocm7DbF+M5BURwq9KFRr3KdvnoV9Y+JcTRFXekBXEL51RXR6P+mZGOqCSnaAD
         jJcDIPmfAvKqK8Bt7TbSW0L0gwiSJnv81OKQgquIx/3Fh2PVW7w0lAUOiNGReD9Xu5H4
         1GZoeQznafbJVm/ZDIh3ylSa1o30RG5Yyt/OyWUlpwcsiFhTvUWBAyXjdSyqMnreHNgl
         f0CvPFG6jE0kXtjAjTsDYsDp1kmx+hky0TYmI4HE9MA+vlSujixVl2GGRbjhb8GlBUGB
         SPOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=D4vxIycjAa/oRBETN9HeGCijuet8TadWyyhq7cpzL/s=;
        b=MRNJJayLMUPXTrKtchKiGXhyk3r42jTxuJwW8D/d+q78AG9MVNNBgfCElqLYqtGW+s
         PeYGVh/IWBW4y6rdEfh6X4u57qilVcXipnw+7sULOFUEfBt7k22dfEoeC23dGXw2XMdV
         38N6J91kd5EAyUv15cMfpo7BrwYL+sly1mhcY6qUGmlDzOFWea+v+n9K0kTEGIp5YJUi
         pi9Ck2Jay5SjynVCxga08VB8rJOjQIQSK+1CoqE+ZNDl0RhpuUcABLF3FxSAQHyQ/31E
         Mm7XSNKkeHNPgyP4NOubrM3TDF+aLpps5DOLvB3jV+73x3bFCcvhszfC8+37mCkmIFMG
         NxtA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=MlbQLz+2;
       spf=pass (google.com: domain of 3gfkmxqokclsifoszcvsothpphmf.dpnmjovy-nnlwbdl.psh@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3gFkmXQoKCLsifoszcvsothpphmf.dpnmjovy-nnlwbdl.psh@flex--henryburns.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id w11sor1799603pfi.56.2019.07.10.14.32.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jul 2019 14:32:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3gfkmxqokclsifoszcvsothpphmf.dpnmjovy-nnlwbdl.psh@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=MlbQLz+2;
       spf=pass (google.com: domain of 3gfkmxqokclsifoszcvsothpphmf.dpnmjovy-nnlwbdl.psh@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3gFkmXQoKCLsifoszcvsothpphmf.dpnmjovy-nnlwbdl.psh@flex--henryburns.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=D4vxIycjAa/oRBETN9HeGCijuet8TadWyyhq7cpzL/s=;
        b=MlbQLz+2fkGnqHycT99BCVEXFcIhY0NwQnphKHCTU8Gz9tipQo+9WHu51grPurjhXe
         a2mJ8ImxNmgAbiTIYRG/nSGwe2kz43z1U4ZFd89xe0Qe96E9FIxdd44b8vQ+Qtm9V9b5
         HXkWdEoy/bQqkyx07h4E6LUexLwmJCyUDimPcIRIL4qOhQYwmfLIrt3mAISYUmIFbA4S
         uN7O6+RFujww9gENEH3kpQJwwTNEUg7kBMszggQSnFpNEPgoXxJgqD+B8MPrcpHgxie9
         owYX9XCkjhjvjOD8la1tz+HhhRIty/YyOGFWGKeYu2TZ7aDtu9hj+njqVG0AF4Gd16+w
         Tt2g==
X-Google-Smtp-Source: APXvYqxkWs1ql8glIONr4J4jL2IwaFcEo5teu2KgnAVys+7+MAYwgY/fHlQzByp8VzJ9+OIkKY/Au1eLlsXi9afg
X-Received: by 2002:a65:65c5:: with SMTP id y5mr407700pgv.342.1562794368035;
 Wed, 10 Jul 2019 14:32:48 -0700 (PDT)
Date: Wed, 10 Jul 2019 14:32:38 -0700
Message-Id: <20190710213238.91835-1-henryburns@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH] mm/z3fold.c: remove z3fold_migration trylock
From: Henry Burns <henryburns@google.com>
To: Vitaly Wool <vitalywool@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vitaly Vul <vitaly.vul@sony.com>, Shakeel Butt <shakeelb@google.com>, 
	Jonathan Adams <jwadams@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Snild Dolkow <snild@sony.com>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, Henry Burns <henryburns@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

z3fold_page_migrate() will never succeed because it attempts to acquire a
lock that has already been taken by migrate.c in __unmap_and_move().

__unmap_and_move() migrate.c
  trylock_page(oldpage)
  move_to_new_page(oldpage_newpage)
    a_ops->migrate_page(oldpage, newpage)
      z3fold_page_migrate(oldpage, newpage)
        trylock_page(oldpage)


Signed-off-by: Henry Burns <henryburns@google.com>
---
 mm/z3fold.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 985732c8b025..9fe9330ab8ae 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -1335,16 +1335,11 @@ static int z3fold_page_migrate(struct address_space *mapping, struct page *newpa
 	zhdr = page_address(page);
 	pool = zhdr_to_pool(zhdr);
 
-	if (!trylock_page(page))
-		return -EAGAIN;
-
 	if (!z3fold_page_trylock(zhdr)) {
-		unlock_page(page);
 		return -EAGAIN;
 	}
 	if (zhdr->mapped_count != 0) {
 		z3fold_page_unlock(zhdr);
-		unlock_page(page);
 		return -EBUSY;
 	}
 	new_zhdr = page_address(newpage);
@@ -1376,7 +1371,6 @@ static int z3fold_page_migrate(struct address_space *mapping, struct page *newpa
 	queue_work_on(new_zhdr->cpu, pool->compact_wq, &new_zhdr->work);
 
 	page_mapcount_reset(page);
-	unlock_page(page);
 	put_page(page);
 	return 0;
 }
-- 
2.22.0.410.gd8fdbe21b5-goog

