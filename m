Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BEE4C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 18:48:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15672206BA
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 18:48:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15672206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9F788E0005; Mon, 29 Jul 2019 14:48:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4F9C8E0002; Mon, 29 Jul 2019 14:48:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 918648E0005; Mon, 29 Jul 2019 14:48:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5BCCA8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 14:48:53 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id z20so38804357edr.15
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 11:48:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ebiMmFpcYrTi8rFUlWJ+SAT01iyu2ulaAIqkNqjfGCI=;
        b=eLgeAsJHoFX+ZYzu6ytnXkVSjKhV+rQ4zy4fZVsi/fRJkQGUG4I07f+tYAKBkqkrmB
         a+Dejg3rvhCfZzak31cUABvyHAe8005a1xwCAUTsARpSLckZXAxT8QLovskb3wg/GVc9
         c5CE429epRQgov3Id1EHMqliu+udm4MyXfqKRiIWI6QmUfLkGa2jXeDmZUFCpaMJucHh
         OM6x9Wog3QeRlyD0f5UOUPwqs4i0Wh8A6A1cJ/p/zClIFu8Q9NBkMz3aj6SH0zJGCr6J
         F8b1cOzTP+TXf8lQ0dq3cu+/2DdONuZV/CiVrdEAKGciCIPJDx58E9QxXc0266+NA0Bm
         0h1g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWAxWYjcC6MomY8Omur3dTJAnZ6c0APkBwkzGg7pwjXp+FUGImw
	zzSgtXaysXqBREwCMy58144bmzbVSMcHIRqraNdz3cVqr0bH9dNmAjs2IBonbcamklv/qVKLQUn
	hyNqv0y+Ps1pWlBQrTQSaxNji3CvPFFIPQDe3YyeYHRWTKfLYWholUmwcCL0oET8=
X-Received: by 2002:a17:906:5c4e:: with SMTP id c14mr83448170ejr.73.1564426132938;
        Mon, 29 Jul 2019 11:48:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwcl/oMhPTNa7gbysxHlKTxli46WJ7iXTOXSs9whU5iAa9w6Dtx1lEVXT7qEPFVMfGTyDkY
X-Received: by 2002:a17:906:5c4e:: with SMTP id c14mr83448135ejr.73.1564426132272;
        Mon, 29 Jul 2019 11:48:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564426132; cv=none;
        d=google.com; s=arc-20160816;
        b=bBMJhVAEy58hJKYCXzXXw8AOxaZGz67LOwVk8L2Ya1pmV8zApccVExB8B49ZFKU9kn
         44WJOxlbQQTDNVEli1Y0qMvVs+vUSHUp/SCJ5rboiT6/6MA9S2a4ZfMA049xHZ6KNt0k
         7gpQEMZUxCJx42b/drixHIRqMfdAhLAr68rAKgYs4J3Cp5M33ujb0RpeOqQ55hwF35r9
         bU7eO81u8CFUSoVR2PqZIirojejftT2znKIZtN18toXQhdrtCMiB09Wk9WQo8foK6tIs
         OhPMZ3SVukizfFVZz6mDvqCzy5By/lVjmvWCSdDgCF7pXAYUjHPy1+e1dy8ENQ/27Ion
         XyWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ebiMmFpcYrTi8rFUlWJ+SAT01iyu2ulaAIqkNqjfGCI=;
        b=awbFKy8r1QTnXjjADpnqbda6jCQGVTAyH816XroLp0dKe85cpk4zkub0LuJCA8ZrtP
         KYhn6mCCJW+5qd21n8zUoYWFXsllN5Rsg/lOdkFSvesutejX7zlIbSjUR+T2Hp2xOrli
         8/+H2dOv4QtV9Dx6/zvsTEAxHTc7WcaVUjnRi5Qi8SPVhNbMVV+O8O/7GXE2ABdhBxn0
         Ghi2NoNIQPl2iDq63z0QnlThgHI6Hep7CeTe55Fs92kYFuNyHWG++e6fzd+6e+2U/L4N
         Sg5XU0Ysp1Ac0HPbH35OluO4jdjkoyTzwCgQ9SQevz1J4CJmFQXRG4ThbhibohSOiyHo
         ZaeA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l43si16834675eda.71.2019.07.29.11.48.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 11:48:52 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id CB20FAEFD;
	Mon, 29 Jul 2019 18:48:51 +0000 (UTC)
Date: Mon, 29 Jul 2019 20:48:50 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <shy828301@gmail.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	cgroups@vger.kernel.org, Vladimir Davydov <vdavydov.dev@gmail.com>,
	Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH RFC] mm/memcontrol: reclaim severe usage over high limit
 in get_user_pages loop
Message-ID: <20190729184850.GH9330@dhcp22.suse.cz>
References: <156431697805.3170.6377599347542228221.stgit@buzz>
 <20190729091738.GF9330@dhcp22.suse.cz>
 <3d6fc779-2081-ba4b-22cf-be701d617bb4@yandex-team.ru>
 <20190729103307.GG9330@dhcp22.suse.cz>
 <CAHbLzkrdj-O2uXwM8ujm90OcgjyR4nAiEbFtRGe7SOoY_fs=BA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHbLzkrdj-O2uXwM8ujm90OcgjyR4nAiEbFtRGe7SOoY_fs=BA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 29-07-19 10:28:43, Yang Shi wrote:
[...]
> I don't worry too much about scale since the scale issue is not unique
> to background reclaim, direct reclaim may run into the same problem.

Just to clarify. By scaling problem I mean 1:1 kswapd thread to memcg.
You can have thousands of memcgs and I do not think we really do want
to create one kswapd for each. Once we have a kswapd thread pool then we
get into a tricky land where a determinism/fairness would be non trivial
to achieve. Direct reclaim, on the other hand is bound by the workload
itself.
-- 
Michal Hocko
SUSE Labs

