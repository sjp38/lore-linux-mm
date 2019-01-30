Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B590BC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 18:16:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7582520870
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 18:16:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7582520870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 29B978E0003; Wed, 30 Jan 2019 13:16:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 24AF28E0001; Wed, 30 Jan 2019 13:16:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 13A058E0003; Wed, 30 Jan 2019 13:16:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id ACF348E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 13:16:36 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id f17so154623edm.20
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 10:16:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=3W4UalfXa4tLjbHR50VZ2eyB3qrm+50BnUgHtZmFAQE=;
        b=Kigm2YGdFw/AB5SAR7j/P1kZqKN9k5L6kKMdkJ9lj2tk+z+FhRVZTcYkI2v9eqs9Mt
         mQkzn715WoqVdt9RkwgbIRijSgfyiORx6SLkL11dZLiUd2o8gJM8PqeDzXOPg6ruJdul
         iFJ6d0Hj431K/drO4c85PHBG7x7BNBphbaN0KyqHwPfnHSQuwQ7Loxf/vmUPccQOoQrk
         XeQ46BBMyDO4ZAw7LDIaq7ci+K06JyR7OVdydmtM5H/H8YegomxZWf1znTMfIUwpBQPM
         r467+gNcIgHxjzRbuW8t9NtygB4W7SrG02qCSOXnFhbljxpAsSyW9KlxaZREqd7lx7mL
         vBVQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukd/f2C/bMhMejuIOna7h/4r8JjhzWnL4hPAZ5kR7vqgHhNUapFL
	Lriy0dHcIs0B+XN7PKHgYPgKUgnsLJuYVOxy+4DZtkslhfchezP5n+VQfuNod9YHDRdi64YnVbB
	Ax8ZaPuuMwOg4/dxjtBh1sB6rkoCELRT4kbpgYafrfPwN+vmUL4oGdt5NqGRb1B8=
X-Received: by 2002:a17:906:1086:: with SMTP id u6-v6mr28017558eju.82.1548872196249;
        Wed, 30 Jan 2019 10:16:36 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5sSO18Cv7frZAPNjmaJiPFvDBJp06eb+c8WF6dXpL9t9zQGpe72GoIYTz7ULQXTPRyDjhC
X-Received: by 2002:a17:906:1086:: with SMTP id u6-v6mr28017499eju.82.1548872195212;
        Wed, 30 Jan 2019 10:16:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548872195; cv=none;
        d=google.com; s=arc-20160816;
        b=BvhH+msG7nCHdMKqJGuSdnicfYpMXmKwmGRmD+wVEYp6rD7u4VPxaUk0pWJLnGmztQ
         DMZGQpJ2fYOxMVv7NJGrXJjFyBKTNHlGBBXEJU81yH6c5OC4gXGYQ3RtcAV6v2FhfZxC
         0DAVA/go35R8vhz9RSMLhbnKlCGEE64aewW5ny2y/yqU9xeFWtHk2/a+vlFKLXFN8/On
         PB+ZtELPYjwOuhFK1gDlpJfiRxdkW+xaQlAj7WeR7enlBTUBZG+UgJGQTxwqF8O2WaB+
         P5RExTfhzxVPJDpb+m6wCtyhaXe8DmjETNBz1kKBlJeKw6+hbA3E8naJTZzF02Ncbm+g
         AmhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=3W4UalfXa4tLjbHR50VZ2eyB3qrm+50BnUgHtZmFAQE=;
        b=kUgkinLa0uk+IOmBku8+A1EMCAf1WgXSbSiZn8PoAOmpQDsnxbjtLMBalEPa02Glpm
         5pH6HL1rtz+Lkv3Sv6yvdSgnZYlORHDeoc0cKzUSB+8hNlQYi4Y+JFsW0iEl6mjxb77Z
         vGuUoJMKXOz1wTaZKJx/LfpCLgtufwFR9dyp0aJSsL/S7chZ5UdGz8HYD0tYsSiZ5OaN
         lelTjSx5sQ6rmNqfbwuQd3Ka11iDzzyUWET7BHhWsJtOiTefokkw/Fat0l6n9EHcwO5a
         E6KzqQooz1hWRAMFMzB1vGM4/4KgR06htv6JQfb3aTUom2NA6NauCdLAhxt3fK5MYWdM
         aRJg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a7si1231375edl.383.2019.01.30.10.16.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 10:16:35 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7CA96B01B;
	Wed, 30 Jan 2019 18:16:34 +0000 (UTC)
Date: Wed, 30 Jan 2019 19:16:30 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Down <chris@chrisdown.name>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190130181630.GF18811@dhcp22.suse.cz>
References: <20190128151859.GO18811@dhcp22.suse.cz>
 <20190128154150.GQ50184@devbig004.ftw2.facebook.com>
 <20190128170526.GQ18811@dhcp22.suse.cz>
 <20190128174905.GU50184@devbig004.ftw2.facebook.com>
 <20190129144306.GO18811@dhcp22.suse.cz>
 <20190129145240.GX50184@devbig004.ftw2.facebook.com>
 <20190130165058.GA18811@dhcp22.suse.cz>
 <20190130170658.GY50184@devbig004.ftw2.facebook.com>
 <20190130174117.GC18811@dhcp22.suse.cz>
 <20190130175222.GA50184@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190130175222.GA50184@devbig004.ftw2.facebook.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 30-01-19 09:52:22, Tejun Heo wrote:
> On Wed, Jan 30, 2019 at 06:41:17PM +0100, Michal Hocko wrote:
> > But we are discussing the file name effectively. I do not see a long
> > term maintenance burden. Confusing? Probably yes but that is were the
> 
> Cost on user side.
> 
> > documentation would be helpful.
> 
> which is an a lot worse option with way higher total cost.

And how exactly does the cost get any smaller with a mount option. The
consumer of the API will likely not know there are two modes and check
for it to figure out how to interpret those values. Or maybe I still do
not follow how exactly is the mount option supposed to work.

-- 
Michal Hocko
SUSE Labs

