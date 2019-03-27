Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F4208C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:00:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB5DD2075C
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:00:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB5DD2075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4BF6D6B0005; Wed, 27 Mar 2019 14:00:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 446D86B0006; Wed, 27 Mar 2019 14:00:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2998F6B0007; Wed, 27 Mar 2019 14:00:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id D54696B0005
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:00:35 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id t1so4797967plo.20
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:00:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=CBNCzVNIvTqCB3OZOVVudHly2Nr/DdQMa5Qs+VDAIgo=;
        b=UMyLx9AwFeIcYXgjPHZO8/mjLBmPMqNBsuzKBi3Jb/IeBxpEyT5Uxni18+HSSrSnV/
         Pz5A2MmrPSzsJDFrE6QMk5fQ5fvIJw9dVqAF1S2HDnlczFNFvbv5JaH0aUr5NYb/WKoQ
         vzdKBFHNGSRpwudRXLRp/UU8lF0SFImLAqM943MyVupm/6jSoQecGUqKGwPgVN0cYGyU
         xS10yRrmdkTrUqWrnwgWixxC4CeZMqYk8kA53WBuTjpS5VYszCgVhzuJuM7pj+wrYSR4
         B+Xi4r7Hu++GAoNSl+FnY9cXvtXbaFYEgtBDju9xzWeo/JNLO59ms9L0WA54jQY460e2
         Ho1Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV0E/ED89ld+j8/XCOCZkqgDzgSqiMPGCq9/iQ8wIRHfI8ZYlFv
	Uo8wDpc5BSgExv4BYb7/PfhuNpoFB7S3702Ow3OW3n1t0UNlFs3BrTMSuiEBuYSZ8Kp3DV5HbqY
	0U8Wu36Zz0jNoydLtk+XfhdymPqlzNk6TpZn1XNhLeLJJtswNc/yLCyu6W0EBfUubLg==
X-Received: by 2002:a62:3585:: with SMTP id c127mr36072025pfa.71.1553709635533;
        Wed, 27 Mar 2019 11:00:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyVsHmVwTVyC+ip5/n54Xgdvv++qpz9Hl33fCyT8kmTWHdvwC7iv7xxwOj9zzP2jEFEw+Ax
X-Received: by 2002:a62:3585:: with SMTP id c127mr36071950pfa.71.1553709634725;
        Wed, 27 Mar 2019 11:00:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553709634; cv=none;
        d=google.com; s=arc-20160816;
        b=PIIto+/ovU3x/Th+a0CyY3xYhW29z/62NIIGA+V4+h/gY1hyycO5Cobz/C+PyqzEt3
         mr2AfvY+Re+qEapfjHxhXgxabKgYYODlihTu4F8WfViDMaxUTOUB8iOlH6l9lxVixP3w
         NRdMPQrR54GEj39s0RLJE5piBwjU0pjkcRUxIbDUY4OnlDQ9zvq5aEUfUTKcNOmEX4NE
         0nxLBky4jZpuGBDa0xy6/zCDtKZtlUjsguTl0++YhQ5i/4+kBErVdV2W5pXex9cmbvI2
         VALECkfxFsGGSr+lr66RoJK0FKoW008D4bHDBvyllQAH7lYnhzooKQAQlmQX6UpPxqK3
         eEtQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=CBNCzVNIvTqCB3OZOVVudHly2Nr/DdQMa5Qs+VDAIgo=;
        b=ve/0+CG7PdvXWhrj2de1P68kMxTxh8bHNx6iU112iL9tq+hRdLMnhG39uTLLRZ+rMe
         NmOQdrEfF0yPS4QXnm+VHwOZyKG/+8p592rznXShENIfDP06LLSYRSykwlmp7GYk9UOl
         iMhz2vD4yvcD9L65Vk/KCSxGOkh+L8U3hX+RQgy9VK8hmysK4pVLwpMna5JVF7YJCoWb
         hjArTd5B5Gd0Atm/bpODscPou76txLG8/65BsQmGpIkkZRY8wz+BP1/ak1W3Q9bfUvvd
         UVJc2QqT9CbJMMY9kYTp9oHIVqMAxWXfXQXjrYYpVgLcc2wcLHnX01DZ7z87CPEePUQq
         o3gA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id f7si15199349pgg.234.2019.03.27.11.00.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:00:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 27 Mar 2019 11:00:33 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,277,1549958400"; 
   d="scan'208";a="310907171"
Received: from ray.jf.intel.com (HELO [10.7.201.126]) ([10.7.201.126])
  by orsmga005.jf.intel.com with ESMTP; 27 Mar 2019 11:00:32 -0700
Subject: Re: [PATCH 06/10] mm: vmscan: demote anon DRAM pages to PMEM node
To: Zi Yan <ziy@nvidia.com>
Cc: Keith Busch <kbusch@kernel.org>, Yang Shi <yang.shi@linux.alibaba.com>,
 mhocko@suse.com, mgorman@techsingularity.net, riel@surriel.com,
 hannes@cmpxchg.org, akpm@linux-foundation.org,
 "Busch, Keith" <keith.busch@intel.com>,
 "Williams, Dan J" <dan.j.williams@intel.com>,
 "Wu, Fengguang" <fengguang.wu@intel.com>, "Du, Fan" <fan.du@intel.com>,
 "Huang, Ying" <ying.huang@intel.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
 <1553316275-21985-7-git-send-email-yang.shi@linux.alibaba.com>
 <20190324222040.GE31194@localhost.localdomain>
 <ceec5604-b1df-2e14-8966-933865245f1c@linux.alibaba.com>
 <20190327003541.GE4328@localhost.localdomain>
 <39d8fb56-df60-9382-9b47-59081d823c3c@linux.alibaba.com>
 <20190327130822.GD7389@localhost.localdomain>
 <2C32F713-2156-4B58-B5C1-789C1821EBB9@nvidia.com>
 <de044f93-c4e8-8b8b-9372-e15ca74e7696@intel.com>
 <33FCCD53-4A4D-4115-9AC3-6C35A300169F@nvidia.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <3fd20a95-7f2d-f395-73f6-21561eae9912@intel.com>
Date: Wed, 27 Mar 2019 11:00:32 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <33FCCD53-4A4D-4115-9AC3-6C35A300169F@nvidia.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/27/19 10:48 AM, Zi Yan wrote:
> For 40MB/s vs 750MB/s, they were using sys_migrate_pages(). Sorry
> about the confusion there. As I measure only the migrate_pages() in
> the kernel, the throughput becomes: migrating 4KB page: 0.312GB/s
> vs migrating 512 4KB pages: 0.854GB/s. They are still >2x
> difference.
> 
> Furthermore, if we only consider the migrate_page_copy() in
> mm/migrate.c, which only calls copy_highpage() and
> migrate_page_states(), the throughput becomes: migrating 4KB page:
> 1.385GB/s vs migrating 512 4KB pages: 1.983GB/s. The gap is
> smaller, but migrating 512 4KB pages still achieves 40% more 
> throughput.
> 
> Do these numbers make sense to you?

Yes.  It would be very interesting to batch the migrations in the
kernel and see how it affects the code.  A 50% boost is interesting,
but not if it's only in microbenchmarks and takes 2k lines of code.

50% is *very* interesting if it happens in the real world and we can
do it in 10 lines of code.

So, let's see what the code looks like.

