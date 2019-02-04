Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4501C169C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 00:57:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8262F20820
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 00:57:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="PSCWH+4R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8262F20820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 219A98E002D; Sun,  3 Feb 2019 19:57:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C9518E001C; Sun,  3 Feb 2019 19:57:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 093C58E002D; Sun,  3 Feb 2019 19:57:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id D25E08E001C
	for <linux-mm@kvack.org>; Sun,  3 Feb 2019 19:57:45 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id k66so15270509qkf.1
        for <linux-mm@kvack.org>; Sun, 03 Feb 2019 16:57:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=XQDJC6eQAtw+8e8Xzlnxqu6fJLyDeNJ8trLkEmZ1sR0=;
        b=boy8NKbPXGFaen1N3oeErYM1c8VXaZT0egswQc+1ZNt6z9+gKOU4zHhOsl3KGROJ6M
         r8BgSx6Mya8IvlAS5oJ2CH7uGdUIk0UGswvUe+EUHS3xB3a/tXB+8lINg2IFqsBoCQT9
         JNBe1qHIaNjqdBDAhjFgIWCenmyc0K/xK2xfNptVfD07BGi+p11sXesMCkFX532vAHNo
         gEt8PR3k69FVizqQtD2rhaeuOeQa33RgyLkeX4mNKJjTFEF1b9uLoI533VIU4C31sp4r
         qPTl2CguQ0mcXH1pndY2eG6egfjH2RmiNpnGNJlEGzVoyFBR8QvNhQIelPItQGg9hwHk
         BQMw==
X-Gm-Message-State: AJcUukfN7QDGCI991wT8JzSm9gRpTHE+PEofazOkkuSosIbM5zHF0F+Y
	dMHBqXS+/Zz/Br+jYZx4yH3Sb4X3TrUEu6iNS6tsx9t8TQJf5/HyUqk0wjiZ7UpA+/l/Uip4qPU
	nXLwmijg9/bCV/E/l9+snPbeUdOl35KLdleqCSVotykKj8s7qjC7e1b1q5ALhzJ0=
X-Received: by 2002:ac8:1d12:: with SMTP id d18mr36262027qtl.343.1549241865623;
        Sun, 03 Feb 2019 16:57:45 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY2CuWiV9U3Ie+asIsmZpgZopgcUxXm7Hdm48LkM5jpuS9uDDpD9yv1EzskOmWtwLUt0QQR
X-Received: by 2002:ac8:1d12:: with SMTP id d18mr36262008qtl.343.1549241865078;
        Sun, 03 Feb 2019 16:57:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549241865; cv=none;
        d=google.com; s=arc-20160816;
        b=YHlYN6csdVkkr+s0Bb/T73MEYdGd6sWab8U2euP1NaQjFnpE93OkvxGyGjlTV83ugd
         NngzPxFKMM3rqufuvxriYD9OarFolNPt9HQzkJD545PX0jFxfVD19HTyk0AxL47KagOs
         9OZvNJTfhYNHPaDR57BxPR2RylYNfywvo3ObDyB+SBu8eqkEIhp7u16K9fP9zLfB0qAX
         VVVQeI2916Rs/G+UZ0RgIvOdhnoYfJSnrihZdb+u8rT/r0/HSq1lAOeG3R1F4ni+03EC
         gVIsL/XLek55zRM6Zis02MSVQujWPQzwWRxvyvx1lkFlgsE60fZwcppUPj5u7R13mcR1
         K32Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=XQDJC6eQAtw+8e8Xzlnxqu6fJLyDeNJ8trLkEmZ1sR0=;
        b=IvDV/IKF7oa8Iuxp1zngyasA6bcNJaeCcpqiagDrB4eUV4mDaQkkFPsIe9snmQFgGS
         nAawPfoiKmpxGAB+4wrrTBXQZY+DXOosMyuDHArcCIyxJ+rSBEdB2vLRG11QlMbBMeZz
         7XV2RvjloX3JUuEGTgWHXgBp7yu2K1uy5SZlgLFT9gFdJ/v0wt4FoEa9jOrjlwp/IGaQ
         qW7e3DDAV7EC2NVOYOWnrlnRs5rdmP6o1pfAODnfWuHlTSwl3wSa0nupSEO7kHUZg24d
         kDDiB2VV5N8SRa4VBN50PYmU/flBNbbB1F8ctzKiobLgI7+kAR6cLQFmWV/luTLUFyGw
         Xrtg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=PSCWH+4R;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id y65si3163305qky.128.2019.02.03.16.57.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Feb 2019 16:57:45 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.25 as permitted sender) client-ip=66.111.4.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=PSCWH+4R;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id C7E0220CF2;
	Sun,  3 Feb 2019 19:57:44 -0500 (EST)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Sun, 03 Feb 2019 19:57:44 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm1; bh=XQDJC6eQAtw+8e8Xzlnxqu6fJLyDeNJ8trLkEmZ1sR0=; b=PSCWH+4R
	8xRnjbTcSafhHKm7O7q9v2+h1tuCE4MpDN0RpP/uTw43mYlNptBPNHqzx+k8eApS
	sQ2ezK9YHF2EJNIqbBliBA/k1H1wV1WMPeeawASIWLH+G1NQ5I5KIuDtdaNUySyW
	xsTwiUAc9Dg9ysNEq5FS7Ug/kkjs2AZYP5QPhMDIp5zNOr0D5ddBU8l+1AEXNh32
	M/rsQNfU5N9cUrOtbQ9KXkfeKz1xI3VsoV4o+l+pKzjdqXayScSz7fc0+KqDONj/
	EvhVx/xLQjVikd8w1Lp1HV4bI+e4OB3+az7pJq1IMvJra/b0zIvtF7GqGywnYivT
	JA8OSd3XfdiAWw==
