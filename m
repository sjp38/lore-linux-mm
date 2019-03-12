Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05195C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 15:39:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AAA11205F4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 15:39:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AAA11205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 27D048E0003; Tue, 12 Mar 2019 11:39:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 22C088E0002; Tue, 12 Mar 2019 11:39:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 11BEF8E0003; Tue, 12 Mar 2019 11:39:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id AECE48E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 11:39:30 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k21so1269301eds.19
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 08:39:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=bF0KTi4f7aIMB3DIQctyhxDicchsDJrp3U+n4tBeGMI=;
        b=t5qPAH6RBawim1CwF9kj3t3p9sRpi7xJvSS0lOUTWg1jPTZqRdRHCNxKlyAFUEwqn6
         ogMxEaeo6JCyFdQDAU3NGJQgrCqlAWg9nybm2SQMBZJ8va1pbZPMtI6ir/8AUW20K0bH
         lMDct/XPN9K44vAYV0iAnKgcyBCAHNs6+9zigBpWQWscqpsw4rS7kaWp1gOEygCfRFNa
         nOU3KkE/Dak8eYrd/6NsCxYMojm1tC3I19yi7Nql3H8UaLgJ1ZhNH2QQQsUFGP31xF1u
         FKX4cczRouQkPeAl91tiUGKMmAiVpwb1pMJbALSSwlTMSWn8wU22D4lKNFoB/fM3PJeB
         xXHQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVy48fE7Yqt4VZ+7eLvaZg9SbEwU63AVjcWg3G8zs3Rez3Bra46
	tzrXzsM3L89oXkT20DTGO1xhVdtU6d7O8U9sTua8NemO2e8Kpm6h7ur98+0CvcU3iXp3zzORSI9
	U7Aa2qeTiLgGbTjOV8JrAEsS78cnxKyFdruXoD6RrilrEvZpK7zz1u/J5OCOSo+0=
X-Received: by 2002:a17:906:1d4a:: with SMTP id o10mr2520636ejh.232.1552405170266;
        Tue, 12 Mar 2019 08:39:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwxaTsfNcNaLEtXhXxXan08cFxODPI/lkD4VnOkt7GvhTYsznz4ECFUnwEPE46phWy9nCNL
X-Received: by 2002:a17:906:1d4a:: with SMTP id o10mr2520593ejh.232.1552405169424;
        Tue, 12 Mar 2019 08:39:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552405169; cv=none;
        d=google.com; s=arc-20160816;
        b=Vk1y23s4AZ/6YbApedhVQdHcMdo5al00qCXx39wt8PenZcpkAYQHYTWVYVvKgYHNFB
         RUxKDY7cVFWPemDBnnQ+tdo+lPZnIezNrMu18I/EHeSRW1lHEhzTilIRm/wm7NrIN/Qj
         sj4OmSr/DBvdlMZBNj4nVIdEztTTWSailOJFkJdUfQNqsI8dDe6xA0tjKdlggeehv7c3
         w8+iCh2HH027CbOE5Mx5ldI/q8h8EJZAvUM+ql4p6mRKL1dTRUCnU8iLOw83uWhMMyuH
         NvENTnfroGozXDFRg95qDuaQn6P7QsX505TaONqhWThc5LkddqWeIIN63SAqOhdQeaTx
         ye3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=bF0KTi4f7aIMB3DIQctyhxDicchsDJrp3U+n4tBeGMI=;
        b=lQ43qefnmnf5y/8kN8nJHxq4QuukeMLY6iBmS7o+XtGume0wGrpKw1Meoo731ICeQ0
         5tanLFwgDQHy7ABnYS5hdPqTDTX2EWxQ2aRi8GbZbCM+d5RqJ/5GiDsRGmHk+aQsXX0N
         +Z6JuuwSJEYBEDwy6KJV0bQVQKc95kFavrjtVOYhiuW6yTgq0qnyjADbYrD3SKm4j3Bg
         9+T5gbwzlmAy4Hkt14XCh2n+xLv5nKn6SS0seY2vpA7GEoRZEn3KZ9CJ6t3565deLzx0
         4iM1gh8wmcXzo2lGUU2t1KZ39hlQWkm9ol+hKomfila84aRobDXZ++MknOoXGz3D3Oqz
         4yUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a17si865649ejy.247.2019.03.12.08.39.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 08:39:29 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E7525B172;
	Tue, 12 Mar 2019 15:39:28 +0000 (UTC)
Date: Tue, 12 Mar 2019 16:39:28 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Suren Baghdasaryan <surenb@google.com>,
	Sultan Alsawaf <sultan@kerneltoast.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Christian Brauner <christian@brauner.io>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, devel@driverdev.osuosl.org,
	linux-mm <linux-mm@kvack.org>, Tim Murray <timmurray@google.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190312153928.GW5721@dhcp22.suse.cz>
References: <20190310203403.27915-1-sultan@kerneltoast.com>
 <20190311174320.GC5721@dhcp22.suse.cz>
 <20190311175800.GA5522@sultan-box.localdomain>
 <CAJuCfpHTjXejo+u--3MLZZj7kWQVbptyya4yp1GLE3hB=BBX7w@mail.gmail.com>
 <20190311204626.GA3119@sultan-box.localdomain>
 <CAJuCfpGpBxofTT-ANEEY+dFCSdwkQswox3s8Uk9Eq0BnK9i0iA@mail.gmail.com>
 <20190312080532.GE5721@dhcp22.suse.cz>
 <20190312152541.GI19508@bombadil.infradead.org>
 <20190312153315.GV5721@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190312153315.GV5721@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 12-03-19 16:33:15, Michal Hocko wrote:
> On Tue 12-03-19 08:25:41, Matthew Wilcox wrote:
> > On Tue, Mar 12, 2019 at 09:05:32AM +0100, Michal Hocko wrote:
> > > On Mon 11-03-19 15:15:35, Suren Baghdasaryan wrote:
> > > > Yeah, killing speed is a well-known problem which we are considering
> > > > in LMKD. For example the recent LMKD change to assign process being
> > > > killed to a cpuset cgroup containing big cores cuts the kill time
> > > > considerably. This is not ideal and we are thinking about better ways
> > > > to expedite the cleanup process.
> > > 
> > > If you design is relies on the speed of killing then it is fundamentally
> > > flawed AFAICT. You cannot assume anything about how quickly a task dies.
> > > It might be blocked in an uninterruptible sleep or performin an
> > > operation which takes some time. Sure, oom_reaper might help here but
> > > still.
> > 
> > Many UNINTERRUPTIBLE sleeps can be converted to KILLABLE sleeps.  It just
> > needs someone to do the work.
> 
> They can and should as much as possible. No question about that. But not
> all of them can and that is why nobody should be relying on that. That
> is the whole point of having the oom_reaper and async oom victim tear
> down.

Let me clarify a bit. LMK obviously doesn't need any guarantee like the
core oom killer because it is more of a pro-active measure than the last
resort. I merely wanted to say that relying on a design which assumes
anything about time victim needs to exit is flawed and it will fail
under different workloads. On the other hand this might work good enough
on very specific workloads to be usable. I am not questioning that. The
point is that this is not generic enough to be accepted to the upstream
kernel.
-- 
Michal Hocko
SUSE Labs

