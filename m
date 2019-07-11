Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B617C742A1
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 18:21:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B75A1208E4
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 18:21:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B75A1208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A4278E00F3; Thu, 11 Jul 2019 14:21:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37A378E00DB; Thu, 11 Jul 2019 14:21:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 241EC8E00F3; Thu, 11 Jul 2019 14:21:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id E387B8E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 14:21:51 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id c31so3163473pgb.20
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 11:21:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=C+NY0oB+oEoueBVtoiZiDFtgCgYI0PCNttKZ7w6LoeA=;
        b=Nkvj0qOBsCzjTUSuRGdtihxzwvpzuLQPCUMdyqIhwBykK4fG9tm/QL2zgxbDxa/Iqt
         ycnm9bbUJWtCkhe9LdwY+6GOIlgrKYMfnTxG7iAAz+ilXDBWbF9LltYnVgj5G3/WHLTD
         zBYDigsZs3XLrSARDFy2nTF53ceKCyQqYhmaZN3bB+Nh2culWwoCDlIEu360+YX5sc47
         UPlPZHz06teW28tyIlqrCLQpSnYPE/6AZRs28a/G05dwmYh9/qGSOUe0aBsxoxPhJiDN
         89hJRID8XTbtA5KQ2Yvv2vlRtaJDb6oqUvLbo+QQ6MaMRH+C2WunlKN7bZwUBVNj2QXj
         d73A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAW9LQrPllCZdyqvHrKEguAiKOmbGbUD34/nOlwVdzJIh3gV+BRj
	xTvYYiRFJ5SnQERYuSAaXCwztRXf46V8g+cxMTIbSL+m7M2/VsaYE5APV5uw4WekIuP+uEE7yRP
	O/tj4UvC61FF7Wy/9KE9J/HlcAg0TL3JJPg4vFs0HXCcmfS04yOOfXBIOjGoCWIEC9g==
X-Received: by 2002:a17:902:8ec7:: with SMTP id x7mr6119527plo.224.1562869311530;
        Thu, 11 Jul 2019 11:21:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyW3zj3XsgTLJ3fPACOi6v1a3qzWOysF6jVd7ZlRW+Qvm0Qa/Q4HG6KdctwxtE2w3xJBxrz
X-Received: by 2002:a17:902:8ec7:: with SMTP id x7mr6119461plo.224.1562869310678;
        Thu, 11 Jul 2019 11:21:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562869310; cv=none;
        d=google.com; s=arc-20160816;
        b=EUgIyKyP1gxvBD6+OhLmRXUr+jkJwBWs+TlnyZMELe9t7dsCyIcXW4dq6p8nv2boui
         QdHvWUfdrzv0xYc2a8kxVqluCzOzD41gmDCRxnz+kMyJ3oPYpdkjjNOu/gcobLOOM8FN
         BkzdkKc/4hZNNRKTzZn/1m1Xo6o1tQnFUC+WuW/ttJghSedsGXmhYGUSpk2GkNXGNSkt
         eHCK/L72jwlwx5K3sad/Cg4Jiqc+Uisrz7l19mywbTvop3qONShqTOp7d4lbpXULafNV
         ppAS4NwW0cqgVNj/hdC9kPSH4b2QSTNJnvBCOYdw156u6IvnXXbZL99wty/lBPicdpst
         edSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:to
         :subject;
        bh=C+NY0oB+oEoueBVtoiZiDFtgCgYI0PCNttKZ7w6LoeA=;
        b=bo1np1htir4Y0hUKysl4/pF0rtAr6pEYk32VdFOi6W+QM95Bik+ZsajC0wjjkP8/90
         YeToWwnDwDBMMDkpz4yElMffV6rF6K7+ZmW/YBhgX8UVPS8LC5z5uXN0UddJyeI0H7i5
         yky6BscQ+GcYUR6Eparq4wMfoDLnXd3EDsnELGC0rDUL2MSfmLGeneR3rDondBdosppT
         4XPNJV3mPmH2ng4kBAQbveGJkFriAXcrhlPPYNCCMcofUvy8AnNsjvF/XW/N3tg/s8Gy
         gHd6DSTf/0WKU/unXo7hpU9Usm8MIKSLPFwSIAbwmlyvI7NwbIXnmG/lGaYeGkzTFK6K
         6daQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id q187si5493588pga.220.2019.07.11.11.21.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 11:21:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Jul 2019 11:21:50 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,479,1557212400"; 
   d="scan'208";a="156901295"
Received: from ray.jf.intel.com (HELO [10.7.201.139]) ([10.7.201.139])
  by orsmga007.jf.intel.com with ESMTP; 11 Jul 2019 11:21:49 -0700
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
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <f9bca947-f88e-51a7-fdaf-4403fda1b783@intel.com>
Date: Thu, 11 Jul 2019 11:21:49 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190710195158.19640-2-nitesh@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/10/19 12:51 PM, Nitesh Narayan Lal wrote:
> +static void bm_set_pfn(struct page *page)
> +{
> +	struct zone *zone = page_zone(page);
> +	int zone_idx = page_zonenum(page);
> +	unsigned long bitnr = 0;
> +
> +	lockdep_assert_held(&zone->lock);
> +	bitnr = pfn_to_bit(page, zone_idx);
> +	/*
> +	 * TODO: fix possible underflows.
> +	 */
> +	if (free_area[zone_idx].bitmap &&
> +	    bitnr < free_area[zone_idx].nbits &&
> +	    !test_and_set_bit(bitnr, free_area[zone_idx].bitmap))
> +		atomic_inc(&free_area[zone_idx].free_pages);
> +}

Let's say I have two NUMA nodes, each with ZONE_NORMAL and ZONE_MOVABLE
and each zone with 1GB of memory:

Node:         0        1
NORMAL   0->1GB   2->3GB
MOVABLE  1->2GB   3->4GB

This code will allocate two bitmaps.  The ZONE_NORMAL bitmap will
represent data from 0->3GB and the ZONE_MOVABLE bitmap will represent
data from 1->4GB.  That's the result of this code:

> +			if (free_area[zone_idx].base_pfn) {
> +				free_area[zone_idx].base_pfn =
> +					min(free_area[zone_idx].base_pfn,
> +					    zone->zone_start_pfn);
> +				free_area[zone_idx].end_pfn =
> +					max(free_area[zone_idx].end_pfn,
> +					    zone->zone_start_pfn +
> +					    zone->spanned_pages);

But that means that both bitmaps will have space for PFNs in the other
zone type, which is completely bogus.  This is fundamental because the
data structures are incorrectly built per zone *type* instead of per zone.

