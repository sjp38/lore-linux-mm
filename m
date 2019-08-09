Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98EB5C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:05:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F41B2086A
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:05:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F41B2086A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF5926B02B5; Fri,  9 Aug 2019 12:01:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACAF36B02B7; Fri,  9 Aug 2019 12:01:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 969506B02B6; Fri,  9 Aug 2019 12:01:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3A1DC6B02B4
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:46 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id u17so1064204wmd.6
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=OQzlkASdL41mJ8uAMNHhlgNbmMT+SusvOkvsrUed7Fg=;
        b=PtZEdzi5Xm//qJzIzmzePhZio2h2UJ6wnd1bHlKnTS6FFyn2oLEl4/TI31o7Oza8Zi
         n231e1motaUmpqSOT0pilFH8FMhpQwHynEV1Sx9OSvKHzIMcay+7A5dmvhmam/NKJ0NL
         rrgV98eBW69KHGG1MzlihZBPDNUwBxLNs9U8OUKrgCVOJnKGmvXE10ZrmNw60Uwn2i+/
         q4jPa6N5Xf3YJe+Feo85XV+u9I/OHwmRNyEy6ORvGRleFZ6lynzqL7HUaiq8aWAffWXO
         XfenzrstBwM9c41IsEAvt9qgWhni7e/e3DPcE/O+Xb2p+NeHbdu+e9L0IfLdX+qIQBHQ
         sDJg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAU/ViMie8Cuq4+cVOBJJ4sa7QfvwXS8g0XAAeVUOj+fUYXWs90p
	ZHQ7iRG/Wg+q7xq3P2gpMlQyE6wKk9/pgD09DixYokEmsFVMfp/ZM4jctSQnQ3STwQIAhfZYoKk
	C3xyfCv/xket6NdXcIem+qTYDrSXa+3oOIbpj98svb74i1MQbjQUNc0eLCSBIy/U3Zg==
X-Received: by 2002:adf:e887:: with SMTP id d7mr9143859wrm.282.1565366505793;
        Fri, 09 Aug 2019 09:01:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwjgg8rK9Pjx12zA2/sHgnG+hVsQGQQIFchksgFdTtGMvbkwdruetsTSklHpzSOvlgWzHND
X-Received: by 2002:adf:e887:: with SMTP id d7mr9143714wrm.282.1565366504432;
        Fri, 09 Aug 2019 09:01:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366504; cv=none;
        d=google.com; s=arc-20160816;
        b=AjFmfz+w1Ia3sdTREUWSfh9hvh5PJdNf0P8Fu76OpWTwBHa9DnYe7oUPp/e5kC+y8d
         gxOiKfqdQLrSO1ekZONkikQEkTJSz87DPYDfGBrwH9p7DjQ0ZTRX39zeaFULZrYt/7E+
         5w6dZmODdM2/SqTqDXcCkr8MdF+M3UEw4DYFDQGFTrIu1dEkJba0qJZiAcKJw8kKXl29
         MGMokzPI/ojUUPnXb9P94SW4cUo6twVvhwbcTtmFjaskc9LBoVDEyXP6VEtaSEsF/R0Z
         8c4Kg3fkZII93ttxLDHhJP0SnkA7F/QbWcP9NAItAZJH/8ocGxGqbrTrQRuKT5ZKeC6i
         HYoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=OQzlkASdL41mJ8uAMNHhlgNbmMT+SusvOkvsrUed7Fg=;
        b=RICPj4thWFPQnj7N0Bn/Zlnz05cykoF482gubSk4nRUYU6qePvzuhI6b8gWIa0sLhV
         85ei0Eq1qUE3dsjNTLC/QogIwr+05TKjifsI8lXka0KD0jtLkt3ittniMXho1PqbnDd7
         oavOWdOxA/R8opMhs+KRShkvKDFlOh3Xoyvp1OWn75ehR+U/KVTpsuoiYBOlMQwE2TED
         5azD9VEyajJXbLihqLgAsLVpWO6BMGYcihO9AA9nD5sZkDXAy29kqoOA3OtYB6RDvoRe
         y5iEh47I0LM3vwe6UI5KT4HOZYo6ENehWUo9zhz2yTo3zATry6qhQIX4uQ//3b5hPz8l
         ptuA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id m11si85968131wro.223.2019.08.09.09.01.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id CE4CF305D368;
	Fri,  9 Aug 2019 19:01:43 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 8B2C3305B7A0;
	Fri,  9 Aug 2019 19:01:43 +0300 (EEST)
