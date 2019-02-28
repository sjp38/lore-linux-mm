Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABBF0C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 14:08:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 746542133D
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 14:08:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 746542133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 113108E0003; Thu, 28 Feb 2019 09:08:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 09DC48E0001; Thu, 28 Feb 2019 09:08:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA69F8E0003; Thu, 28 Feb 2019 09:08:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8FEDD8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 09:08:19 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id f11so7147680edd.2
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 06:08:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=rbHj+zoEV5nKXdYV1pfwFtFwHqMyZlHbszkxbd5FLE0=;
        b=fhDYyv+p2y6lVHuFc5s4UvF3b5Td2kH3pQ0uQjRt0MTOLgcVDltl0PrUb0H2OfPi/s
         flLhZOVTXi9fPHhNvWOn3vNBOIWpWXvW5e/AD1KPDaz25UTV8oHHaMWDzmVdKuix2cVF
         FHqvLgAZ1khOb+NpAmL7i3kKOukgGz8QBV9gJZ0Gq3rHRO9imj8J/nQ7OM+1xIpA4PB5
         /MrkD7Uyv7d36PZvfiA7zcdE5Ej+u3gL8XEEczfBtg3T/XY2Vd+BjWfprrSIYC/jchk9
         TXzqMibofwoiJp0jAP6ZffW2XjB4q9MjDQSZecweVVw008MvjRKkS2DEgDLEuX2+6TlJ
         Qzbw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZlCq+SiKSS5Ag2OHfalTs7Ne5EWanf/3Ind+U52qOlkkBTXnMu
	cjDbCE3FxXG1D2y7tr+9Oy+e97ij1k2aS9O8Y06VBvh3R1FAYCNusjtLBKB0ufGb1D0JkXMHiiK
	vd/Y2oUzbP1c9i0sGN2DRdhzluzXxNfakCrOanOnGzYLJAmNkzupUY1a5mMixwdk=
X-Received: by 2002:a17:906:d552:: with SMTP id gk18mr5554642ejb.55.1551362899132;
        Thu, 28 Feb 2019 06:08:19 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYs2BvmeFQKqkpVlH9B2t7qFPZpFWDgLgSSgf19VV9EhGjpneTg3KZVEMby4GM6AP3jfpbq
X-Received: by 2002:a17:906:d552:: with SMTP id gk18mr5554586ejb.55.1551362898023;
        Thu, 28 Feb 2019 06:08:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551362898; cv=none;
        d=google.com; s=arc-20160816;
        b=ZzJe7Ltnodx+pzrtbBJXImtSDqOke8COy+OkAE0gNSt+TmJj8BBPFIwRYapwmFIdfq
         vsy/o5Dxmiw5vUkoiRWEyEvTab5QANRi9Sg22AZCRIq6f1t06FMdbTF8wFFJeKAT8D6H
         3Uah3jUW2yJ8fTYywEFBJ2qmyA8/WaU2iIYC9lqyzKUAzCZ3yCgno4+oB7oJbWW9JgOz
         wAiMf8w8mIKwWqlgnuQZH2sO2qbQtMP+uqwDC65HJOFrO2QCAyjZ8qi8riXs4VW9Qwhf
         chSVxTePLLdvOyf/Lrd/zZFJNbxR9LeICIGf+98qHhMhw3MGnkV5RgndIEZxHG2BSdF4
         rYVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=rbHj+zoEV5nKXdYV1pfwFtFwHqMyZlHbszkxbd5FLE0=;
        b=nVvX5mKLOjcD1bQJI7epjarkx86qoelxm9f2rkJdmmnHi/OLhuzXO3nzPIo60Tov8O
         C+qyu3mq+Fa8T1Ol9z2jvTPOGSKPc3Q7fub+JgBHeLkKaod3HhjAyXPYttbDWdE8QHaX
         +eTOXwnoQ7Z72TfOLkIuc+VtF69kS58w6HjF+uqzNzYlss5dqpJozEqBVmJLX42L3BEL
         qCJ2injRdr3nbvKkpBARWudMKBt2PxgAMwzJnHqJxqkZT8EiB2C1q2vabgOhMrF2GyQG
         Imc+QTWrEXdYyc6WFaB5rAvNqkhgJSnlz7cfoxzJdHgIUOE0GGkcdEt0/oHuDXZ/Lwvl
         R/0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f7si7089014edm.167.2019.02.28.06.08.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 06:08:17 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7B614ADAA;
	Thu, 28 Feb 2019 14:08:17 +0000 (UTC)
Date: Thu, 28 Feb 2019 15:08:17 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, david@redhat.com,
	mike.kravetz@oracle.com
Subject: Re: [RFC PATCH] mm,memory_hotplug: Unlock 1GB-hugetlb on x86_64
Message-ID: <20190228140817.GD10588@dhcp22.suse.cz>
References: <20190221094212.16906-1-osalvador@suse.de>
 <20190228092154.GV10588@dhcp22.suse.cz>
 <20190228094104.wbeaowsx25ckpcc7@d104.suse.de>
 <20190228095535.GX10588@dhcp22.suse.cz>
 <20190228101949.qnnzgdhyn6deevnm@d104.suse.de>
 <20190228121115.GA10588@dhcp22.suse.cz>
 <20190228133951.outlsq7swhp3nffr@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190228133951.outlsq7swhp3nffr@d104.suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 28-02-19 14:40:54, Oscar Salvador wrote:
> On Thu, Feb 28, 2019 at 01:11:15PM +0100, Michal Hocko wrote:
> > On Thu 28-02-19 11:19:52, Oscar Salvador wrote:
> > > On Thu, Feb 28, 2019 at 10:55:35AM +0100, Michal Hocko wrote:
> > > > You seemed to miss my point or I am wrong here. If scan_movable_pages
> > > > skips over a hugetlb page then there is nothing to migrate it and it
> > > > will stay in the pfn range and the range will not become idle.
> > > 
> > > I might be misunterstanding you, but I am not sure I get you.
> > > 
> > > scan_movable_pages() can either skip or not a hugetlb page.
> > > In case it does, pfn will be incremented to skip the whole hugetlb
> > > range.
> > > If that happens, pfn will hold the next non-hugetlb page.
> > 
> > And as a result the previous hugetlb page doesn't get migrated right?
> > What does that mean? Well, the page is still in use and we cannot
> > proceed with offlining because the full range is not isolated right?
> 
> I might be clumsy today but I still fail to see the point of concern here.

No, it's me who is daft. I have misread the patch and seen that also
page_huge_active got removed. Now it makes perfect sense to me because
active pages are still handled properly.

I will leave the decision whether to split up the patch to you.

Acked-by: Michal Hocko <mhocko@suse.com>

and sorry for being dense here.

-- 
Michal Hocko
SUSE Labs

