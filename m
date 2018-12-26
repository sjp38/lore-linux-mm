Return-Path: <SRS0=eTfr=PD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC171C43612
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:38:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B024218AD
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:38:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B024218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED1528E0015; Wed, 26 Dec 2018 08:37:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D58D8E0008; Wed, 26 Dec 2018 08:37:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C601D8E0008; Wed, 26 Dec 2018 08:37:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6E8AE8E0008
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:08 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id a2so15212809pgt.11
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:subject
         :references:mime-version:content-disposition;
        bh=s9jTr6JOKBa1wmrz7jGYMpBIemoQeVl0/cJO8ct8GUo=;
        b=pjJKUUw/G48Hfh90huDvRV611iVUFYTxuxwYEqbTbfn2miCvDoYIzJK9fD31GNfkTc
         Lz5Q+p6P1lHYsdujUJ3DSj46Niy/TIZ86Gtwx9BU5Q4Oq8LUIooc4/UbCjtSArd+dwPF
         9lQfsUKWnmeQWA8xnM4XBFqJ8mVNh3wZnwYctFoMmykK0toffa253BrMU6YQ6PEBPszK
         YbHBFHxZEwaK6xkNs/U67qv++yQKb4hL8w+9RLnJfR1hK27hjMaAENqYGu8B+7dd3jnB
         cvsL36yApyw1s2tWOxt6S9QWpaC7K1TVMz5vfXjbeMl5ta/jgD4AUIQ48QBrgdZI45od
         RiAA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AA+aEWYOUiVYjB0tWqRvt/2mk4H4gB8maP2cmZSp9rPa+VPyDRoumo69
	WDzBsA5zXvs9eR9aDqwEt4NknV2BW6H66jHmvM1wJRmSQWkxnL1Aw0ZY1JuWbTm4kkLTP3hxpG5
	XmeNHxP3DfMP4TaI/+Gvil5PMJaiXaG+jo0C/8FrFtvGuHtHItmMTiC62i9LHT0YeBA==
X-Received: by 2002:a62:6204:: with SMTP id w4mr20407817pfb.5.1545831428157;
        Wed, 26 Dec 2018 05:37:08 -0800 (PST)
X-Google-Smtp-Source: AFSGD/UYUcyt9sVyAypMxy/kx8oPS9MGhnC85iACNlH+r2fm8WCCL49jRZDbzZLv0rHtjRg9Xtrn
X-Received: by 2002:a62:6204:: with SMTP id w4mr20407782pfb.5.1545831427462;
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545831427; cv=none;
        d=google.com; s=arc-20160816;
        b=xLYSPzh0ADUP9tJzg9Dn7IA9lGhgDNm3Tu86jOb5+1jOmI039dla8D/zchqd01KOdC
         1JRbQnHp+l+71wWDxTfML0anGm5gBvYa160eUFx5gCYiSfvNWD+WN+w9BzJDzebBruoR
         QTnks9PVCVi0iWamp04cJBFjtnoQB+qR2l7WIpr7IdsHYc+fyxuiJ38nD+bMdwLpv4c3
         XuNRZnAi2OG9EnObaEBKeZjq4VA3+mlP4/gDYVzpBudXDiMIn/VniqFZgPDT8wNdQVDe
         6/MSRyaUi5J7dkaHy7YO2to59/MjTTwPGKDzVUSYe6VgnfP4VFXEANiXD9tRGFEJBDWn
         sT5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-disposition:mime-version:references:subject:cc:cc:cc:cc:cc
         :cc:cc:cc:cc:cc:cc:cc:to:from:date:user-agent:message-id;
        bh=s9jTr6JOKBa1wmrz7jGYMpBIemoQeVl0/cJO8ct8GUo=;
        b=xYeYNBPmwklYjAMW/U/YA3YgTX7gSpDZq6r3GKMRyMoaFcuYJI3urCy5c0Wq2VNJVg
         agAQz/huHASplmM2XH1djT8rU10xfNcg7D3cJb4SBexEFlBjNdAR7zB9sdoojAKFPgtp
         hjeuQAjI24h+oPV50DMk/PwOjDqwQCotoQFHW78mcU38pzRSM3P9E4SMH+t07e5laXjQ
         W94yAthH5NAWPyM9Ew9+JV9iZm/mTqVxNzoNGN9NdicaJcwnoAD4399j6ssR+a79rYE3
         0WB5tb4arVaTlG9rGpJIL2One5bduNCE68nHcjieAoaZCnaGWXnScFV8XSI2qNiKOBSK
         sbww==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r12si1487152plo.59.2018.12.26.05.37.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
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
   d="scan'208";a="113358944"
Received: from wangdan1-mobl1.ccr.corp.intel.com (HELO wfg-t570.sh.intel.com) ([10.254.210.154])
  by orsmga003.jf.intel.com with ESMTP; 26 Dec 2018 05:37:02 -0800
Received: from wfg by wfg-t570.sh.intel.com with local (Exim 4.89)
	(envelope-from <fengguang.wu@intel.com>)
	id 1gc9Mr-0005PX-NY; Wed, 26 Dec 2018 21:37:01 +0800
Message-Id: <20181226133352.303666865@intel.com>
User-Agent: quilt/0.65
Date: Wed, 26 Dec 2018 21:15:07 +0800
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
Subject: [RFC][PATCH v2 21/21] mm/vmscan.c: shrink anon list if can migrate to PMEM
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline; filename=0013-vmscan-disable-0-swap-space-optimization.patch
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181226131507.8wiaOSPmQ8sdS6YXVD9nMwnzPozUMUd9HTO0jL0d9HA@z>

Fix OOM by making in-kernel DRAM=>PMEM migration reachable.

Here we assume these 2 possible demotion paths:
- DRAM migrate to PMEM
- PMEM to swap device

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 mm/vmscan.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

--- linux.orig/mm/vmscan.c	2018-12-23 20:38:44.310446223 +0800
+++ linux/mm/vmscan.c	2018-12-23 20:38:44.306446146 +0800
@@ -2259,7 +2259,7 @@ static bool inactive_list_is_low(struct
 	 * If we don't have swap space, anonymous page deactivation
 	 * is pointless.
 	 */
-	if (!file && !total_swap_pages)
+	if (!file && (is_node_pmem(pgdat->node_id) && !total_swap_pages))
 		return false;
 
 	inactive = lruvec_lru_size(lruvec, inactive_lru, sc->reclaim_idx);
@@ -2340,7 +2340,8 @@ static void get_scan_count(struct lruvec
 	enum lru_list lru;
 
 	/* If we have no swap space, do not bother scanning anon pages. */
-	if (!sc->may_swap || mem_cgroup_get_nr_swap_pages(memcg) <= 0) {
+	if (is_node_pmem(pgdat->node_id) &&
+	    (!sc->may_swap || mem_cgroup_get_nr_swap_pages(memcg) <= 0)) {
 		scan_balance = SCAN_FILE;
 		goto out;
 	}


