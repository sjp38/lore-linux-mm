Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39475C0650E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 15:59:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E20222189E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 15:59:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qWymVMwW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E20222189E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C6E38E0003; Wed,  3 Jul 2019 11:59:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 878998E0001; Wed,  3 Jul 2019 11:59:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7672B8E0003; Wed,  3 Jul 2019 11:59:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 114D18E0001
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 11:59:53 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id d18so219952lfn.11
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 08:59:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=gFrhzCDbKN3dXJqOCjxaWjlxE64lMzIuw0MAKOdMJPo=;
        b=ONsaIN4Rq+H2u181UehMbMz+GCB3NtzaWN5wNhRe7SgpgMw9mPgmxtLUbX6xioPxqd
         csi91RixwInNvUygBRqVfYuQZrG5PquXv4axldwx1g6z2OeYoVXSJbmZ28TTf18jsiIC
         zMxWJ+EmX2Z8GXu6Az9saMeYwG2limNfPmacLiED9jn3nsXZ5+fYE7Io7nVD9HnMiTbQ
         L0wYlkv+dt2uKeExbe84yGrQcjSUP9VAVteHi/HNnVVc0LLuiXBQ7YOCwcxehIPndSSk
         DagpdKs7N7Ac3Y1UgEsFMyzRCpeejxTPteACo08Th/k/yvsLKMjEpugiXg3WPVp6cbGp
         rr4A==
X-Gm-Message-State: APjAAAXIo5bFldkhOCR95jCrxfYhtfQ6TE4ygYfvlTKstlHyBekjXr+5
	XwQgA1exkb68F6FjwYrn/RSx6v4RY4oqS1/ouMCkiTbp4OmmXTiXz+D7S0IXsoRsQC+zGinyipN
	BhRshuQdmCKbS0NHDIX/3kCRXnvt4RkWEIrUncNspsej07S6nEG6j2uPRRXk07a+LPg==
X-Received: by 2002:a2e:3a13:: with SMTP id h19mr21435796lja.220.1562169592159;
        Wed, 03 Jul 2019 08:59:52 -0700 (PDT)
X-Received: by 2002:a2e:3a13:: with SMTP id h19mr21435754lja.220.1562169591197;
        Wed, 03 Jul 2019 08:59:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562169591; cv=none;
        d=google.com; s=arc-20160816;
        b=shPl0w2Bz7VYhU2j88iIAIbAgHWOXF7XveJLwMm+eFUB4q0pg11me2u+BaGDznTD8h
         YTq/XdvQu8VIQrjqv0oFyAelBmVBbrBwO5SIP27OzvTKy1dwaFpC74sxhcyHJJqQtjHH
         WaoQf0ik1KAJv6ivagAkeTF5Fq3cDHR09H6Twpj4jUQCGRYwIkgq3cazYKfiVDKsqJNh
         9zQ4rimf9tUkZ0CrnOqe0B88duhoVB8NDni6/HFPeWv7wbaUQH2U9WtuyloVcljPP4XD
         hm2/SzRyYEb75o0y8DqYlWZpNcH76+TJdciJeu+wbEWjk67CLoH7vuoDFwuugthKc2SR
         LCSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=gFrhzCDbKN3dXJqOCjxaWjlxE64lMzIuw0MAKOdMJPo=;
        b=LINIsC3iHMcwH8dFR6Pc1ovH4fMQwghCcXzWdyCqd1szSl/Fyef8QmpvUgbIL8N7bP
         zqiJYmHDyjC1dJLyLHQOc36qkCJG5Dvwtx0xEEGt/ikfIXz3dTkSg19SayQkCr/c+6u7
         jeO2NogoLMSl5B42VqqfOQdVPUZdcgi3O3tmpBi9F8mZSeke/gGvLQqb+5t0kITStYvo
         OgWCw61GnS6cw9dmG2dMp6HezAk7UfI854XG/9SZ2FGwz/6iO8xA6zOtaHJLAPBE/5AE
         w8UAFa/XjQli+gQBR0vUJ/9xLr9liE/QyMM94/PmBAOFco5HjkXf5069TvSjk362azg+
         Sg+A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qWymVMwW;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s12sor1639096lje.40.2019.07.03.08.59.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jul 2019 08:59:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qWymVMwW;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=gFrhzCDbKN3dXJqOCjxaWjlxE64lMzIuw0MAKOdMJPo=;
        b=qWymVMwWBiebY3jqm1IZFIvKbFwtFLiQBcstlPbjsEjP1XWeeND9r9xO1Gv+nq8hMl
         KMjBNXPgyz9R2PCG624S838/3s2HNifSySYIKpD85drn4YzChNIDbXnNFqcb/+Yr9dxU
         w+qz2mE3begIDz0gBU9B+lSKVeoz3DPpfkts4wBr7zcVU3NSEeEwE2Igkn++2ZOww0dt
         VW9zD5ez59Nzn3H2cAlqNWYEHi9c7yeTv5q8tfkcVNqas3NCu5le3eEb/p1zEpN6x0J5
         MWuKxAyKJGUwJLYqYeaT0ronfXLCgUI/sZj3wH9ateZX1SVSOVFpQgea8ix3pvwAle5H
         CtUA==
