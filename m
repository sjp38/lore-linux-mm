Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBAFCC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:02:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E60320820
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:02:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="IepaJTQb";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="pFvarqzE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E60320820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB0A96B0279; Wed,  3 Apr 2019 22:01:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C8D956B027A; Wed,  3 Apr 2019 22:01:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B551A6B027B; Wed,  3 Apr 2019 22:01:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8CB3B6B0279
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 22:01:50 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id x12so986700qtk.2
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 19:01:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=+OWLOaTSulD1I3rYTyrpQROTEVUrL3XU1UdiU3Mdlfc=;
        b=te3vtk+f9/XaVT6BDMajAVgxoIkHbIheZeGX5u5SBfY6RQs+zDPOiPbIjpKbxdlGHE
         Z+uHc1Eo1p/tJkb8+5kwKpe9aQcvVamiLrACU2JTYaqc4MMAtst6EzOzhRTTUl/GCSiR
         ufxlTbzbFwj68yCIZUN9Ww0DK9h2Z2TJ+Y0RDPiJx9Fa1QvdiCdCWgB0IglMkADeWiyj
         4A0t91fEqil8riO194Tqruhei/rLh/Sc81cKB0lwanrVkoyRBLJSzI1I2RnMvgznonFo
         GhJgXnBhJc4Rjmps1YP0JKyBoiiXdWMuVUNA/GMZrl/MKIxp4VeTnu3OCzUurXtiVYzQ
         yaiw==
X-Gm-Message-State: APjAAAWq8NI7VECXxI3MoRA7VC3H7LxAUrG7a1so8q1nxZdGt6msVZnG
	p4q3h+Rho9tKxrpvIv5Pw6MqLWYh6f08ojm2WZaTKa90o6ReWw87JebFM6WNmNkZDr7rnp3SrTL
	rd0x3f6tCuNnQD+8mI1fcbZFmScW1mDRtHM9VWQI79LYP1lk6B3Oa/g6Z63d+qaqwaA==
X-Received: by 2002:a37:ba44:: with SMTP id k65mr2921196qkf.209.1554343310311;
        Wed, 03 Apr 2019 19:01:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxKbg/SsYL3/rHZv+VJCp1jNwLdZ7t/ErDiPXbRDrxRLeqtoA43yJqtpgOyKfwfiGHdS9x7
