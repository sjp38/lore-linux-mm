Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 3B5CF6B0032
	for <linux-mm@kvack.org>; Fri,  5 Dec 2014 03:57:51 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so301726pab.33
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 00:57:51 -0800 (PST)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id dg8si20278893pdb.242.2014.12.05.00.57.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 05 Dec 2014 00:57:50 -0800 (PST)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Fri, 5 Dec 2014 16:57:38 +0800
Subject: [RFC] mm:add KPF_ZERO_PAGE flag for /proc/kpageflags
Message-ID: <35FD53F367049845BC99AC72306C23D103E688B313EE@CNBJMBX05.corpusers.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, 'Konstantin Khlebnikov' <koct9i@gmail.com>, "'akpm@linux-foundation.org'" <akpm@linux-foundation.org>, "'n-horiguchi@ah.jp.nec.com'" <n-horiguchi@ah.jp.nec.com>

This patch add KPF_ZERO_PAGE flag for zero_page,
so that userspace process can notice zero_page from
/proc/kpageflags, and then do memory analysis more accurately.

Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
---
 fs/proc/page.c                         | 3 +++
 include/uapi/linux/kernel-page-flags.h | 1 +
 2 files changed, 4 insertions(+)

diff --git a/fs/proc/page.c b/fs/proc/page.c
index 1e3187d..120dbf7 100644
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -136,6 +136,9 @@ u64 stable_page_flags(struct page *page)
 	if (PageBalloon(page))
 		u |=3D 1 << KPF_BALLOON;
=20
+	if (is_zero_pfn(page_to_pfn(page)))
+		u |=3D 1 << KPF_ZERO_PAGE;
+
 	u |=3D kpf_copy_bit(k, KPF_LOCKED,	PG_locked);
=20
 	u |=3D kpf_copy_bit(k, KPF_SLAB,		PG_slab);
diff --git a/include/uapi/linux/kernel-page-flags.h b/include/uapi/linux/ke=
rnel-page-flags.h
index 2f96d23..a6c4962 100644
--- a/include/uapi/linux/kernel-page-flags.h
+++ b/include/uapi/linux/kernel-page-flags.h
@@ -32,6 +32,7 @@
 #define KPF_KSM			21
 #define KPF_THP			22
 #define KPF_BALLOON		23
+#define KPF_ZERO_PAGE		24
=20
=20
 #endif /* _UAPILINUX_KERNEL_PAGE_FLAGS_H */
--=20
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
