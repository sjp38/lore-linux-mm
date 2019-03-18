Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D18BC10F00
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 13:08:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1524620857
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 13:08:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1524620857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5BCFD6B0005; Mon, 18 Mar 2019 09:08:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 569F46B0006; Mon, 18 Mar 2019 09:08:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 459416B0007; Mon, 18 Mar 2019 09:08:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0594A6B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 09:08:01 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id p5so6926960edh.2
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 06:08:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=EtABQaRkoJ28tVLnbJea5RT6bU0rAHDKiH3UUaBPD8Y=;
        b=o5KChdyhGYoW0FfKwhwFD/0VoDc1FoBKALFACKob1/jaDE8GBq6+Rv9IvxrTWSRfER
         BuBehufXTFdJb7+alB04axBunYO1uWH4zZSGY4V4iZ1vy9V3AGXGirSR+DKJxRuc4WhJ
         VoYQapZjHWKBaraTTaQYQrKV3eAp/YxD9Ku+VAGrSyMygr7kiL3eywaCVI1TUltXgQRo
         y0I6v0Zz9L07UzYDFwguTGgI2oQMQJiXXaMQ19u9t6Nc3FWFS8rTi49kaNKfVmDKV809
         yBBjtxUD36orXV7mEmqTo+YYA4Tr+poGYw2QEM771pdXH9ou4rqon7cDT56VjC5ymXK6
         xOZg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUvqyrOO9k7Krw20iQ8xil/5t+43ZwBXIJCcmjnqeW/Irh+Ue2F
	fTv1ZMS4B3u9vX53n5tUvZbEVpyMyeM9nPHUcXz5fDkCgSln8Y3WA+W7PBxRmymDRczGYur+LAR
	lIry21Y/GWBCtlGIhoQoAVjxCvbBbkjzA9Ltzf5mpfNLEMBfVBLC8r+dP0B3tnjE=
X-Received: by 2002:aa7:d141:: with SMTP id r1mr12912654edo.241.1552914480583;
        Mon, 18 Mar 2019 06:08:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyleRfbYwqZ3CSACtw0qAI40QSRyWc/tZ696jb1/Eiyig1FU39EhBytnV2Exch1jBoREFgQ
X-Received: by 2002:aa7:d141:: with SMTP id r1mr12912610edo.241.1552914479762;
        Mon, 18 Mar 2019 06:07:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552914479; cv=none;
        d=google.com; s=arc-20160816;
        b=Pk3utgmP+bsJKnZxESj1m1Drbyrsry//ulK4oEbPabuopeHFfZkN8hgKF5qCiCToeD
         kzaLOc6yC3az91JPqxYvcrwmu6Vev3Cm8VlIdXyUyOfSsCwEOWw46tjmQjBxGgCcnVvf
         27Wm/F8XJqBI1Ooqt9qCV95AXxLHPQOecnAKNZJJpjWE4jzyki3n29QIdUbL/lHR3aoL
         1Ok6RKmSbgJgYil2Qy3F+OI0K2GJnWlSEePOWKlGpMeyREAZJjJLfN9CqzRf8vO3LLpc
         s0Zs2hpD7aqpDM+WQE8gXnpoxrIQCrKeDaZb/3ywwk34K6PEmBSmjsnCrqBuCjbEBiX/
         7Hnw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=EtABQaRkoJ28tVLnbJea5RT6bU0rAHDKiH3UUaBPD8Y=;
        b=b+/tApQHIs271fQiKNEbz9rA5GY7yfnMDtbucG6faRxtj68NfyETjN/qKHY2n+4K3q
         7ttav0Qxdoromq7LgQRAn9KkAMNbnuKsl6cYY9kLyCavzx4dhzGgZzuVHAQoDzQjx2bb
         Q+hpVXvmbRss/WIRX0woQsApJwVB3Ml4gbYGGXZGWVZfuF7An3jtrmFz8Rx36QW8FHwW
         Mu9O50ywANusFtwckOARiLk+304DqtZD5IGfrfouJMp0oBq0RmDrNQuKtoAIsHCKHlH1
         3uLqhE+YHK1o7N3IObQRZsV1aLcHotP7CYKWb79A2ekvKSdi2c6PXPOEkhI8/5kzarmd
         nQhw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d21si1149993ejk.91.2019.03.18.06.07.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Mar 2019 06:07:59 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 92E7DAE07;
	Mon, 18 Mar 2019 13:07:58 +0000 (UTC)
Date: Mon, 18 Mar 2019 14:07:57 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"minchan@kernel.org" <minchan@kernel.org>,
	Kirill Tkhai <ktkhai@virtuozzo.com>
Subject: Re: mm/cma.c: High latency for cma allocation
Message-ID: <20190318130757.GG8924@dhcp22.suse.cz>
References: <SG2PR02MB3098E44824F5AA69BC04F935E8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <SG2PR02MB3098E44824F5AA69BC04F935E8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 18-03-19 12:58:28, Pankaj Suryawanshi wrote:
> Hello,
> 
> I am facing issue of high latency in CMA allocation of large size buffer.
> 
> I am frequently allocating/deallocation CMA memory, latency of allocation is very high.
> 
> Below are the stat for allocation/deallocation latency issue.
> 
> (390100 kB),  latency 29997 us
> (390100 kB),  latency 22957 us
> (390100 kB),  latency 25735 us
> (390100 kB),  latency 12736 us
> (390100 kB),  latency 26009 us
> (390100 kB),  latency 18058 us
> (390100 kB),  latency 27997 us
> (16 kB), latency 560 us
> (256 kB), latency 280 us
> (4 kB), latency 311 us
> 
> I am using kernel 4.14.65 with android pie(9.0).
> 
> Is there any workaround or solution for this(cma_alloc latency) issue ?

Do you have any more detailed information on where the time is spent?
E.g. migration tracepoints?

-- 
Michal Hocko
SUSE Labs