X-Received: by 2002:a37:ba44:: with SMTP id k65mr2921147qkf.209.1554343309394;
        Wed, 03 Apr 2019 19:01:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554343309; cv=none;
        d=google.com; s=arc-20160816;
        b=0Ut6jp1BVyGpNf2NpUSmAVqmRfLWZqlCmocO/9b5KiFosUsHmqWrZemVUFZS8iTrIO
         sfn7GY+EOhvYSac8YosCEoF89SPdQzeOGGmgJC54vMAahlSXP7oCb5dUXdEoHf6cUjT7
         Drz/lgnLRCAogyjSeD/XgztIMetWOir8i/p1vnZjdedqlL4WqxkOSMi4P2lV4kB6ZkUo
         KAl1ap0YkJ5JZoEKmZown3hylowB0KDjkgVfp1LnL3gHCwSC/pq3FAM5Qi5sBtRut4VJ
         CBnY4O57BCqJwvEB1gCZno7MV38xUUZlOj6oYklFIP8MUTqFw2xBE9AgIXaRilDmdf6X
         Lsyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=+OWLOaTSulD1I3rYTyrpQROTEVUrL3XU1UdiU3Mdlfc=;
        b=kJqqOYn7NJdCYwC1HtKKXAhUrjllZCKKCsnOOL70Xpy+yFLarKYI013Rh6xJw1zA+d
         xYlquaFhUkPKfnlXby5yu0puRnGaxunhf4JGf7KZSVrX/wKFUptTXgVChFc+Z3e22+lu
         9z+ydM00MuVXFBY5XFbt2BOZMatEPkgQIcQZCnMYiMdiguLC1N5zwvBtSLONypKGDm2c
         FPFwBUpsq7uGgvIyVzXpFXUTKJR0OSu3DEENczKdis0tVVHvrEAW6IOPXauGRNkTXnZV
         0Mhu+YXYF9ZxQO5qaOsy67bbgD2M78tlcPf6YcLPJvGjs13z2V7fxP/K3aOrcZkv/ovn
         YX+w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=IepaJTQb;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=pFvarqzE;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from out5-smtp.messagingengine.com (out5-smtp.messagingengine.com. [66.111.4.29])
        by mx.google.com with ESMTPS id x14si3612399qtb.125.2019.04.03.19.01.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 19:01:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) client-ip=66.111.4.29;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=IepaJTQb;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=pFvarqzE;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 10E4822197;
	Wed,  3 Apr 2019 22:01:49 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Wed, 03 Apr 2019 22:01:49 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm3; bh=+OWLOaTSulD1I
	3rYTyrpQROTEVUrL3XU1UdiU3Mdlfc=; b=IepaJTQbb31zalJJGZxTgZaCkwM6d
	eHeCyODQ1uYRTZk/AzVpR1neNOZmfFpY1YlnHUDm8TeEqGn4R8FdxsyDqMwIPlfL
	hQCPcHSOseDhYaRschdT+jVFxj0U2JtNrD/xCmrscoyA2G0Ry03Xr45E2Z43iIYN
	vmiIU6wDztaqQblBtYiPa0LLA418qMYmRh5QTCCsdOWmgyWCh3LjnrL+QrBhVcRq
	HUNN1W1DHA2P+P6MB0em6DKpySNm78bgvUakLYu23lBCzPxiscinsIfadLb2nyJx
	5WObCzzG2GSRkwbpwSLxxt7PtQLjYNLvRzVO48ybpjzBdweOGQ+ilHptw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=+OWLOaTSulD1I3rYTyrpQROTEVUrL3XU1UdiU3Mdlfc=; b=pFvarqzE
	6t4RsHaY5kXD4/iEsCtGmbrabYqmgojOy9io0NkPu3ucLA3xmch/9GusYPD8xpcS
	OGkJ4IT8EMO4KOiKuwYJdemcmT9TrpbL/Jme7Rdty/XGDdKSYsBp/2G5GVTE2jdd
	qdj+i1ib6yjJo1fwcgXWPpdWqEF3hb0FhSEC1x58fYBEDrrCn2N0Fk+dPEFgC7HY
	HP35GPuZ7L586jmytk1uZv9LDF+F1y0b0MoAKuFcL9YHJug98nrI01rVZM8DKh+B
	Uns3S+iGixw0u2MkHR3Tsu/A/2gw7sFZlOiGpDjhbFi5+JEK0BdCwCsVT8NdLy5Q
	3C+29CawBAahYg==
X-ME-Sender: <xms:jGWlXOfUf-q6bf7CDyRVnshj6RWjHebtwN37s7jU_mcz0YBkfieYKA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtdeggdehudculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhhrggfgsedtkeertdertddt
    necuhfhrohhmpegkihcujggrnhcuoeiiihdrhigrnhesshgvnhhtrdgtohhmqeenucfkph
    epvdduiedrvddvkedrudduvddrvddvnecurfgrrhgrmhepmhgrihhlfhhrohhmpeiiihdr
    higrnhesshgvnhhtrdgtohhmnecuvehluhhsthgvrhfuihiivgepudej
X-ME-Proxy: <xmx:jGWlXFEFx8_PmUUB3PsbmOuutWDiyjIwEbvV4gZ5O1zqVArX-6p7EQ>
    <xmx:jGWlXPS-vHgPInmIXULLoPN3KfWvqLnWe7_I6aOHIaudn_Fwmuocyw>
    <xmx:jGWlXLa1XB6TDppAzdo42oOX5wvdlnzCAqDWMC9IYrSicFq1-ATJBA>
    <xmx:jGWlXHtnRmsQ4gdcxLhtYCN7ck_Fa-DEJstr-vNdd4w_FHXc5oz1mw>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id 2061C10316;
	Wed,  3 Apr 2019 22:01:47 -0400 (EDT)
From: Zi Yan <zi.yan@sent.com>
To: Dave Hansen <dave.hansen@linux.intel.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	Keith Busch <keith.busch@intel.com>,
	Fengguang Wu <fengguang.wu@intel.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>,
	John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>,
	Nitin Gupta <nigupta@nvidia.com>,
	Javier Cabezas <jcabezas@nvidia.com>,
	David Nellans <dnellans@nvidia.com>,
	Zi Yan <ziy@nvidia.com>
