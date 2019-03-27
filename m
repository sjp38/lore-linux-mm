Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD77BC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:21:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A02621738
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:21:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="F1CYIjoy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A02621738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1ED686B0293; Wed, 27 Mar 2019 14:21:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 19E8E6B0294; Wed, 27 Mar 2019 14:21:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0665F6B0295; Wed, 27 Mar 2019 14:21:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id BB2E96B0293
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:21:05 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 73so14575858pga.18
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:21:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=LsyZcMWcLFIiH/+e+8c/BbZp6CJ/Ezs0i8f8RkqPre0=;
        b=CRA1RnNtfNs0tfAd7GhfkfOANLAGDGY8c+L9YDucWmlSLTRgj0DiHEhA2iAWwXPM4s
         851rA4T8jVzpyTKH/1fDemWqhv4DtrIAtnF/+dRkXzM5haB57CSt65DVR/OFNspW8Jyw
         8U5+EDARWItNh/GCEWlyDWWKfnHfloR7mN8O77jMuop0SnkljigFtEHRvYAvg3EB6eUj
         nmio7/YKSzarE6s0R5qQ/m3fLOYdX/NBBK0Bk33c7Seabw3A6KvuMgM/seezoGEEwPiY
         OVOumCeoRFNnbW7jhnDdr4KwVNxgRKP7DJKjQ5G/wYuvKsDOjWrwcTL9EXOllibgXjro
         Sz5g==
X-Gm-Message-State: APjAAAUz4AWYWUUajibN8LUe3bo399YtPIAJ2I+UhMdrvZr0bbcozylp
	hpRZryagn1wdO+OZoPotGI8c4YatwGEiRFqT7KgVrtkyvgReFdQDtVg1ygeZH94q9gpgCMn3FzK
	V6SoL6+knU12JFf9JQ5tb1gWllfvjzSfIQ4WpZ4r1BnOaKjCN+4+6xS5PEnYygv+7Ig==
X-Received: by 2002:a63:d352:: with SMTP id u18mr5869417pgi.315.1553710865418;
        Wed, 27 Mar 2019 11:21:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwJMtB4tJc2DAay/V9Wz0eHnZbUbnnekxEGoB6f0S2mOwOxU2T6mAtNO21g7RBO47ptCjom
X-Received: by 2002:a63:d352:: with SMTP id u18mr5869366pgi.315.1553710864750;
        Wed, 27 Mar 2019 11:21:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553710864; cv=none;
        d=google.com; s=arc-20160816;
        b=UNlZV6OMmWI8E4vQUUo+mft2CMREG3sNEmmdTutiPsPFid62lrnTu2SmROymkc30FR
         fsoPC5B2WwU2GCj3n8EKPLzaN7W8lospR4ru4720X2eu4NoBVe4ZPPceXoyDRIxd0sTZ
         fLgegXIIvN8cezIMjwKj3oCaYPsqYUmARQq0lhlMw+OW+FaUDEe6M7YPdcw8z6P7tdeu
         q7NtEVmrctyLtc8HJu0tgpBBfJ0ESy8VK2iewwbiPlDp5wxWr5h11qNq10uaJvNkTvJ/
         6WqST2GkWnJpBR7zwZzi3VGzdF3A0OtJVTsP2n2W610k3Sflbs2ei2m+9MAAcUoFFeoe
         SL8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=LsyZcMWcLFIiH/+e+8c/BbZp6CJ/Ezs0i8f8RkqPre0=;
        b=chOL6hUYsQVrIUFCo64S7aGYf1ZPweaUhy6WQCRR6qKsdDII2RyvJrmWVjShrEtW6k
         +KPOp3Nax7h9qj0oQrR2spwKA8KTdPRSdKTQ1SDVP6KpmCDJKWSpGrl4J9wozo/9QTmV
         7ogrnLgF95aaxM1bweQblKeIKS90nEJ4jdBhatOoT3X2r4AyNpucK3jPfyU0aFyvAKDj
         j0cMdthF7c8Nb50j5QsxXR4I/cW9d3poz9O7Mks+7/uxveGuSZmD+ajK3OfglLPN6mRj
         BcFAvDrtM+YwsDdSC6toBmk1MbwA6BKiSaqx5KlCurJV4G7GIrTFmBmVNUBMIg3jH+0l
         rB6w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=F1CYIjoy;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x206si17702513pgx.37.2019.03.27.11.21.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:21:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=F1CYIjoy;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C492E20643;
	Wed, 27 Mar 2019 18:21:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553710864;
	bh=KopFzjyqiGzG6wk/FnitGtZe8KmXMgXBUElcH87QTQk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=F1CYIjoy1SpwNNZOEJrSmd/7Rr06sRebaCwL88QQ85Gp28hBFjUyPY3sbmjBnbruU
	 j3963DFxFcz53GRlbkHfs1WuI5RVUo9xnEM+ztHihaVytImB/pzy9YhabaJrdGFrpO
	 qJrQ5xQuIYzK3JN1oR8S2V/w97VjE2zscrMcb9JI=
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
Subject: [PATCH AUTOSEL 4.9 12/87] mm/vmalloc.c: fix kernel BUG at mm/vmalloc.c:512!
Date: Wed, 27 Mar 2019 14:19:25 -0400
Message-Id: <20190327182040.17444-12-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190327182040.17444-1-sashal@kernel.org>
References: <20190327182040.17444-1-sashal@kernel.org>
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
index e6aa073f01df..73afe460caf0 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -459,7 +459,11 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
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

