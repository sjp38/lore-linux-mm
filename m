Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9DF4C46470
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 12:35:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 863F02231F
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 12:35:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 863F02231F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 198136B026B; Tue,  4 Jun 2019 08:35:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 148AF6B026C; Tue,  4 Jun 2019 08:35:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 05F216B026E; Tue,  4 Jun 2019 08:35:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C3CE66B026B
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 08:35:54 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r5so215101edd.21
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 05:35:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=r53sSBufWuLXmLBo6iCbp5CAMhHqzB7J3eE0fpQajYs=;
        b=rtRqf+0UKALPmicesxR4xchos/ZLeDU4YrGglY8q08d5doM0lZWoZKKZBG82NIWi6A
         9kZMWtTDq5G8Qm0YVQzoawAVAxm4REjhcbPO0aCbwJRE14+z8KVUnlgXb63LSiXweM+6
         GxTRX6vWTsWWtg7QO4eRedG/TsOZgIq/CrAaRWLRZyEeLuYJ1AtZMctqu7Sn7lXc9085
         AGKB3XwmpIr6hRNKOUw2EYRGClTCnN9kC6wSsYL8G4n6xyG5WTP1UvBxFBfQbqUvw7cj
         fwFMsI0hEU9fOGzGf4TI2WDOX+03aoa0PAcWK8GcpaxY323E8STNcs33neK5ceWlU6K+
         T9sQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUBKTD6xH8K31LY9wzx0FQ0qGMFnpStCN1+0rM7kpJw6f3Jux6m
	2trKYcbP2/UdxJ5B1yM1NI7YwjFLYBX92rTFVTayyoyMWYp/QxAVWugfcE6WBSyftASeDlG5Hz0
	om4OWDLC5cCMm/Oy2DZDyJVFvu6ZD4OLFlDKHbv/0Oyg8hGKkHIsdKX5oAQ5i724=
X-Received: by 2002:a17:906:f8f:: with SMTP id q15mr23880569ejj.47.1559651754248;
        Tue, 04 Jun 2019 05:35:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyuqW0CxLFOwR0C3muDapoDnpdrochQzeomWqX5u52ZPk/N2E9h5IGSx7DNW6GwBX3G2B3D
X-Received: by 2002:a17:906:f8f:: with SMTP id q15mr23880510ejj.47.1559651753470;
        Tue, 04 Jun 2019 05:35:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559651753; cv=none;
        d=google.com; s=arc-20160816;
        b=j2oo3reiEGt8JD6zuNcfo4pS3OjlNrFfXonEylZfBAsT2Fe5wYW3H89avUJ0cZWtb+
         8Aj4bRu9OhhFldb9Giw6EDiquXtHnl/fjQmmF5xkzpAj7DPUBAe3Glx4IO/EL36g5ddA
         qJqPe2csk1SA+Isx+yQ3GABtXG6bdXJ6ETiCwR9s0vV6TikvKGNo2rh4QV9699LkM8GP
         B85ZeSUedwFfzMPyAXRDgs8HcxftH9wD3mglqieRkzAE8npAG7p0t4tEU5B5jV9Hagmm
         zYY0QHexahx/DpdNOX8B8hUsau8eD2eQANthQsr7INdHBrvXDeHwnB77uj1LWi6ExzLo
         cFwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=r53sSBufWuLXmLBo6iCbp5CAMhHqzB7J3eE0fpQajYs=;
        b=Iy5wLmKwQ2XTST4Se1sxB1X++RV8tzdjDq9hjO/vVsPaMDGvmNpOIMyMUNBn+gOwIV
         926+FRgjBwTlG/GKO+R3gnnA/yhBq4+GsO75iXuo2Rrg689BvrtseOo79YFsp71oLLqw
         U7N/Banu9sQPUfVeELHX6hLDca/7aV8iLOqm1hFY5Sf8OShazuCvRVHo/mwjEBMJQNK7
         isuX59fG/+UFCs1o66WSn9d2tskR8lO11cVFsc/VY+MJ9ecddOL/HEg813A4k5f78eXL
         R+ZiBA6GBVeyXPTVf8z7mRhn7WFOzjrzvknCGfp2a+/hfHhE+oanOfNzQFo0IKY1iglI
         UpLw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m3si2769190ejj.26.2019.06.04.05.35.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 05:35:53 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 07CE9AFD1;
	Tue,  4 Jun 2019 12:35:53 +0000 (UTC)
Date: Tue, 4 Jun 2019 14:35:51 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v2] mm/swap: Fix release_pages() when releasing devmap
 pages
Message-ID: <20190604123551.GI4669@dhcp22.suse.cz>
References: <20190524173656.8339-1-ira.weiny@intel.com>
 <20190527150107.GG1658@dhcp22.suse.cz>
 <20190529035618.GA21745@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190529035618.GA21745@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 28-05-19 20:56:19, Ira Weiny wrote:
> Would you like to roll a V3 with some of this in the commit
> message?

Yes please. I will re-read the whole changelog and let's see whether I
can make more sense of it.

Thanks!
-- 
Michal Hocko
SUSE Labs

