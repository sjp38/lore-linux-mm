Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E417AC48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 10:47:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AEBE220659
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 10:47:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AEBE220659
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 428BA6B0003; Wed, 26 Jun 2019 06:47:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3DA2A8E0003; Wed, 26 Jun 2019 06:47:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A1AC8E0002; Wed, 26 Jun 2019 06:47:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D1A7D6B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 06:47:41 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d13so2651826edo.5
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 03:47:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4XQcKnLYsjaA9JXOnH8MQM9Uhl2NmMMjleKl6/PWxwI=;
        b=eME21IGVd7uAz+r8AmRfDPsvWMXFS7nAYAjchdYG5UKA5bMfeMT69VMpPycJ3i43kS
         WbwOWJtvbMKAJ6aCC7RESznqXrdUEnsrsbgDPDXBrc65AA7zEIFhdzSpAqBzUWLMwwj1
         kUwftL9QMZ4IuUGfhltL+Dc1hSHN/dQ0lkVwlwu1p/HuQqGpCy5frahtH/JXFa/RemyF
         KQHmxFmPZAD42qxpkJNqcoAPlCb4QR5K5Y33EztLqP80dxf31QG9tqbtAJEPcnX7Xno+
         7R8P2l6GE2br7Ys9PTS6n1VH+zepmfTkr7QkOiaBB7eBWzODeM4YfuwpxYJ1Ys0F+S3t
         WRsQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXuUZPmVSBwWRT7VymfICK91L55QvTo2J2vNwL1lEBf6Iaompw+
	6WBY4/qzotxkmKOlUU5Z5gb4CL4JRsF2tztV7zAjnuqubL5g0jeGlWSmPAxmaMEAWjCQb1l2HMW
	cne7bD9rhMWhl6tkB0s1dLargs1MqrLu91NL+gjCvaULWdJtZadNYOkGd6GCdzQU=
X-Received: by 2002:a17:907:374:: with SMTP id rs20mr3499588ejb.36.1561546061327;
        Wed, 26 Jun 2019 03:47:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxryHHAd/K8H1O4oXjW5xN8Bi670Hd4Xl+u0JKDWjY5bB2us3RfyUzt81GlaL8dxxVMK3u2
X-Received: by 2002:a17:907:374:: with SMTP id rs20mr3499541ejb.36.1561546060350;
        Wed, 26 Jun 2019 03:47:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561546060; cv=none;
        d=google.com; s=arc-20160816;
        b=REEMQ+HOb/+q2aSoSYrjzKY2CAfb4gYXXDqETugVuU92iovc25c8zVJ7gmJtuP3l38
         JCq/3r2DHZPSEiACp9aT88+y6HjvrFXoxR0tWYUSoxG0XyrEoWBkLXBhWVbds6ec5uYX
         wZVIpvFswDobL39xt0YVN2cnPmaWN2f5Y84vaZH7E+rBKqV3L6U7zAE9STrxCyYb1+Bq
         DOaqTvU8udWVknj6DN3CnqG6WNwOPGEcYn4/oqgxZWwf5hZY0X2DYC88HWmqd152UMZg
         SAtW4hgxQmgl5TFWPavL+zZioGM6heNE8y8zQisfSXHZnB48CAPkIVVXF58AbKm1naSY
         tvMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4XQcKnLYsjaA9JXOnH8MQM9Uhl2NmMMjleKl6/PWxwI=;
        b=dcUsHYqM6MyafWp/VqGDkGFl/gB6xsCPw1QoIgf08Y0WFR7QHqoy/+UZspKuXpZ0HN
         NZCuZId/ZKoBYI/s44z3zf47fBHg/IkuJjJigbCp3uCweb0vpKzVua8DrlF/FnS7BdnB
         cc9B/7P9Vst+G9ip05ZTtmK6zIZfyE/13OM6XH0vQzrNIfhS7S7dDxjpvoUTDPtBiMGk
         uAdssHgn4AUA96hjmM85YinSaybhiI8RG8dx7skTLzw4t1Bf29dtllU7QSLf0K3/l44B
         q5ETXe2ROHmfTQGfYpLyGlwpms85hmDtRaDaD0KiDjoMfg47Yy5771HeCDidRw5p3Hag
         mbRw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e4si2301717ejc.298.2019.06.26.03.47.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 03:47:40 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6AE1BAD7B;
	Wed, 26 Jun 2019 10:47:38 +0000 (UTC)
Date: Wed, 26 Jun 2019 12:47:37 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org
Subject: Re: [PATCH v3 3/3] oom: decouple mems_allowed from
 oom_unkillable_task
Message-ID: <20190626104737.GQ17798@dhcp22.suse.cz>
References: <20190624212631.87212-1-shakeelb@google.com>
 <20190624212631.87212-3-shakeelb@google.com>
 <20190626065118.GJ17798@dhcp22.suse.cz>
 <a94acd91-2bae-0634-b8a4-d5c8674b54f2@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a94acd91-2bae-0634-b8a4-d5c8674b54f2@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 26-06-19 19:19:20, Tetsuo Handa wrote:
> On 2019/06/26 15:55, Michal Hocko wrote:
> > I think that VM_BUG_ON in has_intersects_mems_allowed is over protective
> > and it makes the rest of the code a bit more convoluted than necessary.
> > Is there any reason we just do the check and return true there? Btw.
> > has_intersects_mems_allowed sounds like a misnomer to me. It suggests
> > to be a more generic function while it has some memcg implications which
> > are not trivial to spot without digging deeper. I would go with
> > oom_cpuset_eligible or something along those lines.
> 
> Is "mempolicy_nodemask_intersects(tsk) returning true when tsk already
> passed mpol_put_task_policy(tsk) in do_exit()" what we want?
> 
> If tsk is an already exit()ed thread group leader, that thread group is
> needlessly selected by the OOM killer because mpol_put_task_policy()
> returns true?

I am sorry but I do not really see how this is related to this
particular patch. Are you suggesting that has_intersects_mems_allowed is
racy? More racy now?

-- 
Michal Hocko
SUSE Labs

