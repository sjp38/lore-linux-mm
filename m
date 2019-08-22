Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92D40C3A5A1
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 23:03:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2765E233A0
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 23:03:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="BBxVo2nN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2765E233A0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA1216B035D; Thu, 22 Aug 2019 19:03:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B513A6B035F; Thu, 22 Aug 2019 19:03:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A66436B0360; Thu, 22 Aug 2019 19:03:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0015.hostedemail.com [216.40.44.15])
	by kanga.kvack.org (Postfix) with ESMTP id 800436B035D
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 19:03:46 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 277E6689C
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 23:03:46 +0000 (UTC)
X-FDA: 75851592852.09.nerve57_3c21e0d48c29
X-HE-Tag: nerve57_3c21e0d48c29
X-Filterd-Recvd-Size: 2603
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 23:03:45 +0000 (UTC)
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9C32B21848;
	Thu, 22 Aug 2019 23:03:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1566515024;
	bh=fgi/rgPJr0UBQTUlu1/65uSy+9MMhXIOvXFp0ALGfb0=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=BBxVo2nNziNaw3nAAEFAen1S7XiIO8Vta0pNHjnEDrJV2guXM6hZIbA3EBQnD27XU
	 xx5lUT8HJgT0tzNJTsVuX+MYZ+kxVgP8Ozyil9XXkdjvISelPuFKSvf1uwNrSSSuuI
	 gXZFDs+IVIjusG2rBR8LeQ8NVAbEX+BcR3Xuw3ow=
Date: Thu, 22 Aug 2019 16:03:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov"
 <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@kernel.org>, Mel
 Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 0/4] debug_pagealloc improvements through page_owner
Message-Id: <20190822160344.716eda34585271fa4a519d4c@linux-foundation.org>
In-Reply-To: <20190820131828.22684-1-vbabka@suse.cz>
References: <20190820131828.22684-1-vbabka@suse.cz>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 20 Aug 2019 15:18:24 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:

> v2: also fix THP split handling (added Patch 1) per Kirill
> 
> The debug_pagealloc functionality serves a similar purpose on the page
> allocator level that slub_debug does on the kmalloc level, which is to detect
> bad users. One notable feature that slub_debug has is storing stack traces of
> who last allocated and freed the object. On page level we track allocations via
> page_owner, but that info is discarded when freeing, and we don't track freeing
> at all. This series improves those aspects. With both debug_pagealloc and
> page_owner enabled, we can then get bug reports such as the example in Patch 4.
> 
> SLUB debug tracking additionaly stores cpu, pid and timestamp. This could be
> added later, if deemed useful enough to justify the additional page_ext
> structure size.

Thanks.  I split [1/1] out of the series as a bugfix and turned this
into a three-patch series.


