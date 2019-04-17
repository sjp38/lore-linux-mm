Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,UNWANTED_LANGUAGE_BODY,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5637C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 14:02:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8FDE0206BA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 14:02:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=zytor.com header.i=@zytor.com header.b="YkN6uuUR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8FDE0206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=zytor.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F4B76B0005; Wed, 17 Apr 2019 10:02:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3CA656B0006; Wed, 17 Apr 2019 10:02:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 293076B0007; Wed, 17 Apr 2019 10:02:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 07EE46B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 10:02:02 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id v193so2550330itv.9
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 07:02:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-filter:dkim-signature:date:sender:from
         :message-id:cc:reply-to:in-reply-to:references:to:subject
         :git-commit-id:robot-id:robot-unsubscribe:mime-version
         :content-transfer-encoding:content-disposition:precedence;
        bh=tBTT5DJkWl43S2hPiDWbIhsBneWv51Jto2D4cHXtH9s=;
        b=LhC9KvD0UwC7xAdqz8S/wrN1TXTO7MlvVePBDCpmb7KnGvrEGabdOke/uuGkN/K2Oi
         1WesdQqbyIc1Y8+TL+zSoHWePW6T1xaUm28xJhIIhtut8m+VYMRVRhOfNMgFSD26mPXT
         y4KZfcidx5Ebgrq6Xq+y68zUdY4hK6e1d0Ar9o9JE2IppYB/iJWPyGNKCURmkeQ93Kx8
         fflxHh6X1BFdfInjDrMz+RSDUdX8t67Pz+0S+/hpeciYr+OLN/OLhmr5AfQE44hQ/2Jm
         ZTTMdnNo3RVZKqbLtwW80vXkY9P22EXS2wV/PcHuS0dGUzJvB1c5T+negpfKyRLwWeHx
         Osuw==
X-Gm-Message-State: APjAAAXsIhWhKSc3LrwuVO43mROnZcRXnO2vwAYpm6NaBUI5uspVgFQf
	oX/KCG3VbgUNpmKJqFrQY2d/zymVDkfKJgFG/1E8GO0n/1I7vYJ0MPzwKTLaSjtoO626zWJRBQc
	QfGaqXVD2BKFhhLZo47kBvib80yZ8TouB6/Kn/P967YYz37jJLk1kE925s/cpr7hmjA==
X-Received: by 2002:a6b:4e17:: with SMTP id c23mr57506004iob.212.1555509721624;
        Wed, 17 Apr 2019 07:02:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwbEZ3bTrse3QPcyhYoGyCffPAEDUexhm78mQRzK7AbLWco7V67KNozsbSehDFUse+TfH0q
X-Received: by 2002:a6b:4e17:: with SMTP id c23mr57505857iob.212.1555509720104;
        Wed, 17 Apr 2019 07:02:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555509720; cv=none;
        d=google.com; s=arc-20160816;
        b=ujVZfknuu0SCytm0UnY581RLcfD+nGDwnVMpKJD5/iHgaC5UAs4CrB/YTb5DZ5BEVW
         hPHQLmiyrw06PC1iZc18/GWnuHEYoGHeJbPK6TjFekYgmmHWOPeZ1fkv0HkRsK21M45P
         YW39sKXlIyus3tjQqHSZfN82I73YfS2ZgXlBl600xeQ/mT8duaVVcs3ZHVpVrBWIAugV
         rgLQFFGelrz3X2lMlb0MNKHp7VZTG/9fJ4qkeRippu/XVHA1plNxL1BZpljN/ud08tfh
         v5mG5CGFRFey+kF6yzCSXdMKNlRBOSzV4Crj+C4ODeUQN8ZcGbaacU6o7ocqy8RwULoY
         TYew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=precedence:content-disposition:content-transfer-encoding
         :mime-version:robot-unsubscribe:robot-id:git-commit-id:subject:to
         :references:in-reply-to:reply-to:cc:message-id:from:sender:date
         :dkim-signature:dkim-filter;
        bh=tBTT5DJkWl43S2hPiDWbIhsBneWv51Jto2D4cHXtH9s=;
        b=zVwZqb4AiF/hXHvrI1J8ELVRLZC+hC1mRD0VJ3f0kZgxQ1TPUAeTL3c+YXUmwSM/Kr
         EEJ3NtAxIrl5mXuddndsl3h9cLWzuiRBlahCKMdFC5RV9UJP37hgwvdhv2mulwUgc4ZA
         A4ShJalPdIFAX4d524v6EGxsvh15+EH22J4JaBNjc5wFzxPCgvpPC8gFQw8AWLdLQX99
         avQshfJYT02qo/PIe5vFLPOH8N+Otaz0iICX/BkOGe8JCmi6zXqECn6W/+gjWcdv5xqX
         DysksaWyAAvG+yg+9KnAA+NFGO52BWHZG42PBI/QJ90MJwPNlgD7133JxbL9WJs6yfKu
         L/Tg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=neutral (no key) header.i=@zytor.com header.s=2019041743 header.b=YkN6uuUR;
       spf=pass (google.com: domain of tipbot@zytor.com designates 198.137.202.136 as permitted sender) smtp.mailfrom=tipbot@zytor.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=zytor.com
