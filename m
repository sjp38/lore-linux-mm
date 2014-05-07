Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8D9ED6B0035
	for <linux-mm@kvack.org>; Tue,  6 May 2014 22:58:51 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id x10so394122pdj.20
        for <linux-mm@kvack.org>; Tue, 06 May 2014 19:58:51 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id bn5si1060869pbb.22.2014.05.06.19.58.49
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 19:58:50 -0700 (PDT)
From: "Ma, Xindong" <xindong.ma@intel.com>
Subject: RE: [PATCH] rmap: validate pointer in anon_vma_clone
Date: Wed, 7 May 2014 02:58:46 +0000
Message-ID: <3917C05D9F83184EAA45CE249FF1B1DD025C8840@SHSMSX103.ccr.corp.intel.com>
References: <1399429930-5073-1-git-send-email-xindong.ma@intel.com>
In-Reply-To: <1399429930-5073-1-git-send-email-xindong.ma@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "gorcunov@gmail.com" <gorcunov@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Sorry, my fault. It's already validated in unlock_anon_vma_root().


BR
Leon


-----Original Message-----
From: Ma, Xindong=20
Sent: Wednesday, May 07, 2014 10:32 AM
To: akpm@linux-foundation.org; iamjoonsoo.kim@lge.com; n-horiguchi@ah.jp.ne=
c.com; kirill.shutemov@linux.intel.com; gorcunov@gmail.com; linux-mm@kvack.=
org; linux-kernel@vger.kernel.org
Cc: Ma, Xindong
Subject: [PATCH] rmap: validate pointer in anon_vma_clone

If memory allocation failed in first loop, root will be NULL and will lead =
to kernel panic.

Signed-off-by: Leon Ma <xindong.ma@intel.com>
---
 mm/rmap.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 9c3e773..6e53aed 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -246,8 +246,10 @@ int anon_vma_clone(struct vm_area_struct *dst, struct =
vm_area_struct *src)
=20
 		avc =3D anon_vma_chain_alloc(GFP_NOWAIT | __GFP_NOWARN);
 		if (unlikely(!avc)) {
-			unlock_anon_vma_root(root);
-			root =3D NULL;
+			if (!root) {
+				unlock_anon_vma_root(root);
+				root =3D NULL;
+			}
 			avc =3D anon_vma_chain_alloc(GFP_KERNEL);
 			if (!avc)
 				goto enomem_failure;
--
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