From: =?UTF-8?q?Adalbert=20Laz=C4=83r?= <alazar@bitdefender.com>
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, virtualization@lists.linux-foundation.org,
	Paolo Bonzini <pbonzini@redhat.com>,
	=?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Tamas K Lengyel <tamas@tklengyel.com>,
	Mathieu Tarral <mathieu.tarral@protonmail.com>,
	=?UTF-8?q?Samuel=20Laur=C3=A9n?= <samuel.lauren@iki.fi>,
	Patrick Colp <patrick.colp@oracle.com>,
	Jan Kiszka <jan.kiszka@siemens.com>,
	Stefan Hajnoczi <stefanha@redhat.com>,
	Weijiang Yang <weijiang.yang@intel.com>, Zhang@kvack.org,
	Yu C <yu.c.zhang@intel.com>,
	=?UTF-8?q?Mihai=20Don=C8=9Bu?= <mdontu@bitdefender.com>,
	=?UTF-8?q?Adalbert=20Laz=C4=83r?= <alazar@bitdefender.com>
Subject: [RFC PATCH v6 89/92] kvm: x86: make lock cmpxchg r, r/m atomic
Date: Fri,  9 Aug 2019 19:00:44 +0300
Message-Id: <20190809160047.8319-90-alazar@bitdefender.com>
In-Reply-To: <20190809160047.8319-1-alazar@bitdefender.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Mihai Donțu <mdontu@bitdefender.com>

The current emulation takes place in two steps: the first does all the
actions that an cmpxchg would do, sets ZF and saves all results in a
temporary storage (the emulation context). It's the second step that
does the actual atomic operation (actually uses cmpxchg). The problem
with this approach is that steps one and two can observe different
values in memory and when that happens RAX and RFLAGS will have invalid
values when returning to the guest as emulator_cmpxchg_emulated() does
not set these.

This patch modifies the prototype of emulator_cmpxchg_emulated() so that
when cmpxchg fails, it returns in *old the current value. We also modify
em_cmpxchg() so that if the LOCK prefix is present we invoke
emulator_cmpxchg_emulated() directly and set RAX and RFLAGS. Note that we
also disable writeback as it is no longer needed.

Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/include/asm/kvm_emulate.h |  2 +-
 arch/x86/kvm/emulate.c             | 57 +++++++++++++++++++++++++++---
 arch/x86/kvm/x86.c                 | 48 ++++++++++++++++++-------
 3 files changed, 89 insertions(+), 18 deletions(-)

