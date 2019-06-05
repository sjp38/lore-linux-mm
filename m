Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4CA8C282DE
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 06:02:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 76FA32075B
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 06:02:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="d8ZvxiH8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76FA32075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C1BD66B0007; Wed,  5 Jun 2019 02:02:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BCC946B000A; Wed,  5 Jun 2019 02:02:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ABAD16B000E; Wed,  5 Jun 2019 02:02:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 72B236B0007
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 02:02:38 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 140so17929721pfa.23
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 23:02:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=+mL4FgQ19EroXhijChjGHOiTYmNvNkGMP7gXP3vKz00=;
        b=d7kBv4dGjtAL/tUTWomq2MFIQN2OCLR4NXpBJCobvQqwXcw19pRoZo0K3xiCwIO9KS
         2E1/z1VBpCg6QXu/TWIxEEkM7wXRGFc1Fg6z0nBxwDRo/CMfjsQr8ocnE7k+Z/FV1ZYf
         6jei8wZvbsccDpaC8ECbjY+76yswiOyK17M3Gjv+etaEWU5WoEAULNXZval+R6rnqpR8
         kQ8OMnVtu0Z125gZ3o0/qD3wy6rgS8kHSQVIIx9/0+Ltd0t1Hy2nj4ypfqaqSOvtgA30
         sTl2wLmgf9Hb/1RkS9iXp9YFMeit3vBfkUsy+/f1YGr6oJUZzxtqtZn2MYDvruhC0Bb/
         7Z+g==
X-Gm-Message-State: APjAAAXi4z9RqFVzJDTxDRs5AzmCJnOi65OChKnrov5G8qNAEd5e9TzV
	/EmcYNNh4RBuocSi+olFtbhEgwYCOrIMvgdhqYrtmVJIV6QxJwF+V9kbL6IHmhS5EMB4Dv2QjaI
	MVeAERXRX4OmVIdfd+GyfthcqZqTRlyS4tIEuq8iVQaL9f/G71zq2U8p3/P0vwGHSNQ==
X-Received: by 2002:a63:4006:: with SMTP id n6mr2191705pga.424.1559714557764;
        Tue, 04 Jun 2019 23:02:37 -0700 (PDT)
X-Received: by 2002:a63:4006:: with SMTP id n6mr2191590pga.424.1559714556718;
        Tue, 04 Jun 2019 23:02:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559714556; cv=none;
        d=google.com; s=arc-20160816;
        b=pep8OCl8P4WPKWvVd0uLtwLrIho3uOXdg91DfZQyPF59ghTLJp692ROce/YfK4FqcP
         ahwB5MhoVr/1/PWWrGMSPrSJ9qRI7BLQTfuSD8tts/aSgLtXmi1oKyJDtwttepTc0/Yk
         /xFUUfcCJpZxHd3iPlBwX8VHwHRDYruHZPD8rcUT/L7UbzTanpsmCPJLenaWN3NZivIm
         b7mCK/FRoyrY7p3YVD6aHjHmFfUlhDpHj7SVHl82hL90ffQ9m6tR6+FKWKzrhyXHYh7S
         G2pVG2gz6m5Ms2xnyK/IF2s5IQfgrTjUUTh0CTGrAvE7w37OitsZ25r8msj1NvszeH9p
         pvoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=+mL4FgQ19EroXhijChjGHOiTYmNvNkGMP7gXP3vKz00=;
        b=L2HydBFRYYecHlHCKkIDLpEZEVzcBKSGEpSsMMLcALatIiwNUr77qNGCdnue+L6p8V
         LGShwNUn86R97RWEMTj5tWOYmgwVzdOMpaEPMSFpCYTLpEtxwtVaHqO7ynDYAINaIu4d
         WVopj3bJviG6PATjrLhlisC5Iwf4rWNBUzABw6t0wZrE++mySx0dift/oBnWiitZMggc
         tG8w1h/XEbRQZZENiFG86naE1I1p/qH0YBbZIey1JBGJSAP8lqBcxog9hXWqxWnuNvP0
         dtPLD2RZmMcJXs3hzAY23pBkM055yDLRZE0q4n7yhxOiBgN63kqRLbUnpNjmpRqTylZz
         jAKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=d8ZvxiH8;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d1sor7570712pgt.65.2019.06.04.23.02.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 23:02:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=d8ZvxiH8;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=+mL4FgQ19EroXhijChjGHOiTYmNvNkGMP7gXP3vKz00=;
        b=d8ZvxiH89al4I/4f5vPjsl6RJCAYuBwyr5JZ86FJPZePkQ9Ev2NOSlwuv3X66y/Z4D
         q/B05M4hwLcOu9pDU6heJbhMtQvWUr/2vdCxtp0DhHcfYmxse5+gHlic6msQL3HiA67c
         beApp4NKO1NfGHj+p2P+yLS8IVF3dHavOE2fPO8TuwbbdCzanev+M2ehx/kiTWjgDbGS
         c2zxtr9M8BPnA4tzU81hgiHhp6oquEpttG7B3NxRng1Vwz1NZK77vTKlPhMsgFTKEoWC
         +9ma7/4q7NrrIhyY2pJ+E+zgExMUrRzbJnrOhorpSulak1udo/aReyAYc8MsXpr1AtQ6
         3oJw==
X-Google-Smtp-Source: APXvYqwOzv0XDxxLIsCmIFRx2hA1nEXey9WmOKU0t6xsnmkEzGTrpoAGAeqHpapGRiSK90VIqiHW1A==
X-Received: by 2002:a63:fe51:: with SMTP id x17mr2094853pgj.339.1559714556080;
        Tue, 04 Jun 2019 23:02:36 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.36])
        by smtp.gmail.com with ESMTPSA id u184sm871872pfb.32.2019.06.04.23.02.32
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 23:02:35 -0700 (PDT)
Date: Wed, 5 Jun 2019 11:32:29 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: akpm@linux-foundation.org, vbabka@suse.cz, mhocko@suse.com,
	rientjes@google.com
Cc: khalid.aziz@oracle.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] mm: Remove VM_BUG_ON in __alloc_pages_node
Message-ID: <20190605060229.GA9468@bharath12345-Inspiron-5559>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In __alloc_pages_node, there is a VM_BUG_ON on the condition (nid < 0 ||
nid >= MAX_NUMNODES). Remove this VM_BUG_ON and add a VM_WARN_ON, if the
condition fails and fail the allocation if an invalid NUMA node id is
passed to __alloc_pages_node.

The check (nid < 0 || nid >= MAX_NUMNODES) also considers NUMA_NO_NODE
as an invalid nid, but the caller of __alloc_pages_node is assumed to
have checked for the case where nid == NUMA_NO_NODE.

Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
---
 include/linux/gfp.h | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 5f5e25f..075bdaf 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -480,7 +480,11 @@ __alloc_pages(gfp_t gfp_mask, unsigned int order, int preferred_nid)
 static inline struct page *
 __alloc_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
 {
-	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES);
+	if (nid < 0 || nid >= MAX_NUMNODES) {
+		VM_WARN_ON(nid < 0 || nid >= MAX_NUMNODES);
+		return NULL; 
+	}
+
 	VM_WARN_ON((gfp_mask & __GFP_THISNODE) && !node_online(nid));
 
 	return __alloc_pages(gfp_mask, order, nid);
-- 
2.7.4

