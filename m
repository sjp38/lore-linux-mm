Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A0ABC06510
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 07:56:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D82E6213F2
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 07:56:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="NCUYHS0P"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D82E6213F2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6EA0A6B0006; Mon,  1 Jul 2019 03:56:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 673F38E0003; Mon,  1 Jul 2019 03:56:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 514068E0002; Mon,  1 Jul 2019 03:56:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f207.google.com (mail-pg1-f207.google.com [209.85.215.207])
	by kanga.kvack.org (Postfix) with ESMTP id 1ABB86B0006
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 03:56:40 -0400 (EDT)
Received: by mail-pg1-f207.google.com with SMTP id d187so4543727pga.7
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 00:56:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=+twzjYVpRVjpacx4trZB94509DTZgYQcQMDYuMNcsR4=;
        b=uWE37r8HZtenZQWBx84C5/i6U8unsxPaYTpA+kSHQdENGew05UZCIgXRo0SiWwPi3P
         bFfGBIHhVXPjNw2LqroA2ddqBjYz7Pu2s3L0OrFggh4SYlD8hWKdZPrWy2b/51rWpJP6
         qU/muzoPnGlPbONH/RZVO4z94jQh9dr9imPTOO/y+M/+7YgMJPcT6uRD5KHq940SXZ40
         9dGoYZm5I4b67nDGdgmG8/iV5H8QtuGdxU39BWKAOQDOTgOrOwTCTpg+bhGHfyx0E1Qd
         zQSvQmVni6luDvRafKqERyP+XN5TDE+qrqKiam9HFLnRjOnLdUv6MQPXF5fqZNhjzLKb
         uBcg==
X-Gm-Message-State: APjAAAWcljUzQqs17dH0m4NSew3wIzP29xxdCH5k3F8C6vL5ux18fHSL
	etdT5r4He+pDcMTI9gdc1uj0I9pr8xnfl6Kiq1FWlbz5DQpTgCmP0VfMid5r6soVH/FtwxM1zqJ
	1kY3Skmbx834+vw/DeXZT3snsNMBew50z7o8wJSnw6sufHYHjaYIYbXs9AdKza4HGRA==
X-Received: by 2002:a63:4104:: with SMTP id o4mr24183010pga.345.1561967799677;
        Mon, 01 Jul 2019 00:56:39 -0700 (PDT)
