Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30683C76192
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 13:26:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE53D20693
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 13:26:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="R46pC3b7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE53D20693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E30A6B0006; Tue, 16 Jul 2019 09:26:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 894778E0003; Tue, 16 Jul 2019 09:26:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7841E8E0001; Tue, 16 Jul 2019 09:26:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 444516B0006
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 09:26:57 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id u1so12611050pgr.13
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 06:26:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=2FLMt1biejUADnaZS+D7n9SrnPK40F0jXQ5om7TEM0E=;
        b=CHZYnANPe+66BElbLaf10niGrYa+jqV7m86Tf1KiZVlJdXaFZ0NM8L0/LjkZ9nEWFw
         QK4u/NvTeZWSaxlJd7VDToXIo6xCu4vGX6yWuBD1CpkINxNOeJk8AhEU3DHW4u4vnRNJ
         RlYi6rbEkWoMzgq3pQXhOuOUmn++Vqz7kflxKREAOARIkyK4jfIiaNFJAt6HtwC30hdV
         OHYFWQv3op33jEnTrE+NGUDQJtZkpblJCrzupRXnG1zaC6XduQljUG3TVxkufaHjZhGd
         acs7nqzA+nj766IBishfQ+KS94IQjOILPxZb9bkKNegac7NjKiXwPe0dASOO8HVW/GAK
         gJyg==
X-Gm-Message-State: APjAAAXCk3l+WwPXL8RAiUJ1wE3llBR628GMqVzxzPGK2uZ/x3iXpK7D
	aT0AoFAmDmBvD4w+C/HBHTDVrBiLHE2Gz97jWr/n0k4M/Vl6hlVr8KLBWaR6gEDv7dNEGVtV2CX
	9Myq6hiGuYF+Qrh7puIvKxUIMyMvYxo7jvjqoOT2vNYOBcCz5lYBcNxEGGZlmz5qxNQ==
X-Received: by 2002:a17:902:2be8:: with SMTP id l95mr32227775plb.231.1563283616872;
        Tue, 16 Jul 2019 06:26:56 -0700 (PDT)
X-Received: by 2002:a17:902:2be8:: with SMTP id l95mr32227692plb.231.1563283616106;
        Tue, 16 Jul 2019 06:26:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563283616; cv=none;
        d=google.com; s=arc-20160816;
        b=grWVVXGVrzf+ghdpjHfeODFpnL+m38BFExqrdksR6bV72VmvPyXUXQVb3siPTJ8hoS
         UKYbparggwV9JCj17PdfoGrxTwuF70IlfAr/ADI+Xp+A9G3493iLmLBKJeGG39k0Pwg9
         UBoiOuVzxMzBlNxxOSK/tLNRoVe+45P+tu5pZMCd2BBhgv/97XomSQu3NqjCXhdFR/YN
         2+S0zhqudnhoGnGw9uo44iSFq+xi76rfVMlCzmRodQAEhLtY0amFVYZLeO8J1HjVD9Vh
         lz9GQHxhYahe8CZfEtNjCa4JG+BairsIrbEqG61EkG6CuLi9C0xp7OKz2nLjhcYXvKvZ
         H47w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=2FLMt1biejUADnaZS+D7n9SrnPK40F0jXQ5om7TEM0E=;
        b=La9YnIKV7T406ECozfVE8YbGW4ggcDgN9NEItUqvz8j916Uz1COTLtQAblOdExl1xL
         AF29gjYxdHTHJe4f2ZSjxEEdwaL9wRA4kD8oEk6tUfl+6rFScmCFTi0RQ5gnfUScyuw8
         6UlNZDVb9ox7SfdEHTo8v1TsDyTgtIYzFVTdEMaL22c5h0szQ7gdDILf9Wdyyw/x8I4y
         ibGmcE62ogXEjhT+cIfKqOI2maYayXV633o/SQqp8yACoUx/sd+dGtdgfd/8w2Djx3pH
         g8ZI8fRsmAxVLLqUCPql4aLpTLMrSxpbFOtn4TVGnHYiQKbwhJoAKO+fdgcW84xr0uK3
         bNpw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=R46pC3b7;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bc5sor25078703plb.36.2019.07.16.06.26.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jul 2019 06:26:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=R46pC3b7;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=2FLMt1biejUADnaZS+D7n9SrnPK40F0jXQ5om7TEM0E=;
        b=R46pC3b7xctfYiDbpcjsza4HTmNx/760I2ZaF5EDledhg5vHet72yrOirw34e4/Hwj
         a9XoTMetn8gr04TAIhE2LlWxSqPKgOVdS86OM+fcojB7GI2ad77E+i1jpeqKV1+2cEXe
         2cnBZvd8RrCgjlzvvKJMItIGEgUzHUMwqJ08iwCMu+urNd/gsaxKdt4ji6oD/yqJ9OIH
         iA7wIo+ojN1xpialB5aVNj6g/NfG5lUi4MGaFRthczcja3mE2vVQnE/lPC/wRJoliTKR
         cdRyNH5A1gPD9fXBd/AjwTF+98c6JPOq0uOF0Ht1KinYxfj2YU02TOo6Oqg1Dy5trgYY
         UGYg==
