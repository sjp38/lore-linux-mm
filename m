Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59CE8C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:23:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0AD432082F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:23:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="fH/hskz0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0AD432082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B13BC6B0294; Wed, 27 Mar 2019 14:23:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC3CD6B0295; Wed, 27 Mar 2019 14:23:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 98CC56B0296; Wed, 27 Mar 2019 14:23:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 73AC66B0294
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:23:44 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id u78so14682496pfa.12
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:23:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=k0Bur+RFDOriM93fTrHLNXQCGKMzhneYekLsU8eqnQo=;
        b=tSZZLVp6131o1ztpmXOaR1HSr4kgxJyWA/i0m+BNydmiSMnHLlHJmagyIO2vkwpFrn
         XHcEWZ9FQtkdIfV53qEhToqFqFfqnKo3cl3AvrouWXlUSva3EuSjIGsNOSilEbgtiZVW
         P+UUGykqL8B5L3lqKOqY6T7v9FVjwYGtNKTmGHXp0kXWEcuiY9U8NsTOod9cLfxPuyic
         +Oec76UUblP457veESOX6YQ3YoHXGlLm/l6TUY/T0j9w3yljIh8XoIAVOBwdcLjq/FoK
         lY5OcQRd5aTnF5rX8dtW8Evux+Ues2y67G/v80hQ+vcI8R/ox2pd9Aou3PItSDVtbMpD
         u/ow==
X-Gm-Message-State: APjAAAWvnynPPe4uG1SpPKT/hWKUwWoUB3E+0sosyhbyD99ViTBKxZr0
	krGiOukNseh9Ux1elJRmeuR/kizlNIFdFwmucpWVB/met/jGY48qAtqRkeTm+BuzSMd4ZP2nM0G
	M4Zkcm/rhEgpcfBvVWWl5vKmdRG679EwSKGdxlBSPRa6pdDfII3w/IDcPUTwPfqInCQ==
X-Received: by 2002:a63:3fc3:: with SMTP id m186mr3523098pga.151.1553711024088;
        Wed, 27 Mar 2019 11:23:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxX0baMvn/B3UP5llIj1Sd0NAfORqIMsxEhrbGncC+L0mfsPNYW8hCJDgtwcU05apoKtSil
X-Received: by 2002:a63:3fc3:: with SMTP id m186mr3523049pga.151.1553711023406;
        Wed, 27 Mar 2019 11:23:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553711023; cv=none;
        d=google.com; s=arc-20160816;
        b=Jtr0H5qFIMnNaG4DD9wMUawUPmjpCN7Me8tEC3fxAKCZt1iyRJovTR2HRsjvMwi1Zr
         RVsiTuneJBhIdFajsNmz2e6dPAAMgCEmUtC0bUgOzlLH1f8tnJLKl7GZssDEmaq/Tco0
         cW9c9WjeXchy43m/gNf6yuIDxt6sE+wsJz5bEXrUDmUz6agU0d2udQ3GnQZvs3lmqscJ
         cKQrEOKHrlEqI7qdsl4AkUoJiwlBh9fAOuZWGU1B3UMhNK5wBymeFtQOMC+ypzYQ7O6P
         +styCfQ3G81LfGindlMuEfMwFcQygetkatWVpPssXHX9uVDqI1l+5BPJ9rDCUay+lOIW
         aGjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=k0Bur+RFDOriM93fTrHLNXQCGKMzhneYekLsU8eqnQo=;
        b=Y/+QujXQw1Hg/C+PYxqqeToSqh1wpMEurBit1diiB3MCj7towONoOPpiCNfZjc+rre
         a1lgG0/b4zUEpPsG+PmKp+Y/Qwe7JTLRyRJwnKfC/Tuu5EUUnD8jz5PEw+MhaAJ3jiQb
         1e3MgwXPZUO5D4pA+5NQ2jU+JRS5rl0AIkrtGwDu/lUKcZk3NkS6v4Gq4Z/VC9nKuaRY
         hun4MZ+4Vn4f1vvy98mJnEMtawEcTpQAYr3etQV+JXRU+wHIGcUtJlAiHwSVjtonjrj1
         HQXlIKlTLo/OmoyuL0t1AJ6An63NvgVwqYMQQXBKlUNsGShdW+fPeytOJoxuLDCcH6vs
         goDw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="fH/hskz0";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q3si2978833pfc.151.2019.03.27.11.23.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:23:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="fH/hskz0";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7172A20449;
	Wed, 27 Mar 2019 18:23:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553711023;
	bh=aLuHvExQ6QTyWDJIUWXZ+lYBzBg1vvbbkmkVE+wGv0c=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=fH/hskz09e1HjX9rkf0ZF9xz6SLnvVHRfPUeELs1iiIfAtsXyRYAwW8yNr4xo8sGN
	 OFDAWZrkGJUDv2/xIYIKK9ayHzHGKSuHPDCscfHKK7ztXy7I1BwRHHDVZDpPZYxTfu
	 nCtge8pQAhLpeDnNGpbXbFhyodghi52JY2HNs0Kk=
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
Subject: [PATCH AUTOSEL 4.4 10/63] mm/vmalloc.c: fix kernel BUG at mm/vmalloc.c:512!
Date: Wed, 27 Mar 2019 14:22:30 -0400
Message-Id: <20190327182323.18577-10-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190327182323.18577-1-sashal@kernel.org>
References: <20190327182323.18577-1-sashal@kernel.org>
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
index 400e580725da..7c556b59f0ec 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -446,7 +446,11 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
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

