Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C5A8C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:52:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0FA582184E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:52:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="vGvcqQl8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0FA582184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 33D036B0272; Wed, 20 Mar 2019 10:52:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C9D66B0273; Wed, 20 Mar 2019 10:52:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 11C316B0274; Wed, 20 Mar 2019 10:52:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id E01CD6B0272
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 10:52:40 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id 54so2301479qtn.15
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 07:52:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=wXdkYKKqhy/PeP38eGiAHfinlz29ywOf5m6iUAAWrE8=;
        b=jIHIrT0ljaqUxXl7HwVplEPxTHHUKn5lQGuI6R0O//UDCO/ryrV9a6L/KJdb7Jhrp9
         P+4NI2id13/anHk+8rqRpBm5RmG00WqO73UfDoGZDajIawAwW22Z+nfbnVV4Q6D4/g/a
         q8h7+aRSlM4W2RFFAQvsg7Inhr2FwUu4JChfTi2OukJSG/rxm3znYYoqDO9fJtOdAEEt
         +o7VaRFosEDJBm1owYYesWaluXYz1NNvY8FxSIG6Zl1Hiwv8OoheLBL+edt1iVqL003o
         DOfc8bPypuqmVsxjzlk8ZU0Pteo8fdwUHDk9bD0ZPXa6hC7gGSlhht+x04W4XlxNdrg0
         4LBg==
X-Gm-Message-State: APjAAAX9HwGf+69KGwz3f1+VfCsVkB9WQC562lVMydyb2l0H5CujYPsO
	NxhhjSl7+1lsB0/XKuW3vUiHxBIfBG8/EdCr1xGcqhexur3+HJjOJKP6w2vk4hHpq1mKsIx8yXy
	HbZTp0BvkCgEyUuFI8pkDmdEQZ2Eu+XwFaYHNBPBUpF/VG+PyHijqaYccMrRUqXnEIw==
X-Received: by 2002:ae9:edc8:: with SMTP id c191mr6964866qkg.155.1553093560650;
        Wed, 20 Mar 2019 07:52:40 -0700 (PDT)
X-Received: by 2002:ae9:edc8:: with SMTP id c191mr6964825qkg.155.1553093559983;
        Wed, 20 Mar 2019 07:52:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553093559; cv=none;
        d=google.com; s=arc-20160816;
        b=aEeY2nA6BMy1h8zs8VEy2xU28wuP1GoeH6bIJmZmwp25rM3ECSpn9B6ZBJiroDED5i
         Fdv+zJpe2SslunYiigrON1xxXRebh0EKDklQ2JsFjx9JelaYbO09/UVqKWWlym7S4TR6
         L3pMxkjWBb489C/eFBF0gBsU8BiJcGuzSU3oK4WJxvx6n92I7zbbO7ADIgpAzaCR9l2t
         3qJOjoT8tyMXD9YdW9vG32beSR4iFRCv6Zjlqyqz6cV7/UjqJ5dZ5UlT9AFMsc+YhksQ
         Vsx0QwOBg1XddqE0mrFq6l30vFqEYMuub9PNVKLczdMOSXrYF83yT1O2h/Mh9G/dhcSA
         ONQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=wXdkYKKqhy/PeP38eGiAHfinlz29ywOf5m6iUAAWrE8=;
        b=h8YuHP3AMDA512IGsvbFAgxIUvyPfJCB/3OC0yeZ01BfNlCePZANX0FypKKwMXZH/6
         64SsV0q9/Gz7ERFMcnOd5b6H0MJ0FMQDfIghHR7OQhXLmRLe1djjzW40ji88+s8ZUsTU
         3DGB5SkAB0gJJHnKmEi92CHQZk5mo0GsYFF/pSfZUBijJWsWug2LSLGtcnp9B6VkUX4o
         naCgCRA8Znxs0yl072f1aMXq7Z6v+qkw8TOZiFTukLtLyfh5KHIbT5GJHD5RfOIXA87z
         lzfx4V6ImIUecfWzhdyvC+jycoLQ4psnUBPaYCYmM/LoXFiOE5naQOlURyFnG03AHq98
         LMXg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vGvcqQl8;
       spf=pass (google.com: domain of 3t1osxaokcjiw9zd0k69h72aa270.ya8749gj-886hwy6.ad2@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3t1OSXAoKCJIw9zD0K69H72AA270.yA8749GJ-886Hwy6.AD2@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id z192sor1755293qka.66.2019.03.20.07.52.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 07:52:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3t1osxaokcjiw9zd0k69h72aa270.ya8749gj-886hwy6.ad2@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vGvcqQl8;
       spf=pass (google.com: domain of 3t1osxaokcjiw9zd0k69h72aa270.ya8749gj-886hwy6.ad2@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3t1OSXAoKCJIw9zD0K69H72AA270.yA8749GJ-886Hwy6.AD2@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=wXdkYKKqhy/PeP38eGiAHfinlz29ywOf5m6iUAAWrE8=;
        b=vGvcqQl8zr5X3WM6Pnd+j7ESVWistQw68FAbZfGNeDxL4YYPJ+4OqqvXW7UJbff64S
         SyCyuCgR8FsxykYFHxZWggo7wmmKHcIn/zY2gfqkitnlkwmk5EXExr6QbsvFWToOM+WL
         QCPwgzhfuDbLfbS3Fig3TlGkfXqXtVQtp9TzZy8I9KwzBEdSIeS5Q5WHsyncfNZu/5vS
         Hr5mn91x0XP2yZ8L2TzmgWuRJtVdl+Dl6mGsDyEaHoP98pICbmRz6fkWzF4gQ2C8Nz5C
         XyxbkVWlsM3lV1CHfezqLixEZRPiaqZkNbdh+E/dJkMt88Sw8raDDkXlf+wmKYTUA72K
         gOgg==
X-Google-Smtp-Source: APXvYqy01Tx4GR4P4j18wQEAClBXiiOkZilRtlYP4igDQPOGQlXjkic5cCk6gARehYogarcGTwIZa5tD2bxwI8+V
X-Received: by 2002:a37:a783:: with SMTP id q125mr10967339qke.56.1553093559661;
 Wed, 20 Mar 2019 07:52:39 -0700 (PDT)
Date: Wed, 20 Mar 2019 15:51:31 +0100
In-Reply-To: <cover.1553093420.git.andreyknvl@google.com>
Message-Id: <ae6961bcdd82e529c76d0747abd310546f81e58e.1553093421.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v13 17/20] media/v4l2-core, arm64: untag user pointers in videobuf_dma_contig_user_get
From: Andrey Konovalov <andreyknvl@google.com>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>, 
	Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, 
	Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, 
	Alex Deucher <alexander.deucher@amd.com>, 
	"=?UTF-8?q?Christian=20K=C3=B6nig?=" <christian.koenig@amd.com>, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, 
	Yishai Hadas <yishaih@mellanox.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
	linux-arch@vger.kernel.org, netdev@vger.kernel.org, bpf@vger.kernel.org, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>, 
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
2.21.0.225.g810b269d1ac-goog

