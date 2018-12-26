Return-Path: <SRS0=eTfr=PD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43A23C43387
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D6A6218AD
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D6A6218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 65B738E000E; Wed, 26 Dec 2018 08:37:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1ACA78E0003; Wed, 26 Dec 2018 08:37:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 868058E000E; Wed, 26 Dec 2018 08:37:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 923418E000C
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id t72so17766609pfi.21
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:subject
         :references:mime-version:content-disposition;
        bh=l9DDjMRdHR8SlduXYgg9WlaFUBCS2oE/F8RL01O5gwY=;
        b=nL6KfYz4u8+le7ltaCixYtKA9G9G+pLg45VppmNj2qw3c0j0BR0SwIpzA6VKhKhAm+
         Bh8pVGz9GXt5TuZqOEWXSxumDET+PPAb5paSeGPONSp6u6kbt4vkFEo2GVOpxuo1reM3
         xuLas2GASVwYi+VxWEWx6RtQ2h4k5otk3mytP+KIXMLsQ/E2TYPIooe5pQTRZQo2Tpi3
         vRPkXqcsC4puwizaOaTxFTLLgvnR78wlNSpE23BJqmVFjKvlPIpRPorQDQlmatWLf7sW
         u5yd9lmuXd3WTVLRIbXJg4jY5gtPcTRgTM3IpFGLhIl2bE6aC4bVmsD9uvqps2CNbKOJ
         rSGA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukdEqbi0u3nQUM9ECzlfStqROK16avdZm+DC4eQ2FfrGqaqCJUQF
	K4pqa/2INSkruRD+2ABYBRfVGnY67ejr7sNk0HhhXjOMeTqgfMqc/HpDMWOrXXT78BpJP+joqUE
	5HrecAsBnUqfFlPHvYNWPvHpVojqen+uIBSfpU+yvjEdQCKgXrUcI/m4ZNGPUXTff4w==
X-Received: by 2002:a62:1c7:: with SMTP id 190mr20266401pfb.46.1545831427294;
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
X-Google-Smtp-Source: AFSGD/WJpyXyujlfFV46idNOaLGAzRP7FHJSRjgJEwbTNNDwRgxvl59ot1XZXHSxKBM7axfQPktr
X-Received: by 2002:a62:1c7:: with SMTP id 190mr20266374pfb.46.1545831426792;
        Wed, 26 Dec 2018 05:37:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545831426; cv=none;
        d=google.com; s=arc-20160816;
        b=iyOil8IQ3S0F/rCWO9exippBH3MngzA0x4xMaqWQxxu9Bd+1yugdB4rzp4Vs4f0oQn
         3lNKoHy/Y6aM1t6ce+xV4GsmuVs4RZSa7e06G9mJNrENkEOy7uAs2OcJSgJrNhdeSLQY
         ST4wS/VunoiIUml1KBX3ZrX1Y4RZBPUNNSYCGGXYv30koyi4JdO09Mt/tmtD6wz+y0aL
         Fe5QdvwtZ+/gMq10UcBQ19n0DM1odJehc8tXXmKxT9PIouliqIB+su0edPiAw0YdE5fE
         E2AvuCBxRtOeCVz3IIPBRisqBrVqIT26bU8oOCrx+wvYY59qyWBOdWlY5okykYNnHYSL
         ylcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-disposition:mime-version:references:subject:cc:cc:cc:cc:cc
         :cc:cc:cc:cc:cc:cc:cc:to:from:date:user-agent:message-id;
        bh=l9DDjMRdHR8SlduXYgg9WlaFUBCS2oE/F8RL01O5gwY=;
        b=J0qjEXwLn3YhB5wlBRhk5TnnDcPqq1gQmG/rfM8OxXYO3gZK8VWEfXDOsgolHdHh6Z
         qCiqCyz//hm5SMRD+f94QGvvsJy8TBNjp/ebvEkK0jqvNniGDCPW2RrK5ovOPTORaNkv
         pZIPTSW0L7IcPAde2GV5oSegSySm1rQ0Bqvp7Xp4CHZvJSGhzmJilmMgWTfgcvb3buLE
         vuMjb3J5hHgAXqi01MnNr6zSZTRedZKhWebJGGuVlQ7zgglHq02ZFCQcgUuuVqo7MBIZ
         Scf1dBJJykv8rym7OFTdl+CoCMEyeGtwoyuYjV/T3IDnvHjFKSlAMq641HmEiKULwkU9
         qrNA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id p11si31508288plk.191.2018.12.26.05.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:06 -0800 (PST)
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
   d="scan'208";a="113358933"