Received: from terminus.zytor.com (terminus.zytor.com. [198.137.202.136])
        by mx.google.com with ESMTPS id m184si1582430itc.131.2019.04.17.07.01.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Apr 2019 07:02:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of tipbot@zytor.com designates 198.137.202.136 as permitted sender) client-ip=198.137.202.136;
Authentication-Results: mx.google.com;
       dkim=neutral (no key) header.i=@zytor.com header.s=2019041743 header.b=YkN6uuUR;
       spf=pass (google.com: domain of tipbot@zytor.com designates 198.137.202.136 as permitted sender) smtp.mailfrom=tipbot@zytor.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=zytor.com
Received: from terminus.zytor.com (localhost [127.0.0.1])
	by terminus.zytor.com (8.15.2/8.15.2) with ESMTPS id x3HE1jts3930777
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NO);
	Wed, 17 Apr 2019 07:01:46 -0700
DKIM-Filter: OpenDKIM Filter v2.11.0 terminus.zytor.com x3HE1jts3930777
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=zytor.com;
	s=2019041743; t=1555509707;
	bh=tBTT5DJkWl43S2hPiDWbIhsBneWv51Jto2D4cHXtH9s=;
	h=Date:From:Cc:Reply-To:In-Reply-To:References:To:Subject:From;
	b=YkN6uuURq2lcXTvYY6umMtK1EjmTQHrZMdG8p/gmBKRXXReqTWRGRHmyvEYh5+DZs
	 UVKoPlPVjRfykkJyFf4p1N4r4+x1dyUM66xrLpYlG0sOBtnohuS2fvtR6D0rJ1JG/k
	 jDWj2nu2ZPWO+5NmXKzHtnb7P7jwOC25DmyvzRVWlfaov5SQ2C2vrdmbmOLBz8c5bu
	 xTbhd6tswjOTDFEvC8TprC7q3it82kL7UhRH/OGIvTimRbKyNaLrra78qU6B/AwPf5
	 uroGrFIu+kW2JSVid6rRDS3gM/E2EGVWhuIfiPcPImO7pzsBQAs96TwqLtePkXhYmy
	 6Zro0QZeLkbPw==
Received: (from tipbot@localhost)
	by terminus.zytor.com (8.15.2/8.15.2/Submit) id x3HE1iNY3930774;
	Wed, 17 Apr 2019 07:01:44 -0700
Date: Wed, 17 Apr 2019 07:01:44 -0700
X-Authentication-Warning: terminus.zytor.com: tipbot set sender to tipbot@zytor.com using -f
From: tip-bot for Qian Cai <tipbot@zytor.com>
Message-ID: <tip-80552f0f7aebdd8deda8ea455292cbfbf462d655@git.kernel.org>
Cc: cai@lca.pw, luto@amacapital.net, mingo@kernel.org,
        linux-kernel@vger.kernel.org, bp@suse.de, vbabka@suse.cz,
        akpm@linux-foundation.org, rientjes@google.com, tglx@linutronix.de,
        linux-mm@kvack.org, hpa@zytor.com, iamjoonsoo.kim@lge.com,
        jpoimboe@redhat.com, cl@linux.com, penberg@kernel.org
Reply-To: iamjoonsoo.kim@lge.com, hpa@zytor.com, tglx@linutronix.de,
        linux-mm@kvack.org, penberg@kernel.org, cl@linux.com,
        jpoimboe@redhat.com, vbabka@suse.cz, luto@amacapital.net,
        mingo@kernel.org, linux-kernel@vger.kernel.org, bp@suse.de, cai@lca.pw,
        rientjes@google.com, akpm@linux-foundation.org
In-Reply-To: <20190416142258.18694-1-cai@lca.pw>
References: <20190416142258.18694-1-cai@lca.pw>
To: linux-tip-commits@vger.kernel.org
Subject: [tip:x86/irq] mm/slab: Remove store_stackinfo()
Git-Commit-ID: 80552f0f7aebdd8deda8ea455292cbfbf462d655
X-Mailer: tip-git-log-daemon
Robot-ID: <tip-bot.git.kernel.org>
Robot-Unsubscribe: Contact <mailto:hpa@kernel.org> to get blacklisted from
 these emails
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Commit-ID:  80552f0f7aebdd8deda8ea455292cbfbf462d655
Gitweb:     https://git.kernel.org/tip/80552f0f7aebdd8deda8ea455292cbfbf462d655
Author:     Qian Cai <cai@lca.pw>
AuthorDate: Tue, 16 Apr 2019 10:22:57 -0400
Committer:  Borislav Petkov <bp@suse.de>
CommitDate: Wed, 17 Apr 2019 11:46:27 +0200

