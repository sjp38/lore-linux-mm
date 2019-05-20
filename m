Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F192C04AAC
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 14:00:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 60F74216B7
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 14:00:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60F74216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CBF876B0007; Mon, 20 May 2019 10:00:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C95596B0008; Mon, 20 May 2019 10:00:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B83796B000A; Mon, 20 May 2019 10:00:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 50C586B0007
	for <linux-mm@kvack.org>; Mon, 20 May 2019 10:00:21 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id q3so2621817lfp.7
        for <linux-mm@kvack.org>; Mon, 20 May 2019 07:00:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:date:message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=WNDs88Ea4tbx39imqpysHHjvu2lJrySurfWdBdvnglE=;
        b=Clt67qRHcwZtaVmtuSpBAC/THKBthd1XkrLLIREERH4MKgzbCku0QGEzJBiyPInFZI
         HgYhSTgaK/grxcCXh0NOBxY4KTG5dWusMV47+rmisLtRipOU7LfytIEci/kaz7dzQtZW
         pEdr9thQLdinJ1LB4pcKJpIBGy8wIzM4KlctZL01cas/hDrR3alm9Fa9AKpyqbYtudhL
         WETYSULabPd1nJdYvGC/rT22fLiuiqixcrmUTf+xFOkB8YP8NaVwQt6tDbMLFN6YNaI2
         mfCUYb0N5HOYu4ivpRCskK0m/6ihrBmQz8SW8b2pj2sAnq5g+tHfev0oTU2oJi/9KUs6
         wIbg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAXbMHD0Yq4jSqoKyZCBLH2tRVC6aWryMcNfw3k4PFKKzfJCEJxH
	A5RZb8LSXU1X7Ujhdwt3jcI22lET0ndqOsZw3bUEmBhW+uPmAZLgWzJ7U5ygxS2Gh9pQf+kgKwU
	CuVVGCsRyxwrnl1rFNSazdZL7uFhMnkzPUpqKB3NbJNUr886pIkiqSBm4roy/T34OXA==
X-Received: by 2002:ac2:4c98:: with SMTP id d24mr10790801lfl.146.1558360820731;
        Mon, 20 May 2019 07:00:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHe47P9rAlKD+iFq6o9s0oRKGucI1DHwLEVkKKqgfnc5OkFg7VnoaSSozLpsdyxPXnH1xG
X-Received: by 2002:ac2:4c98:: with SMTP id d24mr10790701lfl.146.1558360819036;
        Mon, 20 May 2019 07:00:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558360819; cv=none;
        d=google.com; s=arc-20160816;
        b=HMsHNSFFDPVnZ1J1tBKBepc66AKI70mVis4XtrHzo6g9u5vH9PMqwubYUnJf/RCYe3
         JXutyNw3KjFWbSSgauuapuYaRwPIPhoqEff3pc19rgFPdiKf1kcJayGO58sXTUQqE5aY
         4lbLxczJpuBrsTl4ua3pDelxATnzgSAUwu5hyHWwxZUkw1HdAmo/46fitynTHJxNVFCz
         9kPjmdwoWdP+NQxT85zbT8V0+1ps/gl+oPMNDfcS0k8QBkw3vtnAz21FE1b/BoagfgPg
         vmGNZcGbfrrxVCEvdIA1wv2S/Ytk6tENA0JlCvMO0NurCex67exdnH9YIwV9ADirX5iO
         TvJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:to:from:subject;
        bh=WNDs88Ea4tbx39imqpysHHjvu2lJrySurfWdBdvnglE=;
        b=hJB/62iuGt9CuxcF2lryirjWI9cH1B2PjluJBXYAk01+k0wLuZYyp2GeZUaZM7IOkq
         Gi9Ul0v9H5mMLvshb2zirYTJrxYGSEpoS6wuTLk5Ms+tDTvWLnZVPVb/f0kVg+Dyjvjg
         0SS31/xLf5SIre8b3pQVCzzBYvb+iWJLOucRfw03XApj9UH8356ZFwUVLf0Qe/bAfpk7
         Fvx+03W4TtJ0VFvkjOVf18lNW8cIjXYzCl1MekMe4I7MTnBxqCt6oGIN7r5t5TkPWSPV
         03tlTY/zuvSFv5vXPP14h46SAe2IoFFYCnfGama4DnB3zwCGVuhBGk8cJr00koQgh+Io
         iMQA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id n19si14940194lji.197.2019.05.20.07.00.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 07:00:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hSipo-00082c-KS; Mon, 20 May 2019 17:00:12 +0300
Subject: [PATCH v2 2/7] mm: Extend copy_vma()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, dan.j.williams@intel.com, ktkhai@virtuozzo.com,
 mhocko@suse.com, keith.busch@intel.com, kirill.shutemov@linux.intel.com,
 alexander.h.duyck@linux.intel.com, ira.weiny@intel.com, andreyknvl@google.com,
 arunks@codeaurora.org, vbabka@suse.cz, cl@linux.com, riel@surriel.com,
 keescook@chromium.org, hannes@cmpxchg.org, npiggin@gmail.com,
 mathieu.desnoyers@efficios.com, shakeelb@google.com, guro@fb.com,
 aarcange@redhat.com, hughd@google.com, jglisse@redhat.com,
 mgorman@techsingularity.net, daniel.m.jordan@oracle.com, jannh@google.com,
 kilobyte@angband.pl, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
