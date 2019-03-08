Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EAE2C10F09
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 04:15:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4185F20855
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 04:15:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="6IBJtDUG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4185F20855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E62C08E000A; Thu,  7 Mar 2019 23:15:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DEBD08E0002; Thu,  7 Mar 2019 23:15:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C6B918E000A; Thu,  7 Mar 2019 23:15:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 956358E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 23:15:26 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id f24so17505645qte.4
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 20:15:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=7KlkGOfn94pNrR5k4Aw3I2CbER2w6gJmF5fBjSSPEBI=;
        b=Elp5JBQEUlQccGfAkoNToOz+qiB9cXwdcDTESQ6i5pp3AdyLmEP0BK8MFiQ9w2R+St
         wPIgR9Qgeu6daLKyDXWDy2jyRSaJS36OQ6JRL9ePpEF0lRNt6Jn4BcTT8VtE5T6+y84Q
         jlO0GAyRtDbgNzhMfOkfwzatP34az39AVA+Ik918tbr597bJN4APXHy9ausfaQ8+ea2V
         RQbJuJoc/AV28VLI4ETO24v68hBUqtg36mAvvsRunioceAgw86wXPwUvn87hWqD4abNJ
         7QneUI6dhx1UcyqkPlE3K+Qb2Og/CGj1CzaDvLOYC4RkqdczULG+6pojWImirWJy7NB6
         1U8A==
X-Gm-Message-State: APjAAAVmHA7muXQiWOi0BIN8Ewro9jrzf+hwpPOM2NfIVfi0h/vPonwi
	xwKgJqql7VRBcCppaEIgXl4d1LRLbROBnabgvT6GR/uEmN4A6PKcNNIzPPPvbyf95bTOZFXJWgS
	44IUuG0qwEc4k1Xkf1ctdvmyRyBBNhH6W8QUIa7j1Z/MFA4sldtW/L1Qijhqnvfg=
X-Received: by 2002:a37:5e01:: with SMTP id s1mr4938501qkb.38.1552018526339;
        Thu, 07 Mar 2019 20:15:26 -0800 (PST)
X-Google-Smtp-Source: APXvYqwV+w5iS+mVYzUVlVy3IS4ScvJYvkucesEpg++SYoIE1ks3KRNLYSvrh+oWfmn/N1B0ynP7
X-Received: by 2002:a37:5e01:: with SMTP id s1mr4938464qkb.38.1552018525492;
        Thu, 07 Mar 2019 20:15:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552018525; cv=none;
        d=google.com; s=arc-20160816;
        b=btP2+YsqGmwdzE5oNVAU6dqJrFxDK58GEjNVdJ3f3P+IasFqRSCBKH2pYXT10+4tQg
         rHldpSFTK4uCGGeocoCzMfAtFm3uXXQDeK8LdHDcurUOkIkbf0E/48LyVFbBDZtykcnW
         +p375QHQUbsLtFoWvrEPU+2PfpujCJzWNsD0tio92o2EEy3X8IZG07hPgIbo6SAAo1jn
         /l4ubhfC79HgJSRgAWFGbt2AxntYr+SUxfAA1c7Ri81Rd+XlVHNEFxq9UIMRWnGhU4AQ
         QL2IkPVxmLFHlIdGHG6feybE5tVjsafrgnfXQ+ekXfdgtQMg/N3SiYVK4AecAKidOGXE
         FoSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=7KlkGOfn94pNrR5k4Aw3I2CbER2w6gJmF5fBjSSPEBI=;
        b=CLtne4ZgsMzjej/MpX/Fvx9s6fGz8npP11PnaxT8Q3RLNhxuNnccQFOD6adWgVDCmq
         DXhB5uOMhKpMQ0F5u1/jy1sz3UPfsx1FGQEIstDHfFzwtwU/G7YLvYk8G3IZexpOJzU9
         bA/Cvv0a35T/cDBcVSZl8MTg4KkaW6UKILIY0ptSMRVxxiGLMq1gvdKim0ScN+Rdx/G0
         wdXEKmKQ5qXmUIxSohpdDRbxQ4f3rW/GuWCurNkGbeA7VEkj8F8BEpy2MaEWcfSH9WDf
         AWHxdx3VX13Lf7FYJnInD8fqIAKwKH8leSzesMYA8RGVJDr8dWlq1RIA5NhHiHuMYeE6
         VhrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=6IBJtDUG;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id c39si1778461qtc.192.2019.03.07.20.15.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 20:15:25 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=6IBJtDUG;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id D48D234AD;
	Thu,  7 Mar 2019 23:15:23 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Thu, 07 Mar 2019 23:15:24 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=7KlkGOfn94pNrR5k4Aw3I2CbER2w6gJmF5fBjSSPEBI=; b=6IBJtDUG
	jLqtpyAzG6aFaZlCfeLvOnLxWfO1jabUczoqCLk7mqzrK2HVQC5UXOECilcK3dxQ
	zXtgiiEJp1hsugZUgJUyEiFKgooWTLvx7Tol42sg7kViarMkIAvlWlRw733oMLwn
	kdqfyezNHWAOifKGI1s3dTd4OPmRij+AzuhQVZmy8Xqy1sIDq4KsLkSe7Tu2Btps
	iXfHRe9JIhvEHQRKO+Y3lTl2x10ZdvGwZFADEjgOD3pi/ecBq9+woSLAdanhdpEd
	K0FUH/nZILktpcgtrxj2OiB6OVsIND0pzQULCFezSZvHEXBoG2EFNxOreyZM/YtW
	6pjuI2Sr61CC2w==