Received: from wangdan1-mobl1.ccr.corp.intel.com (HELO wfg-t570.sh.intel.com) ([10.254.210.154])
  by orsmga003.jf.intel.com with ESMTP; 26 Dec 2018 05:37:02 -0800
Received: from wfg by wfg-t570.sh.intel.com with local (Exim 4.89)
	(envelope-from <fengguang.wu@intel.com>)
	id 1gc9Mr-0005OY-D7; Wed, 26 Dec 2018 21:37:01 +0800
Message-Id: <20181226133351.579378360@intel.com>
User-Agent: quilt/0.65
Date: Wed, 26 Dec 2018 21:14:55 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
cc: Linux Memory Management List <linux-mm@kvack.org>,
 Fengguang Wu <fengguang.wu@intel.com>
cc: kvm@vger.kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>
cc: Fan Du <fan.du@intel.com>
cc: Yao Yuan <yuan.yao@intel.com>
cc: Peng Dong <dongx.peng@intel.com>
cc: Huang Ying <ying.huang@intel.com>
CC: Liu Jingqi <jingqi.liu@intel.com>
cc: Dong Eddie <eddie.dong@intel.com>
cc: Dave Hansen <dave.hansen@intel.com>
cc: Zhang Yi <yi.z.zhang@linux.intel.com>
cc: Dan Williams <dan.j.williams@intel.com>
Subject: [RFC][PATCH v2 09/21] mm: avoid duplicate peer target node
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline; filename=0020-page_alloc-avoid-duplicate-peer-target-node.patch
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181226131455.VI0asQHzUvk6J-NUVMZETk3SZRcavk0DKH8_tRurpKs@z>

To ensure 1:1 peer node mapping on broken BIOS

	node distances:
	node   0   1   2   3
	  0:  10  21  20  20
	  1:  21  10  20  20
	  2:  20  20  10  20
	  3:  20  20  20  10

or with numa=fake=4U

	node distances:
	node   0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15
	  0:  10  10  10  10  21  21  21  21  17  17  17  17  28  28  28  28
	  1:  10  10  10  10  21  21  21  21  17  17  17  17  28  28  28  28
	  2:  10  10  10  10  21  21  21  21  17  17  17  17  28  28  28  28
	  3:  10  10  10  10  21  21  21  21  17  17  17  17  28  28  28  28
	  4:  21  21  21  21  10  10  10  10  28  28  28  28  17  17  17  17
	  5:  21  21  21  21  10  10  10  10  28  28  28  28  17  17  17  17
	  6:  21  21  21  21  10  10  10  10  28  28  28  28  17  17  17  17
	  7:  21  21  21  21  10  10  10  10  28  28  28  28  17  17  17  17
	  8:  17  17  17  17  28  28  28  28  10  10  10  10  28  28  28  28
	  9:  17  17  17  17  28  28  28  28  10  10  10  10  28  28  28  28
	 10:  17  17  17  17  28  28  28  28  10  10  10  10  28  28  28  28
	 11:  17  17  17  17  28  28  28  28  10  10  10  10  28  28  28  28
	 12:  28  28  28  28  17  17  17  17  28  28  28  28  10  10  10  10
	 13:  28  28  28  28  17  17  17  17  28  28  28  28  10  10  10  10
	 14:  28  28  28  28  17  17  17  17  28  28  28  28  10  10  10  10
	 15:  28  28  28  28  17  17  17  17  28  28  28  28  10  10  10  10

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 mm/page_alloc.c |    6 ++++++
 1 file changed, 6 insertions(+)

--- linux.orig/mm/page_alloc.c	2018-12-23 19:48:27.366110325 +0800
+++ linux/mm/page_alloc.c	2018-12-23 19:48:27.362110332 +0800
@@ -6941,16 +6941,22 @@ static int find_best_peer_node(int nid)
 	int n, val;
 	int min_val = INT_MAX;
 	int peer = NUMA_NO_NODE;
+	static nodemask_t target_nodes = NODE_MASK_NONE;
 
 	for_each_online_node(n) {
 		if (n == nid)
 			continue;
 		val = node_distance(nid, n);
+		if (val == LOCAL_DISTANCE)
+			continue;
+		if (node_isset(n, target_nodes))
+			continue;
 		if (val < min_val) {
 			min_val = val;
 			peer = n;
 		}
 	}
+	node_set(peer, target_nodes);
 	return peer;
 }
 


