Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5038C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 20:40:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E9B22054F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 20:40:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E9B22054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 29C026B0007; Wed, 27 Mar 2019 16:40:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 24BF96B0008; Wed, 27 Mar 2019 16:40:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 112F76B000A; Wed, 27 Mar 2019 16:40:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id CC6946B0007
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 16:40:13 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i23so14929052pfa.0
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 13:40:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=1G96h0P5hqT/VXYyr9nVI0aX7uRGU/uCdlCYoJ7ONkI=;
        b=Hyb8tQloGJfs+Vh88eGwGOcNU0QAxVETTEjb9MtZm5J5ix2wBnQ72FrY/tRydGA654
         l4yIlNHi65G1pRlokMBC36gpBK7k9hSdiDjF86ZIeSB7G/BqABdVUYWI4AgJhHXDZ7uT
         JfkgDfR7Ybq5uaHpmQyoHLueBkCfduc5knTQSnMMgZb/wGN/JHHZQmZZbIibpVnoQPZZ
         MQrfbMnairAWTA3Yo/pkZG2W9nBPt8+8xX7usASDy6IQ9COoN7v24CN3FIXOsrC4L45w
         ZrvvnEs3JFElVrV87gAFP3FdUElt9iljb7VQ+AUd4kG5gHYT+i66zV8GLbXSMviYpsM8
         yZzw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWmNnpq31VLvzy/IxktEXxR/+XzSciyh51PKcyVouI4PjKDHlEG
	H4JJNFoAdJs1PppmHTkYLxXjHgf5a+6OiNNv2dZz0olwFFrMxxEHFBBB6zyfZJnucFwYpZNnVH8
	/1RIhkoGayyv6Je/x2PySKFjWASNO4TzejPiDp0Ech9oYBy+GSu0m/VN3tDkZCb6v7g==
X-Received: by 2002:a63:f218:: with SMTP id v24mr16400997pgh.326.1553719213507;
        Wed, 27 Mar 2019 13:40:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqygrXdTCj8E+VA1npgjusCgNNnZLwPi8QOObSaXSM+WaXG8J4TkkwYWwh5lZfLc1Jso6/h2
X-Received: by 2002:a63:f218:: with SMTP id v24mr16400964pgh.326.1553719212906;
        Wed, 27 Mar 2019 13:40:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553719212; cv=none;
        d=google.com; s=arc-20160816;
        b=lEsLLo8SzCRHjt5gxyHySnqQqyhy6rLxdVf5r8Vushq2OalpCYEKEBEWRBvT1zQ+Xb
         ct3q8EUaKz3xcZQ+2xWCLLSzeco7IYWSka+6RoMevB3xbxvcCy2sQNM7mq1c2eSy21B/
         uRbVpt3955Rsm9XocHnBi6wuszCuJo32Y40egDax/ZWAN6qfb9yQxwiX/GDw48dKokrA
         iBHrDwELmFEOjMC6C+Snha9H7yyu2duHvNrtdVYZrtdcS7A/OCcbt9tVKMxA3LPPlNdV
         R0Fdg5ghAMnaKpJ4VxOI0FGqVivjbu1gRpYHnUXgZ6HtcRw6ftCaCsVj6ZwUm2HF/efn
         iPAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=1G96h0P5hqT/VXYyr9nVI0aX7uRGU/uCdlCYoJ7ONkI=;
        b=koB4RWEVwSnDwayJhm4cdYpmPxQCw5TYnUqgCgf3bdeuIX84sUC40m5toZQFjK6K0l
         Y8PrqLuUYfeQhJd4BSbR8rm8EnsHovpNCZtvGYjkhykC+3BmmEph2h0pv2ZjT/k233f/
         7gTOH66uWV16vF7gvqlYuV1Ir1Kv63ZPWbeE+jeeG9WlhPW3dj48pJ1DN1r7vCZ+cgI1
         3+KzlCv8UL3DxjyubawDtXhmEb70T+tfBhAFSqp89OhmGapQLTZ3N3rckrCqY+Ounhks
         vsRptgHKfG3PlLDhVgRp/W5iQ276D9iAEwQ8txYROMVYPgk04VlhzKwRPgmh5FpBzuom
         5msg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id j36si14801338plb.327.2019.03.27.13.40.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 13:40:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 27 Mar 2019 13:40:09 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,277,1549958400"; 
   d="scan'208";a="310943635"
Received: from ray.jf.intel.com (HELO [10.7.201.126]) ([10.7.201.126])
  by orsmga005.jf.intel.com with ESMTP; 27 Mar 2019 13:40:07 -0700
Subject: Re: [RFC PATCH 0/10] Another Approach to Use PMEM as NUMA Node
To: Matthew Wilcox <willy@infradead.org>,
 Dan Williams <dan.j.williams@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, Yang Shi <yang.shi@linux.alibaba.com>,
 Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@surriel.com>,
 Johannes Weiner <hannes@cmpxchg.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Keith Busch <keith.busch@intel.com>, Fengguang Wu <fengguang.wu@intel.com>,
 "Du, Fan" <fan.du@intel.com>, "Huang, Ying" <ying.huang@intel.com>,
 Linux MM <linux-mm@kvack.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190326135837.GP28406@dhcp22.suse.cz>
 <43a1a59d-dc4a-6159-2c78-e1faeb6e0e46@linux.alibaba.com>
 <20190326183731.GV28406@dhcp22.suse.cz>
 <f08fb981-d129-3357-e93a-a6b233aa9891@linux.alibaba.com>
 <20190327090100.GD11927@dhcp22.suse.cz>
 <CAPcyv4heiUbZvP7Ewoy-Hy=-mPrdjCjEuSw+0rwdOUHdjwetxg@mail.gmail.com>
 <20190327203520.GU10344@bombadil.infradead.org>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <7cb4e229-a1a9-e236-f806-926351a917cc@intel.com>
Date: Wed, 27 Mar 2019 13:40:07 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190327203520.GU10344@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/27/19 1:35 PM, Matthew Wilcox wrote:
> 
> pmem1 --- node1 --- node2 --- pmem2
>             |   \ /   |
>             |    X    |
>             |   / \   |
> pmem3 --- node3 --- node4 --- pmem4
> 
> which I could actually see someone building with normal DRAM, and we
> should probably handle the same way as pmem; for a process running on
> node3, allocate preferentially from node3, then pmem3, then other nodes,
> then other pmems.

That makes sense.  But, it might _also_ make sense to fill up all DRAM
first before using any pmem.  That could happen if the NUMA interconnect
is really fast and pmem is really slow.

Basically, with the current patches we are depending on the firmware to
"nicely" enumerate the topology and we're keeping the behavior that we
end up with, for now, whatever it might be.

Now, let's sit back and see how nice the firmware is. :)

