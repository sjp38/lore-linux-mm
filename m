Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C66BAC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 12:53:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8486B2075C
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 12:53:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="FaiH8DNH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8486B2075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 56AA48E00FA; Fri, 22 Feb 2019 07:53:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A2848E00D4; Fri, 22 Feb 2019 07:53:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 234898E00FA; Fri, 22 Feb 2019 07:53:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id BBD658E00D4
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 07:53:37 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id j7so956711wrs.20
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 04:53:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=PKTXMuuFJ0ycWRkeXV5y91b1obeaiELoxpNU31S68XA=;
        b=Pgokf7fYe7g0b+avDn0r9/XgOMH4Nf5iXDollmI+UtRnyVeVxpELNSu9zNNG5x2vcY
         ifC8bYevAXvuCPW96CXXC9RPDMOjVghg9iJ1matffFJppVZmA+ZInbJOAQohiLljr80s
         7iEW+7UzamK1EpbpcpJ5ONUw9VUPW+OBvY83gWsbVguDwAfdpjbERNoOFYv380ksb2Id
         CqBAYXwJW2IuEYflpqSE0ufyN7GpOUM6TyWqSXk2W2Ogtyi9k0ZOdbq5txCgU824S+bu
         LveZPu8Dw2JiLf2rJz9von4BNltv8vS4xYGhIkG4gSEaHsZ1Zc64cjZbM5hGZOpq3/9g
         E1zg==
X-Gm-Message-State: AHQUAuaQhCQeCwC/qTUyZp+pvV9y4cssgDsCe7bhnvUb3hVPCM9G5HP9
	honISdIC1PaeSUnWyxydUU8NNchTABs189QW7YDrqDViNHNNETzIWCIJYIM9EObnWW5jmE6FSka
	u6n9h0A3cMYK1Ngh2QGmskecL/98y8gae+3WAVsjs2SX0pRpa9lPS4HQaAj0kLKi06Bb160lqfP
	a2lWdh13XbfRCUlA/mavx9WHmPkNwgEu/XA5tltFseOMfQWtZfaMkbvFwVt8X3IwSPbcNv/RHez
	/pcrx6GdzoZnN78gobQy1etAeNc/SJeuA8nN0K5AwUL5RFu01BbhJubc0CvV4qdglVnevW248Aw
	bOusi/s0b9IDJGqgulUpnYJDWZK39ya/ZzpdpxfOz7tkzu+C0fmN1rlyGTsx114MljEOCYV2TBa
	P
X-Received: by 2002:a7b:c04f:: with SMTP id u15mr2319647wmc.49.1550840017283;
        Fri, 22 Feb 2019 04:53:37 -0800 (PST)
