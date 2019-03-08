Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FC45C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 04:15:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5C2A20851
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 04:15:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="OlWWky5J"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5C2A20851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3402C8E0004; Thu,  7 Mar 2019 23:15:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C8168E0002; Thu,  7 Mar 2019 23:15:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 16DCB8E0004; Thu,  7 Mar 2019 23:15:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id DDCEA8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 23:15:04 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id 207so15118139qkf.9
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 20:15:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YrkkvhKvCcH6zbANtTOO3evnEL/yeR53kt/mCY+Xjj4=;
        b=Haltu6ueLrfnfR16x/0r0QImi4CLDeJZQp4RJdUzDN5NWN7igzxnLApIBWU4GhH98i
         d0zV74PlyVXLKWPBTZEpfBd7fzjXWjfdEM/jL232xf0Nb9dFQU9U5qkteDf24uvUFnjN
         KUJRmWEdusNCnfopEcpHpBEPxu11WngGgqqNdyTLCKBoRh1fep5RpD6cPR/rb1KJM0Tf
         dyeFqoKOrH97ahsinAHuYGQy5paRcA1jlM4wai62qAvyCm5l/u1jtHl3qedqOr/lYKJl
         plBgDSeMXOK04gLpzCyI7R+sZuYhnrOm0jvX0fzLWwgSId6Psb0/sQP8lfNWESgSbsLc
         bBvA==
X-Gm-Message-State: APjAAAUu7zezWw9tGGenftNHvkpZQDWdAHXeglybHOVBH+/eD41wbfi4
	TKGzcn0IVH9uj07WOOvR3c4sBsUfb4wvlSVaURdSezoSIooTg9nrLUFb1huGYByAnVQXYRm0UbK
	zsnZX/6VnLH4ZGh1WHoOR4lhEj1GKf8c1L4bc7+aI/c9oQIaOaPE5viOYvaBbA4Q=
X-Received: by 2002:a0c:aecf:: with SMTP id n15mr13479608qvd.1.1552018504614;
        Thu, 07 Mar 2019 20:15:04 -0800 (PST)
X-Google-Smtp-Source: APXvYqwSNBTI37z1skK9JamvJWH6mQ+OsND8RNk9FvuuCSmEJfs5ZHWFR1yoz3lh0JvpTCUBD6n/
X-Received: by 2002:a0c:aecf:: with SMTP id n15mr13479570qvd.1.1552018503680;
        Thu, 07 Mar 2019 20:15:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552018503; cv=none;
        d=google.com; s=arc-20160816;
        b=0JRQL9tUZPIMcUcHig1xufWYoHy33udy2xM28GbX3A7Qf5VXDa+7dMKfrYreMtBIAq
         GvlBxbnrAFTZhT25Bq+QYoCvUHXGQ813uCCXQUnuFXcNZIIZTA49CsMweoVxtafe8rC6
         QWM3oZDPIsH+GKOOKk99kgu/efZ11qM4GfikMRisNxNdrZHxRRFJG4L12wWs8ff4HVZ6
         5E2AFll8nkNJ4DYEEZcy310Lkb423+DaOgHcJDQansyybUhC79UnevX22mSQfJo/l0bL
         QLj4WGyvP7ZwTVOKz+7vsvIlWaDKWCccCCgRtAwNpwGjOfMVPEfItYYyEo1tdmtlHZvf
         Yn4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=YrkkvhKvCcH6zbANtTOO3evnEL/yeR53kt/mCY+Xjj4=;
        b=weRK5XmVoYBaRuzJaKqF9vr4uQ1hS6lOVYf/9k6vvzaCLGTRlw8NMI6mWDGu+Slrxe
         LL/ECPdK0RYR1/F5M6aO68014TWXkvmlRPoGpUGD8o6Z/WJ3KUCWC6trdgGJxAxdQjbc
         5LubwgoFT+HxF3DhjbI6llNZh5bWRJ5EZRcWS0SWzA9ZU5j/KsMJKS//gCvvIY3o/Ls1
         jMQKg20xdCd9jf0h7Up5LWw96jBJFQrYlpR8Fg/H1prJJHExs66qVP07RskaiuBKUhdt
         MQDCNZAAkiwN2Q7XG7V/twOA00Ggty5BQwUtjEWk5cRoAPXA2WyElMwTxu+MmVh9rDrC
         KzKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=OlWWky5J;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id f75si4286277qka.125.2019.03.07.20.15.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 20:15:03 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=OlWWky5J;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id 24F41173F;
	Thu,  7 Mar 2019 23:15:02 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Thu, 07 Mar 2019 23:15:02 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=YrkkvhKvCcH6zbANtTOO3evnEL/yeR53kt/mCY+Xjj4=; b=OlWWky5J
	7OckGmNFMQaEaOY6sf1Ou0vdYhzjSmfwaHiUVmGSfl5JXRrSck5DtHCtovmRKRTb
	J0ur6QFL9dnuLNJ5Kkxuk3BSAQ2cFa+SrtgSrY7rAUH8ZENrontbrNldEybTAceD
	46/5jJvX19lViao4nLZ7GTkUNu8x6A/fhkIq2As6xYgi2joDCRWfPvdfQXa0YsZG
	Cagk0p6DpL/bTLgcxaVwzEWMVa92noye933XVO8NHRpqeyJkIJrcj8JwQ2yV6cWJ
	maJt388s5hzuw+6WqClq78c5JEBgKJC2JstrjA6BZXICVRc99k8WlnT3jp6xBy/i
	7d2h8zkKlRDxCA==
