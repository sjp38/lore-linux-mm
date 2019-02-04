Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B72FAC282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 23:35:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C0C320821
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 23:35:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C0C320821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 12CDE8E0068; Mon,  4 Feb 2019 18:35:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0DBBF8E001C; Mon,  4 Feb 2019 18:35:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F33DE8E0068; Mon,  4 Feb 2019 18:35:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id B0F4C8E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 18:35:37 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id x12so963993pgq.8
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 15:35:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=wtuXUqV4ZOFvc0OvGpbjmwczJBBbXCS+25V52I6nESg=;
        b=dhTTgbFEAQnaCuIt3Us8FKk2K/ifIrdHzeEr+zWjhcJAe5IOFb2vq9Bjvf6CF2f2OV
         nfLHArqb3wdtQPfMIhBauF8YKd6zJbIVBIox96iLIDYixvPMTrkiMWh8YMoYOsxky/gY
         EVOOeTwbrhNxz5jFNK5IacAkOhH6eUJTJ5HfNZyQxmeUb9B7z7Okm+u4WJjOigHdEpHC
         XsbIiMMO5sTlGhU51CwdrJCpnYpI7JUWAUbP45P6sgcvqaZZ9CfP4z1gXQU9IMSG3TKY
         jNcZRJnj4QG3rWUkkRX0g9MhYN25BgaOzP7xHlVjRU8kXEWF5wFtdYAD9Za4XcSReCH3
         FaxA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZTbbVBkCaRP/crqUFbaHd2WSPlui486TQf+5GB+2U0TyW1FCdm
	lGcQy/6tyldyrtpo6/2bUElrq3W9Bsias3bRmScNh3i9ursvG0QKxMSfpRexIeQj4v4boNrb0JG
	U5Ju4bIyIRxJLtiGJhhOchWVVh1Az9BqZA42MRiR1CrdEiWb4+sBpjXcaWtEWqtzWjw==
X-Received: by 2002:a17:902:7e0d:: with SMTP id b13mr2031395plm.154.1549323337383;
        Mon, 04 Feb 2019 15:35:37 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZUdTcO5D0+NaIR9czxPbhc4/zr5/Zr8PVbidg4TCSEcvjS3dsCyuUJaCgx74K4Qe8tDYx3
X-Received: by 2002:a17:902:7e0d:: with SMTP id b13mr2031331plm.154.1549323336490;
        Mon, 04 Feb 2019 15:35:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549323336; cv=none;
        d=google.com; s=arc-20160816;
        b=QU3YBALTwVhubLnxcKRvJq+A43FHzLF03qHctTNHa8P23XlaQukspC0R68ApfrNrny
         G7IQBGxtPfwhPh30F6H7Phso9zG1vvxD/fFjHtpoLfbwJ0nBQ1z1X2BjNKp9EHyXh5Pv
         l8ClELmN6gxazWNIqC6IuAKoYDgBHws4gJpamCYFU6I3CQavkmcxDQ3kiHdYFfiqwv4I
         uO4zSpoRD0tWrLOUplr+LIYDsMZl39N/OzyJLxRkdkmqqMV1nc4CiqMGtGLrcmUqcO0X
         5a3Rlft7fqP0J0mH4Ums0cH2lRpKQKgDgl+1gaotpjfH//zrWf+Bk9C39mOBt0ClPYjQ
         5NhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=wtuXUqV4ZOFvc0OvGpbjmwczJBBbXCS+25V52I6nESg=;
        b=iSRyNlRdVKRixvS7DKR4q94o7+cPf/7UYcN2Kw5flV1+MWsR8n7EnJz+TrhE6wU/ap
         Ujj7Z/TY4v0jZyxFxaRnVMAAe5G5qsnh8y+oL8v3FxL2ZoUdWeeVnh5S5K6LQ+sro2l1
         453sqaB19aYhOO9bSFpA7zDqTLfIvTDSd3C1iaRPCgHVCeO8xsQ2g8j2Vafa1rmtaGIj
         BdR6Dl0WzjuPzTQ+pfUdpBVxR+PP1gQbCLMWWdLxbLUqfkfJ70rQtcf9tUv/LRBgNNkv
         taYYoZReXFg7NxZq13wD6QKhWYRshfJ2sm1lF5Nw5fO3uFksCIIUWDzL+do6hwoQ7XvC
         zMFA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id j21si1410929pfn.277.2019.02.04.15.35.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 15:35:36 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Feb 2019 15:35:35 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,560,1539673200"; 
   d="scan'208";a="113707140"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga006.jf.intel.com with ESMTP; 04 Feb 2019 15:35:34 -0800
Date: Mon, 4 Feb 2019 15:35:14 -0800
From: Ira Weiny <ira.weiny@intel.com>
To: Christopher Lameter <cl@linux.com>
Cc: john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org, Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH 0/6] RFC v2: mm: gup/dma tracking
Message-ID: <20190204233513.GA7917@iweiny-DESK2.sc.intel.com>
References: <20190204052135.25784-1-jhubbard@nvidia.com>
 <01000168b980e880-a7d8e0db-84fb-4398-8269-149c66b701b4-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01000168b980e880-a7d8e0db-84fb-4398-8269-149c66b701b4-000000@email.amazonses.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 04, 2019 at 05:14:19PM +0000, Christopher Lameter wrote:
> Frankly I still think this does not solve anything.
> 
> Concurrent write access from two sources to a single page is simply wrong.
> You cannot make this right by allowing long term RDMA pins in a filesystem
> and thus the filesystem can never update part of its files on disk.
> 
> Can we just disable RDMA to regular filesystems? Regular filesystems
> should have full control of the write back and dirty status of their
> pages.

That may be a solution to the corruption/crashes but it is not a solution which
users want to see.  RDMA directly to file systems (specifically DAX) is a use
case we have seen customers ask for.

I think this is the correct path toward supporting this use case.

Ira

