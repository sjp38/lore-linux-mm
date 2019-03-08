Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3FEBDC10F09
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 04:15:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E5D4120851
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 04:15:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="SwqL8g6D"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E5D4120851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 90CBD8E0009; Thu,  7 Mar 2019 23:15:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 86DAE8E0002; Thu,  7 Mar 2019 23:15:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 738678E0009; Thu,  7 Mar 2019 23:15:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4913B8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 23:15:23 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id c9so17340502qte.11
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 20:15:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8pAdMmQJ+aEt5aO3NlY8w+BP/DccAEmjq/sdk333X44=;
        b=nMOeuonCfx8TMvb0a40EBvExJtZeIduB1gq9j/0JQt7SKP2oP/f7obKzJTM6euS8sX
         FE+REnkng46MmKfD7YvSiGRujXT7vc2+12z2i3/EezS2isvRxCyrtmp6uir9N37KUW4W
         +CVq38VfM13DXNQ9s0CBiv/Wy9hVaUkDKkidpa+8J9eOTzeQG4IaQC5JrvNoP0rM8wNi
         1pglF6R4Da02iAQTTAap2PgsDAYitSyh9zqxIBrUgtbVfqDHtwU8hnZqCPRWlzOzTxrw
         S8XvALFnPLwZz7pPTHAgKssR0yJvrFGROToNoK6SeklMKWbtPMwkAh+eMGHWhc2CHLNI
         6K0g==
X-Gm-Message-State: APjAAAU2ynrXkpHxrnYwwfu9LmsyKUvAEUnqR9hh6Gc2FikVJeI/C4mh
	MkLL0lUdN84HDNQ+tOy/i33sHraUAHFbVDitOGY1GmkuqCMDTaIDh6uF/tG8R19xZhKotTZ9Kva
	PYJwwdA1VOZoN32G5o/IDZDmcr/TC+Glv40U9IQ/HwBMtTWPS15t8KdDKSSZUH+k=
X-Received: by 2002:aed:2269:: with SMTP id o38mr13505005qtc.222.1552018523074;
        Thu, 07 Mar 2019 20:15:23 -0800 (PST)
X-Google-Smtp-Source: APXvYqzaJ5bm7cDuze9XmG93p7OKZ0sT3O3zbYFCcnaeuUFHnsf92OpjdOEAEmbQIvxKyGi08mu3
X-Received: by 2002:aed:2269:: with SMTP id o38mr13504964qtc.222.1552018522140;
        Thu, 07 Mar 2019 20:15:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552018522; cv=none;
        d=google.com; s=arc-20160816;
        b=uAaTt6JTC6i6Vj0C4L0qTr3zPxKp09H8R86EW3NvXVUFPtjzQb3P09UMIcXYtoVPU8
         OitQrjyzEmMko9dnfxd0bE8I/LUv1gxC25zD0g3eDAvzVhOZgXYIZzOpInjYCgXzTTJL
         LXFtV8TVikPSA0XWWtC+41C6ylBkZsK2C4Z7mj9E5cCK4Hciw8sB/nwWinvif7s1QtU9
         uQC4hRZ9wc6XM0oYX918UoceXx7KdeD5m50hj6ADsSi8Yu+nOvY6I9xPYuRaXlAz/v9U
         g/tFk/NVRbTyztoHOQxwYMoR+zEVo4RInDjoHMR1+pekDamtGXsYGifP3kcFW8sbgBUI
         6mMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=8pAdMmQJ+aEt5aO3NlY8w+BP/DccAEmjq/sdk333X44=;
        b=zoVsKywRjqifVKKiXcDDIwHZ0iz03NoRH3CQtWqIidM/F+6xbYK82JUHhFiC6U6hKr
         YV0mTFpgIm1aINZ+HTkfhdBlbibINXZkbEdWd5i5g0BpTcYf7PjVosPPFEvxVRaX6+Fm
         7YaLp6GyYrmrmGA5eGKu2Or4YnIW5nkPbxaSebVUNO5XcWExGyAmeUykgNiO9K7aAMec
         JOYe+3NnhLD6k35hOsinXK8NTpCISPGkiJcB/X3MzCykBpU4VJyREtVsJnr2j6FdwUcz
         fY4yqNYcJ0meq0Bg121l7NWu7gjtp2+h4muT9P6fP8Inj+OFwuaBl3G9PxTATavtw+wz
         kT5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=SwqL8g6D;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id u58si4167412qtb.4.2019.03.07.20.15.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 20:15:22 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=SwqL8g6D;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id A63323328;
	Thu,  7 Mar 2019 23:15:20 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Thu, 07 Mar 2019 23:15:21 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=8pAdMmQJ+aEt5aO3NlY8w+BP/DccAEmjq/sdk333X44=; b=SwqL8g6D
	FEedjSAwEi1G9wOQRIytv8jzzsvvSKFGH9BKDQDbRVqSfYc25o9m5aYPY7gGNhDz
	S4V8w7FcdMyO9/s8jimaE/Xbqkk5PGXe6VRIBA6jG2UuuNLf0Z48cm3urAEDkbXL
	uvnYXh8clb9ZbI15b83RrTyi/GTpmw8G4zHg/w1Bw/ZGHlLTvk2wo+cZvGknxOwB
	Pwn64GpwAi2a1IFAm0lhXFamG2wmW0GatncqQ9vbvmf16x76BbVM4AvKyp4w+Jvl
	YLQ6b22uLYq2kXh+JqOQyTxd2RY/S7i1FsCfEsLKpMb7/wNJMR8xV7j8W2D4X8Q6
	md0l6GTR01PM6Q==
