Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4FCBDC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 05:32:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F406F2087C
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 05:32:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="jokTLtgM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F406F2087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3492C8E0004; Thu, 14 Mar 2019 01:32:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D1D18E0001; Thu, 14 Mar 2019 01:32:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 14BAD8E0004; Thu, 14 Mar 2019 01:32:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id DBD1B8E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 01:32:09 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id y12so4317523qti.4
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 22:32:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=D6RBo2xA005T3vgh61b+8gQHpH8S5KLC0eS56YqC/3o=;
        b=KCL7rLXYANTHp91oVLpJwH8r7fXOXUnKBK0LfV42vEnQgZOCnmsRdBDAdyVbgD1RpZ
         nWSav+H3gm9FwASvd2gG2V62gRTNhNzv01w2zZd/AmX4otNNNFYPS56NInsIf+/fvU0J
         1QIqiuJbwKV66JOzOBRsaGvyNCBaJvw6ALrwOhLqiKnHYKMzh3n/MH+eK11NBJXUvoJN
         unHAH6tO31H0AhAQP0qR0599J/FBt65buGYNXvoGrJL9u6bgAXZpK2tF77dGf0O1U/DE
         SrUVY1ejy8KjXX/db+T0APuwXWw+K2Cnk3P/QukIb5vhE9L6AgZnaJQD+AgkrnF+6ws9
         5Rmg==
X-Gm-Message-State: APjAAAU/TtzTuBrXpenRh+SI6dDVni79mHkuhriPaNz2qSiXiXsljQMS
	grT4IEqEB7pQx0G/CH6TyCzdT7rmAGrEeIlvtMw9l/sNfKHRGCflViLqQCnavJXxKBH8N1sAwD2
	/tFHnFuJ1ixJn8teFLpdFusRFXMSm5LWpDpZXxasin+1NgP8CYhtHdu/QjyfMYkw=
X-Received: by 2002:a37:4dd0:: with SMTP id a199mr35511332qkb.318.1552541529646;
        Wed, 13 Mar 2019 22:32:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwzdEUyKDydUFzLdYuduP8pPOy4aaUPhMV+TpM1VkTxpYq2EjCtWcdp8va77DA+3YMzmKtg
X-Received: by 2002:a37:4dd0:: with SMTP id a199mr35511299qkb.318.1552541528976;
        Wed, 13 Mar 2019 22:32:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552541528; cv=none;
        d=google.com; s=arc-20160816;
        b=DkcAFb6QHCNYsOi8Wr95iPQhZd/p4jlkteGAQy4c3MxsPShQslZIVCcK4XFaKqV2tX
         jNlw2XqpjKRiNyr2/6TnNUSSKzpNP/SPU3S6Clx2lQC2T4svfy8O4BW4LswIAMYh2/l8
         tcDuuA7l3LHVQ7ZMRqKpKrLdT1FsnD8ZS9qWVSEkxOcXaMCRBWegf79h6cNOpPpf1BK4
         8otmTrwB3QrmeCLLD60osBuiUolkW3LnjW/2zioOzqwnVbDj2sxxdXbo7XbDHjE0voET
         /jlor3EJVqaaTI1elPoJ8XNEolrjITEILI33RljcQcYSRMLtsdqG1MMLzZheWbN3FEkW
         OAJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=D6RBo2xA005T3vgh61b+8gQHpH8S5KLC0eS56YqC/3o=;
        b=0/ALFaqvrRhTDKqmF52ipgg7nocS5bWJgVhDWGOd2g44UrqYqVsbQyiBUrtKG9cGuh
         SrnbXT/fMpen+l0FuAxHe/jQifrsXCOFiaYKErxPda2WIXz2kUPw18a0Ya46Az4JGRa3
         4Ny7J7dItS8DcHeiGeu/euIEj5hHkUckCoRMujYj5EZPUYxsKGN9luHPm3Wl6jxAW7os
         A+q2Qxsw8xKs+iZuOCsMkaGBRQQm7Ak1XQ5pNLK4xuEJCD4GQHW+HcCocrJ3FdsNkauu
         F39iefF2Cj7QgNKO8kpxV9v6wC3zKSErMx1M1piS0qbT/A/GKNAUiVfkUpiFEP/2JyH0
         Y6YQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=jokTLtgM;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id g63si9163971qkg.261.2019.03.13.22.32.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 22:32:08 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=jokTLtgM;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 9482621550;
	Thu, 14 Mar 2019 01:32:08 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Thu, 14 Mar 2019 01:32:08 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=D6RBo2xA005T3vgh61b+8gQHpH8S5KLC0eS56YqC/3o=; b=jokTLtgM
	Pw26V8ZDtMnDR0czqO17EIIcwvEW/JO0xXkBcGUhyIw+0oppZVFCW8NduwfH/UeT
	1zQvwPnzk8HwOk5PMEqWQZjm06otbVy4h42L25gnq4mFk35xBjibdPCPvVFbeHTl
	n8gfNwLz8mjdCZNblYO1EX3wWWe5vmHY1Qm8cXV27ox/rjwGDt7or3jiSBcPSB0E
	eZSu1ne352wvggS7swjQ23vKAR0wJY2+ode7jQ/hhXFQd4Ub6L5o3kv463FjfzIt
	v+I3lwVjurRoQ5Zt+PwXLQxloGGAJTnCk+lfUvNXI95APCINQjM1mhfwqWtRNkFU
	bDPAdWQ2KV943w==
