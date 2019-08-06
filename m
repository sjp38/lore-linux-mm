Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49141C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 14:36:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5087214C6
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 14:36:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5087214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 33FAB6B0003; Tue,  6 Aug 2019 10:36:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F0086B0006; Tue,  6 Aug 2019 10:36:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B9216B0007; Tue,  6 Aug 2019 10:36:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C1BCC6B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 10:36:12 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d27so54050567eda.9
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 07:36:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=y7BrABq3gCM5NwrWP3u6YNUhVFfVU59M/ZD27Xiu4XY=;
        b=THsoEuZWqw20G7ClEbEEfdDdI60oHMmVgyhmWck+nrfxccU0uiscsZphwF2n8Xf58g
         OpUyGLNgO0Y0CmFEgkarsR1FkwC9EwzOPraqruPokmCDSQDq0fKaAQuEY7Ptzb0l9K9k
         6JAKBUFblUuITSl+yXB0TSa6anzBpwKB8nEJ4tMouYYk4TcN3U4XJp/Wxe6WgGmxbxuU
         laDwJYhMcDxz4roxoeTuTaYaQ2KZ4tMz3mVY4JYMm9XGQ+CTMVbApa6l/wsyf67/t62n
         99TdtTELeXPfgAQ1lbe90BRQyS+NlWrVfNWYUe3Krfqi9VvgNz50MmR6rL3cWJ51Ra9O
         uAeg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUw0kp5hm0h7ftzTkvnIazUzwiqlkiYQa0OG6mi9jTXAvLDMvMp
	a/5AV53izP1lmIWUo63tyNggag/ZYBqJgqrB7tLZuRCAFnELeiA2IBTrXZGrurWEsWhrWQaP30R
	dBRRo6+IGI7H7ygpli2gJRtysVCh5pfAK6NjZSK/MbAUQLfegxe9NCenBmuUvMSU=
X-Received: by 2002:a17:906:8386:: with SMTP id p6mr3495409ejx.139.1565102172343;
        Tue, 06 Aug 2019 07:36:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw424VgJVy/kWKVAbhvvS2UBgyG737yToAAyLTYeFDcrlsIFIc3wRxRhG9nk1euV1JW+uOr
X-Received: by 2002:a17:906:8386:: with SMTP id p6mr3495332ejx.139.1565102171531;
        Tue, 06 Aug 2019 07:36:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565102171; cv=none;
        d=google.com; s=arc-20160816;
        b=HsNKNXZhe+xSZuNtX254I0fUswqBsCsrpqKOBmn/tk/pBKolzjZwORSXEbumQ0K/xv
         02k69/6yo5AVC8aJgyroWkgzOOT/whXrF16UGWkiilHB0ig9rEEv5D3nsr8G6jMOpu0A
         aHWP7Y+WjP+u3VEAHkgGTQdTz50I/K7nh7JoJsOxCQNqe1q+XOlyD/O84eD9/FLKoIvw
         ZP32BnKkX3tLo17POX4K2a+uOeQ0WPtnqqhxoNrk3EA6/EyNynplYMfJFk/n+wwYEatr
         70K6dayvlbXy+uDcE1VlzHoa50xx7GsSQbvWXKGC/q6WKprSppuhXQNBG8p2xDXLo39j
         1myQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=y7BrABq3gCM5NwrWP3u6YNUhVFfVU59M/ZD27Xiu4XY=;
        b=pa+iPMCDIbNaZXBk/1ULuhMBKtICjEzyN1hDTFSgHG76CbwbPONcV1FaNpGTiUH9+y
         xt4iKaZmUZYybZGENTBYxZzkwa+A4uWPmEUiNxZQCa2lCohA4irFEKevsGNwimhQKS/V
         9uXMyigg6hOZNFwcQqicZEoWqDehV5o1JOMSP1OH2OgQMAOEN4PZ6OyW35sqYTPbXU9t
         P/FtwRStT853b5QcGlbg3XngkvOxCh24tUnqQ16kDfajeAUHbmh1o8JCvtEX+HPtuPvu
         b4V1/7xbD1WYc7xrWXiuEFOy5xFxNRui/ex8p8WFntXF6lmR9bq6ukQkXl0TzfBnHdBo
         7vNw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q18si27575732ejt.391.2019.08.06.07.36.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 07:36:11 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7E64CAE1B;
	Tue,  6 Aug 2019 14:36:10 +0000 (UTC)
