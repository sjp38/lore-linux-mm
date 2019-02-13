Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FB4FC282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 09:43:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 19501222BA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 09:43:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19501222BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 815268E0002; Wed, 13 Feb 2019 04:43:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C40E8E0001; Wed, 13 Feb 2019 04:43:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B3858E0002; Wed, 13 Feb 2019 04:43:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1373A8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 04:43:26 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id w12so668846wru.20
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 01:43:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Kk/GG3OgbzX8YIM46cZBNoZxrXJT1E5EGBKwMDd7vXI=;
        b=Ko6PyEAObJAL5srAzO40udEnVxGbg4qThUdI0TjR1aaQkrsMgAbei4/5IU4nb00kFC
         EsVUuNMYXkwKPF+h/Gaaj31acqOovzhYjw4X31wQS/vpuHFD7N6abkkUCN3LAWZ2AZYt
         lzjqhQWzD+GEI+momMP9jfPWiHnNobVn96hegLQ3/85dui3xh4fJz0BJVLlOiMaV+mP2
         cA1yCnmRDerTO0OZ/2mURZO3nZZe6XHMddPZEannjq1KDBpARtcqYkd5KTMxOLbzCRAX
         rfxSUUgRkvdTBWnCXTAh83dcir3aPBDPREGQcqMFUOf+9QfjMwl+A5amF9pxKDRDLg4l
         0tww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAubcZdtVAjCYsDOWDQavl8aaC5Hye9HC3nwMCNgiUw7FjQPwcl8n
	Q8BlgbXEJvbC9PETYYYn74YenSwUj3VeVCBh+X4M57uXopQTvOCsh/bnUIcYvX5khnTlFkYVNYn
	UBijbxQBmUlBgnFEq/oGemtPxFhtu26aqfHHLLiOANSt0sa7wFocHqjK4fiYCbSZjzgQ2VYI3uQ
	KDw8f87aEYycVGCov3j0i1QTBxVzqbCd08rM8VFLYjyraj8v+lNN47QvsCoWuVP3yrDNqb/15Tf
	3cmS95kxxtMNkHx5VtWU5ZBPwPpYhjyyWCIuloYVYD9nkzLhDlm9KP199v+nc+7G7pNnRV4NO1r
	5s/o/zpq5bj30OUW1nGbUvJPVw9su8/lnq78C5kgjIHw3NjeW6JiD0owSES4UaEKGubfdsccOw=
	=
X-Received: by 2002:adf:b7c1:: with SMTP id t1mr6030809wre.248.1550051005639;
        Wed, 13 Feb 2019 01:43:25 -0800 (PST)
X-Received: by 2002:adf:b7c1:: with SMTP id t1mr6030762wre.248.1550051004926;
        Wed, 13 Feb 2019 01:43:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550051004; cv=none;
        d=google.com; s=arc-20160816;
        b=C5U0tYadJLM5uu/ATEIp99cTMJfcfhQ1ef9LJKSOZYYwb1b/lC/wvpzl+yDYJl1RD4
         A3MDVmYu6cT+LT0bCGsxew6P/Fkv+qaJIwDmEXDIPDWG3ouxFpFfPDgj1PCGvOcu+goy
         U7sbR4vwkCx4oluVwcGnfjYiCcNDn6ipZSXeR4wrDkQJLWBqrHer2YgqzT+fWaF25Ewf
         st2MH3hdzZ3QX5kylC6f9fSKhmYhOrSKuc4iU6uStxCQvpMELtihWIrzAhwCnmRa2Mrh
         Vt7jYUAKFROrbgpO14z+AiulDfqW/+QdkoLHzncLkwsUz219q5yzTwfyaIEXeZzzItKN
         dgfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Kk/GG3OgbzX8YIM46cZBNoZxrXJT1E5EGBKwMDd7vXI=;
        b=hwyVCdDZV5mQ8R28fGlhKKcA2Tfbp2WQ+qvyEsWtn0nbKAUGO48DLFUTXZqNaKIPXY
         o2ZYSMaWym3wqe7dA99qQkbwB5AdU7IivaG76aWKDzaHQWVPD1cYT4tQu1BPGFgdNkp7
         BDryR6w8RfDOAolIKuLGvHJdyOLZCFJrNL2+RFL/QbH14LxmtP3WVL+YqvjvehTLHpgC
         2E2qxuBGZ3QrWCsMRUmtwkINIck7/Pmg6rnbsXLa143KYH+n8Roff0djx3MLwlnnlwO0
         8AvagEJpdSeXsYkP8ktuWUNjhSa3/WoeBcfrqaVD+XKhgneIsLrqCN9M8ueYJkixjAG5
         ro4w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l7sor296745wrr.32.2019.02.13.01.43.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 01:43:24 -0800 (PST)
Received-SPF: pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IZGZGyJI5vbywvzsWNw+C5pG4oYQrFxR54toXy/PK1qWoOPyoC6Bgzg4NOhsQ5CAtgQdn/loQ==
X-Received: by 2002:a5d:4b07:: with SMTP id v7mr6179697wrq.281.1550051004381;
        Wed, 13 Feb 2019 01:43:24 -0800 (PST)
Received: from tiehlicka.suse.cz (ip-37-188-151-205.eurotel.cz. [37.188.151.205])
        by smtp.gmail.com with ESMTPSA id x21sm6111396wmi.28.2019.02.13.01.43.22
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 01:43:23 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
To: <linux-mm@kvack.org>
Cc: Pingfan Liu <kernelfans@gmail.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	x86@kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Tony Luck <tony.luck@intel.com>,
	linuxppc-dev@lists.ozlabs.org,
	linux-ia64@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>,
	Michal Hocko <mhocko@suse.com>
Subject: [PATCH v3 2/2] mm: be more verbose about zonelist initialization
Date: Wed, 13 Feb 2019 10:43:15 +0100
Message-Id: <20190213094315.3504-1-mhocko@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190212095343.23315-3-mhocko@kernel.org>
References: <20190212095343.23315-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Michal Hocko <mhocko@suse.com>

We have seen several bugs where zonelists have not been initialized
properly and it is not really straightforward to track those bugs down.
One way to help a bit at least is to dump zonelists of each node when
they are (re)initialized.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Sorry for spamming. I have screwed up ammending the previous version.

 mm/page_alloc.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2e097f336126..52e54d16662a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5234,6 +5234,8 @@ static void build_zonelists(pg_data_t *pgdat)
 	int node, load, nr_nodes = 0;
 	nodemask_t used_mask;
 	int local_node, prev_node;
+	struct zone *zone;
+	struct zoneref *z;
 
 	/* NUMA-aware ordering of nodes */
 	local_node = pgdat->node_id;
@@ -5259,6 +5261,11 @@ static void build_zonelists(pg_data_t *pgdat)
 
 	build_zonelists_in_node_order(pgdat, node_order, nr_nodes);
 	build_thisnode_zonelists(pgdat);
+
+	pr_info("node[%d] zonelist: ", pgdat->node_id);
+	for_each_zone_zonelist(zone, z, &pgdat->node_zonelists[ZONELIST_FALLBACK], MAX_NR_ZONES-1)
+		pr_cont("%d:%s ", zone_to_nid(zone), zone->name);
+	pr_cont("\n");
 }
 
 #ifdef CONFIG_HAVE_MEMORYLESS_NODES
-- 
2.20.1

