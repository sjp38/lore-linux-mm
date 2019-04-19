Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C57A2C282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 13:10:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8314C2229F
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 13:10:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8314C2229F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 151196B0003; Fri, 19 Apr 2019 09:10:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 101016B0007; Fri, 19 Apr 2019 09:10:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0011B6B0008; Fri, 19 Apr 2019 09:10:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id BB1C86B0003
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 09:10:20 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id s22so3496285plq.1
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 06:10:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=RpObNRAj+aDBuQzd6vq0iEfTUyZJjsZa2RpN7XtaNX4=;
        b=dfBHRIbvBY1OQyOtoUPOA+8R4cW91pi01+BqsKKs0zHmx+zBZEAqYhAgO6wMRRpOFk
         Fr9/L5IoCN1+wkbliWCqHFHkUZVX999c9tmnbXAZLQ0/RPzzjSpJnywVqxW3sCvYMC8s
         wnCXAE3+4XrK7bzxduPfeRTvutHyDd+x7G1vP7fo6CDkB9JHMO0tfV0+0bu/9Bl2ikde
         +r2LqhKzRIXgOYOYBYF6c0D/SQ+uOL6xd4Jfc24xDnK1BSLvFrIrZ5WGKU3u64V2YZPT
         /njrphapCuXgUy614F/9lafhtIGwwytWCgBVaSht9xiAt9lRl7R4FSkixD0cxt/4OEIk
         wHfA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVHFhviVCTuRa89h5VrzSUTCB+ePb/sKmbCEEOErezwYz5ftoDc
	xljcECywBOL4YfLQiAJywes7CR1BDnTn+DqqpijssDOoZlwJoI7KxGP+Zox4tQnXHKW9nGbadkz
	GSScq/kmf6tdqf7isitdilLpMoUTVAcGWugDXuLwJvWkXveOxZ28d3cYmDrxfwQP+FQ==
X-Received: by 2002:a17:902:9043:: with SMTP id w3mr3757865plz.101.1555679420054;
        Fri, 19 Apr 2019 06:10:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjZPqdd229OI/VwtTLo7uaHHIJufz4Y1AarHOE+UPNNzzrjY1pV8GXnh3Wbn/OaA8LVp1r
X-Received: by 2002:a17:902:9043:: with SMTP id w3mr3757793plz.101.1555679419279;
        Fri, 19 Apr 2019 06:10:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555679419; cv=none;
        d=google.com; s=arc-20160816;
        b=O+eaZHMBDRZwB1oBXVSe8kT/jEE7HOAampeV0/XHLoxeEitFbVM1/U2wFe39LM/R4J
         RhwNWObDeqZ6YIl9+L/+UdKl09VZ85kFpbRePUrBO3HgTXxqc85qK9ah5jCBLVxVq7Qy
         7R6mAoCG2R7ECqR5tOhRdPtwPDW3GYwz+FUEyEauqMg+ZmoIz7/+VSt30URjVc9JX2Kp
         IvKLIZ4Ujl01qQmZKIFXwULlPMMTya+ZEEr/Abwr9SHWvYTbvGesZneMBz8q1XBJDOyr
         h/R9X/e70fDNtpjQWVJpnq+1/h6YMZILHfkwwcrKxO47tWUhFihw9MgJ6EQ54kEWXqT3
         ygug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=RpObNRAj+aDBuQzd6vq0iEfTUyZJjsZa2RpN7XtaNX4=;
        b=orhAdrCSucj7xvB6FuUokOZlK8D4M+8rJxTOS6gW9wIrs613xZTMJu8knHr2G1uxzn
         o4ylluzjpBNbYhmCUnAD3pM2pUHfM5iAdJPWWupT/bQcajLTCi3VC/Y10VrGccz2rQVb
         DmgNyRMVQAYyCDHHHlVbfncgzr04S9nzgdABs2qlgsmSAsHw8Ee8cZMsXOqhwBsNU1Fp
         vQE81mvJepAbX99oSh2xuVk0qyyoNTzeVqvwl4NUqC7GhT84lfYjmUJPxGMyScJPL7KG
         Sg5vG2SBBUIwJ1617WJAbqtwWGcwyyHd4pG9iUCSVjL6c1R54GGQq5z55hIuM6oQ/6QB
         ZGfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id f127si5410617pfc.176.2019.04.19.06.10.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Apr 2019 06:10:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 19 Apr 2019 06:10:18 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,369,1549958400"; 
   d="scan'208";a="224917876"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by orsmga001.jf.intel.com with ESMTP; 19 Apr 2019 06:10:17 -0700
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1hHTHU-0009Ry-O9; Fri, 19 Apr 2019 21:10:16 +0800
Date: Fri, 19 Apr 2019 21:09:24 +0800
From: kbuild test robot <lkp@intel.com>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: [RFC PATCH mmotm] mm/z3fold.c: z3fold_page_isolate() can be static
Message-ID: <20190419130924.GA161478@ivb42>
References: <201904192137.KiV8DXsU%lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201904192137.KiV8DXsU%lkp@intel.com>
X-Patchwork-Hint: ignore
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Fixes: eaa5a15c91fe ("mm/z3fold.c: support page migration")
Signed-off-by: kbuild test robot <lkp@intel.com>
---
 z3fold.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index d9eabfda..1ffecd6 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -1285,7 +1285,7 @@ static u64 z3fold_get_pool_size(struct z3fold_pool *pool)
 	return atomic64_read(&pool->pages_nr);
 }
 
-bool z3fold_page_isolate(struct page *page, isolate_mode_t mode)
+static bool z3fold_page_isolate(struct page *page, isolate_mode_t mode)
 {
 	struct z3fold_header *zhdr;
 	struct z3fold_pool *pool;
@@ -1320,8 +1320,8 @@ bool z3fold_page_isolate(struct page *page, isolate_mode_t mode)
 	return false;
 }
 
-int z3fold_page_migrate(struct address_space *mapping, struct page *newpage,
-			struct page *page, enum migrate_mode mode)
+static int z3fold_page_migrate(struct address_space *mapping, struct page *newpage,
+			       struct page *page, enum migrate_mode mode)
 {
 	struct z3fold_header *zhdr, *new_zhdr;
 	struct z3fold_pool *pool;
@@ -1379,7 +1379,7 @@ int z3fold_page_migrate(struct address_space *mapping, struct page *newpage,
 	return 0;
 }
 
-void z3fold_page_putback(struct page *page)
+static void z3fold_page_putback(struct page *page)
 {
 	struct z3fold_header *zhdr;
 	struct z3fold_pool *pool;

