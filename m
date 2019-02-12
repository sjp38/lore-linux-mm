Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E9F1C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 02:57:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D6A4A21773
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 02:57:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6A4A21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 675208E019C; Mon, 11 Feb 2019 21:57:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 624A28E000E; Mon, 11 Feb 2019 21:57:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 516488E019C; Mon, 11 Feb 2019 21:57:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 273C08E000E
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 21:57:39 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id y31so1279110qty.9
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 18:57:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=SlBeP/1Rk5D+vIK5AAJaqlVM0UwikLcHv9t1VRvv/Ec=;
        b=Fp1MtgRYd9HJScKJmCZ7LbxfxCWay1fbpI7YL1rkbjuSr2YrDTqnqAtNlkwaP2XIKz
         KiuFiW4YBkglymGCug3hXu96mkE0dr5nLdawJ17TN+p/gI16qZmE8R4sJNZad/Pi67TX
         JKxGQ+PnkVOCvd9maYXoLCt+UohejETDyc+dNwqujibo1Das5/ZNgO6wZqplrH6iHe5I
         +7nLrbnylWoH+m2AVZR/XtJvHpnWPC6nmaaEtBOL3O22gIch50eRmso4fLXQ5a1kQNd3
         DfI+xNT98arh2C5CskpFok2KoEa3f4ztO0xGgj9eCL9o6fQdglnpfoz1zRN42rkie46u
         uBmg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZXl+wqI2hl8FZWA4ZvA6SSOcaqI6+8O7RMWpxVrIv6JxpNWpPa
	JIZjm1aYRcVal3VDuwTHrBp4RX5OO8XHfKss/juCUX8ayd+/jNSxLqnVv7ppoiswhulIEG/T7IY
	2SEI05Z0MyutAgihj2RenT5ScY7j8MVIYy5Yp2x/p2Wk3g+BnI0gIPmonRyVDws3ueg==
X-Received: by 2002:a37:9604:: with SMTP id y4mr1035436qkd.279.1549940258951;
        Mon, 11 Feb 2019 18:57:38 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaYJrRWC7V30Zn2C4e3zmploK+nqFE3bHiV9XVVxOlAABWbm69YDu2QDcSvQSOTly4KmNFL
X-Received: by 2002:a37:9604:: with SMTP id y4mr1035422qkd.279.1549940258473;
        Mon, 11 Feb 2019 18:57:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549940258; cv=none;
        d=google.com; s=arc-20160816;
        b=CnZQdClU/taC187sBW5VINbVr/Jv/S3ZNwHYmaoCy8ScRqIM9LIJ8CFR9UIZxcdvyz
         FC2Ts2qFqH2u1G7s7ZtJW5clcnCZYTRSZ2rexOLWV8qK4x1mzutjW76BgruLuIHcJDeH
         EjFaV/wk/6GHnsVYpmRs/5pQziC8TgDKrTK90VdmuAziwr+quCYK+nfMljH81zy/8QAq
         3sKtBRKNhIAmquPgf7YiVMFILb6UA35TyFyUbYujaanUc+qbGT9QLjRKZ58FYsR2M36C
         9cRVW8VlTfy74EJr9or8FZizZp/jc5CMbrPVd0MyOJWPfqSiOmhIWyc/Vtqm1Nxd2I6Y
         FV7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=SlBeP/1Rk5D+vIK5AAJaqlVM0UwikLcHv9t1VRvv/Ec=;
        b=kug4NSqUL7zDJy6qShjRhLg2yKlZl5/qnSZ+iVxVH+eHSCHb7bn1EE/o58lpvsOBu0
         P6oomOA+GozDpwswl5CyhzlwgKJuBfR5JP44ua39KI22lLhK+SirrM0ic2GYRrTHu7HZ
         4D19YjUcAn6y7dNbliBNoadyFHZJ259gMJV++WQeMBEy448GyuK7vIVWdVC6CE1Plmz4
         ucFWg59iO/x3cIkC0jVWrWuG2BfAqG8KUKxCVrWgEIU1lnTAOMf+xdmNMcXD3UYK4hrT
         oYVQkZfytP9rOAx8IfFd024C3UcQW37k4DQ5RdZE6c/DP7iB/9ABrzXZLuPFjuEiL+qQ
         c1MQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l16si7527568qkg.3.2019.02.11.18.57.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 18:57:38 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A310B5947A;
	Tue, 12 Feb 2019 02:57:37 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id C350B600C6;
	Tue, 12 Feb 2019 02:57:31 +0000 (UTC)
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
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v2 05/26] mm: gup: allow VM_FAULT_RETRY for multiple times
Date: Tue, 12 Feb 2019 10:56:11 +0800
Message-Id: <20190212025632.28946-6-peterx@redhat.com>
In-Reply-To: <20190212025632.28946-1-peterx@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Tue, 12 Feb 2019 02:57:37 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is the gup counterpart of the change that allows the VM_FAULT_RETRY
to happen for more than once.

Signed-off-by: Peter Xu <peterx@redhat.com>
---
 mm/gup.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index fa75a03204c1..ba387aec0d80 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -528,7 +528,10 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 	if (*flags & FOLL_NOWAIT)
 		fault_flags |= FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT;
 	if (*flags & FOLL_TRIED) {
-		VM_WARN_ON_ONCE(fault_flags & FAULT_FLAG_ALLOW_RETRY);
+		/*
+		 * Note: FAULT_FLAG_ALLOW_RETRY and FAULT_FLAG_TRIED
+		 * can co-exist
+		 */
 		fault_flags |= FAULT_FLAG_TRIED;
 	}
 
@@ -943,17 +946,23 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 		/* VM_FAULT_RETRY triggered, so seek to the faulting offset */
 		pages += ret;
 		start += ret << PAGE_SHIFT;
+		lock_dropped = true;
 
+retry:
 		/*
 		 * Repeat on the address that fired VM_FAULT_RETRY
-		 * without FAULT_FLAG_ALLOW_RETRY but with
+		 * with both FAULT_FLAG_ALLOW_RETRY and
 		 * FAULT_FLAG_TRIED.
 		 */
 		*locked = 1;
-		lock_dropped = true;
 		down_read(&mm->mmap_sem);
 		ret = __get_user_pages(tsk, mm, start, 1, flags | FOLL_TRIED,
-				       pages, NULL, NULL);
+				       pages, NULL, locked);
+		if (!*locked) {
+			/* Continue to retry until we succeeded */
+			BUG_ON(ret != 0);
+			goto retry;
+		}
 		if (ret != 1) {
 			BUG_ON(ret > 1);
 			if (!pages_done)
-- 
2.17.1

