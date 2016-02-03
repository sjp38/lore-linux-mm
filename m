Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id ADBEA6B0005
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 23:15:45 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id ho8so6121257pac.2
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 20:15:45 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id q66si6331800pfi.84.2016.02.02.20.15.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Feb 2016 20:15:45 -0800 (PST)
Subject: Re: [PATCH] mm/hugetlb: fix gigantic page initialization/allocation
References: <1454452420-25007-1-git-send-email-mike.kravetz@oracle.com>
 <alpine.DEB.2.10.1602021457500.9118@chino.kir.corp.google.com>
 <56B138F6.70704@oracle.com>
 <20160203030137.GA22446@hori1.linux.bs1.fc.nec.co.jp>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <56B17ED2.2070205@oracle.com>
Date: Tue, 2 Feb 2016 20:15:14 -0800
MIME-Version: 1.0
In-Reply-To: <20160203030137.GA22446@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Jerome Marchand <jmarchan@redhat.com>, Michal Hocko <mhocko@suse.cz>

On 02/02/2016 07:01 PM, Naoya Horiguchi wrote:
> On Tue, Feb 02, 2016 at 03:17:10PM -0800, Mike Kravetz wrote:
>> I agree.  Naoya did debug and provide fix via e-mail exchange.  He did not
>> sign-off and I could not tell if he was going to pursue.  My only intention
>> was to fix ASAP.
>>
>> More than happy to give Naoya credit.
> 
> Thank you! It's great if you append my signed-off below yours.
> 
> Naoya

Adding Naoya's sign off and Acks received

mm/hugetlb: fix gigantic page initialization/allocation

Attempting to preallocate 1G gigantic huge pages at boot time with
"hugepagesz=1G hugepages=1" on the kernel command line will prevent
booting with the following:

kernel BUG at mm/hugetlb.c:1218!

When mapcount accounting was reworked, the setting of compound_mapcount_ptr
in prep_compound_gigantic_page was overlooked.  As a result, the validation
of mapcount in free_huge_page fails.

The "BUG_ON" checks in free_huge_page were also changed to "VM_BUG_ON_PAGE"
to assist with debugging.

Fixes: af5642a8af ("mm: rework mapcount accounting to enable 4k mapping
of THPs")
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: David Rientjes <rientjes@google.com>
---
 mm/hugetlb.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 12908dc..d7a8024 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1214,8 +1214,8 @@ void free_huge_page(struct page *page)

 	set_page_private(page, 0);
 	page->mapping = NULL;
-	BUG_ON(page_count(page));
-	BUG_ON(page_mapcount(page));
+	VM_BUG_ON_PAGE(page_count(page), page);
+	VM_BUG_ON_PAGE(page_mapcount(page), page);
 	restore_reserve = PagePrivate(page);
 	ClearPagePrivate(page);

@@ -1286,6 +1286,7 @@ static void prep_compound_gigantic_page(struct
page *page, unsigned int order)
 		set_page_count(p, 0);
 		set_compound_head(p, page);
 	}
+	atomic_set(compound_mapcount_ptr(page), -1);
 }

 /*
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
