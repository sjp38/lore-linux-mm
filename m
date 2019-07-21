Return-Path: <SRS0=x6gJ=VS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6BFF9C76191
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 15:58:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 26EFC2083B
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 15:58:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ifiOqyLu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26EFC2083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD7336B000D; Sun, 21 Jul 2019 11:58:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C86B38E0010; Sun, 21 Jul 2019 11:58:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B9E506B0010; Sun, 21 Jul 2019 11:58:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 866556B000D
	for <linux-mm@kvack.org>; Sun, 21 Jul 2019 11:58:27 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 191so22107500pfy.20
        for <linux-mm@kvack.org>; Sun, 21 Jul 2019 08:58:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YPxj1xULAmyThBZtHUXs4RUTpVotq1m6ArGML4hnd9o=;
        b=JE4haQ9x1U1ckaqtE9aO4Gjby/7B5D2bFrON8qtIXJu/eT6Q8IqCDaJ38G4vqfPPfd
         wy15LMhYwJCRH4/5OJsEIbxJvJ41KOroIMBVqg7KGoBLTTf4Adem/68EEdJsOEswZTZQ
         Z7pGK95hlX/sm2ug6GwzrOYJNLSmM5RQianDddqdLYuDWt584vxXR9t5jXPhD3eH5aUX
         rybmX3l7U4OcpyBiekzojZ9rL2Nr1VkxgYHvXB1gokGYnA3iOsQvmgXlqU7gCsa/uuAX
         blCpPzgU847pwUKq3gDr1SHdUbHdUjJmcMYrfUnhCid0nmdsXo3Lm2ad7d0S8AU36MNy
         7nww==
X-Gm-Message-State: APjAAAUDQy3+PaVgvD3PoLMqUwDihXUfwHafzGZERGRh4Yt2Esa57uC8
	nIn5catxnPV+xTETuf3ILdPPz3k7205sD7eV1zpcqwX1QXl8O728E7+NTSRtNJ1PRr3mMVkUBCO
	iECgz42ENhcXW46+vkhb7Tqgu4dXvv8uwVePfojHafwMKX1gcZb6PilwEJ7Rnp5Z4eQ==
X-Received: by 2002:a17:90a:17ab:: with SMTP id q40mr73294990pja.106.1563724707155;
        Sun, 21 Jul 2019 08:58:27 -0700 (PDT)
X-Received: by 2002:a17:90a:17ab:: with SMTP id q40mr73294928pja.106.1563724706295;
        Sun, 21 Jul 2019 08:58:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563724706; cv=none;
        d=google.com; s=arc-20160816;
        b=Vawu4S6UTsfiY9sbi6/C6G3RkKLl2CkSbtZ8DjYBZpy9uuJ0sKo3Gr1umZVxgCMkYa
         tnFsw/m//B7InR7On31HY3JZDdiqAaUq6ZrRV4KERJBv/ab+OYxHFlB1Hd5EsItJM/QD
         ESu17qiDxciDHhhXRHe4WJ0qUKIqx4H7NnUYdvG1yF6RMiUQQZ72BzERutlgU77Nu5LH
         wMUwK2jXJV0H1CrxJ88SYTLiaGOIL4YtKq7KZdasGTlHeXzj1fBS0d6t7J18Fsj05aoe
         SdKPu+MmglYCw681jbzYFcK6gsbS5F8tbRJSCJAY0vxn4/TCbwv+aWEUyzwzOm/8umLc
         iibw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=YPxj1xULAmyThBZtHUXs4RUTpVotq1m6ArGML4hnd9o=;
        b=IlPEOmHX2ap0e6WsuL2AL2VfgRmWnBm7aUwARXuvzte0lzHpBLQoxL9ZxO8KjgEPUC
         ablBu0ihV/8WJwzA0/uTv42KRmehlwuFhQkmcEd3e5jatwbE5RPk0dNXksDqB4110321
         17DMsiWxujuotwcNbfrUQPVDUFw+6vtUtdIysdgc0guvXBo7UKBav1k3XbaLHiX+87co
         m6zDoGltYT2KyYWr09FfZCEp8TNeAjQz+EASY8i2yHQEf87oMquQ7St/rhL+1xlaI7Te
         tna/rZg69/D/EiHgWVLeJCHw5BNfUuoU0yy9ngvInpa4rgyaBg20UybTCv+H3psDCFcu
         cG7A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ifiOqyLu;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t5sor5657219pgp.83.2019.07.21.08.58.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 21 Jul 2019 08:58:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ifiOqyLu;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=YPxj1xULAmyThBZtHUXs4RUTpVotq1m6ArGML4hnd9o=;
        b=ifiOqyLuR2fVpSX7LgALyQR4fLm8I1fH/HPzFhDKareH7Mat4AeFK7FriOec5kkIK2
         wrkY60M1g9T4xGKZPATWmMcmqyzUnhouyS8jLdWqlmaw7Uhyw/yfS0tLX1lp5rQKJaLB
         fSm4JJfRR3RL77klHIt1fyvoW6veo0UFmmjnBE0gck+i8fxq2rd44U40PHlylpJTqIFg
         +L6uKhgtV6nQN6+xT9aOPjVaCGAp/jC3uuTmzJ4x6M5L8PFe1TRJ2Dg9yYZ8tyYsO4mz
         WffynzmJeO020XEI+EyeM/h1PfhhEpTI0MK5P2rjMCAKJbRMywzH8bFyVmkubOP7fvDa
         Bwyw==
