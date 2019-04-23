Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2823AC10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 17:31:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE767206BA
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 17:31:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="1a4epwwr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE767206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 72C6A6B0003; Tue, 23 Apr 2019 13:31:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6DCC66B0005; Tue, 23 Apr 2019 13:31:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F4DC6B0007; Tue, 23 Apr 2019 13:31:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2275C6B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 13:31:36 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j18so10090823pfi.20
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 10:31:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=L1WmCDYyvHgiMlA1gUf3QVH5yJIyk9JE2RhTUMHtHrc=;
        b=s6pz294dU38moPn5+357x4UPvnVtjomMxjclkdOifRidZTk7cHCsC2QBA2y+DCO9tu
         vrAigfLiz22uItJb/lZb64ZfQZ82oNI/LqaAmC4r08NswCyFNdK7rB/tCkXbaxvtU5E7
         XOGrvJzmTTVUoZGcxMxEgwAaUmZ1Q2hZ5ZoMEsvl5lzsmiK4J6fyOBy/1aSrfiGPGjtn
         gGEFxEu0XEL3nXf6W6GkJ0Z5BZ0s66l7lDv6RWkOQy8axwqyHCDiWZ/ePMXDUAweNfne
         6VQkHyIvhMk6pJV9tiNaIx/JgV1ISBcICH9rvtq07WcfiNdhF5KdKi/3aO40YsN2gvJ3
         XZlA==
X-Gm-Message-State: APjAAAUgLjQkvGPbESs3N0/VA9w2QbBn51HCcvwDp0Hxu13H//ZnqaeP
	1r84S1IsagPY3zSsVtVHjXSkjoERgYYA7fjBXuHnjhFViY0Lz44hqt4M+KOokCWYATyt/TL4sRe
	JIOfegw1Tk31k7m4ruIqynBOnfx/niw0A7zMGtsJWCOlHA2ETkSWVJLSlx3omcTJKLw==
X-Received: by 2002:aa7:8c84:: with SMTP id p4mr9789396pfd.164.1556040695710;
        Tue, 23 Apr 2019 10:31:35 -0700 (PDT)
X-Received: by 2002:aa7:8c84:: with SMTP id p4mr9789311pfd.164.1556040694803;
        Tue, 23 Apr 2019 10:31:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556040694; cv=none;
        d=google.com; s=arc-20160816;
        b=HusFqOLwW0e92FTm+vDKc2oLPZ3vT45TNucjnZGOn6WnhaT61Pvmlewa/vtONP3TYY
         xpAFbEDpZUJOOkhFxy8ej5z8fJH66QsNa6PiWWDfEsGmzaMAC9j2NylqeiXWLf0/07bw
         sw8Vb1gDsdCCFUTjwUhe6W5iyvd+OMpg8Rgin1Cbq0vKqF1gQ61dxvxwt3SgA5RPIyCW
         uGAv1/1phqprqfYaP/jjyFRKJepFWga+CObeELViCNVJfQtX2gLrPxYQxGYnL9hLOPHk
         V7EvPwjeFCnI/3xbJFe2ukz+r9vOp21b6oTLroyMnrYcMd9BJlfS8XHuaoiJBfHhS8qu
         ccKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=L1WmCDYyvHgiMlA1gUf3QVH5yJIyk9JE2RhTUMHtHrc=;
        b=eWJluDDeOvmAMJeJY8l5qhGMRY5HNfST6JZ6bMZbtRbw4keiZtWgt6TPEqV3c7VCmu
         8Pso8CC56dImQ3h0ZKZBDMoPCzzgEwiyUTM7EkLfpwx1QmTyocctKiZrLLa266QO9pZx
         kvNuWFYrZnp+oK8v3YDAQ4s8aftxas3JlChIy/AVIp4q/GdFpgQePQHqhntsYlico4nb
         TXZ4ukxxS7xZG79Gzq2OACQGDju8JeO93cP7C5SSFbQMVt6+YP7H+mXtZB5sbC8S699J
         85KhajTRTKFi7B3Y1JDdwe9XP19lh2gO0LTr7v0SF/z7+Xr2Oj6ke2Uyhda8bkJF5CK9
         eRxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=1a4epwwr;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f24sor18697911pfn.22.2019.04.23.10.31.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Apr 2019 10:31:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=1a4epwwr;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=L1WmCDYyvHgiMlA1gUf3QVH5yJIyk9JE2RhTUMHtHrc=;
        b=1a4epwwrkbXeTKViUDyaQDbVESbDzJc9T8CWHzir+Tqee4qx7wFITDQDTF92T/IGwl
         PSARxSdVztPahK4Z35XZEZnWBzjdBf2Luqova/q6DvFI2YuRoqxg+2IUZ7FiN+Y85lqf
         CKVGU3BRbiEz5nmvBsD4515otaTmH5mtgu3MKw0dfH0ctksUo0uPjK3+jpCTtOr6rS5I
         azDgfgvDlWA6x4JgRT/6IoFdLEXVy4PuQXS5FbwJmH5cdnB1ZEzrE/Cyz8azj9J5pAa4
         Go9dBzOcTUI0XBNwM1bEHH2TtNG07Beo99Gs1t2tiXYTSQfK2/EhdmJo0Y6+gA3IALiy
         stTg==