Subject: [RFC PATCH 20/25] memory manage: Add memory manage syscall.
Date: Wed,  3 Apr 2019 19:00:41 -0700
Message-Id: <20190404020046.32741-21-zi.yan@sent.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190404020046.32741-1-zi.yan@sent.com>
References: <20190404020046.32741-1-zi.yan@sent.com>
Reply-To: ziy@nvidia.com
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Zi Yan <ziy@nvidia.com>

This prepares for the following patches to provide a user API to
manipulate pages in two memory nodes with the help of memcg.

missing memcg_max_size_node()

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 arch/x86/entry/syscalls/syscall_64.tbl |   1 +
 include/linux/sched/coredump.h         |   1 +
 include/linux/syscalls.h               |   5 ++
 include/uapi/linux/mempolicy.h         |   1 +
 mm/Makefile                            |   1 +
 mm/internal.h                          |   2 +
 mm/memory_manage.c                     | 109 +++++++++++++++++++++++++++++++++
 mm/mempolicy.c                         |   2 +-
 8 files changed, 121 insertions(+), 1 deletion(-)
 create mode 100644 mm/memory_manage.c

diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
index 863a21e..fa8def3 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -344,6 +344,7 @@
 333	common	io_pgetevents		__x64_sys_io_pgetevents
 334	common	rseq			__x64_sys_rseq
 335	common	exchange_pages	__x64_sys_exchange_pages
+336	common	mm_manage		__x64_sys_mm_manage
 # don't use numbers 387 through 423, add new calls after the last
 # 'common' entry
 424	common	pidfd_send_signal	__x64_sys_pidfd_send_signal
diff --git a/include/linux/sched/coredump.h b/include/linux/sched/coredump.h
index ecdc654..9aa9d94b 100644
--- a/include/linux/sched/coredump.h
+++ b/include/linux/sched/coredump.h
@@ -73,6 +73,7 @@ static inline int get_dumpable(struct mm_struct *mm)
 #define MMF_OOM_VICTIM		25	/* mm is the oom victim */
 #define MMF_OOM_REAP_QUEUED	26	/* mm was queued for oom_reaper */
 #define MMF_DISABLE_THP_MASK	(1 << MMF_DISABLE_THP)
+#define MMF_MM_MANAGE		27
 
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK |\
 				 MMF_DISABLE_THP_MASK)
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 2c1eb49..47d56c5 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -1208,6 +1208,11 @@ asmlinkage long sys_exchange_pages(pid_t pid, unsigned long nr_pages,
 				const void __user * __user *to_pages,
 				int __user *status,
 				int flags);
+asmlinkage long sys_mm_manage(pid_t pid, unsigned long nr_pages,
+				unsigned long maxnode,
+				const unsigned long __user *old_nodes,
+				const unsigned long __user *new_nodes,
+				int flags);
 
 /*
  * Not a real system call, but a placeholder for syscalls which are
diff --git a/include/uapi/linux/mempolicy.h b/include/uapi/linux/mempolicy.h
index a9d03e5..4722bb7 100644
--- a/include/uapi/linux/mempolicy.h
+++ b/include/uapi/linux/mempolicy.h
@@ -52,6 +52,7 @@ enum {
 #define MPOL_MF_MOVE_DMA (1<<5)	/* Use DMA page copy routine */
 #define MPOL_MF_MOVE_MT  (1<<6)	/* Use multi-threaded page copy routine */
 #define MPOL_MF_MOVE_CONCUR  (1<<7)	/* Move pages in a batch */
+#define MPOL_MF_EXCHANGE	(1<<8)	/* Exchange pages */
 
 #define MPOL_MF_VALID	(MPOL_MF_STRICT   | 	\
 			 MPOL_MF_MOVE     | 	\
diff --git a/mm/Makefile b/mm/Makefile
index 2f1f1ad..5302d79 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -47,6 +47,7 @@ obj-y += memblock.o
 obj-y += copy_page.o
 obj-y += exchange.o
 obj-y += exchange_page.o
+obj-y += memory_manage.o
 
 ifdef CONFIG_MMU
 	obj-$(CONFIG_ADVISE_SYSCALLS)	+= madvise.o
