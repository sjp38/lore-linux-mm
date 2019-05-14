Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 082DBC04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 23:51:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1EF12084F
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 23:51:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="AF0Ok7DQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1EF12084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4BE426B0005; Tue, 14 May 2019 19:51:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46E7A6B0006; Tue, 14 May 2019 19:51:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 30FD46B0007; Tue, 14 May 2019 19:51:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0DFEA6B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 19:51:20 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id 23so689787ybe.16
        for <linux-mm@kvack.org>; Tue, 14 May 2019 16:51:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=mUkFppAAxjAaE2wXhVtrJ91WjjBKr6GRw5GrMLKoRzU=;
        b=lwt9Np0BieEE5bQi9DXq8CmqP72B94R+zxenwfFgZ8rcmKA3BKy85f1p2qAzim39xo
         KHf0RLbi7YNNufMNwXRY9hxJb/K3l0yWf9xuWN+gqUFxTCQ1nKGqHfV1SQyY0Pd7OY/y
         uKr0/XrbrMTjihHz01yTg7CzRuDwW/3zFa/FCcZyRGqM77UbDl/OBg5PoS4g6pa61idu
         xnxl72tuwoNMJcqnYff8TWYOYsPvCY4mnM2QCVfU0xy3+gIX63p5U/E/NGf8bbet8XYu
         skMvCwIrDhVm6IitlHV4DJXIUmtGE2h99mo3djg/Pc3GlpG13AKXR5o8akUsZ+ErT8Ta
         Bf4A==
X-Gm-Message-State: APjAAAXgw86EsDb1qvE5CbPTQMxiuCLyeEhP7RGoRTChoZh4orC23sev
	ZMKfJJi17G2ngoitaNYBaK/k4FpewvyQq9ExAlb4iETYdqJv6lr5ZcUw8sgdcgm1vAbNG/9Dwff
	Jdi6Bj2VQrBKUvALMe9GHZpp4mKq2wcuCsds61TMruUP4aGJOyIP9eZKMDDhKiRzBGg==
X-Received: by 2002:a81:a141:: with SMTP id y62mr5757873ywg.192.1557877879764;
        Tue, 14 May 2019 16:51:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw7SFCpGDW2z3cr2b8b7Oj2QExOZi0InH+R/e6nNWw1dIfnfugPMhFQPkVqYEpvVtz//oh5
