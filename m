Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D61ECC742B3
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 12:02:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8CD0A216FD
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 12:02:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DPXSuuA3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CD0A216FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2AA4C8E0140; Fri, 12 Jul 2019 08:02:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 25A068E00DB; Fri, 12 Jul 2019 08:02:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 149E88E0140; Fri, 12 Jul 2019 08:02:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D15B18E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 08:02:51 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 145so5414833pfw.16
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 05:02:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1N5T/DvjIbzKu60HNBBXne5dRJa1DkC2KbW+cEgIYvs=;
        b=IoZ1NCxU4Nid3xUGrqRLalUI6rGuliXp6rxC3tnRjnVooMfxjkLs4OqMyn6OYWtFUf
         a/XzSfO0Yz+OiMtgAfbFGvXQJ3Pn+c6HM73G3z8xWV8gJMMrCBaB/XrwWQL/JVcVjdYV
         4JuRR7znEMqUo2bJpz/UO2Oez2NOmj1pYyso4fKTJ1SohuDT121JGtr4DROJ3Ten4Mbq
         iPwaLNsQoG+dzNajWjHDBTBqMKRI3j+bn+Z8gbz/cxLkGTXthyfF8PFw1evGShL1PKBI
         8kJQXbZ4ySIQ8Fap5A0jxvOihCBljxn1m6I1vHHd8lX86HkRN9zK0gf8mD/TRzyOGUzT
         Mnxw==
X-Gm-Message-State: APjAAAXEwOSoveV6O5m5Q19orSIYImEhjicBLSFPdxjryiH21WtG/WZK
	mit3HykKDYpFE3beKJb2CNT+w1JDQ0JMw0KafsHoxz6nkulaIAT1nbSMeOfcIhyGkFa1QRvfxZ8
	0Fw9tO52gq3hT9D10yzy+XYNYbVAm1zMu56ihujmdg3VDy++V2WaIMIv3AZs6SnuTlQ==
X-Received: by 2002:a17:90a:376f:: with SMTP id u102mr11450485pjb.5.1562932971522;
        Fri, 12 Jul 2019 05:02:51 -0700 (PDT)
X-Received: by 2002:a17:90a:376f:: with SMTP id u102mr11450336pjb.5.1562932970200;
        Fri, 12 Jul 2019 05:02:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562932970; cv=none;
        d=google.com; s=arc-20160816;
        b=a7j8Kk/G6ACAJA7xbbu0LmizL6sw89cB3HarGXXEw2tn1+Ia8eTn4qQs16siA86s1x
         zR8rXhftLvpPICRm/6R2cKicyF1sJBu1uHZOrqDEIKQZ8mHRYwDoLpMxejHGiNi4g1M1
         uq8IsaS5GXGVGBIdxNHHncHk8RTQ1WaEGlHVJ9ddLzNKT2jQr18eHh3gdhTdVwSbQxbP
         GTNeIh98pIFx9kUW9WQbIcmVIGbc2CM8G1hO4lsqioYLVrkMoMu/suutbCIjKgdRbQDT
         hCtROMI88n454DgKVKSRLb8322CcEks3w+MTGblW5hLwiN4WBfOc1a1Lw1Z1g7l3eNY5
         +H0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=1N5T/DvjIbzKu60HNBBXne5dRJa1DkC2KbW+cEgIYvs=;
        b=l3FIfO6EAv+IfEeTppuEIluKQxtVNmTS2/yKzgmdFfMAq86u1KtdVo9Xh/+AzYlL+A
         kfDbE71F9zJHoDRTEXYpKOBSbSh/ew8I5QBisIa+N9a+pt4+WB0QLQKKdT6FK92W49k4
         bJRxesVApz4mY4twTEFiT2Ycg/az++ix87c+VodV1u9vRuZn5bhzL5kTHy9KgU4KAnCA
         nCkXcWlq+S0dPjrU9xnYF+iveWEv9e9DKYJpTPF54IqO53PcOD4NkYHzMOKiqaDycziX
         qUQzsRheXF3n82SW301HZnnwNWetuQBjJyJQ5bPf1DyNvNSnlp2R1YhC50i1lNqQ8i1d
         3zHA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DPXSuuA3;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u64sor4566568pfb.68.2019.07.12.05.02.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Jul 2019 05:02:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DPXSuuA3;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=1N5T/DvjIbzKu60HNBBXne5dRJa1DkC2KbW+cEgIYvs=;
        b=DPXSuuA3BhnztMcN3LH2s8P/GhVUIZ+INcZ8vH0qgqibYFB2TDvNG5V4bjJ5hB+roD
         9EpihKRQWeERkyyQXrdjT8wWp/BDewlmTJ3r2t4MmzQW6ocAVC4lZ4JjuB1l4H46FKsa
         JQ4Y1J8oB8D4IZGUTPwPRPc+2tqj4g/+Zl5Wn8c5DGgduv8L++LeAt7lAsekZRaV6gZ1
         IzKQmq6Yl7levcLSBipOot+VObYWOHgI4XgPSfKffhfRYX5cfC07p1ODC/jfobIFbNvS
         oiQYYr5f7Fw66slqU8MghTJuAYpLuSC+ClKCiB1aAR0qazH0j+v+zarzHF7/FQE2yxzp
         z6hQ==
