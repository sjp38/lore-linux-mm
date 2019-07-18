Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD75DC76196
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 05:51:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C2E521855
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 05:51:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C2E521855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C739F6B0005; Thu, 18 Jul 2019 01:51:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BFD3A8E0001; Thu, 18 Jul 2019 01:51:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9F6A6B000A; Thu, 18 Jul 2019 01:51:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6ED046B0005
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 01:51:36 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 91so13321316pla.7
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 22:51:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:user-agent:mime-version:to:cc:subject:references
         :in-reply-to:content-transfer-encoding;
        bh=bJ+P6l4sBWFG4da91ExsiJIOILHZRWwkDB2B+itWlwI=;
        b=GCjubvsD4QKlXy+P0rkd7P4IQaKvKswlVDLLHVHe4f8MUqj3iJULKMUZYZmaB9Wj6J
         uOKY2MsbL6Ut9o0bC7INnen/rIpRkkRwpaSQXCrEmTkxWWPqkZNdmrbLurwr+oWZbqis
         4xn4FASb4Vb8TaA/iP5vUk1ZLCyxvwoSdsbwfr1kFp/9ax+eCeNgPX7btSvL8QMfRt11
         rSkv7IinBj8LEXOHC9HX8lznNkuXdeVgo/A0QEy3dteg+2rzPWCeRSA059F9uEb81fem
         LAlCRgk5ZNKlI9X5boY4maOv1oFy0L93Bt6qCB9JGDGWR7cJBblSjEpX7erroS9mprBr
         4/dA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of wei.w.wang@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=wei.w.wang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWiKdRQbTGixbTozCzBzbTtv4RRVctLoR08Pf+bKHVVVs1bc6aW
	SQaGJKJWjd0mIJQHNlhR85j5xW1aqbyNDkZ3u3JDS1/ykHVWtV2LKWSr+gzBVBjDDcPmqHwsRrC
	AheCL/eJAE5SKVMFlsQtgv9qyC4+nQzEoF4Bj7XahEgG6mep53nv94cbbdVj+qr5K7g==
X-Received: by 2002:a17:902:f301:: with SMTP id gb1mr47227919plb.292.1563429096002;
        Wed, 17 Jul 2019 22:51:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy6GxrMic7DMv2XTAI+k5V64n7Axo3QOkzNDqqAk0M2DSWJy+X2b35g7lKvmhvlEDbnmj1O
X-Received: by 2002:a17:902:f301:: with SMTP id gb1mr47227868plb.292.1563429095346;
        Wed, 17 Jul 2019 22:51:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563429095; cv=none;
        d=google.com; s=arc-20160816;
        b=PpLeP1tvV0r6vuGed0qPzGUC1bdg6U2xk9WsrG3WX+NxtzO50N4MYAlJFmgvu2NpBl
         ZkA6QzgV1bXYAfwYXefpJC5ce7rs3tVW4Kwj3aNLWjleUFXU47TDhk2njIUf8BfM+pWu
         m7BdrrEPdz3Kz07t//u3LfuE1E9M6xN27bGZi2pQSdtvz3Z04fX1Iz3hLBivto5yYvnl
         UxfB2abs94/z1cAZfAlkxjjkmYeSqf0OGiQP3PnDfwEcVqUcbXuu/ooVsJljIcGeTp3R
         CAuz04oEezLsR9q6aww8Kn5ToKIqIrPEueUYgrfdCA2xQwX9FjKz2aXQ8woXmNim2HQw
         w6sg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:subject:cc:to
         :mime-version:user-agent:from:date:message-id;
        bh=bJ+P6l4sBWFG4da91ExsiJIOILHZRWwkDB2B+itWlwI=;
        b=wQZjLb32gGwZra/v4ScVE2y6VAI7g8FpEjaptRywqnCWZoC23dYuIeWWWb+b6dO+lL
         oKqzs41RkOxcMdB1riEgHzlyECGMvIRslfQCI/vAeH8bxdCK3mG94AHhf113m38B0uLz
         oJOl60XEG2uCZC2ZGNSU2XETmuEYoX1GNIE+ByvCPr19WPLf5T0Ip6FddI3N+clQlgXn
         bbto+IfucX9j73rlG+yN1erSuYGQga6pRZC3ZKk14uBT96lnILXkxqyGOXw5jhnBVArX
         +1jAQLpZZdt9jqcJJ0b/GTvO0B2v5ZyQteUOFV+Rbz76YMZrhGUePY8AZyUXeAmHjla9
         qbBg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of wei.w.wang@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=wei.w.wang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id o8si7229388pgj.239.2019.07.17.22.51.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 22:51:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of wei.w.wang@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of wei.w.wang@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=wei.w.wang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Jul 2019 22:51:34 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,276,1559545200"; 
   d="scan'208";a="367248561"