Date: Tue, 6 Aug 2019 16:36:08 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vlastimil Babka <vbabka@suse.cz>,
	Suren Baghdasaryan <surenb@google.com>,
	"Artem S. Tashkinov" <aros@gmx.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's
 inability to gracefully handle low memory pressure
Message-ID: <20190806143608.GE11812@dhcp22.suse.cz>
References: <d9802b6a-949b-b327-c4a6-3dbca485ec20@gmx.com>
 <ce102f29-3adc-d0fd-41ee-e32c1bcd7e8d@suse.cz>
 <20190805193148.GB4128@cmpxchg.org>
 <CAJuCfpHhR+9ybt9ENzxMbdVUd_8rJN+zFbDm+5CeE2Desu82Gg@mail.gmail.com>
 <398f31f3-0353-da0c-fc54-643687bb4774@suse.cz>
 <20190806142728.GA12107@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806142728.GA12107@cmpxchg.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 06-08-19 10:27:28, Johannes Weiner wrote:
> On Tue, Aug 06, 2019 at 11:36:48AM +0200, Vlastimil Babka wrote:
> > On 8/6/19 3:08 AM, Suren Baghdasaryan wrote:
> > >> @@ -1280,3 +1285,50 @@ static int __init psi_proc_init(void)
> > >>         return 0;
> > >>  }
> > >>  module_init(psi_proc_init);
> > >> +
> > >> +#define OOM_PRESSURE_LEVEL     80
> > >> +#define OOM_PRESSURE_PERIOD    (10 * NSEC_PER_SEC)
> > > 
> > > 80% of the last 10 seconds spent in full stall would definitely be a
> > > problem. If the system was already low on memory (which it probably
> > > is, or we would not be reclaiming so hard and registering such a big
> > > stall) then oom-killer would probably kill something before 8 seconds
> > > are passed.
> > 
> > If oom killer can act faster, than great! On small embedded systems you probably
> > don't enable PSI anyway?
> > 
> > > If my line of thinking is correct, then do we really
> > > benefit from such additional protection mechanism? I might be wrong
> > > here because my experience is limited to embedded systems with
> > > relatively small amounts of memory.
> > 
> > Well, Artem in his original mail describes a minutes long stall. Things are
> > really different on a fast desktop/laptop with SSD. I have experienced this as
> > well, ending up performing manual OOM by alt-sysrq-f (then I put more RAM than
> > 8GB in the laptop). IMHO the default limit should be set so that the user
> > doesn't do that manual OOM (or hard reboot) before the mechanism kicks in. 10
> > seconds should be fine.
> 
> That's exactly what I have experienced in the past, and this was also
> the consistent story in the bug reports we have had.
> 
> I suspect it requires a certain combination of RAM size, CPU speed,
> and IO capacity: the OOM killer kicks in when reclaim fails, which
> happens when all scanned LRU pages were locked and under IO. So IO
> needs to be slow enough, or RAM small enough, that the CPU can scan
> all LRU pages while they are temporarily unreclaimable (page lock).
> 
> It may well be that on phones the RAM is small enough relative to CPU
> size.
> 
> But on desktops/servers, we frequently see that there is a wider
> window of memory consumption in which reclaim efficiency doesn't drop
> low enough for the OOM killer to kick in. In the time it takes the CPU
> to scan through RAM, enough pages will have *just* finished reading
> for reclaim to free them again and continue to make "progress".
> 
> We do know that the OOM killer might not kick in for at least 20-25
> minutes while the system is entirely unresponsive. People usually
> don't wait this long before forcibly rebooting. In a managed fleet,
> ssh heartbeat tests eventually fail and force a reboot.
> 
> I'm not sure 10s is the perfect value here, but I do think the kernel
> should try to get out of such a state, where interacting with the
> system is impossible, within a reasonable amount of time.
> 
> It could be a little too short for non-interactive number-crunching
> systems...

Would it be possible to have a module with tunning knobs as parameters
and hook into the PSI infrastructure? People can play with the setting
to their need, we wouldn't really have think about the user visible API
for the tuning and this could be easily adopted as an opt-in mechanism
without a risk of regressions.

I would really love to see a simple threshing watchdog like the one you
have proposed earlier. It is self contained and easy to play with if the
parameters are not hardcoded.

-- 
Michal Hocko
SUSE Labs

