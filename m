Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1AD09C3A59D
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 11:57:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E98D52085A
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 11:57:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E98D52085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 924186B000C; Mon, 19 Aug 2019 07:57:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D4156B000D; Mon, 19 Aug 2019 07:57:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C3ED6B000E; Mon, 19 Aug 2019 07:57:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0173.hostedemail.com [216.40.44.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5C8666B000C
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 07:57:57 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 060D453A3
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 11:57:57 +0000 (UTC)
X-FDA: 75839028594.07.beam54_7f85e1187c40d
X-HE-Tag: beam54_7f85e1187c40d
X-Filterd-Recvd-Size: 2216
Received: from mga14.intel.com (mga14.intel.com [192.55.52.115])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 11:57:56 +0000 (UTC)
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 19 Aug 2019 04:57:54 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,403,1559545200"; 
   d="scan'208";a="377409646"
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga005.fm.intel.com with ESMTP; 19 Aug 2019 04:57:52 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 9AD77128; Mon, 19 Aug 2019 14:57:51 +0300 (EEST)
Date: Mon, 19 Aug 2019 14:57:51 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/3] mm, page_owner: record page owner for each subpage
Message-ID: <20190819115751.bost7nrac4at7pq3@black.fi.intel.com>
References:<20190816101401.32382-1-vbabka@suse.cz>
 <20190816101401.32382-2-vbabka@suse.cz>
 <20190816140430.aoya6k7qxxrls72h@box>
 <a9344bd6-cdb9-3ad6-5bb1-8eb81650c398@suse.cz>
 <20190819115551.xkgnpr7zmaqpuebi@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To:<20190819115551.xkgnpr7zmaqpuebi@black.fi.intel.com>
User-Agent: NeoMutt/20170714-126-deb55f (1.8.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 19, 2019 at 11:55:51AM +0000, Kirill A. Shutemov wrote:
> > @@ -2533,6 +2534,8 @@ static void __split_huge_page(struct page *page, struct list_head *list,
> >  
> >  	remap_page(head);
> >  
> > +	split_page_owner(head, HPAGE_PMD_ORDER);
> > +
> 
> I think it has to be before remap_page(). This way nobody would be able to
> mess with the page until it has valid page_owner.

Or rather next to ClearPageCompound().

-- 
 Kirill A. Shutemov

