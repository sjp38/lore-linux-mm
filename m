Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB1B8C31E59
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 10:13:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8F502089E
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 10:13:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8F502089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 37A0E8E0004; Mon, 17 Jun 2019 06:13:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 32AA78E0001; Mon, 17 Jun 2019 06:13:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 219DE8E0004; Mon, 17 Jun 2019 06:13:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C76378E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 06:13:15 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id l53so15723849edc.7
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 03:13:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=dKJkAlL+oLqLuorOGCwkKbk9g+ahU1IxXGHniKoETXI=;
        b=LcG3quRAVy0ZL4f73JHcpOUxEXYrplsga+WkIU+zVvMwMA1Wsf9RrCrqRfHAv7CTMk
         kN5BIAFQptq0hF+it82vz8TN4p56DkNxCqAFhr2X4XWPYiSAB7vJHw1a8hrgbjp3PZbY
         UJnka0ZYJu3ihqOxz3bxOaCd89puw74T0eMHfluIzFnahwD7JVbITkGnIQCK72/CCv+d
         7FJQG7ZQub8V37RGJghgqVeM6Poo/P8KpSvwEL0JDzsp5LpKCkyR0ukecXPVUr/EcxSz
         r/AwuY1o7dWrG2eihHx4RoneAButEOdUQFYvOGRfmhvbAyYVIQlJQdRkyG6IPdIstXkT
         Rp8w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWK+EKBC9ZeY9x6pg18lycgAbLAzku4s4q3OMeJJG6mTtd2iCWo
	OpZxGAqhPzhj7zxWmFqN1j6xAQqS0Sp7wyTe1WHATxB2JJ6lw6nOXXCHlO1Xd/uXjhLBPfkuFwk
	JN41oxvwuU8GzYFeeNMz/1AEe5+d4Z9liQMkdsLrGJ1FTPVHMhrvToxg+XCIIwsY=
X-Received: by 2002:a17:906:61c3:: with SMTP id t3mr96584219ejl.273.1560766395359;
        Mon, 17 Jun 2019 03:13:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7yZbeNGjuCLAJ61a3VB1hIyynOK9xSM17FDT+pyYGbO6Nc6Bhp3gdgk/7ahszS6xGqv0p
X-Received: by 2002:a17:906:61c3:: with SMTP id t3mr96584173ejl.273.1560766394558;
        Mon, 17 Jun 2019 03:13:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560766394; cv=none;
        d=google.com; s=arc-20160816;
        b=yISEysELgRfjg1zz1/vL1WKLiezTs4kZz6PLV4jiKgi+gN+z/p53xAelKSbLSrRmhM
         89E4HwZyMrrlBe66mqAzzQf4WZgM3H/Dy8NydT/IpBTM5Sh9gVVfX5IdQzHkZL9P0Bkh
         3Oy6Nmvorte8p1s+VNN7gcGx6A8dQ0MBODWiOk8smqzGWIODNOQwuvffSvnKguC+1Hwh
         uEBf0YOe43Gxd8FpgO/BHe6o3tE+ybSbzuAvsawae/1hJAYdf7WKb5+ZJSozUd75lwNB
         BvxaANDxzw18mueK4Ffe8w/5FHgMDlqQzI7lqG6Un1g4T+Yp50qsFA0w7UUeDAox8jWW
         R0QQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=dKJkAlL+oLqLuorOGCwkKbk9g+ahU1IxXGHniKoETXI=;
        b=FUhOw+czCQm4PzEDhhuXXyAv2nLpw6rL+0R92JFmR3UCoxtur8LQKTV5cBSLRRKLwQ
         25i2uX7jn9oXY+DvtgVWBtO6tRObqaP/Pex8bQYeb7VV05QdPEUvDlq+shfk8w6y44EF
         B2rIiPhoJTGJb1B3qUECNCYCqSWVGOhr1BP79SfJEYEoZAadURGDuNE9qTNdqfLFzVod
         IqYKBDUFuwUkdx4wQZ6+E4wxDX+zr7ZB/DOK62zwbFvA1lToDB9YAbAY5svhKKbMU7NC
         UzduWPXkrZVrLFSZu0C6hdYJLmq4wmoyBmrpxkPcZ7nAGUsHhvsA+A4mdk90MXql6SV6
         a1dg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a41si8715892edc.273.2019.06.17.03.13.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 03:13:14 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1D9A1AC11;
	Mon, 17 Jun 2019 10:13:13 +0000 (UTC)
Date: Mon, 17 Jun 2019 12:13:10 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Shakeel Butt <shakeelb@google.com>,
	syzbot <syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>,
	yuzhoujian@didichuxing.com
Subject: Re: general protection fault in oom_unkillable_task
Message-ID: <20190617101310.GB1492@dhcp22.suse.cz>
References: <0000000000004143a5058b526503@google.com>
 <CALvZod72=KuBZkSd0ey5orJFGFpwx462XY=cZvO3NOXC0MogFw@mail.gmail.com>
 <20190615134955.GA28441@dhcp22.suse.cz>
 <CALvZod4hT39PfGt9Ohj+g77om5=G0coHK=+G1=GKcm-PowkXsw@mail.gmail.com>
 <20190617063319.GB30420@dhcp22.suse.cz>
 <268214f9-18ef-b63e-2d4f-c344a7dd5e72@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <268214f9-18ef-b63e-2d4f-c344a7dd5e72@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 17-06-19 18:56:47, Tetsuo Handa wrote:
> On 2019/06/17 15:33, Michal Hocko wrote:
> > On Sat 15-06-19 09:11:37, Shakeel Butt wrote:
> >> On Sat, Jun 15, 2019 at 6:50 AM Michal Hocko <mhocko@kernel.org> wrote:
> > [...]
> >>> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> >>> index 5a58778c91d4..43eb479a5dc7 100644
> >>> --- a/mm/oom_kill.c
> >>> +++ b/mm/oom_kill.c
> >>> @@ -161,8 +161,8 @@ static bool oom_unkillable_task(struct task_struct *p,
> >>>                 return true;
> >>>
> >>>         /* When mem_cgroup_out_of_memory() and p is not member of the group */
> >>> -       if (memcg && !task_in_mem_cgroup(p, memcg))
> >>> -               return true;
> >>> +       if (memcg)
> >>> +               return false;
> >>
> >> This will break the dump_tasks() usage of oom_unkillable_task(). We
> >> can change dump_tasks() to traverse processes like
> >> mem_cgroup_scan_tasks() for memcg OOMs.
> > 
> > Right you are. Doing a similar trick to the oom victim selection is
> > indeed better. We should really strive to not doing a global process
> > iteration when we can do a targeted scan. Care to send a patch?
> 
> I posted a patch that (as a side effect) avoids oom_unkillable_task() from dump_tasks() at
> https://lore.kernel.org/linux-mm/1558519686-16057-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp/ .
> What do you think?

I am sorry but I didn't get to look at this series yet. Anyway, changing
the dump_tasks to use a cgroup iterator for the memcg oom sounds like a
straight forward thing to do without making much more changes around.
Global task list iteration under a single RCU is a more complex problem
that is not limited to the OOM path.

-- 
Michal Hocko
SUSE Labs

