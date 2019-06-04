Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE836C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 07:02:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 959FE24DB4
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 07:02:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 959FE24DB4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 10C886B000A; Tue,  4 Jun 2019 03:02:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0BD536B000D; Tue,  4 Jun 2019 03:02:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EED086B0266; Tue,  4 Jun 2019 03:02:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9F36F6B000A
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 03:02:32 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b33so11211688edc.17
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 00:02:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xdt80mBbVFMBQSshlDttmReozy5pSqDzJQYrUFRB++8=;
        b=jMG9qcinbXKwEZoBGHN1cq67IqPyLHamlWegS7SdSC9u54cu13AIfehQwzI1jyC9gd
         Ccjtzr/e7Mkb0atllqks9fklPXHrRYsmnNiYVQiVeVer0jWzryIrC1wKUCPgWjzBQy2N
         LyXzS698pztbzgJkNAA6PfqVZKWi8f85NAvs2C2AeSO2E7zccSJTVWsnk2JczBwdifqK
         ohmdqWbP/O2LYPb58mHycYHq1cMFHRRSsH01Izvbc2s8vzsl4otsBohT6SILuCVicZ4V
         dlavL8eYtv1hM2xdN9VCYl+I1skhP1jonSmcAW49mfPSYXpBxtXgHNbW+6oFqA9zVCmJ
         Wfpw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWg0V0nAemNyq2aflT8hUeZJZVc0cnGzAHwb7RAfhAST7qnqw63
	KBugKpF3gxmesnf9rYenSpedj2iwbuz6OBkciFuuD1QK7/4IDHeXM2YmIa6jGPf1Y+WsZYXp13A
	6BG/c4EBxeV8dpkhWHCwEpR7FlYtMRhsS0tnK8NybfUnFq0i/201yXvOpKQIGJLo=
X-Received: by 2002:aa7:cdc4:: with SMTP id h4mr23858945edw.221.1559631752232;
        Tue, 04 Jun 2019 00:02:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0t103jHUHoqkB8qlUq8bc6xDOe6sA8jUdOAsNMCGrDylcEk5p8Q6DV4lGUiD7JhK87Inz
X-Received: by 2002:aa7:cdc4:: with SMTP id h4mr23858847edw.221.1559631751286;
        Tue, 04 Jun 2019 00:02:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559631751; cv=none;
        d=google.com; s=arc-20160816;
        b=kVON2cPNgkb/uLeYvHYP/N4+JbLVmkQiTQqwe6aR1BxW1XgFSRJcULj5e9Fg3pDWgY
         jpTI8Q7mb0CcTPlFzc+fb5c+7eQvqyJTm3tUqZVPi/tZ+XqU4cVmO/FIIvlSSYw6R/mJ
         psNslCmSD6leslP7dOaI96nnPrEjppLuVNDXy0VPb78nxlLC/F3X8gl6rUovBCrbsF35
         x5s9AQrrNtyo7BBE2lRtM9bNeWECZzasGrx0naPE2aPLbayySKXii83uaImY7yQaydIn
         Qux9l1vIKskhsK37tEODbFNPN9Udf0wLGt9/UNMnlwqIWmFc/PrH/uF0tghsy0GQPGnw
         nkQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=xdt80mBbVFMBQSshlDttmReozy5pSqDzJQYrUFRB++8=;
        b=HpoacojFUDdceCTe07ApRfBuxNhU0yQP9KH2191zoqUi3xmAg7st9fymHP4lNe4V8T
         Oki7zmSt/snXBO+P0ScViIurgPIIGB1sI1mTl31IAD9WTmlJs0DqQb3qZPBf3d9aQBjp
         GzE+e4ns3V8VUVtCHnGVXUPp17RU9zqtAGcCoFjXgnpeM6vxKHEV9cgY6NrgidnWmAu8
         6T3hO1/rapP/+SWKETuKfzqmk0eVTEbOJA+QmaTbtxbe9z2zwhoRbvPX2ZFRDQ/eaWLB
         NShOuyFt+yP/ybhg55DSdnDpEGycBiWjKXFL4ImGx9qpIkr5FnQzXviGrOk5mQyFm9Zi
         Ljfw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f3si4073973ejb.138.2019.06.04.00.02.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 00:02:31 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 58B31AE4E;
	Tue,  4 Jun 2019 07:02:30 +0000 (UTC)
Date: Tue, 4 Jun 2019 09:02:28 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, oleksandr@redhat.com,
	hdanton@sina.com
Subject: Re: [RFCv2 1/6] mm: introduce MADV_COLD
Message-ID: <20190604070228.GD4669@dhcp22.suse.cz>
References: <20190531064313.193437-1-minchan@kernel.org>
 <20190531064313.193437-2-minchan@kernel.org>
 <20190531084752.GI6896@dhcp22.suse.cz>
 <20190531133904.GC195463@google.com>
 <20190531140332.GT6896@dhcp22.suse.cz>
 <20190531143407.GB216592@google.com>
 <20190603071607.GB4531@dhcp22.suse.cz>
 <20190604042651.GC43390@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190604042651.GC43390@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 04-06-19 13:26:51, Minchan Kim wrote:
> On Mon, Jun 03, 2019 at 09:16:07AM +0200, Michal Hocko wrote:
[...]
> > Right. But there is still the page cache reclaim. Is it expected that
> > an explicitly cold memory doesn't get reclaimed because we have a
> > sufficient amount of page cache (a very common case) and we never age
> > anonymous memory because of that?
> 
> If there are lots of used-once pages in file-LRU, I think there is no
> need to reclaim anonymous pages because it needs bigger overhead due to
> IO. It has been true for a long time in current VM policy.

You are making an assumption which is not universally true. If I _know_
that there is a considerable amount of idle anonymous memory then I
would really prefer if it goes to the swap rather than make a pressure
on caching. Inactive list is not guaranteed to contain only used-once
pages, right?

Anyway, as already mentioned, we can start with a simpler implementation
for now and explicitly note that pagecache biased reclaim is known to be
a problem potentially. I am pretty sure somebody will come sooner or
later and we can address the problem then with some good numbers to back
the additional complexity.

-- 
Michal Hocko
SUSE Labs

