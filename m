Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA487C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 15:55:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C7B0204EC
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 15:55:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C7B0204EC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D2B9F6B027E; Tue, 16 Apr 2019 11:55:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDC336B0287; Tue, 16 Apr 2019 11:55:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA4456B02A8; Tue, 16 Apr 2019 11:55:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8177D6B027E
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 11:55:43 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id b34so13620320pld.17
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 08:55:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=qJ6C1eFWkhYFFNQB8NaXXc/zpdS/YAoYf4VberI1jvY=;
        b=aQG6EDE8IMj59h+3BBApQ49utcMYD5j6sZsF+XBNs7PzHwTGIxzYL724CSZqujKOCb
         xHV1R2bilxVCpzQjAODqyTTIiaMTCb5TJddtocnPwsJMCoFZoRPVv8fWDIBL028R2Vl9
         b5odtemA9mOR5z4fZTRlHl8zIvZZ+Cw9/SQeYFajumuuVKdaZv7KHSVIOM4XdYY1ac6F
         4B4HxDqnNIwBM8zghGXo3GQ/VA6yqrUC32rpC4jPIlbmbk09svW4tRXraPXfzZik40T1
         vfNuDOw3tizGugHvnV72LEBjnyAlnCAa14iE2/3uZbGBRBz32vyBiLvHZ1ZylT301TU/
         6ZoA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX552xE0BQATcRRqJsPqxaEqSnzDFZxoa+Ae9QRhOCk34LmKho8
	r5geA6Uf7hnhgJsnoVuXTl6eo+e7Wq3qhVHWhMGVSrMXvmn6aG3NC4rA6HUV1sJuEqQy+dI4W2C
	Tx54p/A4V7fjD88moABPPJGsVuKuC0eqaQl6anC1q5IixY84AJdW5GBB5xyv3b9uZ+Q==
X-Received: by 2002:a63:b811:: with SMTP id p17mr77443187pge.219.1555430143024;
        Tue, 16 Apr 2019 08:55:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxuUbrlPkepLXHsWF0ieTAY/jVuE0smzsJGJiXa6SkXAVrWOwmhzIhy8JDtX5iTxV94ONNX
X-Received: by 2002:a63:b811:: with SMTP id p17mr77443146pge.219.1555430142429;
        Tue, 16 Apr 2019 08:55:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555430142; cv=none;
        d=google.com; s=arc-20160816;
        b=0Tem5NZnkJUhUsD3q2jH+SzmTl+eOBTjEV04Q4ZKb6wIR7CBvsJR911yFRF9T8UoVS
         Mai7yuyuRlRPHUHdfEOmPAEic+UXMwjXXXhaNJ2KkxzCjbKtc922nN1rOnw3L2EbNwS6
         b10fSOZc2TAxMVmTjcxAUfIEB+UKZMTbGxrjGGsQV2QNq7u79KGXeiI62+GDwsgiMDVB
         xyKAqsZhru1c+mTnULD86k5MwVlr2FFcmEEZpMKz6NerD4896WRh7hLke9Qz+sWYTMJ5
         UldTd0+R1tl6C5C8/iIoXfhcZlyB+pqfCwPsilqQqptFpHkxrLyi9XYDTjZi2qqMh+Ht
         MlJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=qJ6C1eFWkhYFFNQB8NaXXc/zpdS/YAoYf4VberI1jvY=;
        b=dr8cB8eOyQZqKZQFBgazuMyV3a5Wzr0K7tMwj+EtlHri0IzdNdOetNYK0wiyyxuExJ
         6GTuWMMrTF4jJpr2AJ5AYuhDAddk/dvMPKpuXoV40YGOhg1bcu/m/rkS1aaE4JkjKnQW
         orGr4xFskUFbeDtBp/NGXGqjP2ZmworHu96V+g+0Z103hPy4YrE3jTsZJLF6/607JQ8X
         jav77ZLfhclb9+vnBf65WXEzqx+G6Ha1BGHOcStsq/CDKlRcC4YGo53msBc2lA48iFVN
         4C16/UKLRbZW425k/C2JH86cbOjtaXAhE9PPYje8YfZrecFTQ8YcHbdKPbK7pPuAQIpU
         a3mA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id r4si48680706pgh.171.2019.04.16.08.55.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 08:55:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 16 Apr 2019 08:55:42 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,358,1549958400"; 
   d="scan'208";a="292048862"
Received: from ray.jf.intel.com (HELO [10.7.201.126]) ([10.7.201.126])
  by orsmga004.jf.intel.com with ESMTP; 16 Apr 2019 08:55:41 -0700
Subject: Re: [v2 RFC PATCH 0/9] Another Approach to Use PMEM as NUMA Node
To: Zi Yan <ziy@nvidia.com>
Cc: Michal Hocko <mhocko@kernel.org>, Yang Shi <yang.shi@linux.alibaba.com>,
 mgorman@techsingularity.net, riel@surriel.com, hannes@cmpxchg.org,
 akpm@linux-foundation.org, keith.busch@intel.com, dan.j.williams@intel.com,
 fengguang.wu@intel.com, fan.du@intel.com, ying.huang@intel.com,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190412084702.GD13373@dhcp22.suse.cz>
 <a68137bb-dcd8-4e4a-b3a9-69a66f9dccaf@linux.alibaba.com>
 <20190416074714.GD11561@dhcp22.suse.cz>
 <b9b40585-cb59-3d42-bcf8-e59bff77c663@intel.com>
 <960F3918-7D2C-463C-A911-9B62CD7E5D83@nvidia.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <63514bdd-313b-d42f-e582-f8cb350d0b35@intel.com>
Date: Tue, 16 Apr 2019 08:55:41 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <960F3918-7D2C-463C-A911-9B62CD7E5D83@nvidia.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/16/19 8:33 AM, Zi Yan wrote:
>> We have a reasonable argument that demotion is better than
>> swapping. So, we could say that even if a VMA has a strict NUMA
>> policy, demoting pages mapped there pages still beats swapping
>> them or tossing the page cache.  It's doing them a favor to
>> demote them.
> I just wonder whether page migration is always better than
> swapping, since SSD write throughput keeps improving but page
> migration throughput is still low. For example, my machine has a
> SSD with 2GB/s writing throughput but the throughput of 4KB page
> migration is less than 1GB/s, why do we want to use page migration
> for demotion instead of swapping?

Just because we observe that page migration apparently has lower
throughput today doesn't mean that we should consider it a dead end.

