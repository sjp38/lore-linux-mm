Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EB1DC169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 04:11:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C534C218AC
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 04:11:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="L4Kf1drA";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="R25mjrc/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C534C218AC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 431CF8E0005; Wed, 30 Jan 2019 23:11:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 408F38E0001; Wed, 30 Jan 2019 23:11:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D3AB8E0005; Wed, 30 Jan 2019 23:11:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 065C68E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 23:11:11 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id s14so1959591qkl.16
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 20:11:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+qm6IAuBdYJ0KJEezxlGA4lLZCD+PJm0pFyznNM0TqM=;
        b=alCvIkeBvrmZR1zvxOmymHAfnBcyeIG5iAG0mfE0jhZstri9v6YRUXc4SydOTrM7w4
         LhJKbTr/k+59+MWaUFq1JFMT9YnBD5oIHAhuqiYlMytaDEzRVzRHz8wgTaMPEfZ+wqul
         nBmKn4Ur3xUWMci/oiVXWoNeyBTI753XbbqQ4UddGULWhMW4Gr4BJAY3wOy+nUcEdahf
         RyDFkIsbpwXlgQHmbOAYLBUy/HBLXAt8o8cyZTECRVZ/y9xs06FLaP3CSkStjYeiMjao
         kRAbIIbfzt0SviD9yD30EsHuE7nsInNrgi+SAuSV9GjQabdXsFW/cn3NHGzI1Rft5z5E
         u8Zg==
X-Gm-Message-State: AJcUukd7d7qQfDBfG6ZYhKR+c1dlNJezGqk9afACfPWkpDLEqA+T73n9
	/Ghbf+OAsga2DgufaelClaVBfJ8KxV5qijPaTJrfpxXTr8Poh09/CxxXTzNOp2MwWLfgIai47X3
	0Oq50FQEMxCwf+Gym7MYVqVI41lo4Ix4IExb1+Pf2BJvYMh12GaqKZ1/vyFvyqUgtRA==
X-Received: by 2002:a0c:db04:: with SMTP id d4mr30829519qvk.114.1548907870791;
        Wed, 30 Jan 2019 20:11:10 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7ErIN4FHABSQFX/ElHWbGmfBqraadGG5F2Wvz39hZpD7cgeUZ7gMFnP3AWRVMiibodx86k
