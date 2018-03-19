Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 092C16B000C
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 14:18:01 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id w19-v6so8963933plq.2
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 11:18:01 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j88si341065pfe.324.2018.03.19.11.17.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Mar 2018 11:18:00 -0700 (PDT)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.4 115/134] x86/mm: Fix vmalloc_fault to use pXd_large
Date: Mon, 19 Mar 2018 19:06:38 +0100
Message-Id: <20180319171905.892026687@linuxfoundation.org>
In-Reply-To: <20180319171849.024066323@linuxfoundation.org>
References: <20180319171849.024066323@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Gratian Crisan <gratian.crisan@ni.com>, Toshi Kani <toshi.kani@hpe.com>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>

4.4-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Toshi Kani <toshi.kani@hpe.com>

commit 18a955219bf7d9008ce480d4451b6b8bf4483a22 upstream.

Gratian Crisan reported that vmalloc_fault() crashes when CONFIG_HUGETLBFS
is not set since the function inadvertently uses pXn_huge(), which always
return 0 in this case.  ioremap() does not depend on CONFIG_HUGETLBFS.

Fix vmalloc_fault() to call pXd_large() instead.

Fixes: f4eafd8bcd52 ("x86/mm: Fix vmalloc_fault() to handle large pages properly")
Reported-by: Gratian Crisan <gratian.crisan@ni.com>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: stable@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: Borislav Petkov <bp@alien8.de>
Cc: Andy Lutomirski <luto@kernel.org>
Link: https://lkml.kernel.org/r/20180313170347.3829-2-toshi.kani@hpe.com
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/x86/mm/fault.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -287,7 +287,7 @@ static noinline int vmalloc_fault(unsign
 	if (!pmd_k)
 		return -1;
 
-	if (pmd_huge(*pmd_k))
+	if (pmd_large(*pmd_k))
 		return 0;
 
 	pte_k = pte_offset_kernel(pmd_k, address);
@@ -407,7 +407,7 @@ static noinline int vmalloc_fault(unsign
 	if (pud_none(*pud) || pud_pfn(*pud) != pud_pfn(*pud_ref))
 		BUG();
 
-	if (pud_huge(*pud))
+	if (pud_large(*pud))
 		return 0;
 
 	pmd = pmd_offset(pud, address);
@@ -418,7 +418,7 @@ static noinline int vmalloc_fault(unsign
 	if (pmd_none(*pmd) || pmd_pfn(*pmd) != pmd_pfn(*pmd_ref))
 		BUG();
 
-	if (pmd_huge(*pmd))
+	if (pmd_large(*pmd))
 		return 0;
 
 	pte_ref = pte_offset_kernel(pmd_ref, address);
