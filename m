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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95FC6C76195
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 15:27:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5AB9F2173E
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 15:27:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="glco4Syo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5AB9F2173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E7B408E000A; Tue, 16 Jul 2019 11:27:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E05948E0006; Tue, 16 Jul 2019 11:27:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C31EE8E000A; Tue, 16 Jul 2019 11:27:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 88D5C8E0006
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 11:27:27 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id n23so986690pgf.18
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 08:27:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=vzHJ6zZC4j+G0RNaMkru3klGJtcfV37NNKvE8Og+hcc=;
        b=J0mSbebrDB8NU9UqfAlSyM8IRaHVhdxLIyvqH6OqxoDSGuQW197+dgaQAzbTFuZcjU
         94Wb9rTpV6uvqfoLca85ipl9aQmxF9UfSQdAoG43WopJZMLtP3RVY0WsH5aCParh6YVq
         qYYR8aK810mx5NRg4aXEjvRJaKPp7+ffdRMjyPva3H0mdlLchCg7/E9lsA5orkS5CHnw
         hukrUOd4fF1GvrNJWarsfVtgU4rMG8ivz6SUuCZtLx+ykzXFAFPxnQFvWgDux2UL3vDI
         RVdzi/cPOTSkMDJXEfRpaPbKU9edpVzJ4E0rosmc5RTP5ZdSpFr8drZ/eUpUroVTxq6b
         Bixg==
X-Gm-Message-State: APjAAAUh16AFN4BS33KkLZ/dgln15qQvMMeQXvp0ScwFKSPJajMnl8vS
	rrnvhs0t/fN6YJ2tEEq1L7ybJhB2OjzStmj/Ot65HfQhStDeNEnigoNImok3E+XTMTMS++pxwGT
	Jo0Wu5FINvggwpTQAmBt2amjLTKq5DrEcxSU+mx5iL6JreWHemh4E61sRgNzNOPQkUQ==
X-Received: by 2002:a17:90a:3544:: with SMTP id q62mr37728488pjb.53.1563290847079;
        Tue, 16 Jul 2019 08:27:27 -0700 (PDT)
X-Received: by 2002:a17:90a:3544:: with SMTP id q62mr37728296pjb.53.1563290845696;
        Tue, 16 Jul 2019 08:27:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563290845; cv=none;
        d=google.com; s=arc-20160816;
        b=dTK2UCvSd6Q/nk+pk2leRS60ejfzNcIu0Shn3oYrUXK9hQNRTBaLs55/E/2Wb/5YTM
         xDuh+rCDUXbB4bD2QO+9tobnh00ikpBF1XdWaJwD0ZegWbvHqTu4z6tuwiy+n/1eMFaj
         HoKIXAkQACCsXrmdFLI1MAXbdX/tTbbxmimezli10A51+DP2i4aLQc8lc8sZBhHHi0Xo
         5PtIKO/x3qNuahW9UEyT4KBQamIzwHha7aTAPQWHoIclUCQultJ7171aD2ahd9IxVL3T
         mNS05JYaLAW9xTJg8+htvZqtal+v0PqOPuxjwxSp6Oq4McXEmRPImDUO+uxa0iXYYAVr
         7ECg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=vzHJ6zZC4j+G0RNaMkru3klGJtcfV37NNKvE8Og+hcc=;
        b=cwRGMAtyI2DjhfrmtcNnS0kbQnBTSOJkLoWTqM9fB0wFi1ywDm4iN1/l6L7GHFxNn7
         KPkLf3gKZvRX97/rj4EL1Jmch0jxbNFXUDtWwaavKrYwnybxCrJqQeANw2/0wc2tHfw4
         vWWLAZPj6G6CQWPb1oI9xTBw3Eol8PQbzF8FkMXELknHqDCrY+I6u+/Adbvh+hWIKvdv
         8sfWBoHfYcmufQdj6pZtTc0qhnevmLGbQlgiiOQTlvy2Sd9yv0W1GcMGciDsKJqrB33d
         ckcLuSy2hKjHFKPBDf4NzMxhCH/noPymR+BBQxhTmDEuC2Enb/RelgBjSD6HwYG/703G
         sEuw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=glco4Syo;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z68sor11118424pgz.39.2019.07.16.08.27.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jul 2019 08:27:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=glco4Syo;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=vzHJ6zZC4j+G0RNaMkru3klGJtcfV37NNKvE8Og+hcc=;
        b=glco4SyouK9YNe9AOX80l/zZ96PB6sLsVT7aTl00fxtU1t6+DtddCpju1qN1GnakWN
         NrYJNLnKtAlI9BEqqjGZVVE7cTPHBd5l0frW7/DahVt1aVd40V4I3WZiaJ2xkwskuItH
         EH7GRA7bCHZI87LNQUK3NJXg7QDcCqnXqdxUG1uTo2JG+e1J7U0wLOaqMLy1LmuJIZZp
         RbjfH+VpPQIyWfGoyJs4s7lOzIrPRqKFHqTXJeJE3VTajMtsKIdvdM8OqrecYzL9RzXn
         LZym62jEYpAdDFoTY+e75Ca5UoDvQWrQ37rkBpVMIiO5bOwM1GYgCAgXuneXVgxbFwAM
         GPyg==
X-Google-Smtp-Source: APXvYqwg+FuF9Z+ryq1LlKWCFuSwx1x2eeoS4E8Y1ZmKIG10l37NCWviEOWMWa8L2sOVma1B98CQOQ==
X-Received: by 2002:a65:5202:: with SMTP id o2mr13584554pgp.29.1563290845380;
        Tue, 16 Jul 2019 08:27:25 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:bf0:b8c3:8577:bf2f:2])
        by smtp.gmail.com with ESMTPSA id h9sm27453651pgk.10.2019.07.16.08.27.17
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 16 Jul 2019 08:27:25 -0700 (PDT)
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
Subject: [PATCH v6 1/2] mm/vmalloc: do not keep unpurged areas in the busy tree
Date: Tue, 16 Jul 2019 23:26:55 +0800
Message-Id: <20190716152656.12255-2-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190716152656.12255-1-lpf.vector@gmail.com>
References: <20190716152656.12255-1-lpf.vector@gmail.com>
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