X-Google-Smtp-Source: APXvYqwLdB8Cef6LQ3pqCCQ0P7hsVjjgWF54ZHRKloxBfozTuaD/IY5JZ7PR7zFLuVVRnsib5VBBgA==
X-Received: by 2002:a17:902:7448:: with SMTP id e8mr35514887plt.85.1563283615828;
        Tue, 16 Jul 2019 06:26:55 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:bf0:b8c3:8577:bf2f:2])
        by smtp.gmail.com with ESMTPSA id q1sm21472311pfg.84.2019.07.16.06.26.48
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 16 Jul 2019 06:26:55 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org,
	willy@infradead.org
Cc: urezki@gmail.com,
	rpenyaev@suse.de,
	peterz@infradead.org,
	guro@fb.com,
	rick.p.edgecombe@intel.com,
	rppt@linux.ibm.com,
	aryabinin@virtuozzo.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH v5 2/2] mm/vmalloc: modify struct vmap_area to reduce its size
Date: Tue, 16 Jul 2019 21:26:04 +0800
Message-Id: <20190716132604.28289-3-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190716132604.28289-1-lpf.vector@gmail.com>
References: <20190716132604.28289-1-lpf.vector@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Objective
---------
The current implementation of struct vmap_area wasted space.

After applying this commit, sizeof(struct vmap_area) has been
reduced from 11 words to 8 words.

Description
-----------
1) Pack "subtree_max_size", "vm" and "purge_list".
This is no problem because
    A) "subtree_max_size" is only used when vmap_area is in
       "free" tree
    B) "vm" is only used when vmap_area is in "busy" tree
    C) "purge_list" is only used when vmap_area is in
       vmap_purge_list

2) Eliminate "flags".
Since only one flag VM_VM_AREA is being used, and the same
thing can be done by judging whether "vm" is NULL, then the
"flags" can be eliminated.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
Suggested-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
---
 include/linux/vmalloc.h | 20 +++++++++++++-------
 mm/vmalloc.c            | 24 ++++++++++--------------
 2 files changed, 23 insertions(+), 21 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 9b21d0047710..a1334bd18ef1 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -51,15 +51,21 @@ struct vmap_area {
 	unsigned long va_start;
 	unsigned long va_end;
 
-	/*
-	 * Largest available free size in subtree.
-	 */
-	unsigned long subtree_max_size;
-	unsigned long flags;
 	struct rb_node rb_node;         /* address sorted rbtree */
 	struct list_head list;          /* address sorted list */
-	struct llist_node purge_list;    /* "lazy purge" list */
-	struct vm_struct *vm;
+
+	/*
+	 * The following three variables can be packed, because
+	 * a vmap_area object is always one of the three states:
+	 *    1) in "free" tree (root is vmap_area_root)
+	 *    2) in "busy" tree (root is free_vmap_area_root)
+	 *    3) in purge list  (head is vmap_purge_list)
+	 */
+	union {
+		unsigned long subtree_max_size; /* in "free" tree */
+		struct vm_struct *vm;           /* in "busy" tree */
+		struct llist_node purge_list;   /* in purge list */
+	};
 };
 
 /*
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 71d8040a8a0b..39bf9cf4175a 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -329,7 +329,6 @@ EXPORT_SYMBOL(vmalloc_to_pfn);
 #define DEBUG_AUGMENT_PROPAGATE_CHECK 0
 #define DEBUG_AUGMENT_LOWEST_MATCH_CHECK 0
 
-#define VM_VM_AREA	0x04
 
 static DEFINE_SPINLOCK(vmap_area_lock);
 /* Export for kexec only */
