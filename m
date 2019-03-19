Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7220BC10F00
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 03:07:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3AC6C205F4
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 03:07:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3AC6C205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE0F56B0007; Mon, 18 Mar 2019 23:07:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C906F6B0008; Mon, 18 Mar 2019 23:07:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA72D6B000A; Mon, 18 Mar 2019 23:07:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 92A7E6B0007
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 23:07:46 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id d49so18499170qtd.15
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 20:07:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=h4r6W8lhBQGAfpEhniV5yNxj5IJM6e+DGMzsP5DmZi8=;
        b=FUI6ydv1M2bOio7PCzQcQy8BcNitzGR7H5rDfHewuoH9co0AK0Ivk9KrJ0i6A6BvDc
         khyFCQBJ+G34SoQn4DiBECYiwm6g34N0CXgtui0G7omhwPEaSiZqEiLv57ke48KTzSPY
         WbdD9Y96eEINv975T2Y5m/aGhxO99ZDv5yg5n8OyLSWYlc9IzzCq7Jiqcndm5NdOo8TC
         gQWHg1tNT4k7sKNoXDUZ9kYokgaCIwgIxVWqRD6/0pqek9Tsyz5Ai+sWb/6fU1kE2ejM
         tEi7/TcC29ybhGf7WcUOxt+koFxABsyVB5sgw3VQLwbloVMaHQPKxCfV/LB9N00Lol8C
         bccw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXSunZuWbJPXCuRCpolZp/P5UKggK8ku7OXJnq+Pssim3e4GQCG
	4r+ZqZtIUi3ZgfYtum8eIOTyXPBPSNL1NnPA8Oo/l51JIfm58uzAbobJ+Z+QcCdpu4yLm1sLlCP
	SNcM82nykTxWgN6W7ICYTVDHPzJhaAcUCRaw8+OO+sZL2G+7KIZKbIOT+Hh0OzB1b+g==
X-Received: by 2002:aed:3e13:: with SMTP id l19mr160546qtf.125.1552964866379;
        Mon, 18 Mar 2019 20:07:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxIy7zKIxVttBa4Bt4Osbhtal0bSYRtT6qFYSzo7QPO5SWfxtj7oxXNpSMNL5JZ3e5mdJnZ
X-Received: by 2002:aed:3e13:: with SMTP id l19mr160496qtf.125.1552964865140;
        Mon, 18 Mar 2019 20:07:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552964865; cv=none;
        d=google.com; s=arc-20160816;
        b=exY4K9Y9H9Wphh9n2cYBbbn+8tl6KAHNyegJ+AumYx8e/HIYdxRDW7g1+WbG5lOM+t
         EyVNqU72VWCdOlTYjv5bb8ELuYHy6rRwA7xJHCdQ9g/wKokMgEt8ICS9Hwsw+o+b/S2r
         a6cZSY+lt16vFPghtgLhQ1PwWI+GAh7hpwAXYnDwRvnKMQzdwmHI1ho8pciqGsiu/IlX
         iSz2WNZropvmOupMkGKs0eW9SbjleZXP2i6bROvD/0Q1qvtG2fNEDHCz4nsQIOhNvzIc
         CzoAxN+i1PTp5mz2cBE4zC/UBIopsLvYKfAXMRZq+6xrOP0cQn2rFlHNT5+YRSSw/o80
         qP2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=h4r6W8lhBQGAfpEhniV5yNxj5IJM6e+DGMzsP5DmZi8=;
        b=hLMuqAf8cPxvHh8lb1ROg3u+3VZkFYk8cNfquBysf8SHBbi85GJ0pbIs9XU6RaV4/x
         gSvAUFz/MHCw0kkIJHngvmQrKqBmO9kE5yiHvCI9pFVSYFFUE0NMXdR5wuhXmU33mWug
         XAk2YIGTQesaW4Tlz501daD72IoN372m43JV1AlevxXIWjhPBl0xPDQ81bIrPnsY5xzh
         Kz0T4FoO4QO+fKPUlOnFsBsU8Qbk7BFNArnLFHhb4+ZL9p3XPmRdTPSF0934NF/R7CZW
         qVKst/0Fw0GJnWhmgwAzNwaZeVu0kRNC+8dNyfnUirJj9GVlbIOXzk7rVOgX50H49Uu7
         aPBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z8si204075qvg.104.2019.03.18.20.07.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Mar 2019 20:07:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B6EC93082200;
	Tue, 19 Mar 2019 03:07:43 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7FCC25D75C;
	Tue, 19 Mar 2019 03:07:36 +0000 (UTC)
