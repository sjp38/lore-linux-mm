Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91F64C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 09:37:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3CBE42075C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 09:37:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3CBE42075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB8668E000E; Mon, 11 Mar 2019 05:37:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D682C8E0002; Mon, 11 Mar 2019 05:37:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C311F8E000E; Mon, 11 Mar 2019 05:37:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9510C8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 05:37:24 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id n16so3872996qtp.14
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 02:37:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=sw4yziM5HH4yKUiDjHU8TNYvF7G664O4vw4D9f9xkAM=;
        b=SrfsE0Sg1Q3a7XX3prHa+KUSsGNMedV4EDLjlKwxn4D3Aq9C2O0NL12WjrkU0Xjb/C
         NZ06uGtqawp4ORJjM2fAgGIYeQp0jN4Ob+08YlOdMdy+Umc5rNoC6beaF2srTRgOkS4M
         vx0RDZkVrsem9aATO0pNgVeJHylvtk48dHF2YsVVt64Z2lHVwBO7h/urQom8FgxGoVk/
         aRekXC+plHM1/Zhsz3M0cKTZMpa3Z14P25VZKlMAJopspbSV4+V2ySCknMtmp8CN/fMx
         ycdNW/uoI4vUC8rNSTKu8RkdznURW5j+i1WCnavMCzywxBy6+XyaxpeBVIDOtysWrHX1
         6BTw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUPg+MwT7VLWDodpTMhlmPPYG9yr6EVkxXoai2kmw5L6+tRAzHQ
	NQvId4B7Da4lseONuWWuIiFIkofJ4VpZRD9Iiu1+jv0Niav6hHMVPY31tVXAaFmC81RyehKNY3U
	mCtbz8doxnh+2at4ylO1RR1oi4EscEVowK30BR3j/Z80Khq1zJFS3ranDewmIQFg2nw==
X-Received: by 2002:ac8:3718:: with SMTP id o24mr24844932qtb.2.1552297044398;
        Mon, 11 Mar 2019 02:37:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyKF0PawsTJH9Ij+tWg0I4np6kwqZ21x1VtydIsLsJd3xf1URBFRQD9uqcHiDXa16CmtslN
X-Received: by 2002:ac8:3718:: with SMTP id o24mr24844909qtb.2.1552297043529;
        Mon, 11 Mar 2019 02:37:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552297043; cv=none;
        d=google.com; s=arc-20160816;
        b=TPZLsA1AnAJsQ7ZGimyzyvfHX27dtLX0EvB2oN+ag492IciREoIJU77ZZsfX82BnCU
         t9nB56SG69dTdhK1Y1FYMt8T7Wzs3m6uqb6Ach4OzsnYOzJl/8P/XzZWGp5t/phlQz2/
         kLI6IUjr3MmCTDqy0kzoyiZ00uBKoikh18SB/8X6nhj3jEArihvd/jUTfzuLAKHXxCqH
         R2BhNAAJcXmDtYizNEyIHa9On0utKNDNpgE6jKwBvA6r4z2PSaegPloo5w8Cb/XJ1bjR
         JG/zwblPY9lH4JzwT0wXXED684ArcRdOx3sRRGuiTzFkWTrfuSHgq0HYzmb9vclaSj8Y
         gs5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=sw4yziM5HH4yKUiDjHU8TNYvF7G664O4vw4D9f9xkAM=;
        b=A3Q2R2YOaWn14EOhBa7JMRNQ1nILvmn19iR8X3HSqfKM0ftrqAZNRRFKLN08HL5p6K
         rqcg9YuOlLkiFEGMge6QdfR2L4i/GKuJIj6GU3JO4cipErEKqfpgALHxEgkH4XZr2bEp
         tefcnzNYLS9COkvbclwYAh7XAe/yIZHZasgOlN/Mop7xqL9UaB6nq3aEIbzBKEZ0r+L+
         SBTb6NamEnkL6W7bkaG+2G4mXYMFrZM05siRRt7d9jIqiiZFAKyT4EF5r/22cAwo1nL9
         XA7MykEg8lRhu5cm91Oz4XqRSqcrFPHxmlDH1FhYuMqsAmRcCL4GtBNzGjr1CIfHCBy2
         iR4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m12si1132440qkl.250.2019.03.11.02.37.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 02:37:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 71CFD30821E2;
	Mon, 11 Mar 2019 09:37:22 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 595225D706;
	Mon, 11 Mar 2019 09:37:15 +0000 (UTC)