X-ME-Sender: <xms:ReyBXAncFa5yP66KpUPsSd408Rc3U77ZUFJ8MODTUcHRrnZR4qq6FQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrfeelgdeifecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudeiledrhedrudehkeenucfrrghrrghmpehmrghilhhfrhhomhepthhosghi
    nheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:ReyBXJ7QNAJGnOaEq2cInc0LekTnomjsyTQctMvWD-vS4WZf27yMVQ>
    <xmx:ReyBXDkTPccY9XfWiwT1383YpwxFZveUs0LVQIPVk3xsExDhbIyPhg>
    <xmx:ReyBXEVIwFTipdEanz2WePYdXVTWfc8haukikBxdG3v-umcz_Yq9Kw>
    <xmx:ReyBXA-82aZXc2Gj6YvkfX55H9XU4NYMcvsHJAxSb7QD79_SP6bo6w>
Received: from eros.localdomain (124-169-5-158.dyn.iinet.net.au [124.169.5.158])
	by mail.messagingengine.com (Postfix) with ESMTPA id A72B1E4548;
	Thu,  7 Mar 2019 23:14:58 -0500 (EST)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Christopher Lameter <cl@linux.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Matthew Wilcox <willy@infradead.org>,
	Tycho Andersen <tycho@tycho.ws>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RFC 01/15] slub: Create sysfs field /sys/slab/<cache>/ops
Date: Fri,  8 Mar 2019 15:14:12 +1100
Message-Id: <20190308041426.16654-2-tobin@kernel.org>
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

Create an ops field in /sys/slab/*/ops to contain all the callback
operations defined for a slab cache. This will be used to display
the additional callbacks that will be defined soon to enable movable
objects.

Display the existing ctor callback in the ops fields contents.

Co-developed-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 mm/slub.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index dc777761b6b7..69164aa7cbbf 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5009,13 +5009,18 @@ static ssize_t cpu_partial_store(struct kmem_cache *s, const char *buf,
 }
 SLAB_ATTR(cpu_partial);
 
-static ssize_t ctor_show(struct kmem_cache *s, char *buf)
+static ssize_t ops_show(struct kmem_cache *s, char *buf)
 {
+	int x = 0;
+
 	if (!s->ctor)
 		return 0;
-	return sprintf(buf, "%pS\n", s->ctor);
+
+	if (s->ctor)
+		x += sprintf(buf + x, "ctor : %pS\n", s->ctor);
+	return x;
 }
-SLAB_ATTR_RO(ctor);
+SLAB_ATTR_RO(ops);
 
 static ssize_t aliases_show(struct kmem_cache *s, char *buf)
 {
@@ -5428,7 +5433,7 @@ static struct attribute *slab_attrs[] = {
 	&objects_partial_attr.attr,
 	&partial_attr.attr,
 	&cpu_slabs_attr.attr,
-	&ctor_attr.attr,
+	&ops_attr.attr,
 	&aliases_attr.attr,
 	&align_attr.attr,
 	&hwcache_align_attr.attr,
-- 
2.21.0

