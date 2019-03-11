Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81BBFC10F0C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 09:37:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3EA5D2084D
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 09:37:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3EA5D2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C33F28E000F; Mon, 11 Mar 2019 05:37:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE1BD8E0002; Mon, 11 Mar 2019 05:37:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A84388E000F; Mon, 11 Mar 2019 05:37:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8363B8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 05:37:36 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id r9so4031646qkl.4
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 02:37:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=s3q6ORQAbgpYgrufMEFyMW+lw2VCVXcyiiCRY7039hg=;
        b=pE6knGaP34kXJHftsYlqpfLJZl52TXe8xpypMXt93vvS+wu4tDMcYZhV7eW8DddCUo
         I88t3UWin4DWJs1kyKuUiTo2uSbIQC/qmr+i6nu6CTtsq+63UqW8QCTikSvCJoVyilPL
         x2JUuFFlWuiWWvkQuJkKclgbP35OOGX1ZlSrW+69WggVZc4yKHzAAVzMuzRdqVwpI/xH
         ZidTvLtFtDl35A0uzrIrQd+5Qmw1XJfQ3WOO0v4UV2374wofXZQ+E0mn9T/0DpD3HI7z
         zdJWGCW61SpYbB2POn567cEHJjTBM+m6+y4pB4B98+hioUp4cMk4LzatpL8ILW9vPKHC
         WMEg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUDaveK3M20eS6RAxNU5RzFudPBOnQht7CNwF8AUbZdsg26KcBV
	tLE3E+ucj3lxy4R7QdhYJEAuabCPvt8V4nK0d/h2WRLnYSzP2u8NsRRPEZfzeLBtvez+jN9m/LN
	iPR2LUCQyHHLGRjeVZVX2jnqkuenc3Wg+ur3NJ+sQEH/PzV/V4+4O8x1/AMRYtjgtJA==
X-Received: by 2002:ac8:3802:: with SMTP id q2mr24313606qtb.325.1552297056334;
        Mon, 11 Mar 2019 02:37:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztyYHCX4apmZ+jyhAkjc2VD97vlPO/63AEG6OZwGsbFby0iQ/ENx6DUFkBdmCt8sCCUf5C
X-Received: by 2002:ac8:3802:: with SMTP id q2mr24313556qtb.325.1552297055091;
        Mon, 11 Mar 2019 02:37:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552297055; cv=none;
        d=google.com; s=arc-20160816;
        b=lrBixZjxBRCDJW+qjyeUm0j7XU0YGWxxzoCaLZ2JWAEwX1cMCERywFYEC5KA2LjE7H
         +9zam+CqJYpYALhBei5t3cp5DBIoMLVW/t/fcaDXSb9Axe1Hhj9gwyMZ25+ppQOSFZ6n
         AKlla8/ry2IyYJ/yMO3yguvYMLalnHoTzh/Bem696/kDPOjN2n/1DA5OjhDccU/xGD7B
         5qR22C5IK7aamFGhSVx9A1eowG2Jo2R/FvBQHWTB9Ub/vm42NNRTAJJbSu9LEyJDwuNS
         M7addhsulV5YDtPzzflGQLRY3m/vmad5PSePVSaBwNDEcVgpSVFqd+4q79+/Xx5Z6l+U
         UZVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=s3q6ORQAbgpYgrufMEFyMW+lw2VCVXcyiiCRY7039hg=;
        b=wNAj3fbvY7xjR6bx0HsDGlnn9F6Z8h82U4BvAImC4YOdR0ICMFMWJe5ndGy8y9ELqQ
         X/TfFXC91xqoWiNRp3wAGbWbnBCEQGB1IDuHsmzBM45IKpe2RbB3j/byzHjhVeEq8Hjs
         Ro+4NsCrMFaOkpe1hD9BBEx4hezHAJOC9MS4NxLHLbHznsCV+Ukzsj3nBMszYq2wo0jL
         LBTASVgiR9ECWub0y5JGZ11UqRuB9Jbyz3GnPNj42vVOfH1DdfDsQB8nVIsUltzTINQq
         5WmKWJw8hBclnOEJgrpGLpaz3ne20n6acUhjdEQfRVbzT5pNjbDwDJORQsjEhUtFEsOt
         hR1A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x60si102818qte.315.2019.03.11.02.37.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 02:37:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 399093086265;
	Mon, 11 Mar 2019 09:37:34 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id EAB725D705;
	Mon, 11 Mar 2019 09:37:22 +0000 (UTC)
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
Subject: [PATCH 2/3] kvm/mm: introduce MMF_USERFAULTFD_ALLOW flag
Date: Mon, 11 Mar 2019 17:37:00 +0800
Message-Id: <20190311093701.15734-3-peterx@redhat.com>
In-Reply-To: <20190311093701.15734-1-peterx@redhat.com>
References: <20190311093701.15734-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Mon, 11 Mar 2019 09:37:34 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Introduce a new MMF_USERFAULTFD_ALLOW flag and tag it upon the process
memory address space as long as the process opened the /dev/kvm once.
It'll be dropped automatically when fork() by MMF_INIT_TASK to reset
the userfaultfd permission.

Detecting the flag gives us a chance to open the green light for kvm
upon using userfaultfd when we want to make sure all the existing kvm
users will still be able to run their userspace programs without being
affected by the new unprivileged userfaultfd switch.

Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 include/linux/sched/coredump.h | 1 +
 virt/kvm/kvm_main.c            | 7 +++++++
 2 files changed, 8 insertions(+)

diff --git a/include/linux/sched/coredump.h b/include/linux/sched/coredump.h
index ecdc6542070f..9f6e71182892 100644
--- a/include/linux/sched/coredump.h
+++ b/include/linux/sched/coredump.h
@@ -72,6 +72,7 @@ static inline int get_dumpable(struct mm_struct *mm)
 #define MMF_DISABLE_THP		24	/* disable THP for all VMAs */
 #define MMF_OOM_VICTIM		25	/* mm is the oom victim */
 #define MMF_OOM_REAP_QUEUED	26	/* mm was queued for oom_reaper */
+#define MMF_USERFAULTFD_ALLOW	27	/* allow userfaultfd syscall */
 #define MMF_DISABLE_THP_MASK	(1 << MMF_DISABLE_THP)
 
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK |\
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index d237d3350a99..079f6ac00c36 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -3403,7 +3403,14 @@ static long kvm_dev_ioctl(struct file *filp,
 	return r;
 }
 
+static int kvm_dev_open(struct inode *inode, struct file *file)
+{
+	set_bit(MMF_USERFAULTFD_ALLOW, &current->mm->flags);
+	return 0;
+}
+
 static struct file_operations kvm_chardev_ops = {
+	.open		= kvm_dev_open,
 	.unlocked_ioctl = kvm_dev_ioctl,
 	.llseek		= noop_llseek,
 	KVM_COMPAT(kvm_dev_ioctl),
-- 
2.17.1

