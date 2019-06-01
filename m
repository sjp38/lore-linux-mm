Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C246C28CC4
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:17:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C900E27227
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:17:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="KEcQjyjM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C900E27227
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 546446B0005; Sat,  1 Jun 2019 09:17:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F66C6B0006; Sat,  1 Jun 2019 09:17:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3BEA16B0007; Sat,  1 Jun 2019 09:17:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0728F6B0005
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:17:20 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id q2so8219193plr.19
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:17:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=h70okURhlvAWEM4NYE0qde9CjEvbbnTnYv0qKego/VI=;
        b=BtKqkCSLYwDTnoN7UG7ohs8YkanFSd3IZW5tJ8V4Lg2QkTOxBMflJpYp61WPTnxr1q
         DUKiO4ZgJP50ury1PB9qY2q3/S/R1cykJ9jdmWGOzJaMNJz6l+uyHxZAsor98JonC+ri
         wJ/3BL8y7420+iK+gOSXksct8OwTJRG+7knko1HVMnnGbi5mRQc55BdBP13byoRUR77D
         UFOTVCX4XKSTvcBn72GMYPWJsRzxrfhtucQknbKFBhYGCMRrr1/urF6o0+ZQgn0lMBzX
         z1ZllJKApcfHKT5EwNsNNVS/HzhntReHMWtgurGpYVAp0i5O9L6OdmZ3nGpHpf4oB6eS
         24gg==
X-Gm-Message-State: APjAAAUc4haHWnV4AmCDVi29tGbSMX1AUKrUpfljpGxIKaAgN5kv71Vm
	FiuvVMjN8GjTo1UvlQndBK6Mrgmg47LO5p+DwyHRMau8uLWXAMQYZLuDU+d3esSvOe5ALLjQ+h/
	+QNLchF58jvqnyt05/VX48e9knGOwR5MEbngg5e9RgpFU4xawrQUgDLkGh6r609fXBg==
X-Received: by 2002:a17:90a:734a:: with SMTP id j10mr16370914pjs.92.1559395039479;
        Sat, 01 Jun 2019 06:17:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxmR9PGnXj2wYpURBG4Ph4dl1bXYR4QTBRR60wH2pmAuB1+juvbyE8JEZVE64rYdnKQVTdp
X-Received: by 2002:a17:90a:734a:: with SMTP id j10mr16370817pjs.92.1559395038611;
        Sat, 01 Jun 2019 06:17:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395038; cv=none;
        d=google.com; s=arc-20160816;
        b=jdzSlsAJAxMSXaCoDpVtFme+hydE4U3Aj59poqW2UwZKYyLgR6VXDtVF9+g2CKcDPd
         4CuFhywt3ZNmxyjKhLlL/6ljAvl+f7oiK+HNJAOcuzMf5B4kxexathffFEihCiIXX4ut
         aHBYLIX8saqbC8xeY0x8pvjAsU+/HE1EMNGrYD8fZUNfdQWN+NUYboM01QhIxEk+butR
         ied0OqbuFJraaNyW0eGc1AqUDbxwBIPymJnuSe02v0bBWlrGRv7SMqlfQmkJPeQy2X4r
         YppjCUBwgyii2PjgCPClvNit+AZIdagMHH9TQlcCYn6XLHvnE458yGzhl/yaNXXCpgCU
         v7Tw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=h70okURhlvAWEM4NYE0qde9CjEvbbnTnYv0qKego/VI=;
        b=oxExErzehaVm1lO5LNlYA9keVDXH3i/MCI3JlS2VMX2UJci7/Z3DyK0Es/ADn0li5Q
         raKtc9d9rjXhL8cys27CBpSbB0j/dCgNH4C//LZNgLT6ipqmay1x/rQNGNPHoyhQXQCN
         4fLA5zL6ZGbI9O4I2jX70FTRWfQgGdUyHP+GvPiKAtcpQIzg86cT8LY8pYp09VnJ8P72
         UofvHsiyy8nFv3fXKCn46LBHN23LtKPEDNKJJIl0d9qfnJ28hkR6mPZYdB8cGr3XZnYu
         /J6+cMrK2AU2i9F3N838bpoPPLzYdBlCLEgMSAMQsOxbSU/BiG9w5L7E6IiSfVUNd+y3
         IdbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=KEcQjyjM;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s1si10094617pgs.62.2019.06.01.06.17.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:17:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=KEcQjyjM;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2B4132725B;
	Sat,  1 Jun 2019 13:17:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395038;
	bh=Jt7V68HZiWXTwbMN1VICdRfxSL5xySYNAxl4eFdrVlE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=KEcQjyjMTafUVkUJtoC2ywncRgBfpBy+Y4++RYRM5Fys7WbR8OXQyHEUS+hUv9WNw
	 Zv2shBFQdclcLt+BGP2rgH6VUry4iM4/Lj+nI9GZHCZ0a4rCOduBsm9NcrrnWFzHev
	 RnLE5w4ovvYcTEvVm268N9MBEO68x9De77dfMfrE=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Mike Rapoport <rppt@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Song Liu <liu.song.a23@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.1 009/186] mm/mprotect.c: fix compilation warning because of unused 'mm' variable
Date: Sat,  1 Jun 2019 09:13:45 -0400
Message-Id: <20190601131653.24205-9-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601131653.24205-1-sashal@kernel.org>
References: <20190601131653.24205-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Mike Rapoport <rppt@linux.ibm.com>

[ Upstream commit 94393c78964c432917014e3a456fa15c3e78f741 ]

Since 0cbe3e26abe0 ("mm: update ptep_modify_prot_start/commit to take
vm_area_struct as arg") the only place that uses the local 'mm' variable
in change_pte_range() is the call to set_pte_at().

Many architectures define set_pte_at() as macro that does not use the 'mm'
parameter, which generates the following compilation warning:

 CC      mm/mprotect.o
mm/mprotect.c: In function 'change_pte_range':
mm/mprotect.c:42:20: warning: unused variable 'mm' [-Wunused-variable]
  struct mm_struct *mm = vma->vm_mm;
                    ^~

Fix it by passing vma->mm to set_pte_at() and dropping the local 'mm'
variable in change_pte_range().

[liu.song.a23@gmail.com: fix missed conversions]
  Link: http://lkml.kernel.org/r/CAPhsuW6wcQgYLHNdBdw6m0YiR4RWsS4XzfpSKU7wBLLeOCTbpw@mail.gmail.comLink: http://lkml.kernel.org/r/1557305432-4940-1-git-send-email-rppt@linux.ibm.com
Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Cc: Song Liu <liu.song.a23@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/mprotect.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index 028c724dcb1ae..ab40f3d04aa37 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -39,7 +39,6 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
 		int dirty_accountable, int prot_numa)
 {
-	struct mm_struct *mm = vma->vm_mm;
 	pte_t *pte, oldpte;
 	spinlock_t *ptl;
 	unsigned long pages = 0;
@@ -136,7 +135,7 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 				newpte = swp_entry_to_pte(entry);
 				if (pte_swp_soft_dirty(oldpte))
 					newpte = pte_swp_mksoft_dirty(newpte);
-				set_pte_at(mm, addr, pte, newpte);
+				set_pte_at(vma->vm_mm, addr, pte, newpte);
 
 				pages++;
 			}
@@ -150,7 +149,7 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 				 */
 				make_device_private_entry_read(&entry);
 				newpte = swp_entry_to_pte(entry);
-				set_pte_at(mm, addr, pte, newpte);
+				set_pte_at(vma->vm_mm, addr, pte, newpte);
 
 				pages++;
 			}
-- 
2.20.1

