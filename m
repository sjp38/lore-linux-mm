Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19EE8C282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 09:14:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C99E620844
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 09:14:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C99E620844
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 622E58E0002; Fri,  1 Feb 2019 04:14:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D14B8E0001; Fri,  1 Feb 2019 04:14:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E7C28E0002; Fri,  1 Feb 2019 04:14:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E20B78E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 04:14:37 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id b3so2570496edi.0
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 01:14:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=r36EY1z9Gx/pTJRwRL4L5tPpjk+gWGziGjqDEt316iY=;
        b=NScwnP7nRftYct9u32jj1VCKgG5lKbkrORxGu0W4e+cFVygcccTUsclWQ6+2KwVQOs
         HUe6EIv7/D7EDTLJwYK1vf2H96FytyfL7uNeHjwuVCHIgYfElrukO5JOvVzSj+KqACse
         hLnppe8NGNKUCz6iWyhvWmCq0c59eqRwEm+2xuARGNZGYR/ghvkzXpjY9DWS8L4ijjIq
         OJZmkHPqSHraKTCDfap0VGu4Qs3sZZzQ5zfjoIgNXcaVBPzApgXm4FJVUJUKlFv1YeRi
         t3ojV3T5O3dvn58zgP6DGzzO21pffG2ZcFFnmohbliRpNf1Lqc2YrSLLEUevHfSu4rGc
         GGmg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukcPeChIM48EwJDuffz2gL9UctgKoTnp2YLQfugNOXHKTeucpqnh
	aceDiJ60AylviXmZWCc6rToBXN3BvlFRjVcX0NDdHy3wWHvPmlUT41po/yKiErvWWsSvxlVmrDq
	nzXFZ94x3s7S4FnonFm5jwY6T0m2lLHk6L/w+exn16CYy7dbZXaf+LIXg1pxmq8Q=
X-Received: by 2002:a17:906:68c3:: with SMTP id y3mr26527070ejr.126.1549012477407;
        Fri, 01 Feb 2019 01:14:37 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4s1LsAbzkhh1xJExPxq2dP6EXFJe8317BTh10nCHvVrXwpjvAM9mabYN+diRq8H1BUXQCb
X-Received: by 2002:a17:906:68c3:: with SMTP id y3mr26526990ejr.126.1549012475774;
        Fri, 01 Feb 2019 01:14:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549012475; cv=none;
        d=google.com; s=arc-20160816;
        b=CEywjgU1mUvRlsqxr9fXiQzQXq382PyK3Oxgi4EM95LG8wVJnIubYhod6KH8vCyZUv
         xfBbq9IPZGAFZ3R6CxR03FqDWkuutqmi2tPdBPrt725d61jzL7gZezAk/qzU86cNXbXX
         yqvYcYYv+C1TdoEGymaecOhzCI+iNkpGQkWWNqRj5AW24qs0GLcshxeSABUoFwXZfGxk
         18aViSehKSqu1J7Wgxg7yLJYJXw8q1IiPXFv4+zKVVuQ9eRIicqkEFFm7Pew0npButGU
         xLxbYzIrf8Y7vDecJDs7I64hlyyLS3OJ0GjS3hnm2PFv2JwGs8eP5dh3rwoqyx1/AYmG
         8Z+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=r36EY1z9Gx/pTJRwRL4L5tPpjk+gWGziGjqDEt316iY=;
        b=l030o+qWyRt7mDrREnLGI1F4N0R473fUn8s9JzTYCa7aVuVd1c3QQgOKeUUJjrTQU9
         /7lKh2yvy7YcQyfCa5Hh9zMPyV/++QSHA1LKB4rW0tTwaMF7fNblKZeT4L7d5VCTRP4U
         svbTPwJF2SFhxCPoniizyaRd0uER4+kUHYhLn4FNH+4j5kToN/jFQCJIimYs+XofYPQx
         Hu52ZkRFhkOqxXQ/oABx+NrO2rGnWaJ+16zgjQ8Oyo3WIjl2r4M2hd2YOmEbnwYvYON6
         6tPSiqWDv+UYCkWQcD8yhd6eegXufXsWI5duOF+705oFu0PZGtjLCi6zgFsWy9YwKCyq
         CaQg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z23si3298960eji.328.2019.02.01.01.14.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 01:14:35 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3F348AE58;
	Fri,  1 Feb 2019 09:14:35 +0000 (UTC)
