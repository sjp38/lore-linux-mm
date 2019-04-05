Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30F1DC4360F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 07:14:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8666217D4
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 07:14:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8666217D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2AD8B6B000C; Fri,  5 Apr 2019 03:14:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 25C976B000D; Fri,  5 Apr 2019 03:14:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 14CB16B000E; Fri,  5 Apr 2019 03:14:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B8CAD6B000C
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 03:14:25 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id s27so2739906eda.16
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 00:14:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=YBxsHgO8NPXe+GescGixrsB9nea1nkngHZFZZlUsP64=;
        b=O9cJ1An980g7BpdojavZ21Zr1Opy4m13jVHuOeQPaAPpHwAD8OlZcNiRvpou/sBKoB
         Sd9y9UwgzUQcTSNUhRJm6YhzW5MgoRA/4MlsSLd8KzkzeYaYKCRFPBeDqdxOeKbc+KlN
         CnYiVMFVRvidpY7rjCYMWFQEvS4WkQqU2hVu33NmPQOwizBXcftfPVIbBEWFoLJY1JCS
         UMiI3xxHrIz6HGdFnk7p+J2l/zfVz4PrDiOQyCdum8ZG6chPxsX4kAWOtQfk2CujHl2Y
         zjskhwCZCe92I8bdTaQ/1BCV5mSGlDVu2O4++vf/rMRh82AMss26pbUY2Z1wDjAWnLRE
         Uujg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWWGjbWWEMAUsVSQiSGzAu/rxP1BKZs4kxjYSzMvohIZYKkOyEq
	o7LuX3bFqJ8+/H8cC/E/BMHJD/GzW/ZhUCYDTE19QeSCQYBTrIFlJQkLGRMKM+rfkKOJApdqN+m
	5Po36CMMFmBYwyZhTRgFKiE1EpQWsLNmkogFfVtoMkpZZdhY9f0jhxlnmDfpi82g=
X-Received: by 2002:a17:906:f14b:: with SMTP id gw11mr6230877ejb.59.1554448465140;
        Fri, 05 Apr 2019 00:14:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy15v13O4kbVPyLJOBDiaJVvFemIZJbflnf3cHwtEzOs4aM0X8bV/BYYXOeOkqPEafkxEHJ
X-Received: by 2002:a17:906:f14b:: with SMTP id gw11mr6230833ejb.59.1554448464156;
        Fri, 05 Apr 2019 00:14:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554448464; cv=none;
        d=google.com; s=arc-20160816;
        b=NdFovfPlvWW+p+4BXN5FCXRrOrwsGfVVZbEhSzHI1eojsROkzvWRD+QCXP6WFYFTvL
         peBaawuGhhB55KSi7bw+uEkmtjBR5VuiMs8iJGWvsQztR9zRMYrzqZ1UHtAUPyIHBxen
         keSO7YE9Sbdr8ICxqkfil7J8boO8XJ1027kO0o13rMBYBf+1AoiMzdiiKQxjjFAKqMwQ
         qi65X7hiVG8N5yUI7We7ZuAkpYDU7zTighQoNSzFddjguoRSpBUVs1BJ9Mo7oSwI6JAB
         J5qBXwMz0B7k42RSHnPIRqvvk4jttdNdT7qwyQV2fTVeHtFMDUbTwVVnNSNyW2tNNQ2c
         1Jkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=YBxsHgO8NPXe+GescGixrsB9nea1nkngHZFZZlUsP64=;
        b=ctJxCO7NPXbOnb6XdxacBWzSDs+vu8L5DqPdAqPWL/voL6tLX7Arhz/J8zMLKKknl6
         vNAj22cYs0FbYGfdRi36ShIUOE3sW6SrgKP8tccEscW04KDQ1Ybxd4cJ7VsTZzS66pmc
         d6BY7HpAGTQs1NOGEB/+igrJBoABddNxvE3bd0nLVGBdIIRbW1I+WFlWM14CcZwJC4cR
         YrAtZ4c9wIST9sGT2IjmNB/vvLS2Dv0Ss8kYbFnyY/h65JMDArAQsubAgl0vhnS6/FAB
         bsEq9NZG7BKw00Gp3966zs7p5d/r7fUyhUIUTZy5xKHGGMFE3+O1uQDJruhteqBCUmA8
         uSmw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d27si2842005edb.436.2019.04.05.00.14.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Apr 2019 00:14:24 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5CCA1AB48;
	Fri,  5 Apr 2019 07:14:23 +0000 (UTC)
Date: Fri, 5 Apr 2019 09:14:18 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: Oscar Salvador <osalvador@suse.de>, akpm@linux-foundation.org,
	dan.j.williams@intel.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH 2/2] mm, memory_hotplug: provide a more generic
 restrictions for memory hotplug
Message-ID: <20190405071418.GN12864@dhcp22.suse.cz>
References: <20190404125916.10215-1-osalvador@suse.de>
 <20190404125916.10215-3-osalvador@suse.de>
 <880c5d09-7d4e-2a97-e826-a8a6572216b2@redhat.com>
 <20190404180144.lgpf6qgnp67ib5s7@d104.suse.de>
 <5f735328-3451-ebd7-048e-e83e74e2c622@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5f735328-3451-ebd7-048e-e83e74e2c622@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000061, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 04-04-19 20:27:41, David Hildenbrand wrote:
> On 04.04.19 20:01, Oscar Salvador wrote:
[...]
> > But I am not really convinced by MHP_SYSTEM_RAM name, and I think we should stick
> > with MHP_MEMBLOCK_API because it represents __what__ is that flag about and its
> > function, e.g: create memory block devices.

Exactly

> This nicely aligns with the sub-section memory add support discussion.
> 
> MHP_MEMBLOCK_API immediately implies that
> 
> - memory is used as system ram. Memory can be onlined/offlined. Markers
>   at sections indicate if the section is online/offline.

No there is no implication like that. It means only that the onlined
memory has a sysfs interface. Nothing more, nothing less

This is an internal API so we are not carving anything into the stone.
So can we simply start with what we have and go from there? I am getting
felling that this discussion just makes the whole thing more muddy.
-- 
Michal Hocko
SUSE Labs

