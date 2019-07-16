Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54BE8C76192
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 13:26:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C26920693
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 13:26:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SfxbVk9z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C26920693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A1BDD6B0005; Tue, 16 Jul 2019 09:26:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9CB846B0006; Tue, 16 Jul 2019 09:26:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 894DC8E0001; Tue, 16 Jul 2019 09:26:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 519C16B0005
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 09:26:50 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id o6so10175469plk.23
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 06:26:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=vzHJ6zZC4j+G0RNaMkru3klGJtcfV37NNKvE8Og+hcc=;
        b=Nrxnco5rX3SqQ3K2z5bojQrAKYFeXol4hZ52BazKTzpGijEbLtaON8EOtNL1zGC12T
         jKA8fuRo+/2PnyLH+JMCxqmGHy84jE5sC+lmIKZrCtxVacPem9fRiZ9W4xV1Hp15ePBG
         kJZDIq905Q+zthrFTrt6k6qEt87sJ+QEnJ2DxPwwIv9+dLUhmZwHAqFPgEWrI/qqPX9h
         HwB9+pcsTvH4nx07b5pqC6iAWh+5sAkU0J+Rp/r7Wmx8R3GjUpKrOwxb3ccQmGsALs2t
         4DjTgYkGw6tJdolsmiCZXiTVAV0H3PEiMsiCPQmQBhTBwBIhALHm5Cod0nzGG/Out74Q
         ncqg==
X-Gm-Message-State: APjAAAXbxOFfmPFXyvTAjvalhExyCVzVGiVagOv7GlLDkY/+UOmFiFRh
	8BFuAmk9HnIyzB7qiwIl5WYe3G7Ip+15LWMr/WeENZsE5QYfGgKiY/0gUBkV+PWe7YRkxulx3Ov
	tpe9gf6+WxzDaELIp/IakR+/EYPHGVw9fEk/TEci+k1FFUupgV12+BaKhbdywj63FnQ==
X-Received: by 2002:a63:1046:: with SMTP id 6mr34718280pgq.111.1563283609743;
        Tue, 16 Jul 2019 06:26:49 -0700 (PDT)
X-Received: by 2002:a63:1046:: with SMTP id 6mr34718129pgq.111.1563283608395;
        Tue, 16 Jul 2019 06:26:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563283608; cv=none;
        d=google.com; s=arc-20160816;
        b=MYvRq3sx4izrp6Mft3ZEixMvB1Gw4/GQUs3HqPl86nEZGUTcOk9EYZihsrAUVWZckw
         NsQuzGagcBl5+L+yZ4BbMz5W0WzDByEm0s5GosBP3Tnisu8zhtkLYH+nw91HPkm3Dkh6
         BtboETGPZGZHdzY5o35sVFuYGOkXYAXL1NsCx9ApAYB7D3gQvf6Zag0oytKsCZExLU+i
         wCAW8zk0pSA2UoRgg322IptY2T4iftMCAueHJvHGLo3FmvgNoi2ddDBBXsfjulyaL/6z
         Ri2LhvuUCKA6cN/Yk5XoeEK7jVOu32EA4ivufe0yVoQG2NwLlQbljjES97KVx72YuQRf
         I58A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=vzHJ6zZC4j+G0RNaMkru3klGJtcfV37NNKvE8Og+hcc=;
        b=nsQCoWCe7CCutdRQwKnaYsZUioiYu4H8v/i3EpehlYhewE6vhJ9jWUcPPcVr4mulKk
         CdsiTjSXdf07/9rE9sS/I6ib2dOfV3zfTuGRpvwdYrHJnyprHFpnArt+bIucUzWmT5xh
         bSXvFfTz/P11bcJYr6TiVwtpgqS+UHOZ5KhL4fUbov28vo8GCG66bsF5LFaFYqJWvTF6
         5CwQoFxOoIPFzG9Ws2R4cVhniRnl0VZyNJ0HLcD2TfXSYeUFTHgkxjkaUV4Jbn+nD42Z
         O67kJVqe/UZ1qb0PbpAVeR6db57fIw81YrSMGNuV2EEdW0x8U050Lu05MO1lrnFcSEV+
         tIEg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SfxbVk9z;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z25sor10580294pgv.71.2019.07.16.06.26.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jul 2019 06:26:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SfxbVk9z;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=vzHJ6zZC4j+G0RNaMkru3klGJtcfV37NNKvE8Og+hcc=;
        b=SfxbVk9zgVz2Ps0un9Tse4hUUdRf4Prepk2LjLe8DpwR4BEOKi0VTBn5xTg778ccqU
         rTdChq6dKK0X9Rw/Y98Md2IuIVKqlLE0eM/jnTER1i49F+02juTX2RTXM87i5Yu5lnER
         gfVozyJJ0n+ugVPE2FNlkjNrangn//4DjlnFNPraQt6QSB4PgzoFKj3ahJN+Al4Yos/3
         fMsiZ96gCoc2hJ9TJ48WLN2ca5STZiijBBKl915p0l5tQvnYXfP+8CeK6M+sFH3Lr34B
         vXPkppZyoVe2jZMNa0MNHbDJEkFFP8vVdUNd5PB1znbrTihyFqmk6J9cY0wyu/sTaoKi
         AQ0w==