X-ME-Sender: <xms:WOyBXEaMtt7j82Aper8n1YMihon8QgmMr8r3UFxWofkGv_PiLeZBlw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrfeelgdeifecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudeiledrhedrudehkeenucfrrghrrghmpehmrghilhhfrhhomhepthhosghi
    nheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgepge
X-ME-Proxy: <xmx:WOyBXNOraLOAOvyKsddSjuvp-FfI8gRecJln3Ho9xjylY5e2d4rewA>
    <xmx:WOyBXJbwtXv1qyKK_7h2tNQZF4uoTqNUjSmPB4EyE96mMiB3dc0QtA>
    <xmx:WOyBXL2BfE8DJsulGmS6z6Sdi-WktkdVQALytbpFef8aobdzwQjuUA>
    <xmx:WOyBXA3AmucocaQ3S-Lz6qO5ss5tcjUTtm0Pv0-K2KzVvZM8R5nNQQ>
Received: from eros.localdomain (124-169-5-158.dyn.iinet.net.au [124.169.5.158])
	by mail.messagingengine.com (Postfix) with ESMTPA id 55EEEE4362;
	Thu,  7 Mar 2019 23:15:17 -0500 (EST)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Christopher Lameter <cl@linux.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Matthew Wilcox <willy@infradead.org>,
	Tycho Andersen <tycho@tycho.ws>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RFC 06/15] tools/vm/slabinfo: Add remote node defrag ratio output
Date: Fri,  8 Mar 2019 15:14:17 +1100
Message-Id: <20190308041426.16654-7-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190308041426.16654-1-tobin@kernel.org>
References: <20190308041426.16654-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add output line for NUMA remote node defrag ratio.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 tools/vm/slabinfo.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/tools/vm/slabinfo.c b/tools/vm/slabinfo.c
index 6ba8ffb4ea50..9cdccdaca349 100644
--- a/tools/vm/slabinfo.c
+++ b/tools/vm/slabinfo.c
@@ -34,6 +34,7 @@ struct slabinfo {
 	unsigned int sanity_checks, slab_size, store_user, trace;
 	int order, poison, reclaim_account, red_zone;
 	int movable, ctor;
+	int remote_node_defrag_ratio;
 	unsigned long partial, objects, slabs, objects_partial, objects_total;
 	unsigned long alloc_fastpath, alloc_slowpath;
 	unsigned long free_fastpath, free_slowpath;
@@ -377,6 +378,10 @@ static void slab_numa(struct slabinfo *s, int mode)
 	if (skip_zero && !s->slabs)
 		return;
 
+	if (mode) {
+		printf("\nNUMA remote node defrag ratio: %3d\n",
+		       s->remote_node_defrag_ratio);
+	}
 	if (!line) {
 		printf("\n%-21s:", mode ? "NUMA nodes" : "Slab");
 		for(node = 0; node <= highest_node; node++)
@@ -1272,6 +1277,8 @@ static void read_slab_dir(void)
 			slab->cpu_partial_free = get_obj("cpu_partial_free");
 			slab->alloc_node_mismatch = get_obj("alloc_node_mismatch");
 			slab->deactivate_bypass = get_obj("deactivate_bypass");
+			slab->remote_node_defrag_ratio =
+					get_obj("remote_node_defrag_ratio");
 			chdir("..");
 			if (read_slab_obj(slab, "ops")) {
 				if (strstr(buffer, "ctor :"))
-- 
2.21.0

