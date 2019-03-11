Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFFABC43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 09:37:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 680EB2084D
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 09:37:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 680EB2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 025788E0010; Mon, 11 Mar 2019 05:37:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F160D8E0002; Mon, 11 Mar 2019 05:37:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E059D8E0010; Mon, 11 Mar 2019 05:37:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id BAA588E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 05:37:43 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id f15so900005qtk.16
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 02:37:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=XR4pYl9tGrZmg1P3ZFPkJ/fJzo0KOPocn85f2y3YdsI=;
        b=bU/Af+I6rY7kAetcyUiom7sCu4mw0x2kRuXBy3vchHKWcAZjMhmJlPBwMxGc7wkaXb
         LAB9jFC7tTCfmqoQOYxFx28IPPfdtV8LEp39vTfj7kcw4GvVfkAdsSH6NjUOpqVB/k8f
         St3h6RAPMVF+9v1UtgvQyR+17cH2D2ptGVQiWWFUVMQ5dbP2cm5mUjHVqnC5CdbAz/6o
         noOsypmNwIuBZAYaFp5dtukv5VRM3/+qSd+pI1QgXWpW+YicT0P6mrqsvCxDhRKgw+GA
         O16tPVMf52pxunN6PdsqJNbVsSPIdQDD2ZJd8xgdLIPi+l7pKNHrqQwoEdDWTFiG0iBe
         m4Gg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU+uAwI3+rNFiy1aU9SGWW6U7/qO+zeSPBtCfk4SRU0ZAryD25o
	spiu/5QvQY0FsBwA4i8d/GBadgDxuP/OyjjnsTBeS5i6HGRmJvqunJiZ+C5Uj3eT1pdtBvCnD7R
	zLA1P7w06GTxpMc79+lo/wC75yuj7iKmuCTBKGffMjvXWC4WQv9EdmkJwL6mVLJ9ONA==
X-Received: by 2002:a37:7e83:: with SMTP id z125mr15663075qkc.351.1552297063503;
        Mon, 11 Mar 2019 02:37:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzErwavpn/Vxz2Br4Fuy06JFXA/O8aHcufg5EN+e/yceLR/6pe6UvdKHaglG6oclbF9JJHK
X-Received: by 2002:a37:7e83:: with SMTP id z125mr15663048qkc.351.1552297062512;
        Mon, 11 Mar 2019 02:37:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552297062; cv=none;
        d=google.com; s=arc-20160816;
        b=0nVbaLBsgpdJcWJEeSO7RG2Reev6LtUTiDBaqn10tu7xi1GCgeHEVUMlKyOFjJ2rIc
         Qr0xcsh8RMJSAdr6tSCux3W+1+LArkL6pGV3W/1YHGYx/Cx2Ds5naY/X+PlhgAKt0uE9
         FouyCSExUBSRphDM+OaWuxmaGGecmlabKGQY5hccolrZbsLdyPQR3Lc06TY6UF3sxA6w
         u5xTGPcKzrmU5DrBdQTWiexubT3lPVFletCeOjVCEa0sNZbWF8WkCM7ql4LqzNr7TlVz
         4fcKf47X+ZwH3qdUfq9OFVJBRFgvRjQEXbSirzYuBc8OnAnss6F6dSQcVuGg8x4Agxdr
         AELA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=XR4pYl9tGrZmg1P3ZFPkJ/fJzo0KOPocn85f2y3YdsI=;
        b=BwlST+cW+D32jbaTOTXo4h76OJ+E1+TXvsS2/HVEF/Hi/AYdv8t2ajIRfqIEk//lsi
         /IgeWUCVKS/DjmnEmBLawngdvv2In15JYd+oWd1rjYHF1c7PTPUgLy3XaxkerI4QRPi+
         gQC75NcHjv64i6PKYm4o19Ed9WIWZKnsvQ0cEjEuBSPz27Z6axj3sX02t4kpd09kAssF
         aBKXPB8fDHnsk292GvUd0QRuzlcZABhjSeUkkuHIFyybfSq7CKxFaa3HXSmjxI98fJdP
         wbcrPyCMLgKFuGFb67h7zqSxljo/a6aoFriYzZQYckFvcdkuw0gASYqldzR0QXz6IX/O
         hAUg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u27si1041902qtk.279.2019.03.11.02.37.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 02:37:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A7D2EC002965;
	Mon, 11 Mar 2019 09:37:41 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B3B195D705;
	Mon, 11 Mar 2019 09:37:34 +0000 (UTC)
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
Subject: [PATCH 3/3] userfaultfd: apply unprivileged_userfaultfd check
Date: Mon, 11 Mar 2019 17:37:01 +0800
Message-Id: <20190311093701.15734-4-peterx@redhat.com>
In-Reply-To: <20190311093701.15734-1-peterx@redhat.com>
References: <20190311093701.15734-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Mon, 11 Mar 2019 09:37:41 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Apply the unprivileged_userfaultfd check when doing userfaultfd
syscall.  We didn't check it in other paths of userfaultfd (e.g., the
ioctl() path) because we don't want to drag down the fast path of
userfaultfd, as suggested by Andrea.

Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
Suggested-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 fs/userfaultfd.c | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index c2188464555a..effdcfc88629 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -951,6 +951,28 @@ void userfaultfd_unmap_complete(struct mm_struct *mm, struct list_head *uf)
 	}
 }
 
+/* Whether current process allows to use userfaultfd syscalls */
+static bool userfaultfd_allowed(void)
+{
+	bool allowed = false;
+
+	switch (unprivileged_userfaultfd) {
+	case UFFD_UNPRIV_ENABLED:
+		allowed = true;
+		break;
+	case UFFD_UNPRIV_KVM:
+		allowed = !!test_bit(MMF_USERFAULTFD_ALLOW,
+				     &current->mm->flags);
+		/* Fall through */
+	case UFFD_UNPRIV_DISABLED:
+		allowed = allowed || ns_capable(current_user_ns(),
+						CAP_SYS_PTRACE);
+		break;
+	}
+
+	return allowed;
+}
+
 static int userfaultfd_release(struct inode *inode, struct file *file)
 {
 	struct userfaultfd_ctx *ctx = file->private_data;
@@ -2018,6 +2040,9 @@ SYSCALL_DEFINE1(userfaultfd, int, flags)
 	BUILD_BUG_ON(UFFD_CLOEXEC != O_CLOEXEC);
 	BUILD_BUG_ON(UFFD_NONBLOCK != O_NONBLOCK);
 
+	if (!userfaultfd_allowed())
+		return -EPERM;
+
 	if (flags & ~UFFD_SHARED_FCNTL_FLAGS)
 		return -EINVAL;
 
-- 
2.17.1

