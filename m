Return-Path: <SRS0=xW7F=T2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2128C282E3
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 13:58:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9CF1C2075E
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 13:58:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9CF1C2075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3EAE36B0003; Sun, 26 May 2019 09:58:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 39C136B0005; Sun, 26 May 2019 09:58:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B1896B0007; Sun, 26 May 2019 09:58:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id CFA246B0003
	for <linux-mm@kvack.org>; Sun, 26 May 2019 09:58:12 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f41so23329742ede.1
        for <linux-mm@kvack.org>; Sun, 26 May 2019 06:58:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZDWhH5lHKvu6n/JfphSGR0tadyAKjYAsbuB4tHrJEFI=;
        b=ewQ+3rsda5zYOIDem+W+OpN99T0PyLFmXhkgszRdwdWBGK2znrm50HDj51fXVG6InM
         q/9dXz7mZbqWnM7OMyBzIngGEc7YcC6ygKTo4IoaTqQQ5GEOBsRaGRF75Xzpd6VNCVyC
         OaNyd5m8MdNQAr4b0qooNzP399qX3Iao1/UcoM3r9s8WMgbjBXt5MTOTbhS8ohUDtSQA
         1Hoy+4YW+r/isG48KIVwzqZ3tNI9mX4ZcGlNgIZpB76pF+PSviuLHricYefl3Ax8/5WO
         W7V0QEtDbaqUtgABDd5+JbXalN+SHqxuy7o94dgeWTu3k33YQRzDMiDZSR7Jb42q9VPm
         7Csw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXPfpCBf+OvZy0bqjutA3Ph3S/JwW/KLIoYayW9gf0Chh2BYMBc
	GhWvwT6D5S9DFwlU67nu9BFWNEk153MQvlGj9iRdSOF6SuAehGwN78cPF/xLcl6n3tWCbxudnGL
	WBfyPGiNpXNk/nf1hYAO6GMi+6uq0978ZQVqLQM9nZ7TAxsLzxAZ9XIThPU8K1cY=
X-Received: by 2002:a05:6402:1612:: with SMTP id f18mr115004474edv.295.1558879092302;
        Sun, 26 May 2019 06:58:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzwnDpOR/aewUxoQ7Wmclw4fLN3UgunI4A3GqkAw9rK2cEGVLRuimm/En7DtUqBI9qqhtbN
X-Received: by 2002:a05:6402:1612:: with SMTP id f18mr115004424edv.295.1558879091509;
        Sun, 26 May 2019 06:58:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558879091; cv=none;
        d=google.com; s=arc-20160816;
        b=cuE/M12RKnh2bngjDUl4mtzW5cp+mHCfvjkOV0G3XsckN3ebf95Z6UMATt3ixSgItD
         L9EiuqFGcoAK/aJMHkoZy+/56LujD/3AOR3q5boagKdL2b5Wjx8klM08ZeZpXps1ZxKl
         kxok2CvYB+UcuLVwlBMJrsNwHHAFeWgB6b8hVu2G4r+OEAxwWkd8o7yuU8VFc+W4aSX/
         ON+8J4TsKA9gVzilD+g6UAqpo/xZmXCWOVgIa73j9aE8f/mHNJ4VvEpkQoLqRm4Em4y2
         7lFNWj76AyfA8aseTlWN1rV8BZ/D/ZqqAfkgnlix3QDJqKB1HU6pCAIVYwx/hUeOjOnO
         aAhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ZDWhH5lHKvu6n/JfphSGR0tadyAKjYAsbuB4tHrJEFI=;
        b=wAaf9J8G1vrJE94T9hcjhNqh/JdZhfAUKGJ6VKjLtr8+wlSMyPtJgDY/hhPxef5dit
         bZlCAMfRsvzgR9kLpg4waixFWc4UzCqoseBndOf/PTBIJUZkMlNdxX11lv+Sc1RVi/Kg
         WPZ0mKuDc2LQ3Z/+E0x6foPV0ICz6o1LeIpLx5LZuLKYH2hdTM/wNIcua8ftDAt3WsvJ
         cFohjRJT3ziCZYpikzRf1KZtphjTDhQUoZH8kSQrbFT6XxhsGdKOZxZkPs95KF/N488q
         b3Bi+H3R1WP/17LqyANUbLupEUkH01n2W7um37vN55qAckzMgUvFc+KLNxsVho/tmOGm
         5gtA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [217.70.183.195])
        by mx.google.com with ESMTPS id o52si4668122edc.421.2019.05.26.06.58.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 26 May 2019 06:58:11 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.195;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id D80B960006;
	Sun, 26 May 2019 13:58:06 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v4 09/14] mips: Properly account for stack randomization and stack guard gap
Date: Sun, 26 May 2019 09:47:41 -0400
Message-Id: <20190526134746.9315-10-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190526134746.9315-1-alex@ghiti.fr>
References: <20190526134746.9315-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This commit takes care of stack randomization and stack guard gap when
computing mmap base address and checks if the task asked for randomization.
This fixes the problem uncovered and not fixed for arm here:
https://lkml.kernel.org/r/20170622200033.25714-1-riel@redhat.com

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Acked-by: Kees Cook <keescook@chromium.org>
Acked-by: Paul Burton <paul.burton@mips.com>
---
 arch/mips/mm/mmap.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
index 2f616ebeb7e0..3ff82c6f7e24 100644
--- a/arch/mips/mm/mmap.c
+++ b/arch/mips/mm/mmap.c
@@ -21,8 +21,9 @@ unsigned long shm_align_mask = PAGE_SIZE - 1;	/* Sane caches */
 EXPORT_SYMBOL(shm_align_mask);
 
 /* gap between mmap and stack */
-#define MIN_GAP (128*1024*1024UL)
-#define MAX_GAP ((TASK_SIZE)/6*5)
+#define MIN_GAP		(128*1024*1024UL)
+#define MAX_GAP		((TASK_SIZE)/6*5)
+#define STACK_RND_MASK	(0x7ff >> (PAGE_SHIFT - 12))
 
 static int mmap_is_legacy(struct rlimit *rlim_stack)
 {
@@ -38,6 +39,15 @@ static int mmap_is_legacy(struct rlimit *rlim_stack)
 static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
 {
 	unsigned long gap = rlim_stack->rlim_cur;
+	unsigned long pad = stack_guard_gap;
+
+	/* Account for stack randomization if necessary */
+	if (current->flags & PF_RANDOMIZE)
+		pad += (STACK_RND_MASK << PAGE_SHIFT);
+
+	/* Values close to RLIM_INFINITY can overflow. */
+	if (gap + pad > gap)
+		gap += pad;
 
 	if (gap < MIN_GAP)
 		gap = MIN_GAP;
-- 
2.20.1

