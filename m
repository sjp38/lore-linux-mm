Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27FCCC04AB6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 04:27:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF91C267B5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 04:27:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="8AcGMewM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF91C267B5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 800F86B026E; Mon,  3 Jun 2019 00:27:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B1CF6B026F; Mon,  3 Jun 2019 00:27:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A0126B0270; Mon,  3 Jun 2019 00:27:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 491ED6B026E
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 00:27:57 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id v4so13725216qkj.10
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 21:27:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=jGU9saE69a/gfeKWv7WhcnJU8nruwl7/fOnxwG1r6J8=;
        b=dBN4XmfhbeZrW9pekC1s+97mEqQUEOrMF27mWCFcX+v2z9eETiemx6gp2kbKAE1gPW
         ihlLM6hQ4+2HVJh2AMjvRAGc+uDnhOoWgug43rYEo8cCQk4qwO6DsUmFnRjDHK2UhGhm
         eU6zNHaFWRk0zNz6ejoSr4gc40uHKz44rYe7b+zNmS8gY/yjg2pQiiaSLzPvYRjvHX1K
         aImOQTFaax59DZCSK1pxLZhl6SzDYgZhneru5433wFQAqmdWvbJpFmZFYse/lkLG97F+
         E2OGYrzvr9mDt/Hh9YmurjMByjSvTFq5uIbIcOMcye2kn4SYKP4KL3P+Wr55ihTdZN9+
         9EdA==
X-Gm-Message-State: APjAAAWBcVaQE8x4xubfb9bRFhN2NW9x3dtHFA9hXhiK95gzUWgyhVAX
	CilNMLvQZ7ZdujpdsZ6iX9akRpd2k+H3bPQZV0MvoPyF4iNfZXeB3Y/0wzvbQDiASA5vXrW5eDG
	ZhJ+wHZvJ0sALJXj7xyNVrv3uBCSbZJeWwSZYGSa2It+wqHO8XY53SIrSY3qKY9o=
X-Received: by 2002:ac8:374b:: with SMTP id p11mr20363240qtb.316.1559536077038;
        Sun, 02 Jun 2019 21:27:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHjx+Zqnu61NnZcpGoXSqZgFM7tNaCAEV0w8xDJ1p1vzfhZd6NUKTItWkgCFowHWnqDhlY
X-Received: by 2002:ac8:374b:: with SMTP id p11mr20363211qtb.316.1559536076183;
        Sun, 02 Jun 2019 21:27:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559536076; cv=none;
        d=google.com; s=arc-20160816;
        b=Xcvy58p40uUobexFLUecMdgMIt3M2S/MHUtxTFhoAS5M+TDAnG+/nhlD8FwZj7944J
         mVlkDisVhvCyZ7R3HuiCN56s8HZSk/S0Lf0egEYNAOp11pRIUiuyG0j0a44K0fCpi7UO
         2w+VqRZcOBK74hfMUqwhANtlmSBhSDM0hR3xFXGLSliBfJcdIBNQ9pqoZ6Kb2iP80SO4
         ZI8ojYWtnQnjX0NzlcDRp0EG5b/ztJP4VgVge3XMRjLkIkgg3tZOUt1ZgXo/30q00Hg0
         zSddNqbwDFTY5R7vu6Z5Kv//InRB2T/ocf/eJvXiA15IwQTk6dkoAc8Eq/9Wo1BK1rop
         vMSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=jGU9saE69a/gfeKWv7WhcnJU8nruwl7/fOnxwG1r6J8=;
        b=vhXkYHvQWx5kMzm0TX7fn4o8wcaVfuXlzrkdY950z0c1Mi9/TFZeg1JBviY5XLma2f
         wIqhrGgpMMY39ouaA+/pxdBiRmodUU6kaedGbjb+Q9ME7cycWQWht9U1q9zY6D/UUu38
         99GDBUUw9JFMclBGXHWVepXqU0htQcvMgbDCSDUD6A4c90wOBcBRiY4bnmjVeDvu3yJ4
         1H5A0zpBySEC3Sn9HDTYaIpp7wbWxdBbm0v3NVfIycDCoi3syV0E9bWT/dac3xkv2IWM
         H5Sla+s9hjWvXw3LeJ179Z3SBe2eXcKyCIvq3OwEd4+hq+yqKx/krOwUcmBdhjuKsLq7
         eoqA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=8AcGMewM;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id u35si1709638qvg.156.2019.06.02.21.27.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Jun 2019 21:27:56 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=8AcGMewM;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id E7B57123E;
	Mon,  3 Jun 2019 00:27:55 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Mon, 03 Jun 2019 00:27:55 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=jGU9saE69a/gfeKWv7WhcnJU8nruwl7/fOnxwG1r6J8=; b=8AcGMewM
	Ndtg4pdRtsPZpOOKqHUApLCaiiXKUPEyBBAaPdJaaMoZ4+B5eR9/1K70X18Cqxcv
	UsCHyzJfIMF1H80xNpYpRnilppJPkHuSiN7XKRXkAkLJxGDpxJ5+AxWk/on2Kj1Q
	4Dgq5Inh5H9ZWVDSXbCwgyxV1G5i+CbiPvRiY6x/sXaOvU84KptkfhMgi2NnGMi4
	7I5PYAJ7yq34ekuIxckmPeilZtbhnrt1WlolEFtEiRgzu/StEyM3hs4sJ0RA0fdX
	oT2kh8XjDLPSLm/nvFzdE9m/Fj/VLX+MNaxFJHKRQiG3KrYdgq8oL73l0Ab+WN57
	LZoMA1Af0XMAwQ==
