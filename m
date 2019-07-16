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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72EEBC76188
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 12:05:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D4C921721
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 12:05:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="o/fOET0R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D4C921721
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BDF176B0003; Tue, 16 Jul 2019 08:05:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B8F816B0005; Tue, 16 Jul 2019 08:05:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A7F0C8E0001; Tue, 16 Jul 2019 08:05:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 44B916B0003
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 08:05:30 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id m8so1768388lfl.23
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 05:05:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=IM4QT1Xngs9kyBKOtJG5O0RoRFoqAxD/pjBzsYQqx9U=;
        b=VJ/8I+sWXYmJx+/rD0RSJKLtqQ1otaLgmdashOuiii111RHZjDUWH19QMgHN1ey/Sw
         7RH20mr2hHFM60Vywz/YVABeKAOh4Z7HFpyfzu4o1CTQqud4hy7cV/eWK2pk0pe1/F/B
         IxgikBECJy25C0KrCC+jgMM9XEarf5kNcuMHzsDtUlo3aVv2jeZK2sD5mtwLhuFeb5pn
         jKs8X0xtTdpSeGPBnORNbHFbJqr/kLL2ryCYkkX4L6XuS6fo9GNVTIoDBck1Z2sfw4Pd
         hEL5zra4c8V1eWuTxNNUi0r+1FEqwZzcKKSxaS4jonsVGG0blMrvbFBe3SAqu5SXiY1z
         ye3g==
X-Gm-Message-State: APjAAAUUfiwmDiKi6jeceE7y8+0oecDI/xZxvSMMhvx+ULsY9x0dljC2
	s+u/Yro2+/krHcyYD49RBc+T3l06JA+llvH6BDpPtmUclwWzhmaJkTKtv7zNZrQ2WUhBYjy5sZx
	1wEPyS+Z9XKELsXdFqocg2kGsypU3XWNCFwr1L78dqQ5JDdYziyhVCvB6qFsErWIs8w==
X-Received: by 2002:a19:c887:: with SMTP id y129mr14615635lff.73.1563278729251;
        Tue, 16 Jul 2019 05:05:29 -0700 (PDT)
X-Received: by 2002:a19:c887:: with SMTP id y129mr14615589lff.73.1563278728198;
        Tue, 16 Jul 2019 05:05:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563278728; cv=none;
        d=google.com; s=arc-20160816;
        b=nDu3SZUPnfvT9QDAujRBQFueG3R2GnCRMbqhP24YfGBJvJ5J0nLo6DyVN+CPtpI2Qk
         mo8DP8skGR6Vh8D6dVBGl7MovMNAVGAgJMxrrr653L0OCFCs3aqkqpsK2RgVWkfp9Cct
         mdeespt0Hp2rDECvioJJNI8QeIbYsPP0ODlEP4COF8fN0bOx7tlHDKRBWuDO9sIkkH6r
         MWg6UgfzTh0ujoW0wFbNxkH0SS16UCB7p1J9oFZ3apN0y7P97uQciL5rq3MP34GVmS7H
         dwaCYc/8EIQ06X4QwAm+7ZnCchBL4DWt9rWwTydNhREGjooHtsmiJE90gggilS6/wntQ
         M7fg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=IM4QT1Xngs9kyBKOtJG5O0RoRFoqAxD/pjBzsYQqx9U=;
        b=LaP0udMKTK6G2irPwfGaxq1E8E37N0TZSf++dCfLtEUE4QS5f0rYcXE1EN2ROUAUsd
         Cgwsf8JI20uMuvQwiPpwi57iYWQtIZJWG0YIyBhPiQ4fHHdz47mZurwe5KYwE5tmrSwa
         XozyHD0rtcijQysjXMSIkC/KQ0/CYe0V6AyOiKZvksMhW4YLFa8tcIsYSAsmFk/+/5mY
         xhkoSM3/LG63FJ6o9u3mSyFu4a6Bf7K8v8u7yItF96so+jndpIUK/C/agGE2mtraIKXH
         /cu+NJ7QrJcME2nWo1PoOfa9gIUAEKokMIKdN2SEsyWFYKcrSvgJmKjGmhI3XxTMlM2w
         vEXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="o/fOET0R";
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a22sor5106727lfl.61.2019.07.16.05.05.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jul 2019 05:05:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="o/fOET0R";
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=IM4QT1Xngs9kyBKOtJG5O0RoRFoqAxD/pjBzsYQqx9U=;
        b=o/fOET0RjizpnND00mTrql/ioFq1730YOuiSDU3Jev4noFPbrX8FuzixDifpLib9qn
         JTE96ZG2D1yauwu1k/xP72pDs/rIjC8Y3m6OUxJzzshYC/vL5T4pbTJQQY6iyyeyw28u
         9CGMoh934ABOncl2zdfXpTGNC8S/2mfKNy+dG81gJvRKFacndBhRjET745HQNW24OZRL
         zJL9Qez6LO4NBAwnJsPzPq9J7Aqmi39hXwsoT8oibqZD9V+eU8q8IrOgqD6jHnxRXVIG
         UjwcgGZ6WKap82LxdwR5PvOvw4Ytf996o9skNbDXwCMD8Zd2DU6jF1VMmz/EHgfHLo0o
         3iYw==