Date: Mon, 20 May 2019 17:00:12 +0300
Message-ID: <155836081252.2441.9024100415314519956.stgit@localhost.localdomain>
In-Reply-To: <155836064844.2441.10911127801797083064.stgit@localhost.localdomain>
References: <155836064844.2441.10911127801797083064.stgit@localhost.localdomain>
User-Agent: StGit/0.18
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This prepares the function to copy a vma between
two processes. Two new arguments are introduced.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 include/linux/mm.h |    4 ++--
 mm/mmap.c          |   33 ++++++++++++++++++++++++---------
 mm/mremap.c        |    4 ++--
 3 files changed, 28 insertions(+), 13 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0e8834ac32b7..afe07e4a76f8 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2329,8 +2329,8 @@ extern void __vma_link_rb(struct mm_struct *, struct vm_area_struct *,
 	struct rb_node **, struct rb_node *);
 extern void unlink_file_vma(struct vm_area_struct *);
 extern struct vm_area_struct *copy_vma(struct vm_area_struct **,
-	unsigned long addr, unsigned long len, pgoff_t pgoff,
-	bool *need_rmap_locks);
+	struct mm_struct *, unsigned long addr, unsigned long len,
+	pgoff_t pgoff, bool *need_rmap_locks, bool clear_flags_ctx);
 extern void exit_mmap(struct mm_struct *);
 
 static inline int check_data_rlimit(unsigned long rlim,
diff --git a/mm/mmap.c b/mm/mmap.c
index 57803a0a3a5c..99778e724ad1 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3195,19 +3195,21 @@ int insert_vm_struct(struct mm_struct *mm, struct vm_area_struct *vma)
 }
 
 /*
- * Copy the vma structure to a new location in the same mm,
- * prior to moving page table entries, to effect an mremap move.
+ * Copy the vma structure to new location in the same vma
+ * prior to moving page table entries, to effect an mremap move;
  */
 struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
-	unsigned long addr, unsigned long len, pgoff_t pgoff,
-	bool *need_rmap_locks)
+				struct mm_struct *mm, unsigned long addr,
+				unsigned long len, pgoff_t pgoff,
+				bool *need_rmap_locks, bool clear_flags_ctx)
 {
 	struct vm_area_struct *vma = *vmap;
 	unsigned long vma_start = vma->vm_start;
-	struct mm_struct *mm = vma->vm_mm;
+	struct vm_userfaultfd_ctx uctx;
 	struct vm_area_struct *new_vma, *prev;
 	struct rb_node **rb_link, *rb_parent;
 	bool faulted_in_anon_vma = true;
+	unsigned long flags;
 
 	/*
 	 * If anonymous vma has not yet been faulted, update new pgoff
@@ -3220,15 +3222,25 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 
 	if (find_vma_links(mm, addr, addr + len, &prev, &rb_link, &rb_parent))
 		return NULL;	/* should never get here */
-	new_vma = vma_merge(mm, prev, addr, addr + len, vma->vm_flags,
-			    vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma),
-			    vma->vm_userfaultfd_ctx);
+
+	uctx = vma->vm_userfaultfd_ctx;
+	flags = vma->vm_flags;
+	if (clear_flags_ctx) {
+		uctx = NULL_VM_UFFD_CTX;
+		flags &= ~(VM_UFFD_MISSING | VM_UFFD_WP | VM_MERGEABLE |
+			   VM_LOCKED | VM_LOCKONFAULT | VM_WIPEONFORK |
+			   VM_DONTCOPY);
+	}
+
+	new_vma = vma_merge(mm, prev, addr, addr + len, flags, vma->anon_vma,
+			    vma->vm_file, pgoff, vma_policy(vma), uctx);
 	if (new_vma) {
 		/*
 		 * Source vma may have been merged into new_vma
 		 */
 		if (unlikely(vma_start >= new_vma->vm_start &&
-			     vma_start < new_vma->vm_end)) {
+			     vma_start < new_vma->vm_end) &&
+			     vma->vm_mm == mm) {
 			/*
 			 * The only way we can get a vma_merge with
 			 * self during an mremap is if the vma hasn't
@@ -3249,6 +3261,9 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 		new_vma = vm_area_dup(vma);
 		if (!new_vma)
 			goto out;
+		new_vma->vm_mm = mm;
+		new_vma->vm_flags = flags;
+		new_vma->vm_userfaultfd_ctx = uctx;
 		new_vma->vm_start = addr;
 		new_vma->vm_end = addr + len;
 		new_vma->vm_pgoff = pgoff;
diff --git a/mm/mremap.c b/mm/mremap.c
index 37b5b2ad91be..9a96cfc28675 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -352,8 +352,8 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 		return err;
 
 	new_pgoff = vma->vm_pgoff + ((old_addr - vma->vm_start) >> PAGE_SHIFT);
-	new_vma = copy_vma(&vma, new_addr, new_len, new_pgoff,
-			   &need_rmap_locks);
+	new_vma = copy_vma(&vma, mm, new_addr, new_len, new_pgoff,
+			   &need_rmap_locks, false);
 	if (!new_vma)
 		return -ENOMEM;
 

