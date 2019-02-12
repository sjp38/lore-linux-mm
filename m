Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 482A8C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 02:57:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0825E2084D
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 02:57:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0825E2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 931918E0115; Mon, 11 Feb 2019 21:57:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E2698E000E; Mon, 11 Feb 2019 21:57:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D14B8E0115; Mon, 11 Feb 2019 21:57:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 526188E000E
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 21:57:57 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id m37so1261871qte.10
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 18:57:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Rn84y8C8A09oYMyr3TKfoYKiYwkNmhvpkXr89LUWW7o=;
        b=ELXPjMoJfZKqEotMXWY2QwKGbU1PZRWtok3Kb/ZP+vpODE/VadjFfC5o+LYT5mlZgN
         6Bw6Qt2J+fwXdqPjZugv/0Mm6dSTK6f7gz5D233KlWVGwI8BK+ykeo+GmA9s7x5IMuY+
         G9b9zRbdby6DvTZpe7hw8TBRPdWZPNiuBM64IeTaWEShVb5lhsaIf93V29Pgm0hdCQMA
         yDH+TSkgrBRjzOFXTj3EvTlR/SUlgssJMa1LLdD2begASNXYrgmnR1hothUGqmJaWXY8
         IUZ2fwAY2m08I4C5r/S4Q0oC96eRLv4q0nlcDUpzib5BxlpgXjdX/KyXfcQaq29Xex9E
         u2rg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubR9EAfZw3+JznJYCXfRkB7TbUWD6OZzkwKxCu8PcYt/8YUOW+I
	yni/jNDZ3lgfpQdpx9+fm7rtiGyJ9roX3oYN2i2wkx2ejns3o9zsEAUVxKxE2Lusww20cqZO7Mz
	uKsFewx/0iK6DxdmPvWidiuvrzxBzAlRJQx8UwCMw3HKnFeQ/oIL7xlO71w1Lp+i5AQ==
X-Received: by 2002:ac8:2614:: with SMTP id u20mr1154705qtu.28.1549940277120;
        Mon, 11 Feb 2019 18:57:57 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia0vGVCk7j2VNca+QOZ6g9U2Ro0tPYF8WkESVhhW6bFtOYCfnygxoM/OM7B6Cc1CRjEh99K
X-Received: by 2002:ac8:2614:: with SMTP id u20mr1154691qtu.28.1549940276739;
        Mon, 11 Feb 2019 18:57:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549940276; cv=none;
        d=google.com; s=arc-20160816;
        b=e8tg1t+Mv1Sj6imfwt38tv53io3nfuP2reMSI9Es9FjfmrGAGNRBevKEV7G4b3jbeD
         aLUK0qxjYclHiAdhZCKs7zR/OvbFVPpAqI0IFgZ/dPe9MtBspBmHDnZ8VwuF1uPKcWoI
         Jm4Giipnnwcc2uflV73BcfWU7+49MK4+CZysxOtv0oWvuqEAow62YNRhuP1h2zZhUtji
         mBogwST4/5ozC8JVrkxk9sxBGH+4v2RQRqwj5Oj17Ui4M/dWy+SbKUdsWrRPI7Axwrh5
         7EulYVcmsZWE92j90BRE0Kp/mv7A6cZVnvSZ0l01HRzuu7bt5NHncZQz6MnKZ7Uc57SI
         Bjlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Rn84y8C8A09oYMyr3TKfoYKiYwkNmhvpkXr89LUWW7o=;
        b=XeEe12e6Xd/v3WVjx2h2Jes8MscbyTc3orpBoXrwePUkFVzIbwjsGkGKVtQfGi+DuD
         D55zb6m4uKBTbZrusxowvw7avJb/BnS7QNx092VwNU9qsn5quP3UsEVDPNKN8KbpmGBi
         KDZSjOm5k5hmZ4Nq03YxolYTZw3BM3CEA38cg+66jcLw8QG4iY/D8D7IEOWz87kiZDNg
         8+vBIea0u2EEeI7Y6CfJ5EMx2Jo1GqRNkspd9Uxrpll2t1HH8WD9kjVXzJHPCDgnbOhT
         liLYDKhwtICHfwICkgmQRIRc9uc1iW4BeV4+yP4Q4GZvBYgBiy2JllZoqakMwFhpmr6l
         V3yw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d32si3831749qtd.307.2019.02.11.18.57.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 18:57:56 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DA48A81DEB;
	Tue, 12 Feb 2019 02:57:55 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 2D30F600C6;
	Tue, 12 Feb 2019 02:57:37 +0000 (UTC)
From: Peter Xu <peterx@redhat.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	peterx@redhat.com,
	Martin Cracauer <cracauer@cons.org>,
	Shaohua Li <shli@fb.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Rik van Riel <riel@redhat.com>
Subject: [PATCH v2 06/26] userfaultfd: wp: add helper for writeprotect check
Date: Tue, 12 Feb 2019 10:56:12 +0800
Message-Id: <20190212025632.28946-7-peterx@redhat.com>
In-Reply-To: <20190212025632.28946-1-peterx@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Tue, 12 Feb 2019 02:57:56 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Shaohua Li <shli@fb.com>

add helper for writeprotect check. Will use it later.

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Shaohua Li <shli@fb.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 include/linux/userfaultfd_k.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
index 37c9eba75c98..38f748e7186e 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -50,6 +50,11 @@ static inline bool userfaultfd_missing(struct vm_area_struct *vma)
 	return vma->vm_flags & VM_UFFD_MISSING;
 }
 
+static inline bool userfaultfd_wp(struct vm_area_struct *vma)
+{
+	return vma->vm_flags & VM_UFFD_WP;
+}
+
 static inline bool userfaultfd_armed(struct vm_area_struct *vma)
 {
 	return vma->vm_flags & (VM_UFFD_MISSING | VM_UFFD_WP);
@@ -94,6 +99,11 @@ static inline bool userfaultfd_missing(struct vm_area_struct *vma)
 	return false;
 }
 
+static inline bool userfaultfd_wp(struct vm_area_struct *vma)
+{
+	return false;
+}
+
 static inline bool userfaultfd_armed(struct vm_area_struct *vma)
 {
 	return false;
-- 
2.17.1

