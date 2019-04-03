Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A362FC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:23:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48C212146E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:23:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="FC9CRiNy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48C212146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 004C56B0274; Wed,  3 Apr 2019 00:23:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F1D9C6B0275; Wed,  3 Apr 2019 00:23:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E0F436B0276; Wed,  3 Apr 2019 00:23:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id C09156B0274
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 00:23:07 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id p26so15549307qtq.21
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 21:23:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=oAX6zCohmPiQ74kYACc2QgeImmemzleYDH4h+URdt/s=;
        b=ubdcPIROTKI7jbU6JOaJJ58d+zJBuOuLB0g+SZIGvXB25mtt5nv20UZkel7vZWvOSV
         Zdewn/P7oRGWTiYlNb2/Pyc5291o6zGqc275GXH93W0u6z4VUXrSW8lX9zmt6/fRJmvl
         trfvD6w87a2HobPInyFy4Czgvp3A869gmhNZgmDM/lU3d92QPaXr7s9jEbiDXQu2L+cC
         HzoGBCqxsakcGBMTwUFo4iZbzvhy0W0S9fX84LDfV6tNNLWuTKD65apsf1LCuMA5MIKI
         9Uq4AUp0UsCGIcf5OLLeGxB371AlKBMuJRH7S0/6KoYhM8fwwsO8swgS6j3zcJZC6Z6D
         aF3g==
X-Gm-Message-State: APjAAAW6UdtKi1GRfYQsGJpnrqD9TSl9NmJGlMtGdTm/GJx3LUV7gwRK
	5NsVuE9i46Si8pnjR0I30iGvF1lG5kThAY7EMeO9k7+gnZWFDYLXWQJ18QkyFFmLvGrMh0/2uow
	eMSzr+sFdOaQQkTQKhSXyVLBQZ7ofsjFsYhBxD0dysoXg1fzo7iwrAtoIFh5rfGo=
X-Received: by 2002:a0c:9319:: with SMTP id d25mr59129603qvd.99.1554265387520;
        Tue, 02 Apr 2019 21:23:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzWB3vAwe08xEj5XFAE6dhb6ugnyewSv4Bl5uRS6VbepGyxWONit/fuJQt3GGTkCJXKcIs6
X-Received: by 2002:a0c:9319:: with SMTP id d25mr59129570qvd.99.1554265386658;
        Tue, 02 Apr 2019 21:23:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554265386; cv=none;
        d=google.com; s=arc-20160816;
        b=VZIEH1eV0sGWvquukL0flfqcQxDyX3Lc9SlW1CpU+5HDa5FMchG5GcIJK64I/WoTsj
         NJI59vlnhkpzLCYRTGBXxZgN5pIWRhuybD64aLqCEbtP9uO7xDLKYxpDHwx2KXCrnjLd
         jQZzQKnIkWDtofpUUppOevyTQUyJikZum/C/eCPI0K4TA6QnxWyqjdXyRVdlwMO73jKX
         ktaugaoBw4DQPPinty1RHc1hVWhSuuFC5elK6dA9IvGBkeJSyqYSIvPudlkNlC8/GiQl
         Y4xUEq+FP1VQGicEkT9HylzrIyBTSH3fy5HgyxTd+usgQGFEnw9DATaXgfTZ4CSGiBej
         NYgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=oAX6zCohmPiQ74kYACc2QgeImmemzleYDH4h+URdt/s=;
        b=ewyBZuAqL5ojx+g0RMNgaNteq9jvlpLwiPPjIPpE6ikkpkEUAYyf8ts/kIwWEdFW8x
         4hrPujW6R68ndz0UnNuXHpsz6Uol6iMGpBLEEMQH/H7kWMQILLNsMkIwd2SO0qqancaW
         dP7JZ0jSxD1ruy+esBBCS2/SIodxoOWqKBhk94fhfzi5Bk07NLSU/a73QjoIkzY551Rd
         cukwLGxd0ObSejO8eGTZuRYU8sxR1h44fZg8GgRtQnZFARncsg6QM30v7hFK3Ac0wUuX
         NaSAHhn1te7wctLCnrQjRoLrQ3mxlU9fyxwVJFu+kWyMVR0cYwuZoLJYxL0VO1hTSN4q
         4XUA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=FC9CRiNy;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.28 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out4-smtp.messagingengine.com (out4-smtp.messagingengine.com. [66.111.4.28])
        by mx.google.com with ESMTPS id y6si342406qkf.93.2019.04.02.21.23.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 21:23:06 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.28 as permitted sender) client-ip=66.111.4.28;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=FC9CRiNy;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.28 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 57E9821B2A;
	Wed,  3 Apr 2019 00:23:06 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Wed, 03 Apr 2019 00:23:06 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=oAX6zCohmPiQ74kYACc2QgeImmemzleYDH4h+URdt/s=; b=FC9CRiNy
	/A2QACAxPg4m3dmOCUdhhqa5feWxuaX7P0DN1cHtAGYWp1mGWP79PKIKnCk61N8b
	HJ+e0qEBWAWBOZ8aIklqcS6HduIcqSzhR2lHIemxwotBmC58QMnVTGS32LM3UIt+
	6qp1Xg1tEinuIHZtRcvmbN2JKESdUCciDey+5yqaPvwCkJ3TRgHkUAnA+MXn7aKv
	JIremYOdC/D8Zo9iexYBt+p91801gl7QHym/o0JuDzUYmYJMhU+7p0rN4tFvmNGt
	qdleqeBuW4FoFEBbAUdh3EXUMNNhPut1FvkVUfwRAj9AenIa0OO01aO3RbaLsYPo
	fSbc5pRf/Vpe6w==
X-ME-Sender: <xms:KjWkXAMAadFEKSji-jKpD65Pk5MCBTa69LGYjRUyDXr3NKHeHWW7bw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtddugdektdculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhgggfestdekredtredttden
    ucfhrhhomhepfdfvohgsihhnucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrh
    hnvghlrdhorhhgqeenucfkphepuddvgedrudeiledrvdejrddvtdeknecurfgrrhgrmhep
    mhgrihhlfhhrohhmpehtohgsihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghruf
    hiiigvpedv
X-ME-Proxy: <xmx:KjWkXBNmOykh5jksjMZXXL3SRPbWLG97p95FiIAdlXfAyB8-TF_jZQ>
    <xmx:KjWkXMsjrBxDY92haktuDCCZN3U4tBtwqA4VcLqmUzCJJ7Wv0kmGRg>
    <xmx:KjWkXO--NjFTy9UKSOvKrEdX0FuExPWlG7a1ZFMTXvyJu6k5AMTKvw>
    <xmx:KjWkXJakolUOLXLXS-GgxSlXzBcuiKvaEnY5ABAZpxIA1X85q__9JA>
Received: from eros.localdomain (124-169-27-208.dyn.iinet.net.au [124.169.27.208])
	by mail.messagingengine.com (Postfix) with ESMTPA id 43DB310310;
	Wed,  3 Apr 2019 00:22:59 -0400 (EDT)
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
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v2 03/14] slub: Sort slab cache list
Date: Wed,  3 Apr 2019 15:21:16 +1100
Message-Id: <20190403042127.18755-4-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190403042127.18755-1-tobin@kernel.org>
References: <20190403042127.18755-1-tobin@kernel.org>
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

