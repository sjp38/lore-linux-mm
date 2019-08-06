Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7E13C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 14:27:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DC072089E
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 14:27:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="bav8Zaoj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DC072089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A9666B0003; Tue,  6 Aug 2019 10:27:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 25BE86B0006; Tue,  6 Aug 2019 10:27:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 149656B0007; Tue,  6 Aug 2019 10:27:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id D19066B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 10:27:35 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 71so48469735pld.1
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 07:27:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=YvOUxLGsf5REbDYV1mt1/FJ++s5a0U4QlhLEhk90+sU=;
        b=ZvQnFT9DQBpQcN7nejCrLW8AUTH2ujrwsdX1WqgncPB2uoaHLx/N2uA0lILOWOvTgx
         JPcQt0RvXC3kcEUnoHoSK9K+Om5ZmEwerQUXGD7F+/RgeNtdAu3AFCDA2blPzCc5lQkj
         qIe78flhz44uyrH2wJjIiE5AOU0ocqllJIrDiciyfYt6MvqCuADtgQfJmBBD/KVpXLGu
         alvjHxfGXmSZY8BfBLkbHzkAmJV0m/B1uUEQ6jDWPCW4OAEOwKWR3MuOWxsHxffgC7zx
         UJTHErys8g39P/RTnfRv3FLbQBK36GOhXMoY1B/noslFNOGf148YelZnpebCcngc7pwq
         fEXg==
X-Gm-Message-State: APjAAAWyQWJI6UDaZoDBSugN59Lk/9plWiZWAYIy8+sbNTCekfRLibUG
	xtjRcCak9ngoB2bjo7/dfSK2IKKINdlnkVZIVEYyNTsShTLFyHO1TCkf7GhXmCT0y4/+svmn+YI
	4a/HJRPYUi+IxIU3TdnbhEI+yfpPrrfv4Jdq+XD75AJYrdgeoiEKFAaMnw7qeKw6f1g==
X-Received: by 2002:a62:e806:: with SMTP id c6mr4010391pfi.158.1565101655437;
        Tue, 06 Aug 2019 07:27:35 -0700 (PDT)
X-Received: by 2002:a62:e806:: with SMTP id c6mr4010317pfi.158.1565101654362;
        Tue, 06 Aug 2019 07:27:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565101654; cv=none;
        d=google.com; s=arc-20160816;
        b=UIln3UHHDiuJp2xZBnDtJHJSLmjmgrQT/u+MOrto+aXITfLTmTCn1WPfPPVBkT4you
         rpm7+sU/WC/+iLNK1ulHzhLi8jvuGYHR1JXgefqaLhunSyMrYiS21ipbxECx+40Ab2j6
         TS6o2yeH+K4F+tzn43NxnoIiC9HUaZmTdzqKYyLOuwJCPtzlZ5+bN6r4n9/kH47xA76f
         Q1WDkQuoZTz3nP+0raqqeKRi7wlxi6TW18hHCryC2rrbNILTj/dLul82UUK2UYdYuWcZ
         CE8m8k0CAU0ESU7QaIeipBTJd8GxI3BZxESwkZkgcWU9Y7YXl92Iyyfm9jz10kZkxuAQ
         EwwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=YvOUxLGsf5REbDYV1mt1/FJ++s5a0U4QlhLEhk90+sU=;
        b=BRbWjqHWeg6TxPo6DevKPk0iWlk+JO/RRULa9UIJkZZcGrYtv6zWbd6/LNrlu3r3dD
         Br2XxKtHw7Q/Zq9h6DRoin9do/+ldFbQTg4bcoEMLH9Og/GgI4dPTJZ6iShvc+mpH9WU
         J95RnO7RcbCscSq795dmoeAeYcLUs0lH8c3zxBDQsBI+uFKMBuqmSglvMT4UBELTQ5lx
         Ko77Rt4ED2ZKcI5znmX4ipMo0WuTvNJlI1P9lm5qaohgLsyF4CQ2AcEHf+5zZiVgFcWL
         IyYK+xODU1tQLq2qIH4qPOdoHIiG7WJ5KJIzp6YKt9Bep6OLfHvFgd1hRtT63RfwT3oh
         lxiA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=bav8Zaoj;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q30sor24436822pjc.13.2019.08.06.07.27.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 07:27:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=bav8Zaoj;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=YvOUxLGsf5REbDYV1mt1/FJ++s5a0U4QlhLEhk90+sU=;
        b=bav8ZaojXR2Z1rc/BSjwZS8N8F2yIt51pqZ9cgUxBwuiI7HYHuqFHm1uYhsEremsJI
         azzUR1HDyAxtnNEoC+W+p2eC9uW61STp/ZcwWg/9VoU+oVBY3aQruRGgTkIIkurZoLm3
         4hjNwy/j6L6826Mb2Oz7HSMWHLSv5A0dXSrPrA2ADmADUWhJke99tYUoF4dRf3S7bgJ2
         MhsnutogSlmdTGxC78N0ZhJ3MBhlvZOihF8d+7rOwih3jSYHA6NCgFrO5k4ShxzJB+8k
         GMx9eeEZ3TtRrmShFv6Z9tNtRCtNQep2h0lHdL0Ci+d30x7RVDgNKdmZcdgt12G6eG9n
         aHxQ==
