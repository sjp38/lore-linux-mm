Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88C24C43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 02:27:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 52257206BF
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 02:27:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="68vQh+yi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52257206BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E1A966B0007; Thu, 25 Apr 2019 22:27:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DCA336B0008; Thu, 25 Apr 2019 22:27:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C927F6B000A; Thu, 25 Apr 2019 22:27:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id A7D996B0007
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 22:27:35 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id j49so1626317qtk.19
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 19:27:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=aATYrCxRlNMszFJ57g3u99UUP818320yu7bmbbR1Mt4=;
        b=Y+Ne6DMqsoXxzCiNhKSg0qqIFOggY36e7EnolXxW2b7usw4j3qci7waL3jHjjZlk4D
         TY9l3IYstGckEVpGHKsjhSYV3ATjS7Ohd5tjAraw76pLs9PPi09o5JDtQFlkUNtos8ub
         3IE0gLii5SFh4jNrZ92aFpM0afeYpAvESF17PX+fji7cbV2gGWHR6o3NzLQw8bRaM3Di
         z8PY0dhrLY5Qx4/FADUSCtQc9DVUIC/WBd5Domc3SuDikF8cwx90ZEDCtGDxaP/EskbA
         kulQLhy6nXy9vQ7I9gmnei57yAgi75TQQwDZAS5F/su1xCroDmqxZ5DHnQVSUfzew4lf
         ifOA==
X-Gm-Message-State: APjAAAXuz+zUR/bs45hDsV2pfzjLozcOc5z5sS4H6JQIwal9BVYF9DkE
	zB6PUmHthtmewQF+7uQdEEilDCyI81Gab9eC3BZVB3HfRRdKqqQ+f8yEcIPz437EHROWwAs1aAr
	M2nV1AJhYup0dYYl3eB46lOf+IZWUuuDKHTWq2P6CUxt7/0PWQVEI0Da4RuwGEFg=
X-Received: by 2002:a37:8fc3:: with SMTP id r186mr33957507qkd.102.1556245655455;
        Thu, 25 Apr 2019 19:27:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzOaftDGbrT3tTx/jYEMHsG+KYRUTHmTwr/08IGa5MLwDvaycehR8aKiVLVgzMwS/N3Nbol
X-Received: by 2002:a37:8fc3:: with SMTP id r186mr33957458qkd.102.1556245654378;
        Thu, 25 Apr 2019 19:27:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556245654; cv=none;
        d=google.com; s=arc-20160816;
        b=fIdjIE+kAJLx2Yg6zDcGoU9CrZZvVr46Dc6CUuTkbGfBVG0e3DY0dbDCJC+CgiOY5k
         bQOccHXqiAZvu+V9tJgQKjgZHxJVQ/RBCuJ5N3I3f6vTpc4t/rcgun0i3avjHp3tOVLK
         8tPts7pF5DIq//UntDLSDKRPkCL6HJ+hK+y7W8lITAsC7gHx5bbZ+X2W3lTDD+7HdEJC
         cMLeg12xDoliA3IwG9Dxe/ZgD+I0k6VQ+yc6FNRJZUlxkvlBuj1TuRBRxcgrH2JZDQCb
         NHRdwneVlClxXE68OpD8H4QuJww6nSwAg+dYIaDYaT3hTA5Uf9SYbsgv5rCHzvFk6/+F
         8deQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=aATYrCxRlNMszFJ57g3u99UUP818320yu7bmbbR1Mt4=;
        b=Bxj2xSrhxKmKo9P2N4oqg2UM8owz1zsvRDnc02erqq5YHRmNm2IF7xd7x1D1lo34rj
         vU3YZqtx4PkaXZQvg5Sudk2ybJ+bjynHqljMvvIC806mddPyftPaBaQ3mo+DPJ4QnrdW
         uNwJkfdKPvEG/RYCyg39+/9Q9AFelsyQV+Ek1g12lFWZnF9BGaMbtJIQKJnyQ1rTrWeK
         nY1neJrnJd/VXLAb4S1lzsEsQYgGJ0D3571MkxnTlsY/HnJW+nBDAnFqQjY0nX5rKx5R
         v5IsGFN/rrbHv5zxfBM1BA42f8IjXmsygj4FD14KnkEy5KWvsvPgPwK+fT15UB4qpXG7
         7psw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=68vQh+yi;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new1-smtp.messagingengine.com (new1-smtp.messagingengine.com. [66.111.4.221])
        by mx.google.com with ESMTPS id g15si5333454qki.133.2019.04.25.19.27.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 19:27:34 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) client-ip=66.111.4.221;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=68vQh+yi;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 0D24710FA2;
	Thu, 25 Apr 2019 22:27:34 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Thu, 25 Apr 2019 22:27:34 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=aATYrCxRlNMszFJ57g3u99UUP818320yu7bmbbR1Mt4=; b=68vQh+yi
	M75/HLJuUgg97N18rXVBRlHToOk742865TAoiRxWPyqFG95mjm3E1uVuLFsiRLAb
	ABG5WUNf5jgQSzekVQs/9nDOXKVGCVOnUArwPFrh0awYu8ci3FP634CLHaJBhw3l
	6RmMNRAFD9kyEY3rm9PVwfvLQTlWTwuORh2yMtwL1Q5YZiS4ccHYbWv0/y7+NDJb
	Y/KS23rBvGHqQycUP5jhobVbGU6iAAx2Ushd3IpWLsw9sTtG5PUML+VkO+Yl9laK
	puyiw1HZF2rnA8OuIreveUWdo0/p+TbSqIu2mDBUaMk4JpTcfikINciam/RbI0qh
	9zw7LoJdGLb1Kg==
