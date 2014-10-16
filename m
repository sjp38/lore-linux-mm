Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9B7766B0038
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 14:05:26 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id r10so3691607pdi.10
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 11:05:26 -0700 (PDT)
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com. [202.81.31.147])
        by mx.google.com with ESMTPS id xd1si19491491pab.234.2014.10.16.11.05.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 16 Oct 2014 11:05:25 -0700 (PDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 17 Oct 2014 04:05:20 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 9B9AC2BB0056
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 05:05:17 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s9GI7JWu6291548
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 05:07:20 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s9GI5Fsm014088
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 05:05:16 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] mm: Update generic gup implementation to handle hugepage directory
In-Reply-To: <20141016154228.GA12995@linaro.org>
References: <1413390888-4934-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20141016092529.GA1524@linaro.org> <871tq8kpqb.fsf@linux.vnet.ibm.com> <20141016154228.GA12995@linaro.org>
Date: Thu, 16 Oct 2014 23:35:10 +0530
Message-ID: <87ppdrki09.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: akpm@linux-foundation.org, Andrea Arcangeli <aarcange@redhat.com>, benh@kernel.crashing.org, mpe@ellerman.id.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, will.deacon@arm.com, catalin.marinas@arm.com, linux@arm.linux.org.uk

Steve Capper <steve.capper@linaro.org> writes:

> Can we not just add a:
> #define pgd_huge(pgd)		(0)
> above the "#endif /* CONFIG_HUGETLB_PAGE */" line in the second patch?
> (or, more precisely, prevent the second patch from removing this line).
>
> That way we get a clearer code overall?

it is strange to have both pmd_huge and pud_huge in hugetlb.h and
pgd_huge in page.h. But if that is what we want then we may need.


diff --git a/arch/powerpc/include/asm/page.h b/arch/powerpc/include/asm/page.h
index aa430ec14895..aeca81947dc6 100644
--- a/arch/powerpc/include/asm/page.h
+++ b/arch/powerpc/include/asm/page.h
@@ -383,6 +383,7 @@ static inline int hugepd_ok(hugepd_t hpd)
 int pgd_huge(pgd_t pgd);
 #else /* CONFIG_HUGETLB_PAGE */
 #define is_hugepd(pdep)			0
+#define pgd_huge(pgd)			0
 #endif /* CONFIG_HUGETLB_PAGE */
 #define __hugepd(x) ((hugepd_t) { (x) })
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
