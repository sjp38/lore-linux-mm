Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DCB5C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 04:15:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4338B20851
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 04:15:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="FwMcvt+I"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4338B20851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E8A9C8E000B; Thu,  7 Mar 2019 23:15:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E5FC88E0002; Thu,  7 Mar 2019 23:15:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D03C28E000B; Thu,  7 Mar 2019 23:15:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id A25B18E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 23:15:29 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id o2so14972185qkb.11
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 20:15:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=4XtFG0o08VP7KrL9BCqmvaLWxmrIynX8gM/X1EsO8JE=;
        b=R+QEZXylOCuKuVnNRdigt6T8TykhAmGYfpvLWoa+WUC9RuP9tuxWMjYUrvIScUj0Yr
         odn+mnyTjY9fdFIasAoBt+WfUuPo4nxk9ziqW/LVggnuNL1IcxG7Vrgvuwv5boajuZ7Y
         88qUJI84BZ/w7DCUDkVqTDL/Bwl8f0NzLzM8+Hx9Rj5vZlN2znQu2+l7goOPxPJ1ymtB
         5SR8KzCW76Coi8a9a5SQ+jQAaqVMSgtiBi7lcYnXmNStABYER0rPOqbgmOK2yCDM3IHZ
         ela9+nRZZOrJVw7HPSxU3apj4C7YFsSO+THrwVJjvQ/MT4UZxT+s7s43RRkx5RCcJ/9A
         JAqQ==
X-Gm-Message-State: APjAAAUCsVC1PcnLvihszmVH0NXSoKnBGj8qShHQLVbulvIDJs86R8B7
	ypjOID4LTINPyjfjMjbMIfwMC8stcx7hcEX/8/8tpFq9ZoiCm+//97AF+9rLU0TmP4IKqnZ6RUW
	/h3XidA/JeINdW06q2oW56BEEY4uDbJ2JMxnMDiwZseFO7Rl6n26QQ8K03sqeE7o=
X-Received: by 2002:ac8:8d7:: with SMTP id y23mr932319qth.249.1552018529404;
        Thu, 07 Mar 2019 20:15:29 -0800 (PST)
X-Google-Smtp-Source: APXvYqwmxzrtjrGku56xOE0B0qKBLFGOeJUbT1P7L5z6uLaJpFX060qaIKdKD1zxclXUo4v1ZbMI
X-Received: by 2002:ac8:8d7:: with SMTP id y23mr932287qth.249.1552018528502;
        Thu, 07 Mar 2019 20:15:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552018528; cv=none;
        d=google.com; s=arc-20160816;
        b=yv/sD0AIuaLZ2xq7owCu3num3WGXy3yo8ViNmrfhkmsBkZzKkF3ZyxGeXi2D1LP1VR
         kJesZ+fT9ZBXl2pwtb4cuYTStu+sdEiqXQmWKa7S1SXY1RT86pl3orjqVspwnN/XUlyZ
         uK0oJx19VF+osSBqRB8Ux17XEx0G3YWOzOPwdG7xL1cQZ+1MgGKYEcCdAUPHP15nb9dX
         aon6sErAR2XyG5wYBGMs6w2Mny8IheqmdykvMDFI4P/6DWC2VVQPa9eNQzjOBMq7MR7k
         yYwm62V0yEtcQzgAO6fYPj+KVyu2hzVbW1cHWLvB+W7lBLQAog0Gfy2bjCejoHCQQveE
         XxAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=4XtFG0o08VP7KrL9BCqmvaLWxmrIynX8gM/X1EsO8JE=;
        b=fHs52yHC0iMyRTQUVp8IhHUUuFIjz736ICRTodQAC7Eq0WuOY6rI0enug+QlAHZiPi
         91bKh/z5oQymxrN52/nTN5rIqM1ps8P9bHciBd4UGrfkTv8k7RuPCFJGtroObO/jYhwb
         S6qE/rLwVPSR5ix6Y0hHGxkdy/8E9TN4tbyoTxDcFfB7P3NIAC2zDyM0ESkqzOa+4LX9
         UESzBqepszMNr/KKZ2cxpjaqg/ap+q6Ud8/OQjd1ZUmu9r4ANnCDPNum2uIvLT+xN6LM
         xCZZTnEnzGP9bwkWk+gv662nv7yZpeuwIRM94u6EzibECrOKlBiE5BSVFPlz5JbXHUKL
         +O5A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=FwMcvt+I;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id v26si2627721qtc.201.2019.03.07.20.15.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 20:15:28 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=FwMcvt+I;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id 0A22836B0;
	Thu,  7 Mar 2019 23:15:26 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Thu, 07 Mar 2019 23:15:27 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=4XtFG0o08VP7KrL9BCqmvaLWxmrIynX8gM/X1EsO8JE=; b=FwMcvt+I
	Q6eBIB2iK4dL8TExfycPnlKNVCKTFW8q3Yq/KTCK1JuEko249NK4a1+3yEsOkkhv
	IU3BzXm7+zBA2Gr19tP2teZwKZeTUiseqG/p4mMXXUympNWXRYPPxjwbgTNFmO81
	/SrCZK0JuRHwIiOp5giq/JBqjKQXUi/fkJCgd3lh+shN2aRX2OCHOLiy0NLv3wR2
	AaaeYRe0sTgtPbRvmMgjmzfQMKNWVR7Fn1DFjryvgHD2g0Dpc3MeaTvxykX8z26/
	JZk/i8jxYjkGVQPkPJnW5nWIA4PK6vp3w0SaMp1fgJpYaWm3OFPu7qX/DjlPjAgF
	NeZAV6H54Fu6Og==