X-Google-Smtp-Source: APXvYqz5OuQb6D2Fp8RCUxssijj+aLGD4V7/ZrKKVKZHGaNlTSTN/MhpzdVUfmVeJIZ7W1vTufjRog==
X-Received: by 2002:a63:9a41:: with SMTP id e1mr34297879pgo.210.1563283608045;
        Tue, 16 Jul 2019 06:26:48 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:bf0:b8c3:8577:bf2f:2])
        by smtp.gmail.com with ESMTPSA id q1sm21472311pfg.84.2019.07.16.06.26.41
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 16 Jul 2019 06:26:47 -0700 (PDT)
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
	linux-kernel@vger.kernel.org
Subject: [PATCH v5 1/2] mm/vmalloc: do not keep unpurged areas in the busy tree
Date: Tue, 16 Jul 2019 21:26:03 +0800
Message-Id: <20190716132604.28289-2-lpf.vector@gmail.com>
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
 mm/vmalloc.c | 52 ++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 44 insertions(+), 8 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 4fa8d84599b0..71d8040a8a0b 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -329,7 +329,6 @@ EXPORT_SYMBOL(vmalloc_to_pfn);
 #define DEBUG_AUGMENT_PROPAGATE_CHECK 0
 #define DEBUG_AUGMENT_LOWEST_MATCH_CHECK 0
 
-#define VM_LAZY_FREE	0x02
 #define VM_VM_AREA	0x04
 
 static DEFINE_SPINLOCK(vmap_area_lock);
@@ -1276,7 +1275,14 @@ static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
 	llist_for_each_entry_safe(va, n_va, valist, purge_list) {
 		unsigned long nr = (va->va_end - va->va_start) >> PAGE_SHIFT;
 
-		__free_vmap_area(va);
+		/*
+		 * Finally insert or merge lazily-freed area. It is
+		 * detached and there is no need to "unlink" it from
+		 * anything.
+		 */
+		merge_or_add_vmap_area(va,
+			&free_vmap_area_root, &free_vmap_area_list);
+
 		atomic_long_sub(nr, &vmap_lazy_nr);
 
 		if (atomic_long_read(&vmap_lazy_nr) < resched_threshold)
@@ -1318,6 +1324,10 @@ static void free_vmap_area_noflush(struct vmap_area *va)
 {
 	unsigned long nr_lazy;
 
+	spin_lock(&vmap_area_lock);
+	unlink_va(va, &vmap_area_root);
+	spin_unlock(&vmap_area_lock);
+
 	nr_lazy = atomic_long_add_return((va->va_end - va->va_start) >>
 				PAGE_SHIFT, &vmap_lazy_nr);
 
@@ -2137,14 +2147,13 @@ struct vm_struct *remove_vm_area(const void *addr)
 
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
@@ -2152,6 +2161,8 @@ struct vm_struct *remove_vm_area(const void *addr)
 
 		return vm;
 	}
+
+	spin_unlock(&vmap_area_lock);
 	return NULL;
 }
 
@@ -3431,6 +3442,22 @@ static void show_numa_info(struct seq_file *m, struct vm_struct *v)
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
@@ -3443,10 +3470,9 @@ static int s_show(struct seq_file *m, void *p)
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
@@ -3482,6 +3508,16 @@ static int s_show(struct seq_file *m, void *p)
 
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