X-Google-Smtp-Source: APXvYqzhFNS83alo8YNYqfvdQn3zmSRYYawYWvmFRyUDi/eUzwiHW2Llamiru/wzvN1leVS05P1tEA==
X-Received: by 2002:ac2:514b:: with SMTP id q11mr14799941lfd.33.1563278727704;
        Tue, 16 Jul 2019 05:05:27 -0700 (PDT)
Received: from pc636.semobile.internal ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id t23sm3686410ljd.98.2019.07.16.05.05.26
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 05:05:27 -0700 (PDT)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Uladzislau Rezki <urezki@gmail.com>,
	Pengfei Li <lpf.vector@gmail.com>,
	Hillf Danton <hdanton@sina.com>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH v2 1/1] mm/vmalloc: do not keep unpurged areas in the busy tree
Date: Tue, 16 Jul 2019 14:05:17 +0200
Message-Id: <20190716120517.10305-2-urezki@gmail.com>
X-Mailer: git-send-email 2.11.0
In-Reply-To: <20190716120517.10305-1-urezki@gmail.com>
References: <20190716120517.10305-1-urezki@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

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
index 534d6628924e..e4f3f093484f 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -329,7 +329,6 @@ EXPORT_SYMBOL(vmalloc_to_pfn);
 #define DEBUG_AUGMENT_PROPAGATE_CHECK 0
 #define DEBUG_AUGMENT_LOWEST_MATCH_CHECK 0
 
-#define VM_LAZY_FREE	0x02
 #define VM_VM_AREA	0x04
 
 static DEFINE_SPINLOCK(vmap_area_lock);
@@ -1269,7 +1268,14 @@ static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
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
@@ -1311,6 +1317,10 @@ static void free_vmap_area_noflush(struct vmap_area *va)
 {
 	unsigned long nr_lazy;
 
+	spin_lock(&vmap_area_lock);
+	unlink_va(va, &vmap_area_root);
+	spin_unlock(&vmap_area_lock);
+
 	nr_lazy = atomic_long_add_return((va->va_end - va->va_start) >>
 				PAGE_SHIFT, &vmap_lazy_nr);
 
@@ -2130,14 +2140,13 @@ struct vm_struct *remove_vm_area(const void *addr)
 
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
@@ -2145,6 +2154,8 @@ struct vm_struct *remove_vm_area(const void *addr)
 
 		return vm;
 	}
+
+	spin_unlock(&vmap_area_lock);
 	return NULL;
 }
 
@@ -3432,6 +3443,22 @@ static void show_numa_info(struct seq_file *m, struct vm_struct *v)
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
@@ -3444,10 +3471,9 @@ static int s_show(struct seq_file *m, void *p)
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
@@ -3483,6 +3509,16 @@ static int s_show(struct seq_file *m, void *p)
 
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
2.11.0