X-Google-Smtp-Source: APXvYqw+mL4dtvDqG/HOBlE/eKxohKGn3vxgXC9NjINqDpnyasVQ2CQ/+l+kO0tma8baClGGqllUxg==
X-Received: by 2002:a17:90a:c391:: with SMTP id h17mr3525011pjt.131.1565101651110;
        Tue, 06 Aug 2019 07:27:31 -0700 (PDT)
Received: from localhost ([2620:10d:c090:180::9890])
        by smtp.gmail.com with ESMTPSA id c26sm91636411pfr.172.2019.08.06.07.27.29
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 07:27:30 -0700 (PDT)
Date: Tue, 6 Aug 2019 10:27:28 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Suren Baghdasaryan <surenb@google.com>,
	"Artem S. Tashkinov" <aros@gmx.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's
 inability to gracefully handle low memory pressure
Message-ID: <20190806142728.GA12107@cmpxchg.org>
References: <d9802b6a-949b-b327-c4a6-3dbca485ec20@gmx.com>
 <ce102f29-3adc-d0fd-41ee-e32c1bcd7e8d@suse.cz>
 <20190805193148.GB4128@cmpxchg.org>
 <CAJuCfpHhR+9ybt9ENzxMbdVUd_8rJN+zFbDm+5CeE2Desu82Gg@mail.gmail.com>
 <398f31f3-0353-da0c-fc54-643687bb4774@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <398f31f3-0353-da0c-fc54-643687bb4774@suse.cz>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 11:36:48AM +0200, Vlastimil Babka wrote:
> On 8/6/19 3:08 AM, Suren Baghdasaryan wrote:
> >> @@ -1280,3 +1285,50 @@ static int __init psi_proc_init(void)
> >>         return 0;
> >>  }
> >>  module_init(psi_proc_init);
> >> +
> >> +#define OOM_PRESSURE_LEVEL     80
> >> +#define OOM_PRESSURE_PERIOD    (10 * NSEC_PER_SEC)
> > 
> > 80% of the last 10 seconds spent in full stall would definitely be a
> > problem. If the system was already low on memory (which it probably
> > is, or we would not be reclaiming so hard and registering such a big
> > stall) then oom-killer would probably kill something before 8 seconds
> > are passed.
> 
> If oom killer can act faster, than great! On small embedded systems you probably
> don't enable PSI anyway?
> 
> > If my line of thinking is correct, then do we really
> > benefit from such additional protection mechanism? I might be wrong
> > here because my experience is limited to embedded systems with
> > relatively small amounts of memory.
> 
> Well, Artem in his original mail describes a minutes long stall. Things are
> really different on a fast desktop/laptop with SSD. I have experienced this as
> well, ending up performing manual OOM by alt-sysrq-f (then I put more RAM than
> 8GB in the laptop). IMHO the default limit should be set so that the user
> doesn't do that manual OOM (or hard reboot) before the mechanism kicks in. 10
> seconds should be fine.

That's exactly what I have experienced in the past, and this was also
the consistent story in the bug reports we have had.

I suspect it requires a certain combination of RAM size, CPU speed,
and IO capacity: the OOM killer kicks in when reclaim fails, which
happens when all scanned LRU pages were locked and under IO. So IO
needs to be slow enough, or RAM small enough, that the CPU can scan
all LRU pages while they are temporarily unreclaimable (page lock).

It may well be that on phones the RAM is small enough relative to CPU
size.

But on desktops/servers, we frequently see that there is a wider
window of memory consumption in which reclaim efficiency doesn't drop
low enough for the OOM killer to kick in. In the time it takes the CPU
to scan through RAM, enough pages will have *just* finished reading
for reclaim to free them again and continue to make "progress".

We do know that the OOM killer might not kick in for at least 20-25
minutes while the system is entirely unresponsive. People usually
don't wait this long before forcibly rebooting. In a managed fleet,
ssh heartbeat tests eventually fail and force a reboot.

I'm not sure 10s is the perfect value here, but I do think the kernel
should try to get out of such a state, where interacting with the
system is impossible, within a reasonable amount of time.

It could be a little too short for non-interactive number-crunching
systems...

