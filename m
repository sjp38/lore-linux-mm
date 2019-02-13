Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7F68C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 21:46:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 958D7222C9
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 21:46:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="nmSN7x4f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 958D7222C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 298A48E0002; Wed, 13 Feb 2019 16:46:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 21E4C8E0001; Wed, 13 Feb 2019 16:46:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E8EF8E0002; Wed, 13 Feb 2019 16:46:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id D76528E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 16:46:12 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id h6so4968092itk.9
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 13:46:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=FNhxP8JN/aOogF64x1RdI276bG+FvUjSYc/h3hGis10=;
        b=Nxh/OmmbFfyuq42CnvgC7/ZHxK6koGAHv5DQi+Y90Z7VRp9OPlvjeupwPkmarcKZ7E
         xIraUr20DL9BiCuPILFAsERagJBZrvBECk2qEXh5G2yFBcxaeWJruoZ8NpFnnvk96WEX
         sVZoyAD8onECxN0KuukVNNIJtTxN+ga10xSiySHMn98CocKnDK8Fso6gqgvM7BAfYpda
         Pom6RH4jGrs67zVrNVo0tc2Oc7H27u6obP701CPvYtsLrBMKsyNWtgGJCpeuY4/Fx1+4
         ZKBRybv5H3gADkkl4nXMKghrCdcia5gEGifJ28WM7E+a5ChTnJRNvNm1fd7FAqEnoL2W
         X7Fw==
X-Gm-Message-State: AHQUAua3aTEk0CNcJr2sxnkururdX0HG6qDLfk5aOeJ2Y31THEkVamj7
	ZufqQhaCpL6IGQ8M4vIfryU28S7k0XYQ8UW2/xtbOEe8YnHYIPVRA5Hz3uxif/JQ14g9CKtJMo/
	ICyS1p1ySgIbuLjFaWTcpnUuHKVf5ViJEHqpHoxbFiIfcST9KtQITAY15QZ0fDqKHv2bDAwO5fT
	bO3zmiyBnSf2au3Bo1AiuLtZKYTu7sLDB8ghVK+ANtygAR4yuoS39jXMjJznhhPlRplI9bB8ReY
	QLx3u92vd95KBhzLFZtkH36jaWrjuZzO8TAWBDRTQRP/kKG+qrPp/jj3lhBV3qjgRFCBCp+/Uk6
	WXRoUbNnonBX74b6iAD8OehLk6SPOJsaoQ83xF9NL4TYx3Fu2du2YpoT/g2NXN3/nLdcuiXvDlt
	6
X-Received: by 2002:a02:946e:: with SMTP id a101mr223930jai.90.1550094372615;
        Wed, 13 Feb 2019 13:46:12 -0800 (PST)
