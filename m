Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8AB4BC76194
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:59:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48D3521926
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:59:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ce/6WmN6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48D3521926
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F096A8E0013; Tue, 23 Jul 2019 13:59:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E1BA38E0002; Tue, 23 Jul 2019 13:59:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D0BBF8E0013; Tue, 23 Jul 2019 13:59:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id A73508E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 13:59:46 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id y9so19897101ybq.7
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 10:59:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=HpinGwuxMTqrT/lGIW6pacs7O2cDdG9/5Ty+RZAfASg=;
        b=jGOoYkNlV/BRG6ZzgrDUhwBpHX3AlCB2QfdXe4t2ARyyOaEoxkxsEqPrYQ05NF3ek+
         W2z35REUL27QZ3uzgS/0BkrMxQconzW2cQBQnFqKUGbGmbnA+oQNyFp+lhebQN47I7yg
         0+onug6lS7FEBef/8wBTyYehIx7v+7HRdfZGzCXpjLeggIp0XmbFsLxML0ITw2xvl8II
         SysnaqsUSTKw/Uh27cJPy0Ef8MBIqY61iLZyg6V599KIk5h3PjcTXI9mvH93FGRQyRQ9
         d3d7c476WIQKHZFwHr/4dqaP2f9qIWJ0SNd+ITSuH1UhBWbVyoMynM5TlT5YFHMHpCxJ
         ATJA==
X-Gm-Message-State: APjAAAV0KWCmXF/Kuw11qzwRfLNfJ8BhLU4NS+cfgF3pzllrqTtvfkw7
	TakSkaWuMxB18RQcds0rJPsVoZKHbbmW5cRqS8nJiS1FA/IWqaVuwaYiFVuXr2UsG+tP5ldFW2U
	JObqDP/So6v/afglj+6FwYWsRbzANHT23Azzw9P+DNC/kgw/tkvsFc82zNWhrhlX0xg==
X-Received: by 2002:a81:5c0a:: with SMTP id q10mr47561152ywb.474.1563904786469;
        Tue, 23 Jul 2019 10:59:46 -0700 (PDT)
