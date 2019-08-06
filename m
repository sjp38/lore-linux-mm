Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85770C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 22:02:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B58221880
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 22:02:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="izZrIVgA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B58221880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C045C6B0003; Tue,  6 Aug 2019 18:01:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB46E6B0006; Tue,  6 Aug 2019 18:01:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ACAD46B0007; Tue,  6 Aug 2019 18:01:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 794106B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 18:01:59 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id r7so49120969plo.6
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 15:01:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=9TOOMXpdHhfNP8TqOOWmaxW9SdWGrnprCe8IpBGpEI4=;
        b=e5i8VWqp7P7BCXUzI6UF+xqpj6DVZEqfKKzcGo1AmBmxbeLrr82SCDEwK0ZeULusGo
         zDkQaBTUrDpE7jscYAukX8qcw8hw7B071uCeZKkj6f4U1Y2kb6rePNMpN3qv80BPbVJ/
         K087/LdQ7FyYPJRM8M4f4tRYztKbtK/Xij83vGMtopKLgf/4SJvgezy2L0I/KW38SeLN
         uzipcKoCSyYTJ1STkEO9sGritFK2qrlRZiq+oVC2yXrvxlJ7xoGEAPHo1ReeXEA3jAuc
         oGt6rYp3T8lIy126i78HqA7k1e4h9GGHnEqzPKjn/qGjRotEz2feiKFcfWJCcij+zC6G
         0m0A==
X-Gm-Message-State: APjAAAXy92MT29UkA2eYKpvy3Q7V5KVNm/DHCQgSSlYB9ryCSg2+vfIC
	7J+E4DWsafRL2SkU6xsZKb+AqX4yBWjuT4IkM9TiV3kliX0U6uYPfdPDNvh175xe7nGGUSvHFp1
	1eWq73ZNrpPYV81eLmM1F2vtEOWaWc4pP4ZhsCP35FrXqmdUmEezbF11mmdnCQCsAbw==
X-Received: by 2002:aa7:8705:: with SMTP id b5mr6182068pfo.27.1565128919146;
        Tue, 06 Aug 2019 15:01:59 -0700 (PDT)
X-Received: by 2002:aa7:8705:: with SMTP id b5mr6181987pfo.27.1565128918159;
        Tue, 06 Aug 2019 15:01:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565128918; cv=none;
        d=google.com; s=arc-20160816;
        b=D++ZCfIertRpoc0jzPN4klU7+JRbfFEFhzAUuDMAj1oHjkVzfWd+dqLFW+6TGikMOi
         uP1dFgsVFKe7I1JjKrbiCDkULeqY+5dyTiJcn+mYtnHO1Lbx/GNPZbBE3QIjAhG5h8p7
         pFQ8RSpMXFJbNYCKvPnJDaT4zjnFVIuDuNTKICo2qoCx8flOhPaAasv1akOWXAPqGesA
         8cOZpPeb5ZjWu1nq1stJ/vSNka3hDL5NgSd1ORIMPhCouWlTdZdmeuE9Q5b1zoptgjIG
         gODJbfVsSFu+etpuo2x6kLV/2vZ32058Alcm3z/hctpez+DxSwze8twE1pHli0ThcMDj
         mqsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=9TOOMXpdHhfNP8TqOOWmaxW9SdWGrnprCe8IpBGpEI4=;
        b=qHwVGRsFxI97Rm2SMiQX7+TYj40slT9w4pKO3XgSiCbNXW88zP//rdZOkf7612H+ju
         R/vy8aI2k58//PNGnXyYis8+plOyc50CPHVdB8MnaKYDuaBwQEeAQ2dNMEqMCith9oAo
         ad0JpcPi+87dx0XK/TeUBSTdYr9VjW5ALQ8sqlaJ1OGoDq3TyTMLB2m/A+1aN7YvGCqp
         OvvA2XTXrlzh3htmAVhDY1Ba0OeuI0M8kzQ2OyX+lASyvDwqg3A7Rlrd/a+sdg1Nz2ku
         IIBsFD8IM/ZOtxaPw3raD4K/wqCywHDayubYALiP1redvGjGy/2zEuEEX++9VgJa75Cv
         io9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=izZrIVgA;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l98sor25886372pje.13.2019.08.06.15.01.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 15:01:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=izZrIVgA;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=9TOOMXpdHhfNP8TqOOWmaxW9SdWGrnprCe8IpBGpEI4=;
        b=izZrIVgAtbTKNmvIhm0adtZEpVPQff9m+j8ZhJegGGwGh6JorpoIi0Oh1tcYzxMAGC
         SrvdhuxNpzri3k9FXRmRHEz6RDAR0fMsZGdAl4t3D9QSW64Ev/NUUwyUI7vAREmnDJRy
         osnkM0XhNgHSI7aIm86HPOfAx3hiis1/tCK/VcP088Hf0CFzKXCO09m2sc+cLTDHN5WR
         zfOoNbLvRTuTArLMMzTcMEFDQUhQ+OUQ3BT9YL/nM9qx7PsVhtb2QdBc5/a1r/p6TLyW
         xf8VkhGovW2P7FvrUEwtA6LhMIPrL1y/qG8f1RzuGRBOActenUbAchhGpkDv2rpWghLc
         LKtA==