X-Received: by 2002:a7b:c04f:: with SMTP id u15mr2319615wmc.49.1550840016442;
        Fri, 22 Feb 2019 04:53:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550840016; cv=none;
        d=google.com; s=arc-20160816;
        b=w5xLb8+aTULUcoeNe1CAoTQhhIjPTB7KISvu1legTRhtzBw72tIH3K9DmdqDpcNUrb
         45FbtPe5m4Ey9+V8zmzHU9zG8pAFuDj6INtZpxSw9QJ8X48KFc+dhiIxpXAtEduev5WH
         Yf1EXBkOA3P/RNn9U8bPjUC13lbexrvgTCht7KHAVGpjqs18y80ySO9gI/lqzfEpf96f
         +KH6DeDx1AUir8/ABusl+5DirRoaVcmRKh6reaCfMTp3iDA66hzUORe1wkjBR/D+55YO
         +oo3oleRU33ZyQ8HWnjeunNu+m2N09Ripc/HqMFvmwkWCQl/J9/lqTC23dTxC5At1LIu
         Qn4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=PKTXMuuFJ0ycWRkeXV5y91b1obeaiELoxpNU31S68XA=;
        b=i88jtewBNtMcyOyNgplGHmBy2bE+H53VW/kQkvofY/tZYWO/YjjYCJtmTzIoYn4w0h
         VRiWewsk+MvVMt19w6Fo5I5D2znyqoGWWb5PYbzvTxlW60h8ASOWUgmp54Hp8KTcQ8Ax
         5I3HsMkQxCFB9rFmo3PGNIKu5PJR64IAAF+WD3QQgGzHgvF2hlCgC2KAo0nc0zR+hX03
         V5Vcfy/AWW+7+LlS8ErIuabYgr5gJrhH5ZgW3MH2tpKIswiws2+Ba0WJEaQAf955YgXT
         5OSLSm82ZSjc3xlI3ykr7xvl5Hc03L8L5sFevkxlzyMlll3qAInkf+Sh7XbgLW27qwYY
         TFgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=FaiH8DNH;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f193sor923555wme.9.2019.02.22.04.53.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Feb 2019 04:53:36 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=FaiH8DNH;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=PKTXMuuFJ0ycWRkeXV5y91b1obeaiELoxpNU31S68XA=;
        b=FaiH8DNHehCmj69FkdBo6mXbqqulK/U8NyRCwUPqCoCXisYnu5gQCGM5mMgF2o+r5C
         Q895ILkegF7YVy2vFzwoQsyu3DHKrS7Js60oUmj3EHAuQ3lDC4dMnGfkMJZ62pMapL+k
         xytmFOkCQHvp0gNluVOkEqXFJhXzhLYBgN2pDRZLIp1yIz0MZnbqLpN529eBLDmuCQ7L
         aRGgYK5N5Bf8jKNgpzLn0LgSmAlL7MWKlzzgbhspTRp7qG3c5svcptnL3y0tn8I+xiVR
         fsnSCnDs4Y6Ma8rGFmML1DTnS0qu8iSEQz/qlVoGNtR0rlFccPGC+6s/xVUFiGjh1uzO
         Tj3A==
X-Google-Smtp-Source: AHgI3IaT3TA/4v9Ai1qhl8SBylCTupXNiKIcUjrbtqaeD8Hyvt8HixWPqJY4f8llGtC/USwzdYOlYQ==
X-Received: by 2002:a7b:c115:: with SMTP id w21mr2545389wmi.104.1550840015942;
        Fri, 22 Feb 2019 04:53:35 -0800 (PST)
Received: from andreyknvl0.muc.corp.google.com ([2a00:79e0:15:13:8ce:d7fa:9f4c:492])
        by smtp.gmail.com with ESMTPSA id o14sm808209wrp.34.2019.02.22.04.53.33
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 04:53:34 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
To: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Kate Stewart <kstewart@linuxfoundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Shuah Khan <shuah@kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v10 03/12] lib, arm64: untag user pointers in strn*_user
Date: Fri, 22 Feb 2019 13:53:15 +0100
Message-Id: <dd3921be1d264efda649740a94d38872206de122.1550839937.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.rc0.258.g878e2cd30e-goog
In-Reply-To: <cover.1550839937.git.andreyknvl@google.com>
References: <cover.1550839937.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

strncpy_from_user and strnlen_user accept user addresses as arguments, and
do not go through the same path as copy_from_user and others, so here we
need to handle the case of tagged user addresses separately.

Untag user pointers passed to these functions.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 lib/strncpy_from_user.c | 2 ++
 lib/strnlen_user.c      | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/lib/strncpy_from_user.c b/lib/strncpy_from_user.c
index 58eacd41526c..c6adfad39016 100644
--- a/lib/strncpy_from_user.c
+++ b/lib/strncpy_from_user.c
@@ -106,6 +106,8 @@ long strncpy_from_user(char *dst, const char __user *src, long count)
 	if (unlikely(count <= 0))
 		return 0;
 
+	src = untagged_addr(src);
+
 	max_addr = user_addr_max();
 	src_addr = (unsigned long)src;
 	if (likely(src_addr < max_addr)) {
diff --git a/lib/strnlen_user.c b/lib/strnlen_user.c
index 1c1a1b0e38a5..26a6a2a1a963 100644
--- a/lib/strnlen_user.c
+++ b/lib/strnlen_user.c
@@ -108,6 +108,8 @@ long strnlen_user(const char __user *str, long count)
 	if (unlikely(count <= 0))
 		return 0;
 
+	str = untagged_addr(str);
+
 	max_addr = user_addr_max();
 	src_addr = (unsigned long)str;
 	if (likely(src_addr < max_addr)) {
-- 
2.21.0.rc0.258.g878e2cd30e-goog