X-Google-Smtp-Source: APXvYqxR3apRKE+bjL/RIafrN09zwtwDK7k4VgH+z+nofeQhrdMlDJRdJAJmgBykSLy7PDtfNCHdgg==
X-Received: by 2002:a65:614a:: with SMTP id o10mr9920097pgv.407.1562932969685;
        Fri, 12 Jul 2019 05:02:49 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:478:b8c3:8577:bf2f:2])
        by smtp.gmail.com with ESMTPSA id a128sm4605496pfb.185.2019.07.12.05.02.43
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 12 Jul 2019 05:02:49 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org
Cc: urezki@gmail.com,
	rpenyaev@suse.de,
	peterz@infradead.org,
	guro@fb.com,
	rick.p.edgecombe@intel.com,
	rppt@linux.ibm.com,
	aryabinin@virtuozzo.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v4 1/2] mm/vmalloc: do not keep unpurged areas in the busy tree
Date: Fri, 12 Jul 2019 20:02:12 +0800
Message-Id: <20190712120213.2825-2-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190712120213.2825-1-lpf.vector@gmail.com>
References: <20190712120213.2825-1-lpf.vector@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>

The busy tree can be quite big, even though the area is freed
or unmapped it still stays there until "purge" logic removes
it.

1) Optimize and reduce the size of "busy" tree by removing a
node from it right away as soon as user triggers free paths.
It is possible to do so, because the allocation is done using
another augmented tree.

The vmalloc test driver shows the difference, for example the
"fix_size_alloc_test" is ~11% better comparing with default
configuration:

sudo ./test_vmalloc.sh performance

<default>
Summary: fix_size_alloc_test loops: 1000000 avg: 993985 usec
Summary: full_fit_alloc_test loops: 1000000 avg: 973554 usec
Summary: long_busy_list_alloc_test loops: 1000000 avg: 12617652 usec
<default>

<this patch>
Summary: fix_size_alloc_test loops: 1000000 avg: 882263 usec
Summary: full_fit_alloc_test loops: 1000000 avg: 973407 usec
Summary: long_busy_list_alloc_test loops: 1000000 avg: 12593929 usec
<this patch>

2) Since the busy tree now contains allocated areas only and does
not interfere with lazily free nodes, introduce the new function
show_purge_info() that dumps "unpurged" areas that is propagated
through "/proc/vmallocinfo".

3) Eliminate VM_LAZY_FREE flag.

Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
---
 mm/vmalloc.c | 51 ++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 42 insertions(+), 9 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 4fa8d84599b0..9eb700a2087b 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -329,7 +329,6 @@ EXPORT_SYMBOL(vmalloc_to_pfn);
 #define DEBUG_AUGMENT_PROPAGATE_CHECK 0
 #define DEBUG_AUGMENT_LOWEST_MATCH_CHECK 0
 
-#define VM_LAZY_FREE	0x02
 #define VM_VM_AREA	0x04
 
 static DEFINE_SPINLOCK(vmap_area_lock);