X-Google-Smtp-Source: APXvYqyDe+sCd5FRDCmOmRIXdySTeZWqUYEAUktkoNCOZ/cTcS00bVF0NkzwxRlN9NuVa5WhLthECg==
X-Received: by 2002:a17:90a:db42:: with SMTP id u2mr5267500pjx.48.1565128912708;
        Tue, 06 Aug 2019 15:01:52 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::2:9067])
        by smtp.gmail.com with ESMTPSA id br18sm21063562pjb.20.2019.08.06.15.01.51
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 15:01:51 -0700 (PDT)
Date: Tue, 6 Aug 2019 18:01:50 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>,
	"Artem S. Tashkinov" <aros@gmx.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's
 inability to gracefully handle low memory pressure
Message-ID: <20190806220150.GA22516@cmpxchg.org>
References: <d9802b6a-949b-b327-c4a6-3dbca485ec20@gmx.com>
 <ce102f29-3adc-d0fd-41ee-e32c1bcd7e8d@suse.cz>
 <20190805193148.GB4128@cmpxchg.org>
 <CAJuCfpHhR+9ybt9ENzxMbdVUd_8rJN+zFbDm+5CeE2Desu82Gg@mail.gmail.com>
 <398f31f3-0353-da0c-fc54-643687bb4774@suse.cz>
 <20190806142728.GA12107@cmpxchg.org>
 <20190806143608.GE11812@dhcp22.suse.cz>
 <CAJuCfpFmOzj-gU1NwoQFmS_pbDKKd2XN=CS1vUV4gKhYCJOUtw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJuCfpFmOzj-gU1NwoQFmS_pbDKKd2XN=CS1vUV4gKhYCJOUtw@mail.gmail.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 09:27:05AM -0700, Suren Baghdasaryan wrote:
> On Tue, Aug 6, 2019 at 7:36 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Tue 06-08-19 10:27:28, Johannes Weiner wrote:
> > > On Tue, Aug 06, 2019 at 11:36:48AM +0200, Vlastimil Babka wrote:
> > > > On 8/6/19 3:08 AM, Suren Baghdasaryan wrote:
> > > > >> @@ -1280,3 +1285,50 @@ static int __init psi_proc_init(void)
> > > > >>         return 0;
> > > > >>  }
> > > > >>  module_init(psi_proc_init);
> > > > >> +
> > > > >> +#define OOM_PRESSURE_LEVEL     80
> > > > >> +#define OOM_PRESSURE_PERIOD    (10 * NSEC_PER_SEC)
> > > > >
> > > > > 80% of the last 10 seconds spent in full stall would definitely be a
> > > > > problem. If the system was already low on memory (which it probably
> > > > > is, or we would not be reclaiming so hard and registering such a big
> > > > > stall) then oom-killer would probably kill something before 8 seconds
> > > > > are passed.
> > > >
> > > > If oom killer can act faster, than great! On small embedded systems you probably
> > > > don't enable PSI anyway?
> 
> We use PSI triggers with 1 sec tracking window. PSI averages are less
> useful on such systems because in 10 secs (which is the shortest PSI
> averaging window) memory conditions can change drastically.
> 
> > > > > If my line of thinking is correct, then do we really
> > > > > benefit from such additional protection mechanism? I might be wrong
> > > > > here because my experience is limited to embedded systems with
> > > > > relatively small amounts of memory.
> > > >
> > > > Well, Artem in his original mail describes a minutes long stall. Things are
> > > > really different on a fast desktop/laptop with SSD. I have experienced this as
> > > > well, ending up performing manual OOM by alt-sysrq-f (then I put more RAM than
> > > > 8GB in the laptop). IMHO the default limit should be set so that the user
> > > > doesn't do that manual OOM (or hard reboot) before the mechanism kicks in. 10
> > > > seconds should be fine.
> > >
> > > That's exactly what I have experienced in the past, and this was also
> > > the consistent story in the bug reports we have had.
> > >
> > > I suspect it requires a certain combination of RAM size, CPU speed,
> > > and IO capacity: the OOM killer kicks in when reclaim fails, which
> > > happens when all scanned LRU pages were locked and under IO. So IO
> > > needs to be slow enough, or RAM small enough, that the CPU can scan
> > > all LRU pages while they are temporarily unreclaimable (page lock).
> > >
> > > It may well be that on phones the RAM is small enough relative to CPU
> > > size.
> > >
> > > But on desktops/servers, we frequently see that there is a wider
> > > window of memory consumption in which reclaim efficiency doesn't drop
> > > low enough for the OOM killer to kick in. In the time it takes the CPU
> > > to scan through RAM, enough pages will have *just* finished reading
> > > for reclaim to free them again and continue to make "progress".
> > >
> > > We do know that the OOM killer might not kick in for at least 20-25
> > > minutes while the system is entirely unresponsive. People usually
> > > don't wait this long before forcibly rebooting. In a managed fleet,
> > > ssh heartbeat tests eventually fail and force a reboot.
> 
> Got it. Thanks for the explanation.
> 
> > > I'm not sure 10s is the perfect value here, but I do think the kernel
> > > should try to get out of such a state, where interacting with the
> > > system is impossible, within a reasonable amount of time.
> > >
> > > It could be a little too short for non-interactive number-crunching
> > > systems...
> >
> > Would it be possible to have a module with tunning knobs as parameters
> > and hook into the PSI infrastructure? People can play with the setting
> > to their need, we wouldn't really have think about the user visible API
> > for the tuning and this could be easily adopted as an opt-in mechanism
> > without a risk of regressions.

It's relatively easy to trigger a livelock that disables the entire
system for good, as a regular user. It's a little weird to make the
bug fix for that an opt-in with an extensive configuration interface.

This isn't like the hung task watch dog, where it's likely some kind
of kernel issue, right? This can happen on any current kernel.

What I would like to have is a way of self-recovery from a livelock. I
don't mind making it opt-out in case we make mistakes, but the kernel
should provide minimal self-protection out of the box, IMO.

> PSI averages stalls over 10, 60 and 300 seconds, so implementing 3
> corresponding thresholds would be easy. The patch Johannes posted can
> be extended to support 3 thresholds instead of 1. I can take a stab at
> it if Johannes is busy.
> If we want more flexibility we could use PSI triggers with
> configurable tracking window but that's more complex and probably not
> worth it.

This goes into quality-of-service for workloads territory again. I'm
not quite convinced yet we want to go there.