X-Received: by 2002:a81:5c0a:: with SMTP id q10mr47561135ywb.474.1563904785984;
        Tue, 23 Jul 2019 10:59:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563904785; cv=none;
        d=google.com; s=arc-20160816;
        b=o8AGjyDcQV9/8WQ0R0zU3nnoWhAS59Q5IUEw+JuQ8bycoHUtX8CWK6OCGjEcXbZ8n2
         8s28DPPD1mri2vcpzEszUdApvchVXFRz8J7i69MtJpQbfalcYhSyZRIYq5v+E2Et/RMf
         WhEkWOszk1rlH2Xy3eRLTkrwEmZxK8z0JF/zurZ4tzcOWJI8GOYy85EAmtgPiBJxOf9L
         M5qG9fWTrXPIoi00EO/SC1ZoqWUsox7FGUuYgwo7ec2lOLVwtpFJ8RsvHL5AhvpB4TFF
         OCNvjZLSI9EZUV3Na1kLO8pfNI3FDMWttdCa/kQ3GUlU4QxY07ayJs+XJYPj0tTKZ7y8
         RbPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=HpinGwuxMTqrT/lGIW6pacs7O2cDdG9/5Ty+RZAfASg=;
        b=E/vPa2EfmlmtMbObMZrsmOGKY0xe229m3o6ZmjFT7boNUFITFAk9JeP25CNmyCSW+y
         oON89X7giZthqfSU6oTpGB/3L0IyvDagm2HHicQHFkP8jEbrhVqTx4Ig8yQ2CZpzceMq
         hQVveXJnJeii8NazfhnW004te/aQtjcti1Ln7Z6hpMorxvuwD7HO3q4BHlZmwvIztsp2
         CvbQ4r7TbeeylAy9s7wd3ZFM84KlNSK0pyP1w1gip+LiftFSJOPixQ7JBbCHWFX0igUN
         wwXG+XC7DDuUABprt7obOEM8we50v5HkFiav1K3gaV7R4DetHX0qhi8I4hUoKJGo4Fvk
         sbRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="ce/6WmN6";
       spf=pass (google.com: domain of 3eus3xqokchqsfvjwqcfndyggydw.ugedafmp-eecnsuc.gjy@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3EUs3XQoKCHQSfVjWqcfndYggYdW.Ugedafmp-eecnSUc.gjY@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id h11sor12855966ywb.89.2019.07.23.10.59.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 10:59:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3eus3xqokchqsfvjwqcfndyggydw.ugedafmp-eecnsuc.gjy@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="ce/6WmN6";
       spf=pass (google.com: domain of 3eus3xqokchqsfvjwqcfndyggydw.ugedafmp-eecnsuc.gjy@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3EUs3XQoKCHQSfVjWqcfndYggYdW.Ugedafmp-eecnSUc.gjY@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=HpinGwuxMTqrT/lGIW6pacs7O2cDdG9/5Ty+RZAfASg=;
        b=ce/6WmN6TyK+cE8ZhsNWx985tcmb8TsBUG67QVHPvfluZ/ESLePB0+Iu2kpzcDEd4Q
         YbgyS6kgeVvVFCMr/LAOnm0UHsRKQhmlp8Muf9Haj3921fIO1R3W8RTR8Ay/3UNeJg77
         3oj3IZF7aFzplHspAYys2RygkkcmZ5oyq8CPcTBqzS7rp1MfCHQ9R/Uyt21zik3yW2ex
         viSYi5ZHeqKSa6InOONOnbkuTpjEw9pZIBEPGTBapLOkb92OQ042RHOMLo5PTXbS7p7j
         huNarTmfeFDbiHSfiNnedUTa6Tx9rh0fc8dZU+mkH0hxVq24fx81n5unKjL7cIn91yBU
         G6/Q==
X-Google-Smtp-Source: APXvYqzHKD7+vuBXgJcq/Tk4Un/3kb/bP9xO8IxzyxfANBAOcEtBJXWYvzpx9hfbGP7jrgSdMTzC7LW89o7yIBsc
X-Received: by 2002:a81:7854:: with SMTP id t81mr13003915ywc.2.1563904785456;
 Tue, 23 Jul 2019 10:59:45 -0700 (PDT)
Date: Tue, 23 Jul 2019 19:58:49 +0200
In-Reply-To: <cover.1563904656.git.andreyknvl@google.com>
Message-Id: <100436d5f8e4349a78f27b0bbb27e4801fcb946b.1563904656.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1563904656.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.709.g102302147b-goog
Subject: [PATCH v19 12/15] media/v4l2-core: untag user pointers in videobuf_dma_contig_user_get
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
	Leon Romanovsky <leon@kernel.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, 
	Jason Gunthorpe <jgg@ziepe.ca>, Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Andrey Konovalov <andreyknvl@google.com>, Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends kernel ABI to allow to pass
tagged user pointers (with the top byte set to something else other than
0x00) as syscall arguments.

videobuf_dma_contig_user_get() uses provided user pointers for vma
lookups, which can only by done with untagged pointers.

Untag the pointers in this function.

Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
Reviewed-by: Kees Cook <keescook@chromium.org>
Acked-by: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 drivers/media/v4l2-core/videobuf-dma-contig.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/media/v4l2-core/videobuf-dma-contig.c b/drivers/media/v4l2-core/videobuf-dma-contig.c
index 76b4ac7b1678..aeb2f497c683 100644
--- a/drivers/media/v4l2-core/videobuf-dma-contig.c
+++ b/drivers/media/v4l2-core/videobuf-dma-contig.c
@@ -157,6 +157,7 @@ static void videobuf_dma_contig_user_put(struct videobuf_dma_contig_memory *mem)
 static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_memory *mem,
 					struct videobuf_buffer *vb)
 {
+	unsigned long untagged_baddr = untagged_addr(vb->baddr);
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	unsigned long prev_pfn, this_pfn;
@@ -164,22 +165,22 @@ static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_memory *mem,
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
2.22.0.709.g102302147b-goog

