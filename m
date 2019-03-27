Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56E9EC10F00
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:25:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C1F62184D
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:25:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="NkTQ9ddm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C1F62184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B134C6B0293; Wed, 27 Mar 2019 14:25:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A74326B0294; Wed, 27 Mar 2019 14:25:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 917636B0296; Wed, 27 Mar 2019 14:25:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 559886B0293
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:25:32 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id y17so4846277plr.15
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:25:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=uWM7evQ3a1hwNJX/fZ/gCAE6Osr0amPulsyHVtISRb4=;
        b=aYllJPmjLA2/bEJYp8aN4X/eOBEzBs/8uLEdSv7m4SrXEYFseDWAL2so7mVBciVRF2
         BzgMzgs54WV8CysxZ7Z7h6okelZuTq8aMXf0fcL9tuRKfNUnpkBm3glRxmB8R6dP4/Ym
         6wFUF4ogukeT82utijR+ok113YLoq5ZMsDw6At5DanKeP5H9zFwlMcSkyPuOs4K3gg3a
         UEWLCfcs6MC6WdXLxKcdVxHYOheT4XulZaLxkS2nN4xFAut1lu2FVjCGWX+rkMXKDatQ
         QkWkZn9Q4GMUPFKWBbpSeWsuHBBaaDJq1J4owymolXnjXkr9uDXN8E9urIp6o1ZrUJzT
         dKrg==
X-Gm-Message-State: APjAAAVGUNMHvz0LnWkwkNFG7b/N/jnfe/Cq3c7PHsfdFP6bUKLDNoZw
	kg4+CkfX+JtRoPM3CAFKfFZV51cy4B+CvF8JGdxR8/FE0UUhRCfuayMh9gbqbQQyAzhGXbL4CCe
	vLTErTs/6s6zESQ09QOc559I6xsVeS5A/mwKWPJj6cBOxiMLItzeVm+bdl4qz7OHg+A==
X-Received: by 2002:a63:61d7:: with SMTP id v206mr35256260pgb.349.1553711132007;
        Wed, 27 Mar 2019 11:25:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyDPGWyd8UFY92ornOKvDevEugvjwHT8HSRdIGxyqJCyN62Vi6h4f5XValcgIVC10gKIsn3
X-Received: by 2002:a63:61d7:: with SMTP id v206mr35256218pgb.349.1553711131374;
        Wed, 27 Mar 2019 11:25:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553711131; cv=none;
        d=google.com; s=arc-20160816;
        b=ZP+IRIBfBEjIVdZAq41jup3WVkHdck9L9vRJYW8Pqqb6MTBwRDTD8U6wpQYWLvEK2W
         rETAZFLayOjFSEn5Kjdrbn2KZHoTn6OCGEt+RPZSbPT6UNkf4wIZP2X1e+Ps4QAVDtGH
         7V7ORk9YM/XUB7WK5MKVfFYJjVxT07Tna81BLwyVqQkYVvePn5k87RfeE5GvmuH6Pc4l
         hZv2hRxektsT2ObOdPNo0MhX1A3a8MzGUFOePGJuIQLIt99LE5E/BRykC0ATpW6/PX3B
         vUc0Qrj/ywgO4/DCQMLa4hPTI628+qeKbMJyp2qXBRIMRKhRo0IdHX7VzmGSbcLEaemk
         p1Eg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=uWM7evQ3a1hwNJX/fZ/gCAE6Osr0amPulsyHVtISRb4=;
        b=heboGGPlKG2gQTt96pvyhRx1JP+O4UG3w1E4RDjR4VVT3a2ESseedcuTpWLTn9wtjI
         H8mhcTRoqIWUHmUTCpKPkPIl7XQZeaukg0TYtoibXc/0lOSHGKugBASUNBFVTkYk1DTh
         F2BuI64Cu30fPv5UxcakiA5yZEZsGzLOlB75/xQ3wk4UFId4Mqbc3c2/ncmGqc3dwXvk
         V2lTQ6VBiO+4COOpz7qj+Qjex5HIC/jM8c4T87RQ1xdWp0Uuk37AVV/C64Vmsvm8XqyQ
         +YUKUFKkIaUJLc21Jno9I5erxUIIH5S8NJ99uKtrI1rMEcBtQ/rvFqjhHKbhYl+jehtr
         NRzg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=NkTQ9ddm;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 61si20708035plr.153.2019.03.27.11.25.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:25:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=NkTQ9ddm;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 63A1A21738;
	Wed, 27 Mar 2019 18:25:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553711131;
	bh=UdBjZ8FK8o9ttQtzfeuKa6sc1MsTVRfzZ9QH1B+By9M=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=NkTQ9ddm/vvjKKk7JDjYmExa2QY0h/Hbdhu4AjaxJ/qwTMP1qkyX858sQm8n9CTT2
	 1u2IlxoU3Dk6qIVdNXlmJN23NaYv4PoOwlmvA7vlJaeFsADFnTaUeA0Hzdy6KGYEdU
	 xvcga3GFMtf5TwcNqVsESXz9bXACYU2K0oI4M8oY=
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
Subject: [PATCH AUTOSEL 3.18 05/41] mm/vmalloc.c: fix kernel BUG at mm/vmalloc.c:512!
Date: Wed, 27 Mar 2019 14:24:42 -0400
Message-Id: <20190327182518.19394-5-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190327182518.19394-1-sashal@kernel.org>
References: <20190327182518.19394-1-sashal@kernel.org>
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
index 33920fc41d6b..fbb00e0d4c56 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -439,7 +439,11 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
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