X-ME-Sender: <xms:WOeJXEurL39Wn7M4NqnAgDGjp7VVGpC7lop4WQN7AT8PeIBuTNlMTA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrhedugdekgecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudeiledrvdefrddukeegnecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:WOeJXMIp-xDfTnXcvsH5nHpwjyr81vC5a40qkb2V6175T36BApu1FQ>
    <xmx:WOeJXGbGDKqc5G_15E3_DAaQYu-cphvi5343CgTCWUsyRTECteUbUQ>
    <xmx:WOeJXCK54Ni_Htqi9TD03s_Za5AHj9BSeqI-0ioIVSJULx87gewbHw>
    <xmx:WOeJXHRfat0peDtsBxFlK_JnN6aEtp-eRXbUw004oEU-PGdpoc0qEg>
Received: from eros.localdomain (124-169-23-184.dyn.iinet.net.au [124.169.23.184])
	by mail.messagingengine.com (Postfix) with ESMTPA id E4137E41BB;
	Thu, 14 Mar 2019 01:32:04 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v3 1/7] list: Add function list_rotate_to_front()
Date: Thu, 14 Mar 2019 16:31:29 +1100
Message-Id: <20190314053135.1541-2-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190314053135.1541-1-tobin@kernel.org>
References: <20190314053135.1541-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently if we wish to rotate a list until a specific item is at the
front of the list we can call list_move_tail(head, list).  Note that the
arguments are the reverse way to the usual use of list_move_tail(list,
head).  This is a hack, it depends on the developer knowing how the
list_head operates internally which violates the layer of abstraction
offered by the list_head.  Also, it is not intuitive so the next
developer to come along must study list.h in order to fully understand
what is meant by the call, while this is 'good for' the developer it
makes reading the code harder.  We should have an function appropriately
named that does this if there are users for it intree.

By grep'ing the tree for list_move_tail() and list_tail() and attempting
to guess the argument order from the names it seems there is only one
place currently in the tree that does this - the slob allocatator.

Add function list_rotate_to_front() to rotate a list until the specified
item is at the front of the list.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 include/linux/list.h | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/include/linux/list.h b/include/linux/list.h
index 79626b5ab36c..8ead813e7f1c 100644
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -270,6 +270,24 @@ static inline void list_rotate_left(struct list_head *head)
 	}
 }
 
+/**
+ * list_rotate_to_front() - Rotate list to specific item.
+ * @list: The desired new front of the list.
+ * @head: The head of the list.
+ *
+ * Rotates list so that @list becomes the new front of the list.
+ */
+static inline void list_rotate_to_front(struct list_head *list,
+					struct list_head *head)
+{
+	/*
+	 * Deletes the list head from the list denoted by @head and
+	 * places it as the tail of @list, this effectively rotates the
+	 * list so that @list is at the front.
+	 */
+	list_move_tail(head, list);
+}
+
 /**
  * list_is_singular - tests whether a list has just one entry.
  * @head: the list to test.
-- 
2.21.0