X-Google-Smtp-Source: APXvYqzyvqZLIxg67pxkdxLJpTK/51NalCRn7KTGd70dRGh3NJlFIdRe+Ue6E9oqJ+ciSF87NclM4A==
X-Received: by 2002:a63:b1d:: with SMTP id 29mr67183457pgl.103.1563724705973;
        Sun, 21 Jul 2019 08:58:25 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.34])
        by smtp.gmail.com with ESMTPSA id e17sm27335437pgm.21.2019.07.21.08.58.24
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 21 Jul 2019 08:58:25 -0700 (PDT)
From: Bharath Vedartham <linux.bhar@gmail.com>
To: arnd@arndb.de,
	sivanich@sgi.com,
	gregkh@linuxfoundation.org
Cc: ira.weiny@intel.com,
	jhubbard@nvidia.com,
	jglisse@redhat.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Bharath Vedartham <linux.bhar@gmail.com>
Subject: [PATCH 2/3] sgi-gru: Remove CONFIG_HUGETLB_PAGE ifdef
Date: Sun, 21 Jul 2019 21:28:04 +0530
Message-Id: <1563724685-6540-3-git-send-email-linux.bhar@gmail.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1563724685-6540-1-git-send-email-linux.bhar@gmail.com>
References: <1563724685-6540-1-git-send-email-linux.bhar@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

is_vm_hugetlb_page has checks for whether CONFIG_HUGETLB_PAGE is defined
or not. If CONFIG_HUGETLB_PAGE is not defined is_vm_hugetlb_page will
always return false. There is no need to have an uneccessary
CONFIG_HUGETLB_PAGE check in the code.

Cc: Ira Weiny <ira.weiny@intel.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dimitri Sivanich <sivanich@sgi.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
---
 drivers/misc/sgi-gru/grufault.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/grufault.c
index 61b3447..75108d2 100644
--- a/drivers/misc/sgi-gru/grufault.c
+++ b/drivers/misc/sgi-gru/grufault.c
@@ -180,11 +180,8 @@ static int non_atomic_pte_lookup(struct vm_area_struct *vma,
 {
 	struct page *page;
 
-#ifdef CONFIG_HUGETLB_PAGE
 	*pageshift = is_vm_hugetlb_page(vma) ? HPAGE_SHIFT : PAGE_SHIFT;
-#else
-	*pageshift = PAGE_SHIFT;
-#endif
+
 	if (get_user_pages(vaddr, 1, write ? FOLL_WRITE : 0, &page, NULL) <= 0)
 		return -EFAULT;
 	*paddr = page_to_phys(page);
@@ -238,11 +235,9 @@ static int atomic_pte_lookup(struct vm_area_struct *vma, unsigned long vaddr,
 		return 1;
 
 	*paddr = pte_pfn(pte) << PAGE_SHIFT;
-#ifdef CONFIG_HUGETLB_PAGE
+
 	*pageshift = is_vm_hugetlb_page(vma) ? HPAGE_SHIFT : PAGE_SHIFT;
-#else
-	*pageshift = PAGE_SHIFT;
-#endif
+
 	return 0;
 
 err:
-- 
2.7.4

