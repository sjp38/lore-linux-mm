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
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9C86C4CECD
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 17:08:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6FCB021479
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 17:08:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ChR4G6GA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6FCB021479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1E5B36B0269; Sun, 15 Sep 2019 13:08:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 170696B026D; Sun, 15 Sep 2019 13:08:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 036E36B026F; Sun, 15 Sep 2019 13:08:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0189.hostedemail.com [216.40.44.189])
	by kanga.kvack.org (Postfix) with ESMTP id D48D26B026D
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 13:08:56 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 813FB181AC9AE
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 17:08:56 +0000 (UTC)
X-FDA: 75937789872.04.waves19_30eb2e864115d
X-HE-Tag: waves19_30eb2e864115d
X-Filterd-Recvd-Size: 5109
Received: from mail-pl1-f193.google.com (mail-pl1-f193.google.com [209.85.214.193])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 17:08:56 +0000 (UTC)
Received: by mail-pl1-f193.google.com with SMTP id t11so15559102plo.0
        for <linux-mm@kvack.org>; Sun, 15 Sep 2019 10:08:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=nii43oMTaFtktKbnijjugyrLFfb5ZKvbiN8kMj3vNPE=;
        b=ChR4G6GAPaZdbwdfKHEQSYy9/d3o+YfQNx9G6ElCWcdroi5oVcnCWZ0D9ltIPZcxkW
         6rJ9OuFwAUTeyoZmJKyvA8c2HlyUN6MpflA36FPfDaPlhN+8MpDJUOmABIkQg3IXj+5X
         5GGwg62qwPXQcBlF8QNS+M7Ww5yDUu66qX1T3mwv+tCVYVOPi/njgfU5BoChKExCRBny
         VNLOKJDxONTTBugsfaTwNW7FyBDRyj+Q5kKt/Ha5YmiJiNDCnU7Gu5uW3D9KCPPbmdFC
         gb7aTCIP08Su+wr3nLOXUv7Efdy5ovyi9gRj9ZiRgHiCatS9jLsNmuvQeojVZrAlXuA8
         BVZw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=nii43oMTaFtktKbnijjugyrLFfb5ZKvbiN8kMj3vNPE=;
        b=GIRad8bIq+V7mFjaE36pktLPWrgdciDnLoDYkyrSbshZHMguaagaiTXHAixEaOf6Hf
         GTeL/ncEbqM7BZB+MCIfBBbHWJkXtzNfk/jjkrA5TMViI+sYCS8gmM+XOS6B4/YbWbDN
         R4R7QqaFvcxgr/dFOoQewsX2ll5geNaksBviUcsfbTO1H5Tt49RKOa0dzMcib+GhAv2f
         iwzWhUYRpHE40bwoifvIb1EkLt371cG1f4SPQSh90wdILtad8ImztiRMSA/cbm5EdWQI
         Yk8rf/J3XfhJ99Tr4Hik01igpLmIC3oKRoNfBroGFRbpN6BVmdC3oh3fMolFEcT1hJ1V
         YxPA==
X-Gm-Message-State: APjAAAU6x9/RW13zSoZ9CDv2qV1E2LtLmLnpQZMz83wWwdnA+2RqjKc4
	/2zEfHWVdlt4FkFQgFM5Spw=
X-Google-Smtp-Source: APXvYqxIpfa3q8cGvHRTwJ6lHu6xR8cG8RIe6yRmztIbu+l53V7wTKsneEQe0JI+j7ru62hQqZv6Ag==
X-Received: by 2002:a17:902:a606:: with SMTP id u6mr46467079plq.224.1568567335179;
        Sun, 15 Sep 2019 10:08:55 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:160:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id r28sm62279134pfg.62.2019.09.15.10.08.48
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 15 Sep 2019 10:08:54 -0700 (PDT)
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
Subject: [RESEND v4 4/7] mm, slab: Return ZERO_SIZE_ALLOC for zero sized kmalloc requests
Date: Mon, 16 Sep 2019 01:08:06 +0800
Message-Id: <20190915170809.10702-5-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190915170809.10702-1-lpf.vector@gmail.com>
References: <20190915170809.10702-1-lpf.vector@gmail.com>
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