X-ME-Sender: <xms:CI5XXDtup5RKL-0YXo-hnGTo6dWfWWGgBOBHLEQp6EMGSID1dJ6SnQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledrkeefgddvjecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecufedt
    tdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhephffvufffkffojg
    hfggfgsedtkeertdertddtnecuhfhrohhmpedfvfhosghinhcuvedrucfjrghrughinhhg
    fdcuoehtohgsihhnsehkvghrnhgvlhdrohhrgheqnecukfhppeduvddurdeggedrvddvje
    drudehjeenucfrrghrrghmpehmrghilhhfrhhomhepthhosghinheskhgvrhhnvghlrdho
    rhhgnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:CI5XXMDQLzyV1vJ90U65DfL7FdBVh_y03oOsIcYxmK2Wn8HcoX1-8A>
    <xmx:CI5XXOV-ICvss76W_6OHH0nw70g_5vrpPTpImEiQiswrrn_5G0_n6A>
    <xmx:CI5XXCJNJq237asu_PsuiU0_WhCToq-BcRNGPD7pOgTE-dr1EE-vDg>
    <xmx:CI5XXEAa72wilVoEYkoakFIF4quDBwGDG-QAG9vTO8Ub3qUU3tdDjw>
Received: from eros.localdomain (ppp121-44-227-157.bras2.syd2.internode.on.net [121.44.227.157])
	by mail.messagingengine.com (Postfix) with ESMTPA id 4D4A710087;
	Sun,  3 Feb 2019 19:57:41 -0500 (EST)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Christopher Lameter <cl@linux.com>,
	William Kucharski <william.kucharski@oracle.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v2 1/3] slub: Capitialize comment string
Date: Mon,  4 Feb 2019 11:57:11 +1100
Message-Id: <20190204005713.9463-2-tobin@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190204005713.9463-1-tobin@kernel.org>
References: <20190204005713.9463-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SLUB include file has particularly clean comments, one comment string is
holding us back.

Capitialize comment string.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 include/linux/slub_def.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 3a1a1dbc6f49..541b082ffcaf 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -110,7 +110,7 @@ struct kmem_cache {
 #endif
 #ifdef CONFIG_MEMCG
 	struct memcg_cache_params memcg_params;
-	/* for propagation, maximum size of a stored attr */
+	/* For propagation, maximum size of a stored attr */
 	unsigned int max_attr_size;
 #ifdef CONFIG_SYSFS
 	struct kset *memcg_kset;
-- 
2.20.1

