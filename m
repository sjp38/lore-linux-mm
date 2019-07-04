Return-Path: <SRS0=d6aY=VB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59DBFC0651F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 13:31:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1208F21850
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 13:31:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="d4pTzOKM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1208F21850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B48E46B0006; Thu,  4 Jul 2019 09:31:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AFA198E0003; Thu,  4 Jul 2019 09:31:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9EA298E0001; Thu,  4 Jul 2019 09:31:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 69B7D6B0006
	for <linux-mm@kvack.org>; Thu,  4 Jul 2019 09:31:09 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id j22so3689183pfe.11
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 06:31:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=UPUePBpwAZp2cAxUnqaMmjnaAF2A22YwwKy9LFV95Jg=;
        b=Z62PRLcK0myQblveSZsnCTZbPBjV72CtgMWrLqVe+0nH1z9S5VoBf7tl8hv9Ow/J/n
         Rl0UNeAkRN7v6JMgA4fcYyMvA3vyR+V/iOtXscqS+8BSnRq/R10j7vgASwg2wQ3ncZWc
         fRnZst1QjCzaOkf5pNfBoiutsGPlWGskAeYcq0Drca/G0JOUB6jmP5Xsv1ZbXq9d/kR4
         AvD1LoiVhbQ/8qNkE70Doj3fsTs2/xehHz/hVggeWnCCTm20OeHs4Ssk08uPRpKbAgOu
         5FLK/NxLSQv5+uuPPpEowlLPeSrlHTVFoxehSwmr3w10ksjjPm0etoQN5BTWhQNSOZ0y
         ZKRg==
X-Gm-Message-State: APjAAAVx1kiTtBW6/zzgrkQStZZbJhVeaY751+o07sX+R21vfruaPm/X
	w2Ak5HeLneeAyDkI7pIVjg+4xW8TdENPrWX22Z1NyjA6QAD4PQdwONsJ42hP0clYJu/p00v3sFN
	Pr4O7WIJ2GR5G+DnQT3RRkny/q7PMqRbzoLE/YrDpi+3Wo0ICqGjCpurnycuIzXmobA==
X-Received: by 2002:a17:902:2ac1:: with SMTP id j59mr49833337plb.156.1562247069004;
        Thu, 04 Jul 2019 06:31:09 -0700 (PDT)
X-Received: by 2002:a17:902:2ac1:: with SMTP id j59mr49833257plb.156.1562247068060;
        Thu, 04 Jul 2019 06:31:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562247068; cv=none;
        d=google.com; s=arc-20160816;
        b=AaBu++lrOlMaMJznzjSg9NXXHm9h+ztrG7Aje0Jrg1gD8NbQeLsF4A2VdjbEx939Jp
         2M7GuONJ7JUwK7goalo8Sgi6KY+Kz0RNqNd4KmJVmOAekgwdcUb7/8ZmS87mHufnC89+
         uUl8HViUyACoIkh1KakoUOJF418+ijC1VKB8GFnnPcD3edKxaQmqGOWuw4PUOu3NGCjW
         zCvetmD/fymsX+EvTOSVUYneUG4RwqUsm9vj0NlRiKtdLVH8CUQ5314oaa3UraIGINKW
         Fv3KSxKc/hAzIy5C0j97DBtHoPV7GQt2x4Jx02H9I6DXBFolAPRAN5wNqpzkueU4isfD
         io0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=UPUePBpwAZp2cAxUnqaMmjnaAF2A22YwwKy9LFV95Jg=;
        b=pdLT15oCFga0sfIxYS+LuhH2gFUcWXQ+4dM6EpBJAcH9gf0FsgXBTs1/2qOhUZZP8C
         VGH430+O/GgzLkiOmUbpi8bKm3yo4QdJcewxH1423XaQN+6QaJEkDp9SGpPLjHY+8lt8
         dlsfHnJJ26tYAj4YpSInwL2hmtgrS9cyG2ub7U+Jfr73jgJYjSAS1MSK/7y1vRUIZCGa
         8hGeTIG4m+45H847ieLpIWci3Wpmqw/z9OSKZZRauAInysxeHRdRk6D2+R3tAMy4FL4D
         kIXVXIMuaj1PQeCUgmdMAndu3hFLBJVcSJGun1RckbBPTQCXtw3zL3QrBWN5DH3m4YUH
         7phg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=d4pTzOKM;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id ck8sor6528983pjb.22.2019.07.04.06.31.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Jul 2019 06:31:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=d4pTzOKM;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=UPUePBpwAZp2cAxUnqaMmjnaAF2A22YwwKy9LFV95Jg=;
        b=d4pTzOKMxcI7GJ0gZ0bcaYKFu8XwSkD0G4UMw0zcHozLflTvaIzr/rg0fqWPWk554y
         adigQ1E21BcxonG+yPmoPhq1nO2n2CSETSICWw6Coia2Z2GLhPeUf+ux3Ea967oxc1aE
         cXhvKHjebC1Set0bEvbxpfkxF7FQYGScd0052nCDDPLfZAvTUxAVLAwOS5xsRqWY9vO9
         E0MsWSQ9pZJE/JxatV2LSl7jlwoP2idjCb8E79Pgbv5G3FDlAyuArktddlR8s8095Ni3
         ZZtJs8Jyi1h3IOHM3tnvxWc9GKAJ9c4nDRKTcUS/eSHtMbuRp1o/jQTTK8eCwPXYn55X
         BA2w==
