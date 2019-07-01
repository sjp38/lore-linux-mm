Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D80CDC0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 17:31:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F7F221479
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 17:31:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="SYl2HFPL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F7F221479
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2EF2C6B0006; Mon,  1 Jul 2019 13:31:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A0608E0003; Mon,  1 Jul 2019 13:31:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B5E28E0002; Mon,  1 Jul 2019 13:31:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f206.google.com (mail-qk1-f206.google.com [209.85.222.206])
	by kanga.kvack.org (Postfix) with ESMTP id EF0DA6B0006
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 13:31:17 -0400 (EDT)
Received: by mail-qk1-f206.google.com with SMTP id d62so14166602qke.21
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 10:31:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=57FXAe/wgMHkImrRgxBMfz6F69lw3WXfZi6uoGW6nJo=;
        b=SZJXpvjXnviVbTOp5v+LEuj26jqxIj/f87poKM/1nc61PPr5vZ0D7CRDsgMy0xN38T
         VGaxuejdIxfQB6rsVjqLMWsjenCB1GPWG0zRlZv9Dbw7fsDqpcpQyjqUPHcTYj8mRRza
         s1K+P8iuGdyDcNCtKPYlv+vkc7CJuCrS7a5k/zW1QguGXwQSXz0M9Bq4lk6Au1gz9Y4n
         NtAiPrjycz4sCzjGUlQlihCmxHnLTUz6KKIN/blMos1oWhaLOqHPyG8MipqYxDH1aW1o
         3oEjGIPMPT9sNQO5VePeArUpRq+u5TW3/R/du8uLoR1jqUICvvO4Zra1O8lbkR1boZyj
         GsFQ==
X-Gm-Message-State: APjAAAVNaSGFhw5TK2LnVytPX2jJvYxtS4ozvvYQvxBz+ZB2M32r7dy1
	LJv5jr+7mj0FLQf9nfJaBOHd/eaKeXj48L9bKKAMo8PdpTBQFZFYmJLFbnKe/tN2E5Y+TuAEKqw
	p0LetUnyzgh3CD9Tf3HnJL5/OUnt+zcgC30exKPYyvjgtdT7gJXepTKMX/MEay5ezHQ==
X-Received: by 2002:a05:620a:1ee:: with SMTP id x14mr21924596qkn.70.1562002277732;
        Mon, 01 Jul 2019 10:31:17 -0700 (PDT)
X-Received: by 2002:a05:620a:1ee:: with SMTP id x14mr21924542qkn.70.1562002277071;
        Mon, 01 Jul 2019 10:31:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562002277; cv=none;
        d=google.com; s=arc-20160816;
        b=zdvTAmm0Uf1zFlfvG7rp+CSIREexRuHO3RVL+iUgsTXukMhDNUXPyAaRjFr7zBbxSs
         p88Dp8PuHS7ib0RstNLBg73OcSW3OvGK9w1wPlHQRRWmjEHMRPhEdD5UFjHnWJELq643
         UY3hNEAtx3D/YaAlMv2eF5DWkSbgAFNDORJOMJ2NkHUb11ZQA66LY+dLGiSVoTxWsPNE
         CWBktRHuEUvmRvx+HFQBAaznXP+PAYYlggR557266R6iQe78OX/HfmuwzNkBCClocGZs
         qXGcg1Z2ChzY0DqcBRGnxe8o0fpUjCC8Q25hyAENN/IaXL21BIWJL0/66u1EGLYXBa+P
         cgEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=57FXAe/wgMHkImrRgxBMfz6F69lw3WXfZi6uoGW6nJo=;
        b=zXtF3Tn/czDlWumftmpkv9lk2tupUC+gDC9bv4Kc9H643M92rZgrywiDDuxNXaQIN1
         rCq/dsyrNF8qaOfkelC2eH6VNXCmLMR2oHKcjHvwIQibXAzQ6lYM70Knitw6pc6jh7Ph
         IgfTqDPyZCUuquzzAjaLWicwRvGUKUQ1eS39meKKoJEsPqI5RgOMVhTOAthbR0+OLzmC
         qnGQD9vUPMJDiA/QwzCw9U5PEWQL0G3xwW2TyHg9lexrjfiKTxCZzk2DlpdxsWkKC1SV
         wQyrlWGswudgPmAMD9fuy8o7N5U0L3/eNCCcdTmkJn6o2WEfvRbdew6ucxt9mwIl9ebI
         ZAvw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=SYl2HFPL;
       spf=pass (google.com: domain of 3zemaxqokcemmjsw3gzwsxlttlqj.htrqnsz2-rrp0fhp.twl@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3ZEMaXQoKCEMmjsw3gzwsxlttlqj.htrqnsz2-rrp0fhp.twl@flex--henryburns.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id o10sor15160751qte.26.2019.07.01.10.31.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Jul 2019 10:31:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3zemaxqokcemmjsw3gzwsxlttlqj.htrqnsz2-rrp0fhp.twl@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=SYl2HFPL;
       spf=pass (google.com: domain of 3zemaxqokcemmjsw3gzwsxlttlqj.htrqnsz2-rrp0fhp.twl@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3ZEMaXQoKCEMmjsw3gzwsxlttlqj.htrqnsz2-rrp0fhp.twl@flex--henryburns.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=57FXAe/wgMHkImrRgxBMfz6F69lw3WXfZi6uoGW6nJo=;
        b=SYl2HFPLHC4vO1l86HKGG+KsnA3p3ugT/bhNQ/ORJtqVZc8wQfosqv55sqkPjCue2f
         7e+f0w+fwy4nCLJm+aSX0gjcTPTFuslk7RJ2coLvl4tv42WYnQaSVWoyeshxUbGcyoO4
         hhD0T0RPIoAUdBGs62mRr5atpiOg14m1NCtJjHk47BVcRRY/tyaLMM7grU8ZMoLNJZwx
         IcepxW70TRfXeKJAeFoYS7BQzeBLr9pEERYN8p01Y1/ZagLCW5l8l5vOesfkxnJcd8au
         EhxOm/nyih6HRvFbzX+vkO9xWXLQ+vCqk6tmWeWdmKAGMqonEnvKkeksITidwsCJDq9F
         iQEA==
X-Google-Smtp-Source: APXvYqwzE7/6t/styf6kTpX++BJRIsoo5TiY7JuE7+CzfD2WEAoCByH3gCWAWT1gJmZrbbugH9SfdK0LrtM8ZHGQ
X-Received: by 2002:ac8:fbb:: with SMTP id b56mr2584122qtk.324.1562002276640;
 Mon, 01 Jul 2019 10:31:16 -0700 (PDT)
Date: Mon,  1 Jul 2019 10:30:42 -0700
Message-Id: <20190701173042.221453-1-henryburns@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH] mm/z3fold: Fix z3fold_buddy_slots use after free
From: Henry Burns <henryburns@google.com>
To: Vitaly Wool <vitalywool@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Vitaly Vul <vitaly.vul@sony.com>, 
	Mike Rapoport <rppt@linux.vnet.ibm.com>, Xidong Wang <wangxidong_97@163.com>, 
	Shakeel Butt <shakeelb@google.com>, Jonathan Adams <jwadams@google.com>, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, Henry Burns <henryburns@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Running z3fold stress testing with address sanitization
showed zhdr->slots was being used after it was freed.

z3fold_free(z3fold_pool, handle)
  free_handle(handle)
    kmem_cache_free(pool->c_handle, zhdr->slots)
  release_z3fold_page_locked_list(kref)
    __release_z3fold_page(zhdr, true)
      zhdr_to_pool(zhdr)
        slots_to_pool(zhdr->slots)  *BOOM*

Instead we split free_handle into two functions, release_handle()
and free_slots(). We use release_handle() in place of free_handle(),
and use free_slots() to call kmem_cache_free() after
__release_z3fold_page() is done.

Fixes: 7c2b8baa61fe  ("mm/z3fold.c: add structure for buddy handles")
Signed-off-by: Henry Burns <henryburns@google.com>
---
 mm/z3fold.c | 33 ++++++++++++++-------------------
 1 file changed, 14 insertions(+), 19 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index f7993ff778df..e174d1549734 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -213,31 +213,24 @@ static inline struct z3fold_buddy_slots *handle_to_slots(unsigned long handle)
 	return (struct z3fold_buddy_slots *)(handle & ~(SLOTS_ALIGN - 1));
 }
 