X-ME-Sender: <xms:W-yBXDo1EQwBibMuuvYkFajOevpDK_xcZ6WZwLE6XTHzgmMIDou3LQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrfeelgdeifecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudeiledrhedrudehkeenucfrrghrrghmpehmrghilhhfrhhomhepthhosghi
    nheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgepie
X-ME-Proxy: <xmx:W-yBXHrjhmuj4Z0apTOhHE28Oi2KGg0XmcfbWjKY4CpoOSRefemSjA>
    <xmx:W-yBXG0FhaENHZvqobzcpbwrttwYP4eUNFUNR9-33cebhO9HYMvoIA>
    <xmx:W-yBXFE7t6_3k8br93hOI0Zff-r8Q3PKhz4OGCscdhN_R5EvqJcMcA>
    <xmx:W-yBXCHriP-UpPDJb6lfQqVzxZ-jK4DWp1JMiasrtltzf1ektzMUIA>
Received: from eros.localdomain (124-169-5-158.dyn.iinet.net.au [124.169.5.158])
	by mail.messagingengine.com (Postfix) with ESMTPA id 736AAE4548;
	Thu,  7 Mar 2019 23:15:20 -0500 (EST)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Christopher Lameter <cl@linux.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Matthew Wilcox <willy@infradead.org>,
	Tycho Andersen <tycho@tycho.ws>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RFC 07/15] slub: Add defrag_used_ratio field and sysfs support
Date: Fri,  8 Mar 2019 15:14:18 +1100
Message-Id: <20190308041426.16654-8-tobin@kernel.org>
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

In preparation for enabling defragmentation of slab pages.

"defrag_used_ratio" is used to set the threshold at which
defragmentation should be attempted on a slab page.

"defrag_used_ratio" is a percentage in the range of 0 - 100 (inclusive).
If less than that percentage of slots in a slab page are in use then the
slab page will become subject to defragmentation.

Add a defrag ratio field and set it to 30% by default. A limit of 30%
specifies that more than 3 out of 10 available slots for objects need to
be in use otherwise slab defragmentation will be attempted on the
remaining objects.