X-Received: by 2002:a81:a141:: with SMTP id y62mr5757858ywg.192.1557877879107;
        Tue, 14 May 2019 16:51:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557877879; cv=none;
        d=google.com; s=arc-20160816;
        b=lGXMOWNg3I0IWaoBmUo0Pa6CL30Y1rjZsa2+roLoMaGgMf8MjFLdGyCDhigfEUALsh
         pBukUicG5lyHKDaHCIIspkQqNxLgF6E0w1LgsMhwYXKpoYQi8OzhlPC+d8D9RC5gQBjc
         34bcDNb+p+LRNdz8JYEFpXDJjF6EjBzRXpD7KkX6t3eDtWWN1wDlNam+/VFmAEZAlCZf
         kIW9U9ECM3LiZ0sGHS/wFD+UwF5LsPnDXkMQZOGyGuqhQOkj05GQrdGd3xivQOOFsNjm
         pvqaCsvf4qv+5txClFmV/pVwRqNIZ7pCLGdiPW11afh/uyUn8ps3g/tsn9dbTtybCW0s
         pe9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=mUkFppAAxjAaE2wXhVtrJ91WjjBKr6GRw5GrMLKoRzU=;
        b=fAJ96nPmmGHl8Mv1p/K0s+Swbn0cnc+BBKQ4+DYjfhnnGbFoHWPhC+bI86oofXs+aY
         fFOBHsd1egnVFKoEdIPpfQ0VcAT9ajBFZi5faZfHsf1lnbVAJKYbCzhJZSFkh2Ndruvn
         dhzZpwHM8NY4Kbihvhiq+UJr92o3gLD6xieERCPpak1N31Gv15+1PwRzNXPLKkJFItZc
         B44Vhoqp2ByPwmHcyq+Z896VUNc1nLYMoGbi7eRkM1PC++zQAD0N2fqWpNk8qQj8ZirP
         DgV/4nmW67A6PK0QQfKEWNWQSXNbmFY59YrJd22sOCF2UgtXbwBnYWlqXtZxsHyTBzxG
         0XvA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=AF0Ok7DQ;
       spf=pass (google.com: domain of prvs=0037dedd0e=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=0037dedd0e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id d4si64039ybr.272.2019.05.14.16.51.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 16:51:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0037dedd0e=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=AF0Ok7DQ;
       spf=pass (google.com: domain of prvs=0037dedd0e=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=0037dedd0e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148460.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4ENhdFS022408
	for <linux-mm@kvack.org>; Tue, 14 May 2019 16:51:18 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=mUkFppAAxjAaE2wXhVtrJ91WjjBKr6GRw5GrMLKoRzU=;
 b=AF0Ok7DQriDizVKzZBOD4/IvxG41k64FkudQjZGoUgeoSUlhZgjI3RD4N38CtZxZ69t1
 c+ds43zMjz93JkylISnxoDGviWrHVwUrwJkeZ6Dq6FmILolxzBa9NNSM4YDrF3I5MxA7
 3R66NJ+77s92Ekew/l8KJ0g08ubFAFhqooo= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2sg0pkhnck-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 May 2019 16:51:18 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::4) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 14 May 2019 16:51:17 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id E265312084F4A; Tue, 14 May 2019 16:51:15 -0700 (PDT)
Smtp-Origin-Hostprefix: devvm
From: Roman Gushchin <guro@fb.com>
Smtp-Origin-Hostname: devvm2643.prn2.facebook.com
To: Andrew Morton <akpm@linux-foundation.org>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
        Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin
	<guro@fb.com>
Smtp-Origin-Cluster: prn2c23
Subject: [PATCH RESEND] mm: show number of vmalloc pages in /proc/meminfo
Date: Tue, 14 May 2019 16:51:11 -0700
Message-ID: <20190514235111.2817276-2-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190514235111.2817276-1-guro@fb.com>
References: <20190514235111.2817276-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-14_13:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905140154
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Vmalloc() is getting more and more used these days (kernel stacks,
bpf and percpu allocator are new top users), and the total %
of memory consumed by vmalloc() can be pretty significant
and changes dynamically.

/proc/meminfo is the best place to display this information:
its top goal is to show top consumers of the memory.

Since the VmallocUsed field in /proc/meminfo is not in use
for quite a long time (it has been defined to 0 by the
commit a5ad88ce8c7f ("mm: get rid of 'vmalloc_info' from
/proc/meminfo")), let's reuse it for showing the actual
physical memory consumption of vmalloc().

Signed-off-by: Roman Gushchin <guro@fb.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 fs/proc/meminfo.c       |  2 +-
 include/linux/vmalloc.h |  2 ++
 mm/vmalloc.c            | 10 ++++++++++
 3 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 568d90e17c17..465ea0153b2a 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -120,7 +120,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 	show_val_kb(m, "Committed_AS:   ", committed);
 	seq_printf(m, "VmallocTotal:   %8lu kB\n",
 		   (unsigned long)VMALLOC_TOTAL >> 10);
-	show_val_kb(m, "VmallocUsed:    ", 0ul);
+	show_val_kb(m, "VmallocUsed:    ", vmalloc_nr_pages());
 	show_val_kb(m, "VmallocChunk:   ", 0ul);
 	show_val_kb(m, "Percpu:         ", pcpu_nr_pages());
 
diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 51e131245379..9b21d0047710 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -72,10 +72,12 @@ extern void vm_unmap_aliases(void);
 
 #ifdef CONFIG_MMU
 extern void __init vmalloc_init(void);
+extern unsigned long vmalloc_nr_pages(void);
 #else
 static inline void vmalloc_init(void)
 {
 }
+static inline unsigned long vmalloc_nr_pages(void) { return 0; }
 #endif
 
 extern void *vmalloc(unsigned long size);
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 8d4907865614..65871ddba497 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -398,6 +398,13 @@ static void purge_vmap_area_lazy(void);
 static BLOCKING_NOTIFIER_HEAD(vmap_notify_list);
 static unsigned long lazy_max_pages(void);
 
+static atomic_long_t nr_vmalloc_pages;
+
+unsigned long vmalloc_nr_pages(void)
+{
+	return atomic_long_read(&nr_vmalloc_pages);
+}
+
 static struct vmap_area *__find_vmap_area(unsigned long addr)
 {
 	struct rb_node *n = vmap_area_root.rb_node;
@@ -2214,6 +2221,7 @@ static void __vunmap(const void *addr, int deallocate_pages)
 			BUG_ON(!page);
 			__free_pages(page, 0);
 		}
+		atomic_long_sub(area->nr_pages, &nr_vmalloc_pages);
 
 		kvfree(area->pages);
 	}
@@ -2390,12 +2398,14 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 		if (unlikely(!page)) {
 			/* Successfully allocated i pages, free them in __vunmap() */
 			area->nr_pages = i;
+			atomic_long_add(area->nr_pages, &nr_vmalloc_pages);
 			goto fail;
 		}
 		area->pages[i] = page;
 		if (gfpflags_allow_blocking(gfp_mask|highmem_mask))
 			cond_resched();
 	}
+	atomic_long_add(area->nr_pages, &nr_vmalloc_pages);
 
 	if (map_vm_area(area, prot, pages))
 		goto fail;
-- 
2.20.1