X-Google-Smtp-Source: APXvYqxQN0IjsHvsXPGL1/dmxNkT7MMV5tTjkmdNONnvAy7DjCdslgHJ1eS+uFVKcySrprZrSgDZXA==
X-Received: by 2002:a2e:9ad1:: with SMTP id p17mr22136975ljj.34.1562169590522;
        Wed, 03 Jul 2019 08:59:50 -0700 (PDT)
Received: from pc636.semobile.internal ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id t21sm441121lfd.85.2019.07.03.08.59.49
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jul 2019 08:59:49 -0700 (PDT)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Uladzislau Rezki <urezki@gmail.com>,
	Hillf Danton <hdanton@sina.com>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH 1/1] mm/vmalloc: do not keep unpurged areas in the busy tree
Date: Wed,  3 Jul 2019 17:59:42 +0200
Message-Id: <20190703155942.13571-1-urezki@gmail.com>
X-Mailer: git-send-email 2.11.0
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
 mm/vmalloc.c | 51 ++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 42 insertions(+), 9 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index edb212298c8a..1219152e60b1 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -329,7 +329,6 @@ EXPORT_SYMBOL(vmalloc_to_pfn);
 #define DEBUG_AUGMENT_PROPAGATE_CHECK 0
 #define DEBUG_AUGMENT_LOWEST_MATCH_CHECK 0
 
-#define VM_LAZY_FREE	0x02
 #define VM_VM_AREA	0x04
 
 static DEFINE_SPINLOCK(vmap_area_lock);
@@ -534,7 +533,7 @@ link_va(struct vmap_area *va, struct rb_root *root,
 static __always_inline void
 unlink_va(struct vmap_area *va, struct rb_root *root)
 {
-	if (WARN_ON(RB_EMPTY_NODE(&va->rb_node)))
+	if (RB_EMPTY_NODE(&va->rb_node))
 		return;
 
 	if (root == &free_vmap_area_root)
@@ -1160,7 +1159,11 @@ EXPORT_SYMBOL_GPL(unregister_vmap_purge_notifier);
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
 
@@ -1311,6 +1314,10 @@ static void free_vmap_area_noflush(struct vmap_area *va)
 {
 	unsigned long nr_lazy;
 
+	spin_lock(&vmap_area_lock);
+	unlink_va(va, &vmap_area_root);
+	spin_unlock(&vmap_area_lock);
+
 	nr_lazy = atomic_long_add_return((va->va_end - va->va_start) >>
 				PAGE_SHIFT, &vmap_lazy_nr);
 
@@ -2130,14 +2137,13 @@ struct vm_struct *remove_vm_area(const void *addr)
 
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
@@ -2145,6 +2151,8 @@ struct vm_struct *remove_vm_area(const void *addr)
 
 		return vm;
 	}
+
+	spin_unlock(&vmap_area_lock);
 	return NULL;
 }
 
@@ -3421,6 +3429,22 @@ static void show_numa_info(struct seq_file *m, struct vm_struct *v)
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
@@ -3433,10 +3457,9 @@ static int s_show(struct seq_file *m, void *p)
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
@@ -3472,6 +3495,16 @@ static int s_show(struct seq_file *m, void *p)
 
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

