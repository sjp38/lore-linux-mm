Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EEEBC282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 11:06:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B16F2064A
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 11:06:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B16F2064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D1986B0007; Wed, 17 Apr 2019 07:06:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 057B16B0008; Wed, 17 Apr 2019 07:06:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E3AAF6B000A; Wed, 17 Apr 2019 07:06:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 93AB96B0007
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 07:06:19 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id h27so12236351eda.8
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 04:06:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=GKkukveh+vsboSnZ8MBlwj76eeNG6OpZ6t7ta7GWu70=;
        b=YE4SfjNUoQzwdmGT6dPpnFpp/6ZSDka7tJIIcD/iieSuaM6PFIfOFs44Xa0Ck2/pEZ
         CqoLNy6MM0xhk/2cOOu+u5GZrlqIZ0AwL9lEiousboLBUxvBuETyBIiLazuXI9vssYmK
         n5/tQUuHJsgL1wrSmtpYhq/5igedZU4vKfxKXpr0HJtIdHRMxEECO8l7G1zN05H/aFG5
         pr09J1wKdKITRt905csehu2QfU0j6/qvG3o9l3nqInJVS17wnUTuV6lH+KrDsZionUjj
         L3LoZhY1VisaDFJT/bfqIfp0u9d7LLS5sGPKqijeGKw9meieQEHV1qNxE5Bhs31IVUnD
         5d4w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWDEif0n6UL9bnogayup7Axlic2RoVKULxsiew6mVseuERZ65WJ
	YhCXNFeJ8eC6RSc0rY4XkFKX7i0WVMS0aqopO4A/zGP+opiJUpFmfjRS1W6jzJkwDFXucBiAlpa
	iNasmsN65iom56iwfZQWvydQjVYrbrrw4OeG6YchRSKJVtSiHiU/UnXXOnma0Kn4=
X-Received: by 2002:aa7:d351:: with SMTP id m17mr7855320edr.259.1555499179095;
        Wed, 17 Apr 2019 04:06:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyEyoinYO+5uDlRA+1ZFaf6H3EX2S+hmSMudxDm4mXoikYs7x5urIPIXqcyIxtgfzYUxLet
X-Received: by 2002:aa7:d351:: with SMTP id m17mr7855244edr.259.1555499177737;
        Wed, 17 Apr 2019 04:06:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555499177; cv=none;
        d=google.com; s=arc-20160816;
        b=qAAQq297pYP1LdEUwmeIFU7PZpKXPBgA+XreA6pN2matwz2UkN769iOxQEdBcMS/vq
         QlrLpC0n1nLWvfLCotzUTuQ88ao3n+eOkoTB7xTi8urS4ObDAHe/yJXla21vgPgaBAoB
         oE9modyw+/pECzbTjbOz7IaxmzcItMHNoZZIb+xsgWYNmPWlz01nIFedbHKOm32evBFp
         CdeKtTQUmNJoD7v3ktrbhWSpzbQjjA4nhTDGrzNiO13uKOLh+ulc+8th7b6Q9US0rNoO
         q6/FhfaI8jEvAAMfgex6BhbIcT8w/y5EmSRnkBeOSOz/6/G2YIKnHoU635HPs7vt6GLu
         i6PQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=GKkukveh+vsboSnZ8MBlwj76eeNG6OpZ6t7ta7GWu70=;
        b=WyQ2fFFbs1xiZ//JENnbUa+J9RyZ6pYOR1EEvF833KQmoVppRSJLDBoKbXahir0zHs
         JakD1uU41Yv2lBQwDsBbKUh8X6s0XgNiYhKZvXNm3uiW3hBcVQQygUjkLbuxW/K5yhal
         RBlbw1L6kusvmvs/OQU2SDnS2Kl9RrTL5vAsp20xevtfh1C1PlYYzuEin9ncCZEfbpw1
         Y/ylIeMEYnvoeID6NB+WwMbrn5lVGlEhxIFPycz90yzUlmLXcUaiU1C3XCNPZsXluA/J
         Ai4NgNGSjKWgki9pozfGI8D0d5klSog5sF19LlpNOOo3/9I59y2d6tgOhpKVMkXLAAgt
         7U1A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j25si2841509ejt.234.2019.04.17.04.06.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 04:06:17 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BEA68AE1B;
	Wed, 17 Apr 2019 11:06:16 +0000 (UTC)
Date: Wed, 17 Apr 2019 13:06:15 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Zhaoyang Huang <huangzhaoyang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	David Rientjes <rientjes@google.com>,
	Zhaoyang Huang <zhaoyang.huang@unisoc.com>,
	Roman Gushchin <guro@fb.com>, Jeff Layton <jlayton@redhat.com>,
	"open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH] mm/workingset : judge file page activity via
 timestamp
Message-ID: <20190417110615.GC5878@dhcp22.suse.cz>
References: <1555487246-15764-1-git-send-email-huangzhaoyang@gmail.com>
 <CAGWkznFCy-Fm1WObEk77shPGALWhn5dWS3ZLXY77+q_4Yp6bAQ@mail.gmail.com>
 <CAGWkznEzRB2RPQEK5+4EYB73UYGMRbNNmMH-FyQqT2_en_q1+g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGWkznEzRB2RPQEK5+4EYB73UYGMRbNNmMH-FyQqT2_en_q1+g@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 17-04-19 18:55:15, Zhaoyang Huang wrote:
> fix one mailbox and update for some information
> 
> Comparing to http://lkml.kernel.org/r/1554348617-12897-1-git-send-email-huangzhaoyang@gmail.com,
> this commit fix the packing order error and add trace_printk for
> reference debug information.
> 
> For johannes's comments, please find bellowing for my feedback.

OK, this suggests there is no strong reason to poset a new version of
the patch then. Please do not fragment discussion and continue
discussing in the original email thread until there is some conclusion
reached.

Thanks!
-- 
Michal Hocko
SUSE Labs