mm/slab: Remove store_stackinfo()

store_stackinfo() does not seem used in actual SLAB debugging.
Potentially, it could be added to check_poison_obj() to provide more
information but this seems like an overkill due to the declining
popularity of SLAB, so just remove it instead.

Signed-off-by: Qian Cai <cai@lca.pw>
Signed-off-by: Borislav Petkov <bp@suse.de>
Acked-by: Thomas Gleixner <tglx@linutronix.de>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: rientjes@google.com
Cc: sean.j.christopherson@intel.com
Link: https://lkml.kernel.org/r/20190416142258.18694-1-cai@lca.pw
---
 mm/slab.c | 48 ++++++------------------------------------------
 1 file changed, 6 insertions(+), 42 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 47a380a486ee..e79ef28396e2 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1467,53 +1467,17 @@ static bool is_debug_pagealloc_cache(struct kmem_cache *cachep)
 }
 
 #ifdef CONFIG_DEBUG_PAGEALLOC
-static void store_stackinfo(struct kmem_cache *cachep, unsigned long *addr,
-			    unsigned long caller)
-{
-	int size = cachep->object_size;
-
-	addr = (unsigned long *)&((char *)addr)[obj_offset(cachep)];
-
-	if (size < 5 * sizeof(unsigned long))
-		return;
-
-	*addr++ = 0x12345678;
-	*addr++ = caller;
-	*addr++ = smp_processor_id();
-	size -= 3 * sizeof(unsigned long);
-	{
-		unsigned long *sptr = &caller;
-		unsigned long svalue;
-
-		while (!kstack_end(sptr)) {
-			svalue = *sptr++;
-			if (kernel_text_address(svalue)) {
-				*addr++ = svalue;
-				size -= sizeof(unsigned long);
-				if (size <= sizeof(unsigned long))
-					break;
-			}
-		}
-
-	}
-	*addr++ = 0x87654321;
-}
-
-static void slab_kernel_map(struct kmem_cache *cachep, void *objp,
-				int map, unsigned long caller)
+static void slab_kernel_map(struct kmem_cache *cachep, void *objp, int map)
 {
 	if (!is_debug_pagealloc_cache(cachep))
 		return;
 
-	if (caller)
-		store_stackinfo(cachep, objp, caller);
-
 	kernel_map_pages(virt_to_page(objp), cachep->size / PAGE_SIZE, map);
 }
 
 #else
 static inline void slab_kernel_map(struct kmem_cache *cachep, void *objp,
-				int map, unsigned long caller) {}
+				int map) {}
 
 #endif
 
@@ -1661,7 +1625,7 @@ static void slab_destroy_debugcheck(struct kmem_cache *cachep,
 
 		if (cachep->flags & SLAB_POISON) {
 			check_poison_obj(cachep, objp);
-			slab_kernel_map(cachep, objp, 1, 0);
+			slab_kernel_map(cachep, objp, 1);
 		}
 		if (cachep->flags & SLAB_RED_ZONE) {
 			if (*dbg_redzone1(cachep, objp) != RED_INACTIVE)
@@ -2434,7 +2398,7 @@ static void cache_init_objs_debug(struct kmem_cache *cachep, struct page *page)
 		/* need to poison the objs? */
 		if (cachep->flags & SLAB_POISON) {
 			poison_obj(cachep, objp, POISON_FREE);
-			slab_kernel_map(cachep, objp, 0, 0);
+			slab_kernel_map(cachep, objp, 0);
 		}
 	}
 #endif
@@ -2813,7 +2777,7 @@ static void *cache_free_debugcheck(struct kmem_cache *cachep, void *objp,
 
 	if (cachep->flags & SLAB_POISON) {
 		poison_obj(cachep, objp, POISON_FREE);
-		slab_kernel_map(cachep, objp, 0, caller);
+		slab_kernel_map(cachep, objp, 0);
 	}
 	return objp;
 }
@@ -3077,7 +3041,7 @@ static void *cache_alloc_debugcheck_after(struct kmem_cache *cachep,
 		return objp;
 	if (cachep->flags & SLAB_POISON) {
 		check_poison_obj(cachep, objp);
-		slab_kernel_map(cachep, objp, 1, 0);
+		slab_kernel_map(cachep, objp, 1);
 		poison_obj(cachep, objp, POISON_INUSE);
 	}
 	if (cachep->flags & SLAB_STORE_USER)

