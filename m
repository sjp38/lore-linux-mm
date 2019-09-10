Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C155BC4740A
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 14:01:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6727C2081B
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 14:01:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6727C2081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA3CA6B0003; Tue, 10 Sep 2019 10:01:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B533A6B0006; Tue, 10 Sep 2019 10:01:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A42496B0007; Tue, 10 Sep 2019 10:01:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0006.hostedemail.com [216.40.44.6])
	by kanga.kvack.org (Postfix) with ESMTP id 817186B0003
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:01:45 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 28F7E82437CF
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 14:01:45 +0000 (UTC)
X-FDA: 75919174170.08.32128A4
Received: from filter.hostedemail.com (10.5.16.251.rfc1918.com [10.5.16.251])
	by smtpin08.hostedemail.com (Postfix) with ESMTP id 144761819DA39
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 14:01:12 +0000 (UTC)
X-HE-Tag: fall87_a6ac7aa6133d
X-Filterd-Recvd-Size: 2216
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 14:01:11 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 60A59B71C;
	Tue, 10 Sep 2019 14:01:09 +0000 (UTC)
Date: Tue, 10 Sep 2019 16:01:07 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Toshiki Fukasawa <t-fukasawa@vx.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"dan.j.williams@intel.com" <dan.j.williams@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"adobriyan@gmail.com" <adobriyan@gmail.com>,
	"hch@lst.de" <hch@lst.de>,
	"longman@redhat.com" <longman@redhat.com>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"mst@redhat.com" <mst@redhat.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Junichi Nomura <j-nomura@ce.jp.nec.com>
Subject: Re: [RFC PATCH v2] mm: initialize struct pages reserved by
 ZONE_DEVICE driver.
Message-ID: <20190910140107.GD2063@dhcp22.suse.cz>
References: <20190906081027.15477-1-t-fukasawa@vx.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190906081027.15477-1-t-fukasawa@vx.jp.nec.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 06-09-19 08:09:52, Toshiki Fukasawa wrote:
[...]
> @@ -5856,8 +5855,6 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>  		if (!altmap)
>  			return;
>  
> -		if (start_pfn == altmap->base_pfn)
> -			start_pfn += altmap->reserve;
>  		end_pfn = altmap->base_pfn + vmem_altmap_offset(altmap);

Who is actually setting reserve? This is is something really impossible
to grep for in the kernle and git grep on altmap->reserve doesn't show
anything AFAICS.

Btw. irrespective to this issue all three callers should be using
pfn_to_online_page rather than pfn_to_page AFAICS. It doesn't really
make sense to collect data for offline pfn ranges. They might be
uninitialized even without zone device.
-- 
Michal Hocko
SUSE Labs

