Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9BACC10F14
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 17:19:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6CA2720693
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 17:19:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="EqTRBwrH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6CA2720693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 09EC36B026D; Thu, 11 Apr 2019 13:19:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 04EE16B026E; Thu, 11 Apr 2019 13:19:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E7F3F6B026F; Thu, 11 Apr 2019 13:19:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id C4EF56B026D
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 13:19:14 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id k188so4849449yba.2
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 10:19:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=cyJyq9xBxqcKv8h0VQs22akH4SgmjPKIUCFKPUkzKqQ=;
        b=YB14oz7Guu3Xf8kavehLrOotFJKs/KBZRph0jTN1b+LMNAcmdqH00CXBMWhOb3ostN
         J+anYLJCPZWjYn/Ey5xKkE2/rHEojKJivXHnepGvs6WTEGXjr8KH4O0YpBHSyWf2lOXx
         0/aIgXfTdMVR+0mbDEhbHrA/kez5kxyO3ns/Y2T49rssdo244V+iMYixOEucU/tRZ/Rs
         sc8BZT7kThC9q1pCEEwd+7XE1c0ul8P1guVvu/0Hzl0j8L/Q1oHEi3lQaITgRTTmsRe1
         i06+p/k0rrz2QplvFZt5T3PS52Sroqy9lV1c5cILGWtt/UQmo9MsiK1NqeqXGgoRdM5g
         akeA==
X-Gm-Message-State: APjAAAUmz+agUNqJckObA9iQt3UJFOsBXDuNRPebGGlbUJZH4LjqiqBv
	/dTZvWWkHX5aondYEGiMoFPoI2SvsUK1s/vtRRV1DSJlU8lpmSApjxSosoqZqSnD3yE1PRzhcY5
	pmwxMdt4ES27c2eqbQRWnt6zpp+QlWFTBr5hyjM77WpuwHtRoneHHC5o4yxPNFSF4AA==
X-Received: by 2002:a25:da05:: with SMTP id n5mr31879641ybf.199.1555003154525;
        Thu, 11 Apr 2019 10:19:14 -0700 (PDT)
X-Received: by 2002:a25:da05:: with SMTP id n5mr31879585ybf.199.1555003153842;
        Thu, 11 Apr 2019 10:19:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555003153; cv=none;
        d=google.com; s=arc-20160816;
        b=V7tVO5IFH5DMHfIDWHyZJCnnoMtsD9OdoKdRFwVEilHkVbOOWtJ28Iq+SRqwxNFO5i
         +6yDB66BM65pezC7U9iRHwY4LNbmf6mtbGjn3kUHPq4jfGUW/XRBC4tEUM90+HzxarSk
         rK4K7MrYpkeV+HiJaegzofctXeiA8jYCmVrTpetD7ThFochraePaNlUG+x6e3jnhQfY1
         67Gcn4O14mWjbw7sz+NZ519jaDlaxDDBkylxqvx3PveVLxuK9M++yIJK3wFgYICU+qax
         jYcxHKVsXGtEMAPnTQq6dar6MxbaUsvOuHmfomDFxkHoDOa+Q+RqpxOEHU5EfoRwfPlm
         g15w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=cyJyq9xBxqcKv8h0VQs22akH4SgmjPKIUCFKPUkzKqQ=;
        b=fFnE4CrRkqfOKv7BcAgjwaexqA6K7d0ZbF9v1W1h1eCN42Rs5Q01TDzVghYFHcl43P
         aR+ZHuHQhK483TNqzrckeJFPiP8EEaVaxiM4a+okbvn9HzCjuSM54iLaJq6vEptvJXDw
         1MWpO4g8SbPIFmSwGb3ONBgZFx3Xtj9/Sl/b/jR7J/KRk6C/Vza2+T7BX+hMY7WpTqIk
         H/hkdy0aI5D7TP4aOc5WhZ0DvbMows+oKt0cSLNvc0WCm+LNuBOMbfoNSEfvy+RsrP1u
         sPrlQ9HaWwZQm88EPMsgvw19sDAJXXu3jWn8i5N7+7ziL7x9GRJbf1zY++AxRqktIrYd
         yQhA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=EqTRBwrH;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q198sor18339647ybq.6.2019.04.11.10.19.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 10:19:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=EqTRBwrH;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=cyJyq9xBxqcKv8h0VQs22akH4SgmjPKIUCFKPUkzKqQ=;
        b=EqTRBwrHJfArZzz19rJ1yu0nWJBZrywhQAaYqkIgR+Eemxw9LBes2KIk9kITGbiSPH
         K23cbLMim+6mGbba7xndiogldsHAPk9PSrRK94PzAiOXZcQKHv/42dzB+WkLLRxH1DGg
         2SIoDRKdmDs4UYYrYghG6NoocONFk5ugNSSsL9/QpbUldzzsAyXUHT8Sul5Xbsx5tpF/
         EqMvnrchcl4/8l0CukILEamDQz8NU5spc+HA1OLo7K0h6ykbR8b45xxj7NumciQQLroX
         iUNG4kw04OasQi1BECafxLzBmzY8IGmnVDpgyGYfQRDnJwJgY4rNX3nU2M3+CwAdO3kc
         t6XQ==
