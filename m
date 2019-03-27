Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E120BC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:17:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 969DD217F5
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:17:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="aWYbfshX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 969DD217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 686666B028A; Wed, 27 Mar 2019 14:17:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 60CEA6B028C; Wed, 27 Mar 2019 14:17:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 354576B028D; Wed, 27 Mar 2019 14:17:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id D88BD6B028A
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:17:05 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id f6so14594878pgo.15
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:17:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1IwwchPOR/bNwcpmyWgFnh9e7P+wF/IR3W8QUdVjbO0=;
        b=LpIu6IqQVjNZppF+yCHtHvAP/RhWzfOzinuYjrGHZtK9hiqpiOOUWB3qAECblbm+DZ
         3N1E8g64T0V7tlKziw+ILd9n1IL0+EhrdgFcAJEA1Hd6Onf1iHE9IoIZty7GlUyPK1VQ
         PoUc/+UCdarARfV0/l7wZFJp75lonhfOxR5LIa72QG5e9cQzcq26FZpIOZz4pu8f7G2d
         XS3HjClI+IcXFOWbBnzArExfPsfHYem9Lot4AiZpBc1V/ab2V53fiYehzWjneJ8Say5C
         WubTa6gEOFW/9n7jlICI9UXBGEIoN++SdBjHe1medhQn3BTilDOZhrggwWoLMj0eL7z1
         KJPw==
X-Gm-Message-State: APjAAAXZ+JTIZG3vQD2VwXTw24FSKfZ0D0/U1X5U9N2f2FLjvw8uouIN
	PCAYGj3DAb8q0fDDkRVViSrSg3U/IdLJx0x1pDNwsro1OIMpB0Q+Jsj10OttMCqAkm5I+w9tgdW
	6CKxusXdiCh4Pf9xTcE7BwjvychKVf+vK1Nz/rWgkikBTf7zKA0OBJyC7E82LjIea0Q==
X-Received: by 2002:a62:bd17:: with SMTP id a23mr35810771pff.233.1553710625549;
        Wed, 27 Mar 2019 11:17:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxFTJt3DI15fDVMTjwAjk6fsApfJDZp+KW1jzFfHIT2Uz1cG+bRYyzJ3K7vE0RFi8qR70uH
X-Received: by 2002:a62:bd17:: with SMTP id a23mr35810701pff.233.1553710624676;
        Wed, 27 Mar 2019 11:17:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553710624; cv=none;
        d=google.com; s=arc-20160816;
        b=Tp6WEoI0I2D/Rn0/Xr8srxWW10/NIATQbpaMIuhohaELJNBSFtf6a5vrNUwp1Ne6ST
         fef0n9u8znCAyP/XPmMxH+iOYxmKU1bmghTHap2SlWvwU8NsH/x9ejcmTi/s20J8ZUrC
         nfU2uwegmpr5RSS8USQJQLjb/ovxyBr4fn8wXuhByo5wbHjg0h05eYFXIwL7abXJuo4x
         ldrnJtRE8e8A1VaRhUxWj3C8HPmAhEv5GHEyMPgiJJP7I0pFpSMomRGfHNiW8GmreV2f
         D6bmkal0z8tgKmrmEPfkOnLHRmUf/8T2tRnmCkmSyyRaC8sm1vW5Sdqvtpgd7qTHv/i7
         ydNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=1IwwchPOR/bNwcpmyWgFnh9e7P+wF/IR3W8QUdVjbO0=;
        b=QwiCdkZIPA2F7SRClOOQC9GsSDH3H19dOsqioC03lmjnRLUxlbGDaYKpd2GZozhKhu
         FNcBr56WVg1oQESjJxwQzK/bA2/9XUkHzjK67Hwi+ANxVeyel8Ypi3y48j9IQL5YEDjS
         2r/xR98DFsTV+B+ecz/Nm+bJHiRg8J58uO1ePUclu1N+c6fkOWlB6JtR1Gi8ZJ/wgtWo
         CqTKeDc2eyprxtNMSJNNPfEOwEZZLjIBty97MUuivcXUu19w7QHGBcAXAc2IhoxReQ1/
         MaTCHmlbEWPHRpQ7ww/BuJpP1bNcpNge1K9DhoUqy19YTztuproiP+8SgIz+xRBKrkyE
         eTow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=aWYbfshX;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e7si6276800pls.411.2019.03.27.11.17.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:17:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=aWYbfshX;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id AE81D2087C;
	Wed, 27 Mar 2019 18:17:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553710624;
	bh=TNUjCTpnpukH81AkiRMAYJj5+/rsne7FaSX8E7sYNXk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=aWYbfshXVJKN127ra7VIBcXSo6Ns9u9BUnrspqHQCUNUPr/DyZsHyghVGCkeOlQNk
	 kHonFIeH/Kbh7cbLm7XWVUjYnuO/0HW3iyFTMo8yS0amkNWkaM42V6I5Ybm1Ze/b5e
	 Oa48Dw1/aeAfp9ZRy7c3wzOY8pZBasi5vV7H+6kM=
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
Subject: [PATCH AUTOSEL 4.14 018/123] mm/vmalloc.c: fix kernel BUG at mm/vmalloc.c:512!
Date: Wed, 27 Mar 2019 14:14:42 -0400
Message-Id: <20190327181628.15899-18-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190327181628.15899-1-sashal@kernel.org>
References: <20190327181628.15899-1-sashal@kernel.org>
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
index 8d9f636d0c98..6c906f6f16cc 100644
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