X-Received: by 2002:a0c:db04:: with SMTP id d4mr30829486qvk.114.1548907869932;
        Wed, 30 Jan 2019 20:11:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548907869; cv=none;
        d=google.com; s=arc-20160816;
        b=YpW3zs/pdwyKTOrn9PD9Vnly30juUmWCNE2XUKmw9h6IBziUh6786IQNpFCbXldtKS
         7Nt6x62R0tSYZ09/fu1djI6Ted5ah754ODX4PjYnzPaNTdjMCcQX58bvEXYiO7TPj71z
         niNsRPjVJ1MkQfflcqQ+DOy/QjVgwRu1M/f9EeuQDmxT84KmgnUHu4nL7wmOO0YCXzeU
         1JwpfOsddZnbMsTFuRrVW4KVD60cmk0DgmD9gLHtarUlASx8VmRqgsx3X0Mb4wThzDAL
         zrlViEXFI9aTUqC/BuLXCEBiZ3Q2+3bARPvisPBEXFVoOsGtalU4JoeR8DUi9fjNrhIl
         XKYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=+qm6IAuBdYJ0KJEezxlGA4lLZCD+PJm0pFyznNM0TqM=;
        b=Mb60n6ZeJC8bGOurDaaTZ3pkUpxLIsjsNQXCRiC03hBpuW3woo6bza7zJkHiu6Tdll
         FBX1ZKSGdAos0/8VnbPC56ajAeLzOuJ0MR6dPpsCixgwFgBFL/iE3ymh16FjXFIguzgu
         SJxh8772YliQdjcAT3Ml9nWNOVo5LSwi3+bmsGHyy8NEfuuaUEGy2FjrruLv1D6jHbfO
         sbS9PmYTyrsbrhpP6j0Php0dj/WM+GNWt/cXbOc/bOf1VzIlKu9IMRe7iykzkcXrt8il
         vlXBfpzaZ/ymJ030guerUxrUoTb2E0yoW2BeQ0oNx8aE9OrIr8TysbB8B/us8jpt900D
         LCFw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=L4Kf1drA;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b="R25mjrc/";
       spf=neutral (google.com: 66.111.4.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id c4si534621qvo.215.2019.01.30.20.11.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 20:11:09 -0800 (PST)
Received-SPF: neutral (google.com: 66.111.4.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=L4Kf1drA;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b="R25mjrc/";
       spf=neutral (google.com: 66.111.4.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id AC8262221E;
	Wed, 30 Jan 2019 23:11:09 -0500 (EST)
Received: from mailfrontend2 ([10.202.2.163])
  by compute5.internal (MEProxy); Wed, 30 Jan 2019 23:11:09 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=from
	:to:cc:subject:date:message-id:in-reply-to:references
	:mime-version:content-transfer-encoding; s=fm2; bh=+qm6IAuBdYJ0K
	JEezxlGA4lLZCD+PJm0pFyznNM0TqM=; b=L4Kf1drAhsQV9rdCZsdUaatbA2lCl
	kGJljvJbkTAT2b2Tt9MYfnwGbOqVdw7DjKOrXfWtEIQHdBu96VGKlow56UQy/Cgu
	gOCe6dnmYpRsmvTe4wCHweH1DQ0yb0nJv2kfcAHvNh3LqFSGRAKc/+Ob9OqlVzPP
	t5dV7dgLy0zy8pU9ksi1r3Ka5DsLGCp/5ctjpC79d63qgymuVTQJawiNni3b6aeJ
	O84oaOJpJ7BOoUJyjywmbK/JU3a3bhTg8fpWXw7j2VmARIDH/jh1Jj2ZhG1eqBUd
	Ekobj4sOmRHlnV/1diYWfgd1AA+T3N8aHZzLSb8S2cmL/HuMq/RmH55nQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm1; bh=+qm6IAuBdYJ0KJEezxlGA4lLZCD+PJm0pFyznNM0TqM=; b=R25mjrc/
	LAGhD40XbnnU9l/QhALVsTi9Tu6c7taouJNs3lmWj2JGWbjcS65Leyh+R3Dc5em+
	DH3DD5yCow/9lRE7XBLHSg8zOgmICS+K2rXkCAhx00DH+nOLYaR0RgPqAxcFFnx9
	iaa6TzJ50qjamNzeHtmYFwCSEiZEG8YcPrfJ83sq4QrNr7+3KcpcajvXOTItTuit
	BRSDkrHp/FcKgA9ot5q1Jf2QiDSpG0QajojpUP8X/GMd/XJmlV0egimdP3/41pr+
	NS23fjvGqtMFv3Tyb4oGsUPqePVhIR2yE3BvWrijXUtr908cquvOEBU9lpTmn9jF
	y+rR2ifAqgDPww==
X-ME-Sender: <xms:XXVSXO21kSLiHAp1m2PEN4-OVMrjgTVd3UZW-tFEPUHzOmH9MVt4qw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledrjeehgdeijecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecufedt
    tdenucesvcftvggtihhpihgvnhhtshculddquddttddmnegfrhhlucfvnfffucdlfedtmd
    enucfjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgs
    ihhnucevrdcujfgrrhguihhnghdfuceomhgvsehtohgsihhnrdgttgeqnecukfhppeduud
    ekrddvuddurddvudefrdduvddvnecurfgrrhgrmhepmhgrihhlfhhrohhmpehmvgesthho
    sghinhdrtggtnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:XXVSXFVZHn9vA7AK_7wbaObvp4SM6DyPBkBugSIH8aANI3CG9bAdrw>
    <xmx:XXVSXB5UNTauek0eN9f7_PZhczRzW9Lz58c2O6HE_O7K3Rjb5BsHGA>
    <xmx:XXVSXELO7pzSPBpkfFn7eiPJr9cJaL8VpqYlTz7hXCbU5Nvd-IF6vQ>
    <xmx:XXVSXFNdNsuk7grXB-DrY3L2HZp-1PvyZW6fg4Enj4IW380K5mROBQ>
Received: from eros.localdomain (ppp118-211-213-122.bras1.syd2.internode.on.net [118.211.213.122])
	by mail.messagingengine.com (Postfix) with ESMTPA id 9F7B110086;
	Wed, 30 Jan 2019 23:11:06 -0500 (EST)
From: "Tobin C. Harding" <me@tobin.cc>
To: Christopher Lameter <cl@linux.com>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 3/3] slub: Use C89 comment style
Date: Thu, 31 Jan 2019 15:10:03 +1100
Message-Id: <20190131041003.15772-4-me@tobin.cc>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190131041003.15772-1-me@tobin.cc>
References: <20190131041003.15772-1-me@tobin.cc>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Tobin C. Harding" <tobin@kernel.org>

SLUB include file uses a c99 comment style.  In line with the rest of
the kernel lets use c89 comment style.

Use C89 comment style.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 include/linux/slub_def.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index d12d0e9300f5..c8e52206a761 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -151,7 +151,7 @@ struct kmem_cache {
 #else
 #define slub_cpu_partial(s)		(0)
 #define slub_set_cpu_partial(s, n)
-#endif // CONFIG_SLUB_CPU_PARTIAL
+#endif /* CONFIG_SLUB_CPU_PARTIAL */
 
 #ifdef CONFIG_SYSFS
 #define SLAB_SUPPORTS_SYSFS
-- 
2.20.1

