Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB6C5C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 12:18:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 759E62192B
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 12:18:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 759E62192B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB1C88E0002; Fri, 15 Feb 2019 07:18:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B37898E0001; Fri, 15 Feb 2019 07:18:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D8038E0002; Fri, 15 Feb 2019 07:18:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3FA318E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 07:18:51 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id d9so3874678edl.16
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 04:18:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=A8NkFGx7t4xh0Z8FXKwUgOlVYbr1DNYsH6w5upFUvN8=;
        b=nFU6O5MP57tk40UaFqUSqpTxZrMzLQpyXrMagNUYoQFxpOuKfIh0bBTd1mvE97zSsx
         oAhHXp7QmEZGWZXOAYDqYmzdJPaw4oxN8bOUN2P92PRDHq5TQ+/kDblqaS/AMIT8qPM/
         pa1aRyH/ec9jYwarQd/lisTgJDle1SNiBMZGhHyi5iJyAao/xwlNdrMRo3X/gwdaOlsE
         DceNWaWflqNawOXThJiJnlYeM2mz7dzMqGegDzwu9mB/Lm1nIeWDJ+Nm7vXcIGI/OXfr
         DRSHhTwvVxgBLHfBaPCzrNS55P2bUgBfwQF02ky3S9sIHmViyLbXiXP9RakbvLprKE4q
         p2uA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuYPAibuzc7JlMh/nLBfc3XtAgpVW79eHDO4sTnQe3p7PQ0aUl/A
	de+PXGuvbkYGZe8ObOtNdAY6WzrPTujB9xj6H3pH31OQlivvMMgub0kjMZcL/mt7ZIEBzBTthxH
	oXrkLotwIK5qac6POwARe8TuswBh+YX7biYQ8ItgLeT8JG1HqjyRS6g70Y2oD7IM=
X-Received: by 2002:a17:906:81d7:: with SMTP id e23mr6409133ejx.207.1550233130772;
        Fri, 15 Feb 2019 04:18:50 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZL8q7C8uyk2Ac6JsXpfZ7hoeWaCjr+hy7lpctFiHg2TLxFqXZP/CLgUDq/qJQRDo08shjt
X-Received: by 2002:a17:906:81d7:: with SMTP id e23mr6409072ejx.207.1550233129631;
        Fri, 15 Feb 2019 04:18:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550233129; cv=none;
        d=google.com; s=arc-20160816;
        b=c5kVLeDYbgcIoOV6wdQJN7lwQJHvQwtLFa5MbXqC6dpKWjT6IxKL5MLJRoV+S6wXxu
         rzAYpARYG4cL2zMa8Fyo0nuoDMaAfe3Ss6AglwfmLJgB+rhoWEKF8xwQVBpH7iz7BKqG
         OMuQ+cmdD7bgSSEzc9pNw8H+L6iNbSXV5nL4ysMeXgg/PLpVgQS6rwWatC0aJQ8wuZ0K
         HJ4tx7iV3JiG46Zf/MjLIxHUSSYRzFmF8HRBwnenRF6iEY1YZrTgebi1bSMnFoPz2aSM
         tzSeJOuuxcJgKB12pNB3H5VHXDHRaZgUvFC6WZXKLQL7KrXlKk2r6ttznuIdLaZe9ORg
         1CLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=A8NkFGx7t4xh0Z8FXKwUgOlVYbr1DNYsH6w5upFUvN8=;
        b=fum+pqg1mI4LDF6f2x0xW2kzJyykyG6oUzr6x93ll60/WHRe1I+BjgZ74gccr/v//B
         d4uT1dXnLZA6M+ajVbAJCAuVPlLWFSEGWy2GM0d4XAFpq2KYBSMm5kJ9Wov4MKqeGm0N
         fKtw5ZrU/rrxMWNu8dS8oZVBjPeDuDXzyG5vOz360PxLpMuPVGp/RPMGB2acmIFZqpqa
         7XnBrOnlIFyHx/6YByym71u9aM/2JAiRKT6Rd+d2l9/Ha6sGHlp0/tu/7/0iWYkgJFmy
         U+aNglcdIXkXUj17fkOYLMm32/RNCWEXFIK+1yurk29Yl7Mcr6wT8FNb4JNZDdRwNScO
         TZjA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a9si2219022ejj.269.2019.02.15.04.18.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 04:18:49 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 237F5AF0F;
	Fri, 15 Feb 2019 12:18:49 +0000 (UTC)
