Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0EF9C48BDF
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:21:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3349215EA
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:21:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3349215EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3568E6B0003; Wed, 19 Jun 2019 22:21:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 305FB8E0002; Wed, 19 Jun 2019 22:21:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F59C8E0001; Wed, 19 Jun 2019 22:21:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 020A56B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:21:45 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id n77so1700525qke.17
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 19:21:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=RJusdW+a9mihYhTYjKehRlZ9xNq8p5VU2+XjeF7nXj4=;
        b=W7q2qogdqad9iXmfwsvPP0ZoGFuvgJJxd9YnNbyzoa3aEJSJ0kEb92ThjoAAorgCtV
         dlr4m5So7wVZajO48i/nyLPWflKj8zmGKMzxk9yaJgtK0eHY+O9UEaXu8NCtBrHDXkXC
         47cgj6itHKVfdKydsxDgBTC1os9zp9PmGo3erhvJbAvUy/1QW5uX/s7aeZkxgoypJYCd
         16pkXdg+y0AhrDGDrj5M6XQrU1sWegBxDiG19BQXDpUYo1xBKfITm4zYs0XrNgifNrTQ
         EoWilsktueEOhWKwefN6x0ok8XhcZuGtQRay4EHgqQvxf/1qEzfP0G5KQvnlRTmVA4VE
         h8eQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXGY3QbhHRr5k0XHHUEUJunLp++MxRWZ88//cRlntXiNpJ9NT2/
	rDBSWYDaPSSW2V9TiHMZZNqM1i1/nRkoCjGKKm0v8aYEvrVa/8jm+BLynH2/EtDEvCbhCDQfi8S
	EeLCn0ff3TlzlvveQWIWsBZRG+NsfDnol2ubPzIucIDfTHmESHcZSQ7d23Ya4JhF5Qw==
X-Received: by 2002:a0c:818f:: with SMTP id 15mr10113724qvd.162.1560997304816;
        Wed, 19 Jun 2019 19:21:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz27imfL9fyKQjj8rqehA92lCfNqFGioZHDC6FsmZ93KFBUVrTPoKsH9oZYY/64J/kHMMP1
X-Received: by 2002:a0c:818f:: with SMTP id 15mr10113700qvd.162.1560997304362;
        Wed, 19 Jun 2019 19:21:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560997304; cv=none;
        d=google.com; s=arc-20160816;
        b=cc+ZQNHKjBXWp4FlGMJM2kkbESyHjqrljeZE17h5lUpvmHLTYBAIqPGDarMlkYyc04
         Eqkt0jd/tEgxARO/brBIqHIXif/5+8+AnCn1W3Ld/oBSKaJ0T13+Ab+bwz0MmmF3Mk/L
         NhCazJlNxOmdza5TdXjbrYGOawSBYSl8z7btw2ewsnIYr+S89MThG2nyKS3AGSb6Jdsv
         1BgJloYl7iizNKi4yqCi3AZ8rfxxkITE62qitZaiOUQ+HA1SDYjMu5C+cOuGp1et0dVd
         RrNjDLFpiut/EeFD0chy0lh9Pi6r9vNB6GZIGWZTzH1tDwP4qv2o2zysTXbEZ+5cUh3j
         0wdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=RJusdW+a9mihYhTYjKehRlZ9xNq8p5VU2+XjeF7nXj4=;
        b=P4UAjsJMlGSXWaohgkpSDbszeDuGhazmcm29WV5DiVVZfgA3iPh/JT8hB9s0b8qWo/
         SF0PfsZlfILJODJtqEbka7HWSKyx6Fj1nISNKEvhT9apbvaVhaxodjkAhduBzKFIyCbK
         R/vNmyDEQkhtjXl02ioYf4lbVBzSmO+uEEd4hDHtO334Y1auAxKtNvGE5oC441x7t1up
         O5zFd/pyAsGpTeC6VQmQIayJclJfL4zz8/cH9Pa/49HqzkGFWCWdkbNvh0wZ3eI557/J
         neZySMHVEHadkwijM+PajidK7pUFFb0SuKCXuglJAlK6Qw8h8YCLqX9OUsyQvsT7gcyi
         uDxA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o4si8077028qkc.142.2019.06.19.19.21.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 19:21:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5EC3B3079B86;
	Thu, 20 Jun 2019 02:21:43 +0000 (UTC)
Received: from xz-x1.redhat.com (ovpn-12-78.pek2.redhat.com [10.72.12.78])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B29151001E6F;
	Thu, 20 Jun 2019 02:21:28 +0000 (UTC)
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
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Shaohua Li <shli@fb.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Rik van Riel <riel@redhat.com>
Subject: [PATCH v5 06/25] userfaultfd: wp: add helper for writeprotect check
Date: Thu, 20 Jun 2019 10:19:49 +0800
Message-Id: <20190620022008.19172-7-peterx@redhat.com>
In-Reply-To: <20190620022008.19172-1-peterx@redhat.com>
References: <20190620022008.19172-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Thu, 20 Jun 2019 02:21:43 +0000 (UTC)
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
Reviewed-by: Jerome Glisse <jglisse@redhat.com>
Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 include/linux/userfaultfd_k.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
index ac9d71e24b81..5dc247af0f2e 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -52,6 +52,11 @@ static inline bool userfaultfd_missing(struct vm_area_struct *vma)
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
@@ -96,6 +101,11 @@ static inline bool userfaultfd_missing(struct vm_area_struct *vma)
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
2.21.0

