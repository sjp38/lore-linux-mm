Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6139EC10F11
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 01:36:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14C05217D9
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 01:36:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="bU4QAIg2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14C05217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8CBF6B0008; Wed, 10 Apr 2019 21:36:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A3CF56B000A; Wed, 10 Apr 2019 21:36:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 92C596B000C; Wed, 10 Apr 2019 21:36:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 74A346B0008
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 21:36:05 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id a15so3660964qkl.23
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 18:36:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=oAX6zCohmPiQ74kYACc2QgeImmemzleYDH4h+URdt/s=;
        b=Rkr28+tfyNRGF5j0EBUZRGr89V/CbpaVp5hgTtZodG4Q7VPYfW3fGKrw+qpEwmAdYf
         a29sgg6tqaca6EYfMWRtnmqUaGwW5GoHI0Q7FXw8oYnZBX7mqO08TM+RTP3s6YmWDGbu
         0Vo27hxLFbNGNMGDLBN8fTiXl9Sq+OHEepxDc6bPyoepOHmyffLvLk1lZuel+Q5eQdPv
         BTm0CCt0BfKOsKBUgWOOE9Fn/cpt0mwAzyMmzouFMsENSv0uK/g4g1gjDTRW2oZ/jjLH
         0eafWNszrsFJgdVA79F88FFArnicTNSFPMQyBNVkFYlPGwuw8lmHVNKegdd0QFW2+Py8
         mTjg==
X-Gm-Message-State: APjAAAUL7wBhZc1W7rBMB7zkdRZ8el1k+cKGSY9V2qaphYElycqOvbPi
	9BUY66gpMOPM0zkzvh7ZicnGC8wyq4xsHvNJ8DQSdJJWlpCgi3UOx3ZVlut7RUCxEmYwGyrUG9g
	i4rKCGWo2iUeAkVI9v3t8dS0m7NAhWYIOVNVA0BQuIQ9KDgiL4lRmk1fFaSZMsOA=
X-Received: by 2002:ae9:ebcf:: with SMTP id b198mr35201191qkg.129.1554946565222;
        Wed, 10 Apr 2019 18:36:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyrhuvi3I9K1Q8efxlIjG6O7Vk0hkiemtxz6IEzWHxzC9cYiPQMgdMokgJzyfbCED2VRapq
X-Received: by 2002:ae9:ebcf:: with SMTP id b198mr35201156qkg.129.1554946564279;
        Wed, 10 Apr 2019 18:36:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554946564; cv=none;
        d=google.com; s=arc-20160816;
        b=YuII+3tu1DY/u/nZMWhEaztuZEHLep9wNoVCpIpXMlecpCphCfe5DzADhvcEhxOF58
         mZhZZpzI67PcIhk/ums/8W12ou3qAX6p2YZqNSY4muCn7XYWQzktkOhpWSP8UdX+VtwN
         ekZ68riSKk9M9UyauHCcoRFcmsrbOKOc88MOkkmB+O/USFfHqoK8dJz/qQ2mGryQE5gC
         q7BFJh0pYzIQg0dTWtfh0rcc7kjvWd6P7IyK36KuOT4uoqN+EkjogSFHmyHFVkjuWBKS
         PeUska3FAPJZCXj/NVO4onD60Oy7n14MPfwmWIFIaojzVBw0wdgKDeTftCKQDfDkDzx8
         HimQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=oAX6zCohmPiQ74kYACc2QgeImmemzleYDH4h+URdt/s=;
        b=ZNefEtNOau040dy3SSUKnH7hBaKeZhmvjlRSZimNJdHnecqaWyO80Dw52u9v1YQ/LK
         8uuSH8PZp4E2UrKmRLBAWBKOaIT4MskmvDg3RuDz7dsaJVf0jkyJ3JbzCKgN3/2texdh
         H2FEkNG3EU6pJR1+G8E+xCnAYCuCLkP1Eccw/uizd8SzNYJr61twzY1lhrd0urm5TQOv
         LtgrfnV+k840K8qIHy+l+wmaYfUwk1CtcxRenVorQuYPuKxHjz5AKlYBWlK04SEA8ayz
         hZd/u/37JgFuoAwPKvHW4QgOmSifP0X1YlNJNLejsZn2PXbu1UQxf+hJAXfL8mTD6Xa5
         c3zg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=bU4QAIg2;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id q25si3013482qkc.221.2019.04.10.18.36.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 18:36:04 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=bU4QAIg2;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 04F6A147EC;
	Wed, 10 Apr 2019 21:36:04 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Wed, 10 Apr 2019 21:36:04 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=oAX6zCohmPiQ74kYACc2QgeImmemzleYDH4h+URdt/s=; b=bU4QAIg2
	NWnEZDK05i97TTDWVBgITU4BwEoq16Q/a6w1aStUqIWQNenRpyAOgNq3Nla8uF94
	DDZCcbxgIEdcuw6BpW6tG8X7B4VbY+UvprRvIs5H99Wo1H3hLTIkNOqnvvRec4O8
	4GB0Klrr2CCXKs0w5zY4PHUaMhYhpW+cfxDDVCppFNu8l2rluP694CqwuBL4r55e
	epQf57pWCIqDvmDijy2LU4HpNI7ExugUEQESWRu/y9y+6w7zeGKwMDHVcl4GvzBw
	1Mtc4t4AhWbTNTvOeO5tCgpnCRzvsj1PUpPd6wA1mgEB+Afot2S7cVXJ2ZUSkTx5
	SVaiAaTtGdgl6w==
