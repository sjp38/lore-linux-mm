Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D80BCC07542
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 14:22:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB056217F4
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 14:22:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB056217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FFE16B027F; Mon, 27 May 2019 10:22:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2AEF96B0280; Mon, 27 May 2019 10:22:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C6066B0281; Mon, 27 May 2019 10:22:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D7C1E6B027F
	for <linux-mm@kvack.org>; Mon, 27 May 2019 10:21:59 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z5so28278618edz.3
        for <linux-mm@kvack.org>; Mon, 27 May 2019 07:21:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=NTNHqqPeZJwrBa49ycH3AX6TzC9DC051vM2hOEhMuT8=;
        b=QivCpJUzXJph95Rb2XXjP6DtOh4nSWwHYGBbG2EiTTg5GLr2u0Km/xccJj/FlhzfNG
         HSu/CALcvC/YoZG9aNGs60LW63Nrg+VprndbEz0XToVREzFLNmKF/9tIWDwykcW2ZHF8
         8+XesVIe0t0ES3lBbkb738sEZ2Jgj5lnyMaEvdg4lLR4T+gMR75DtMtS1RESORMEhjjq
         i6ouEciUIzpQZuPG3RdigpiXo2FIm9cm3HtY2Mje4LBSeZZDOIzwoGmGxoszOWbr7NIK
         p1/s+42NaxUck0SbKW7izTc0kBqgatEgukHvWlmWCghINoHN9DXxv3iiVQg2q8c2lKIp
         u4eA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXMFZjdmLUbKXNIB1X7MtGU+wjH5z3SzpOuQFHiCDpSl1AW5H9C
	qrLyzDhNDh9nguiBhlb5jv3xNN6q3/b21X+TtdKFwpNVFZwftg4h2LUJt0UayOIG+ieoDDu6L8j
	TRskb+L88qf+Nykg4FxMZ7quLOwhj4b7YjimEmkTFcsV7mzjOJeDIZkQ80TP5iQI=
X-Received: by 2002:a17:906:80c4:: with SMTP id a4mr14665342ejx.312.1558966919456;
        Mon, 27 May 2019 07:21:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzRSA3hgkYpp6BBVRlv/8vklK5JIgg+nDqGv0bjK3HTMj8xKeyI5HQvErVf7JtbrLdzQeJ8
X-Received: by 2002:a17:906:80c4:: with SMTP id a4mr14665256ejx.312.1558966918586;
        Mon, 27 May 2019 07:21:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558966918; cv=none;
        d=google.com; s=arc-20160816;
        b=tZ1wVgOvq1/QO//+2nmeCSCVaWn5Tp7NElCj3ZRshCpkDxezC4s4OamYEtH64AV8zq
         gWBfYPHskkL2kCGBkWHJp226L04OhRRpIX+TnDmtDbSuYng57Ztdaq7ZkvDQ7OtR4j2B
         LP3I92TXuwG0gYaHItJe5VGs0vKb0v/I+XnTcLFatnpZTtS3RD389oIpQOibHl6dIRnH
         cPEH+VB4ETqN6fyBT/KOaxIA8uP8mUjZdZFZb4rBm4HbERacZ/pqv+Y22UNmJHZ1U3yQ
         Lb9EpBvhjbDZczu2l402MeWzNaaTU+XWJ7CwvFFKcwjD7SiB0GLEuAGiduvqKhFB0RsH
         9oUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=NTNHqqPeZJwrBa49ycH3AX6TzC9DC051vM2hOEhMuT8=;
        b=kbMR7kvkNrzOEfX9LzaS87n324rAMw+gOL8G77B9WOBrfaGfHpI/nh+wWcd27UAsCL
         41390nPsGXTMpbfcbWXCM4vo7Sdzz5YUqzX/mVWyup9yg4/r//PokVc3IiEpPB8iPDqa
         jmPDd0eFE7OpS6glNaKpFYmEgDIvNdavBdMVjPqDnCCFPqH9CBr16Gg9nsJHb0Nsrota
         tRZK5lLgBMYdgb2CFLZSozYAhe+qUAhtAYqMlAr3130ACYh1Ei3UwIAIi0k4aC8R+o3F
         Hgls9clX+LbGeBrYTjfA2R9L3XMQxsJ3nQ3+tnfcuWJ+iV6f7NmPfV3Sx+3ahegZYFSQ
         dvNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g55si8844988edc.336.2019.05.27.07.21.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 07:21:58 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 25D96AEF3;
	Mon, 27 May 2019 14:21:58 +0000 (UTC)
Date: Mon, 27 May 2019 16:21:56 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Roman Gushchin <guro@fb.com>, linux-api@vger.kernel.org
Subject: Re: [PATCH RFC] mm/madvise: implement MADV_STOCKPILE (kswapd from
 user space)
Message-ID: <20190527142156.GE1658@dhcp22.suse.cz>
References: <155895155861.2824.318013775811596173.stgit@buzz>
 <20190527141223.GD1658@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527141223.GD1658@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 27-05-19 16:12:23, Michal Hocko wrote:
> [Cc linux-api. Please always cc this list when proposing a new user
>  visible api. Keeping the rest of the email intact for reference]
> 
> On Mon 27-05-19 13:05:58, Konstantin Khlebnikov wrote:
[...]
> > This implements manual kswapd-style memory reclaim initiated by userspace.
> > It reclaims both physical memory and cgroup pages. It works in context of
> > task who calls syscall madvise thus cpu time is accounted correctly.

I do not follow. Does this mean that the madvise always reclaims from
the memcg the process is member of?
-- 
Michal Hocko
SUSE Labs