diff --git a/arch/x86/include/asm/kvm_emulate.h b/arch/x86/include/asm/kvm_emulate.h
index 97cb592687cb..863c04561a37 100644
--- a/arch/x86/include/asm/kvm_emulate.h
+++ b/arch/x86/include/asm/kvm_emulate.h
@@ -178,7 +178,7 @@ struct x86_emulate_ops {
 	 */
 	int (*cmpxchg_emulated)(struct x86_emulate_ctxt *ctxt,
 				unsigned long addr,
-				const void *old,
+				void *old,
 				const void *new,
 				unsigned int bytes,
 				struct x86_exception *fault);
diff --git a/arch/x86/kvm/emulate.c b/arch/x86/kvm/emulate.c
index 7261b94c6c00..dac4c0ca1ee3 100644
--- a/arch/x86/kvm/emulate.c
+++ b/arch/x86/kvm/emulate.c
@@ -1547,11 +1547,15 @@ static int segmented_cmpxchg(struct x86_emulate_ctxt *ctxt,
 {
 	int rc;
 	ulong linear;
+	unsigned char buf[16];
 
 	rc = linearize(ctxt, addr, size, true, &linear);
 	if (rc != X86EMUL_CONTINUE)
 		return rc;
-	return ctxt->ops->cmpxchg_emulated(ctxt, linear, orig_data, data,
+	if (size > sizeof(buf))
+		return X86EMUL_UNHANDLEABLE;
+	memcpy(buf, orig_data, size);
+	return ctxt->ops->cmpxchg_emulated(ctxt, linear, buf, data,
 					   size, &ctxt->exception);
 }
 
@@ -1803,16 +1807,21 @@ static int __load_segment_descriptor(struct x86_emulate_ctxt *ctxt,
 		/* CS(RPL) <- CPL */
 		selector = (selector & 0xfffc) | cpl;
 		break;
-	case VCPU_SREG_TR:
+	case VCPU_SREG_TR: {
+		struct desc_struct buf;
+
 		if (seg_desc.s || (seg_desc.type != 1 && seg_desc.type != 9))
 			goto exception;
-		old_desc = seg_desc;
+		buf = old_desc = seg_desc;
 		seg_desc.type |= 2; /* busy */
-		ret = ctxt->ops->cmpxchg_emulated(ctxt, desc_addr, &old_desc, &seg_desc,
-						  sizeof(seg_desc), &ctxt->exception);
+		ret = ctxt->ops->cmpxchg_emulated(ctxt, desc_addr, &buf,
+						  &seg_desc,
+						  sizeof(seg_desc),
+						  &ctxt->exception);
 		if (ret != X86EMUL_CONTINUE)
 			return ret;
 		break;
+	}
 	case VCPU_SREG_LDTR:
 		if (seg_desc.s || seg_desc.type != 2)
 			goto exception;
@@ -2384,6 +2393,44 @@ static int em_ret_far_imm(struct x86_emulate_ctxt *ctxt)
 
 static int em_cmpxchg(struct x86_emulate_ctxt *ctxt)
 {
+	if (ctxt->lock_prefix) {
+		int rc;
+		ulong linear;
+		u64 old = reg_read(ctxt, VCPU_REGS_RAX);
+		u64 new = ctxt->src.val64;
+
+		/* disable writeback altogether */
+		ctxt->d &= ~SrcWrite;
+		ctxt->d |= NoWrite;
+
+		rc = linearize(ctxt, ctxt->dst.addr.mem, ctxt->dst.bytes, true,
+			       &linear);
+		if (rc != X86EMUL_CONTINUE)
+			return rc;
+
+		rc = ctxt->ops->cmpxchg_emulated(ctxt, linear, &old, &new,
+						 ctxt->dst.bytes,
+						 &ctxt->exception);
+
+		switch (rc) {
+		case X86EMUL_CONTINUE:
+			ctxt->eflags |= X86_EFLAGS_ZF;
+			break;
+		case X86EMUL_CMPXCHG_FAILED: {
+			u64 mask = BITMAP_LAST_WORD_MASK(ctxt->dst.bytes * 8);
+
+			*reg_write(ctxt, VCPU_REGS_RAX) = old & mask;
+
+			ctxt->eflags &= ~X86_EFLAGS_ZF;
+
+			rc = X86EMUL_CONTINUE;
+			break;
+		}
+		}
+
+		return rc;
+	}
+
 	/* Save real source value, then compare EAX against destination. */
 	ctxt->dst.orig_val = ctxt->dst.val;
 	ctxt->dst.val = reg_read(ctxt, VCPU_REGS_RAX);
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index e09a76179c4b..346ce6c5887b 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -5643,18 +5643,18 @@ static int emulator_write_emulated(struct x86_emulate_ctxt *ctxt,
 }
 
 #define CMPXCHG_TYPE(t, ptr, old, new) \
-	(cmpxchg((t *)(ptr), *(t *)(old), *(t *)(new)) == *(t *)(old))
+	cmpxchg((t *)(ptr), *(t *)(old), *(t *)(new))
 
 #ifdef CONFIG_X86_64
 #  define CMPXCHG64(ptr, old, new) CMPXCHG_TYPE(u64, ptr, old, new)
 #else
 #  define CMPXCHG64(ptr, old, new) \
-	(cmpxchg64((u64 *)(ptr), *(u64 *)(old), *(u64 *)(new)) == *(u64 *)(old))
+	cmpxchg64((u64 *)(ptr), *(u64 *)(old), *(u64 *)(new))
 #endif
 
 static int emulator_cmpxchg_emulated(struct x86_emulate_ctxt *ctxt,
 				     unsigned long addr,
-				     const void *old,
+				     void *old,
 				     const void *new,
 				     unsigned int bytes,
 				     struct x86_exception *exception)
@@ -5663,7 +5663,7 @@ static int emulator_cmpxchg_emulated(struct x86_emulate_ctxt *ctxt,
 	gpa_t gpa;
 	struct page *page;
 	char *kaddr;
-	bool exchanged;
+	bool exchanged = false;
 
 	/* guests cmpxchg8b have to be emulated atomically */
 	if (bytes > 8 || (bytes & (bytes - 1)))
@@ -5688,18 +5688,42 @@ static int emulator_cmpxchg_emulated(struct x86_emulate_ctxt *ctxt,
 	kaddr = kmap_atomic(page);
 	kaddr += offset_in_page(gpa);
 	switch (bytes) {
-	case 1:
-		exchanged = CMPXCHG_TYPE(u8, kaddr, old, new);
+	case 1: {
+		u8 val = CMPXCHG_TYPE(u8, kaddr, old, new);
+
+		if (*((u8 *)old) == val)
+			exchanged = true;
+		else
+			*((u8 *)old) = val;
 		break;
-	case 2:
-		exchanged = CMPXCHG_TYPE(u16, kaddr, old, new);
+	}
+	case 2: {
+		u16 val = CMPXCHG_TYPE(u16, kaddr, old, new);
+
+		if (*((u16 *)old) == val)
+			exchanged = true;
+		else
+			*((u16 *)old) = val;
 		break;
-	case 4:
-		exchanged = CMPXCHG_TYPE(u32, kaddr, old, new);
+	}
+	case 4: {
+		u32 val = CMPXCHG_TYPE(u32, kaddr, old, new);
+
+		if (*((u32 *)old) == val)
+			exchanged = true;
+		else
+			*((u32 *)old) = val;
 		break;
-	case 8:
-		exchanged = CMPXCHG64(kaddr, old, new);
+	}
+	case 8: {
+		u64 val = CMPXCHG64(kaddr, old, new);
+
+		if (*((u64 *)old) == val)
+			exchanged = true;
+		else
+			*((u64 *)old) = val;
 		break;
+	}
 	default:
 		BUG();
 	}

