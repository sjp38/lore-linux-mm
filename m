Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.3 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94E33C4CECE
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 14:47:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4FF9321670
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 14:47:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YR9U5b2A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4FF9321670
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0133B6B000D; Mon, 16 Sep 2019 10:47:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F07606B000E; Mon, 16 Sep 2019 10:47:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E1C566B0010; Mon, 16 Sep 2019 10:47:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0112.hostedemail.com [216.40.44.112])
	by kanga.kvack.org (Postfix) with ESMTP id BF8246B000D
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 10:47:07 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 6B535181AC9AE
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 14:47:06 +0000 (UTC)
X-FDA: 75941061252.29.snake60_20e48c57c5100
X-HE-Tag: snake60_20e48c57c5100
X-Filterd-Recvd-Size: 5155
Received: from mail-pl1-f196.google.com (mail-pl1-f196.google.com [209.85.214.196])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 14:47:05 +0000 (UTC)
Received: by mail-pl1-f196.google.com with SMTP id q24so557243plr.13
        for <linux-mm@kvack.org>; Mon, 16 Sep 2019 07:47:05 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=QbVF1PSqvP2xnQhufiGK8AJvI4iylUVt8uZ1yhy2wwc=;
        b=YR9U5b2Al2uZzdBiRyBtWDbXpGBtWrT4PMKL+x1AZt3LYMS+m3xzN98uaYTyO+CFUF
         7IhKvR0RKbfMl53lB1Ph16DPrOSZmSqW+QKgSAysJpNWZ2zntkD2HbA5vaUegHGgsgAZ
         oJ+A1++3S4ceNlCIng74lZeCWfICtAWZCEdhaZQwsZKVTrdPCKh0WuGIjZhjI4aE+o5m
         +BxDxp98Qw4Z9Bnmonbf1saR7UI/vHeAMNjYTplEWhlTdWKZdRVyuv56bI+tizq7Sit9
         GdxJfk7bGuackN22jFCiFIs8FrfIzZC0RtxbQiBgucqMNmxnwNsiCOCCLWLgf4vxn6CR
         44lQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=QbVF1PSqvP2xnQhufiGK8AJvI4iylUVt8uZ1yhy2wwc=;
        b=Bcqf7phVWDn9N/2NoxLXYQFTBdPxZpZcCtvLCMHohgs1WpymwRVSpaOvsl6x/SZ/JJ
         wy/8AdsGGcWEtUu7E4OaJu0UumGmwbnpNe6nZSkUiaEjvK+ja63qazdMZbvGjnLfa1Ud
         LXsoLpxM82b+FviIz46KOi4Xw8DfkrqrAw7UMzW15Jzw5TG7WBx7EjKgXRmR0EALeYyE
         TZMAWsmqIy3lw79bHAy+9FtiyUiZH2URWZSLghk2QA+xDD/SKYWs4Ez4fjZCKK8OHdUi
         yCZFzXCFtA7fQ/X6+CPokqOdYg5BAh15S/4xUGvF4eZcYWZRFx1+Z9oynv1pNiUeyrX0
         z8Bg==
X-Gm-Message-State: APjAAAVLuZ/XccEUMbW3AFXhkdosG0xkBOVRVNnu8G/9uCSzWX53B6LL
	O6xQWQlh7LXca+sMUq9Z9BQ=
X-Google-Smtp-Source: APXvYqx+StnT131uYw7DO0XD9HWiydJc/EU947IkydJV5DEyZ1C4JCqpo96WEbZQgnCh54f/is3EFg==
X-Received: by 2002:a17:902:a418:: with SMTP id p24mr161368plq.312.1568645225140;
        Mon, 16 Sep 2019 07:47:05 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:160:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id d190sm15036004pgc.25.2019.09.16.07.46.55
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 16 Sep 2019 07:47:04 -0700 (PDT)
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
Subject: [PATCH v5 4/7] mm, slab: Return ZERO_SIZE_ALLOC for zero sized kmalloc requests
Date: Mon, 16 Sep 2019 22:45:55 +0800
Message-Id: <20190916144558.27282-5-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190916144558.27282-1-lpf.vector@gmail.com>
References: <20190916144558.27282-1-lpf.vector@gmail.com>
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
Acked-by: David Rientjes <rientjes@google.com>
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


