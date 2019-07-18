Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F5E3C76191
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 14:02:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDE042173E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 14:02:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDE042173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8219F6B0007; Thu, 18 Jul 2019 10:02:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D1CF6B000A; Thu, 18 Jul 2019 10:02:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E7138E0001; Thu, 18 Jul 2019 10:02:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 212DA6B0007
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 10:02:27 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f3so20001022edx.10
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 07:02:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=3z+gI4fcNcvXioM040huM6gHufSeTkaIl96vjaR/2c4=;
        b=ML99/olZKDG8+AKJtAGV8kvkNnSE2FRBvluVDRVfV+fJfnaqj+XEztG2FaOFdoQAo+
         oyPjlYdKLBPeMkXSQJtpZkAndKfX69qh9/rLGrddLZtzL32jjT+t8y8gS1wOWYprm9Eu
         O+qgJCuM+jW5mN/QvCWzdAb/vdDN1BZgDkKMLDkwxeOeU3F5g5BEpvmYxT+yBzIam0Lq
         UbI4qir6t38Lw8Fb6eh1j+jdGBVjDEh5ggd40pkAxEOUfwJEgqtKNLoqmwVXCjKJ4cH4
         iWAZ3C3Dzg86Q11GYOlwKXtYlrFyFHVHzG6tLqLP0+TJFdeBIGPTYrXMBjs3f3EoQLEg
         eC/A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAX0wfzuEp3G6XV/AwMUB+bmvNTElQk7+2m5xkIqilk09XYHBLic
	gJF8ONNuIvfMV8zsTnESUdPtKgJbo3uqd97CHCMg8RayH0ihNeWl2WsVyH8KPWBQJ8UAjvhfE9o
	2wyvmALFsZqKHko1RPwTKWua5qFFfU/z4doHjSy+rYjR40rnmzGR1/n4mq5AXYSYJ/w==
X-Received: by 2002:a50:a3f5:: with SMTP id t50mr40618031edb.273.1563458546722;
        Thu, 18 Jul 2019 07:02:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwNnIBhxdCFvbypz7xjTomCOJep5ckEP3NCWzDSFhHtCpxtvU5RGnpSf9OEJWNvNh8QPAl
X-Received: by 2002:a50:a3f5:: with SMTP id t50mr40617951edb.273.1563458546044;
        Thu, 18 Jul 2019 07:02:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563458546; cv=none;
        d=google.com; s=arc-20160816;
        b=oQPVCUcAkV1EwoLHuBPSaqQoheWAEUamFrqX/E4Wn9SHGA2tjmVcNmTV8+f7leK3lB
         CD88DkQhV4FsgZCvSdHxRC29wyUWU0QCcyvX8cs0O/TdDl/By9UypsidmNVqEs408Vqi
         GlUlMykpFTS61BOmIUDKhg20cpkEpnEQQfEdxDO97FOMLm/FMWEGEhIAYpurYVLhj59u
         hLw7PT5dF+jhUc+B9qZdb0Rg8iPXnVnK5YYh6T7ZZgUKLJNKXIGlSvbPD7WETxlQhY/1
         /XPHKSPbDAxW5aFUOFfvmlyZ7b3pzJL1mtZrSkWrimrCZL9hfND4bzhWwk8kQN0XkHOV
         Ov3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=3z+gI4fcNcvXioM040huM6gHufSeTkaIl96vjaR/2c4=;
        b=HyzqS5aD8pf1k0GFds4sPissgCkQnWH9WjIBbgrOt+wr87m84GzH0DVrN8Pw+oTIXk
         TnAavUk1AH8KsPjMDX4FnI62Hyxjpdx8wltZdMMbwgKU8iJMtC/D22MLE76dt3n9tN2q
         f9zaFrslQQ1N1ybPJ8v1GvqTcwKjVGNSjht/eVkeWLS9hVKcrefOnXc3wHM37For5gdz
         4zOuFWjo9JXlgoABoTzGSlX+kmvF4zDXadE+NHqzrYGli1pouoJr1OYzTNqG3rEau2gL
         BtUBitZdShSmQ+F/ODAlc39QAYZt3zh5IsLxQOzpaXZXIjkaF63xjXAXfJ44jhN/k+Ib
         1npQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o15si346639ejj.248.2019.07.18.07.02.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 07:02:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8EA56AF77;
	Thu, 18 Jul 2019 14:02:25 +0000 (UTC)
Date: Thu, 18 Jul 2019 16:02:24 +0200
From: Michal Hocko <mhocko@suse.com>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Roman Gushchin <guro@fb.com>, Shakeel Butt <shakeelb@google.com>,
	linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] mm, oom: avoid printk() iteration under RCU
Message-ID: <20190718140224.GC30461@dhcp22.suse.cz>
References: <1563360901-8277-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190718083014.GB30461@dhcp22.suse.cz>
 <7478e014-e5ce-504c-34b6-f2f9da952600@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7478e014-e5ce-504c-34b6-f2f9da952600@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 18-07-19 22:50:14, Tetsuo Handa wrote:
> On 2019/07/18 17:30, Michal Hocko wrote:
> > On Wed 17-07-19 19:55:01, Tetsuo Handa wrote:
> >> Currently dump_tasks() might call printk() for many thousands times under
> >> RCU, which might take many minutes for slow consoles.
> > 
> > Is is even wise to enable dumping tasks on systems with thousands of
> > tasks and slow consoles? I mean you still have to call printk that is
> > slow that many times. So why do we actually care? Because of RCU stall
> > warnings?
> > 
> 
> That's a stupid question. WE DO CARE.

-ENOARGUMENT

> We are making efforts for avoid calling printk() on each thread group (e.g.
> 
>   commit 0c1b2d783cf34324 ("mm/oom_kill: remove the wrong fatal_signal_pending() check in oom_kill_process()")

removes fatal_signal_pending rather than focusing on printk

>   commit b2b469939e934587 ("proc, oom: do not report alien mms when setting oom_score_adj"))

removes a printk of a dubious value.

> ) under RCU and this patch is one of them (except that we can't remove
> printk() for dump_tasks() case).

No, this one adds a complexity for something that is not clearly a huge
win or the win is not explained properly.

-- 
Michal Hocko
SUSE Labs

