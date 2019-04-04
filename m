Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DFA77C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 09:09:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77EFA20693
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 09:09:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="IEBVyolg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77EFA20693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF3F26B0005; Thu,  4 Apr 2019 05:09:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA26B6B0006; Thu,  4 Apr 2019 05:09:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D6B0F6B0007; Thu,  4 Apr 2019 05:09:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9DDC56B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 05:09:52 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id z12so1186668pgs.4
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 02:09:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=cmewEeo7CPbOt4HdWwgdrWYYs0tc20LVge3PPN7b8tE=;
        b=kUaxx2Q4gej0aPkDc3b+lNB9SIu9slu4n5Viw81fnuASM3rzECl1nBJuj5/o0U4dgA
         ah/IVhAmu3nykVQ8MIqV8JOzogucevj/3Ly+CZEED43yAMrxHBsVbWa2nlZQjSJ4jh5G
         YOAY+ZcQiVYR7QN0sH/PFM4bS+HEfaaiaPyTKfpKTgTlgQUM7XnrTF++Au0iBCSo0O+I
         mrh0cckasVZZx0wdSKbUYYq6lv6CzofWgl1sq0ZfqZ8930MrLqB9kbceYN91t6ptj5qQ
         9Mg7YtR3thw129xPM30MmHF5XB2Kso3QyGfD6EU3G+Vod7MhUYw3RQTskdUaWEsfY5BN
         AnNA==
X-Gm-Message-State: APjAAAUsNssvHsEt3uAt8YS8EJ0zdESFmINeChcoj6fovJ+04nyC82N1
	dQULum1HOvmUCgbdHQD+dfcex3V1Gdyf9H2ItPM/QsJxqrK4f5WsJTS3UUFSWL/eMc0XHDEdOey
	3MOC9jXdG7uoX4Ksv9Utv2c5X0gYs03VrP2ohXKFpatV77MPHBEAFjr67TKHTGPHONw==
X-Received: by 2002:a17:902:9a43:: with SMTP id x3mr5268436plv.173.1554368992017;
        Thu, 04 Apr 2019 02:09:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz9+4hRzUMX7myMhV3ULCufcrvrZSHTfqaDPjAHeByuSykCZz9lhLdtrpzK+E24K7zebKKR
X-Received: by 2002:a17:902:9a43:: with SMTP id x3mr5268368plv.173.1554368991252;
        Thu, 04 Apr 2019 02:09:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554368991; cv=none;
        d=google.com; s=arc-20160816;
        b=cPGKyxBO1HyObm5lqa3TjmsTWYJX51GTzsQPgAXv/xygqJCQyZtkzp7tnvFkzG2W9W
         j14PzJ6Ihoflr1uI/l/XbZDlf7qMtYJpxNAo48v38tBszQVQa+dEVi/Gc/+OFNv5dwi9
         T1AJVbZ+jzqXHzVSOTthQfm0vJAZJwDMtXoAoiV846pH3wgBTIIo4IUhGKJ+g7AkGeCb
         FBqj5MyqS4zCaH/7Yj818Tv9m15jOLi8gTT6guO99f53GMfMVxRj03tQL9dF4rRN1jG3
         LntwLMv9c/c3rEbakh/heAbQLYXwSX0orEk5PKuZrVyMllhIlmySrSSaOhXEHgAIw70Z
         bVpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature;
        bh=cmewEeo7CPbOt4HdWwgdrWYYs0tc20LVge3PPN7b8tE=;
        b=NQO+dVWz8ArwHKthW+8oEsm/xURQhyBxIoWjzg9cMtl6dgJ6Ifx9GB5Rs/2RX2+2Ij
         nmRYqBBWD922RqXnsZS+hiw9VdkS1smQRNjE0C35aAoUBMREhccpXFAqicSozImTKuOF
         mR1x/8pRmopfWXQ/euwiffqimA7iP2JLhF1xtj/E4/p8H+/zyHxcUfMZzrAQZxG5UCR3
         y/ciHwGOQDlBBqbiXPR92vTu83Y+z11vvb7UtKE8EECKXF/k5zntBxCrPdqsqi1OEIm8
         j0gFJvj4YdJeixrPISU6I0C8iPwXia+ZZyiHBqUQ4DtcepfTvZ4CkqWHWdCBWGOige1z
         lo1w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=IEBVyolg;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id i98si16205376plb.292.2019.04.04.02.09.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 02:09:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=IEBVyolg;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 40D4A20652;
	Thu,  4 Apr 2019 09:09:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1554368990;
	bh=/nIV/fGH+CgcQy8+EIi55FqpZEINdruxAOGABvN50jE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=IEBVyolg8sZ/+bImPxBfu7KDDMvjcI5GaYWCb6QDVZtkTwHb9ugBhv1JVvR5JVtnA
	 Tb5a1d16b/JPeiSIHX0RhU8F3SWLmCGxbV95Jk0H2DI0OMp+hQEL3O4is6EgI96y98
	 IN3XE2H7h/dUDhe7ioh7+gEzDCKU/TsYnzWcqmVo=
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	stable@vger.kernel.org,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Jiang <dave.jiang@intel.com>,
	Ross Zwisler <zwisler@kernel.org>,
	Vishal Verma <vishal.l.verma@intel.com>,
	Tom Lendacky <thomas.lendacky@amd.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	linux-nvdimm@lists.01.org,
	linux-mm@kvack.org,
	Huang Ying <ying.huang@intel.com>,
	Fengguang Wu <fengguang.wu@intel.com>,
	Borislav Petkov <bp@suse.de>,
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>,
	Takashi Iwai <tiwai@suse.de>,
	Jerome Glisse <jglisse@redhat.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	linuxppc-dev@lists.ozlabs.org,
	Keith Busch <keith.busch@intel.com>,
	Sasha Levin <sashal@kernel.org>,
	Michael Ellerman <mpe@ellerman.id.au>
