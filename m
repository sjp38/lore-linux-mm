Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BAB62C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:43:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 829AA21473
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:43:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 829AA21473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E9F66B0008; Wed,  3 Apr 2019 04:43:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 29A216B000A; Wed,  3 Apr 2019 04:43:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 189806B000C; Wed,  3 Apr 2019 04:43:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id BC0446B0008
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 04:43:47 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c41so7089388edb.7
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 01:43:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fUi6jnwOj7GxAcA1WAN47iHF0Jz/ddP9Lkk4limqD9s=;
        b=Jfi9Ed/olDFvYIfniNUSAvaQYboUH1fPq8+/KQTO8WEaQNLHKRl+6Vh+8wiX1wkj58
         PWI7ZjxOW488uMglFIleyqEh/t50BDi35P5laT3pOJ1ygocuPh0WtAZ5YPJGPNdXQf9R
         YhLltwzgITc+JBKL7AxNxx01mIOef8a/N4QcdreGgx6Ec5GwlRTbT8N9xLHO8cWnoIKJ
         4I03bV4djVm5HsDVMEVwp7rPFnZBnLGbQE0KzxjXLcf+HJWkj5445ACAb8Uv0WB5wXG0
         EUhcZMv2Wj0SdIXrtgCDis1jcZ+QsB1uY9ZKkT4Vmq3alit56pZVe+VFmSW1MuBXn/R/
         lA+g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXxUbOgjvl+pWtii9tb/1Fckxr9zsBiBEuDVHCUKwYYFV6fsGKo
	cCV5XK8Ip/c9Mu/cYTArn3DKAy3XRRZEnVNczfwGBjbuS9L1J48wCXBwSgZLKYo6crCLUYbmiEd
	iOkkBGJx/KeBgn3zHcNpiF6nkqq48SIZ3OKBu7iXDemqAcPIqt1bOsSHvVkTreXM=
X-Received: by 2002:a17:906:905:: with SMTP id i5mr43172414ejd.23.1554281027313;
        Wed, 03 Apr 2019 01:43:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwLCb8vPLcqVIJ0upojfmfnLqNlmP6L2QupWUXP/mGoCyU9v/MTmNwShjfDy5j3JDwE3bc/
X-Received: by 2002:a17:906:905:: with SMTP id i5mr43172376ejd.23.1554281026544;
        Wed, 03 Apr 2019 01:43:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554281026; cv=none;
        d=google.com; s=arc-20160816;
        b=iskY09hiH0Ol90jrxOxbRT30YBO0N3mYfeuJQlmWKPxtPFh6OpVo82X6C66/9+bS+c
         d3sp0+9gEzbxHb1z3RVtP/TAXO69h1hFD92fPkMmTsZ+DtDT0BJ+HmAu9NttET7WGnjC
         7ABcIVU8sqir+cJYX6Sbad9htNfT3kEIacHV2BrztJWG+Z+ty8lxsEs7eAhwXgryW0SU
         t9aX+g2q0r7LX6YkfO6tdizfDdzn00DbCAURTZlCNHyuKf/TKOnd3k0e1BSVuH28vx+U
         eML8yrfwuJVHedjvMEUViQURd8Rp5wCeIHyb6UGdZrUseEJrI8/g6AQfwERJIDr+CdRc
         KDcg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fUi6jnwOj7GxAcA1WAN47iHF0Jz/ddP9Lkk4limqD9s=;
        b=gq2bmoRGXyNuDJctAxFUoMMn0K0cMXPJ1HnOEduOKtZ7YG0EwJ06m9CAiXBrJyXlv5
         FhqJavhTFr84mB//qm9AS3vU2Y3RVPxid6ucDQRFT/PNM8ti6lERbyjMx8DV34044SL/
         oRdjwDzMycX3rr7hqWv0ejOplv7pN81sk+4RQG0UG47HdyPihM/KFRdeO+c0E+Z3Ls9M
         m5OxZJE83Or2y56PEhOJQ+Sajp3I+pqs6SAuecmg98a7eoLdzhGVWUSqh/xQMhnLojAy
         QnKvdo7cq3Wu2a2SyuvCpS7jTK+brlCYEJjVFU0TE8HpwElPGE4H6GFLdYuYJzO5lYrN
         AShg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g56si911431edb.1.2019.04.03.01.43.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 01:43:46 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5E1ABB027;
	Wed,  3 Apr 2019 08:43:45 +0000 (UTC)
Date: Wed, 3 Apr 2019 10:43:44 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, david@redhat.com, dan.j.williams@intel.com,
	Jonathan.Cameron@huawei.com, anshuman.khandual@arm.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 1/4] mm, memory_hotplug: cleanup memory offline path
Message-ID: <20190403084344.GD15605@dhcp22.suse.cz>
References: <20190328134320.13232-1-osalvador@suse.de>
 <20190328134320.13232-2-osalvador@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190328134320.13232-2-osalvador@suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 28-03-19 14:43:17, Oscar Salvador wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> check_pages_isolated_cb currently accounts the whole pfn range as being
> offlined if test_pages_isolated suceeds on the range. This is based on
> the assumption that all pages in the range are freed which is currently
> the case in most cases but it won't be with later changes, as pages
> marked as vmemmap won't be isolated.
> 
> Move the offlined pages counting to offline_isolated_pages_cb and
> rely on __offline_isolated_pages to return the correct value.
> check_pages_isolated_cb will still do it's primary job and check the pfn
> range.
> 
> While we are at it remove check_pages_isolated and offline_isolated_pages
> and use directly walk_system_ram_range as do in online_pages.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> Signed-off-by: Oscar Salvador <osalvador@suse.de>

Can we merge this even without the rest of the series? It looks like a
useful thing regardless of this series. Sure we do not really use it
right now but it cleans up the code and actually removes more than it
adds...

-- 
Michal Hocko
SUSE Labs

