Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id 95265800CA
	for <linux-mm@kvack.org>; Fri,  7 Nov 2014 02:05:28 -0500 (EST)
Received: by mail-yk0-f174.google.com with SMTP id q200so2028610ykb.5
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 23:05:28 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id t83si6739685ykc.162.2014.11.06.23.05.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 23:05:27 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH -mm v7 10/13] arch/powerpc/mm/subpage-prot.c: use walk->vma
 and walk_page_vma()
Date: Fri, 7 Nov 2014 07:02:02 +0000
Message-ID: <1415343692-6314-11-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1415343692-6314-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1415343692-6314-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Peter Feiner <pfeiner@google.com>, Jerome Marchand <jmarchan@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

We don't have to use mm_walk->private to pass vma to the callback function
because of mm_walk->vma. And walk_page_vma() is useful if we walk over a
single vma.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/powerpc/mm/subpage-prot.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git mmotm-2014-11-05-16-01.orig/arch/powerpc/mm/subpage-prot.c mmotm=
-2014-11-05-16-01/arch/powerpc/mm/subpage-prot.c
index 6c0b1f5f8d2c..fa9fb5b4c66c 100644
--- mmotm-2014-11-05-16-01.orig/arch/powerpc/mm/subpage-prot.c
+++ mmotm-2014-11-05-16-01/arch/powerpc/mm/subpage-prot.c
@@ -134,7 +134,7 @@ static void subpage_prot_clear(unsigned long addr, unsi=
gned long len)
 static int subpage_walk_pmd_entry(pmd_t *pmd, unsigned long addr,
 				  unsigned long end, struct mm_walk *walk)
 {
-	struct vm_area_struct *vma =3D walk->private;
+	struct vm_area_struct *vma =3D walk->vma;
 	split_huge_page_pmd(vma, addr, pmd);
 	return 0;
 }
@@ -163,9 +163,7 @@ static void subpage_mark_vma_nohuge(struct mm_struct *m=
m, unsigned long addr,
 		if (vma->vm_start >=3D (addr + len))
 			break;
 		vma->vm_flags |=3D VM_NOHUGEPAGE;
-		subpage_proto_walk.private =3D vma;
-		walk_page_range(vma->vm_start, vma->vm_end,
-				&subpage_proto_walk);
+		walk_page_vma(vma, &subpage_proto_walk);
 		vma =3D vma->vm_next;
 	}
 }
--=20
2.2.0.rc0.2.gf745acb

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
