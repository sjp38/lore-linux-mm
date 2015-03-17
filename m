Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9BCCE6B0038
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 04:33:56 -0400 (EDT)
Received: by pagr17 with SMTP id r17so3440508pag.0
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 01:33:56 -0700 (PDT)
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com. [202.81.31.145])
        by mx.google.com with ESMTPS id n10si27873978pap.20.2015.03.17.01.33.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Mar 2015 01:33:55 -0700 (PDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 17 Mar 2015 18:33:48 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 08960357804C
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 19:33:44 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t2H8XZIt48300128
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 19:33:43 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t2H8X9bN021279
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 19:33:10 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCHv4 12/24] thp: PMD splitting without splitting compound page
In-Reply-To: <1425486792-93161-13-git-send-email-kirill.shutemov@linux.intel.com>
References: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com> <1425486792-93161-13-git-send-email-kirill.shutemov@linux.intel.com>
Date: Tue, 17 Mar 2015 14:02:36 +0530
Message-ID: <878uewausb.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:

> Current split_huge_page() combines two operations: splitting PMDs into
> tables of PTEs and splitting underlying compound page. This patch
> changes split_huge_pmd() implementation to split the given PMD without
> splitting other PMDs this page mapped with or underlying compound page.
>
> In order to do this we have to get rid of tail page refcounting, which
> uses _mapcount of tail pages. Tail page refcounting is needed to be able
> to split THP page at any point: we always know which of tail pages is
> pinned (i.e. by get_user_pages()) and can distribute page count
> correctly.
>
> We can avoid this by allowing split_huge_page() to fail if the compound
> page is pinned. This patch removes all infrastructure for tail page
> refcounting and make split_huge_page() to always return -EBUSY. All
> split_huge_page() users already know how to handle its fail. Proper
> implementation will be added later.
>
> Without tail page refcounting, implementation of split_huge_pmd() is
> pretty straight-forward.
>

mm/gup.c: In function =E2=80=98gup_huge_pgd=E2=80=99:
mm/gup.c:1183:2: error: =E2=80=98tail=E2=80=99 undeclared (first use in thi=
s function)
  tail =3D page;
  ^
diff --git a/mm/gup.c b/mm/gup.c
index 2f776850108c..141b5a81cf8a 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1180,7 +1180,6 @@ static int gup_huge_pgd(pgd_t orig, pgd_t *pgdp, unsi=
gned long addr,
 	refs =3D 0;
 	head =3D pgd_page(orig);
 	page =3D head + ((addr & ~PGDIR_MASK) >> PAGE_SHIFT);
-	tail =3D page;
 	do {
 		VM_BUG_ON_PAGE(compound_head(page) !=3D head, page);
 		pages[*nr] =3D page;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