Received: from unknown (HELO [10.239.13.7]) ([10.239.13.7])
  by fmsmga006.fm.intel.com with ESMTP; 17 Jul 2019 22:51:30 -0700
Message-ID: <5D300A32.4090300@intel.com>
Date: Thu, 18 Jul 2019 13:57:06 +0800
From: Wei Wang <wei.w.wang@intel.com>
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:31.0) Gecko/20100101 Thunderbird/31.7.0
MIME-Version: 1.0
To: "Michael S. Tsirkin" <mst@redhat.com>
CC: Alexander Duyck <alexander.duyck@gmail.com>, 
 Nitesh Narayan Lal <nitesh@redhat.com>,
 kvm list <kvm@vger.kernel.org>, David Hildenbrand <david@redhat.com>, 
 "Hansen, Dave" <dave.hansen@intel.com>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
 Andrew Morton <akpm@linux-foundation.org>,
 Yang Zhang <yang.zhang.wz@gmail.com>, 
 "pagupta@redhat.com" <pagupta@redhat.com>,
 Rik van Riel <riel@surriel.com>, 
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 "lcapitulino@redhat.com" <lcapitulino@redhat.com>, 
 Andrea Arcangeli <aarcange@redhat.com>,
 Paolo Bonzini <pbonzini@redhat.com>, 
 "Williams, Dan J" <dan.j.williams@intel.com>,
 Alexander Duyck <alexander.h.duyck@linux.intel.com>
Subject: Re: use of shrinker in virtio balloon free page hinting
References: <20190717071332-mutt-send-email-mst@kernel.org> <286AC319A985734F985F78AFA26841F73E16D4B2@shsmsx102.ccr.corp.intel.com> <20190718000434-mutt-send-email-mst@kernel.org>
In-Reply-To: <20190718000434-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/18/2019 12:13 PM, Michael S. Tsirkin wrote:
>
> It makes sense for pages in the balloon (requested by hypervisor).
> However free page hinting can freeze up lots of memory for its own
> internal reasons. It does not make sense to ask hypervisor
> to set flags in order to fix internal guest issues.

Sounds reasonable to me. Probably we could move the flag check to
shrinker_count and shrinker_scan as a reclaiming condition for
ballooning pages only?


>
> Right. But that does not include the pages in the hint vq,
> which could be a significant amount of memory.

I think it includes, as vb->num_free_page_blocks records the total number
of free page blocks that balloon has taken from mm.

For shrink_free_pages, it calls return_free_pages_to_mm, which pops pages
from vb->free_page_list (this is the list where pages get enlisted after 
they
are put to the hint vq, see get_free_page_and_send).


>
>
>>> - if free pages are being reported, pages freed
>>>    by shrinker will just get re-allocated again
>> fill_balloon will re-try the allocation after sleeping 200ms once allocation fails.
> Even if ballon was never inflated, if shrinker frees some memory while
> we are hinting, hint vq will keep going and allocate it back without
> sleeping.

Still see get_free_page_and_send. -EINTR is returned when page 
allocation fails,
and reporting ends then.

Shrinker is called on system memory pressure. On memory pressure
get_free_page_and_send will fail memory allocation, so it stops 
allocating more.


Best,
Wei