Date: Fri, 1 Feb 2019 10:14:33 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	David Rientjes <rientjes@google.com>, linux-mm@kvack.org,
	Yong-Taek Lee <ytk.lee@samsung.com>,
	Paul McKenney <paulmck@linux.vnet.ibm.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v2] mm, oom: Tolerate processes sharing mm with different
 view of oom_score_adj.
Message-ID: <20190201091433.GH11599@dhcp22.suse.cz>
References: <1547636121-9229-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190116110937.GI24149@dhcp22.suse.cz>
 <88e10029-f3d9-5bb5-be46-a3547c54de28@I-love.SAKURA.ne.jp>
 <20190116121915.GJ24149@dhcp22.suse.cz>
 <6118fa8a-7344-b4b2-36ce-d77d495fba69@i-love.sakura.ne.jp>
 <20190116134131.GP24149@dhcp22.suse.cz>
 <20190117155159.GA4087@dhcp22.suse.cz>
 <edad66e0-1947-eb42-f4db-7f826d3157d7@i-love.sakura.ne.jp>
 <20190131071130.GM18811@dhcp22.suse.cz>
 <5fd73d87-3e4b-f793-1976-b937955663e3@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5fd73d87-3e4b-f793-1976-b937955663e3@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 01-02-19 05:59:55, Tetsuo Handa wrote:
> On 2019/01/31 16:11, Michal Hocko wrote:
> > On Thu 31-01-19 07:49:35, Tetsuo Handa wrote:
> >> This patch reverts both commit 44a70adec910d692 ("mm, oom_adj: make sure
> >> processes sharing mm have same view of oom_score_adj") and commit
> >> 97fd49c2355ffded ("mm, oom: kill all tasks sharing the mm") in order to
> >> close a race and reduce the latency at __set_oom_adj(), and reduces the
> >> warning at __oom_kill_process() in order to minimize the latency.
> >>
> >> Commit 36324a990cf578b5 ("oom: clear TIF_MEMDIE after oom_reaper managed
> >> to unmap the address space") introduced the worst case mentioned in
> >> 44a70adec910d692. But since the OOM killer skips mm with MMF_OOM_SKIP set,
> >> only administrators can trigger the worst case.
> >>
> >> Since 44a70adec910d692 did not take latency into account, we can "hold RCU
> >> for minutes and trigger RCU stall warnings" by calling printk() on many
> >> thousands of thread groups. Also, current code becomes a DoS attack vector
> >> which will allow "stalling for more than one month in unkillable state"
> >> simply printk()ing same messages when many thousands of thread groups
> >> tried to iterate __set_oom_adj() on each other.
> >>
> >> I also noticed that 44a70adec910d692 is racy [1], and trying to fix the
> >> race will require a global lock which is too costly for rare events. And
> >> Michal Hocko is thinking to change the oom_score_adj implementation to per
> >> mm_struct (with shadowed score stored in per task_struct in order to
> >> support vfork() => __set_oom_adj() => execve() sequence) so that we don't
> >> need the global lock.
> >>
> >> If the worst case in 44a70adec910d692 happened, it is an administrator's
> >> request. Therefore, before changing the oom_score_adj implementation,
> >> let's eliminate the DoS attack vector first.
> > 
> > This is really ridiculous. I have already nacked the previous version
> > and provided two ways around. The simplest one is to drop the printk.
> > The second one is to move oom_score_adj to the mm struct. Could you
> > explain why do you still push for this?
> 
> Dropping printk() does not close the race.

But it does remove the source of a long operation from the RCU context.
If you are not willing to post such a trivial patch I will do so.

> You must propose an alternative patch if you dislike this patch.

I will eventually get there.
-- 
Michal Hocko
SUSE Labs

