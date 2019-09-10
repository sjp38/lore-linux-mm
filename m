Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9FC41C3A5A2
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 12:20:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A23220872
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 12:20:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A23220872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F23CB6B0003; Tue, 10 Sep 2019 08:20:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EACD76B0006; Tue, 10 Sep 2019 08:20:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9BFC6B0007; Tue, 10 Sep 2019 08:20:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0109.hostedemail.com [216.40.44.109])
	by kanga.kvack.org (Postfix) with ESMTP id BC0B26B0003
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 08:20:33 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 71BB7BEF6
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 12:20:33 +0000 (UTC)
X-FDA: 75918919146.30.coal14_4ce23f663f3c
X-HE-Tag: coal14_4ce23f663f3c
X-Filterd-Recvd-Size: 2873
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 12:20:32 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 80E9FABCE;
	Tue, 10 Sep 2019 12:20:31 +0000 (UTC)
Date: Tue, 10 Sep 2019 14:20:30 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, mst@redhat.com,
	catalin.marinas@arm.com, david@redhat.com, dave.hansen@intel.com,
	linux-kernel@vger.kernel.org, willy@infradead.org,
	linux-mm@kvack.org, akpm@linux-foundation.org, will@kernel.org,
	linux-arm-kernel@lists.infradead.org, osalvador@suse.de,
	yang.zhang.wz@gmail.com, pagupta@redhat.com, konrad.wilk@oracle.com,
	nitesh@redhat.com, riel@surriel.com, lcapitulino@redhat.com,
	wei.w.wang@intel.com, aarcange@redhat.com, ying.huang@intel.com,
	pbonzini@redhat.com, dan.j.williams@intel.com,
	fengguang.wu@intel.com, alexander.h.duyck@linux.intel.com,
	kirill.shutemov@linux.intel.com
Subject: Re: [PATCH v9 2/8] mm: Adjust shuffle code to allow for future
 coalescing
Message-ID: <20190910122030.GV2063@dhcp22.suse.cz>
References: <20190907172225.10910.34302.stgit@localhost.localdomain>
 <20190907172520.10910.83100.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190907172520.10910.83100.stgit@localhost.localdomain>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat 07-09-19 10:25:20, Alexander Duyck wrote:
> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> 
> Move the head/tail adding logic out of the shuffle code and into the
> __free_one_page function since ultimately that is where it is really
> needed anyway. By doing this we should be able to reduce the overhead
> and can consolidate all of the list addition bits in one spot.

This changelog doesn't really explain why we want this. You are
reshuffling the code, allright, but why do we want to reshuffle? Is the
result readability a better code reuse or something else? Where
does the claimed reduced overhead coming from?

From a quick look buddy_merge_likely looks nicer than the code splat
we have. Good.

But then

> Reviewed-by: Dan Williams <dan.j.williams@intel.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>

[...]

> -	if (is_shuffle_order(order))
> -		add_to_free_area_random(page, &zone->free_area[order],
> -				migratetype);
> +	area = &zone->free_area[order];
> +	if (is_shuffle_order(order) ? shuffle_pick_tail() :
> +	    buddy_merge_likely(pfn, buddy_pfn, page, order))

Ouch this is just awful don't you think?
-- 
Michal Hocko
SUSE Labs