Co-developed-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 Documentation/ABI/testing/sysfs-kernel-slab | 14 ++++++++++++
 include/linux/slub_def.h                    |  7 ++++++
 mm/slub.c                                   | 24 +++++++++++++++++++++
 3 files changed, 45 insertions(+)

diff --git a/Documentation/ABI/testing/sysfs-kernel-slab b/Documentation/ABI/testing/sysfs-kernel-slab
index 29601d93a1c2..7770c03be6b4 100644
--- a/Documentation/ABI/testing/sysfs-kernel-slab
+++ b/Documentation/ABI/testing/sysfs-kernel-slab
@@ -180,6 +180,20 @@ Description:
 		list.  It can be written to clear the current count.
 		Available when CONFIG_SLUB_STATS is enabled.
 
+What:		/sys/kernel/slab/cache/defrag_used_ratio
+Date:		February 2019
+KernelVersion:	5.0
+Contact:	Christoph Lameter <cl@linux-foundation.org>
+		Pekka Enberg <penberg@cs.helsinki.fi>,
+Description:
+		The defrag_used_ratio file allows the control of how aggressive
+		slab fragmentation reduction works at reclaiming objects from
+		sparsely populated slabs. This is a percentage. If a slab has
+		less than this percentage of objects allocated then reclaim will
+		attempt to reclaim objects so that the whole slab page can be
+		freed. 0% specifies no reclaim attempt (defrag disabled), 100%
+		specifies attempt to reclaim all pages.  The default is 30%.
+
 What:		/sys/kernel/slab/cache/deactivate_to_tail
 Date:		February 2008
 KernelVersion:	2.6.25
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index a7340a1ed5dc..6da6197ca973 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -107,6 +107,13 @@ struct kmem_cache {
 	unsigned int red_left_pad;	/* Left redzone padding size */
 	const char *name;	/* Name (only for display!) */
 	struct list_head list;	/* List of slab caches */
+	int defrag_used_ratio;	/*
+				 * Ratio used to check against the
+				 * percentage of objects allocated in a
+				 * slab page.  If less than this ratio
+				 * is allocated then reclaim attempts
+				 * are made.
+				 */
 #ifdef CONFIG_SYSFS
 	struct kobject kobj;	/* For sysfs */
 	struct work_struct kobj_remove_work;
diff --git a/mm/slub.c b/mm/slub.c
index f37103e22d3f..515db0f36c55 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3642,6 +3642,7 @@ static int kmem_cache_open(struct kmem_cache *s, slab_flags_t flags)
 
 	set_cpu_partial(s);
 
+	s->defrag_used_ratio = 30;
 #ifdef CONFIG_NUMA
 	s->remote_node_defrag_ratio = 1000;
 #endif
@@ -5261,6 +5262,28 @@ static ssize_t destroy_by_rcu_show(struct kmem_cache *s, char *buf)
 }
 SLAB_ATTR_RO(destroy_by_rcu);
 
+static ssize_t defrag_used_ratio_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%d\n", s->defrag_used_ratio);
+}
+
+static ssize_t defrag_used_ratio_store(struct kmem_cache *s,
+				       const char *buf, size_t length)
+{
+	unsigned long ratio;
+	int err;
+
+	err = kstrtoul(buf, 10, &ratio);
+	if (err)
+		return err;
+
+	if (ratio <= 100)
+		s->defrag_used_ratio = ratio;
+
+	return length;
+}
+SLAB_ATTR(defrag_used_ratio);
+
 #ifdef CONFIG_SLUB_DEBUG
 static ssize_t slabs_show(struct kmem_cache *s, char *buf)
 {
@@ -5585,6 +5608,7 @@ static struct attribute *slab_attrs[] = {
 	&validate_attr.attr,
 	&alloc_calls_attr.attr,
 	&free_calls_attr.attr,
+	&defrag_used_ratio_attr.attr,
 #endif
 #ifdef CONFIG_ZONE_DMA
 	&cache_dma_attr.attr,
-- 
2.21.0

