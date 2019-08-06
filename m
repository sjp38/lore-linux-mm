Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90C69C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 07:35:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E1602189F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 07:35:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E1602189F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E18E86B0005; Tue,  6 Aug 2019 03:35:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC9A96B0006; Tue,  6 Aug 2019 03:35:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CB8616B0008; Tue,  6 Aug 2019 03:35:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7AEE36B0005
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 03:35:29 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y3so53201413edm.21
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 00:35:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=47bol3YUTn9etsbfy9kFHc/UdUcnxK5mO3tLr3QT99Q=;
        b=N/Rso2pMfhNH3UwfEd2BdnYoT/JW2vDPRLRX06UOXnO7gPYNVe8m4YTP3padKrhBVz
         JAK6C2U1hCPRtduPwFnwu+6P/2Fu3oydmE9UKvjknRyYhVPLT1nt5EYD00RyeWoVVgvA
         J/g9m0/FmTNHKYX53fMlfiq+qmxgeDWhTnXKaMUK/bVp/ra/tuq40RBTC3Qpa90N4O+O
         Isw/NYJjtL6DdJX6cF2upmFN4W+EpLtw4/XAEnksqoWb+LB7qlXkCGgbJWSDKRfhFMH2
         y3qh4PuYO/4ONoYgO0XCKoDHXOZ/63Ghkr5YfCj8+PJxIfD3svd6neDDWCVSEoOlI2AV
         TrxA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVZhcIYd6Aevx7oYxKFysBJhoL78smKBBSOsILquS9Yoqzc6K4k
	NQGnYpOUuCoSWxndkVwIcKKzlrxuJ64hUX1fg35sUL0y483DJ4kOXqjO8e/zX4fJnV+fs7p73JC
	GNTmNvJpj5YTV3vgKh8Oy6FxO2XtubRFGJDsVVFMKw+Y5wNWcl1qUqjWWj8T/p1U=
X-Received: by 2002:a50:ac4a:: with SMTP id w10mr2368267edc.33.1565076928782;
        Tue, 06 Aug 2019 00:35:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzuhGmvN63TIiINyrPRUWiqfDYRCHIS93Ew/iqw6P7BCRRGqe9vE9373rJRDgc7Gy5f1UGr
X-Received: by 2002:a50:ac4a:: with SMTP id w10mr2368233edc.33.1565076928110;
        Tue, 06 Aug 2019 00:35:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565076928; cv=none;
        d=google.com; s=arc-20160816;
        b=a4ynte+4jRNtcNvpY9qtb9uobw6r5SPbULMc8bVaKHAyDvbIQEiCiR0KgDyw5m6Tsu
         eB6FjpBKd20NRlo6UxHX9F3dUxKYWOlSVIHjHVoB6FlwIiwXvHtBHh3qQo8sU9tHhZXo
         YGBPxev6xXQ3ohyAbiZuYmVtNivXhaJ8i5KW7akafNgoId2xztytU2+owV3lsaVNoxLJ
         Zur6fueqTNTeBO08zENnkrVtnMlv3MfYU4XM81BNIX/GcFcRknhtSpSy1Nrx6R9J3RnB
         6epB4k9PXLgQ1Epen0UpuhUv59BmwA0riYib1G8TKn8zk/wC7x+CCQnrwQ5595mkWEjZ
         ot5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=47bol3YUTn9etsbfy9kFHc/UdUcnxK5mO3tLr3QT99Q=;
        b=ztJxYF7QR1OpfBKpByCD442a+aZIz2zySOZ8PPNls2wFST9WxF/ZZMkYYbCKhz4f+g
         Etj0jhPtxvdVKVV3jOyD9YeKMlz5Tv84C6Ska5CxrgHIius+wh7qKilLfAITGYdqtf61
         EgX4dn0Z/Gtba9yZns3Yw4Y+dtBZcR6eo2brLpDUo5u56VoSR7wE8qrH4Obg15vug3t7
         wtyzbBNNtsfCQeQFKBQyluGpK1CFq+TKp0IihoS+qXRZ+YJxPmtu7hVLVnn8clZd8wJ5
         TRb7RTBkxAmZUJLs+lhjxNT+fQZK7BqFNbrEwJF6Hq86t3IMTxfFb591UfwVU4sW73Le
         55kA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e13si27050374eja.85.2019.08.06.00.35.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 00:35:28 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 53DA9AC3F;
	Tue,  6 Aug 2019 07:35:27 +0000 (UTC)
Date: Tue, 6 Aug 2019 09:35:25 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
	Daniel Jordan <daniel.m.jordan@oracle.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Christoph Lameter <cl@linux.com>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: Re: [PATCH v2] mm/vmscan: shrink slab in node reclaim
Message-ID: <20190806073525.GC11812@dhcp22.suse.cz>
References: <1565075940-23121-1-git-send-email-laoar.shao@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1565075940-23121-1-git-send-email-laoar.shao@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 06-08-19 03:19:00, Yafang Shao wrote:
> In the node reclaim, may_shrinkslab is 0 by default,
> hence shrink_slab will never be performed in it.
> While shrik_slab should be performed if the relcaimable slab is over
> min slab limit.
> 
> Add scan_control::no_pagecache so shrink_node can decide to reclaim page
> cache, slab, or both as dictated by min_unmapped_pages and min_slab_pages.
> shrink_node will do at least one of the two because otherwise node_reclaim
> returns early.
> 
> __node_reclaim can detect when enough slab has been reclaimed because
> sc.reclaim_state.reclaimed_slab will tell us how many pages are
> reclaimed in shrink slab.
> 
> This issue is very easy to produce, first you continuously cat a random
> non-exist file to produce more and more dentry, then you read big file
> to produce page cache. And finally you will find that the denty will
> never be shrunk in node reclaim (they can only be shrunk in kswapd until
> the watermark is reached).
> 
> Regarding vm.zone_reclaim_mode, we always set it to zero to disable node
> reclaim. Someone may prefer to enable it if their different workloads work
> on different nodes.

Considering that this is a long term behavior of a rarely used node
reclaim I would rather not touch it unless some _real_ workload suffers
from this behavior. Or is there any reason to fix this even though there
is no evidence of real workloads suffering from the current behavior?
-- 
Michal Hocko
SUSE Labs

