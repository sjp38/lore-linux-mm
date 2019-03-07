Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4166CC43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 20:38:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EECFB20675
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 20:38:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EECFB20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 81C788E0003; Thu,  7 Mar 2019 15:38:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C8FF8E0002; Thu,  7 Mar 2019 15:38:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 692D78E0003; Thu,  7 Mar 2019 15:38:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2A9368E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 15:38:15 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id h15so19183853pfj.22
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 12:38:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=oNa9ogHrVIBiQ543ma+QKodCVVCQnhrAefy7GJ78x98=;
        b=ZzzKLE76P9qzXFeEuHbC/KibtDeY0pYs8lzXNGB7jd8nGicUh3rVhyMfHCfSurZ6h5
         pfSQHbb8nhSA6CQv2NFRH1Raq+GFuYUpQAEoB0x5n3dtsOHfTqh3olkB9D5Q9/O0kyTM
         umBLb+AbPw8rzfoqnpm93Lq1pmzXjJxulODOuAP8FiR/pXXgBynF13Ue7KLzpyM1+SWa
         vXbTWn0jrCCdx5ezAKx6Fa1qf2v8/UbRMHh41Q5phC6nEO9yb+cjxH8oogmPLD2Apkcl
         jcJxwJeSOUHAbxsjtXHcSjtHEXRbr6zCY9CE7wQVgkGDtIpn3bVW/NMJifxpT87LVQLx
         cd+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV7woZeL8Jz2c5fkzWWE0DGPYUV/i88XjPY77VheEl0QTJU3+n3
	q1WbiDSAhiN9d7ztdt7rA0fDOzopZrxjXtaqxpBfk9wVVf6vgGhH1TdROA/TRgi/cIudFcVeGKR
	mU/bR09+Zz6eU4+O2/y0FEzgszhwd1Iw85jCU1NrmOg5iwUADpGae6KdCVuU8lGAckw==
X-Received: by 2002:a65:5bc9:: with SMTP id o9mr13010548pgr.42.1551991094614;
        Thu, 07 Mar 2019 12:38:14 -0800 (PST)
X-Google-Smtp-Source: APXvYqy9yMid74yjPrrQYfngV6RsAVxsC4FXDp3/RiaEia6+AfID6F8pfaoeckl6SjuAhgPq7U3T
X-Received: by 2002:a65:5bc9:: with SMTP id o9mr13010491pgr.42.1551991093828;
        Thu, 07 Mar 2019 12:38:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551991093; cv=none;
        d=google.com; s=arc-20160816;
        b=c3uliZTvuQ+UIw8Wcabw2Hzc7NTGIicovLJo1ygmZNJyrdcfnx9G0oJGn+Cl0NIG4K
         F8JWe0pUxtx38BxdwWPQ/QM4F7D77YGIWuGqLU+zXKrZmtxLYt+4YoARYMjFGBjrNCh9
         tdL5x3VeIF8QEZpa8zT9x9SKxBXmbqsU2WpGe8GB75GfOP8xAUH9Cbkm74/U5LClA7hQ
         LUIP+mbzxIgJ4NP0gDuv2sUsQLE+gGauW1alZV3zzbzfnQMphnQvU3gBAQHCsO60IE9d
         EkQvA2q+KMSZRe0r7Qq1bMu9xItPZtu48Ay3EYWK5Hd59ygrffJhW68AwtC2jGvGsupK
         2FYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=oNa9ogHrVIBiQ543ma+QKodCVVCQnhrAefy7GJ78x98=;
        b=XSZ7/9ilVy2UgpHw06NG6QRO3TFzUCdWF40X4cykS/kWHR4AVxBXkaEpUtW2MZ+oY+
         QMpl0Oa3CVzIbRbI8BoBa5mgXw5UDnUlxBu79+4hlmkbEIxbm7q9qqSHoXqxRkz9Pbrl
         Hpco4IpuI5kvbI+RoYML30uOzW8geLto5nNMTTPhUxNuJtiZeUmVD8eQwVyP/PFHVLnL
         qQF6XecayLV40MAQiJF3W7ZX/uaw9vQrmHb0wD2kKvY7SAh7geMR/GsnYw9HMzXLHPjO
         t75YtTaUYMZWLUZPVRSeQXwSf+FazEROuukjkwcFPFaDA0PnvuvGptzT1ISFVVR0OBXG
         3wbA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id w13si4677592pgj.177.2019.03.07.12.38.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 12:38:13 -0800 (PST)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Mar 2019 12:38:13 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,453,1544515200"; 
   d="scan'208";a="305302212"
Received: from ray.jf.intel.com (HELO [10.7.201.16]) ([10.7.201.16])
  by orsmga005.jf.intel.com with ESMTP; 07 Mar 2019 12:38:12 -0800
Subject: Re: Kernel bug with MPX?
To: Richard Biener <rguenther@suse.de>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
Cc: mhocko@suse.com
References: <alpine.LSU.2.20.1903060944550.7898@zhemvz.fhfr.qr>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <ba1d2d3c-e616-611d-3cff-acf6b8aaeb66@intel.com>
Date: Thu, 7 Mar 2019 12:38:15 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.20.1903060944550.7898@zhemvz.fhfr.qr>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/6/19 12:53 AM, Richard Biener wrote:
> When running the gcc.target/i386/mpx/memmove-1.c testcase
> from the GCC 8 branch on MPX capable hardware the testcase
> faults and the kernel log reports the following:

While I don't doubt that we have some MPX bugs around, I wasn't able to
reproduce this one with that binary.  Is there anything else that would
help us track this down?


