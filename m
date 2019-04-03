Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7FCACC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:23:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2EEC02084C
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:23:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="8g49H2KY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2EEC02084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D98846B0277; Wed,  3 Apr 2019 00:23:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D70CB6B0278; Wed,  3 Apr 2019 00:23:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C5F5D6B0279; Wed,  3 Apr 2019 00:23:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id A2B136B0277
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 00:23:30 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id f196so13643321qke.4
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 21:23:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=eB8W4ZifzOOx7n477C9lsHSgteznueDWRYbTVC4RGG4=;
        b=b+5gwRgWFajPZy+qqDmBe1rjk+9Uc+oaPmN0A6LFLL4Zk49w7uudPp7ee/EC7HVAM+
         B1MNVSHAGCzqZKQhX2lQCX9entNcTnn4LE4lZQhRWMvWBgXJc1sKuW8RXdKae/8WuHiJ
         H/PuomiYwOA36mI1tTWL6RcTHMUMHswe0PiRuFDn1tNWLH+1akLMxcdcq9RUDL3NaIg0
         j3wViUnbb4kawUpRg0Z+P11FFaIna8VZ/F9KaDLFJWK0i4cfu+5aSt8BSow7INewB9Ad
         fnTMkGZszuLBbIMZUMjVoEYJcNnQZRmwUJNnZcVYCKnfOr+RRH4T25zlyQoQHygVjMPp
         FQEQ==
X-Gm-Message-State: APjAAAWMytVjuolq3gtlLD2dHo3EG+tZC+glGSu2eIVTl+2JYYutVQuq
	G+wUschzOmsT6BD6g+DivymzDzPQNdw+kzRIkjrPV5Dhryl/tZz6DyPfc9YLrnMAzOVSpbuzlMQ
	519g8JkC1YUo8ZeVz4hOqvk+PMxLZpD8YEmrMkWlUrXsFhRLGJ84aYJet644qnKA=
X-Received: by 2002:a05:620a:15b5:: with SMTP id f21mr59624713qkk.89.1554265410429;
        Tue, 02 Apr 2019 21:23:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyfvbwUyS0/IOSpSOaAsr08piEMqkTD1olWF7ZsupKagphkhVXsqvZUo2jUXkM6s7cxIY5u
X-Received: by 2002:a05:620a:15b5:: with SMTP id f21mr59624679qkk.89.1554265409585;
        Tue, 02 Apr 2019 21:23:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554265409; cv=none;
        d=google.com; s=arc-20160816;
        b=xDG5k3ddvOwCW3WoaqjXaPG6T2Ybn+fbhkWAg8sQeRfdnbnyFPsZZZQ+Zlgely+DeS
         Q0hFWuVi+OCaHi/xfOqVhpRs3hbSZeloYSIr6qDDX7DGm+BpDvTQs33FNaHER19M+YZl
         BraNQunTQI1KkpyeMO+txkQFZbgDDWOccmDYXmZ2l0oKusbcivap+62AMCBCA+sA76OH
         +LGW0ROc6+BvjHJYkuNuOYfHxIJov2NBxuFBJeRVosp+psTimWadcMAHfeUNF34EQFhv
         FZeC0B50B7RFdJZ/wCfsFfv4kiJ9btR21zOhz4aVMwKfrEsJvOquyAhuWmtyalemQSQT
         qvKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=eB8W4ZifzOOx7n477C9lsHSgteznueDWRYbTVC4RGG4=;
        b=ueETmMaPJkY9ld9mEru/iU+xXdjPYYaGI1Ra1sOjG/e7t50cl6Ds6c0H/fOIYTqrSI
         0RNvLccpQFsrahGrrVbG/uL/cFmckHcUlyJM5AaxwPwCib50YW2or6sxUDZmGLIlkPuC
         WW78mJLFVDHsUdA+FMvQVPxZk4rFOTC1AipCu1dB3zNQzN2eFD2AWtnJJ+g6SUxJnHXl
         kAyfn17uGoKrM/Ck1X9venpiwxSBb5mLlsTumONkDGHi74vxrA6WD77buOX+4r2wUAZC
         cRznCOsFB3Jb/E4jEx7lUM8yFnZ+tS39oslDzhafjx2abR9PizrRTHgDVfD1vKubEpmG
         KYOg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=8g49H2KY;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.28 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out4-smtp.messagingengine.com (out4-smtp.messagingengine.com. [66.111.4.28])
        by mx.google.com with ESMTPS id u16si2645531qka.158.2019.04.02.21.23.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 21:23:29 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.28 as permitted sender) client-ip=66.111.4.28;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=8g49H2KY;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.28 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 4DE0121F26;
	Wed,  3 Apr 2019 00:23:29 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Wed, 03 Apr 2019 00:23:29 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=eB8W4ZifzOOx7n477C9lsHSgteznueDWRYbTVC4RGG4=; b=8g49H2KY
	JPyh5+opdBo9WW/hQaD63ziek5gLUqZ1SJAEGX/UPnwhMGr6q5qStSpPv8+QQxjR
	POc2MSuSFcOpQ9JZVhJXiQ+CsQsAJYapK45RsWHMctm3CZYuKSE6kMSi70ZPCWOX
	sDJ6uFRFKyVqXJFxXTeB78uOR1Uoq647tk4/PcINYiihTDwM4BZa9nbT5K8/3Glz
	PMRpIDbhDh91Nf5jKli946Lb0KAegvU1nuuPBHNX6VPf5srmtyz6QdzcdHCEzha6
	gEZZuskbhtHXFyoOlPvr6z/b3XwxrmRNq2QxqohPy8bPTBFDQFZw1MDSApW4a04l
	vCd/yIyM8PLOQw==
X-ME-Sender: <xms:QDWkXCxRIGyAQgFEXDw9jYYrl90i4NZYxrtv4fpvV7MOWWQT_qA7hQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtddugdektdculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhgggfestdekredtredttden
    ucfhrhhomhepfdfvohgsihhnucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrh
    hnvghlrdhorhhgqeenucfkphepuddvgedrudeiledrvdejrddvtdeknecurfgrrhgrmhep
    mhgrihhlfhhrohhmpehtohgsihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghruf
    hiiigvpeeh
X-ME-Proxy: <xmx:QDWkXFddG9JMs6HNDwUwAFyy3piaIS6zSSMva7UZW5-8_Hq4PlQi9Q>
    <xmx:QDWkXIveFTJbBvnFQwQgXrkwdL57vf6Xf-zkFXtnLYdD4PACdkLdUA>
    <xmx:QDWkXBMN58V4nxQrZC5mjohKJZSOIlFePO_fBx-vPehtH9stOsd-iw>
    <xmx:QTWkXFfKqIgCqODCa2b7XY5etePIbRSWtnjSo9HhJcTdlttAZjLN9A>
Received: from eros.localdomain (124-169-27-208.dyn.iinet.net.au [124.169.27.208])
	by mail.messagingengine.com (Postfix) with ESMTPA id 5D5D5100E5;
	Wed,  3 Apr 2019 00:23:22 -0400 (EDT)
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
Subject: [RFC PATCH v2 06/14] tools/vm/slabinfo: Add defrag_used_ratio output
Date: Wed,  3 Apr 2019 15:21:19 +1100
Message-Id: <20190403042127.18755-7-tobin@kernel.org>
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

Add output for the newly added defrag_used_ratio sysfs knob.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 tools/vm/slabinfo.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/tools/vm/slabinfo.c b/tools/vm/slabinfo.c
index d2c22f9ee2d8..ef4ff93df4cc 100644
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

