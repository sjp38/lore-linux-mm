Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 53E106B0038
	for <linux-mm@kvack.org>; Sat,  5 Sep 2015 10:09:25 -0400 (EDT)
Received: by igcrk20 with SMTP id rk20so29953669igc.1
        for <linux-mm@kvack.org>; Sat, 05 Sep 2015 07:09:25 -0700 (PDT)
Received: from COL004-OMC1S14.hotmail.com (col004-omc1s14.hotmail.com. [65.55.34.24])
        by mx.google.com with ESMTPS id w1si10243062pdr.124.2015.09.05.07.09.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 05 Sep 2015 07:09:24 -0700 (PDT)
Message-ID: <COL130-W16C972B0457D5C7C9CB06B9560@phx.gbl>
From: Chen Gang <xili_gchen_5257@hotmail.com>
Subject: [PATCH] mm/mmap.c: Remove redundent 'get_area' function pointer in
 get_unmapped_area()
Date: Sat, 5 Sep 2015 22:09:24 +0800
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, "oleg@redhat.com" <oleg@redhat.com>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "pfeiner@google.com" <pfeiner@google.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "vishnu.ps@samsung.com" <vishnu.ps@samsung.com>, Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>

=0A=
>From a1bf4726f71d6d0394b41309944646fc806a8a0c Mon Sep 17 00:00:00 2001=0A=
From: Chen Gang <gang.chen.5i5j@gmail.com>=0A=
Date: Sat=2C 5 Sep 2015 21:51:08 +0800=0A=
Subject: [PATCH] mm/mmap.c: Remove redundent 'get_area' function pointer in=
=0A=
get_unmapped_area()=0A=
=0A=
Call the function pointer directly=2C then let code a bit simpler.=0A=
=0A=
Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>=0A=
---=0A=
=A0mm/mmap.c | 12 ++++++------=0A=
=A01 file changed=2C 6 insertions(+)=2C 6 deletions(-)=0A=
=0A=
diff --git a/mm/mmap.c b/mm/mmap.c=0A=
index 4db7cf0..39fd727 100644=0A=
--- a/mm/mmap.c=0A=
+++ b/mm/mmap.c=0A=
@@ -2012=2C10 +2012=2C8 @@ unsigned long=0A=
=A0get_unmapped_area(struct file *file=2C unsigned long addr=2C unsigned lo=
ng len=2C=0A=
=A0		unsigned long pgoff=2C unsigned long flags)=0A=
=A0{=0A=
-	unsigned long (*get_area)(struct file *=2C unsigned long=2C=0A=
-				 =A0unsigned long=2C unsigned long=2C unsigned long)=3B=0A=
-=0A=
=A0	unsigned long error =3D arch_mmap_check(addr=2C len=2C flags)=3B=0A=
+=0A=
=A0	if (error)=0A=
=A0		return error=3B=0A=
=A0=0A=
@@ -2023=2C10 +2021=2C12 @@ get_unmapped_area(struct file *file=2C unsigned=
 long addr=2C unsigned long len=2C=0A=
=A0	if (len> TASK_SIZE)=0A=
=A0		return -ENOMEM=3B=0A=
=A0=0A=
-	get_area =3D current->mm->get_unmapped_area=3B=0A=
=A0	if (file && file->f_op->get_unmapped_area)=0A=
-		get_area =3D file->f_op->get_unmapped_area=3B=0A=
-	addr =3D get_area(file=2C addr=2C len=2C pgoff=2C flags)=3B=0A=
+		addr =3D file->f_op->get_unmapped_area(file=2C addr=2C len=2C=0A=
+							pgoff=2C flags)=3B=0A=
+	else=0A=
+		addr =3D current->mm->get_unmapped_area(file=2C addr=2C len=2C=0A=
+							pgoff=2C flags)=3B=0A=
=A0	if (IS_ERR_VALUE(addr))=0A=
=A0		return addr=3B=0A=
=A0=0A=
--=A0=0A=
1.9.3=0A=
=0A=
 		 	   		  =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