From: Peter Xu <peterx@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Paolo Bonzini <pbonzini@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Maxime Coquelin <maxime.coquelin@redhat.com>,
	kvm@vger.kernel.org,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	peterx@redhat.com,
	Martin Cracauer <cracauer@cons.org>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	linux-mm@kvack.org,
	Marty McFadden <mcfadden8@llnl.gov>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Kees Cook <keescook@chromium.org>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	linux-fsdevel@vger.kernel.org,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH 1/3] userfaultfd/sysctl: introduce unprivileged_userfaultfd
Date: Mon, 11 Mar 2019 17:36:59 +0800
Message-Id: <20190311093701.15734-2-peterx@redhat.com>
In-Reply-To: <20190311093701.15734-1-peterx@redhat.com>
References: <20190311093701.15734-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Mon, 11 Mar 2019 09:37:22 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Introduce a new sysctl called "vm.unprivileged_userfaultfd" that can
be used to decide whether userfaultfd syscalls are allowed by
unprivileged users.  It'll allow three modes:

  - disabled: disallow unprivileged users to use uffd

  - enabled:  allow unprivileged users to use uffd

  - kvm:      allow unprivileged users to use uffd only if the user
              had enough permission to open /dev/kvm (this option only
              exists if the kernel turned on KVM).

This patch only introduce the new interface but not yet applied it to
the userfaultfd syscalls, which will be done in the follow up patch.

Signed-off-by: Peter Xu <peterx@redhat.com>
---
 fs/userfaultfd.c              | 96 +++++++++++++++++++++++++++++++++++
 include/linux/userfaultfd_k.h |  5 ++
 init/Kconfig                  | 11 ++++
 kernel/sysctl.c               | 11 ++++
 4 files changed, 123 insertions(+)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 89800fc7dc9d..c2188464555a 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -29,6 +29,8 @@
 #include <linux/ioctl.h>
 #include <linux/security.h>
 #include <linux/hugetlb.h>
+#include <linux/sysctl.h>
+#include <linux/string.h>
 
 static struct kmem_cache *userfaultfd_ctx_cachep __read_mostly;
 
@@ -93,6 +95,95 @@ struct userfaultfd_wake_range {
 	unsigned long len;
 };
 
