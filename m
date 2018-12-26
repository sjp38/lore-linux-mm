Return-Path: <SRS0=eTfr=PD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D317C43387
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 477DF218AD
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 477DF218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C3AD8E0005; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2460E8E0003; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C1188E0001; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id A161B8E0002
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:06 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id j8so14043738plb.1
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:subject
         :references:mime-version:content-disposition;
        bh=A32p6PRUkSePjgXOn8auRhPpIw8cvQ9iIIA7hvL+s2I=;
        b=UQkqWebzAYSMQ1ZTeCgPvuz2Ba9gf8PE/GuMKrI+ZnS6YrqYfZ2+5rtaP3vdcGmGew
         YyY3E7/SjT7I4FNJt1k91OoAwYa55HTu532n8FvkmZK+txH16EU5vXCpXKvH6rRAM/Oa
         VKJSROautDjKjqgTFwEqwBBRfiFX7wyX9rcYK7S4Nztd8FmGslIZ3olrav2Hxq9XFcAI
         JxkVE6eX3df2Z9d6mheGFN7NSyxC/iP8nl2vDcs8GiappwGKCKYLpX032Gt2ctJ7hr9G
         CF2fG01wAkw4ktOlSQwDXGWAlxcJYAR37ZoOvYZGoOig14QoGueUhTpC5p/ziVx+mEBC
         yxvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AA+aEWYASnNFOyNMGnPJHwfxJAfTJvotXWJizDoHclGlZgvE6y90HhW2
	BhFQOFYl9mIHu0+GV9UlUyFZNWoqvSpnKZ2wBwg9roQt1FeYfaB4oHby0PnVWAY59McqxAZzXqZ
	J+yrthKo6iNl2cj9UCtdUMahwilQ9rdyvk7VoQB48TK8yviz5uANiUztoXDvEGOeBqw==
X-Received: by 2002:a62:b80a:: with SMTP id p10mr20146968pfe.32.1545831426336;
        Wed, 26 Dec 2018 05:37:06 -0800 (PST)
X-Google-Smtp-Source: AFSGD/UonuPM4hcWlLd+GOQcLdvPjo/SZKDdabzSZhSR/zJPSQ871HpzV92Q5XQ9bvlykcpq7mb9
X-Received: by 2002:a62:b80a:: with SMTP id p10mr20146936pfe.32.1545831425823;
        Wed, 26 Dec 2018 05:37:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545831425; cv=none;
        d=google.com; s=arc-20160816;
        b=ZWVfEdJ+1Fjyj0c91TMDDtywGvR0YCDAI9TfiqidFMoved5B0a0VhSx+y28luTRFfj
         79J8PlApQpPJ4OY/nM2cxV81TjQJTearfYnczLfU0+G+lDgzXQcO3QdP6/RSNbO5Iv27
         yLlSX6NNd73qGWQX6FcryHAuSNhIbpz5MslhI2xEYZZYVWVZYhbJa9sDon9wxnzCdOn+
         W6EY9N4Yet4bXR60jqI116CneM/Bb3+gg5aK5mSvYk29oydHP3u24udDLaAbAuEUCuoT
         QRwV6zhcdx6WnNPuKuMOLiHWwnXSHbHfXknSW2TA4biVpH7arHGx7gjW8VqfZn3JEb/U
         tBkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-disposition:mime-version:references:subject:cc:cc:cc:cc:cc
         :cc:cc:cc:cc:cc:cc:cc:to:from:date:user-agent:message-id;
        bh=A32p6PRUkSePjgXOn8auRhPpIw8cvQ9iIIA7hvL+s2I=;
        b=zvRZwaYSUvMYJFgsro4NPJDudfXcg6TF6KoQSYYFhfLQ0jGcvYvfu/4p5E3qiM2/20
         0lUMTeeFWMHxhj7Se90zIeoYKX4H5EI6C+dtOHVtOnn2SX7c2Bi0h8ANIWSpCXO0HcNq
         Q93EOCa2KhgvizHVPB9v2r4KotFsioaPehhEpaXUsgRyEPdnrK5OhGvQ9uIVDylQUrsF
         DjL88tToUvAWC3mNRrTmG+JxBQCM7jfBZQEnqFebguAkvcJBh5Y3ax4uken/vnzFF1yd
         i3CvLsdW1GQZiAbNU7Rv5s1K/bedbpFzP/0H5HyBZcDfaAl2ejYbCac+hMACQcg4oMCT
         yqCg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r12si1487152plo.59.2018.12.26.05.37.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:05 -0800 (PST)