diff --git a/mm/internal.h b/mm/internal.h
index cf63bf6..94feb14 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -574,5 +574,7 @@ bool buffer_migrate_lock_buffers(struct buffer_head *head,
 int writeout(struct address_space *mapping, struct page *page);
 int expected_page_refs(struct address_space *mapping, struct page *page);
 
+int get_nodes(nodemask_t *nodes, const unsigned long __user *nmask,
+		     unsigned long maxnode);
 
 #endif	/* __MM_INTERNAL_H */
diff --git a/mm/memory_manage.c b/mm/memory_manage.c
new file mode 100644
index 0000000..b8f3654
--- /dev/null
+++ b/mm/memory_manage.c
@@ -0,0 +1,109 @@
+/*
+ * A syscall used to move pages between two nodes.
+ */
+
+#include <linux/sched/mm.h>
+#include <linux/cpuset.h>
+#include <linux/mempolicy.h>
+#include <linux/nodemask.h>
+#include <linux/security.h>
+#include <linux/syscalls.h>
+
+#include "internal.h"
+
+
+SYSCALL_DEFINE6(mm_manage, pid_t, pid, unsigned long, nr_pages,
+		unsigned long, maxnode,
+		const unsigned long __user *, slow_nodes,
+		const unsigned long __user *, fast_nodes,
+		int, flags)
+{
+	const struct cred *cred = current_cred(), *tcred;
+	struct task_struct *task;
+	struct mm_struct *mm = NULL;
+	int err;
+	nodemask_t task_nodes;
+	nodemask_t *slow;
+	nodemask_t *fast;
+	NODEMASK_SCRATCH(scratch);
+
+	if (!scratch)
+		return -ENOMEM;
+
+	slow = &scratch->mask1;
+	fast = &scratch->mask2;
+
+	err = get_nodes(slow, slow_nodes, maxnode);
+	if (err)
+		goto out;
+
+	err = get_nodes(fast, fast_nodes, maxnode);
+	if (err)
+		goto out;
+
+	/* Check flags */
+	if (flags & ~(MPOL_MF_MOVE_MT|
+				  MPOL_MF_MOVE_DMA|
+				  MPOL_MF_MOVE_CONCUR|
+				  MPOL_MF_EXCHANGE))
+		return -EINVAL;
+
+	/* Find the mm_struct */
+	rcu_read_lock();
+	task = pid ? find_task_by_vpid(pid) : current;
+	if (!task) {
+		rcu_read_unlock();
+		err = -ESRCH;
+		goto out;
+	}
+	get_task_struct(task);
+
+	err = -EINVAL;
+	/*
+	 * Check if this process has the right to modify the specified
+	 * process. The right exists if the process has administrative
+	 * capabilities, superuser privileges or the same
+	 * userid as the target process.
+	 */
+	tcred = __task_cred(task);
+	if (!uid_eq(cred->euid, tcred->suid) && !uid_eq(cred->euid, tcred->uid) &&
+	    !uid_eq(cred->uid,  tcred->suid) && !uid_eq(cred->uid,  tcred->uid) &&
+	    !capable(CAP_SYS_NICE)) {
+		rcu_read_unlock();
+		err = -EPERM;
+		goto out_put;
+	}
+	rcu_read_unlock();
+
+	err = security_task_movememory(task);
+	if (err)
+		goto out_put;
+
+	task_nodes = cpuset_mems_allowed(task);
+	mm = get_task_mm(task);
+	put_task_struct(task);
+
+	if (!mm) {
+		err = -EINVAL;
+		goto out;
+	}
+	if (test_bit(MMF_MM_MANAGE, &mm->flags)) {
+		mmput(mm);
+		goto out;
+	} else {
+		set_bit(MMF_MM_MANAGE, &mm->flags);
+	}
+
+
+	clear_bit(MMF_MM_MANAGE, &mm->flags);
+	mmput(mm);
+out:
+	NODEMASK_SCRATCH_FREE(scratch);
+
+	return err;
+
+out_put:
+	put_task_struct(task);
+	goto out;
+
+}
\ No newline at end of file
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 0e30049..168d17f8 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1249,7 +1249,7 @@ static long do_mbind(unsigned long start, unsigned long len,
  */
 
 /* Copy a node mask from user space. */
-static int get_nodes(nodemask_t *nodes, const unsigned long __user *nmask,
+int get_nodes(nodemask_t *nodes, const unsigned long __user *nmask,
 		     unsigned long maxnode)
 {
 	unsigned long k;
-- 
2.7.4

