Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21D88C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:33:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2F9721655
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:33:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="BuaO5811"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2F9721655
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A909C8E0012; Mon, 24 Jun 2019 10:33:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A1A498E0002; Mon, 24 Jun 2019 10:33:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E41D8E0012; Mon, 24 Jun 2019 10:33:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id 617CC8E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 10:33:42 -0400 (EDT)
Received: by mail-vs1-f71.google.com with SMTP id m186so3938733vsm.2
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 07:33:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=+QjTccShtmk/DNvEu2Adujr4/24uQqkMA4u/Npu2BdA=;
        b=njKUSkxRRiCCTmt7usTZs+IY9weVE1zgBEpPLxxlVepvsHT3Sm91/tVtC9Ju46iviS
         31tXUP7GxIX+jh2VTcfzLXVnEvgszpcrt0/Tiej888h/kvwydlhnQArItJNF3wUthwXQ
         3nf11y/eHbjxkFz3ocZclUfJccOaxOWsX7PNceQmeMObvaT7qH5MOoIxuIsFDHnL2au4
         MYfPMtD3uOuCf6tnRgubaJ3fxmnhXrl8unbXHimuWn3oI60wEawd5NzTlOsJOn46B2eT
         w9GGfycudKHnIQVDA0LIIxdqAppw1WmykGA9AaOITdIzrdt21rHXxAMJyNBv5RZdfv25
         R9Tg==
X-Gm-Message-State: APjAAAXYZkgXCLTVNO0cUi4G9sKQBAAEgGk8UbJyRZfLnaNgWnPvnsQx
	adpnVU37jv8isQJmiR6vv4+heRvwrb7ANL4ioOPSivvor7gXApCwi1/LsqX8xAMJj5K4s++EwzR
	I2d2erFOkUg3Vso60VC76uFyZU7dQM/LzAhzfjDi+feF7ha1evxa0dstpAVHE1vKa9w==
X-Received: by 2002:a67:efca:: with SMTP id s10mr16584029vsp.20.1561386822158;
        Mon, 24 Jun 2019 07:33:42 -0700 (PDT)
