Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 282D4C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 16:21:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D586A20863
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 16:21:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="MWC4/3S+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D586A20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6167D6B0003; Mon, 18 Mar 2019 12:21:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C3BE6B0006; Mon, 18 Mar 2019 12:21:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B4476B0007; Mon, 18 Mar 2019 12:21:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0713C6B0003
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 12:21:33 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id e5so19596898pfi.23
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 09:21:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=CgwRVS2Q+Iae+lbffdt/SU+OjpN+MyifpJVYq7Y3K8k=;
        b=dNiZLauXz+hfYpLxfbEWLqOypJzW73bTiK273WDHu5xYwunz6IkozDKYUY85c+xTxp
         uqY8mYYIKr0BU05Mu/Pp4TpUeusDpc04t9b2fYd00dMcthGnRHihbne9Ap3vlkuGonrz
         DF5NYjl+PTZFUY8zUqxWsFSI6SQ0ZZgcDGESvAaBIL1ZmfCe5AA4U0jnlwCpqxvCEu9m
         WgCo3FdtbfSbCeQrFMc+SYi70HR+TOqcAWThPAimXTNDUINJd/htIWKAQj42HHG5KAVZ
         VQ52jd7nU6/0lsex/ruGEGSJVy/XN2ntMCJdZECEO1vXZNzg/vjHVwg3+PqNEv4B8B+H
         A7rg==
X-Gm-Message-State: APjAAAWrWqwQm8lMYXtvVFiz0t0Pq7V26MiK7y5Z/MCU8VgPzmD+k82i
	D9j1k1D0BFFV5ZN5K9XN1sKv/QIc5jCiEFcnfC0aiiGoIjD6oucant7Y3DVF9JURDoMj9i3HGY9
	NDc39NxHz0BuKDw3J9SSwtylpztxxfrcG38AWQvNiW622mS0SSO0tFXxK8AP3ECEtLg==
X-Received: by 2002:a63:91c1:: with SMTP id l184mr208477pge.46.1552926092670;
        Mon, 18 Mar 2019 09:21:32 -0700 (PDT)
X-Received: by 2002:a63:91c1:: with SMTP id l184mr208402pge.46.1552926091607;
        Mon, 18 Mar 2019 09:21:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552926091; cv=none;
        d=google.com; s=arc-20160816;
        b=LJGDlR0MYMseQ18lyyzfEGoto590aqjA5U4Q0QMlvZE/0XzeamLhdcdWSg0fUy4f/G
         zEK+GBa81HimcCHvGRn8LQ8G1PYl4IhrEZYnFR44TWlnBoQ62o28r6l/NF+MhyB388Wp
         IHNKkiPyMxEDRt5tztHraxZuzshW86jd0Wrx8H1u/NOMgJ6kd4i0irndjmB29a0oPupv
         49jL94rsbJzBRj7IQ+Wg46WZMyygeCpNpASJLwAcTyEV6XrMvi3OSg7Wwt5Z5jMYAhWK
         g/P17dCXuoVH3Gy0v/IK+r87A6wTlj+Z4qQK2IYrGFubGtipSbY0RVUaoHVBWA7tpto5
         vhgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=CgwRVS2Q+Iae+lbffdt/SU+OjpN+MyifpJVYq7Y3K8k=;
        b=DIAEhJc3qnJbRE++ol31pdqDFjnuTbXrVRmGec0AbxzwEIBiVA6cmt7yBoxNAQ50zG
         0VzGIy3rceJY/SVKJ05UIYDFNlNutdEfcMf6Ooev+rXNPogba+jhgYCUSU3h5xFX/irk
         myRHLGtTRCuEMX/iesCiL2dx5w7fetNAparzxXW/uXfyZCjEbUWPLUGDW5GYqqMqSM2R
         zqRs+xIvdvcxRCy9oYh+uCZj3YCjaBS681f8Vlgz/1+/kzDmVNjP532Ybw8XfYguo68f
         7hG8qrRHo630qbB4Lmvxbcc+bzKgu3ItUNQ0ZdFTiSCm1FlA6S2TzS9pz8FgA3lyQuh5
         90SQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="MWC4/3S+";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d8sor15655766pgc.51.2019.03.18.09.21.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 09:21:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="MWC4/3S+";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=CgwRVS2Q+Iae+lbffdt/SU+OjpN+MyifpJVYq7Y3K8k=;
        b=MWC4/3S+X+/VHhs7voniM9phy/o7yqCWtKuyosSnpIUCAAnZP/Mn/DsNv3XRJweEef
         jZRIeMihSOp1ASm83jxCAnAw3ViWzpZEBFUOSHzcpfJkGeBaG6F/TBcR6Kz4BH0AIqBf
         Gzh9PBQPZ8pr/EcJVjRnUxjFWMrNxn3irZNRu3wMiyf1wognYBMph+ebK+gbMx7LhXoJ
         oV0M9D36FS81wHAnGWahxYbcx4RxJ7lvr83vXwqLdwO4IYJZouer23ny/kJ1LkOP6sHP
         AVVxXnLoumIaK6WbT6AKyhnGkge0WKU7awH8NUq8MTaMAlpkjQHFIeNFGlDycX5EI5GY
         xXFA==
