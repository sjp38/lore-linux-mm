Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7393BC76196
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 06:24:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 27CC3204FD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 06:24:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27CC3204FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A11F6B000A; Thu, 18 Jul 2019 02:24:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 752508E0003; Thu, 18 Jul 2019 02:24:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 619D78E0001; Thu, 18 Jul 2019 02:24:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2AC6C6B000A
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 02:24:30 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id u1so16084186pgr.13
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 23:24:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:user-agent:mime-version:to:cc:subject:references
         :in-reply-to:content-transfer-encoding;
        bh=wlt7IgxhDbN6y+nDGBuY58WV4H+ze496zzF13EIGCbQ=;
        b=SCj9o4eQ5U/n7q66gJlwukmvRmeirCOjl/v7gekcYxLtWcJdb5Hv5M22UZYuV7mJlD
         dVVC8XYWts26+S74ybC3D5gKXT741yPBHCwuYiLM4v6158gLIeZHDYKcZ3JY4GIdjhk+
         7GTToCSgl7j9upKtsYI8AyZ808N7KL+ucay6aFKdO2OlC/co0/Bx3nz/daq3xpat5XsR
         ypIUJOu67C2PFcAmSzf0Y+anWKnbsBKMv0BKWhNB+wObAv54icpE4ADC63KaJORMRByh
         nfjhry5lC6bSp1KssH7Ysb8Sd4GI6fjT8XAns5o6zCIvVxKz2N+NYAihS2N+gX3Yrh/Z
         O0Vw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of wei.w.wang@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=wei.w.wang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUM1ZOgHpEMq/m+pa6JpDZdIk+BA1c+zkyh6EVAqA9DqIc4HXdW
	R4A9xkHfMsMXsXumCcsjBdHCCLu2kabu6/m+CAYxUlsW4IdEVMm1IfVBUFV0AlI31/2Ks+RNK/F
	7cDE03XLQu3+mh3DqGe5kaeZuoIBc7Tb0mUTfpBhApU55HIxeo8RUqt7aeii6I+/TRQ==
X-Received: by 2002:a17:902:2d01:: with SMTP id o1mr49158110plb.105.1563431069804;
        Wed, 17 Jul 2019 23:24:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyGiQeHD6Ro1lAZmsPzKfn1/wGufQDwDwH0tQJXbmZym+G7k66VKv/bIBTB0Z15DJQAWldn
X-Received: by 2002:a17:902:2d01:: with SMTP id o1mr49158068plb.105.1563431069154;
        Wed, 17 Jul 2019 23:24:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563431069; cv=none;
        d=google.com; s=arc-20160816;
        b=KDz/fBCflJwQ3S7DICQvNaYNwjt+JysTnF/M1pMJjnbpk44K0K3hSEA19JLFj9o5zt
         05MnIEp3It8HvF5D5n0M8secSErkmQ0l7g1jbdh25KOWVnVz6EETuYHAqHy954ToY9Dx
         k4N/KlYh2GF3J7pASRK8fd0UrzlNsOlsjo0Mw10FJow/bURPSd2/TodY1sncrYeSRIoO
         LZfQFbmUAG73fO5llkkUw2PDUCs+HjPQ6d9SOlrQXf5TbEpkFGOE2p9IS8eudo5F/CW2
         miut30+xM6kpmDuieROV9OYO7OtIy9OEYGxm1ja4NiKeJPNCs0NTikrhDWRYC2MWSky8
         8YTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:subject:cc:to
         :mime-version:user-agent:from:date:message-id;
        bh=wlt7IgxhDbN6y+nDGBuY58WV4H+ze496zzF13EIGCbQ=;
        b=z2lqXbItwJ1J81XKnpyGNQ7fbfawQ4+9lSpbq63V6C+viO2YCGFOw+b/0p8LoWae1G
         GgL21gDREvu3tfh0FdjqDx1DdZQJa+clL6qeJRfnaNMNwiZ82YVPQmEXQiJoMd2jRKxL
         nGm4wnAFKXTR2qGIzFNWxWhTOARyMvKfVjz1vQrhTgyX0VMJY2nK/bWaHCAEZ0R9yrfH
         V02ptCWrfdMT4jd2+TtunY7pmIqDbzMNhTbDHhr89bIHW1kEd2m+JP1omd4/E4Jk1dgY
         Zr4M5MDX8ksU+4nhS0Q77a5sXWrtnezEFz6PbxjpN90dhSJLiAM3ah9INlzxSAgChZQq
         mvQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of wei.w.wang@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=wei.w.wang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id b92si684669pjc.17.2019.07.17.23.24.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 23:24:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of wei.w.wang@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of wei.w.wang@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=wei.w.wang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Jul 2019 23:24:28 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,276,1559545200"; 
   d="scan'208";a="191506353"
Received: from unknown (HELO [10.239.13.7]) ([10.239.13.7])
  by fmsmga004.fm.intel.com with ESMTP; 17 Jul 2019 23:24:25 -0700
Message-ID: <5D3011E9.4040908@intel.com>
Date: Thu, 18 Jul 2019 14:30:01 +0800
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
References: <20190717071332-mutt-send-email-mst@kernel.org> <286AC319A985734F985F78AFA26841F73E16D4B2@shsmsx102.ccr.corp.intel.com> <20190718000434-mutt-send-email-mst@kernel.org> <5D300A32.4090300@intel.com> <20190718015319-mutt-send-email-mst@kernel.org>
In-Reply-To: <20190718015319-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/18/2019 01:58 PM, Michael S. Tsirkin wrote:
>
> what if it does not fail?
>
>
>> Shrinker is called on system memory pressure. On memory pressure
>> get_free_page_and_send will fail memory allocation, so it stops allocating
>> more.
> Memory pressure could be triggered by an unrelated allocation
> e.g. from another driver.

As memory pressure is system-wide (no matter who triggers it), free page 
hinting
will fail on memory pressure, same as other drivers.

As long as the page allocation succeeds, we could just think the system 
is not in
the memory pressure situation, then thing could go on normally.

Also, the VIRTIO_BALLOON_FREE_PAGE_ALLOC_FLAG includes NORETRY and 
NOMEMALLOC,
which makes it easier than most other drivers to fail allocation first.

Best,
Wei