Subject: [PATCH 5.0 057/246] mm/resource: Return real error codes from walk failures
Date: Thu,  4 Apr 2019 10:45:57 +0200
Message-Id: <20190404084621.174666333@linuxfoundation.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190404084619.236418459@linuxfoundation.org>
References: <20190404084619.236418459@linuxfoundation.org>
User-Agent: quilt/0.65
X-stable: review
X-Patchwork-Hint: ignore
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

5.0-stable review patch.  If anyone has any objections, please let me know.

------------------

[ Upstream commit 5cd401ace914dc68556c6d2fcae0c349444d5f86 ]

walk_system_ram_range() can return an error code either becuase
*it* failed, or because the 'func' that it calls returned an
error.  The memory hotplug does the following:

	ret = walk_system_ram_range(..., func);
        if (ret)
		return ret;

and 'ret' makes it out to userspace, eventually.  The problem
s, walk_system_ram_range() failues that result from *it* failing
(as opposed to 'func') return -1.  That leads to a very odd
-EPERM (-1) return code out to userspace.

Make walk_system_ram_range() return -EINVAL for internal
failures to keep userspace less confused.

This return code is compatible with all the callers that I
audited.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Bjorn Helgaas <bhelgaas@google.com>
Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Jiang <dave.jiang@intel.com>
Cc: Ross Zwisler <zwisler@kernel.org>
Cc: Vishal Verma <vishal.l.verma@intel.com>
Cc: Tom Lendacky <thomas.lendacky@amd.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: linux-nvdimm@lists.01.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: Huang Ying <ying.huang@intel.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>
Cc: Borislav Petkov <bp@suse.de>
Cc: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Cc: Takashi Iwai <tiwai@suse.de>
Cc: Jerome Glisse <jglisse@redhat.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: linuxppc-dev@lists.ozlabs.org
Cc: Keith Busch <keith.busch@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 kernel/resource.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/resource.c b/kernel/resource.c
index 915c02e8e5dd..ca7ed5158cff 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -382,7 +382,7 @@ static int __walk_iomem_res_desc(resource_size_t start, resource_size_t end,
 				 int (*func)(struct resource *, void *))
 {
 	struct resource res;
-	int ret = -1;
+	int ret = -EINVAL;
 
 	while (start < end &&
 	       !find_next_iomem_res(start, end, flags, desc, first_lvl, &res)) {
@@ -462,7 +462,7 @@ int walk_system_ram_range(unsigned long start_pfn, unsigned long nr_pages,
 	unsigned long flags;
 	struct resource res;
 	unsigned long pfn, end_pfn;
-	int ret = -1;
+	int ret = -EINVAL;
 
 	start = (u64) start_pfn << PAGE_SHIFT;
 	end = ((u64)(start_pfn + nr_pages) << PAGE_SHIFT) - 1;
-- 
2.19.1