X-Google-Smtp-Source: APXvYqyw1Bx/onz96XVk/VzfT2P30uQI4lOEdkGn1FqYErJitQaCHsJU2FF6AK2yAnsDrfL2aeQc4A==
X-Received: by 2002:a65:52c9:: with SMTP id z9mr5436469pgp.227.1552926091321;
        Mon, 18 Mar 2019 09:21:31 -0700 (PDT)
Received: from jordon-HP-15-Notebook-PC ([106.51.18.188])
        by smtp.gmail.com with ESMTPSA id h184sm24617707pfc.78.2019.03.18.09.21.29
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Mar 2019 09:21:30 -0700 (PDT)
Date: Mon, 18 Mar 2019 21:56:05 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, mike.kravetz@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@infradead.org
Subject: [PATCH] include/linux/hugetlb.h: Convert to use vm_fault_t
Message-ID: <20190318162604.GA31553@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

kbuild produces the below warning ->

tree: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
head:   5453a3df2a5eb49bc24615d4cf0d66b2aae05e5f
commit 3d3539018d2c ("mm: create the new vm_fault_t type")
reproduce:
        # apt-get install sparse
        git checkout 3d3539018d2cbd12e5af4a132636ee7fd8d43ef0
        make ARCH=x86_64 allmodconfig
        make C=1 CF='-fdiagnostic-prefix -D__CHECK_ENDIAN__'

>> mm/memory.c:3968:21: sparse: incorrect type in assignment (different
>> base types) @@    expected restricted vm_fault_t [usertype] ret @@
>> got e] ret @@
   mm/memory.c:3968:21:    expected restricted vm_fault_t [usertype] ret
   mm/memory.c:3968:21:    got int

This patch will convert to return vm_fault_t type for hugetlb_fault()
when CONFIG_HUGETLB_PAGE =n.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
---
 include/linux/hugetlb.h | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 087fd5f4..0ee502a 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -203,7 +203,6 @@ static inline void hugetlb_show_meminfo(void)
 #define pud_huge(x)	0
 #define is_hugepage_only_range(mm, addr, len)	0
 #define hugetlb_free_pgd_range(tlb, addr, end, floor, ceiling) ({BUG(); 0; })
-#define hugetlb_fault(mm, vma, addr, flags)	({ BUG(); 0; })
 #define hugetlb_mcopy_atomic_pte(dst_mm, dst_pte, dst_vma, dst_addr, \
 				src_addr, pagep)	({ BUG(); 0; })
 #define huge_pte_offset(mm, address, sz)	0
@@ -234,6 +233,13 @@ static inline void __unmap_hugepage_range(struct mmu_gather *tlb,
 {
 	BUG();
 }
+static inline vm_fault_t hugetlb_fault(struct mm_struct *mm,
+				struct vm_area_struct *vma, unsigned long address,
+				unsigned int flags)
+{
+	BUG();
+	return 0;
+}
 
 #endif /* !CONFIG_HUGETLB_PAGE */
 /*
-- 
1.9.1