X-ME-Sender: <xms:lWzCXP3FES-trKp4szFTvuaokkn52SETSz_Q8gbmtDQVf0qGUTyOMA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrheehgdehlecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudeiledrudehledrvddutdenucfrrghrrghmpehmrghilhhfrhhomhepthho
    sghinheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgepud
X-ME-Proxy: <xmx:lWzCXNCf2YH8IHSN6ksZrUJToGCjR3kXKcL6p0CYYlNVrWg78nm4jw>
    <xmx:lWzCXL9eqLawLdyCIWY0OiBzlAaf02pfCvb344z-JQelTN4UE26-mQ>
    <xmx:lWzCXIVhx2ViuUlC0edbesis_c-GN-hJFrnf12QDburBMiDOhm7sIg>
    <xmx:lmzCXGdnNvl_5jh7r6EWXD7QjvDF4MR2A8dgyQbLvDuD2XFKy4auTQ>
Received: from eros.localdomain (124-169-159-210.dyn.iinet.net.au [124.169.159.210])
	by mail.messagingengine.com (Postfix) with ESMTPA id 70F8F103C8;
	Thu, 25 Apr 2019 22:27:28 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Pekka Enberg <penberg@iki.fi>,
	Vlastimil Babka <vbabka@suse.cz>,
	Christoph Lameter <cl@linux.com>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Tejun Heo <tj@kernel.org>,
	Qian Cai <cai@lca.pw>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Michal Hocko <mhocko@kernel.org>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	linux-mm@kvack.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 2/4] tools/vm/slabinfo: Add partial slab listing to -X
Date: Fri, 26 Apr 2019 12:26:20 +1000
Message-Id: <20190426022622.4089-3-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190426022622.4089-1-tobin@kernel.org>
References: <20190426022622.4089-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We would like to see how fragmented the SLUB allocator is, one window
into fragmentation is the total number of partial slabs.

Currently `slabinfo -X` shows slabs sorted by loss and by size.  We can
use this option to also show slabs sorted by number of partial slabs.

Option '-X' can be used in conjunction with '-N' to control the number
of slabs shown e.g. list of top 5 slabs:

	slabinfo -X -N5

Add list of slabs ordered by number of partial slabs to output of
`slabinfo -X`.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 tools/vm/slabinfo.c | 41 ++++++++++++++++++++++++++++-------------
 1 file changed, 28 insertions(+), 13 deletions(-)

diff --git a/tools/vm/slabinfo.c b/tools/vm/slabinfo.c
index e9b5437b2f28..3f3a2db65794 100644
--- a/tools/vm/slabinfo.c
+++ b/tools/vm/slabinfo.c
@@ -79,6 +79,7 @@ int sort_size;
 int sort_active;
 int set_debug;
 int show_ops;
+int sort_partial;
 int show_activity;
 int output_lines = -1;
 int sort_loss;
@@ -1047,6 +1048,8 @@ static void sort_slabs(void)
 				result = slab_activity(s1) < slab_activity(s2);
 			else if (sort_loss)
 				result = slab_waste(s1) < slab_waste(s2);
+			else if (sort_partial)
+				result = s1->partial < s2->partial;
 			else
 				result = strcasecmp(s1->name, s2->name);
 
@@ -1307,27 +1310,39 @@ static void output_slabs(void)
 	}
 }
 
+static void _xtotals(char *heading, char *underline,
+		     int loss, int size, int partial)
+{
+	printf("%s%s", heading, underline);
+	line = 0;
+	sort_loss = loss;
+	sort_size = size;
+	sort_partial = partial;
+	sort_slabs();
+	output_slabs();
+}
+
 static void xtotals(void)
 {
+	char *heading, *underline;
+
 	totals();
 
 	link_slabs();
 	rename_slabs();
 
-	printf("\nSlabs sorted by size\n");
-	printf("--------------------\n");
-	sort_loss = 0;
-	sort_size = 1;
-	sort_slabs();
-	output_slabs();
+	heading = "\nSlabs sorted by size\n";
+	underline = "--------------------\n";
+	_xtotals(heading, underline, 0, 1, 0);
+
+	heading = "\nSlabs sorted by loss\n";
+	underline = "--------------------\n";
+	_xtotals(heading, underline, 1, 0, 0);
+
+	heading = "\nSlabs sorted by number of partial slabs\n";
+	underline = "---------------------------------------\n";
+	_xtotals(heading, underline, 0, 0, 1);
 
-	printf("\nSlabs sorted by loss\n");
-	printf("--------------------\n");
-	line = 0;
-	sort_loss = 1;
-	sort_size = 0;
-	sort_slabs();
-	output_slabs();
 	printf("\n");
 }
 
-- 
2.21.0