@@ -541,7 +540,7 @@ link_va(struct vmap_area *va, struct rb_root *root,
 static __always_inline void
 unlink_va(struct vmap_area *va, struct rb_root *root)
 {
-	if (WARN_ON(RB_EMPTY_NODE(&va->rb_node)))
+	if (RB_EMPTY_NODE(&va->rb_node))
 		return;
 
 	if (root == &free_vmap_area_root)
@@ -1167,7 +1166,11 @@ EXPORT_SYMBOL_GPL(unregister_vmap_purge_notifier);
 static void __free_vmap_area(struct vmap_area *va)
 {
 	/*
-	 * Remove from the busy tree/list.
+	 * In most cases VA is not attached to the tree, but there
+	 * are a few exceptions:
+	 *
+	 * - is linked only in case of pcpu, recovery part;
+	 * - if radix_tree_preload gets failed, see new_vmap_block().
 	 */
 	unlink_va(va, &vmap_area_root);
 
@@ -1318,6 +1321,10 @@ static void free_vmap_area_noflush(struct vmap_area *va)
 {
 	unsigned long nr_lazy;
 
+	spin_lock(&vmap_area_lock);
+	unlink_va(va, &vmap_area_root);
+	spin_unlock(&vmap_area_lock);
+
 	nr_lazy = atomic_long_add_return((va->va_end - va->va_start) >>
 				PAGE_SHIFT, &vmap_lazy_nr);
 
@@ -2137,14 +2144,13 @@ struct vm_struct *remove_vm_area(const void *addr)
 
 	might_sleep();
 
-	va = find_vmap_area((unsigned long)addr);
+	spin_lock(&vmap_area_lock);
+	va = __find_vmap_area((unsigned long)addr);
 	if (va && va->flags & VM_VM_AREA) {
 		struct vm_struct *vm = va->vm;
 
-		spin_lock(&vmap_area_lock);
 		va->vm = NULL;
 		va->flags &= ~VM_VM_AREA;
-		va->flags |= VM_LAZY_FREE;
 		spin_unlock(&vmap_area_lock);
 
 		kasan_free_shadow(vm);
@@ -2152,6 +2158,8 @@ struct vm_struct *remove_vm_area(const void *addr)
 
 		return vm;
 	}
+
+	spin_unlock(&vmap_area_lock);
 	return NULL;
 }
 
@@ -3431,6 +3439,22 @@ static void show_numa_info(struct seq_file *m, struct vm_struct *v)
 	}
 }
 
+static void show_purge_info(struct seq_file *m)
+{
+	struct llist_node *head;
+	struct vmap_area *va;
+
+	head = READ_ONCE(vmap_purge_list.first);
+	if (head == NULL)
+		return;
+
+	llist_for_each_entry(va, head, purge_list) {
+		seq_printf(m, "0x%pK-0x%pK %7ld unpurged vm_area\n",
+			(void *)va->va_start, (void *)va->va_end,
+			va->va_end - va->va_start);
+	}
+}
+
 static int s_show(struct seq_file *m, void *p)
 {
 	struct vmap_area *va;
@@ -3443,10 +3467,9 @@ static int s_show(struct seq_file *m, void *p)
 	 * behalf of vmap area is being tear down or vm_map_ram allocation.
 	 */
 	if (!(va->flags & VM_VM_AREA)) {
-		seq_printf(m, "0x%pK-0x%pK %7ld %s\n",
+		seq_printf(m, "0x%pK-0x%pK %7ld vm_map_ram\n",
 			(void *)va->va_start, (void *)va->va_end,
-			va->va_end - va->va_start,
-			va->flags & VM_LAZY_FREE ? "unpurged vm_area" : "vm_map_ram");
+			va->va_end - va->va_start);
 
 		return 0;
 	}
@@ -3482,6 +3505,16 @@ static int s_show(struct seq_file *m, void *p)
 
 	show_numa_info(m, v);
 	seq_putc(m, '\n');
+
+	/*
+	 * As a final step, dump "unpurged" areas. Note,
+	 * that entire "/proc/vmallocinfo" output will not
+	 * be address sorted, because the purge list is not
+	 * sorted.
+	 */
+	if (list_is_last(&va->list, &vmap_area_list))
+		show_purge_info(m);
+
 	return 0;
 }
 
-- 
2.21.0

