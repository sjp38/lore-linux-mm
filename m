Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A117C74A5B
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 16:45:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD3E1206B8
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 16:45:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD3E1206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BA908E00EE; Thu, 11 Jul 2019 12:45:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 76B5D8E00DB; Thu, 11 Jul 2019 12:45:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60C5A8E00EE; Thu, 11 Jul 2019 12:45:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2AFA78E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 12:45:14 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id s21so3541182plr.2
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 09:45:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=4XO1Nm+FLfUg5JQKhSWY1g4GlpGzgqqnqNsVify9SRE=;
        b=r5UafmX20HQhYoLj3B1zA5YoecNEs/M+IHhXp0ws71yTeVF4WITgVooMXHmG5Z3W6d
         jGiE0JN0088cCTa6FAxYKhD2+6eft0pRXPugbZsM26CLxxwg/vRdnPjcGsSSuanmG464
         lwgh59oitlv+u0H2u6u4fVkPrAwMlUwsEHCYs38Tk/fVybF3AGCx6ctE6lyt3i+fuz6v
         EbFDUR3176LO1n8JaHbC81JzkdLZR7EFjTM2Lg2dFK2C4DgoukdPf/1jk4Nx1G8vZiO5
         OOm+gmkGblGwkCYMZSzpxEzTALB29OHNYXp/L/q+eql68nOeiCGy6IyUk/hliAgnJpmb
         OKzw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX/yv+Y3foEaMW1TQibUficNxKQ66E9U6A5pGuvsQoC1+XlidbD
	eJqKj2abZ1PLJIiBxdPaYUlI2YCifDp6vce0gn3V8IL6rlJFp6qOGP7DStQqQAC3YZASFdtvqXV
	+d/PLjPxBoHiuxFREA/MRD6+wBu3+QmRIKksCXniRMuJFiXiBXtIC2zkIBEutxPrQvw==
X-Received: by 2002:a65:4347:: with SMTP id k7mr5448265pgq.253.1562863513714;
        Thu, 11 Jul 2019 09:45:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjf5KFtiaMqizBz3YY1efUVfh2UWsDRR+kzgVchRW3jIea98b49gpJMZr7bUg0mxeltZ9W
X-Received: by 2002:a65:4347:: with SMTP id k7mr5448213pgq.253.1562863513057;
        Thu, 11 Jul 2019 09:45:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562863513; cv=none;
        d=google.com; s=arc-20160816;
        b=h50OGMQSm0OhKXwj9GAQgaf7uX6cXmR4y0Eq47iBJCGN1Nd30ayMNRd+zaGG1qGDwu
         3b5DcnCsUW+6VMb4DNcbp8fu4aDS9d+cT/hYHCvPI+ApQybwDL7sWKeiuHvl6l9gRT0X
         QLKXVt0cFg8Y40VjOAuW9XCRcsUQlWcEtkveJnzJT0ihBGFeFB3yhTCyJNB53Gdy8oay
         FTy1klo1GUvQF+T9MDGjOCWzjmlDpI1YMv68tGeWXZLu40Dp7npSZj/NdcxLFWIFHdrp
         9VGbqNw0DcrTwuNB11xnMKeAXeqo47UR1nqBzjQ5F7n9ShpXjvWfzFCAn3c0Etfurl8s
         /KLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:to
         :subject;
        bh=4XO1Nm+FLfUg5JQKhSWY1g4GlpGzgqqnqNsVify9SRE=;
        b=dPHXxYUuTqV7xe4V1LLH+CMTuamF9hf4oXGeVtCsSKszw6kAcA8n+bS4BMerQUolKh
         br8BEcyWE0DkPojaIRcUHvMqggF6jjfukGz296Vnzwxz+JHJIxN11+yHcr5rDBfudSMi
         10yXAkS+/Auii7yqScqSKwQl1ModplEvYIW8EyP4clsLSu+epAePl2zkbW4DAx4wIxXg
         TE3OuPSEjAk7kbHe3mkAXM8S4/H3952bHmNLxPf94x06GUi4Bq3fy+ssg8Sz+LoeLVNT
         pYkKGJ3UJ5vtLp4U3ikNMJVXM/vQF6NKXOLau8QhE9WOBoshgN7X9aDWRy+xBmsbJYBQ
         hq8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id j191si5438607pgc.73.2019.07.11.09.45.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 09:45:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Jul 2019 09:45:12 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,479,1557212400"; 
   d="scan'208";a="177221572"
Received: from unknown (HELO [10.7.201.139]) ([10.7.201.139])
  by orsmga002.jf.intel.com with ESMTP; 11 Jul 2019 09:45:11 -0700
Subject: Re: [RFC][Patch v11 1/2] mm: page_hinting: core infrastructure
To: Nitesh Narayan Lal <nitesh@redhat.com>, kvm@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, pbonzini@redhat.com,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 yang.zhang.wz@gmail.com, riel@surriel.com, david@redhat.com, mst@redhat.com,
 dodgen@google.com, konrad.wilk@oracle.com, dhildenb@redhat.com,
 aarcange@redhat.com, alexander.duyck@gmail.com, john.starks@microsoft.com,
 mhocko@suse.com
References: <20190710195158.19640-1-nitesh@redhat.com>
 <20190710195158.19640-2-nitesh@redhat.com>
 <3f9a7e7b-c026-3530-e985-804fc7f1ec31@intel.com>
 <0b871cf1-e54f-f072-1eaf-511a03c2907f@redhat.com>
 <c41671f0-2080-b925-39e2-79e33a84088b@intel.com>
 <fd49381e-cdfa-7ac9-e938-ac790995df24@redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <719ac813-01d7-7602-0951-6c90f1f7efc1@intel.com>
Date: Thu, 11 Jul 2019 09:45:11 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <fd49381e-cdfa-7ac9-e938-ac790995df24@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/11/19 9:36 AM, Nitesh Narayan Lal wrote:
>>>>> +struct zone_free_area {
>>>>> +	unsigned long *bitmap;
>>>>> +	unsigned long base_pfn;
>>>>> +	unsigned long end_pfn;
>>>>> +	atomic_t free_pages;
>>>>> +	unsigned long nbits;
>>>>> +} free_area[MAX_NR_ZONES];
>>>> Why do we need an extra data structure.  What's wrong with putting
>>>> per-zone data in ... 'struct zone'?
>>> Will it be acceptable to add fields in struct zone, when they will only
>>> be used by page hinting?
>> Wait a sec...  MAX_NR_ZONES the number of zone types not the maximum
>> number of *zones* in the system.
>>
>> Did you test this on a NUMA system?
> Yes, I tested it with a guest having 2 and 3 NUMA nodes.

How can this *possibly* have worked?

Won't each same-typed zone just use the same free_area[] entry since
zone_idx(zone1)==zone_idx(zone2) if zone1 and zone2 are (for example)
both ZONE_NORMAL?

