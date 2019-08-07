Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE956C19759
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 07:59:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 911AB22C7E
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 07:59:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 911AB22C7E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 27E7F6B0003; Wed,  7 Aug 2019 03:59:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 22CD96B0006; Wed,  7 Aug 2019 03:59:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F4006B0007; Wed,  7 Aug 2019 03:59:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B47A86B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 03:59:29 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z20so55647340edr.15
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 00:59:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/sjfDZd59wz700DrN89/lOB/BPsttxDiNquUxYGyhak=;
        b=a+8v7uwt6fXaueoqcSnjFljcAdDxKMqtScyEM6S6X/MX83M+JbxtAcDQWHBkHMET7l
         b+qf80Oo1wWkhXRvejlKg7vrBiRqDnDeT1daAFY4yYmqiyO3Rk+9nlBWkgnMQhZW2uNN
         WdjusUUFPxAuDehiaeDPb8urZa91iRw20CCW9RZBROc76zJWmy8muxeu6MkN262sCMb4
         1m4w0etUwYv+lFPpMhXH/Eiva6VRtmlIwEhTUBVwnE3gB8bhG6HYyGCQG9BwpDxuVQqY
         V+22FUEmvgomGNemGVqgGtyiSRkpgcnXVkjIBYDuY5e5mcOZHuReZSqkObb8kXJGa6Wx
         txHw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXx2jJ6CzCb2ieE/4SbHIb+gHILervYkAgR3FDA1p5kkzUxbhe5
	Fird7wHZbQOcsgUgxiuoegQ5GmALloQYXLjYNQbcUfpDSgjyTcPnLzLt3evta6rfdUmWuu3J333
	owh8sgk/Z0WMiqhR9DKFRnHlNdbdrQemRm3NqaSr0P0BV9dXQQlEpiWIygWnnwQE=
X-Received: by 2002:a50:f05a:: with SMTP id u26mr8232990edl.116.1565164769312;
        Wed, 07 Aug 2019 00:59:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz+3Mp6M6Qg8I2PMku09Bolo55Y7gubcJmLoEFkGxDab/v2b4xKwOLSiEegkvMBfhLxskXu
X-Received: by 2002:a50:f05a:: with SMTP id u26mr8232960edl.116.1565164768676;
        Wed, 07 Aug 2019 00:59:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565164768; cv=none;
        d=google.com; s=arc-20160816;
        b=KXEpdTaGnyGZFDfJWX/ngAM6O8ZWGoKW5GawSonQxr8pDV1dBpVke5zSXeBZDlCghs
         infI0IxMed9wsQNwsjl3opsEDmvcUpS6CZDxuwWk3orVX/wqwmjmMBLsLHa+THt4rca1
         zka0rSimIy1NOl4gZJRwyBzUkRnerIJEN/wJXsplV/ACm/vSGTnYRAOqEz0bVczGAwgN
         TeXLZwoVY0ZTitli4/YcREHMJNLWKuVBfvwDkqsocQ4xGtBG0AEIj8mdSRCVClRhmPRG
         PS05KLduNDINKt0+ib4FPckytRJYJ5QCv21cehncdCIbRi8VA79LNs3lsLc17sxVoL2w
         rYMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/sjfDZd59wz700DrN89/lOB/BPsttxDiNquUxYGyhak=;
        b=cufiFzkqaTrIr2u2E3aeeM90pkY0swjp83ORkXu2na27AYvsvFpDjMO+SiYEqdw8aE
         nD8IVeNgCvPK6NziD+6agqy/sKL1+zIKhssKaBrIpV8DonEtElY/Gv2KjXS4Zsm5DUHL
         GZnHFu90QyN5MGHdk+25hSmaAVBmKdKrFFSh7p/1M3TkHX+T9NGVk/mI8J94MGjv2s48
         3i+4oJqEKAZUkmFjk9+bs2icYcCCSbggiZIR5T89nYlds5f6ckefetNXNpjNORaWyqvm
         ZK84gGLl7HJga25jgSuZX6PmajU8lXPacfwzQkdNH148sjhs/5sU+gmuUpn+Qh0kmTSP
         qrqA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l42si32957111edd.332.2019.08.07.00.59.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 00:59:28 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E3C77ACC6;
	Wed,  7 Aug 2019 07:59:27 +0000 (UTC)
Date: Wed, 7 Aug 2019 09:59:27 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Suren Baghdasaryan <surenb@google.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	"Artem S. Tashkinov" <aros@gmx.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's
 inability to gracefully handle low memory pressure
Message-ID: <20190807075927.GO11812@dhcp22.suse.cz>
References: <d9802b6a-949b-b327-c4a6-3dbca485ec20@gmx.com>
 <ce102f29-3adc-d0fd-41ee-e32c1bcd7e8d@suse.cz>
 <20190805193148.GB4128@cmpxchg.org>
 <CAJuCfpHhR+9ybt9ENzxMbdVUd_8rJN+zFbDm+5CeE2Desu82Gg@mail.gmail.com>
 <398f31f3-0353-da0c-fc54-643687bb4774@suse.cz>
 <20190806142728.GA12107@cmpxchg.org>
 <20190806143608.GE11812@dhcp22.suse.cz>
 <CAJuCfpFmOzj-gU1NwoQFmS_pbDKKd2XN=CS1vUV4gKhYCJOUtw@mail.gmail.com>
 <20190806220150.GA22516@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806220150.GA22516@cmpxchg.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 06-08-19 18:01:50, Johannes Weiner wrote:
> On Tue, Aug 06, 2019 at 09:27:05AM -0700, Suren Baghdasaryan wrote:
[...]
> > > > I'm not sure 10s is the perfect value here, but I do think the kernel
> > > > should try to get out of such a state, where interacting with the
> > > > system is impossible, within a reasonable amount of time.
> > > >
> > > > It could be a little too short for non-interactive number-crunching
> > > > systems...
> > >
> > > Would it be possible to have a module with tunning knobs as parameters
> > > and hook into the PSI infrastructure? People can play with the setting
> > > to their need, we wouldn't really have think about the user visible API
> > > for the tuning and this could be easily adopted as an opt-in mechanism
> > > without a risk of regressions.
> 
> It's relatively easy to trigger a livelock that disables the entire
> system for good, as a regular user. It's a little weird to make the
> bug fix for that an opt-in with an extensive configuration interface.

Yes, I definitely do agree that this is a bug fix more than a
feature. The thing is that we do not know what the proper default is for
a wide variety of workloads so some way of configurability is needed
(level and period).  If making this a module would require a lot of
additional code then we need a kernel command line parameter at least.

A module would have a nice advantage that you can change your
configuration without rebooting. The same can be achieved by a sysfs on
the other hand.
-- 
Michal Hocko
SUSE Labs