X-Google-Smtp-Source: APXvYqxYYmAqds/36N0MP8a52j8h8ZGTARgQ3QY+aNhPoNQ8MzkZu4UCfXQNPbgCmNoMU0jwhGWpug==
X-Received: by 2002:a62:19ca:: with SMTP id 193mr365152pfz.227.1556040691930;
        Tue, 23 Apr 2019 10:31:31 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:6d60])
        by smtp.gmail.com with ESMTPSA id f2sm31450377pgc.30.2019.04.23.10.31.29
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Apr 2019 10:31:30 -0700 (PDT)
Date: Tue, 23 Apr 2019 13:31:28 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: lsf-pc@lists.linux-foundation.org, Linux MM <linux-mm@kvack.org>,
	Michal Hocko <mhocko@kernel.org>, Rik van Riel <riel@surriel.com>,
	Roman Gushchin <guro@fb.com>
Subject: Re: [LSF/MM TOPIC] Proactive Memory Reclaim
Message-ID: <20190423173128.GA3601@cmpxchg.org>
References: <CALvZod4V+56pZbPkFDYO3+60Xr0_ZjiSgrfJKs_=Bd4AjdvFzA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod4V+56pZbPkFDYO3+60Xr0_ZjiSgrfJKs_=Bd4AjdvFzA@mail.gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Shakeel,

On Tue, Apr 23, 2019 at 08:30:46AM -0700, Shakeel Butt wrote:
> Though this is quite late, I still want to propose a topic for
> discussion during LSFMM'19 which I think will be beneficial for Linux
> users in general but particularly the data center users running a
> range of different workloads and want to reduce the memory cost.
> 
> Topic: Proactive Memory Reclaim
> 
> Motivation/Problem: Memory overcommit is most commonly used technique
> to reduce the cost of memory by large infrastructure owners. However
> memory overcommit can adversely impact the performance of latency
> sensitive applications by triggering direct memory reclaim. Direct
> reclaim is unpredictable and disastrous for latency sensitive
> applications.
> 
> Solution: Proactively reclaim memory from the system to drastically
> reduce the occurrences of direct reclaim. Target cold memory to keep
> the refault rate of the applications acceptable (i.e. no impact on the
> performance).
> 
> Challenges:
> 1. Tracking cold memory efficiently.
> 2. Lack of infrastructure to reclaim specific memory.
> 
> Details: Existing "Idle Page Tracking" allows tracking cold memory on
> a system but it becomes prohibitively expensive as the machine size
> grows. Also there is no way from the user space to reclaim a specific
> 'cold' page. I want to present our implementation of cold memory
> tracking and reclaim. The aim is to make it more generally beneficial
> to lot more users and upstream it.
> 
> More details:
> "Software-driven far-memory in warehouse-scale computers", ASPLOS'19.
> https://youtu.be/aKddds6jn1s

I would be very interested to hear about this as well.

As Rik mentions, I've been working on a way to determine the "true"
memory workingsets of our workloads. I'm using a pressure feedback
loop of psi and dynamically adjusted cgroup limits, to harness the
kernel's LRU/clock algorithm to sort out what's cold and what isn't.

This does use direct reclaim, but since psi quantifies the exact time
cost of that, it backs off before our SLAs are violated. Of course, if
necessary, this work could easily be punted to a kthread or something.

The additional refault IO also has not been a problem in practice for
us so far, since our pressure parameters are fairly conservative. But
that is a bit harder to manage - by the time you experience those you
might have already oversteered. This is where compression could help
reduce the cost of being aggressive. That said, even with conservative
settings I've managed to shave off 25-30% of the memory footprint of
common interactive jobs without affecting their performance. I suspect
that in many workloads (depending on their exact slope of the access
locality bell curve) shaving off more would require a disproportionate
amount more pressure/CPU/IO, and so might not be worthwile.

Anyway, I'd love to hear your insights on this.

