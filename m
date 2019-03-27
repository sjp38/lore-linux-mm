Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1515FC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:11:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE336217D9
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:11:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="vVHdg0rV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE336217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DDEC16B027C; Wed, 27 Mar 2019 14:11:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D67A16B027E; Wed, 27 Mar 2019 14:11:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C2DD16B027F; Wed, 27 Mar 2019 14:11:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7D6656B027C
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:11:18 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id o61so4813811pld.21
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:11:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Z3Yx1mRHwOX7BR5EWdnccd6ZcyxqvKC5e7ZzwIZ5aYk=;
        b=UyT6smWN1CAVfhcapF43kxN6bGxKKFO1dcH4UyEDLR7YxnMFst9SWVNy6GBazbEjKZ
         36ewhnhdH+7zKHX3pV0XL59U9gow4lIEAPVGlTcfhJZ85jMUkEDGnu6xX2v28gxc+594
         ZBoe7ZmTpbVmPyn64/sSVBHevh5LgwqmAcVAh2ZaAg6cGrcY6l5Oe6aP6TLrTJBo4JC/
         LTb0tmjrvkvurRMupXPrszHGHVaFZwKtkgavRhJo2vP935OcFP5en2aOO/bggupti4J8
         5riBAPPUoCbBD63ZDY/pIcv4eGASyBnUH9wfhcoLWldshbdlZBodVO4QybwroYJq5fMV
         R/bg==
X-Gm-Message-State: APjAAAXQR2LqO0/SxyYbFsmYy0YvD3bexwh46Zb6hSPuvJqayZvNKH4g
	AZ02+qbQH/Nj1I2Jyp6+AWfhM3WwK7/ybosJb9Fnu9VNeIzp+/0TuDud/KDu9ye1KX9xt4Xg4Av
	w8xxGlFD8WA+oWZK24Pq/Mx/7iM+xXM9+G+7bDjf0OojRax5SaFVr+qMT+CbrRPEZtQ==
X-Received: by 2002:aa7:85cc:: with SMTP id z12mr36596430pfn.142.1553710278179;
        Wed, 27 Mar 2019 11:11:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzkL3cx6BT50KGpyYfvwCJZsLsp8GLv1dq0rE4OofsjASZRTpetHGigIwKCb0ZidIYNkX2E
X-Received: by 2002:aa7:85cc:: with SMTP id z12mr36596372pfn.142.1553710277481;
        Wed, 27 Mar 2019 11:11:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553710277; cv=none;
        d=google.com; s=arc-20160816;
        b=TH2c9456U8If3a18RBdaK8LLBw+4D8AEXMHsM9Fqb3zvtWpa+MbDSm3KRyNGAW6nNg
         svDe25O+LTeEt2OuAEOGX52zSLAKVOSA5QO2uS3DQwH2nVVPLFb5KEKJvWmb24+sOQ2o
         WIk6JoXx7amrpVj3Wy7bGqWvMdFj1bmBYCIPZ/tjwgpyO2TgWe0VY75HXNfVMNSwCgps
         BXmgQODMJD1doScSUL07OiILZasTDs076Nwrg6DaPQ82/hS8MXWCtz+0xgt2f+Cd5zCR
         i8Z//Gv6qVZFGg7F0Os5aJIHXNnn+cecbmkVmGBH/8wEyPGWhzaoJWsvSZnsSesOMm+q
         E3IA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Z3Yx1mRHwOX7BR5EWdnccd6ZcyxqvKC5e7ZzwIZ5aYk=;
        b=vdRbJ0CygFYVcXtM7Ol25MYQP+qCPud8fy9qdwrQmhUVKLd0SUJKK8G0QWbRuelJAs
         kgOpOcWEzb2AZcQR/OHXMSFm2hE67HSxQ8XWC0i5ER0AsTGt6U54yNiUtfqXWNYOyw5S
         IOOlCY+SvOPRTjyvPevasGbhS2O/AjAlQg25RjIba9ex7AsduX8aXloKefGLhKfISgsg
         0dfJljhV1hPsVXBnjfBnxGEe2ecW7zJgmJ5p+uUKeegu7FNNzHNrExZDeO2n2mCAPkoT
         H7L4oqmrd/klwLraevlX49ozmIoNAhafzIU53V+9kmsW1TrBVaY4WnBT+sBgwazpV2nw
         wxZg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=vVHdg0rV;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w21si6171890pgj.513.2019.03.27.11.11.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:11:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=vVHdg0rV;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8DB472177E;
	Wed, 27 Mar 2019 18:11:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553710277;
	bh=K7yYPLFx3amT6R6Xjhn3baqyYjcaDBPufusH8XHJqtk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=vVHdg0rVq8eNju3G6S7KkSfeUe/MBwAnCfm6Sc3ctN/nqju+cAVtImfiOFFmnOle0
	 RsPT0WGNQ3GL2gMQj6Q3AkIo7U7mvwC6V5PnORKsfXd9jzWPko8R2ahpvKaB3a9M7b
	 TPJ3cyx1EmPLYNbV4sTt/NpELlEhuYCF8l8ESWDU=
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
Subject: [PATCH AUTOSEL 4.19 028/192] mm/vmalloc.c: fix kernel BUG at mm/vmalloc.c:512!
Date: Wed, 27 Mar 2019 14:07:40 -0400
Message-Id: <20190327181025.13507-28-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190327181025.13507-1-sashal@kernel.org>
References: <20190327181025.13507-1-sashal@kernel.org>
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
index 91a789a46b12..a46ec261a44e 100644
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

