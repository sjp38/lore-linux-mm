Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 600CDC04AAB
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:31:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1BF6520C01
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:31:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="smw+2+ze"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1BF6520C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 105466B0279; Mon,  6 May 2019 12:31:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0DEB86B027A; Mon,  6 May 2019 12:31:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F36536B027B; Mon,  6 May 2019 12:31:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id D3F266B0279
	for <linux-mm@kvack.org>; Mon,  6 May 2019 12:31:51 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id j6so13226715ywd.23
        for <linux-mm@kvack.org>; Mon, 06 May 2019 09:31:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=qJJU2gbhvvSzaaRZNAk/AylUL7YQ1I9YBdVQ8VYA/h0=;
        b=HjZ70/MZNHgpkb/MzF5ynQ+A7NGWCKmA3ICeaWy2cxUN6pemsFRsltcwOzcsbvjC+r
         E4PpxuP/yj/FsEo7F2jtKWrpIJEsOOd8DOKd+w4fHJ1uJSuClfdbUAb0My/UjPmj1R6I
         3VwnCfW0RlKlgWcSK7GPnR9Cgi8FuN/d87sOMvSUgT+zYu0vTQYV7L92YcfWHlZxJaWP
         XN9KlaKqz3R+oK3epermukad9xZ0YTBzaGuvQSLawfgSB+oTj5SIZjq6FZTZkgKb9jND
         JgqGmfE3BtgZWAJ9+N36vos/eJKDg/vn2bgT9Xox4l4rtnME1/20Mt4WMORyOt2+zFMY
         M5RQ==
X-Gm-Message-State: APjAAAUT4vS29eEBzBccpInlnD5eXxMtIpv+lL67SdxGi7NjhyeLyFoY
	3alwccheryRh1v74oj5SjRJ1sYlpUXrxaKfBPV2wwCc5UofBJfcJctRpuHeIrALTE84d6bI8zyb
	kBO4pYK4f8N1Du85dShKonf01MMoisL7oJgkdQo3LRUcYu0DdjQUA6bFSuxM66YtZEg==
X-Received: by 2002:a81:6586:: with SMTP id z128mr18636924ywb.239.1557160311594;
        Mon, 06 May 2019 09:31:51 -0700 (PDT)
