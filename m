Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1ED6AC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 12:11:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D61AD2133D
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 12:11:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D61AD2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 736858E0003; Thu, 28 Feb 2019 07:11:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E5368E0001; Thu, 28 Feb 2019 07:11:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D4008E0003; Thu, 28 Feb 2019 07:11:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1C2368E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 07:11:18 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id f2so8303979edm.18
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 04:11:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Xon0kn15d0/SV7aD/V/3L55otBT/BsTvluSbnJwJf70=;
        b=bRjtzQKIBGkonujpqeb27sh+lS8Hfn//PZ3BqXWHjIYHEzY59nW/MSH55bRyI9fhIy
         e96ZBUNO8ucSfGur6FDPPI2MfpE/OLS0ppauwKFaIfB0LjndBxc5Ir8/yQ0qEhIXHtZe
         +jEfFrcbwNEtjpcz6iVLp/x7hu4HWPCsauqplvxnFrNgGngNEX0mULG9YlYHEe5616fG
         aKrxwbrj29fABOVsxq6B/eE8aKpiNeyRoVSqgMq0TUavHIHBjeoyYf/8bh7K5BkeNyg1
         W4iWZ9nbAug9gK92W/KZWbnSnPBIpKnNIwXnGrR7wjvYUHn5lwipzl2QlIOJL57epxRO
         9NAw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuagQG2hC5c72O+kRXdY8ZtNA4jy2mYJ8Z+kYhi0QcsEzo8uYU9+
	GPvzsFmku7yAcnX8VZ1TsQ4VbiLiZmDM8PkR4CKbh2BAB7P+JYAGtH4f2ChFiijFtyYDbl54Agv
	YEp9YSIaWR89Y3aPJtMzTWhwV7NvGnzOoXHz/K+czJZ3LQcIwEv1eQwpvnw71W4U=
X-Received: by 2002:a17:906:81d0:: with SMTP id e16mr5172373ejx.243.1551355877674;
        Thu, 28 Feb 2019 04:11:17 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaBYMNt5K9+/Cm5Scq4DbTckeD2OnYflt8qX4YxqM41Tv6aprLLcZb+Zef62nqIPzQ3lAod
X-Received: by 2002:a17:906:81d0:: with SMTP id e16mr5172334ejx.243.1551355876791;
        Thu, 28 Feb 2019 04:11:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551355876; cv=none;
        d=google.com; s=arc-20160816;
        b=id2YQ9DH+udYiqDPItWok58La3xyPk5+lX9NKhezeVee/LDO89T7DsZCnQDO6XK8wZ
         XNK14l5ldZb/LldLHl6fUdvAXWfuFM9Rdn2SHVk0WXTTF72ZePLk5tSuCePlmRz1tlzV
         5QUqMm192y6IHuzQn4mXLTAh26pZOA3ywHkpMjjOKlTWQI9uVHVBtX9sIoJ3gvnxRVma
         K0YQjNXrjbCOyc14RWljlgEkkSzTJXmOBKu6tR9RCQWKhT7R1Kv+UtASznQ9ZMFqYJJU
         lXJnvr5OX6hC6SubWrINdjEkPR3TrAKR7flHkWsCrf0YazSlsBl4fUReY/sDZl5dIpIp
         hfMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Xon0kn15d0/SV7aD/V/3L55otBT/BsTvluSbnJwJf70=;
        b=yn8xiBrC6fNj1ZKnJagHyodTlvoNUEu72K1r3CIhegfSRAoAFXhpIcbmmiVPrCyG+Q
         /QIarQf1XakRYgt/SA7gx5FdseIsB1fbc7OibRAdZmL9cuPyq0wgfVwEp+aQdg5nQUAa
         ETG06ptiV7NnKJb0F3GKCEd52qV8KqkhRqrQKq5hoMKwkXZSQ8reCASni1X8DLTlPF0K
         /xNMbRq9kXvYwq0sZMAfFqV/H1baUEiumCcBauyNp6nyVFTIcsksNV0uMGVxTju2l+7M
         6j5phvIS9WZRT+Ze1Nb5Es/F6S/tSqIO3dBQjcEhIbpZqVKPfSKzF9u279QmynhWkuSW
         TGkw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p11si1699131ejq.186.2019.02.28.04.11.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 04:11:16 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4E220AF8D;
	Thu, 28 Feb 2019 12:11:16 +0000 (UTC)
Date: Thu, 28 Feb 2019 13:11:15 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, david@redhat.com,
	mike.kravetz@oracle.com
Subject: Re: [RFC PATCH] mm,memory_hotplug: Unlock 1GB-hugetlb on x86_64
Message-ID: <20190228121115.GA10588@dhcp22.suse.cz>
References: <20190221094212.16906-1-osalvador@suse.de>
 <20190228092154.GV10588@dhcp22.suse.cz>
 <20190228094104.wbeaowsx25ckpcc7@d104.suse.de>
 <20190228095535.GX10588@dhcp22.suse.cz>
 <20190228101949.qnnzgdhyn6deevnm@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190228101949.qnnzgdhyn6deevnm@d104.suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 28-02-19 11:19:52, Oscar Salvador wrote:
> On Thu, Feb 28, 2019 at 10:55:35AM +0100, Michal Hocko wrote:
> > You seemed to miss my point or I am wrong here. If scan_movable_pages
> > skips over a hugetlb page then there is nothing to migrate it and it
> > will stay in the pfn range and the range will not become idle.
> 
> I might be misunterstanding you, but I am not sure I get you.
> 
> scan_movable_pages() can either skip or not a hugetlb page.
> In case it does, pfn will be incremented to skip the whole hugetlb
> range.
> If that happens, pfn will hold the next non-hugetlb page.

And as a result the previous hugetlb page doesn't get migrated right?
What does that mean? Well, the page is still in use and we cannot
proceed with offlining because the full range is not isolated right?
-- 
Michal Hocko
SUSE Labs

