Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF8ABC10F00
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:03:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A06E62184C
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:03:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Q2zq7sZo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A06E62184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AAF8F6B0266; Wed, 27 Mar 2019 14:03:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A41426B0269; Wed, 27 Mar 2019 14:03:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 815786B026A; Wed, 27 Mar 2019 14:03:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4A1E16B0266
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:03:11 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id x5so4806122pll.2
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:03:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=HxZQCMfQMuUqXY9wAy0wjCaaLxZqg540IGKWFOCtCIg=;
        b=f84A2DgFqCWyvx/Wi0J8afgpNgwoYGQyYxwjaBY0PwhdUFi60Osu+IoTmis98K0cbT
         rC/ZHEvaf2oG9SRWH+Y7daRMLOEdK35eYGScvBncEJ+PZ7pBtpmwzqbbM1v/cyWebZyz
         TaSlaXegZwT5wBQ4q9VV/909KYgvTH6c07UMFI2YuIn6mPVUC5uqRfgz+B8XfGjNUrN1
         34lBFmiuwwFVVgJnlC6xtc5VJ2H8xS1z2g0YrXYpSn2fcIzWQ65hQPmI70wyNbGWN1fR
         0uff2iQirTjoCpB7TdwnVz+9y6T4LeGrSCo/0YOGE9AzdGHeG1VqYqj6ITCxLryM5swk
         zo1g==
X-Gm-Message-State: APjAAAXt3e9RMKmRGYXrkmG7cfS81RwBYdoR9oUfECujg0BgSz6WabFa
	R1YCTrzkA5pgvCCddcbo5ZQdwggJtbyHrDFQwH5XpNfVR1oVn369uo/j9w9norhEHv/9Sgy3DNj
	I7SghBB2y4c9xhM0My86fEaA3X8K8KI0sXpVHC6beqfaGlyii+EeAVexbjwYpAK3Jsg==
X-Received: by 2002:a17:902:1a9:: with SMTP id b38mr38250485plb.37.1553709790965;
        Wed, 27 Mar 2019 11:03:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHJ3UhQhpU07ZHbnfOeUNbJmhRXgk14gKTPUL6yjMxs6wuPTptEgTko4RkC76l0/GAXFmu
X-Received: by 2002:a17:902:1a9:: with SMTP id b38mr38250423plb.37.1553709790289;
        Wed, 27 Mar 2019 11:03:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553709790; cv=none;
        d=google.com; s=arc-20160816;
        b=ABPnuwCHDMnXT85wHK37uc6DVHWJwiKmDy+X2HsSxDkxWq8QC9Yb2haeJO0SFQzmTi
         Qx/HCpHzV3pgWlYtj8burChsN9cT35hcAN8Lw4PX5EiPEKuwTpHZIv7OnNgNdr3O8KCR
         J8+OBuoW+p9eKWgAsuBqsVmZXhXIsOsQGRNlZd0NdvfuRJSpjTv9BAYT1y1+SUPTfmj2
         cr7oZQOOi/XsQ4FGtVfK8BHs/+pltn7uDFZHv9aWzHp8EPVYfW7D7n1MMV/JVjwqHooy
         lqjO/bMM59OnNEJx+hfmdccz04x7o8uJ0DhFiasKVMrpCI0lClAEUPiaZGUbm1TOye3A
         Z4mw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=HxZQCMfQMuUqXY9wAy0wjCaaLxZqg540IGKWFOCtCIg=;
        b=tK0m7uW3rfcQqfw38Q6oV0FnXWEnnk90NFQ4EnooQ6GBg74qlxwt+CSvhNr3X4cPz+
         WnGjSIetjhOzRBjsG8DSwNlSwiwv7UT29BvNMhB1YsQ34MQ2vArd0dbxeuI4G5pI4MBQ
         5PSATsPpSm1ZqLF4RWiM12dCBMqzk7umWuouA4Wd8Yh8SvQC15192nDOVZuQT/0WyNJD
         0Ch41ozpJ3CeJomRe7cD8dya0giBk+mvS7bJlF2H4XQQBRikUqccjf+AhJ2IxBIWGSHN
         IKfztpUDlMkXk8EVBLSa5hKfOCpt4DT0EluIRbYCikDliL1I84oBrDo9p9FBOqbMx2PY
         Sq+g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Q2zq7sZo;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m2si19534517pgn.481.2019.03.27.11.03.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:03:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Q2zq7sZo;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5488821738;
	Wed, 27 Mar 2019 18:03:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553709790;
	bh=VcSMi5SB+nqATDrzE4hHwpKxihfdy2+RbrKYIW5+tgA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=Q2zq7sZo+ckE2vgUwf/aehALzfjSzL0AvyErXKlTJZVQYqy7v2vjvgv5v5IKIjYkO
	 jBwMe2x8l8Gd+DGgw2s9pbAltoLlPVKkEy+CwTr2h/lvbD9PJ9yxO1LS1oRVGgjRSP
	 sitfc4bL+JhzGD86V5zGtORL05ohI4M9W/zOhSK0=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: "Uladzislau Rezki (Sony)" <urezki@gmail.com>,
	Ingo Molnar <mingo@elte.hu>,
	Joel Fernandes <joelaf@google.com>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@suse.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Tejun Heo <tj@kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.0 038/262] mm/vmalloc.c: fix kernel BUG at mm/vmalloc.c:512!
Date: Wed, 27 Mar 2019 13:58:13 -0400
Message-Id: <20190327180158.10245-38-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190327180158.10245-1-sashal@kernel.org>
References: <20190327180158.10245-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>

[ Upstream commit afd07389d3f4933c7f7817a92fb5e053d59a3182 ]

One of the vmalloc stress test case triggers the kernel BUG():

  <snip>
  [60.562151] ------------[ cut here ]------------
  [60.562154] kernel BUG at mm/vmalloc.c:512!
  [60.562206] invalid opcode: 0000 [#1] PREEMPT SMP PTI
  [60.562247] CPU: 0 PID: 430 Comm: vmalloc_test/0 Not tainted 4.20.0+ #161
  [60.562293] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
  [60.562351] RIP: 0010:alloc_vmap_area+0x36f/0x390
  <snip>

it can happen due to big align request resulting in overflowing of
calculated address, i.e.  it becomes 0 after ALIGN()'s fixup.

Fix it by checking if calculated address is within vstart/vend range.

Link: http://lkml.kernel.org/r/20190124115648.9433-2-urezki@gmail.com
Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Joel Fernandes <joelaf@google.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Thomas Garnier <thgarnie@google.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/vmalloc.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 2cd24186ba84..583630bf247d 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -498,7 +498,11 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	}
 
 found:
-	if (addr + size > vend)
+	/*
+	 * Check also calculated address against the vstart,
+	 * because it can be 0 because of big align request.
+	 */
+	if (addr + size > vend || addr < vstart)
 		goto overflow;
 
 	va->va_start = addr;
-- 
2.19.1

