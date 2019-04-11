Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 986DDC10F14
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 14:31:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B2242184B
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 14:31:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B2242184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A4646B000D; Thu, 11 Apr 2019 10:31:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 954FC6B000E; Thu, 11 Apr 2019 10:31:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 844546B0010; Thu, 11 Apr 2019 10:31:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4A4706B000D
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 10:31:02 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id g1so4373257pfo.2
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 07:31:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=yhjYIG48cVO5bGgiCdjsBnBpIQv+u5j9xoBu5pG9Oeo=;
        b=YkdR7X4+v+8my4+Zm7PlyilDi/lo1V0jH6vqRSpqeBoP9Ga5lMHlTwyMJoqUfLDr3h
         UpJGM+GPg7tCKNvUEa4mDMXuyEduEKdKUHrkp95di9AKv8tv43A2bFDl9Qk+lx4AlKyl
         /HbU4XScf2wXU7Y5wio6WhrrQyuh0Nl5Vv40zQNi//+aH17slFkMAOSYK1p072HWeK7P
         NYHzKKBLKcwrBrbppsHlytYiEEzo5QzukzcXWhKZm4HSrHau5+U5psGvsuNClkOGi/r6
         vpS2+SxGsKdgMjgXjHefrImYf4oxT8lxHJFw8MchXE2lmjRrNkt9taX2evbEtL0Iqnat
         zSxQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAW6aM4hmYvhzR5kjkmT0fjauO/d9Mu2y8Yfuh2ZL70SUwxySYhx
	dwM7z8vHMAtXjSp5QY2dP6M/Xw1zPwHvlhp4dp8KqL2ddg2yUJFykyOiJFdnv/jyWvbH2Qqtq/K
	h7YQHNz+nYLyD7JUCF0RYEaVUP4kwZc1xuzBlQohAi5KcgPJdXU+Zkl3N5VPcxNnmQA==
X-Received: by 2002:a65:6210:: with SMTP id d16mr45955141pgv.110.1554993061935;
        Thu, 11 Apr 2019 07:31:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxq5eAl7sH3pgwOwv3enljbWpmHW5VUqCH3uCStj8FHba7T4w7OTIhQBBAL8Bm/9FhP4T43
X-Received: by 2002:a65:6210:: with SMTP id d16mr45955065pgv.110.1554993061093;
        Thu, 11 Apr 2019 07:31:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554993061; cv=none;
        d=google.com; s=arc-20160816;
        b=yj8E12KsBa7WWfuM8ntIbEyygbdC9kJOSf5Uyh9ULw4iRVkkH53teXO/gAkPzBhFYJ
         y61+94Ucc2CGkag9IgpYGJtNl/fhphM3+CQp/VPASYuRg1XicqRMgUbCsKWMV4fdaq7E
         05Ri6AjRD30Yn5seJcjYXJM/MNEjA5T2nFcN71sQ4YvzbXwy8+YBEqSYTQaiQkvHB4cS
         YWvXtlpk1IbZ7fWZNo8BLDdXVrhbCQSfC5Nm8krQZ6V3Yfqw4s22DPkkxavFSm5QmdDN
         qcUufm4oOSS38OkIP5OseCSn9xKDpcLCMqtKnAqBa8UIQfJJSI86CU2EvE93Kd7C1hrs
         Zr6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=yhjYIG48cVO5bGgiCdjsBnBpIQv+u5j9xoBu5pG9Oeo=;
        b=Fx3fyWwdsvyfUh+OASZaQfxJIaT7B2uKDR2IB0HhUKt2ItEiLYav1NQdo22w5J/mR2
         0zOFgvtUX+3K4n+N4ML0hk1sBZkAByXf70InX439dN9Mvxdb+9PQ611kEqYxOEj2SWTj
         H/JqlcV/WSFFVlY7AcHfCm6P4Q1b1qnZmVHdD91KNnZoWXeXEwFuo2WqO1mrITcjpwg9
         rRc+4gVsFYI6eqVTg7wVtemHQOcH4LuW5lD8w48pbig4aORhD82ZIWjNBinvVIY63vS7
         3X7HVMizB6X9yqXomNkUw/3TCfCzucOCv31j4w2QLu3T3Jj8dHDBsPgEh5w88+btSJqo
         sKGg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id h10si17348451pll.251.2019.04.11.07.31.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 07:31:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Apr 2019 07:31:00 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,337,1549958400"; 
   d="scan'208";a="141895234"
Received: from tqlu-mobl.amr.corp.intel.com (HELO [10.251.9.147]) ([10.251.9.147])
  by orsmga003.jf.intel.com with ESMTP; 11 Apr 2019 07:31:00 -0700
Subject: Re: [v2 PATCH 5/9] mm: vmscan: demote anon DRAM pages to PMEM node
To: Yang Shi <yang.shi@linux.alibaba.com>, mhocko@suse.com,
 mgorman@techsingularity.net, riel@surriel.com, hannes@cmpxchg.org,
 akpm@linux-foundation.org, keith.busch@intel.com, dan.j.williams@intel.com,
 fengguang.wu@intel.com, fan.du@intel.com, ying.huang@intel.com,
 ziy@nvidia.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
 <1554955019-29472-6-git-send-email-yang.shi@linux.alibaba.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <bc4cd9b2-327d-199b-6de4-61561b45c661@intel.com>
Date: Thu, 11 Apr 2019 07:31:00 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <1554955019-29472-6-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/10/19 8:56 PM, Yang Shi wrote:
>  include/linux/gfp.h            |  12 ++++
>  include/linux/migrate.h        |   1 +
>  include/trace/events/migrate.h |   3 +-
>  mm/debug.c                     |   1 +
>  mm/internal.h                  |  13 +++++
>  mm/migrate.c                   |  15 ++++-
>  mm/vmscan.c                    | 127 +++++++++++++++++++++++++++++++++++------
>  7 files changed, 149 insertions(+), 23 deletions(-)

Yikes, that's a lot of code.

And it only handles anonymous pages?

Also, I don't see anything in the code tying this to strictly demote
from DRAM to PMEM.  Is that the end effect, or is it really implemented
that way and I missed it?

