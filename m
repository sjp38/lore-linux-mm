Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7897C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 08:38:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F40B2229F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 08:38:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F40B2229F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2ABA98E0002; Thu, 14 Feb 2019 03:38:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 25B668E0001; Thu, 14 Feb 2019 03:38:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 172FC8E0002; Thu, 14 Feb 2019 03:38:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B4FD68E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 03:38:47 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id f11so2179117edi.5
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 00:38:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=kac+nYvpWnH+Awusyrd/T+5HAI5jD8HrWDDBfj0cYO8=;
        b=tEGVLkM7Je0A+nZLOeVSswDFohcdm5UMIzH1+wIo7rUxdBfUBLudHxTBNDOm9ZP5Ll
         3rX9AmhEtTTAdAW886Qha9N1DtQzIC8f39WyeDj5aOFa2V+YLborBGMXTAWIINNC2IzD
         DetaWkwk1UJmFQnuMzK0hihkrpy1rmcPOusSae3LwEGrnWEsEjZfyXa27+xZNGCUx3Ja
         hq8b/BxbrkV82xFo+2rl/5hnIYFolXfCYAWU3otdNtX12fztRMOZk2JDvLRr+ifQZ059
         NXUtIKnok4t6aWy9NaiyqGqKqI9rYf85CGluK+LJ2svduiN9Cpk5OPp+cUsuH3QuS7U9
         0K3w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: AHQUAuYRUEIqDNhD++YEqYiM6isRK/lUklcd7j9hNflNEceNqjENWeht
	uURnuzrSpgD2exw6wdf4rkj2ivOIa5Mhvv7GRDcP5TkDZTLzNty/5UqL9sECztd9lGLLItk3CWP
	JOKOg3SHh/s/Lu7xeYDjC43Xffovz+vCz8qTRc6tuIGJZYoYe0Cvin179p1QX9cxUyw==
X-Received: by 2002:a17:906:3482:: with SMTP id g2mr1901830ejb.242.1550133527277;
        Thu, 14 Feb 2019 00:38:47 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYpZ1cQZd5RDWKInMKTKSSM+mXvlkps4Wg4P2pFxT22hzgac+BklqssccAnO4zOb5U4wKpV
X-Received: by 2002:a17:906:3482:: with SMTP id g2mr1901794ejb.242.1550133526343;
        Thu, 14 Feb 2019 00:38:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550133526; cv=none;
        d=google.com; s=arc-20160816;
        b=Zu6ecoZDspqjajU6GUJCguPDFILRTNnHmsMCMWikwgUIKDK86zuYJdji/j1/+gS2sM
         051iI85z5HcV/6dNxJFZgohtQg+pHaDg9+qMuc5EXLFuRzZRF1PQh2E2cEJGLL/Taycw
         QZ4cHpbt9iKqmifkCctVTfOy3LTOXzxfMHBy6tMX06hPfyGqC3m9Zqt12IXd1AhLSELH
         s7wSMrO0t/TxXwibOlmtDKIlOlPh/gn7AobnS6QBtPH+1dfT3aTvC7O2d02TTPQ7Nzo/
         Vve7HJHieImfEd9fzlKQuj61RMdssWAjmrAnuDTPnLuLYMxMe8bUpCYEygqPx+qvdjJc
         08PA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=kac+nYvpWnH+Awusyrd/T+5HAI5jD8HrWDDBfj0cYO8=;
        b=J+Gtg27pT/IwJq+V1LiwN4M1iBt0ZbTJ5fP3Dz+jWrQH0pRza/2AZWvhzvbRyifM72
         rPPL5+ZYfD0Zwh/Zrd77C67Iz7HHQmPmtVrVCM6GzPNUGwrR8C2NRnrTUi/cthaHUThH
         iqbArLcIakv6ULz36+bYqj+QZkQztKBYFNPm4OdpX8N67Y/BUhjxdAwrKH6VNevBDsOq
         GNDgeHkD1x7OM+ifJpZ6UXSG4JRT1pWNFJ8JzTipmTHNvkBl9f6dSEvPb5OoqkirYyzs
         hOzMS9qdyN6nWGT77sNptA3BH/MXa0ce3Wi1BSI+wydCPvBM/Vy6Xy5VOIcqu58ZkT3A
         UG5A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t18si826225edi.278.2019.02.14.00.38.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 00:38:46 -0800 (PST)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id CD9CEAF49;
	Thu, 14 Feb 2019 08:38:45 +0000 (UTC)
Date: Thu, 14 Feb 2019 09:38:44 +0100
From: Michal Hocko <mhocko@suse.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, linux-mm@kvack.org,
	akpm@linux-foundation.org, kirill@shutemov.name,
	kirill.shutemov@linux.intel.com, vbabka@suse.cz,
	will.deacon@arm.com, dave.hansen@intel.com
Subject: Re: [RFC 0/4] mm: Introduce lazy exec permission setting on a page
Message-ID: <20190214083844.GZ4525@dhcp22.suse.cz>
References: <1550045191-27483-1-git-send-email-anshuman.khandual@arm.com>
 <20190213112135.GA9296@c02tf0j2hf1t.cambridge.arm.com>
 <20190213153819.GS4525@dhcp22.suse.cz>
 <0b6457d0-eed1-54e4-789b-d62881bea013@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0b6457d0-eed1-54e4-789b-d62881bea013@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 14-02-19 11:34:09, Anshuman Khandual wrote:
> 
> 
> On 02/13/2019 09:08 PM, Michal Hocko wrote:
> > On Wed 13-02-19 11:21:36, Catalin Marinas wrote:
> >> On Wed, Feb 13, 2019 at 01:36:27PM +0530, Anshuman Khandual wrote:
> >>> Setting an exec permission on a page normally triggers I-cache invalidation
> >>> which might be expensive. I-cache invalidation is not mandatory on a given
> >>> page if there is no immediate exec access on it. Non-fault modification of
> >>> user page table from generic memory paths like migration can be improved if
> >>> setting of the exec permission on the page can be deferred till actual use.
> >>> There was a performance report [1] which highlighted the problem.
> >> [...]
> >>> [1] http://lists.infradead.org/pipermail/linux-arm-kernel/2018-December/620357.html
> >>
> >> FTR, this performance regression has been addressed by commit
> >> 132fdc379eb1 ("arm64: Do not issue IPIs for user executable ptes"). That
> >> said, I still think this patch series is valuable for further optimising
> >> the page migration path on arm64 (and can be extended to other
> >> architectures that currently require I/D cache maintenance for
> >> executable pages).
> > 
> > Are there any numbers to show the optimization impact?
> 
> This series transfers execution cost linearly with nr_pages from migration path
> to subsequent exec access path for normal, THP and HugeTLB pages. The experiment
> is on mainline kernel (1f947a7a011fcceb14cb912f548) along with some patches for
> HugeTLB and THP migration enablement on arm64 platform.

Please make sure that these numbers are in the changelog. I am also
missing an explanation why this is an overal win. Why should we pay
on the later access rather than the migration which is arguably a slower
path. What is the usecase that benefits from the cost shift?

-- 
Michal Hocko
SUSE Labs

