Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DD3DC31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 06:33:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23A3B21873
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 06:33:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23A3B21873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B72058E0003; Mon, 17 Jun 2019 02:33:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B222C8E0001; Mon, 17 Jun 2019 02:33:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E9A98E0003; Mon, 17 Jun 2019 02:33:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4C9358E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 02:33:22 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b3so14907611edd.22
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 23:33:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=K3tIasHIXQYAMbR9cx7yI5JHsfZVXW41V1yq/a7KQeY=;
        b=JJ6mTkGAhBjQLljaqVXQ+Z0RKaLFLlgfyH1mkhwAIZ0VbYDUYWvKnWmGZDdFPb7327
         cnHOYG5/KidMIvmaPM5MbgiTHIVq5hxu44RW0e6mhSXvTpXgCv8HrpLvUlliEQOLAbsi
         YcH77m79ezFvjfBdGI9NpRpA3RA7+YanSx9d2Y+IwVcs/cRj7Cys2LGVklh/6o7NZA14
         Ixt20MXwLRvUrgL5+37LtKH2AS1PEMq/lhGEsSZ8JZLaTcuaZydbLuqZ4QxpM+7WVnpe
         RkXiKgLP3VBA1c8bF/cMvPvNzMsC9pdudntahiY9HXuPNdahaSyuu3nUdLRl/ucVSe8z
         M49g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUL3vmqUpbTamjztMBqmKQI2X67GwLJLDU3VGTD9QpUh6Otmz5h
	yOXtbbrFFZKYieYrGsjQqq6wTQiYy0euj/Qnc0W1OS6d763W5yGM+4Rq9t38uDfw3Khfyz7/A9P
	2CXX/PWrKBJiZOOFO5ngc0AOZuXAr9ajCW6YAZj57VwYY2OH70uGjCG/yUlif3EM=
X-Received: by 2002:a17:906:2cce:: with SMTP id r14mr19284350ejr.107.1560753201890;
        Sun, 16 Jun 2019 23:33:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzezQ7+A3CW1xS4uO/+XIsj/MO6IP0O5Tety+XKlv2mv8WfMn581ivYtQ5V5fTnjJ5liM3f
X-Received: by 2002:a17:906:2cce:: with SMTP id r14mr19284307ejr.107.1560753201161;
        Sun, 16 Jun 2019 23:33:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560753201; cv=none;
        d=google.com; s=arc-20160816;
        b=JeL1VhGDUvChURInYtzGdXX/fg8ViHFoNY2CYat+LIEWa3Ls5fjMgEi1rS4+h39Yi0
         vQrLLe5SeeJ+GM89TYEltsaL8F6u/MbADvg7FE7Alm8UsoCzg4hWKtmLHWj+h+IHTXZb
         I5HC//LU0iMXF7W3OnkSkrTRQLo6uUeHnJ9sP/Y77EP51PXCtRHBFrI2rqmN4G2EjGqV
         Dg0hGlvYL6Km3pssJZJRMYXYBWM9v1Z2statMG3JjMNB6EcDDSYD9bTzpLKwFuAZvEQV
         SaBqcXsXy82FDY1F55UDZ/3idGjv7WaNWdMilUlAcYs7oNTIYkWxXKIM0+M8ZEOPLo5h
         N2YQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=K3tIasHIXQYAMbR9cx7yI5JHsfZVXW41V1yq/a7KQeY=;
        b=bNnjYRvj+dsqOq/3JhRWHxN3RrMMFN0KcOwxj+jj2dxy8kCe9KnZoETcUx2mM0H/Kc
         acDiXPH+t2HYCmTAqcbWJYKtk3KNIcvjx0es17qaDU8Lry54ZaVsW09Pwcdjw90KtO4k
         xTWgnLVtJc6W5wMhcVXSR+/S2FyYWhPNapZ/vsVvtVaNBQKVK1EZnZ1XRRx//2UgXr4W
         TXosKbGL2KinK94VYM8BtonOUc7TplXIa8pkiQEhFQhdlI6B1go7vIrwxiykBVkXNoap
         SVmDdnM6CWPyNG1RMrXT9GBOx0G/nwumIRSMrMPtQiMG9QeDqXK5Hi+oEr3FRFX+Kp5o
         xLVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z6si7450183edp.370.2019.06.16.23.33.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jun 2019 23:33:21 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id AF6EDAFC9;
	Mon, 17 Jun 2019 06:33:20 +0000 (UTC)
Date: Mon, 17 Jun 2019 08:33:19 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: syzbot <syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>,
	yuzhoujian@didichuxing.com
Subject: Re: general protection fault in oom_unkillable_task
Message-ID: <20190617063319.GB30420@dhcp22.suse.cz>
References: <0000000000004143a5058b526503@google.com>
 <CALvZod72=KuBZkSd0ey5orJFGFpwx462XY=cZvO3NOXC0MogFw@mail.gmail.com>
 <20190615134955.GA28441@dhcp22.suse.cz>
 <CALvZod4hT39PfGt9Ohj+g77om5=G0coHK=+G1=GKcm-PowkXsw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod4hT39PfGt9Ohj+g77om5=G0coHK=+G1=GKcm-PowkXsw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat 15-06-19 09:11:37, Shakeel Butt wrote:
> On Sat, Jun 15, 2019 at 6:50 AM Michal Hocko <mhocko@kernel.org> wrote:
[...]
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 5a58778c91d4..43eb479a5dc7 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -161,8 +161,8 @@ static bool oom_unkillable_task(struct task_struct *p,
> >                 return true;
> >
> >         /* When mem_cgroup_out_of_memory() and p is not member of the group */
> > -       if (memcg && !task_in_mem_cgroup(p, memcg))
> > -               return true;
> > +       if (memcg)
> > +               return false;
> 
> This will break the dump_tasks() usage of oom_unkillable_task(). We
> can change dump_tasks() to traverse processes like
> mem_cgroup_scan_tasks() for memcg OOMs.

Right you are. Doing a similar trick to the oom victim selection is
indeed better. We should really strive to not doing a global process
iteration when we can do a targeted scan. Care to send a patch?

Thanks!
-- 
Michal Hocko
SUSE Labs