Received-SPF: pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Dec 2018 05:37:05 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,400,1539673200"; 
   d="scan'208";a="113358926"
Received: from wangdan1-mobl1.ccr.corp.intel.com (HELO wfg-t570.sh.intel.com) ([10.254.210.154])
  by orsmga003.jf.intel.com with ESMTP; 26 Dec 2018 05:37:02 -0800
Received: from wfg by wfg-t570.sh.intel.com with local (Exim 4.89)
	(envelope-from <fengguang.wu@intel.com>)
	id 1gc9Mr-0005O3-8C; Wed, 26 Dec 2018 21:37:01 +0800
Message-Id: <20181226133351.229014333@intel.com>
User-Agent: quilt/0.65
Date: Wed, 26 Dec 2018 21:14:49 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
cc: Linux Memory Management List <linux-mm@kvack.org>,
 Fan Du <fan.du@intel.com>
cc: kvm@vger.kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>
cc: Yao Yuan <yuan.yao@intel.com>
cc: Peng Dong <dongx.peng@intel.com>
cc: Huang Ying <ying.huang@intel.com>
CC: Liu Jingqi <jingqi.liu@intel.com>
cc: Dong Eddie <eddie.dong@intel.com>
cc: Dave Hansen <dave.hansen@intel.com>
cc: Zhang Yi <yi.z.zhang@linux.intel.com>
cc: Dan Williams <dan.j.williams@intel.com>
cc: Fengguang Wu <fengguang.wu@intel.com>
Subject: [RFC][PATCH v2 03/21] x86/numa_emulation: fix fake NUMA in uniform case
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline; filename=fix-fake-numa.patch
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181226131449.xG9n4DGjfPGPxQts2kQ5magG2OogdN2fbwIFCKHlCmE@z>

From: Fan Du <fan.du@intel.com>

The index of numa_meminfo is expected to the same as of numa_meminfo.blk[].
and numa_remove_memblk_from break the expectation.

2S system does not break, because

before numa_remove_memblk_from
index  nid
0	0
1	1

after numa_remove_memblk_from

index  nid
0	1
1	1

If you try to configure uniform fake node in 4S system.
index  nid
0	0
1	1
2       2
3	3

node 3 will be removed by numa_remove_memblk_from when iterate index 2.
so we only create fake node for 3 physcial node, and a portion of memroy
wasted as much as it hit lost pages checking in numa_meminfo_cover_memory.

Signed-off-by: Fan Du <fan.du@intel.com>

---
 arch/x86/mm/numa_emulation.c |   16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

--- linux.orig/arch/x86/mm/numa_emulation.c	2018-12-23 19:20:51.570664269 +0800
+++ linux/arch/x86/mm/numa_emulation.c	2018-12-23 19:20:51.566664364 +0800
@@ -381,7 +381,21 @@ void __init numa_emulation(struct numa_m
 		goto no_emu;
 
 	memset(&ei, 0, sizeof(ei));
-	pi = *numa_meminfo;
+
+	{
+		/* Make sure the index is identical with nid */
+		struct numa_meminfo *mi = numa_meminfo;
+		int nid;
+
+		for (i = 0; i < mi->nr_blks; i++) {
+			nid = mi->blk[i].nid;
+			pi.blk[nid].nid = nid;
+			pi.blk[nid].start = mi->blk[i].start;
+			pi.blk[nid].end = mi->blk[i].end;
+		}
+		pi.nr_blks = mi->nr_blks;
+
+	}
 
 	for (i = 0; i < MAX_NUMNODES; i++)
 		emu_nid_to_phys[i] = NUMA_NO_NODE;


