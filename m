Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id A6488800CA
	for <linux-mm@kvack.org>; Fri,  7 Nov 2014 02:04:38 -0500 (EST)
Received: by mail-ie0-f174.google.com with SMTP id x19so4619271ier.33
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 23:04:38 -0800 (PST)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id b6si13583540icm.44.2014.11.06.23.04.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 23:04:37 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH -mm v7 03/13] pagewalk: add walk_page_vma()
Date: Fri, 7 Nov 2014 07:01:56 +0000
Message-ID: <1415343692-6314-4-git-send-email-n-horiguchi@ah.jp.nec.com>
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

Introduces walk_page_vma(), which is useful for the callers which want to
walk over a given vma.  It's used by later patches.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
ChangeLog v3:
- check walk_page_test's return value instead of walk->skip
---
 include/linux/mm.h |  1 +
 mm/pagewalk.c      | 18 ++++++++++++++++++
 2 files changed, 19 insertions(+)

diff --git mmotm-2014-11-05-16-01.orig/include/linux/mm.h mmotm-2014-11-05-=
16-01/include/linux/mm.h
index 25a4cf75b575..1022cc27150e 100644
--- mmotm-2014-11-05-16-01.orig/include/linux/mm.h
+++ mmotm-2014-11-05-16-01/include/linux/mm.h
@@ -1157,6 +1157,7 @@ struct mm_walk {
=20
 int walk_page_range(unsigned long addr, unsigned long end,
 		struct mm_walk *walk);
+int walk_page_vma(struct vm_area_struct *vma, struct mm_walk *walk);
 void free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
 		unsigned long end, unsigned long floor, unsigned long ceiling);
 int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
diff --git mmotm-2014-11-05-16-01.orig/mm/pagewalk.c mmotm-2014-11-05-16-01=
/mm/pagewalk.c
index d9cc3caae802..4c9a653ba563 100644
--- mmotm-2014-11-05-16-01.orig/mm/pagewalk.c
+++ mmotm-2014-11-05-16-01/mm/pagewalk.c
@@ -272,3 +272,21 @@ int walk_page_range(unsigned long start, unsigned long=
 end,
 	} while (start =3D next, start < end);
 	return err;
 }
+
+int walk_page_vma(struct vm_area_struct *vma, struct mm_walk *walk)
+{
+	int err;
+
+	if (!walk->mm)
+		return -EINVAL;
+
+	VM_BUG_ON(!rwsem_is_locked(&walk->mm->mmap_sem));
+	VM_BUG_ON(!vma);
+	walk->vma =3D vma;
+	err =3D walk_page_test(vma->vm_start, vma->vm_end, walk);
+	if (err > 0)
+		return 0;
+	if (err < 0)
+		return err;
+	return __walk_page_range(vma->vm_start, vma->vm_end, walk);
+}
--=20
2.2.0.rc0.2.gf745acb

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