X-ME-Sender: <xms:A5quXF21ca2stwI5jdRG0xP8JhvI8uJqkAZBfi4ZXu2kKsvdNkD6Mg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrudekgdegvdcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudejuddrudelrdduleegnecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:A5quXAG3qhyZxlNst_PXnNIOcBMJu9oJAn74cUGfS0xgYt5VTH_5tQ>
    <xmx:A5quXGgGt_tTGicmDty1E_gqgPM5CszeW6W0fuQIyUVnuvdIiHf-wQ>
    <xmx:A5quXCt4kknYI0F4wITCDwJtiN4ZF9TOmTr4wzzyyle_AKy93S-dDg>
    <xmx:A5quXGlC-OYQKBm7v5DbpIAaNWx0rHhj8RhkEfx-r7dNM_Twbp1hMQ>
Received: from eros.localdomain (124-171-19-194.dyn.iinet.net.au [124.171.19.194])
	by mail.messagingengine.com (Postfix) with ESMTPA id 540ACE409D;
	Wed, 10 Apr 2019 21:35:55 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Alexander Viro <viro@ftp.linux.org.uk>,
	Christoph Hellwig <hch@infradead.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Christopher Lameter <cl@linux.com>,
	Matthew Wilcox <willy@infradead.org>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Andreas Dilger <adilger@dilger.ca>,
	Waiman Long <longman@redhat.com>,
	Tycho Andersen <tycho@tycho.ws>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Andi Kleen <ak@linux.intel.com>,
	David Chinner <david@fromorbit.com>,
	Nick Piggin <npiggin@gmail.com>,
	Rik van Riel <riel@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Jonathan Corbet <corbet@lwn.net>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v3 03/15] slub: Sort slab cache list
Date: Thu, 11 Apr 2019 11:34:29 +1000
Message-Id: <20190411013441.5415-4-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190411013441.5415-1-tobin@kernel.org>
References: <20190411013441.5415-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It is advantageous to have all defragmentable slabs together at the
beginning of the list of slabs so that there is no need to scan the
complete list. Put defragmentable caches first when adding a slab cache
and others last.

Co-developed-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 mm/slab_common.c | 2 +-
 mm/slub.c        | 6 ++++++
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 58251ba63e4a..db5e9a0b1535 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -393,7 +393,7 @@ static struct kmem_cache *create_cache(const char *name,
 		goto out_free_cache;
 
 	s->refcount = 1;
-	list_add(&s->list, &slab_caches);
+	list_add_tail(&s->list, &slab_caches);
 	memcg_link_cache(s);
 out:
 	if (err)
diff --git a/mm/slub.c b/mm/slub.c
index ae44d640b8c1..f6b0e4a395ef 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4342,6 +4342,8 @@ void kmem_cache_setup_mobility(struct kmem_cache *s,
 		return;
 	}
 
+	mutex_lock(&slab_mutex);
+
 	s->isolate = isolate;
 	s->migrate = migrate;
 
@@ -4350,6 +4352,10 @@ void kmem_cache_setup_mobility(struct kmem_cache *s,
 	 * to disable fast cmpxchg based processing.
 	 */
 	s->flags &= ~__CMPXCHG_DOUBLE;
+
+	list_move(&s->list, &slab_caches);	/* Move to top */
+
+	mutex_unlock(&slab_mutex);
 }
 EXPORT_SYMBOL(kmem_cache_setup_mobility);
 
-- 
2.21.0

