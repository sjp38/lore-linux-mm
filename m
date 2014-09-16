Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id A17BA6B0038
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 21:47:15 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id v10so7514534pde.5
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 18:47:15 -0700 (PDT)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id j2si26457977pdr.83.2014.09.15.18.47.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Sep 2014 18:47:14 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Tue, 16 Sep 2014 09:44:15 +0800
Subject: [PATCH v2] arm:extend __init_end to a page align address
Message-ID: <35FD53F367049845BC99AC72306C23D103D6DB49160B@CNBJMBX05.corpusers.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>, Jiang Liu <jiang.liu@huawei.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, Will Deacon <Will.Deacon@arm.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>

this patch change the __init_end address to a
page align address, so that free_initmem() can
free the whole .init section, because if the end
address is not page aligned, it will round down to
a page align address, then the tail unligned page
will not be freed.

Signed-off-by: wang <yalin.wang2010@gmail.com>
---
 arch/arm/kernel/vmlinux.lds.S     | 2 +-
 arch/arm64/kernel/vmlinux.lds.S   | 2 +-
 include/asm-generic/vmlinux.lds.h | 2 ++
 3 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/arch/arm/kernel/vmlinux.lds.S b/arch/arm/kernel/vmlinux.lds.S
index 6f57cb9..8e95aa4 100644
--- a/arch/arm/kernel/vmlinux.lds.S
+++ b/arch/arm/kernel/vmlinux.lds.S
@@ -219,8 +219,8 @@ SECTIONS
 	__data_loc =3D ALIGN(4);		/* location in binary */
 	. =3D PAGE_OFFSET + TEXT_OFFSET;
 #else
-	__init_end =3D .;
 	. =3D ALIGN(THREAD_SIZE);
+	__init_end =3D .;
 	__data_loc =3D .;
 #endif
=20
diff --git a/arch/arm64/kernel/vmlinux.lds.S b/arch/arm64/kernel/vmlinux.ld=
s.S
index 97f0c04..edf8715 100644
--- a/arch/arm64/kernel/vmlinux.lds.S
+++ b/arch/arm64/kernel/vmlinux.lds.S
@@ -97,9 +97,9 @@ SECTIONS
=20
 	PERCPU_SECTION(64)
=20
+	. =3D ALIGN(PAGE_SIZE);
 	__init_end =3D .;
=20
-	. =3D ALIGN(PAGE_SIZE);
 	_data =3D .;
 	_sdata =3D .;
 	RW_DATA_SECTION(64, PAGE_SIZE, THREAD_SIZE)
diff --git a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmlinu=
x.lds.h
index 5ba0360..aa70cbd 100644
--- a/include/asm-generic/vmlinux.lds.h
+++ b/include/asm-generic/vmlinux.lds.h
@@ -40,6 +40,8 @@
  * }
  *
  * [__init_begin, __init_end] is the init section that may be freed after =
init
+ * 	// __init_begin and __init_end should be page aligned, so that we can
+ *	// free the whole .init memory
  * [_stext, _etext] is the text section
  * [_sdata, _edata] is the data section
  *
--=20
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
