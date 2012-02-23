Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 488BE6B004A
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 08:05:43 -0500 (EST)
Received: by vcbf13 with SMTP id f13so1103657vcb.14
        for <linux-mm@kvack.org>; Thu, 23 Feb 2012 05:05:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120222130659.d75b6f69.akpm@linux-foundation.org>
References: <CAJd=RBALNtedfq+PLPnGKd4i4D0mLiVPdW_7pWWopnSZNC_vqA@mail.gmail.com>
	<20120222130659.d75b6f69.akpm@linux-foundation.org>
Date: Thu, 23 Feb 2012 21:05:41 +0800
Message-ID: <CAJd=RBA53nS70Q7GEeskKFas-hfg4GKmUf=Zut5anSN0P+d1KA@mail.gmail.com>
Subject: Re: [PATCH] mm: hugetlb: bail out unmapping after serving reference page
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>

On Thu, Feb 23, 2012 at 5:06 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>
> Perhaps add a little comment to this explaining what's going on?
>
>
> It would be sufficient to do
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ref_page)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0break;
>
> This is more efficient, and doesn't make people worry about whether
> this value of `page' is the same as the one which
> pte_page(huge_ptep_get()) earlier returned.
>
Hi Andrew

It is re-prepared,

=3D=3D=3Dcut here=3D=3D=3D
From: Hillf Danton <dhillf@gmail.com>
Subject: [PATCH] mm: hugetlb: bail out unmapping after serving reference pa=
ge

When unmapping given VM range, we could bail out if a reference page is
supplied and is unmapped, which is a minor optimization.

Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/hugetlb.c	Wed Feb 22 19:34:12 2012
+++ b/mm/hugetlb.c	Thu Feb 23 20:13:06 2012
@@ -2280,6 +2280,10 @@ void __unmap_hugepage_range(struct vm_ar
 		if (pte_dirty(pte))
 			set_page_dirty(page);
 		list_add(&page->lru, &page_list);
+
+		/* Bail out after unmapping reference page if supplied */
+		if (ref_page)
+			break;
 	}
 	spin_unlock(&mm->page_table_lock);
 	flush_tlb_range(vma, start, end);
--


> Why do we evaluate `page' twice inside that loop anyway? =C2=A0And why do=
 we
> check for huge_pte_none() twice? =C2=A0It looks all messed up.
>

and a follow-up cleanup also attached.

Thanks
Hillf

=3D=3D=3Dcut here=3D=3D=3D
From: Hillf Danton <dhillf@gmail.com>
Subject: [PATCH] mm: hugetlb: cleanup duplicated code in unmapping vm range

When unmapping given VM range, a couple of code duplicate, such as pte_page=
()
and huge_pte_none(), so a cleanup needed to compact them together.

Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/hugetlb.c	Thu Feb 23 20:13:06 2012
+++ b/mm/hugetlb.c	Thu Feb 23 20:30:16 2012
@@ -2245,16 +2245,23 @@ void __unmap_hugepage_range(struct vm_ar
 		if (huge_pmd_unshare(mm, &address, ptep))
 			continue;

+		pte =3D huge_ptep_get(ptep);
+		if (huge_pte_none(pte))
+			continue;
+
+		/*
+		 * HWPoisoned hugepage is already unmapped and dropped reference
+		 */
+		if (unlikely(is_hugetlb_entry_hwpoisoned(pte)))
+			continue;
+
+		page =3D pte_page(pte);
 		/*
 		 * If a reference page is supplied, it is because a specific
 		 * page is being unmapped, not a range. Ensure the page we
 		 * are about to unmap is the actual page of interest.
 		 */
 		if (ref_page) {
-			pte =3D huge_ptep_get(ptep);
-			if (huge_pte_none(pte))
-				continue;
-			page =3D pte_page(pte);
 			if (page !=3D ref_page)
 				continue;

@@ -2267,16 +2274,6 @@ void __unmap_hugepage_range(struct vm_ar
 		}

 		pte =3D huge_ptep_get_and_clear(mm, address, ptep);
-		if (huge_pte_none(pte))
-			continue;
-
-		/*
-		 * HWPoisoned hugepage is already unmapped and dropped reference
-		 */
-		if (unlikely(is_hugetlb_entry_hwpoisoned(pte)))
-			continue;
-
-		page =3D pte_page(pte);
 		if (pte_dirty(pte))
 			set_page_dirty(page);
 		list_add(&page->lru, &page_list);
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