Date: Fri, 15 Feb 2019 13:18:48 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm <linux-mm@kvack.org>
Subject: Re: [PATCH v3] mm,page_alloc: wait for oom_lock before retrying.
Message-ID: <20190215121848.GY4525@dhcp22.suse.cz>
References: <20900d89-b06d-2ec6-0ae0-beffc5874f26@I-love.SAKURA.ne.jp>
 <20190213165640.GV4525@dhcp22.suse.cz>
 <87896c67-ddc9-56d9-8643-09865c6cbfe2@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87896c67-ddc9-56d9-8643-09865c6cbfe2@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 15-02-19 19:42:41, Tetsuo Handa wrote:
> On 2019/02/14 1:56, Michal Hocko wrote:
> > On Thu 14-02-19 01:30:28, Tetsuo Handa wrote:
> > [...]
> >> >From 63c5c8ee7910fa9ef1c4067f1cb35a779e9d582c Mon Sep 17 00:00:00 2001
> >> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> >> Date: Tue, 12 Feb 2019 20:12:35 +0900
> >> Subject: [PATCH v3] mm,page_alloc: wait for oom_lock before retrying.
> >>
> >> When many hundreds of threads concurrently triggered a page fault, and
> >> one of them invoked the global OOM killer, the owner of oom_lock is
> >> preempted for minutes because they are rather depriving the owner of
> >> oom_lock of CPU time rather than waiting for the owner of oom_lock to
> >> make progress. We don't want to disable preemption while holding oom_lock
> >> but we want the owner of oom_lock to complete as soon as possible.
> >>
> >> Thus, this patch kills the dangerous assumption that sleeping for one
> >> jiffy is sufficient for allowing the owner of oom_lock to make progress.
> > 
> > What does this prevent any _other_ kernel path or even high priority
> > userspace to preempt the oom killer path? This was the essential
> > question the last time around and I do not see it covered here. I
> 
> Since you already NACKed disabling preemption at
> https://marc.info/?i=20180322114002.GC23100@dhcp22.suse.cz , pointing out
> "even high priority userspace to preempt the oom killer path" is invalid.

Why?

> Since printk() is very slow, dump_header() can become slow, especially when
> dump_tasks() is called. And changing dump_tasks() to use rcu_lock_break()
> does not solve this problem, for this is a problem that once current thread
> released CPU, current thread might be kept preempted for minutes.

dump_tasks might be disabled for those who are concerned about the
overhead but I do not see what your actual point here is.

> Allowing OOM path to be preempted is what you prefer, isn't it?

No, it is just practicality. If you disable preemption you are
immediatelly going to fight with soft lockups.

> Then,
> spending CPU time for something (what you call "any _other_ kernel path") is
> accountable for delaying OOM path. But wasting CPU time when allocating
> threads can do nothing but wait for the owner of oom_lock to complete OOM
> path is not accountable for delaying OOM path.
> 
> Thus, there is nothing to cover for your "I do not see it covered here"
> response, except how to avoid "wasting CPU time when allocating threads
> can do nothing but wait for the owner of oom_lock to complete OOM path".
> 
> > strongly suspect that all these games with the locking is just a
> > pointless tunning for an insane workload without fixing the underlying
> > issue.
> 
> We could even change oom_lock to a local lock inside oom_kill_process(), for
> all threads in a same allocating context will select the same OOM victim
> (unless oom_kill_allocating_task case), and many threads already inside
> oom_kill_process() will prevent themselves from selecting next OOM victim.
> Although this approach wastes some CPU resources for needlessly selecting
> same OOM victim for many times, this approach also can solve this problem.
> 
> It seems that you don't want to admit that "wasting CPU time when allocating
> threads can do nothing but wait for the owner of oom_lock to complete OOM path"
> as the underlying issue. But we can't fix it without throttling direct reclaim
> paths. That's the evidence that this problem is not fixed for many years.

And yet I do not rememeber any _single_ bug report for a real life
workload that would be suffering from this. I am all for a better
throttling on the OOM conditions but what you have been proposing are
hacks at best without any real world workload backing them.

Please try to understand that the OOM path in the current form is quite
complex already and adding more on top without addressing a problem
which real workloads do care about is not really all that attractive.
I have no objections to simple and obviously correct changes in this
area but playing with locking with hard to evaluate side effects is not
something I will ack.
-- 
Michal Hocko
SUSE Labs

