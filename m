Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2B10C76191
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 09:03:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7794A2173E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 09:03:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7794A2173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2231C6B000C; Thu, 18 Jul 2019 05:03:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1AD716B000D; Thu, 18 Jul 2019 05:03:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 04DFA8E0001; Thu, 18 Jul 2019 05:03:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id BB77D6B000C
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 05:03:09 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id r7so13609323plo.6
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 02:03:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:user-agent:mime-version:to:cc:subject:references
         :in-reply-to:content-transfer-encoding;
        bh=BTlwn7b9X7fbmiqyeyhke/PgaxZPsryoucFSrzo/MtM=;
        b=Echxc7fBPL/UrhY4mlJQQlPiLoGTSLi2QUSV0FhQ83MiQCpPd/y5rr2g/6nL2LFSC1
         FCqEchBk8hyeEe1+q3e7aFODH7V58NFyQVzKrQLNP86eA0BszEeC8NClTERGFZUD0BAI
         1VQekDqcAzaS4PjBRCHfhM7/Vnb+rJZfPtwi+I/grQHyPle/oDCKsLLgQjsidg8R51KP
         wzAD0Ds1P/2oxJe2JiZUO+hpqFYWPlBQTIox7KGV9wdBSGy0sHBQFrkplaByhQ/GupL4
         Pc5V7blvYyF9qkIWCIgvHf0n+X8XK5NYALtJsIFpZdWo4E0oVBfk0SXZg4WjT+ijHMoj
         1FIA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of wei.w.wang@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=wei.w.wang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXGE/6PGvK/8gB9UhI+D/f2ip5JJ9ewPWJfm41M25NTFU8NHl/r
	27RFaZwtM0c09Hi0a41MhsIoDuSQCL1ij7YZTp1VpwRDugci+DYJfYjve694YY4ZrBFTBxcQGPB
	d8A+JZdLDUVXkflxrQ2eahuSNEML8T5W51ZfCxMYvsZkZga8H6ESSaZGqg3ZcPtE9dA==
X-Received: by 2002:a65:4505:: with SMTP id n5mr6695113pgq.301.1563440589323;
        Thu, 18 Jul 2019 02:03:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz3vu+gqWbOlxnUKDhjJjC1zKQxeEwep5DxHKpSGLBb/wKcF9FUE46oGzRzR9hkie0JW6r3
X-Received: by 2002:a65:4505:: with SMTP id n5mr6695041pgq.301.1563440588540;
        Thu, 18 Jul 2019 02:03:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563440588; cv=none;
        d=google.com; s=arc-20160816;
        b=R6VbiFmaCPuEKb0VIy4VfuTHgZ0/ORc30Xh80Bb8RWEzMR+2F3wTi0d6ta56ZhqSLj
         thuwH+AfAnv4OH4Olms57Auf+vmJyRdv5YNrhGCtjZTBlo5RGj08Y78sgqbqfPo2Vr7m
         8xohxoJQrYoD5/dqx7BQMCZlarNL1iwM21HUYTBL7JYwzTKmbPSR8Camg6qa1V/8LrW2
         QNUvteQ1ROm/257GZNpAvAMnRK+RGCrNVRcVwDU7cCPI9PrhN8HIJ25qmnlpwehVS2i2
         7xSVVi2RnS2SeuTEg++CQwCAayeQ0WAtJ6I6KKvq5tMAMWip9n+Pq/NBf3iKLJdBWOWs
         uYSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:subject:cc:to
         :mime-version:user-agent:from:date:message-id;
        bh=BTlwn7b9X7fbmiqyeyhke/PgaxZPsryoucFSrzo/MtM=;
        b=IV84vF5bBBoo5Pf/w6104wVGp8Yx9omyRvPDrsinX212PBZ6KssiWc9+Wag4/Wz9JE
         krGqo8IHTgdG+qJtCKf7lgdSa3O5R1O4YwKeos3QmGhOYFy927GNHtdEMJbtzob64Alk
         IWa7X7rpSQLgdbltThaRlGxLS7puE0g2HL4n4c3Qnad7cf2UzU0p+jBPVSZLCNcDi4gY
         tt1xfDIO//S/PjP3HAsbjFF/Ih6MVPJy7QXaxvdFj1a9eCiyxEzSG7V+ko0Z7t7XwUzU
         RfuBJdZMtSCV9XxQQIknw/jSPl20dmCpREkov3SxzgdigqXJNlqLzo7Hw07P+CdxKMos
         9tLw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of wei.w.wang@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=wei.w.wang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id o11si1409387pjb.30.2019.07.18.02.03.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 02:03:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of wei.w.wang@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of wei.w.wang@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=wei.w.wang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Jul 2019 02:03:08 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,276,1559545200"; 
   d="scan'208";a="187751473"
Received: from unknown (HELO [10.239.13.7]) ([10.239.13.7])
  by fmsmga001.fm.intel.com with ESMTP; 18 Jul 2019 02:03:05 -0700
Message-ID: <5D303719.3060900@intel.com>
Date: Thu, 18 Jul 2019 17:08:41 +0800
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
References: <20190717071332-mutt-send-email-mst@kernel.org> <286AC319A985734F985F78AFA26841F73E16D4B2@shsmsx102.ccr.corp.intel.com> <20190718000434-mutt-send-email-mst@kernel.org> <5D300A32.4090300@intel.com> <20190718015319-mutt-send-email-mst@kernel.org> <5D3011E9.4040908@intel.com> <20190718024408-mutt-send-email-mst@kernel.org>
In-Reply-To: <20190718024408-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/18/2019 02:47 PM, Michael S. Tsirkin wrote:
> On Thu, Jul 18, 2019 at 02:30:01PM +0800, Wei Wang wrote:
>> On 07/18/2019 01:58 PM, Michael S. Tsirkin wrote:
>>> what if it does not fail?
>>>
>>>
>>>> Shrinker is called on system memory pressure. On memory pressure
>>>> get_free_page_and_send will fail memory allocation, so it stops allocating
>>>> more.
>>> Memory pressure could be triggered by an unrelated allocation
>>> e.g. from another driver.
>> As memory pressure is system-wide (no matter who triggers it), free page
>> hinting
>> will fail on memory pressure, same as other drivers.
> That would be good.  Except instead of failing it can hit a race
> condition where it will reallocate memory freed by shrinker. Not good.

OK..I could see this when another module does allocation, which triggers 
kswapd
to have balloon's shrinker release some memory, which could be eaten by 
balloon
quickly again before that module takes it, and this could happen repeatedly
in theory.

So add a vb->stop_free_page_report boolean, set it in shrinker_count, 
and clear it in
virtio_balloon_queue_free_page_work?

Best,
Wei