-static inline void free_handle(unsigned long handle)
+static inline void release_handle(unsigned long handle)
 {
-	struct z3fold_buddy_slots *slots;
-	int i;
-	bool is_free;
-
 	if (handle & (1 << PAGE_HEADLESS))
 		return;
 
 	WARN_ON(*(unsigned long *)handle == 0);
 	*(unsigned long *)handle = 0;
-	slots = handle_to_slots(handle);
-	is_free = true;
-	for (i = 0; i <= BUDDY_MASK; i++) {
-		if (slots->slot[i]) {
-			is_free = false;
-			break;
-		}
-	}
+}
 
-	if (is_free) {
-		struct z3fold_pool *pool = slots_to_pool(slots);
+/* At this point all of the slots should be empty */
+static inline void free_slots(struct z3fold_buddy_slots *slots)
+{
+	struct z3fold_pool *pool = slots_to_pool(slots);
+	int i;
 
-		kmem_cache_free(pool->c_handle, slots);
-	}
+	for (i = 0; i <= BUDDY_MASK; i++)
+		VM_BUG_ON(slots->slot[i]);
+	kmem_cache_free(pool->c_handle, slots);
 }
 
 static struct dentry *z3fold_do_mount(struct file_system_type *fs_type,
@@ -431,7 +424,8 @@ static inline struct z3fold_pool *zhdr_to_pool(struct z3fold_header *zhdr)
 static void __release_z3fold_page(struct z3fold_header *zhdr, bool locked)
 {
 	struct page *page = virt_to_page(zhdr);
-	struct z3fold_pool *pool = zhdr_to_pool(zhdr);
+	struct z3fold_buddy_slots *slots = zhdr->slots;
+	struct z3fold_pool *pool = slots_to_pool(slots);
 
 	WARN_ON(!list_empty(&zhdr->buddy));
 	set_bit(PAGE_STALE, &page->private);
@@ -442,6 +436,7 @@ static void __release_z3fold_page(struct z3fold_header *zhdr, bool locked)
 	spin_unlock(&pool->lock);
 	if (locked)
 		z3fold_page_unlock(zhdr);
+	free_slots(slots);
 	spin_lock(&pool->stale_lock);
 	list_add(&zhdr->buddy, &pool->stale);
 	queue_work(pool->release_wq, &pool->work);
@@ -1009,7 +1004,7 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 		return;
 	}
 
-	free_handle(handle);
+	release_handle(handle);
 	if (kref_put(&zhdr->refcount, release_z3fold_page_locked_list)) {
 		atomic64_dec(&pool->pages_nr);
 		return;
-- 
2.22.0.410.gd8fdbe21b5-goog

