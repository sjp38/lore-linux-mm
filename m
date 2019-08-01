Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64F5BC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 16:32:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3009220B7C
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 16:32:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3009220B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C8DE28E0034; Thu,  1 Aug 2019 12:32:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C3E2E8E0001; Thu,  1 Aug 2019 12:32:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B53DE8E0034; Thu,  1 Aug 2019 12:32:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 697A98E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 12:32:18 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f3so45213420edx.10
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 09:32:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=SMkRwo+3GMU59u7ixTlNuVLK8LmqMc+rJ2f6Uq4N7xU=;
        b=kp4aRkqQTmSmVJpSCUYVNln0pfZttWgBvolnPI6qWEGmkLct+DuGZ8SXlxK3fTbr2s
         HPOUe5th6B0mU9hr/rButpHLIkAcUrxzIGuB1apD3eRJ+gbzxUk2Pu38ilN6OkHwAVUL
         L9XneflN0UWY2leQUooBChzT0tknZR+0lTfdVe4mgmLC5E/R1rMBhSqENJrren1kPlBt
         0Cmh2YoyRdhsURFf5llqqEMWNU0pWtmGjriJq1OyLMROuUbm8RgXwh7n9yC3otWaYuXU
         x63WFhn/W4Y5rpm1ZvqBv2pewLTXBl73dSjFCfV9SQ95irFc80TFjT8QY/Yk+e2hbx2f
         jDjA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVhdJJhmRLXAepPkVLpAiyTcUvrRKj1HtYpAsxXknnYtdIj9Jxa
	zh9p801p1i2K6S4QGjoz81uYtctb0PU3rUOSOFyJ5qZNeiEJsPKGWQikVWz2cPDm9h6uUVFhwlH
	TGkdncVZT4iMDUi+Mwarpq1+oRC5mLMcOXyoY1q6tiDXGnZCTgfGxG6MHUWu7IxQ=
X-Received: by 2002:a50:b875:: with SMTP id k50mr115384347ede.232.1564677138018;
        Thu, 01 Aug 2019 09:32:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyK0wOfCJkiECsbFZVn9QVJf1iYnSkXlHAIo49mCMSGBBxFqfVRTlhnis5PGNrhE8liZTVB
X-Received: by 2002:a50:b875:: with SMTP id k50mr115384252ede.232.1564677137058;
        Thu, 01 Aug 2019 09:32:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564677137; cv=none;
        d=google.com; s=arc-20160816;
        b=n9iDyDIRGjeD5HZDkCx119aGMWRLkfH353KdwYDd0YosrVbrfCfjvF2hYHht2nr6bq
         9TMk/659Lwjz6Acjvf2LTkwuSw3uDrSElQ27DAJfJOTsQZ/LIZvKbpLuTMR7EI5pV0Ku
         UVl2FAH9WwX8FV38FWT5fPqLEw0olPzpM0DyqaFLDeo/Kr/XL2jt9Q/FBAdCA9Gvbab6
         6TqPKSRBw+RpQNqmU8qEcYPWWQa2RU+XtXk3udzXK2il02JQOovvyX6HO8vnNxJIrJFm
         B7AtKenDCi6sYCfeY/fME0PM+QrGzcaJZyCu+z6EKC6RgBUifDFX8/4mmx8HzdptKBpX
         llIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=SMkRwo+3GMU59u7ixTlNuVLK8LmqMc+rJ2f6Uq4N7xU=;
        b=ONlkaLanp6MyhC800pKizISLSLQ2MA1zbV9NncfDVZgkaeiRQwV7J7is2BPN5cGebX
         U7Wk9th8axxNosvv9uIM9+dohpVlZk4Txr8PBd8KqIroO5CHl3856QzghTNGc65IhMAz
         G0gF0W58zL5GWuqwIlT8FAC0uIa8RIFS7kOujh7mEVLwA6vI+bI4bmRi4A1hi+nZlCwx
         KZ+wnNgau9IUjUADIKQsqjJu6ry5uUxKVzWe/SxlkmPRlObiJMAEv61JtwCgA97FcD21
         qZTUa06/xRsgwpKkG7IbCZPxIU1FW3syqOfLnRyxT46Q0lUC0jDhBDT63Tfkc6wRLQUz
         Hphg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b12si21243613ejd.385.2019.08.01.09.32.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 09:32:17 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F04C7AFF3;
	Thu,  1 Aug 2019 16:32:15 +0000 (UTC)
Date: Thu, 1 Aug 2019 18:32:13 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Jan Hadrava <had@kam.mff.cuni.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	wizards@kam.mff.cuni.cz, Kirill Tkhai <ktkhai@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	Shakeel Butt <shakeelb@google.com>
Subject: Re: [BUG]: mm/vmscan.c: shrink_slab does not work correctly with
 memcg disabled via commandline
Message-ID: <20190801163213.GO11627@dhcp22.suse.cz>
References: <20190801134250.scbfnjewahbt5zui@kam.mff.cuni.cz>
 <20190801140610.GM11627@dhcp22.suse.cz>
 <20190801155434.2dftso2wuggfuv7a@kam.mff.cuni.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190801155434.2dftso2wuggfuv7a@kam.mff.cuni.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 01-08-19 17:54:34, Jan Hadrava wrote:
> On Thu, Aug 01, 2019 at 04:06:10PM +0200, Michal Hocko wrote:
> > On Thu 01-08-19 15:42:50, Jan Hadrava wrote:
> > > There seems to be a bug in mm/vmscan.c shrink_slab function when kernel is
> > > compilled with CONFIG_MEMCG=y and it is then disabled at boot with commandline
> > > parameter cgroup_disable=memory. SLABs are then not getting shrinked if the
> > > system memory is consumed by userspace.
> > 
> > This looks similar to http://lkml.kernel.org/r/1563385526-20805-1-git-send-email-yang.shi@linux.alibaba.com
> > although the culprit commit has been identified to be different. Could
> > you try it out please? Maybe we need more fixes.
> 
> Yes, it is same.

I am happy to hear that!

> So my report is duplicate and I'm just bad in searching the
> archives, sorry.

No worries. Your bug report was really good with great level of details.
I wish all the bug reports were done so thoroughly.
 
> Just to be sure, i run my tests and patch proposed in the original thread
> solves my issue in all four affected stable releases:

Cc Andrew. I assume we can assume your Tested-by tag?

Thanks a lot!
-- 
Michal Hocko
SUSE Labs

