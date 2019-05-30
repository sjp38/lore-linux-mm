Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BDD51C28CC2
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 15:41:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 908D525D01
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 15:41:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 908D525D01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0532D6B0270; Thu, 30 May 2019 11:41:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 002D16B0271; Thu, 30 May 2019 11:41:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E0D3B6B0272; Thu, 30 May 2019 11:41:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 92A836B0270
	for <linux-mm@kvack.org>; Thu, 30 May 2019 11:41:23 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d15so9183865edm.7
        for <linux-mm@kvack.org>; Thu, 30 May 2019 08:41:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=IyRI0tNH81CjN6eKDokaXonl88pbPgyl3Qelar7DU64=;
        b=EwfODuGOb0WwpAq+wfqFt4l70XSYpkMLhRUn1aonjgNJDagjGBOcd25WwbZzQ4Ip2J
         l6ot5NN2MefHgkWIbLgsjXm93FD16dxvqmi4gaO0pWaR74nWGA+VafGYq/QxnHDLLAAD
         R9vCeaJtTPD1nUc+9W0smpYnRmo6MONLnfcVOn3JWlUYuWgwSH35RSX0ChmgkvuJ110e
         h86VyugdiFrptfYOIBCcJGmJDcTuzr1tM3GFdl4mIpKDkhJ25UcPg2Hb6uXw2oHCnGRC
         A87lq213fgDguE/FRFkz/JtSYwPUofkQET5VL8LzeL3Z7fvcuziz0/gbTsnl+i5CFwf6
         Pezg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAW3xp8OAAVgPdPPGJOEOtPo1mlSVS1gh2bcibClNRe0w+RjowYo
	sA6vOQuM2w/VCcr0hdaRI7XvM31khdjKgcYHTCOQRADE/IiJQRZfL9coBuki8MA6RnXOPwni+HO
	p4z7zx6ToyVly6tJqIKspEqS772jOsHHsIu6cw3rTNm61id0FY4o4i4VbxaQlLqc=
X-Received: by 2002:a05:6402:16d2:: with SMTP id r18mr5434733edx.261.1559230883178;
        Thu, 30 May 2019 08:41:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw7oFubsluHXAdZNJqysC4NNBWoivjsVxOSEFTtAUSIbjH4yKtpmpmnyZPevBTMDbdmbLvF
X-Received: by 2002:a05:6402:16d2:: with SMTP id r18mr5434637edx.261.1559230882201;
        Thu, 30 May 2019 08:41:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559230882; cv=none;
        d=google.com; s=arc-20160816;
        b=A6W1QOY7lfPPrqGT5Oaz4c+lxHRAAghky4k/ChnsxK4A3/QN898FNxY5Vd0jOgxRjt
         a5FCRUK6B36i8UqilkWyCONqn9unhll/hF/zHkQj4Z1secqCeBSGXdftO1azI2ELCPrr
         xYnnqUwJcB1LeoKz4tRUS4YI02ea0ptakx+IfWrMEKf4BZwLu3Zk8x8y6svqviB4eNYy
         LO71fa8YE+wGJvAmjsehc46uW8GneRp2M70Vrkn7J1xx2rH41hLv1wCaDzNDJO6xwoc9
         4cLvF5O1TVis2WSK/8g1WnCbyaOu55j+p3M8IyZte5XL9C0u1+UnqW78TWQ4pveceSdv
         xJgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=IyRI0tNH81CjN6eKDokaXonl88pbPgyl3Qelar7DU64=;
        b=UT/6LpLyww683i2+HGr1AaB6/OmCOF008WnLT7sk/l98O+ATkV93phEX+tJjjgkfzk
         Msu0YY6feDZjQNAkQJ4GAiUW+eRexa6pFYIR/DGNqODQamu86f+Gv6VafdNgfX1Lbzg9
         +HhuRit3BzoOj3F2MKLFYO5XZs7I33jzKhd/yIdSYoOE+Bc+uRRRxngqyFLTm8WhIueN
         Cfn+sBZ1kJJMfSp9crg79Di97qNl4kZcIYNdepZIF29rs1kqlNvPp0jzkjv8X6ssgUHs
         YbetGsiXnrAVGy1ywKm801Vv2eOBEnuCbXeyV4onPtOkzkIfz30wS41s3ck5RKcQEY8S
         RJPw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d26si1928528ejc.277.2019.05.30.08.41.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 08:41:22 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id ADB58AFE7;
	Thu, 30 May 2019 15:41:21 +0000 (UTC)
Date: Thu, 30 May 2019 17:41:19 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Mel Gorman <mgorman@techsingularity.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
Subject: Re: [HELP] How to get task_struct from mm
Message-ID: <20190530154119.GF6703@dhcp22.suse.cz>
References: <5cf71366-ba01-8ef0-3dbd-c9fec8a2b26f@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5cf71366-ba01-8ef0-3dbd-c9fec8a2b26f@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 30-05-19 14:57:46, Yang Shi wrote:
> Hi folks,
> 
> 
> As what we discussed about page demotion for PMEM at LSF/MM, the demotion
> should respect to the mempolicy and allowed mems of the process which the
> page (anonymous page only for now) belongs to.

cpusets memory mask (aka mems_allowed) is indeed tricky and somehow
awkward.  It is inherently an address space property and I never
understood why we have it per _thread_. This just doesn't make any
sense to me. This just leads to weird corner cases. What should happen
if different threads disagree about the allocation affinity while
working on a shared address space?
 
> The vma that the page is mapped to can be retrieved from rmap walk easily,
> but we need know the task_struct that the vma belongs to. It looks there is
> not such API, and container_of seems not work with pointer member.

I do not think this is a good idea. As you point out in the reply we
have that for memcgs but we really hope to get rid of mm->owner there
as well. It is just more tricky there. Moreover such a reverse mapping
would be incorrect. Just think of a disagreeing yet overlapping cpusets
for different threads mapping the same page.

Is it such a big deal to document that the node migrate is not
compatible with cpusets?
-- 
Michal Hocko
SUSE Labs