@@ -1115,7 +1114,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 
 	va->va_start = addr;
 	va->va_end = addr + size;
-	va->flags = 0;
+	va->vm = NULL;
 	insert_vmap_area(va, &vmap_area_root, &vmap_area_list);
 
 	spin_unlock(&vmap_area_lock);
@@ -1922,7 +1921,6 @@ void __init vmalloc_init(void)
 		if (WARN_ON_ONCE(!va))
 			continue;
 
-		va->flags = VM_VM_AREA;
 		va->va_start = (unsigned long)tmp->addr;
 		va->va_end = va->va_start + tmp->size;
 		va->vm = tmp;
@@ -2020,7 +2018,6 @@ static void setup_vmalloc_vm(struct vm_struct *vm, struct vmap_area *va,
 	vm->size = va->va_end - va->va_start;
 	vm->caller = caller;
 	va->vm = vm;
-	va->flags |= VM_VM_AREA;
 	spin_unlock(&vmap_area_lock);
 }
 
@@ -2125,10 +2122,10 @@ struct vm_struct *find_vm_area(const void *addr)
 	struct vmap_area *va;
 
 	va = find_vmap_area((unsigned long)addr);
-	if (va && va->flags & VM_VM_AREA)
-		return va->vm;
+	if (!va)
+		return NULL;
 
-	return NULL;
+	return va->vm;
 }
 
 /**
@@ -2149,11 +2146,10 @@ struct vm_struct *remove_vm_area(const void *addr)
 
 	spin_lock(&vmap_area_lock);
 	va = __find_vmap_area((unsigned long)addr);
-	if (va && va->flags & VM_VM_AREA) {
+	if (va && va->vm) {
 		struct vm_struct *vm = va->vm;
 
 		va->vm = NULL;
-		va->flags &= ~VM_VM_AREA;
 		spin_unlock(&vmap_area_lock);
 
 		kasan_free_shadow(vm);
@@ -2856,7 +2852,7 @@ long vread(char *buf, char *addr, unsigned long count)
 		if (!count)
 			break;
 
-		if (!(va->flags & VM_VM_AREA))
+		if (!va->vm)
 			continue;
 
 		vm = va->vm;
@@ -2936,7 +2932,7 @@ long vwrite(char *buf, char *addr, unsigned long count)
 		if (!count)
 			break;
 
-		if (!(va->flags & VM_VM_AREA))
+		if (!va->vm)
 			continue;
 
 		vm = va->vm;
@@ -3466,10 +3462,10 @@ static int s_show(struct seq_file *m, void *p)
 	va = list_entry(p, struct vmap_area, list);
 
 	/*
-	 * s_show can encounter race with remove_vm_area, !VM_VM_AREA on
-	 * behalf of vmap area is being tear down or vm_map_ram allocation.
+	 * If !va->vm then this vmap_area object is allocated
+	 * by vm_map_ram.
 	 */
-	if (!(va->flags & VM_VM_AREA)) {
+	if (!va->vm) {
 		seq_printf(m, "0x%pK-0x%pK %7ld vm_map_ram\n",
 			(void *)va->va_start, (void *)va->va_end,
 			va->va_end - va->va_start);
-- 
2.21.0

