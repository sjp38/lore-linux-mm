Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C165C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 17:13:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 07B7520675
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 17:13:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 07B7520675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 84A6F6B000A; Wed, 17 Apr 2019 13:13:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FA866B000C; Wed, 17 Apr 2019 13:13:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6738F6B000D; Wed, 17 Apr 2019 13:13:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2C5CE6B000A
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 13:13:46 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 132so14975143pgc.18
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 10:13:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=+O3RcTglkocLyqGfjRo8kkhyFc+iNTRk0QE05qdstOo=;
        b=HXTE+W4tnaciFfrjFOKELbvo/Mt2TtNtQHnkeS372+NMAn/k+3Yh1WV1QmB4/S2tHb
         xf1DwcV7M9/Tbcw+aAHIcufC9PGLxiqAVD/BIryxjQp3rTrBswAePvYHXFfrC8rts2kl
         L0TIkntcAs9Z7RMi0du6EY+5GOuyDU+hsNtCUlzKYlilTwzTBzKXF4Iaqoe60bH0LIxq
         WZisbRBtKM4NTZXCKRvzgJ1DuTpBT6ankHJWsf/TBz9EjUgI3jfyMbNtAHk2KbIJow5V
         rCdm3SD2NaWzOmrLx+BuLJRl8wsTW5HcpksAo5AEzKH4do+v/OblJoPbfnfe4N4nBHpI
         irGA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUYexOIwxnoBP/xR9ESUzefrU5/pwLK4idpv2Xw31BmNj9mYeIP
	vkraPw+R6JvJGHvz1nGB/ElWULmNdhu06E/iPmnBdtNYHnQvttSWzaBCHYCgPfaVqKb1sP6us+u
	d1WoK9sQM5MD2gr2f2bDajkL2s0Dvp5zWGVGORY7vo8BRKB44VoU+wfXv3UWQCDLgSA==
X-Received: by 2002:aa7:8208:: with SMTP id k8mr92029262pfi.69.1555521225755;
        Wed, 17 Apr 2019 10:13:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzoqgIXv1C+cXH0V66d+EyMhWY+Z9nvM1raVw+/BMfCJQ1RHmm9boqt3OkwnYKOZzOJsPlH
X-Received: by 2002:aa7:8208:: with SMTP id k8mr92029200pfi.69.1555521225058;
        Wed, 17 Apr 2019 10:13:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555521225; cv=none;
        d=google.com; s=arc-20160816;
        b=RKf2UV28gquHTLvdDhR46SpcXfcSSmVcVPmmgbbLw5Ns/IEU5zK57fhHKRpTF/D8J4
         IzkYViCQoP+e7lWMWw6hmfbVl0MDhroc0FGfJoZm5OHuJ+aOR+cQqxDGSwQyoMGg2r90
         tar9fLCWQId0Hgh2TDa+FVcIf9iNniGCkO2r9dY08OkR3onud7dccXMK68ZaZr+ZVxLl
         sW3NhYPj/+gVYLT8kmB6S8GbiRFer2vPfXNlr2pvKIWRPQDCiToQK5tWUkY9e36meUzY
         NnGrv5yr59HY8rZpJppwAJ3KX7SRjA+Ppa2qa7D9wE1+UEijlcPhZ3j643j3/EfIhMt9
         wySg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=+O3RcTglkocLyqGfjRo8kkhyFc+iNTRk0QE05qdstOo=;
        b=UzSgxXBq6YzCQYWv1kBOrKzbC7F5Uo4SeatXZlBfTe1TxGxROw3mJlIRWuaHKKtyoB
         320eT8xywxPXhh/s5J1Bswg2Y1cjN+cI2vcL6uil3sZrfUghxxjoQZqn+3GdjquCwxWD
         08sLqxhuqN9Lpk7XzOliEoVlZyCCQNuNpn16bzTfABvfIqDDiGHrft7GDA94mRwU9E71
         RsWBOAutWbogpNRoT6FsMai7NnYKZ097iiNrjRKJBWhwnJKeq1hxl++/mugcmq1qMw97
         r5BeGq5Z/VjZbFeZQ3ZanfSQbRNqvC0MRZ/8JKOM/SGiwj/P0D3KUnJiIYCJSQ5Zi0kO
         iAcA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id 194si50003402pfu.48.2019.04.17.10.13.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 10:13:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Apr 2019 10:13:44 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,362,1549958400"; 
   d="scan'208";a="292380456"
Received: from ray.jf.intel.com (HELO [10.7.201.16]) ([10.7.201.16])
  by orsmga004.jf.intel.com with ESMTP; 17 Apr 2019 10:13:44 -0700
Subject: Re: [v2 RFC PATCH 0/9] Another Approach to Use PMEM as NUMA Node
To: Michal Hocko <mhocko@kernel.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, mgorman@techsingularity.net,
 riel@surriel.com, hannes@cmpxchg.org, akpm@linux-foundation.org,
 keith.busch@intel.com, dan.j.williams@intel.com, fengguang.wu@intel.com,
 fan.du@intel.com, ying.huang@intel.com, ziy@nvidia.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190412084702.GD13373@dhcp22.suse.cz>
 <a68137bb-dcd8-4e4a-b3a9-69a66f9dccaf@linux.alibaba.com>
 <20190416074714.GD11561@dhcp22.suse.cz>
 <876768ad-a63a-99c3-59de-458403f008c4@linux.alibaba.com>
 <a0bf6b61-1ec2-6209-5760-80c5f205d52e@intel.com>
 <20190417092318.GG655@dhcp22.suse.cz>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <5c2d37e1-c7f6-5b7b-4f8e-a34e981b841e@intel.com>
Date: Wed, 17 Apr 2019 10:13:44 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190417092318.GG655@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/17/19 2:23 AM, Michal Hocko wrote:
>> 3. The demotion path can not have cycles
> yes. This could be achieved by GFP_NOWAIT opportunistic allocation for
> the migration target. That should prevent from loops or artificial nodes
> exhausting quite naturaly AFAICS. Maybe we will need some tricks to
> raise the watermark but I am not convinced something like that is really
> necessary.

I don't think GFP_NOWAIT alone is good enough.

Let's say we have a system full of clean page cache and only two nodes:
0 and 1.  GFP_NOWAIT will eventually kick off kswapd on both nodes.
Each kswapd will be migrating pages to the *other* node since each is in
the other's fallback path.

I think what you're saying is that, eventually, the kswapds will see
allocation failures and stop migrating, providing hysteresis.  This is
probably true.

But, I'm more concerned about that window where the kswapds are throwing
pages at each other because they're effectively just wasting resources
in this window.  I guess we should figure our how large this window is
and how fast (or if) the dampening occurs in practice.

