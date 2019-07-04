Return-Path: <SRS0=d6aY=VB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 952A2C46486
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 15:38:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 63CC121852
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 15:38:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 63CC121852
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E1D116B0006; Thu,  4 Jul 2019 11:38:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA6B38E0003; Thu,  4 Jul 2019 11:38:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C48E48E0001; Thu,  4 Jul 2019 11:38:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8ABD46B0006
	for <linux-mm@kvack.org>; Thu,  4 Jul 2019 11:38:12 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id f9so218081wrq.14
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 08:38:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BxbnvXa/OZizuISJhWJMQ9vb97R6oLvhKSG/1JjS2dk=;
        b=rcp+xE/RRCoy5fdpJlGGoJW+IkFaq2HjSMMbNuIFdqmU4KjzLFUDX515/u3Caj8hdx
         9W8ULDTsdkBVAonbfjV1L0E9jt3ehs/ZfqG6tALUhwH6dWz+/1pf0Xw5DYTYqq3Snn4J
         rI8XJWytUwg1K6KXL8jOqF9oMcQKNXV4L7KQgffbhb1vRbhcJEfPuKmoAO20K0xMF+hY
         MPi03VswgybR1C8AC/VcIeXs8alHToE15yLDP0sBo7cIgtMfCWPgO5iBncnW1hq6aFGd
         1YMlBz8Mk/7QBUDYThyQTmu/Sw41BMFuk9rQjpkrSu2asm922H/XtdWI4SHcJOYJk5c0
         1/KA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
X-Gm-Message-State: APjAAAWC7lY9bDkgAjhUhH74DJFM7PH9NEjCWzNXQReiytSEAYLklphO
	C4OjqRNU0Fz7fUfpLqaPqcG6Ct9HUvkH54nWyCftyVaLRHxRQrwGV84soLHn3g+Y2vZgr5zsMRM
	27HPVHSkrSy5mPlE6UppAV5yG9R1GsbHI1l2u8BSSjwjC0v5qrMroe9ur783U43DTaw==
X-Received: by 2002:a7b:c356:: with SMTP id l22mr113778wmj.97.1562254692137;
        Thu, 04 Jul 2019 08:38:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzcFrukaLbxIRvtkSFhDimdEyW2IvVw+AEqT3l+WqsPIDOs3FWnLPmVmpv+fYam04cjZyKO
X-Received: by 2002:a7b:c356:: with SMTP id l22mr113733wmj.97.1562254691092;
        Thu, 04 Jul 2019 08:38:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562254691; cv=none;
        d=google.com; s=arc-20160816;
        b=vxD81KOado+g9MqIYbul1Z6HdEP39A8KquTdjApqtwxImToI2zdQWu9lOyKi297tOT
         OnX3OOOstbAKmDzZ+GnxLGy4SExEWADjj+JPkaSvqQFMUhnWkhi+nlZxr0nOcT4jIfS3
         w5lHAKAiPnNvUFpYUDj9V05Hxh41+EKTSJW/UKMjR4ThzR9mT0XpEeslV0gR/BAoVvY6
         OFXiSl0+e/yrIzemuiGKfG94cgQX1N1CCAaU9+HdFR7Vx3lEbPOQiQA4Gl563RNHiovI
         jG1Onkzko1EXngsjK52uuC8S4wxVN32KQkuR/XdrEkp6sTWdkWloe16eNf2nMvAC7e2k
         W1Nw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=BxbnvXa/OZizuISJhWJMQ9vb97R6oLvhKSG/1JjS2dk=;
        b=fmLi1QGnLpeGxkZxG9UINuWOdu3TLiuIl87VmVnYEtXsDiS2zwMCbvUc3p2UurL23a
         Yfa3IOE/GB3E2zAZbQXpVTCMwMPO6T0ItQTmfUmK2JNsS/pnUEBNsZX7XGAXt/3+k/mz
         6HXDz+qQGrJIRdpWKGN/jnvRKCCcuW4omziHzn8qHQye1LDRfkcf9Iaoh0urGivjsY0q
         Oj5Q7hpzKmpFl2M05Io2SeFrrFhdSRzYZeLG6YKJMJVNKsKOBbZAbpLsTosc7U5GYA6y
         X/5t11JwQaEgiYOXCN5EM6TBTfOc7ZDYD5SAGpqfuWXxgN9hnfP9kF4HMk6iTZ+QWRWU
         XLZg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a0a:51c0:0:12e:550::1])
        by mx.google.com with ESMTPS id t142si3666600wmt.87.2019.07.04.08.38.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 04 Jul 2019 08:38:11 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) client-ip=2a0a:51c0:0:12e:550::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from localhost ([127.0.0.1] helo=flow.W.breakpoint.cc)
	by Galois.linutronix.de with esmtp (Exim 4.80)
	(envelope-from <bigeasy@linutronix.de>)
	id 1hj3oF-0004wg-Pi; Thu, 04 Jul 2019 17:38:07 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: linux-kernel@vger.kernel.org
Cc: tglx@linutronix.de,
	Peter Zijlstra <peterz@infradead.org>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH 2/7] vmpressure: Use spinlock_t instead of struct spinlock
Date: Thu,  4 Jul 2019 17:37:58 +0200
Message-Id: <20190704153803.12739-3-bigeasy@linutronix.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190704153803.12739-1-bigeasy@linutronix.de>
References: <20190704153803.12739-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

For spinlocks the type spinlock_t should be used instead of "struct
spinlock".

Use spinlock_t for spinlock's definition.

Cc: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 include/linux/vmpressure.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/vmpressure.h b/include/linux/vmpressure.h
index 61e6fddfb26fd..6d28bc433c1cf 100644
--- a/include/linux/vmpressure.h
+++ b/include/linux/vmpressure.h
@@ -17,7 +17,7 @@ struct vmpressure {
 	unsigned long tree_scanned;
 	unsigned long tree_reclaimed;
 	/* The lock is used to keep the scanned/reclaimed above in sync. */
-	struct spinlock sr_lock;
+	spinlock_t sr_lock;
 
 	/* The list of vmpressure_event structs. */
 	struct list_head events;
-- 
2.20.1