X-Google-Smtp-Source: APXvYqzn4RYWtX/ATfNEwEVd98+0YcQHPTse8AbadNFkg/MSQ1oUxMXbh2lHxc0VJKkNgADH4uoNNw==
X-Received: by 2002:a25:2d45:: with SMTP id s5mr41609862ybe.272.1555003151188;
        Thu, 11 Apr 2019 10:19:11 -0700 (PDT)
Received: from localhost ([2620:10d:c091:200::3:2a81])
        by smtp.gmail.com with ESMTPSA id h3sm15971243ywa.61.2019.04.11.10.19.10
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 11 Apr 2019 10:19:10 -0700 (PDT)
Date: Thu, 11 Apr 2019 13:19:09 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Suren Baghdasaryan <surenb@google.com>, akpm@linux-foundation.org,
	rientjes@google.com, willy@infradead.org,
	yuzhoujian@didichuxing.com, jrdr.linux@gmail.com, guro@fb.com,
	penguin-kernel@i-love.sakura.ne.jp, ebiederm@xmission.com,
	shakeelb@google.com, christian@brauner.io, minchan@kernel.org,
	timmurray@google.com, dancol@google.com, joel@joelfernandes.org,
	jannh@google.com, linux-mm@kvack.org,
	lsf-pc@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	kernel-team@android.com
Subject: Re: [RFC 0/2] opportunistic memory reclaim of a killed process
Message-ID: <20190411171909.GB5136@cmpxchg.org>
References: <20190411014353.113252-1-surenb@google.com>
 <20190411105111.GR10383@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190411105111.GR10383@dhcp22.suse.cz>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 12:51:11PM +0200, Michal Hocko wrote:
> I would question whether we really need this at all? Relying on the exit
> speed sounds like a fundamental design problem of anything that relies
> on it. Sure task exit might be slow, but async mm tear down is just a
> mere optimization this is not guaranteed to really help in speading
> things up. OOM killer uses it as a guarantee for a forward progress in a
> finite time rather than as soon as possible.

I don't think it's flawed, it's just optimizing the user experience as
best as it can. You don't want to kill things prematurely, but once
there is pressure you want to rectify it quickly. That's valid.

We have a tool that does this, side effect or not, so I think it's
fair to try to make use of it when oom killing from userspace (which
we explictily support with oom_control in cgroup1 and memory.high in
cgroup2, and it's not just an Android thing).

The question is how explicit a contract we want to make with
userspace, and I would much prefer to not overpromise on a best-effort
thing like this, or even making the oom reaper ABI.

If unconditionally reaping killed tasks is too expensive, I'd much
prefer a simple kill hint over an explicit task reclaim interface.