From: Peter Xu <peterx@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Paolo Bonzini <pbonzini@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Maxime Coquelin <maxime.coquelin@redhat.com>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	peterx@redhat.com,
	Martin Cracauer <cracauer@cons.org>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	linux-mm@kvack.org,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Kees Cook <keescook@chromium.org>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	linux-api@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH v2 1/1] userfaultfd/sysctl: add vm.unprivileged_userfaultfd
Date: Tue, 19 Mar 2019 11:07:22 +0800
Message-Id: <20190319030722.12441-2-peterx@redhat.com>
In-Reply-To: <20190319030722.12441-1-peterx@redhat.com>
References: <20190319030722.12441-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Tue, 19 Mar 2019 03:07:44 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add a global sysctl knob "vm.unprivileged_userfaultfd" to control
whether userfaultfd is allowed by unprivileged users.  When this is
set to zero, only privileged users (root user, or users with the
CAP_SYS_PTRACE capability) will be able to use the userfaultfd
syscalls.

Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
Suggested-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 Documentation/sysctl/vm.txt   | 12 ++++++++++++
 fs/userfaultfd.c              |  5 +++++
 include/linux/userfaultfd_k.h |  2 ++
 kernel/sysctl.c               | 12 ++++++++++++
 4 files changed, 31 insertions(+)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 187ce4f599a2..f146712f67bb 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -61,6 +61,7 @@ Currently, these files are in /proc/sys/vm:
 - stat_refresh
 - numa_stat
 - swappiness
+- unprivileged_userfaultfd
 - user_reserve_kbytes
 - vfs_cache_pressure
 - watermark_boost_factor
@@ -818,6 +819,17 @@ The default value is 60.
 
 ==============================================================
 
+unprivileged_userfaultfd
+
+This flag controls whether unprivileged users can use the userfaultfd
+syscalls.  Set this to 1 to allow unprivileged users to use the
+userfaultfd syscalls, or set this to 0 to restrict userfaultfd to only
+privileged users (with SYS_CAP_PTRACE capability).
+
+The default value is 1.
+
+==============================================================
+
 - user_reserve_kbytes
 
 When overcommit_memory is set to 2, "never overcommit" mode, reserve
diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 89800fc7dc9d..7e856a25cc2f 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -30,6 +30,8 @@
 #include <linux/security.h>
 #include <linux/hugetlb.h>
 
+int sysctl_unprivileged_userfaultfd __read_mostly = 1;
+
 static struct kmem_cache *userfaultfd_ctx_cachep __read_mostly;
 
 enum userfaultfd_state {
@@ -1921,6 +1923,9 @@ SYSCALL_DEFINE1(userfaultfd, int, flags)
 	struct userfaultfd_ctx *ctx;
 	int fd;
 
+	if (!sysctl_unprivileged_userfaultfd && !capable(CAP_SYS_PTRACE))
+		return -EPERM;
+
 	BUG_ON(!current->mm);
 
 	/* Check the UFFD_* constants for consistency.  */
diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
index 37c9eba75c98..ac9d71e24b81 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -28,6 +28,8 @@
 #define UFFD_SHARED_FCNTL_FLAGS (O_CLOEXEC | O_NONBLOCK)
 #define UFFD_FLAGS_SET (EFD_SHARED_FCNTL_FLAGS)
 
+extern int sysctl_unprivileged_userfaultfd;
+
 extern vm_fault_t handle_userfault(struct vm_fault *vmf, unsigned long reason);
 
 extern ssize_t mcopy_atomic(struct mm_struct *dst_mm, unsigned long dst_start,
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 7578e21a711b..9b8ff1881df9 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -66,6 +66,7 @@
 #include <linux/kexec.h>
 #include <linux/bpf.h>
 #include <linux/mount.h>
+#include <linux/userfaultfd_k.h>
 
 #include <linux/uaccess.h>
 #include <asm/processor.h>
@@ -1704,6 +1705,17 @@ static struct ctl_table vm_table[] = {
 		.extra1		= (void *)&mmap_rnd_compat_bits_min,
 		.extra2		= (void *)&mmap_rnd_compat_bits_max,
 	},
+#endif
+#ifdef CONFIG_USERFAULTFD
+	{
+		.procname	= "unprivileged_userfaultfd",
+		.data		= &sysctl_unprivileged_userfaultfd,
+		.maxlen		= sizeof(sysctl_unprivileged_userfaultfd),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &one,
+	},
 #endif
 	{ }
 };
-- 
2.17.1