+enum unprivileged_userfaultfd {
+	/* Disallow unprivileged users to use userfaultfd syscalls */
+	UFFD_UNPRIV_DISABLED = 0,
+	/* Allow unprivileged users to use userfaultfd syscalls */
+	UFFD_UNPRIV_ENABLED,
+#if IS_ENABLED(CONFIG_KVM)
+	/*
+	 * Allow unprivileged users to use userfaultfd syscalls only
+	 * if the user had enough permission to open /dev/kvm
+	 */
+	UFFD_UNPRIV_KVM,
+#endif
+	UFFD_UNPRIV_NUM,
+};
+
+static int unprivileged_userfaultfd __read_mostly;
+static const char *unprivileged_userfaultfd_str[UFFD_UNPRIV_NUM] = {
+	"disabled", "enabled",
+#if IS_ENABLED(CONFIG_KVM)
+	"kvm",
+#endif
+};
+
+static int unprivileged_uffd_parse(char *buf, size_t size)
+{
+	int i;
+
+	for (i = 0; i < UFFD_UNPRIV_NUM; i++) {
+		if (!strncmp(unprivileged_userfaultfd_str[i], buf, size)) {
+			unprivileged_userfaultfd = i;
+			return 0;
+		}
+	}
+
+	return -EFAULT;
+}
+
+static void unprivileged_uffd_dump(char *buf, size_t size)
+{
+	int i;
+
+	*buf = 0x00;
+	for (i = 0; i < UFFD_UNPRIV_NUM; i++) {
+		if (i == unprivileged_userfaultfd)
+			strncat(buf, "[", size - strlen(buf));
+		strncat(buf, unprivileged_userfaultfd_str[i],
+			size - strlen(buf));
+		if (i == unprivileged_userfaultfd)
+			strncat(buf, "]", size - strlen(buf));
+		strncat(buf, " ", size - strlen(buf));
+	}
+
+}
+
+int proc_unprivileged_userfaultfd(struct ctl_table *table, int write,
+				  void __user *buffer, size_t *lenp,
+				  loff_t *ppos)
+{
+	struct ctl_table tmp_table = { .maxlen = 0 };
+	int ret;
+
+	if (write) {
+		tmp_table.maxlen = UFFD_UNPRIV_STRLEN;
+		tmp_table.data = kmalloc(UFFD_UNPRIV_STRLEN, GFP_KERNEL);
+
+		ret = proc_dostring(&tmp_table, write, buffer, lenp, ppos);
+		if (ret)
+			goto out;
+
+		ret = unprivileged_uffd_parse(tmp_table.data,
+					      UFFD_UNPRIV_STRLEN);
+	} else {
+		/* Leave space for "[]" */
+		int len = UFFD_UNPRIV_STRLEN * UFFD_UNPRIV_NUM + 2;
+
+		tmp_table.maxlen = len;
+		tmp_table.data = kmalloc(len, GFP_KERNEL);
+
+		unprivileged_uffd_dump(tmp_table.data, len);
+
+		ret = proc_dostring(&tmp_table, write, buffer, lenp, ppos);
+	}
+
+out:
+	if (tmp_table.data)
+		kfree(tmp_table.data);
+	return ret;
+}
+
 static int userfaultfd_wake_function(wait_queue_entry_t *wq, unsigned mode,
 				     int wake_flags, void *key)
 {
@@ -1955,6 +2046,11 @@ SYSCALL_DEFINE1(userfaultfd, int, flags)
 
 static int __init userfaultfd_init(void)
 {
+	char unpriv_uffd[UFFD_UNPRIV_STRLEN] =
+	    CONFIG_USERFAULTFD_UNPRIVILEGED_DEFAULT;
+
+	unprivileged_uffd_parse(unpriv_uffd, sizeof(unpriv_uffd));
+
 	userfaultfd_ctx_cachep = kmem_cache_create("userfaultfd_ctx_cache",
 						sizeof(struct userfaultfd_ctx),
 						0,
diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
index 37c9eba75c98..f53bc02ccffc 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -28,6 +28,11 @@
 #define UFFD_SHARED_FCNTL_FLAGS (O_CLOEXEC | O_NONBLOCK)
 #define UFFD_FLAGS_SET (EFD_SHARED_FCNTL_FLAGS)
 
+#define UFFD_UNPRIV_STRLEN 16
+int proc_unprivileged_userfaultfd(struct ctl_table *table, int write,
+				  void __user *buffer, size_t *lenp,
+				  loff_t *ppos);
+
 extern vm_fault_t handle_userfault(struct vm_fault *vmf, unsigned long reason);
 
 extern ssize_t mcopy_atomic(struct mm_struct *dst_mm, unsigned long dst_start,
diff --git a/init/Kconfig b/init/Kconfig
index c9386a365eea..d90caa4fed17 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1512,6 +1512,17 @@ config USERFAULTFD
 	  Enable the userfaultfd() system call that allows to intercept and
 	  handle page faults in userland.
 
+config USERFAULTFD_UNPRIVILEGED_DEFAULT
+        string "Default behavior for unprivileged userfault syscalls"
+        depends on USERFAULTFD
+        default "disabled"
+        help
+          Set this to "enabled" to allow userfaultfd syscalls from
+          unprivileged users.  Set this to "disabled" to forbid
+          userfaultfd syscalls from unprivileged users.  Set this to
+          "kvm" to forbid unpriviledged users but still allow users
+          who had enough permission to open /dev/kvm.
+
 config ARCH_HAS_MEMBARRIER_CALLBACKS
 	bool
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 7578e21a711b..5dc9f3d283dd 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -96,6 +96,9 @@
 #ifdef CONFIG_LOCKUP_DETECTOR
 #include <linux/nmi.h>
 #endif
+#ifdef CONFIG_USERFAULTFD
+#include <linux/userfaultfd_k.h>
+#endif
 
 #if defined(CONFIG_SYSCTL)
 
@@ -1704,6 +1707,14 @@ static struct ctl_table vm_table[] = {
 		.extra1		= (void *)&mmap_rnd_compat_bits_min,
 		.extra2		= (void *)&mmap_rnd_compat_bits_max,
 	},
+#endif
+#ifdef CONFIG_USERFAULTFD
+	{
+		.procname	= "unprivileged_userfaultfd",
+		.maxlen		= UFFD_UNPRIV_STRLEN,
+		.mode		= 0644,
+		.proc_handler	= proc_unprivileged_userfaultfd,
+	},
 #endif
 	{ }
 };
-- 
2.17.1

