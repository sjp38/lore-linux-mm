Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8681BC43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:53:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51459206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:53:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51459206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E733D6B0008; Fri, 26 Apr 2019 00:53:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E20916B026E; Fri, 26 Apr 2019 00:53:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE9B26B026F; Fri, 26 Apr 2019 00:53:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id AD6F86B0008
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:53:25 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id e31so1906551qtb.0
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 21:53:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=dMjQIHNpFGSe7O5uqRGBwJx8Nml7amhMVaY9sZK8RHg=;
        b=poauBJeYmMthD+iW+vgbLReTFE0/u9TBgZK+fCtvSCMy/zyr/PSTHAi40NLoeKVVQ8
         u8h/5Nc/nGFstsfoQiETgCMaYSwE0S316ywwKLs5B1Sz8UYwsfKc7okuyr0wtU4hzpmW
         +6Eg2VuU4AbOMiyiI39cRRgkPL8crwvSM+eZwxyw0F4M5syszzg3711V/Nbu2T6EC+rM
         yQ+5EV2jQuUMgC/0GlTp2qS0V/+UOZUL3mnz29XIiA7gLItD1dE9JCexXhoMqw/DnBhN
         eJFnTbIVErQyQBW+jsYSCQNQ9qi7LuxoUBRjiPHebwE94L0cMyItVfASSSS4/zpAlG2x
         geHg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXxRXl/JyiLEVSHE3bORgDBasvRRvXGJKWuvW1Ni3apf0YmbXNC
	UDyYKJoyJ9u6FCpWZMxLrINuoKjQfR/3lnU6czmW2Z3dInYUnQAx7GgYytMwD5A9Rlpcv5iph2O
	ZjMlFxxDnfODxt+TqZiMb9J1PXtoKhiGCqhAgxP/pe+9Dtg1ogMtFT0d0X6m9tcqcNA==
X-Received: by 2002:a0c:b6c8:: with SMTP id h8mr33500077qve.67.1556254405512;
        Thu, 25 Apr 2019 21:53:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyYIWtJLRKGJUHSQfq8js4DWFFJJVNPebielrCgX2+Ye/D1ft4Ks48p0XcDAAeVfWI2J98x
X-Received: by 2002:a0c:b6c8:: with SMTP id h8mr33500052qve.67.1556254404986;
        Thu, 25 Apr 2019 21:53:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556254404; cv=none;
        d=google.com; s=arc-20160816;
        b=Kn3Cwxws/r9Z4ZWwWtRgl55Uj0pSY9/UevE55EgZ4NCP6oKtoOuNVdJ3Gzu/qBhWq+
         3tgcAGFhwJeZIifRkCwqeNpQzojfaXEMb9Af2M1osoxS9wGWXcR1NIcErTVDBjv3GRJC
         8avuKVXmY7kZYrvbcwH1nWGENyGqAEwUP86t88uTNww+ufXtwiuJ/C7j7swrKT7ixgGS
         PE/4YLVEd3U9rc8mLuaqG+Eu5wE01Tb49xXIskP0EOxSlHI7ivnfrIv/yqME8/6dFpZU
         hA698OyFv/gzqR1bUwrYUlaanY543L9mQ+xoCqfJ95rTZt4q4UOPzdpoNxH5/P4c4IkO
         mgAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=dMjQIHNpFGSe7O5uqRGBwJx8Nml7amhMVaY9sZK8RHg=;
        b=kZ/Z0W6q6fOV3gYfK3aE7jXjPjL+xDWXM3leeqIFZz4WEcRLmRCqtucZk9Z8iRYf8h
         IaCKnGpodTz9x+61x0pUEODncilMym+pTLAvoqVAnac6BWe9drdrN/pR8x8RBxDXcJwh
         mw5jSVhWS/gbpBJqLzGVZuI5ybADvKNjL2sDpAqhQEIMhr4jk/7kR/pDikjWsSy8IA1X
         9x9EvQT3iphNXZfsifOedDnsH0RpagCR4KtXo7lcfmGoBYoqLW7MdEjONYNfqvXMg15E
         MC1UlMwiKMTcirsXobLurn0Cqjvt3QuAJYxkS//1W3/O1Uzs3nUhasxz7b7myT4CE5db
         XjKA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m30si4101973qtg.171.2019.04.25.21.53.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 21:53:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3247C59458;
	Fri, 26 Apr 2019 04:53:24 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-15-205.nay.redhat.com [10.66.15.205])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E91DD17B21;
	Fri, 26 Apr 2019 04:53:16 +0000 (UTC)
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
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v4 09/27] userfaultfd: wp: userfaultfd_pte/huge_pmd_wp() helpers
Date: Fri, 26 Apr 2019 12:51:33 +0800
Message-Id: <20190426045151.19556-10-peterx@redhat.com>
In-Reply-To: <20190426045151.19556-1-peterx@redhat.com>
References: <20190426045151.19556-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Fri, 26 Apr 2019 04:53:24 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Implement helpers methods to invoke userfaultfd wp faults more
selectively: not only when a wp fault triggers on a vma with
vma->vm_flags VM_UFFD_WP set, but only if the _PAGE_UFFD_WP bit is set
in the pagetable too.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Jerome Glisse <jglisse@redhat.com>
Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 include/linux/userfaultfd_k.h | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
index 38f748e7186e..c6590c58ce28 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -14,6 +14,8 @@
 #include <linux/userfaultfd.h> /* linux/include/uapi/linux/userfaultfd.h */
 
 #include <linux/fcntl.h>
+#include <linux/mm.h>
+#include <asm-generic/pgtable_uffd.h>
 
 /*
  * CAREFUL: Check include/uapi/asm-generic/fcntl.h when defining
@@ -55,6 +57,18 @@ static inline bool userfaultfd_wp(struct vm_area_struct *vma)
 	return vma->vm_flags & VM_UFFD_WP;
 }
 
+static inline bool userfaultfd_pte_wp(struct vm_area_struct *vma,
+				      pte_t pte)
+{
+	return userfaultfd_wp(vma) && pte_uffd_wp(pte);
+}
+
+static inline bool userfaultfd_huge_pmd_wp(struct vm_area_struct *vma,
+					   pmd_t pmd)
+{
+	return userfaultfd_wp(vma) && pmd_uffd_wp(pmd);
+}
+
 static inline bool userfaultfd_armed(struct vm_area_struct *vma)
 {
 	return vma->vm_flags & (VM_UFFD_MISSING | VM_UFFD_WP);
@@ -104,6 +118,19 @@ static inline bool userfaultfd_wp(struct vm_area_struct *vma)
 	return false;
 }
 
+static inline bool userfaultfd_pte_wp(struct vm_area_struct *vma,
+				      pte_t pte)
+{
+	return false;
+}
+
+static inline bool userfaultfd_huge_pmd_wp(struct vm_area_struct *vma,
+					   pmd_t pmd)
+{
+	return false;
+}
+
+
 static inline bool userfaultfd_armed(struct vm_area_struct *vma)
 {
 	return false;
-- 
2.17.1

