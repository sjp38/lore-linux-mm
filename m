Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0444AC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B20A12083B
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="R1dyNzOz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B20A12083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7546B6B0278; Thu,  1 Aug 2019 22:20:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 66CA26B0279; Thu,  1 Aug 2019 22:20:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E1AC6B027A; Thu,  1 Aug 2019 22:20:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 139546B0278
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:20:49 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id j12so40681179pll.14
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:20:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=lKIFYbXGeRFczJ7GPuSawhtMV9YIx2+MYUTps7oOTAE=;
        b=RJNDNg8qzkPq7ntCGi19JS8xxHUol5fRkq7es8VW0ImlLdSeiArZOFwd7ARZpzc5ZB
         LKjyKLNZoGXEcqlcmgy+YpI949yEqM+7Ev0SRsbajl+pMGDkuHFKGs/zTkhfKl4rYXpB
         92pTo4tHxKILGcyGZAvA6z3u7TfoSY9QbaQPXEcKaXrOdqE3m1QFg6z8jEPPI0aZ4P9H
         0z/mZYfTbXYtZbR4pUBxP4iP0krtBoBfxN4uJ2CJTLtasZr7v/S9LhPNkFNbBc/ew1UQ
         +FdYCEOPntpe1DHt2+NE9NTFJIbDywUlXmT/JrjjXhluuFB1AcdqB3c/I+3yBoebPgTQ
         oANQ==
X-Gm-Message-State: APjAAAWmTDbJC5KiQX75ae0mBkly6apfxrS0FeI8gPxj2mrINOQFLmHu
	R5tpXOfZnp26FzLGlXnJsy0oWVnr1Ky1ndmNDULx2OiEb1vvk9shrMMZKTfG0TYCALlTaZf8u4Q
	fgotx6s+BG28F/BPGY+h78TDvDhsA43damSPreWmgZP5wRGImp3Wr5XgVQp0gQFWyqA==
X-Received: by 2002:a62:cdc8:: with SMTP id o191mr57009547pfg.74.1564712448760;
        Thu, 01 Aug 2019 19:20:48 -0700 (PDT)
X-Received: by 2002:a62:cdc8:: with SMTP id o191mr57009487pfg.74.1564712448140;
        Thu, 01 Aug 2019 19:20:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712448; cv=none;
        d=google.com; s=arc-20160816;
        b=YXYOTMcWgOHYe73R/IaQYgaNOAA6dmsJSHBZ87WPjeUH/6gLSFfSqU873UmEraeZ3J
         qcfCGoY4jYE5dhjuEAEqu3FgkHVr/0sh+29vs+ySq2cbig+C8U0NDZUre9FwRwm2+9WR
         kcGSthPkmC/bSZG9p9801oYUfbk6/omLSWhGTVRkOkaUTd3TOzvPQ4vsnF94vkfeqLjI
         vnBK7QVkUOTFITJQD80n0GdVjp4ChVSZHqAsRQXUQu5FdASnRXisLTsPeFZEU4mZnTSE
         MucIuJLGu1h7yHjKxGVSDtTVU0mJb9B1D/WXqN0PbcHQMX3jFcjsThAlcvnsJMBaQadt
         Sbrg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=lKIFYbXGeRFczJ7GPuSawhtMV9YIx2+MYUTps7oOTAE=;
        b=NC/7CJUjlkyGsBr+2aj9jZe7UWahBd8C85hyDNIjGd1vhbXIusxVV39igy/yrWLD4d
         383R9tP4CUH+zfB+CNFW1QYhEevLBEXvOMOMFko1oMnw40gFTQmT1L6kTgwML5HNycwx
         CU176VxuiworytTxJztQSV5PmgNSOOd/K5JBRW3vIB0X1XE5vvausgrlgbpBJ1Q8WE+0
         Adc36vwDS8ZpUnjmlygMyxOkmWLeVPUWs0au1sk9AFuXGk6+biFEJcGVKtNGDxJA8fmF
         IlyIIhXJBbOC3zpAdwXWv8hn9DLCDrKdYZflhS3p/lLGzgUvSOSPJ/cMYKsHBHOfXC+V
         jT6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=R1dyNzOz;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h4sor8179487pji.23.2019.08.01.19.20.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:20:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=R1dyNzOz;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=lKIFYbXGeRFczJ7GPuSawhtMV9YIx2+MYUTps7oOTAE=;
        b=R1dyNzOze/eqllrUqxRpjhDn38RC7VsduB92QlfhFLYwuwka43d0Yt9myEGcw6WlZm
         fYIT193clb3cCKkKRa4gQjk01O64tt0BXAAw6nkursyUCEWzk96M/WL6vzziPZU6IL+r
         rvITeJdAvAjJK8q/L91CFM+eVayVF1xEXzXBIhRNt9HdhEGbz9zWiE6QknGvjT5Q+PbG
         0FUQwvdG6OLHf8hS8zvFCr0JHd7YtbTEpJO3//HXWtUvFA/ZCzXGA0y95q3Jed0ZzVaE
         Qk7ZxouFXvlN6jsSJv67cehYgfxqrCWaOQlJqOD886yacjrOWwt50AkY8+51bO/ECErB
         IQTg==
