Return-Path: <SRS0=FJsX=XK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1DD01C4CEC7
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 16:52:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CCDAB214D8
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 16:52:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jo+e4APs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CCDAB214D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BE0D6B000A; Sun, 15 Sep 2019 12:52:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 76ED56B000C; Sun, 15 Sep 2019 12:52:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 65CE06B000D; Sun, 15 Sep 2019 12:52:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0212.hostedemail.com [216.40.44.212])
	by kanga.kvack.org (Postfix) with ESMTP id 42BFC6B000A
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 12:52:50 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id E09473AB9
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 16:52:49 +0000 (UTC)
X-FDA: 75937749258.09.story36_35c1c86a17631
X-HE-Tag: story36_35c1c86a17631
X-Filterd-Recvd-Size: 5096
Received: from mail-pg1-f194.google.com (mail-pg1-f194.google.com [209.85.215.194])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 16:52:49 +0000 (UTC)
Received: by mail-pg1-f194.google.com with SMTP id 4so18002898pgm.12
        for <linux-mm@kvack.org>; Sun, 15 Sep 2019 09:52:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=nii43oMTaFtktKbnijjugyrLFfb5ZKvbiN8kMj3vNPE=;
        b=jo+e4APs5xDRR8vZnH8rVBXMdzgGhpBwxw1z0mC3zae1JlCpMP62+atbzfzG4DzlJ4
         weLCzW1zyxAYbUHZEPNrQtsLGmmxNCJWoa02cfILoRJfidraJ/kiXJgAl7L/E8Q0fs9c
         Dn/J+0SvCTaHBHWnlM2UnCAVBdLyy6KgR6bwLi7xR2wQwJ/MXLv8ynXcZwlUN4nwfe+s
         mxH+qYSu1vigjSVG1BrMLQUwD7FpJli522rbBGlbnGrt3xKG30eSKffnD0Y2HkDdyYzk
         pUuTC/IUU8TzL15qlK7Wzrw6vMLteSA9xTkhgzsInyxQftpd8Cy5PZjQZfwwplgw50+k
         yv6Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=nii43oMTaFtktKbnijjugyrLFfb5ZKvbiN8kMj3vNPE=;
        b=q1xwyv0EkZF7TOQ6iGnQFYzGsU10dFvU10JLyogVH8SEKT6ualKkWwPHyYe3h6EEWk
         fXwTHSNX5pbwwdLTWGBQqijWBP6pWBTYecj+kSybj91dPw+Tbl8cHwbv1mtfTDwLcmFj
         k3nlTUoGASUnMiD1vX6/8bi/qgl2snkT+6YiWl+W1FPIesndGmpQ1wjEJ6PHzGLni4lS
         I4DxEeuxymVL4gvcH6vIK9xEHW3cJPbJuVZ0ApiAztHyPtns0et169HN6KnmWAIjN52j
         ZzYveQoR1A9rGtIIGf4gbtUNxOiXUSKMw7X5sOyU0ILhxRAV8/vFKIGWvewCke012pnn
         qtdg==
X-Gm-Message-State: APjAAAWvPk6fmBdiJlZYIoCouj6/HtgvLVgw1jIi3J618ivFu39GJMg4
	U+EknxvyC1+T5VwbGTADkLQ=
X-Google-Smtp-Source: APXvYqyTb4DRsLUcRsbIEyib6eSVHgjnGgZ0zUwvJ1lKLEu0+d9WiS+28E8PoS/0ro55mhxu8KF8iA==
X-Received: by 2002:a62:7c4d:: with SMTP id x74mr7837018pfc.95.1568566368554;
        Sun, 15 Sep 2019 09:52:48 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:160:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id a4sm4383259pgq.6.2019.09.15.09.52.38
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 15 Sep 2019 09:52:48 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org
Cc: vbabka@suse.cz,
	cl@linux.com,
	penberg@kernel.org,
	rientjes@google.com,
	iamjoonsoo.kim@lge.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	guro@fb.com,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH v4 4/7] mm, slab: Return ZERO_SIZE_ALLOC for zero sized kmalloc requests
Date: Mon, 16 Sep 2019 00:51:15 +0800
Message-Id: <20190915165121.7237-7-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190915165121.7237-1-lpf.vector@gmail.com>
References: <20190915165121.7237-1-lpf.vector@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a preparation patch, just replace 0 with ZERO_SIZE_ALLOC
as the return value of zero sized requests.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
---
 include/linux/slab.h | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index e773e5764b7b..1f05f68f2c3e 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -121,14 +121,20 @@
 #define SLAB_DEACTIVATED	((slab_flags_t __force)0x10000000U)
=20
 /*
- * ZERO_SIZE_PTR will be returned for zero sized kmalloc requests.
+ * ZERO_SIZE_ALLOC will be returned by kmalloc_index() if it was zero si=
zed
+ * requests.
  *
+ * After that, ZERO_SIZE_PTR will be returned by the function that calle=
d
+ * kmalloc_index().
+
  * Dereferencing ZERO_SIZE_PTR will lead to a distinct access fault.
  *
  * ZERO_SIZE_PTR can be passed to kfree though in the same way that NULL=
 can.
  * Both make kfree a no-op.
  */
-#define ZERO_SIZE_PTR ((void *)16)
+#define ZERO_SIZE_ALLOC		(UINT_MAX)
+
+#define ZERO_SIZE_PTR		((void *)16)
=20
 #define ZERO_OR_NULL_PTR(x) ((unsigned long)(x) <=3D \
 				(unsigned long)ZERO_SIZE_PTR)
@@ -350,7 +356,7 @@ static __always_inline enum kmalloc_cache_type kmallo=
c_type(gfp_t flags)
 static __always_inline unsigned int kmalloc_index(size_t size)
 {
 	if (!size)
-		return 0;
+		return ZERO_SIZE_ALLOC;
=20
 	if (size <=3D KMALLOC_MIN_SIZE)
 		return KMALLOC_SHIFT_LOW;
@@ -546,7 +552,7 @@ static __always_inline void *kmalloc(size_t size, gfp=
_t flags)
 #ifndef CONFIG_SLOB
 		index =3D kmalloc_index(size);
=20
-		if (!index)
+		if (index =3D=3D ZERO_SIZE_ALLOC)
 			return ZERO_SIZE_PTR;
=20
 		return kmem_cache_alloc_trace(
@@ -564,7 +570,7 @@ static __always_inline void *kmalloc_node(size_t size=
, gfp_t flags, int node)
 		size <=3D KMALLOC_MAX_CACHE_SIZE) {
 		unsigned int i =3D kmalloc_index(size);
=20
-		if (!i)
+		if (i =3D=3D ZERO_SIZE_ALLOC)
 			return ZERO_SIZE_PTR;
=20
 		return kmem_cache_alloc_node_trace(
--=20
2.21.0


