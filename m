Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id A96F06B0031
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 17:46:36 -0400 (EDT)
Received: by mail-qg0-f53.google.com with SMTP id f51so700837qge.26
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 14:46:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id b42si1533917qgd.193.2014.04.08.14.46.34
        for <linux-mm@kvack.org>;
        Tue, 08 Apr 2014 14:46:34 -0700 (PDT)
Date: Tue, 08 Apr 2014 17:46:25 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <53446e3a.2d508c0a.1866.ffff8020SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <6B2BA408B38BA1478B473C31C3D2074E30981E3EDC@SV-EXCHANGE1.Corp.FC.LOCAL>
References: <534462dd./BWAtkVlKQGnheFN%akpm@linux-foundation.org>
 <1396991970-aj1xjt2j@n-horiguchi@ah.jp.nec.com>
 <6B2BA408B38BA1478B473C31C3D2074E30981E3EDC@SV-EXCHANGE1.Corp.FC.LOCAL>
Subject: [PATCH] mm/hugetlb.c: add cond_resched_lock() in
 return_unused_surplus_pages()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Motohiro.Kosaki@us.fujitsu.com
Cc: mhocko@suse.cz, kosaki.motohiro@jp.fujitsu.com, iamjoonsoo.kim@lge.com, aneesh.kumar@linux.vnet.ibm.com, m.mizuma@jp.fujitsu.com, linux-mm@kvack.org

On Tue, Apr 08, 2014 at 02:21:22PM -0700, Motohiro Kosaki wrote:
> Naoya
> 
> > -----Original Message-----
> > From: Naoya Horiguchi [mailto:n-horiguchi@ah.jp.nec.com]
> > Sent: Tuesday, April 08, 2014 5:20 PM
> > To: akpm@linux-foundation.org
> > Cc: mhocko@suse.cz; Motohiro Kosaki JP; iamjoonsoo.kim@lge.com; aneesh.kumar@linux.vnet.ibm.com; m.mizuma@jp.fujitsu.com
> > Subject: Re: [merged] mm-hugetlb-fix-softlockup-when-a-large-number-of-hugepages-are-freed.patch removed from -mm tree
> > 
> > Hi Andrew,
> > # off list
> > 
> > This patch is obsolete and latest version is ver.2.
> > http://www.spinics.net/lists/linux-mm/msg71283.html
> > Could you queue the new one to go to mainline?
> 
> [merged] mean the patch has already been merged the linus tree. So, it can be changed. Please make
> an incremental patch.

Here it is.

Thanks,
Naoya Horiguchi
---
Subject: [PATCH] mm/hugetlb.c: add cond_resched_lock() in return_unused_surplus_pages()

From: "Mizuma, Masayoshi" <m.mizuma@jp.fujitsu.com>

soft lockup in freeing gigantic hugepage fixed in commit 55f67141a892
"mm: hugetlb: fix softlockup when a large number of hugepages are freed."
can happen in return_unused_surplus_pages(), so let's fix it.

Signed-off-by: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: <stable@vger.kernel.org>
---
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 7d57af2..761ef5b 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1160,6 +1160,7 @@ static void return_unused_surplus_pages(struct hstate *h,
 	while (nr_pages--) {
 		if (!free_pool_huge_page(h, &node_states[N_MEMORY], 1))
 			break;
+		cond_resched_lock(&hugetlb_lock);
 	}
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
