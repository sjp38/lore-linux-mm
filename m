Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 621296B0253
	for <linux-mm@kvack.org>; Sun, 12 Jul 2015 15:13:57 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so194890200pac.2
        for <linux-mm@kvack.org>; Sun, 12 Jul 2015 12:13:57 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id qm10si24706757pdb.138.2015.07.12.12.13.56
        for <linux-mm@kvack.org>;
        Sun, 12 Jul 2015 12:13:56 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <1436550130-112636-27-git-send-email-kirill.shutemov@linux.intel.com>
References: <1436550130-112636-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1436550130-112636-27-git-send-email-kirill.shutemov@linux.intel.com>
Subject: RE: [PATCH 26/36] mm: rework mapcount accounting to enable 4k mapping
 of THPs
Content-Transfer-Encoding: 7bit
Message-Id: <20150712191350.7E8D190@black.fi.intel.com>
Date: Sun, 12 Jul 2015 22:13:50 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Kirill A. Shutemov wrote:
>  TESTPAGEFLAG_FALSE(TransHuge)
>  TESTPAGEFLAG_FALSE(TransCompound)
>  TESTPAGEFLAG_FALSE(TransTail)
> +TESTPAGEFLAG_FALSE(DoubleMap)
> +	TESTSETFLAG_FALSE(DoubleMap)
> +	CLEARPAGEFLAG_NOOP(DoubleMap)
>  #endif
>  
>  /*

Fixlet for !THP:


diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 757a4b162242..eec24e6391d3 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -633,7 +633,7 @@ TESTPAGEFLAG_FALSE(TransCompound)
 TESTPAGEFLAG_FALSE(TransTail)
 TESTPAGEFLAG_FALSE(DoubleMap)
 	TESTSETFLAG_FALSE(DoubleMap)
-	CLEARPAGEFLAG_NOOP(DoubleMap)
+	TESTCLEARFLAG_FALSE(DoubleMap)
 #endif
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