X-ME-Sender: <xms:y6H0XBSnCvxB5QUBzY_zceAXhFcHrC1UQ8Z8K55zNuaFyueUDtZ7mw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrudefiedgkedvucetufdoteggodetrfdotf
    fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
    uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
    cujfgurhephffvufffkffojghfggfgsedtkeertdertddtnecuhfhrohhmpedfvfhosghi
    nhcuvedrucfjrghrughinhhgfdcuoehtohgsihhnsehkvghrnhgvlhdrohhrgheqnecukf
    hppeduvdegrddugeelrdduudefrdefieenucfrrghrrghmpehmrghilhhfrhhomhepthho
    sghinheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:y6H0XCCC5UUlERMcrpuraYfwZAN-prgO0tbUvf1H0Uyz7nhM5ckgUw>
    <xmx:y6H0XPaJrJlFMfhuQTEHG8bvq_oPJps3lPYqAwydSk-1acf8h7nUNw>
    <xmx:y6H0XGZhpdbhd8Hl7FaxP3Wl0N8obYs-EdUdDnV6ksAfr21tQyOCrA>
    <xmx:y6H0XIPjlm1YHg4LXXIIuvdNP7DVeDxZJksUn8T6H_OJrnquwXKEUQ>
Received: from eros.localdomain (124-149-113-36.dyn.iinet.net.au [124.149.113.36])
	by mail.messagingengine.com (Postfix) with ESMTPA id BBC6680059;
	Mon,  3 Jun 2019 00:27:48 -0400 (EDT)
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
	Miklos Szeredi <mszeredi@redhat.com>,
	Andreas Dilger <adilger@dilger.ca>,
	Waiman Long <longman@redhat.com>,
	Tycho Andersen <tycho@tycho.ws>,
	Theodore Ts'o <tytso@mit.edu>,
	Andi Kleen <ak@linux.intel.com>,
	David Chinner <david@fromorbit.com>,
	Nick Piggin <npiggin@gmail.com>,
	Rik van Riel <riel@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 03/15] slub: Sort slab cache list
Date: Mon,  3 Jun 2019 14:26:25 +1000
Message-Id: <20190603042637.2018-4-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190603042637.2018-1-tobin@kernel.org>
References: <20190603042637.2018-1-tobin@kernel.org>
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
index 1c380a2bc78a..66d474397c0f 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4333,6 +4333,8 @@ void kmem_cache_setup_mobility(struct kmem_cache *s,
 		return;
 	}
 
+	mutex_lock(&slab_mutex);
+
 	s->isolate = isolate;
 	s->migrate = migrate;
 
@@ -4341,6 +4343,10 @@ void kmem_cache_setup_mobility(struct kmem_cache *s,
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

