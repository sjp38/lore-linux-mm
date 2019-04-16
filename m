Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74AE9C10F14
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 14:30:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34A8320693
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 14:30:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34A8320693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D20286B02A4; Tue, 16 Apr 2019 10:30:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CCF5F6B02A6; Tue, 16 Apr 2019 10:30:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B97C96B02A7; Tue, 16 Apr 2019 10:30:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7F4B56B02A4
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 10:30:23 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id c64so14188661pfb.6
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 07:30:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=8VNp8YsDiSPNj7tJbxX+JH3o+stEDUqAgKEN5HW9ZU8=;
        b=X4JKicCOwz3iDh3rzxTYn2oAbDKDwa44jJpkvUZPUZADhfilbFUru0O6/2xg2XRA+w
         SBiJ4gBHKxg2awEDQEEVmToG9fxFf62x/ep35IUDcnZoyejrybpWdYKaSVEmuQF6VBPy
         w8fH3r25tuoa8d7Dg/EsKMq0AKu+76tNR9s9Ll3CtDoKoMDvA1CjAsOX+wmrz/bvbHqa
         EVu/KtoBHWgRMNhLtPoL1M7Z1T2i1+bBmwCv4C0jTazLQ2cY/m5t3TcDAZeBumO2FD5V
         ahfk3i0ao7KmPhHHaRE8MPNnJ3f3tECrkkZOrFRQCNsN+Lvb0pnMn8WWVsXikNa20JJf
         kV+Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUQxlQ4VBSPdo+vy62BtThRKxKh+mbBMAmrJLGfXvsPxdyornq0
	bAQbwCN4QZ94p6trxvxaDxMMEg6OxI4FV6bWbYZx9SWs8adW+1tWwV2dP0y6pR4jJjr/sEbVVEc
	FlWlRlZMUyvGYl18hqBzn8MARlilz2QeCaDrhPHEHy0ey8pNvUAFdcWz50RqwlDYfaQ==
X-Received: by 2002:a63:6e0e:: with SMTP id j14mr75850866pgc.203.1555425022964;
        Tue, 16 Apr 2019 07:30:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwxkNHEPt5LGU0DuLjx6fgemF4pU0ekaEM4BDRAudTstVEli2FOjJlt8klYKkN7NSdv+vgX
X-Received: by 2002:a63:6e0e:: with SMTP id j14mr75850767pgc.203.1555425022073;
        Tue, 16 Apr 2019 07:30:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555425022; cv=none;
        d=google.com; s=arc-20160816;
        b=bAuEVID38m5aU1mdNGKCUdU+dSgdVS2klvRX3qiMaWESVGvos1+PfQXHjZ3APQiJFi
         22WLVDmZ6Qmhhc0TPvSe31sJSlDOqu5f9Pn1rV2PKuFwjHFsHHInOj3Mg044CgQ9KSmU
         Cckb8WTIn3BH/h7tSy5kNAYXSFIT/ZRWJMVyAnY4ThGeE/gKQQX0SwZ9izGuABQX9AfK
         WUVbiNU4a04u38yZov4sJk3gUyle6BHmpR5xxwwscnF183AffXGomcAqpE1YYcEAqc4+
         H3NnxD0a03ygHVdXle+lTnJuYovBMZR0XI3HfeeNqZq00VH7ojHNgDBkRv9LvDyplUFq
         Ogxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=8VNp8YsDiSPNj7tJbxX+JH3o+stEDUqAgKEN5HW9ZU8=;
        b=fnTc1++fPUGdgO5CwmBL7jIDZobxKXrNFQbZ/KIIAKIS8w4yinkM3xSZ+IebcoEuEV
         AjOr3er8ffeptwIi6xsaz+oGNRvX7qCE9cHmS6PnXoo9bq5hwZZvSr+3MEFQSSiqlI4y
         581o/wpjxsuaHh/1MrT3cnI6tlGgCAim/LwLrNZzdlqmR2/BUhMFhE7sQb10ytWGFFRA
         CZ/9YKQWFfao0P2FAf6N+5OJQ+vvwb8dzeSCXK9ok0hSp7sfXRs6uYvnP/lYi/DIDrqg
         +oZWGqq69Scgob7P1tWDZSolpIbBffZYAOI+A50Ir3xSLL0O0Rfp3q++mn/+i/cq2RdP
         lDbg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id i63si47509996pge.151.2019.04.16.07.30.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 07:30:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 16 Apr 2019 07:30:21 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,358,1549958400"; 
   d="scan'208";a="131861703"
Received: from jssmit2-mobl3.amr.corp.intel.com (HELO [10.254.83.57]) ([10.254.83.57])
  by orsmga007.jf.intel.com with ESMTP; 16 Apr 2019 07:30:21 -0700
Subject: Re: [v2 RFC PATCH 0/9] Another Approach to Use PMEM as NUMA Node
To: Michal Hocko <mhocko@kernel.org>, Yang Shi <yang.shi@linux.alibaba.com>
Cc: mgorman@techsingularity.net, riel@surriel.com, hannes@cmpxchg.org,
 akpm@linux-foundation.org, keith.busch@intel.com, dan.j.williams@intel.com,
 fengguang.wu@intel.com, fan.du@intel.com, ying.huang@intel.com,
 ziy@nvidia.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190412084702.GD13373@dhcp22.suse.cz>
 <a68137bb-dcd8-4e4a-b3a9-69a66f9dccaf@linux.alibaba.com>
 <20190416074714.GD11561@dhcp22.suse.cz>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <b9b40585-cb59-3d42-bcf8-e59bff77c663@intel.com>
Date: Tue, 16 Apr 2019 07:30:20 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190416074714.GD11561@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/16/19 12:47 AM, Michal Hocko wrote:
> You definitely have to follow policy. You cannot demote to a node which
> is outside of the cpuset/mempolicy because you are breaking contract
> expected by the userspace. That implies doing a rmap walk.

What *is* the contract with userspace, anyway? :)

Obviously, the preferred policy doesn't have any strict contract.

The strict binding has a bit more of a contract, but it doesn't prevent
swapping.  Strict binding also doesn't keep another app from moving the
memory.

We have a reasonable argument that demotion is better than swapping.
So, we could say that even if a VMA has a strict NUMA policy, demoting
pages mapped there pages still beats swapping them or tossing the page
cache.  It's doing them a favor to demote them.

Or, maybe we just need a swap hybrid where demotion moves the page but
keeps it unmapped and in the swap cache.  That way an access gets a
fault and we can promote the page back to where it should be.  That
would be faster than I/O-based swap for sure.

Anyway, I agree that the kernel probably shouldn't be moving pages
around willy-nilly with no consideration for memory policies, but users
might give us some wiggle room too.

