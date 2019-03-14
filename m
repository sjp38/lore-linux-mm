Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECD87C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 08:22:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ACC7E217F5
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 08:22:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACC7E217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 403D58E0003; Thu, 14 Mar 2019 04:22:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B1288E0001; Thu, 14 Mar 2019 04:22:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A1528E0003; Thu, 14 Mar 2019 04:22:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id BE50B8E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 04:22:23 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id o9so2038806edh.10
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 01:22:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=RnHds/Jfu70cnPFRGiPA/FZ8Dgg785YUCb/fzTZTik0=;
        b=Q4BujvykaF8QKqq0gztWOQWuu731iqzySEgQvn2sXrvQpATcsVaG+m1eS4sX0EH1X5
         V8y2lLQe5otrBsZffADdONOSmjG8L9SxCtMu8SQTyLq5h1aqqwJeqSU+d9xBEXP8TzqM
         58eNsWIpUs8PsRr0zBSy2xrguf1XQVGfSP53XkJPBjhXIh7YfoiQCSyuiup+B/WO5rBv
         m1ytM0rvvXms7qNYwUEsHJhzJrSmd/0Vj6gjsPVpge11bbKIqDrRyRcs0uhddKZnzXXM
         iyTohsUzVNs5Hfv2vTYdCem3cGfV1hn8Wr3wgwS8A5CQq8NFPC6syMplfSL4sqZvgtYF
         gqlw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAV5odNOtHEvudGau0CzY9VtQ+WlwwELcGVLT75bQi/sGD/rAWjV
	khQvkywKy6wT5HcOV6nHTqJ+1tUGSl4bZY0UTDUXXBddxH1dCKcGqFCudwb0SqYzqkrtp+EEcsg
	IxmNIAhip7FM6PVtGNusJDYDm7VwZtpbctFuTllM0ZSXMc1TTmhwwfekCTNT77xQ=
X-Received: by 2002:a17:906:2a86:: with SMTP id l6mr31566447eje.186.1552551741886;
        Thu, 14 Mar 2019 01:22:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz0R60S1jpDPc0u9r6zDfmoOir+AnE0IU/CK6z7/AXhyVLNKZ1OKNTt654gW5UF/ursbsGr
X-Received: by 2002:a17:906:2a86:: with SMTP id l6mr31566366eje.186.1552551741005;
        Thu, 14 Mar 2019 01:22:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552551741; cv=none;
        d=google.com; s=arc-20160816;
        b=SlB4160jBSmrigsLxwHTo79UAF3zOh68tJ8jovY8Iy/zCewSTwwUi6/fSGpkGcyYSn
         /hZgIkAXsT93a56gWnp4SP+C0hUcBCCyHTvEDXc8TkQA5MhaBu0gQ/ffoF2mtdpnJWP9
         jLH5lBafrhFX3YlmfYMBBgDmVRZxcIpJ9LVVyJSPImaGVsBlcGz8g1vLKjJ4c3qzCzCq
         jZgkHG8uAPLQVGF8rTlmF78YqyBAu1asi6iSpjUu3vD55GJdXVZDxVdplhZPkQJTyUx9
         eM1hw4rPMUlek0SHg4yndaldmHCF5ipzxI6z6SWK0pULPbaRh7w8IlGlr5BUOEcSJZ9K
         IR5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=RnHds/Jfu70cnPFRGiPA/FZ8Dgg785YUCb/fzTZTik0=;
        b=x5O1erRu8OjkuYOFP7JyH8bUXhPhm8L6Yiw2qky5QpCtypyTYzfn/A/pMe9A11rlXM
         faG5ae8Y17vnvZXemS8mwamUcG3BvNgqtZQu+2mH2svTmbp+cko114VZ+Z0WBoym/8my
         Ylll64Xzbx8As2kYO8BzYTwKhLeENcyE9KxRoFnIl+ow2Btw6sq50M0a22heggFw061Z
         q8hoaH3o8xGCNNPoLIjky27qfRmfkfEIClqAksQAd/ADSZUPzVFOqLdkyUSr2x57AXSj
         dkQEDn7psiYeYcflq0dVynr8rS5qzsbYV+05YrXTCY6Z8JD+LyE4vlo32gS/rJlwc19e
         Yfxg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n24si1144761edq.65.2019.03.14.01.22.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 01:22:20 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3D8E2ACE3;
	Thu, 14 Mar 2019 08:22:20 +0000 (UTC)
Date: Thu, 14 Mar 2019 09:22:19 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org, vbabka@suse.cz,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] mm/hotplug: fix offline undo_isolate_page_range()
Message-ID: <20190314082219.GD7473@dhcp22.suse.cz>
References: <20190313143133.46200-1-cai@lca.pw>
 <20190314080922.dk5ljg7fbtarzrog@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190314080922.dk5ljg7fbtarzrog@d104.suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000010, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 14-03-19 09:09:22, Oscar Salvador wrote:
> On Wed, Mar 13, 2019 at 10:31:33AM -0400, Qian Cai wrote:
> > Also, after calling the "useless" undo_isolate_page_range() here, it
> > reaches the point of no returning by notifying MEM_OFFLINE. Those pages
> > will be marked as MIGRATE_MOVABLE again once onlining. The only thing
> > left to do is to decrease the number of isolated pageblocks zone
> > counter which would make some paths of the page allocation slower that
> > the above commit introduced. A memory block is usually at most 1GiB in
> > size, so an "int" should be enough to represent the number of pageblocks
> > in a block. Fix an incorrect comment along the way.
> 
> Well, x86_64's memblocks can be up to 2GB depending on the memory we got.
> Plus the fact that alloc_contig_range can be used to isolate 16GB-hugetlb
> pages on powerpc, and that could be a lot of pageblocks.
> 
> While an "int" could still hold, I think we should use "long" just to be
> more future-proof.

I would rather not touch that for now. If we really need to change the
type then do it when it is really needed. I pressume more things would
have to be changed anyway.

-- 
Michal Hocko
SUSE Labs