X-Received: by 2002:a02:946e:: with SMTP id a101mr223871jai.90.1550094371445;
        Wed, 13 Feb 2019 13:46:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550094371; cv=none;
        d=google.com; s=arc-20160816;
        b=jQ16D1BFtRTDnxM9AVoLIZR2Tl8HpEr79muLMO8uJxPC5gN+32Yhg+pM1b/wAxKpV0
         rZRM9Tv4ezAph3fZr+jVWtYbt3CP7cIUJ0grAiPnUDAG/yjGXMbfdTuEVVFJ71X8BuK2
         DczAafGKkltd9I4sMjTKKuE/N4H2MIym54h6d7jmXl17ClrQ5jKyy7I8kOW68IMZKrRg
         rxNBo02Ny6WoOVFMvd6abLggt5brdnpemQ81l/WkylLRQcWO0bCjoDRqqZLTIluQ24kF
         zgnb724BLH2W41gLP+zF89KjyI5o9Ku4rtjV1Pv0vP5lDDCS3Hzvh2Q8BKd4h8xZz14g
         s5Vw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=FNhxP8JN/aOogF64x1RdI276bG+FvUjSYc/h3hGis10=;
        b=WD+hGr8R9rrGJLGDM8ktCe8fhMPBlg8OsiW0YwAcgeSPyqbepnuVJcL5O85wXPHzjc
         PoPy1FZRDYCESPIaOUcjgNjucKdJfX780CO0e8qvLWa0Hvz1UQ8DlME18DBLNcpD+sza
         pQkdnt6ZNNZhNEHBKO8WjCb3Op9e7V75+2N02b1Q/90GsuXBgrFqJca5bRQRjhEY8k1a
         EGsKqeRa75S23dTTOAhbMBHIyeYnx0Hv6nyz/Rwx3cRLVBoqC48o6hZ1yolwgqwa7LH7
         SjQGm3/t+b35U6Ovx2wND4JK5Snewzhimaovbw1Epi5uF7R/I03re9f7sc3TDp/GS7wL
         Xgmg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=nmSN7x4f;
       spf=pass (google.com: domain of 3i5bkxaukcl4nerrlksskpi.gsqpmry1-qqozego.svk@flex--jannh.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3I5BkXAUKCL4nerrlksskpi.gsqpmry1-qqozego.svk@flex--jannh.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id t134sor856166ita.12.2019.02.13.13.46.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 13:46:11 -0800 (PST)
Received-SPF: pass (google.com: domain of 3i5bkxaukcl4nerrlksskpi.gsqpmry1-qqozego.svk@flex--jannh.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=nmSN7x4f;
       spf=pass (google.com: domain of 3i5bkxaukcl4nerrlksskpi.gsqpmry1-qqozego.svk@flex--jannh.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3I5BkXAUKCL4nerrlksskpi.gsqpmry1-qqozego.svk@flex--jannh.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=FNhxP8JN/aOogF64x1RdI276bG+FvUjSYc/h3hGis10=;
        b=nmSN7x4f0dFsz2f8CmOy0DSZEVYELcvMbs3qFQceL8JHg4uPw7v3hsrtQFyLw9sE5X
         K3+ltokbjOLnlDMKXcOKKCOxKs5urZWEJmGd7HmcyAcanVs7dh0Hb+XIT6mehoPOHu1z
         c0KH48taiqX05DvKw2KMQDIa+P5Iky7RvtdBpMnRXl1xtahZSCjHg0ryL3QpeEfSNy7n
         1Jxu74dVhDvvJF/jLy64FaZnxTo88JDD7+vqhn4Oqv214x+MzdzUXP6mwVozZrCTCvDX
         VNBrpaIh/tsmsJ0HLMKHyWPFXwtTsDKh39OoHk3xwKBdfASz/7QgvfdSBoToyD1iQi1H
         K9vQ==
X-Google-Smtp-Source: AHgI3IYHqsYwFvWOqst/rKom/+dGsarTpRUx/qbL+/QdEt9tRubhgZrB/16HNXoxImLIXoRQ9XJseh71SA==
X-Received: by 2002:a24:5311:: with SMTP id n17mr187606itb.39.1550094371114;
 Wed, 13 Feb 2019 13:46:11 -0800 (PST)
Date: Wed, 13 Feb 2019 22:45:59 +0100
Message-Id: <20190213214559.125666-1-jannh@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.20.1.791.gb4d0f1c61a-goog
Subject: [RESEND PATCH net] mm: page_alloc: fix ref bias in page_frag_alloc()
 for 1-byte allocs
From: Jann Horn <jannh@google.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, jannh@google.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, 
	Pavel Tatashin <pavel.tatashin@microsoft.com>, Oscar Salvador <osalvador@suse.de>, 
	Mel Gorman <mgorman@techsingularity.net>, Aaron Lu <aaron.lu@intel.com>, 
	Alexander Duyck <alexander.h.duyck@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The basic idea behind ->pagecnt_bias is: If we pre-allocate the maximum
number of references that we might need to create in the fastpath later,
the bump-allocation fastpath only has to modify the non-atomic bias value
that tracks the number of extra references we hold instead of the atomic
refcount. The maximum number of allocations we can serve (under the
assumption that no allocation is made with size 0) is nc->size, so that's
the bias used.

However, even when all memory in the allocation has been given away, a
reference to the page is still held; and in the `offset < 0` slowpath, the
page may be reused if everyone else has dropped their references.
This means that the necessary number of references is actually
`nc->size+1`.

Luckily, from a quick grep, it looks like the only path that can call
page_frag_alloc(fragsz=1) is TAP with the IFF_NAPI_FRAGS flag, which
requires CAP_NET_ADMIN in the init namespace and is only intended to be
used for kernel testing and fuzzing.

To test for this issue, put a `WARN_ON(page_ref_count(page) == 0)` in the
`offset < 0` path, below the virt_to_page() call, and then repeatedly call
writev() on a TAP device with IFF_TAP|IFF_NO_PI|IFF_NAPI_FRAGS|IFF_NAPI,
with a vector consisting of 15 elements containing 1 byte each.

Signed-off-by: Jann Horn <jannh@google.com>
---
Resending to davem at the request of akpm.

 mm/page_alloc.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 35fdde041f5c..46285d28e43b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4675,11 +4675,11 @@ void *page_frag_alloc(struct page_frag_cache *nc,
 		/* Even if we own the page, we do not use atomic_set().
 		 * This would break get_page_unless_zero() users.
 		 */
-		page_ref_add(page, size - 1);
+		page_ref_add(page, size);
 
 		/* reset page count bias and offset to start of new frag */
 		nc->pfmemalloc = page_is_pfmemalloc(page);
-		nc->pagecnt_bias = size;
+		nc->pagecnt_bias = size + 1;
 		nc->offset = size;
 	}
 
@@ -4695,10 +4695,10 @@ void *page_frag_alloc(struct page_frag_cache *nc,
 		size = nc->size;
 #endif
 		/* OK, page count is 0, we can safely set it */
-		set_page_count(page, size);
+		set_page_count(page, size + 1);
 
 		/* reset page count bias and offset to start of new frag */
-		nc->pagecnt_bias = size;
+		nc->pagecnt_bias = size + 1;
 		offset = size - fragsz;
 	}
 
-- 
2.20.1.791.gb4d0f1c61a-goog