X-Received: by 2002:a63:4104:: with SMTP id o4mr24182972pga.345.1561967798908;
        Mon, 01 Jul 2019 00:56:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561967798; cv=none;
        d=google.com; s=arc-20160816;
        b=rLy7phHNEP0wmHbHWkACi728Wx4maG+WdDfCfWYGxndh95esSCRpx0VltDjhS2XWvD
         oHMU0Up6eLGdL0CgK9B4gDT1Ze4yavM7GjW2tI8Iu75B1k0tPPahYA4xMXpLwP02yteU
         4YJqGSLYGEDhDnmviwGqjEq6Tvl9G6mKW+YRq+FSnKYUBZDyQT2qxLwtDy3p6q+bLA2r
         Hr+Glp/SYlumj0uSYCgkTB4CYuoi3pz5AyosWiWEV8BPb5tvWAf2mKMjq/d76ZlnnmXa
         nbn5mTas20x0iPfijbCeghRWf8e8Ec7kY26ofcUrsyGbV31QghI4HECFq6If361JllQH
         IBug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=+twzjYVpRVjpacx4trZB94509DTZgYQcQMDYuMNcsR4=;
        b=SNwbokCuFfokGyHnaUsVEht8YYiTWlWIyL68FDT7DTqV62kIYWnCmAQF5UmQBgakqm
         yBnX+vaw7gHlBY/ytSliCoclmfeZGRAAz3kVfEK17MZx7flDczL0I/xbh5dKqhq16yWV
         b7u8zNBzLYPkbEfRbqxhkSUwCXgtzRu0b+iMD229E1xvoiA+PLy9M5Dvj5hwGxahUldr
         09O9iQXSIaC4b2h+qlMxGMzd6ZR9Az6HqF6ferzZP1jFhCq41tI6QkWo1ZUxj7lG39Jd
         70XWf4nyzwMjP0LiXmj3sl6UyJWgOmye/ySqrQ1Vm8wSmoO4CBmNnpyvkx4jlCBTPAF2
         GYtg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=NCUYHS0P;
       spf=pass (google.com: domain of vovoy@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=vovoy@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w20sor11536541plp.27.2019.07.01.00.56.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Jul 2019 00:56:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of vovoy@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=NCUYHS0P;
       spf=pass (google.com: domain of vovoy@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=vovoy@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=+twzjYVpRVjpacx4trZB94509DTZgYQcQMDYuMNcsR4=;
        b=NCUYHS0PUlBnq+9KUz6uY9duejMIwMu4rMg9X7onsD0fH/oIyThXHJHPrtnSc1V48K
         mwOXzdoJWMRsV/Nmapl5JdfEmmamY6OPDUoObkcs5JkIjL3NgtN2ASgrklfejqb7wpWm
         R/w9aVDSUub8VCFUBjyCa1wlgeejhnwrI+6NI=
X-Google-Smtp-Source: APXvYqysC4YyV+eiee73csmXAhFAB6RLW8rCAw1OyNcYhUuZizAOjeak5niISZrBjh6iF1wgIBW1dw==
X-Received: by 2002:a17:902:968c:: with SMTP id n12mr28901036plp.59.1561967798535;
        Mon, 01 Jul 2019 00:56:38 -0700 (PDT)
Received: from google.com ([2401:fa00:1:b:d89e:cfa6:3c8:e61b])
        by smtp.gmail.com with ESMTPSA id m13sm8127237pgv.89.2019.07.01.00.56.36
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 01 Jul 2019 00:56:37 -0700 (PDT)
Date: Mon, 1 Jul 2019 15:56:35 +0800
From: Kuo-Hsin Yang <vovoy@chromium.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>,
	Sonny Rao <sonnyrao@chromium.org>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH v2] mm: vmscan: fix not scanning anonymous pages when
 detecting file refaults
Message-ID: <20190701075635.GA79748@google.com>
References: <20190619080835.GA68312@google.com>
 <20190628111627.GA107040@google.com>
 <20190628143201.GB17212@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190628143201.GB17212@cmpxchg.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 28, 2019 at 10:32:01AM -0400, Johannes Weiner wrote:
> On Fri, Jun 28, 2019 at 07:16:27PM +0800, Kuo-Hsin Yang wrote:
> > Commit 2a2e48854d70 ("mm: vmscan: fix IO/refault regression in cache
> > workingset transition") introduced actual_reclaim parameter.  When file
> > refaults are detected, inactive_list_is_low() may return different
> > values depends on the actual_reclaim parameter.  Vmscan would only scan
> > active/inactive file lists at file thrashing state when the following 2
> > conditions are satisfied.
> > 
> > 1) inactive_list_is_low() returns false in get_scan_count() to trigger
> >    scanning file lists only.
> > 2) inactive_list_is_low() returns true in shrink_list() to allow
> >    scanning active file list.
> > 
> > This patch makes the return value of inactive_list_is_low() independent
> > of actual_reclaim and rename the parameter back to trace.
> 
> This is not. The root cause for the problem you describe isn't the
> patch you point to. The root cause is our decision to force-scan the
> file LRU based on relative inactive:active size alone, without taking
> file thrashing into account at all. This is a much older problem.
> 
> After the referenced patch, we're taking thrashing into account when
> deciding whether to deactivate active file pages or not. To solve the
> problem pointed out here, we can extend that same principle to the
> decision whether to force-scan files and skip the anon LRUs.
> 
> The patch you're pointing to isn't the culprit. On the contrary, it
> provides the infrastructure to solve a much older problem.
> 
> > Fixes: 2a2e48854d70 ("mm: vmscan: fix IO/refault regression in cache workingset transition")
> 
> Please replace this line with the two Fixes: lines that I provided
> earlier in this thread.

Thanks for your clarification, I will update the changelog.