X-Google-Smtp-Source: APXvYqxwmSe9JrA8Nqe8Cu6LF/8yd68XYfT17/pT9PHXIhg3Pa3JuYgXApqhYkPrHPsf3+6NRlbhyg==
X-Received: by 2002:a17:90a:601:: with SMTP id j1mr1872789pjj.96.1564712447882;
        Thu, 01 Aug 2019 19:20:47 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u9sm38179744pgc.5.2019.08.01.19.20.46
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:20:47 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	amd-gfx@lists.freedesktop.org,
	ceph-devel@vger.kernel.org,
	devel@driverdev.osuosl.org,
	devel@lists.orangefs.org,
	dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org,
	kvm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-block@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-media@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	linux-rpi-kernel@lists.infradead.org,
	linux-xfs@vger.kernel.org,
	netdev@vger.kernel.org,
	rds-devel@oss.oracle.com,
	sparclinux@vger.kernel.org,
	x86@kernel.org,
	xen-devel@lists.xenproject.org,
	John Hubbard <jhubbard@nvidia.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	Jiri Olsa <jolsa@redhat.com>,
	Namhyung Kim <namhyung@kernel.org>
Subject: [PATCH 23/34] uprobes: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 19:19:54 -0700
Message-Id: <20190802022005.5117-24-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190802022005.5117-1-jhubbard@nvidia.com>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page() or
release_pages().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Alexander Shishkin <alexander.shishkin@linux.intel.com>
Cc: Jiri Olsa <jolsa@redhat.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 kernel/events/uprobes.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 84fa00497c49..4a575de8cec8 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -397,7 +397,7 @@ __update_ref_ctr(struct mm_struct *mm, unsigned long vaddr, short d)
 	ret = 0;
 out:
 	kunmap_atomic(kaddr);
-	put_page(page);
+	put_user_page(page);
 	return ret;
 }
 
@@ -504,7 +504,7 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 	ret = __replace_page(vma, vaddr, old_page, new_page);
 	put_page(new_page);
 put_old:
-	put_page(old_page);
+	put_user_page(old_page);
 
 	if (unlikely(ret == -EAGAIN))
 		goto retry;
@@ -1981,7 +1981,7 @@ static int is_trap_at_addr(struct mm_struct *mm, unsigned long vaddr)
 		return result;
 
 	copy_from_page(page, vaddr, &opcode, UPROBE_SWBP_INSN_SIZE);
-	put_page(page);
+	put_user_page(page);
  out:
 	/* This needs to return true for any variant of the trap insn */
 	return is_trap_insn(&opcode);
-- 
2.22.0

