Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id DD5B9440325
	for <linux-mm@kvack.org>; Mon,  5 Oct 2015 12:24:06 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so181419316pac.0
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 09:24:06 -0700 (PDT)
Received: from COL004-OMC1S7.hotmail.com (col004-omc1s7.hotmail.com. [65.55.34.17])
        by mx.google.com with ESMTPS id pk7si41337809pbb.160.2015.10.05.09.24.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 05 Oct 2015 09:24:06 -0700 (PDT)
Message-ID: <COL130-W360AE827EAE109246BEB25B9480@phx.gbl>
From: Chen Gang <xili_gchen_5257@hotmail.com>
Subject: [PATCH] mm/mmap.c: Do not initialize retval in mmap_pgoff()
Date: Tue, 6 Oct 2015 00:24:05 +0800
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, "oleg@redhat.com" <oleg@redhat.com>, "dave@stgolabs.net" <dave@stgolabs.net>, "pfeiner@google.com" <pfeiner@google.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "vishnu.ps@samsung.com" <vishnu.ps@samsung.com>
Cc: Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>

>From 71fbe2eb02be288558b62045dbf56825afb99cbb Mon Sep 17 00:00:00 2001=0A=
From: Chen Gang <gang.chen.5i5j@gmail.com>=0A=
Date: Tue=2C 6 Oct 2015 00:16:23 +0800=0A=
Subject: [PATCH] mm/mmap.c: Do not initialize retval in mmap_pgoff()=0A=
=0A=
When fget() fails=2C can return -EBADF directly.=0A=
=0A=
Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>=0A=
---=0A=
=A0mm/mmap.c | 5 ++---=0A=
=A01 file changed=2C 2 insertions(+)=2C 3 deletions(-)=0A=
=0A=
diff --git a/mm/mmap.c b/mm/mmap.c=0A=
index 1da4600..33fffaf 100644=0A=
--- a/mm/mmap.c=0A=
+++ b/mm/mmap.c=0A=
@@ -1412=2C13 +1412=2C13 @@ SYSCALL_DEFINE6(mmap_pgoff=2C unsigned long=2C =
addr=2C unsigned long=2C len=2C=0A=
=A0		unsigned long=2C fd=2C unsigned long=2C pgoff)=0A=
=A0{=0A=
=A0	struct file *file =3D NULL=3B=0A=
-	unsigned long retval =3D -EBADF=3B=0A=
+	unsigned long retval=3B=0A=
=A0=0A=
=A0	if (!(flags & MAP_ANONYMOUS)) {=0A=
=A0		audit_mmap_fd(fd=2C flags)=3B=0A=
=A0		file =3D fget(fd)=3B=0A=
=A0		if (!file)=0A=
-			goto out=3B=0A=
+			return -EBADF=3B=0A=
=A0		if (is_file_hugepages(file))=0A=
=A0			len =3D ALIGN(len=2C huge_page_size(hstate_file(file)))=3B=0A=
=A0		retval =3D -EINVAL=3B=0A=
@@ -1453=2C7 +1453=2C6 @@ SYSCALL_DEFINE6(mmap_pgoff=2C unsigned long=2C ad=
dr=2C unsigned long=2C len=2C=0A=
=A0out_fput:=0A=
=A0	if (file)=0A=
=A0		fput(file)=3B=0A=
-out:=0A=
=A0	return retval=3B=0A=
=A0}=0A=
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