X-Google-Smtp-Source: APXvYqzs724Q0a+qAL27vJcD3e0B9fxIm2y1EPOSpY/Cw1QM2Y857mW5LJ+lb6UYnPa5TOxnWMRMCQ==
X-Received: by 2002:a17:90a:e397:: with SMTP id b23mr19859656pjz.117.1562247067769;
        Thu, 04 Jul 2019 06:31:07 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:648:b8c3:8577:bf2f:2])
        by smtp.gmail.com with ESMTPSA id h26sm12517367pfq.64.2019.07.04.06.30.59
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 04 Jul 2019 06:31:07 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org,
	peterz@infradead.org,
	urezki@gmail.com
Cc: rpenyaev@suse.de,
	mhocko@suse.com,
	guro@fb.com,
	aryabinin@virtuozzo.com,
	rppt@linux.ibm.com,
	mingo@kernel.org,
	rick.p.edgecombe@intel.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH v3 1/1] Modify struct vmap_area to reduce its size
Date: Thu,  4 Jul 2019 21:30:40 +0800
Message-Id: <20190704133040.5623-2-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190704133040.5623-1-lpf.vector@gmail.com>
References: <20190704133040.5623-1-lpf.vector@gmail.com>
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
It is correct because these three variables are used in different
states.
    A) "subtree_max_size" is only used when vmap_area is in
       "free" tree
    B) "vm" is only used when vmap_area is in "busy" tree
    C) "purge_list" is only used when vmap_area is in
       vmap_purge_list

2) Eliminate "flags".
Since now only one flag VM_VM_AREA is being used, and the same
thing can be done by judging whether "vm" is NULL, then the
"flags" can be eliminated.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
Suggested-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
---
 include/linux/vmalloc.h | 20 +++++++++++++-------
 mm/vmalloc.c            | 24 ++++++++++--------------
 2 files changed, 23 insertions(+), 21 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 51e131245379..2bc04b717600 100644
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
+		struct vm_struct *vm;           /* in "buys" tree */
+		struct llist_node purge_list;   /* in purge list */
+	};
 };
 
 /*
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 948f4e35341b..07c1823d7ea5 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -329,7 +329,6 @@ EXPORT_SYMBOL(vmalloc_to_pfn);
 #define DEBUG_AUGMENT_PROPAGATE_CHECK 0
 #define DEBUG_AUGMENT_LOWEST_MATCH_CHECK 0
 
-#define VM_VM_AREA	0x04
 
 static DEFINE_SPINLOCK(vmap_area_lock);
 /* Export for kexec only */
@@ -1108,7 +1107,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 
 	va->va_start = addr;
 	va->va_end = addr + size;
-	va->flags = 0;
+	va->vm = NULL;
 	insert_vmap_area(va, &vmap_area_root, &vmap_area_list);
 
 	spin_unlock(&vmap_area_lock);
@@ -1912,7 +1911,6 @@ void __init vmalloc_init(void)
 		if (WARN_ON_ONCE(!va))
 			continue;
 
-		va->flags = VM_VM_AREA;
 		va->va_start = (unsigned long)tmp->addr;
 		va->va_end = va->va_start + tmp->size;
 		va->vm = tmp;
@@ -2010,7 +2008,6 @@ static void setup_vmalloc_vm(struct vm_struct *vm, struct vmap_area *va,
 	vm->size = va->va_end - va->va_start;
 	vm->caller = caller;
 	va->vm = vm;
-	va->flags |= VM_VM_AREA;
 	spin_unlock(&vmap_area_lock);
 }
 
@@ -2115,10 +2112,10 @@ struct vm_struct *find_vm_area(const void *addr)
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
@@ -2139,11 +2136,10 @@ struct vm_struct *remove_vm_area(const void *addr)
 
 	spin_lock(&vmap_area_lock);
 	va = __find_vmap_area((unsigned long)addr);
-	if (va && va->flags & VM_VM_AREA) {
+	if (va && va->vm) {
 		struct vm_struct *vm = va->vm;
 
 		va->vm = NULL;
-		va->flags &= ~VM_VM_AREA;
 		spin_unlock(&vmap_area_lock);
 
 		kasan_free_shadow(vm);
@@ -2854,7 +2850,7 @@ long vread(char *buf, char *addr, unsigned long count)
 		if (!count)
 			break;
 
-		if (!(va->flags & VM_VM_AREA))
+		if (!va->vm)
 			continue;
 
 		vm = va->vm;
@@ -2934,7 +2930,7 @@ long vwrite(char *buf, char *addr, unsigned long count)
 		if (!count)
 			break;
 
-		if (!(va->flags & VM_VM_AREA))
+		if (!va->vm)
 			continue;
 
 		vm = va->vm;
@@ -3464,10 +3460,10 @@ static int s_show(struct seq_file *m, void *p)
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

