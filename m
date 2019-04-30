Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 293B5C004C9
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 03:09:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D12F121670
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 03:09:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="IIiJcM6A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D12F121670
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 30E8F6B0272; Mon, 29 Apr 2019 23:09:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2EF516B0274; Mon, 29 Apr 2019 23:09:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1ACEB6B0275; Mon, 29 Apr 2019 23:09:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id ED8336B0272
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 23:09:29 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id f48so12106058qtk.17
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 20:09:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=eB8W4ZifzOOx7n477C9lsHSgteznueDWRYbTVC4RGG4=;
        b=oUffA13Wt4WX5wrfeeeLMbFXKS+cmRzVopuUttL5DTZ9xRQmBDh0oCZE3glYfphp30
         huvyYDjHsvodyTm2aRk95vFzgddNHfvBHlJ0k4HEeNPeNSD8VqBWntvhsrBWSe2KG96C
         BwQ9bW6BvutrqA+K8z76OyPJPMJiZYEiohzKHlZtFZ7EOFK+o3ysoGGYZWt+DhfInRkA
         FkKBi6+iafPuDjc53KOF6vxhdFBegMLcv+Cu5W/fJgId7MywNST2py7ZWk0KM2ra2W59
         XAdJ7VKJShVDdKZ9TgqDs/+woQLouVr8wuU8Gmhw6/v9QCMin7zlZh0+rd8j3crb2kH4
         t43Q==
X-Gm-Message-State: APjAAAV5dzqj3aUf7y7ZSq9TzwDlswvlgdkxNAC5S4p4rDpplceB3qQV
	v/P2dT0zENIZh5Atnf2TrocX7QQRpy5VMAhhaiCl8ShX1yDqPsUxXFmJtOGVzLreQ+7SaagrcB1
	iqLQ7zuEUNdD8meko3iRq5VSuln0PuTC7SSQtgokFNCvI3adoJx5HLdF5Yf/HfEA=
X-Received: by 2002:ac8:35c6:: with SMTP id l6mr41562588qtb.326.1556593769762;
        Mon, 29 Apr 2019 20:09:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJ9ztFy5eUnaN8vzcesdRbH1fr/Hz3Uw0gssvajfGrSGwcmJzv+lIS54Al7DCp6TfsRNug
X-Received: by 2002:ac8:35c6:: with SMTP id l6mr41562547qtb.326.1556593768826;
        Mon, 29 Apr 2019 20:09:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556593768; cv=none;
        d=google.com; s=arc-20160816;
        b=FOEocoi6wY3M3Try+qYF/hi49kLCEkj/6F/IYM/XdBCdcUoO8qb58MGnSZU1pGryFF
         ZH5SOa66GafbaEgJHFbmXSL8NNORBAwKOmkieqnhU7I1fQXPwwVwtNW1Omk1PAt5M/07
         +Q5y3LlEbHKong5D+s4udTiVXLzcC0S2l3vCC7uV/p8RHPFAPRzxwgbgyIQyoXS+FN4o
         JjpjxdcoHOsl5wxbFX5TVWtViXbwbD8FkL6DwWJR7q3Oa1DQzgblO0OdeALVISZIMVRj
         AhE4TgslmuPhyYZaCEKBAQwMpPBL1KgIg4Z2cpcPQM5mlReOWn93z15lNiltoez74bC3
         WBdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=eB8W4ZifzOOx7n477C9lsHSgteznueDWRYbTVC4RGG4=;
        b=f22kMdSGwE4sEkB6F12O8+JM6Zy71FTvXMtWKZjKAnjIaFTnzL6R365XPx5N0uRXit
         sFR4QU4v0RubOBi1rvDcHi61+qiNp3e8dPQWgDRtfev/5m5qQvN7lFqoYX1R5AfbeLF3
         tYaqiKOwoPoCXm+R1vMX1HgjyFVcTJoL4QyreqLz+v2bQH4yvMe76KSTx9JtNzmDxoBN
         EwqLC90y9phnMuzUrUF5CxMtVnHrRt7bao3BjVrjVCflH+YGhA7QsRf00pgZWC0mRMib
         wyc+RVlwhTf6TCKGfsIlNco2ZiF81dbFrLQSt7hWy4rOwJysBKuYOj5XsZdy5cL/EWhi
         AMlQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=IIiJcM6A;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new1-smtp.messagingengine.com (new1-smtp.messagingengine.com. [66.111.4.221])
        by mx.google.com with ESMTPS id y66si1990782qke.252.2019.04.29.20.09.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 20:09:28 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) client-ip=66.111.4.221;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=IIiJcM6A;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 8A2C4C248;
	Mon, 29 Apr 2019 23:09:28 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Mon, 29 Apr 2019 23:09:28 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=eB8W4ZifzOOx7n477C9lsHSgteznueDWRYbTVC4RGG4=; b=IIiJcM6A
	Me6lXrEYm7aMvEu4IniFKE1Gy/ckecyeq+RQCjDcEluoWUY/TJPW6sh8UNZ+l3k2
	nRzSrCQpCgS6c1MihLEx14Aqb0sDq3rzDhqQE2rBXsIqlEEX0OEFWdDk4O1+HlD1
	Q5eciHxYnNKKJ+U/rB8aESqJSe+2vM6ttloEQdkdePxND+yaq286Gm0v++FZIVct
	lQkZNj3lpvoaWE4wBqSdc+heek7Rq7NxK36kScV3p6qxBzNBhde+US49CsQEQ+hI
	uKQkDPxz3P9ne2lS7AJxzKPqhaJqEab1e9Ou5FL6KhmkLKUWNQutfPyyUyplf60x
	zmjKkhoXnj0BSg==
X-ME-Sender: <xms:aLzHXJlqi0FfDPFoUUxuSGbtB6tUOB7-Pc5MdJb3HKWltGLLi6LcEw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrieefgdeikecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvuddrgeegrddvfedtrddukeeknecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpeeh
X-ME-Proxy: <xmx:aLzHXHkleEUiYxjLHlffLtcOI3RALL_1UOh1n07H3SCaEKrqUVMO_g>
    <xmx:aLzHXMhFu5J43jwC4dfrRejLeeDTEt2UqLRvWaD2Quf_Y7myGQ8Teg>
    <xmx:aLzHXBEXzXuR4cJVeaJcJEbjFbRj0AAlNcsleZLkX8KXNAxmLp3l7w>
    <xmx:aLzHXDDVCLRIopLk7sNclnepO7Lftl9WZEo6476KKXnr3fDqS_tAqg>
Received: from eros.localdomain (ppp121-44-230-188.bras2.syd2.internode.on.net [121.44.230.188])
	by mail.messagingengine.com (Postfix) with ESMTPA id C4DAA103CA;
	Mon, 29 Apr 2019 23:09:20 -0400 (EDT)
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
	Jonathan Corbet <corbet@lwn.net>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v4 06/15] tools/vm/slabinfo: Add defrag_used_ratio output
Date: Tue, 30 Apr 2019 13:07:37 +1000
Message-Id: <20190430030746.26102-7-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190430030746.26102-1-tobin@kernel.org>
References: <20190430030746.26102-1-tobin@kernel.org>
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

