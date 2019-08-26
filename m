Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D4C7C3A5A6
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 18:02:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 178F120850
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 18:02:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="d2fknKfO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 178F120850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89AE16B05CA; Mon, 26 Aug 2019 14:02:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 84B0E6B05CB; Mon, 26 Aug 2019 14:02:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 739F16B05CC; Mon, 26 Aug 2019 14:02:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0030.hostedemail.com [216.40.44.30])
	by kanga.kvack.org (Postfix) with ESMTP id 531FD6B05CA
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 14:02:15 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id E9540824CA28
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 18:02:14 +0000 (UTC)
X-FDA: 75865348188.16.shoes88_4dca61d390137
X-HE-Tag: shoes88_4dca61d390137
X-Filterd-Recvd-Size: 3721
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com [216.228.121.64])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 18:02:14 +0000 (UTC)
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d641ea70000>; Mon, 26 Aug 2019 11:02:15 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 26 Aug 2019 11:02:13 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 26 Aug 2019 11:02:13 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 26 Aug
 2019 18:02:12 +0000
Subject: Re: [PATCH 1/2] mm/hmm: hmm_range_fault() NULL pointer bug
To: Christoph Hellwig <hch@lst.de>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
	<amd-gfx@lists.freedesktop.org>, <dri-devel@lists.freedesktop.org>,
	<nouveau@lists.freedesktop.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>, Andrew Morton
	<akpm@linux-foundation.org>
References: <20190823221753.2514-1-rcampbell@nvidia.com>
 <20190823221753.2514-2-rcampbell@nvidia.com> <20190824223754.GA21891@lst.de>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <e2ecc1a7-0d2f-5957-e6cb-b3c86c085d80@nvidia.com>
Date: Mon, 26 Aug 2019 11:02:12 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190824223754.GA21891@lst.de>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL111.nvidia.com (172.20.187.18) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1566842535; bh=q0XlO0WIP1WKl6O/MutlXE9k/HAHL1+wksVgPZA90XQ=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=d2fknKfO2/+Zv6spaSSH3ujdgxCAZH3q2pr6c/Siwshb41aUxlG/I+6Tyj3fXyYY5
	 r1ZUUnxreiuxEswRCYLLZsMIXjsrYEZ2qKObAcIzx4lFW+80OBz929fmspCEwePFSM
	 Weh8IBdvRGmAYugnTXZh+qH1U82UBGS1UKNXbJ6ZBS+xJMiQMjfCYuJvF6l51O9pkO
	 O0oy/5uowbDESOjWEqnQfr3ZNPKFAUyr/vq/8JL6L4ZXdjyHlF2eCpi6YaUIhZ26eX
	 tDQ19l3lAZnppu1N//ySuXInwpJ3YqMTeBXQVmBM1ehXjdv0DZYHvm24rrRDsWS3r/
	 wDuGvR7pgamGw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 8/24/19 3:37 PM, Christoph Hellwig wrote:
> On Fri, Aug 23, 2019 at 03:17:52PM -0700, Ralph Campbell wrote:
>> Although hmm_range_fault() calls find_vma() to make sure that a vma exists
>> before calling walk_page_range(), hmm_vma_walk_hole() can still be called
>> with walk->vma == NULL if the start and end address are not contained
>> within the vma range.
> 
> Should we convert to walk_vma_range instead?  Or keep walk_page_range
> but drop searching the vma ourselves?
> 
> Except for that the patch looks good to me:
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> 

I think keeping the call to walk_page_range() makes sense.
Jason is hoping to be able to snapshot a range with & without vmas
and have the pfns[] filled with empty/valid entries as appropriate.

I plan to repost my patch changing hmm_range_fault() to use
walk.test_walk which will remove the call to find_vma().
Jason had some concerns about testing it so that's why I have
been working on some HMM self tests before resending it.