X-ME-Sender: <xms:XuyBXIReSHnPqgn7jiprdoGATVYGXBR0VkTHdS6ibslL8jFZtFDaew>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrfeelgdeifecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudeiledrhedrudehkeenucfrrghrrghmpehmrghilhhfrhhomhepthhosghi
    nheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgepie
X-ME-Proxy: <xmx:XuyBXBoWKIsOw56NC0VVCNX3Kl7szTdOj2fOBXFEsRp9RiVLgxK_Iw>
    <xmx:XuyBXOrVwKHk_gK0_iVYMPy0niO7cgrjHHT4KK-bNd9opOPvtXumNg>
    <xmx:XuyBXE2jyw2K1I_1W3CeAs0tjc1lM2JWLljuy_Y3DRm2Ffdch_8F8g>
    <xmx:XuyBXMeRxWZRjlywgwGRGLRC8eNG-FCBsUDfVDZL5L38k_A9zXYvwQ>
Received: from eros.localdomain (124-169-5-158.dyn.iinet.net.au [124.169.5.158])
	by mail.messagingengine.com (Postfix) with ESMTPA id BE16FE4481;
	Thu,  7 Mar 2019 23:15:23 -0500 (EST)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Christopher Lameter <cl@linux.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Matthew Wilcox <willy@infradead.org>,
	Tycho Andersen <tycho@tycho.ws>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RFC 08/15] tools/vm/slabinfo: Add defrag_used_ratio output
Date: Fri,  8 Mar 2019 15:14:19 +1100
Message-Id: <20190308041426.16654-9-tobin@kernel.org>
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

Add output for the newly added defrag_used_ratio sysfs knob.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 tools/vm/slabinfo.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/tools/vm/slabinfo.c b/tools/vm/slabinfo.c
index 9cdccdaca349..8cf3bbd061e2 100644
--- a/tools/vm/slabinfo.c
+++ b/tools/vm/slabinfo.c
@@ -34,6 +34,7 @@ struct slabinfo {
 	unsigned int sanity_checks, slab_size, store_user, trace;
 	int order, poison, reclaim_account, red_zone;
 	int movable, ctor;
+	int defrag_used_ratio;
 	int remote_node_defrag_ratio;
 	unsigned long partial, objects, slabs, objects_partial, objects_total;
 	unsigned long alloc_fastpath, alloc_slowpath;
@@ -549,6 +550,8 @@ static void report(struct slabinfo *s)
 		printf("** Slabs are destroyed via RCU\n");
 	if (s->reclaim_account)
 		printf("** Reclaim accounting active\n");
+	if (s->movable)
+		printf("** Defragmentation at %d%%\n", s->defrag_used_ratio);
 
 	printf("\nSizes (bytes)     Slabs              Debug                Memory\n");
 	printf("------------------------------------------------------------------------\n");
@@ -1279,6 +1282,7 @@ static void read_slab_dir(void)
 			slab->deactivate_bypass = get_obj("deactivate_bypass");
 			slab->remote_node_defrag_ratio =
 					get_obj("remote_node_defrag_ratio");
+			slab->defrag_used_ratio = get_obj("defrag_used_ratio");
 			chdir("..");
 			if (read_slab_obj(slab, "ops")) {
 				if (strstr(buffer, "ctor :"))
-- 
2.21.0

