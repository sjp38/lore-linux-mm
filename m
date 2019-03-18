Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88AC6C10F00
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 07:29:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B85F2083D
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 07:29:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B85F2083D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C02A6B0003; Mon, 18 Mar 2019 03:29:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 86C926B0006; Mon, 18 Mar 2019 03:29:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 75CBC6B0007; Mon, 18 Mar 2019 03:29:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 359446B0003
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 03:29:53 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id p4so6541020edd.0
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 00:29:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=DWFtiZPjoRjiWvPt/gIzocfW/ZQPI6hXRK4YSyrSrUs=;
        b=cjtG0W9A6zX3dMCq66wQS7/nkKfAHz92Lt4Cmqt7cClGEyJN13rUM3LN/Iz1RITgSj
         KZ6QmdCzABWzE2bVNowq4HNDvn8h1U8QaKT3QVYTMsyAH8Mhhq/4SvuKsaMvbLYUXtKy
         MFrSnHDORY/zz2kOpb51PxRSwTaEIukys2IXif9e77B/zOA/qKc+OwF/AbT1z2LQYOlr
         QT8uVOj6B2gqrFfg/D3Wq5DfXXXLXq2uiiRT+wafOD6y8pTMdmmcYRpvRQrTDzCg1mYx
         ckKqejlgVPeB0lHUCD0PWVCB0W+t+aigucBoKPn0e669yh18k+f1Dby+wjGVPhTvykF5
         VjAQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAV70GORY6sQHVVBplFLhzHwfL2YK4Sos5IGPtfgWyfmxGWrgLKA
	o+TXfmxncDoixMSAIY8ts2bOf7cASFcxCY2yTVAPvoXL3iJtVKhxuvLDnZUi9oywxLh2obe0G9L
	HqD2L+mQCpcKnTCPkXSJc1yFnlR0VmRqpTXkBQ1AUf0zIZHBZIcPJ2eKZ1SB9t+TVmQ==
X-Received: by 2002:a50:b6a9:: with SMTP id d38mr11847405ede.98.1552894192683;
        Mon, 18 Mar 2019 00:29:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwNvLXDz/8wkD0xNJfhsl1YGDKE5kMAS0HCHLGBcOZn3qoYFEqOkrPTQOw1bqBUVq8z5sTp
X-Received: by 2002:a50:b6a9:: with SMTP id d38mr11847349ede.98.1552894191505;
        Mon, 18 Mar 2019 00:29:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552894191; cv=none;
        d=google.com; s=arc-20160816;
        b=y7ay7q7PjABBH0n960zK5IxQ5aqYuzNlp4p3TxVsRLjes78DkuU/Za66Lbe+Vx9tcz
         4O0NKW7n9nTEuyCADrSITnU2VBLi+HU1JolAkpqPel133/SxqE0gJEWdvpkKhtMDpLLY
         fE2RKBWd30lEg2lW8fyKJ41oZ2JTQbbGeSTPWPXdEGsCy1HlItZC3mfm4LYCF6oX2PQK
         1JMdJGZBto9dW6lIpNNlrfpRcrGUAw0nkXVMQnzwJly3PpRNIVvpLJw0fsD4qgF0yNgm
         ileaG2lcj+rCEcTClEOZqWjuptO0/RMD9p4/u6fSiPnYuCBUmKWWalPsl1OHrGfMbT9z
         uQNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=DWFtiZPjoRjiWvPt/gIzocfW/ZQPI6hXRK4YSyrSrUs=;
        b=dAutOAu1LMfzxx6zmllKpVt8Qk9SLGLtYAeDE7XLMDJKvwC9lLWh4wu6+6ivv88qMT
         +LwKuh8+vPqpITE2ccnTO0N6wkEJOarT4O9Z0eWJAQClFpkQteI9G5ElCmFOBAXXZO/R
         i8wVcfjLGZ5R5+RwV3WzRdyQ5PMk1pHuqDCkINp3G07ZO7o6IbqD4YWbtFsC+ThVgybF
         5Z4YNgacz2EVY90UYRAPjOSNBKjyPqIrh7WM464NTRXPpDnwdOSu7s/6LnMf7h9SAiyn
         c6hZLrQIUPGwrdJ6P20bk+SpaOT6DFzHcEyrWVng6e8/db8zEtFOAb8x9/Es/OaSStlx
         EerQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id h9si1712581ejc.175.2019.03.18.00.29.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Mar 2019 00:29:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Mon, 18 Mar 2019 08:29:50 +0100
Received: from d104.suse.de (nwb-a10-snat.microfocus.com [10.120.13.201])
	by emea4-mta.ukb.novell.com with ESMTP (NOT encrypted); Mon, 18 Mar 2019 07:29:44 +0000
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com,
	anshuman.khandual@arm.com,
	william.kucharski@oracle.com,
	hughd@google.com,
	jack@suse.cz,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH v2] mm: Fix __dump_page when mapping->host is not set
Date: Mon, 18 Mar 2019 08:29:31 +0100
Message-Id: <20190318072931.29094-1-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Swap mapping->host is NULL, so let us protect __dump_page() for such cases.

Fixes: 1c6fb1d89e73c ("mm: print more information about mapping in __dump_page")
Signed-off-by: Oscar Salvador <osalvador@suse.de>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 mm/debug.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/debug.c b/mm/debug.c
index c0b31b6c3877..7759f12a8fbb 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -79,7 +79,7 @@ void __dump_page(struct page *page, const char *reason)
 		pr_warn("ksm ");
 	else if (mapping) {
 		pr_warn("%ps ", mapping->a_ops);
-		if (mapping->host->i_dentry.first) {
+		if (mapping->host && mapping->host->i_dentry.first) {
 			struct dentry *dentry;
 			dentry = container_of(mapping->host->i_dentry.first, struct dentry, d_u.d_alias);
 			pr_warn("name:\"%pd\" ", dentry);
-- 
2.13.7