X-Received: by 2002:a81:6586:: with SMTP id z128mr18636871ywb.239.1557160310940;
        Mon, 06 May 2019 09:31:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557160310; cv=none;
        d=google.com; s=arc-20160816;
        b=XNb7RcgBLL9QxrIwf5IGK8p0+PgcIOBVfEkfd+qRrmY8Bnwi99vK9Jy9yIxKVTitBA
         JJyA4D1aOS1rkDpYvY5N8ZcP2bTuXDjVmA9ACiUXf8e3UC+UImHY/EUv9UPtMD6fZs4Z
         vm2P0XZZguZ5OQV6zcl7z2gK/JRu1Uy/XaMwhQMkN9a/T5Jp6bFacNQxJrrbTyP1iZlm
         u1vQTWxEAhhSCitBEWzrTQc49otnyZ3AV4AXXk2R0lQgwdMXn352y/XN3AvIgsmXzMhH
         e5PkXJpq5BnA5tBitoXfL62MXRQzGr5KlpvSGrnfghe4CG4oiQ7lHBuGAX6oKwuANyut
         fFxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=qJJU2gbhvvSzaaRZNAk/AylUL7YQ1I9YBdVQ8VYA/h0=;
        b=oChpdjf1UZX7imZnDkbZNfxhCkMKXdcM+nmPQ0EpFfs865cYCxfC771fQ5rb7vq1Po
         tvASr3UM1/mdleNpAgtFR2NxwFWpERlbNX3SG0G+tgv+UeCLSTHxQe04irFjAB6Wx/C3
         BLjfnz0POG7jfBtpuD/fN5tiXYcoN+vegNzTdzfSGREIaj1UOt4R5+hx7fYbOTJb3FoO
         Tmci8MCOJifVYTBX7H9VfZU05mvRdgtbRysrwl1SSL+LxMsnRo2b4JHMKCYaRq18mK2Y
         9MSBLCucO1Nv4lSrjdixX10di7iIKmn0+0utEQIJYDQOylFANlSvFxorXfywj0Oe5pyE
         BRVg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=smw+2+ze;
       spf=pass (google.com: domain of 3dmhqxaokcgcfsiwjdpsaqlttlqj.htrqnszc-rrpafhp.twl@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3dmHQXAoKCGcFSIWJdPSaQLTTLQJ.HTRQNSZc-RRPaFHP.TWL@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id w7sor1844710ybe.185.2019.05.06.09.31.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 May 2019 09:31:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3dmhqxaokcgcfsiwjdpsaqlttlqj.htrqnszc-rrpafhp.twl@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=smw+2+ze;
       spf=pass (google.com: domain of 3dmhqxaokcgcfsiwjdpsaqlttlqj.htrqnszc-rrpafhp.twl@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3dmHQXAoKCGcFSIWJdPSaQLTTLQJ.HTRQNSZc-RRPaFHP.TWL@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=qJJU2gbhvvSzaaRZNAk/AylUL7YQ1I9YBdVQ8VYA/h0=;
        b=smw+2+zeQRYDg9lMdhXKhP6q2UgWQk5tdiALYOGrpKFur5CJhfOg9OO/PZTfQT7ZwY
         RvP2Hk/sSL7ML8WOTNeWv38qmUNAe4g4KhC0ua28+5atrFm7K5fmvkLjk0Db/ljqag0b
         dQjecdgCCDsZyAajxBKxJc7LsxcMY95MEt9IiglDE0kwt30ExqYblax2XRbyRPQRXMO4
         E+sey04rspIj0vK4v2o8+jJjIqc7WmoTjK96Ljfvnn/wyfRgdPoxhrZ+nqZ5Pgf+9DsA
         QtQ6iTRFCgpCJVB7xCQGyTJqnI3tF0Os9MEQkOzATYUN++U4ys3fnY4AQGWE9mngxzPC
         elwg==
X-Google-Smtp-Source: APXvYqx1X9tJcqBzNMWoEfXSSulDx8NO+a1TdtkQwmCv7glkGcm++BXem7IIU8nDFZviDaBVQ7bW4qmRV4r3Auad
X-Received: by 2002:a25:2a17:: with SMTP id q23mr16755885ybq.195.1557160310462;
 Mon, 06 May 2019 09:31:50 -0700 (PDT)
Date: Mon,  6 May 2019 18:31:00 +0200
In-Reply-To: <cover.1557160186.git.andreyknvl@google.com>
Message-Id: <b7999d13af54eb3ed8d7b0192397c7cde3df0b28.1557160186.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1557160186.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH v15 14/17] media/v4l2-core, arm64: untag user pointers in videobuf_dma_contig_user_get
From: Andrey Konovalov <andreyknvl@google.com>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org, 
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, 
	linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	linux-kselftest@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Kees Cook <keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>, 
	Felix Kuehling <Felix.Kuehling@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, 
	Christian Koenig <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends arm64 kernel ABI to allow to
pass tagged user pointers (with the top byte set to something else other
than 0x00) as syscall arguments.

videobuf_dma_contig_user_get() uses provided user pointers for vma
lookups, which can only by done with untagged pointers.

Untag the pointers in this function.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 drivers/media/v4l2-core/videobuf-dma-contig.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/media/v4l2-core/videobuf-dma-contig.c b/drivers/media/v4l2-core/videobuf-dma-contig.c
index e1bf50df4c70..8a1ddd146b17 100644
--- a/drivers/media/v4l2-core/videobuf-dma-contig.c
+++ b/drivers/media/v4l2-core/videobuf-dma-contig.c
@@ -160,6 +160,7 @@ static void videobuf_dma_contig_user_put(struct videobuf_dma_contig_memory *mem)
 static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_memory *mem,
 					struct videobuf_buffer *vb)
 {
+	unsigned long untagged_baddr = untagged_addr(vb->baddr);
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	unsigned long prev_pfn, this_pfn;
@@ -167,22 +168,22 @@ static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_memory *mem,
 	unsigned int offset;
 	int ret;
 
-	offset = vb->baddr & ~PAGE_MASK;
+	offset = untagged_baddr & ~PAGE_MASK;
 	mem->size = PAGE_ALIGN(vb->size + offset);
 	ret = -EINVAL;
 
 	down_read(&mm->mmap_sem);
 
-	vma = find_vma(mm, vb->baddr);
+	vma = find_vma(mm, untagged_baddr);
 	if (!vma)
 		goto out_up;
 
-	if ((vb->baddr + mem->size) > vma->vm_end)
+	if ((untagged_baddr + mem->size) > vma->vm_end)
 		goto out_up;
 
 	pages_done = 0;
 	prev_pfn = 0; /* kill warning */
-	user_address = vb->baddr;
+	user_address = untagged_baddr;
 
 	while (pages_done < (mem->size >> PAGE_SHIFT)) {
 		ret = follow_pfn(vma, user_address, &this_pfn);
-- 
2.21.0.1020.gf2820cf01a-goog

