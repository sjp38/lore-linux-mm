Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A939BC10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 18:34:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7629320449
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 18:34:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7629320449
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0848B6B0269; Tue, 16 Apr 2019 14:34:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 033E56B026B; Tue, 16 Apr 2019 14:34:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E8D696B026D; Tue, 16 Apr 2019 14:34:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9B1BF6B0269
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 14:34:08 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id o3so4544530edr.6
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 11:34:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=NVleg4vxC5EidiKXiZI47idHwsmkAicZ+TYiKEWyOHg=;
        b=cNkk1PhnhYqkPxUTvTvA0AXvG5Ntg5Sn0lk4ks16Ps/eGklJI0TxqBjIkd0ZQvAaLM
         oHPkyPwPu2TDvDFIyaMn7/EMUuKA/yvAGyzTTLzoKu1UYamShpOAMfF/+xT09XLCcePn
         h2LSgH7KAdpruS+LYslyD+M49/BTZ6er27isYGjqTy5tTY1zQO3/bBgAy780MY/gej9y
         W19NtmCI3FEOu9Rrh+IdKiQw50Jjw29zOfbFF0W/Lrf0FMEqvdkAh6lnxM2B6kdJK+6o
         6IXVnPFIQL/QWvSXgGVGu99UO4sihRAoaaoaD83x+1RG3R5+MYqCIxLsPLxrFh2FKpAi
         3Zpw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUUJ5YzTrHocGuX5/aNELMol5BpiRLR8tgueSveS8Bqe3n/FgYD
	z14hYl1pDJzMiZy3ypUpIz+LWi9gpa1NlAU/qMJmlIwJedguCgYwPVdVcLYhJt/sH7HW9kZW42z
	GQylK4HEENAyM8BmFAHcDJeC+U/nLDZ4FvFPClNg8ZRJTQyBYueT6SZxPoxf2rK8=
X-Received: by 2002:a50:deca:: with SMTP id d10mr9162183edl.25.1555439648212;
        Tue, 16 Apr 2019 11:34:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxKnz99ZQg9SoYj6PEXrM2ikaWhNaOqBZMtFTs9Y6f/MbyPPcIewPqRios+T3XvcXn6vwiO
X-Received: by 2002:a50:deca:: with SMTP id d10mr9162120edl.25.1555439647408;
        Tue, 16 Apr 2019 11:34:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555439647; cv=none;
        d=google.com; s=arc-20160816;
        b=0QO/yzjozQcsvMLaHbXeErY0WCcT+xAGSq7ai372V99uaCAWYCcY+TjyMqdT4WX+TG
         Smvx50Jl7RhsqxNXo5HAtdZ/9aScoGJCgp8a1jko2Qj61O5KkxGMMdu0B+JVjMWEZ1+T
         wmD14GUXAFb42AyZxbxrwbWJ6Cmt9jPaYPCQDLx5TRp6X/iW1fUmUI4hm0w1VNCrYokP
         ZOWEs8uI9KLgEn5A8MVVmOhWqURVgJANMZ1uR+pZk0w652hfKDiNf+e25cg23sAs4VN1
         EJHpDVQUpf1oDgmq2Q6IwPIeDe+q4TRfev5ib9ruNP6ZMUfzlrhnfTwDf2bGgu0rquPh
         qFVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=NVleg4vxC5EidiKXiZI47idHwsmkAicZ+TYiKEWyOHg=;
        b=kp9YuqoomKjI13Ga8J3uVmVw3W9eEgu4Hvt5kkI+kbCRjjfWLEF9X0ktUsqmqE4jt8
         mQIvrIM0ANsYt9qUrjiJH1Dek7OepglNttILyNTjHvh8+1UNGK7VopxQf91BuiOJH5WT
         ftgUzdRYZbr4vAo5P9pfmwcbRdY+52FC2t2gFTRbKQzp589xqPdHbd0bjOygD65XbjNP
         XApl/1P0mtInHJyaCiNaAgp794T9bIffA6R44R6cMfmkn8DzsRyNl0my9G7sL+07WdR5
         emnTdg4K6BeX7P26y/YBhdotKcxjVS7w4HtQbKylsDnqjOI+lK9u83VG9KJyqj7hhL0k
         GfFg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n44si668786edn.69.2019.04.16.11.34.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 11:34:07 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 919C9AC58;
	Tue, 16 Apr 2019 18:34:06 +0000 (UTC)
Date: Tue, 16 Apr 2019 20:34:04 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, mgorman@techsingularity.net,
	riel@surriel.com, hannes@cmpxchg.org, akpm@linux-foundation.org,
	keith.busch@intel.com, dan.j.williams@intel.com,
	fengguang.wu@intel.com, fan.du@intel.com, ying.huang@intel.com,
	ziy@nvidia.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [v2 RFC PATCH 0/9] Another Approach to Use PMEM as NUMA Node
Message-ID: <20190416183404.GA655@dhcp22.suse.cz>
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190412084702.GD13373@dhcp22.suse.cz>
 <a68137bb-dcd8-4e4a-b3a9-69a66f9dccaf@linux.alibaba.com>
 <20190416074714.GD11561@dhcp22.suse.cz>
 <b9b40585-cb59-3d42-bcf8-e59bff77c663@intel.com>
 <20190416143958.GI11561@dhcp22.suse.cz>
 <bddc3469-2984-2d32-f2cf-e1d0cc64f1e8@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bddc3469-2984-2d32-f2cf-e1d0cc64f1e8@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 16-04-19 08:46:56, Dave Hansen wrote:
> On 4/16/19 7:39 AM, Michal Hocko wrote:
> >> Strict binding also doesn't keep another app from moving the
> >> memory.
> > I would consider that a bug.
> 
> A bug where, though?  Certainly not in the kernel.

Kernel should refrain from moving explicitly bound memory nilly willy. I
certainly agree that there are corner cases. E.g. memory hotplug. We do
break CPU affinity for CPU offline as well. So this is something user
should expect. But the kernel shouldn't move explicitly bound pages to a
different node implicitly. I am not sure whether we even do that during
compaction if we do then I would consider _this_ to be a bug. And NUMA
rebalancing under memory pressure falls into the same category IMO.
-- 
Michal Hocko
SUSE Labs