X-Received: by 2002:a67:efca:: with SMTP id s10mr16584007vsp.20.1561386821634;
        Mon, 24 Jun 2019 07:33:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561386821; cv=none;
        d=google.com; s=arc-20160816;
        b=aQNEO8Z/K6h5uFhhkQUjacyBYFmjZU53gbDVOgqQRUEObqQ8kUoKye3Eow2dPAZf6I
         Wlq65ll1SiJ1eOOCcV5w70UkE2Lh7BDtJDDpaIIUYP+yG0R714cOffgoRV+7LFMhQMF4
         NTdJvX3of8BX/rSlfeyhpm+IQDIow/mlDIPHTKcieTux+W6dd01vMPvnxHK4qTucyUVP
         LgHjLQbIPGCYzmBA4g9l+8/Ax97eBszwIZnEeurbhB6RKCGlg3LOXHjF6Xv+dBZEbPmb
         qAoO5dpklVr9x5e3AfML2NpOgy7RO/J689vq7ZHVlbVq9qdo37pCI7yjm8AbbmgB33FH
         rjpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=+QjTccShtmk/DNvEu2Adujr4/24uQqkMA4u/Npu2BdA=;
        b=nDOd5woVEpf3EOVtvdCyMPoBcPgOqAFs3VbJBTKdlOjXLWKrrYL0inFkovkIdUFiyQ
         1v7sA68xEV7lYpKNlX3OszZEOjd2soIcSGKrD9AvK3EKjW/UuLxoZeQSFKanRUFvUJz0
         53w9BQuEr8HszE0Svm+Wwj0nXdOYjd4paQdhq4B1P/Zl6mvTqlAm1oXsJe96sc4vD+bS
         B5IuZYW57kK7Ub8TsbzMH1H0gBvK1eQxut3Hci/wjP2zaTFIjBnUv8oWAvbOTp5ccKnk
         NCPpZpBQW+06D9BlkU7VRZFm+4x0G+Ospz7Lxsf+ZrWtn/rluQIW74EK2JUjvmmgCG7q
         7toQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=BuaO5811;
       spf=pass (google.com: domain of 3rd8qxqokcdysfvjwqcfndyggydw.ugedafmp-eecnsuc.gjy@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3Rd8QXQoKCDYSfVjWqcfndYggYdW.Ugedafmp-eecnSUc.gjY@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id t140sor3409890vkt.48.2019.06.24.07.33.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 07:33:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3rd8qxqokcdysfvjwqcfndyggydw.ugedafmp-eecnsuc.gjy@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=BuaO5811;
       spf=pass (google.com: domain of 3rd8qxqokcdysfvjwqcfndyggydw.ugedafmp-eecnsuc.gjy@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3Rd8QXQoKCDYSfVjWqcfndYggYdW.Ugedafmp-eecnSUc.gjY@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=+QjTccShtmk/DNvEu2Adujr4/24uQqkMA4u/Npu2BdA=;
        b=BuaO5811jnUX9zfd4G8ToBhrbhMJy0LzFmcX+sgB7AQM8NJvSv01OIt+sAqC0IYDFj
         O+VE+bcKl7xzCDnEKiecjcqkjUhFXSFgcq02fOM7s9XnYH4kbv5oATeSWl+tEWpHxjax
         uddXNBc9L6bsecbckcats1vGIj+FRm1AXB1jETFkmq7osCy5XjHt0r7A/MylVaoS7sEi
         BEqqQGEpCtD+G1DLTSJRrPX1jP7q6JLRto0o7pT68gHSfXhTroGbTpoKZNwyLPn4gBNV
         8ODVys95W2+g/mSu4Rja/qhLF+ras1jurnSxRwwt4QC/Gcz8iYCVwlkq+O0Dgaz38Z6X
         Qigg==
X-Google-Smtp-Source: APXvYqyUWW8huBSfbOwzfvyZrK53WvzmxiQ9by61ETLtrVtF59paHvOBrjS1vPlQyT8G9KXO3foj9yEr/dGEqynR
X-Received: by 2002:a1f:a887:: with SMTP id r129mr2036386vke.75.1561386821206;
 Mon, 24 Jun 2019 07:33:41 -0700 (PDT)
Date: Mon, 24 Jun 2019 16:32:56 +0200
In-Reply-To: <cover.1561386715.git.andreyknvl@google.com>
Message-Id: <ea0ff94ef2b8af12ea6c222c5ebd970e0849b6dd.1561386715.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1561386715.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v18 11/15] IB/mlx4: untag user pointers in mlx4_get_umem_mr
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
	Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends kernel ABI to allow to pass
tagged user pointers (with the top byte set to something else other than
0x00) as syscall arguments.

mlx4_get_umem_mr() uses provided user pointers for vma lookups, which can
only by done with untagged pointers.

Untag user pointers in this function.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 drivers/infiniband/hw/mlx4/mr.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/mr.c b/drivers/infiniband/hw/mlx4/mr.c
index 355205a28544..13d9f917f249 100644
--- a/drivers/infiniband/hw/mlx4/mr.c
+++ b/drivers/infiniband/hw/mlx4/mr.c
@@ -378,6 +378,7 @@ static struct ib_umem *mlx4_get_umem_mr(struct ib_udata *udata, u64 start,
 	 * again
 	 */
 	if (!ib_access_writable(access_flags)) {
+		unsigned long untagged_start = untagged_addr(start);
 		struct vm_area_struct *vma;
 
 		down_read(&current->mm->mmap_sem);
@@ -386,9 +387,9 @@ static struct ib_umem *mlx4_get_umem_mr(struct ib_udata *udata, u64 start,
 		 * cover the memory, but for now it requires a single vma to
 		 * entirely cover the MR to support RO mappings.
 		 */
-		vma = find_vma(current->mm, start);
-		if (vma && vma->vm_end >= start + length &&
-		    vma->vm_start <= start) {
+		vma = find_vma(current->mm, untagged_start);
+		if (vma && vma->vm_end >= untagged_start + length &&
+		    vma->vm_start <= untagged_start) {
 			if (vma->vm_flags & VM_WRITE)
 				access_flags |= IB_ACCESS_LOCAL_WRITE;
 		} else {
-- 
2.22.0.410.gd8fdbe21b5-goog

