Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD6F2C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 07:23:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7504520883
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 07:23:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7504520883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D1EF26B0270; Tue, 28 May 2019 03:23:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CCFD76B0273; Tue, 28 May 2019 03:23:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE5446B0275; Tue, 28 May 2019 03:23:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 736EC6B0270
	for <linux-mm@kvack.org>; Tue, 28 May 2019 03:23:48 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c26so31672427eda.15
        for <linux-mm@kvack.org>; Tue, 28 May 2019 00:23:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=7q87WTTa/ot1Wj66VKE+53bC/MlLpUvP7FaIekCpkDA=;
        b=Tum95obeQ+VAmoVLLOzywZ5DVIHOBDThdYMleCljBc9YJcdRkCNSVu4FtKhBb999e1
         xvcwvQB6VdOlrRqXW0iv4RQI8T7I9gZiZvJI6/y9j9CytjUMb2+iYPK1zIervU73Dlwe
         mYEF3KLrDGOvNGnxM1B+tz+RHTwW11delFFnb6vxDD4o7eUBQEdK9JRhriifWSm4ejuP
         GnirajhQG19aWnHs88W6uDqPYFK4kFI8rUK6Eyk7MqWIDFwzPUxYSStvd3eYxanozq+4
         Idb6P4fBXIYylwQ3RcaBNSJG8ODdwSgi7yq++QPnxTTEiydiRylx5P3opETwmqEhsnnI
         Ojvg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXYbbmFaLIAl18WdylT+8pBqBwbn4fgyW0uuL2PhBTl7toANsB7
	/yJ0VSdPMk98WZaPsp/WQDcW3I6+3Df38ZmytrXMlyuLWNzW5nT8UJFDl+oSkarbGMnt9+j2LFC
	7/4UTWhDCVIjSv2ZTZhND2iWnqYpAne59NUu7D/CjUKZQQ/zOLFhhv3DiKcBShfA=
X-Received: by 2002:a50:e048:: with SMTP id g8mr127595263edl.26.1559028228007;
        Tue, 28 May 2019 00:23:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqybe08w/7+K1TscIGrcXvz3OtpI08teB3smZ0joNpVG+yGQyYk6ZTcDhALabt7apoOApzM0
X-Received: by 2002:a50:e048:: with SMTP id g8mr127595174edl.26.1559028226541;
        Tue, 28 May 2019 00:23:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559028226; cv=none;
        d=google.com; s=arc-20160816;
        b=g1XwEnh1IxK1E8lzHc6RcDffl7d4BlY1uzH2qdLdVVi2PNDU6uEk72Sxb4jYnnttt/
         uTtlVBK1J+wLyOgYek1u/NdzZ7BANB2eASVYLeKjSp+X4xUXf41JnPSNkrMxvRbm9zVv
         9bqX9vMuN7biS7NqdVzRPGukhIbfOlEkaNrwIssviSP4b8JW+xj3QqAJvODr9meyDPzX
         tmWhTXtWqTjmpiMhVGgAZEr8UfYnvsyPiqJbffQnwHM+sedi/5ywcmn9ojZqdVY+9WiA
         AO+RPitA6aeRo33obI16f1/FQyrwKX1eVmPbxGBx1Y8i6KreUzpCQ7fKUW8Fsy9/n4zu
         lfGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=7q87WTTa/ot1Wj66VKE+53bC/MlLpUvP7FaIekCpkDA=;
        b=xgbuDfY7Kuszm7wFYGZY7Xr/o3k+HmUEsinzJOH9XivBXn5YSM7wQOQbWSHmBJxTyo
         zGFRYFiRlgICB06DdyoipShjdf6c35Ix98Tf+0q6JdAU7mh2Q5ajokgpHN+OmBXygepK
         N/YmMWPL61gvF7pPnW2DBjdQSP2LsL5gvVmgCcXoZXJboJgc45/HEwHaABM0Xy7L2v74
         XR/yvFbIWH92ujXaL7/olByAlKYuFn/owbKqSp3hgQMRUslJIqSpxRgrizZdCv+5ju2Q
         tncrHEkULrqq9JXDffcbyL1jQeVDdnVZkHEXHsqWqf4Ewb2eg/tkXCwzQZgyXEQlmpTD
         1zsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p12si188765eju.75.2019.05.28.00.23.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 00:23:46 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B7A0CADC1;
	Tue, 28 May 2019 07:23:45 +0000 (UTC)
Date: Tue, 28 May 2019 09:23:44 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Oleg Nesterov <oleg@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 5/7] mm: introduce external memory hinting API
Message-ID: <20190528072344.GO1658@dhcp22.suse.cz>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-6-minchan@kernel.org>
 <20190521153113.GA2235@redhat.com>
 <20190527074300.GA6879@google.com>
 <20190527151201.GB8961@redhat.com>
 <20190527233306.GE6879@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527233306.GE6879@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 28-05-19 08:33:06, Minchan Kim wrote:
> On Mon, May 27, 2019 at 05:12:02PM +0200, Oleg Nesterov wrote:
> > On 05/27, Minchan Kim wrote:
> > >
> > > > another problem is that pid_task(pid) can return a zombie leader, in this case
> > > > mm_access() will fail while it shouldn't.
> > >
> > > I'm sorry. I didn't notice that. However, I couldn't understand your point.
> > > Why do you think mm_access shouldn't fail even though pid_task returns
> > > a zombie leader?
> > 
> > The leader can exit (call sys_exit(), not sys_exit_group()), this won't affect
> > other threads. In this case the process is still alive even if the leader thread
> > is zombie. That is why we have find_lock_task_mm().
> 
> Thanks for clarification, Oleg. Then, Let me have a further question.
> 
> It means process_vm_readv, move_pages have same problem too because find_task_by_vpid
> can return a zomebie leader and next line checks for mm_struct validation makes a
> failure. My understand is correct? If so, we need to fix all places.

Isn't that a problem of most callers of get_task_mm? Shouldn't we fix it
turning it into find_lock_task_mm?
-- 
Michal Hocko
SUSE Labs

