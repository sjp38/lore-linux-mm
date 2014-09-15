Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5CD336B003B
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 06:26:51 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id z10so5908169pdj.20
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 03:26:51 -0700 (PDT)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id m6si21971770pdk.214.2014.09.15.03.26.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Sep 2014 03:26:50 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Mon, 15 Sep 2014 18:26:43 +0800
Subject: [RFC Resend] arm:extend __init_end to a page align address
Message-ID: <35FD53F367049845BC99AC72306C23D103D6DB491607@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103CDBFBFB028@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103D6DB4915FB@CNBJMBX05.corpusers.net>
In-Reply-To: <35FD53F367049845BC99AC72306C23D103D6DB4915FB@CNBJMBX05.corpusers.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Will Deacon' <will.deacon@arm.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>

this patch change the __init_end address to a page align address, so that f=
ree_initmem()
can free the whole .init section, because if the end address is not page al=
igned,
it will round down to a page align address, then the tail unligned page wil=
l not be freed.

Signed-off-by: Yalin wang <yalin.wang@sonymobile.com>
---
 arch/arm/kernel/vmlinux.lds.S   | 2 +-
 arch/arm64/kernel/vmlinux.lds.S | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/arm/kernel/vmlinux.lds.S b/arch/arm/kernel/vmlinux.lds.S =
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
s.S index 97f0c04..edf8715 100644
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
--
1.9.2.msysgit.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
