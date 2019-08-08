Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05CE7C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 22:15:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9878A2173C
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 22:15:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=arista.com header.i=@arista.com header.b="Dk+6FJdE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9878A2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 44C636B0007; Thu,  8 Aug 2019 18:15:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3FEBF6B0008; Thu,  8 Aug 2019 18:15:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2EBD16B000A; Thu,  8 Aug 2019 18:15:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0206F6B0007
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 18:15:26 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id q16so64776076otn.11
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 15:15:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=NDuScBkGjT5nSsmn6LtJOvcXlMJwigFAIaUOlNo8VtQ=;
        b=j0moj/2lCqnr9L6k9uSQhz+RSa4FMY5DbOzfdSKgb6VbaCz2gGhJ0qxOoqFu0zuHD+
         3M71CfEnIki65PGJi6FmeUOxvVkBUZx3oUrVkj0eAl4vRaQfEy39/WPqWyEschQgIddf
         m13vvJpokA6fZZEcbmTX0oLiKo5R0bMf3kBqO72+LPbC2yIfYnm2U52E06ZkhnhKkRkO
         yorv2KjNHhJ6PvFE7A2wsc5f807pT+52mn3P1eQdmaZy/rKfNjfqzlJcuRidViNKF8I4
         rmqlkazI66v2TEFLeFXynHfJa7m6GjWA8CljdFBtpL6OdbuLk8zE0MNcxNBi8Eb4396P
         Kb2w==
X-Gm-Message-State: APjAAAXOp60wlXa7T3c02gdvqpMx4i+pJnkJq86S4Ov/hPV6UTwedH+C
	XgM2alEknlN7wpE3+5VS7wsevrdO6r5evaAtMRD2QEuBie/yflkl8gcucCtV2tgQS9fowz6eW++
	raPUIrHPlGEuAU2ZbY3t27F3XivydjQxKoWu3+B+dKeQVlh7HxoD0MSMCxACRkQ5VFGuW1tSvu0
	63lVhNGCjovV40PIauGV/AKnbyFjLL+gcprpj4IdTVkopXzkn2XbbUUA8YzI2E6iFTkkIICmkUS
	DkKcZqqim3SML5FygBCTEIJU7yG8fsCPOKhe/vK06f537cOmMM=
X-Received: by 2002:a02:a1c7:: with SMTP id o7mr19631456jah.26.1565302525593;
        Thu, 08 Aug 2019 15:15:25 -0700 (PDT)
X-Received: by 2002:a02:a1c7:: with SMTP id o7mr19631368jah.26.1565302524678;
        Thu, 08 Aug 2019 15:15:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565302524; cv=none;
        d=google.com; s=arc-20160816;
        b=LQcWp/BeDAzMOiNZcA1d91CYjvG5BrB+fCSmiGPj9aqJv6mkQieDzilVjWNpr3QAjO
         ygrHYsVwU4BehDd6CpgRsXXgdPb+DwQfEipYr8LXUUtfQQfJSy5ilMf/Hl3Br3Q69jpF
         LV2Z1tcu03h0ij/eqdNryZMqAXlqyBXoIMC3Yp7AVYYeRy7ZQI6dK9BDEzWH2XrAvStK
         wlGhm/JLvfEoLVg4wce+NCtc4uu7srilTD6Otpm2DTery2I90wDk7jgKgA9MwivCVmPg
         s6cqCgag10UeY6Z09fSyKfazLcTQv/JS+wrrdrZKaIqcQoakU46vTDUL9Ns+m2Whvlv7
         gfcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=NDuScBkGjT5nSsmn6LtJOvcXlMJwigFAIaUOlNo8VtQ=;
        b=CLs5sz6S1Vxg5H6BQXgJgTMEPSnHnslvoE2MkOOk5ESyO4etq/+gsm9VxnELLRYuMU
         His/fntswkvtBSqFMLMwpvjbxE8e+vKdE5boX5Dduv40rffLOW8OX6hu2hco0xKBCOvz
         y0CyRCYHF2oITWdfr8dUFzP26p1WQeMMThyzsuJAo4loOJPDpN75koidN6fEvHLqEtfM
         5Kv+pU01/XA+etgwbbJrJ8w216yai0Mn/H3Jr76dGJJzzZbG0+js2XnpVs44Kr0qlg1s
         fwgyP8bmNrqaKUDr5d42F3wsDVo76ZTTyFljxsXWwz58feKL5kAw9+Oa7m5uWi2HrC7B
         N6NA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@arista.com header.s=googlenew header.b=Dk+6FJdE;
       spf=pass (google.com: domain of echron@arista.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=echron@arista.com;
       dmarc=pass (p=QUARANTINE sp=REJECT dis=NONE) header.from=arista.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r17sor9279598jam.9.2019.08.08.15.15.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Aug 2019 15:15:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of echron@arista.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@arista.com header.s=googlenew header.b=Dk+6FJdE;
       spf=pass (google.com: domain of echron@arista.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=echron@arista.com;
       dmarc=pass (p=QUARANTINE sp=REJECT dis=NONE) header.from=arista.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=arista.com; s=googlenew;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=NDuScBkGjT5nSsmn6LtJOvcXlMJwigFAIaUOlNo8VtQ=;
        b=Dk+6FJdEexeYjR3aFFo2RcNwKRIMuHClL7PiIVO3hopF/LjfhAMdDKKMdvQDGJgK2R
         Bfzl1ByNxGJ8ndlqV4/G1LPqRmNqcjqKqSPlmSCMXJXct0FhBDdgr/t/dHWbJasr4K8/
         1JQJJdpNsB2TP4+uaOC/TwiGyhAktGZaoTC3KzJQ+zGTTgVGoUzSFtCHCooxCeCwy0A/
         cCzuIt21lKPbv/vtBBHrO47ZB+Y0Lu8+Yl9PwjHBKwRFvVLaz4xF3nvYSghdDt6pi5gQ
         ZkDsQdRSMtv8UFoJ0T6REQL/1OJlGVcVDysofrUaTIsVsfCaM0tRtTwCI/w7XT/NaOCs
         sv1g==
X-Google-Smtp-Source: APXvYqxKzTeapIMM3uSrv1CUfmpNqVZPgXYnvHumDVA5DAS8WyMLEqYmtuLYmHYO4EzNz0LU9DhhOCN1zRePlcIPr5Y=
X-Received: by 2002:a02:c519:: with SMTP id s25mr18744820jam.11.1565302524248;
 Thu, 08 Aug 2019 15:15:24 -0700 (PDT)
MIME-Version: 1.0
References: <20190808183247.28206-1-echron@arista.com> <20190808185119.GF18351@dhcp22.suse.cz>
 <CAM3twVT0_f++p1jkvGuyMYtaYtzgEiaUtb8aYNCmNScirE4=og@mail.gmail.com> <20190808200715.GI18351@dhcp22.suse.cz>
In-Reply-To: <20190808200715.GI18351@dhcp22.suse.cz>
From: Edward Chron <echron@arista.com>
Date: Thu, 8 Aug 2019 15:15:12 -0700
Message-ID: <CAM3twVS7tqcHmHqjzJqO5DEsxzLfBaYF0FjVP+Jjb1ZS4rA9qA@mail.gmail.com>
Subject: Re: [PATCH] mm/oom: Add killed process selection information
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Shakeel Butt <shakeelb@google.com>, 
	linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Ivan Delalande <colona@arista.com>
Content-Type: text/plain; charset="UTF-8"
X-CLOUD-SEC-AV-Info: arista,google_mail,monitor
X-CLOUD-SEC-AV-Sent: true
X-Gm-Spam: 0
X-Gm-Phishy: 0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000014, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In our experience far more (99.9%+) OOM events are not kernel issues,
they're user task memory issues.
Properly maintained Linux kernel only rarely have issues.
So useful information about the killed task, displayed in a manner
that can be quickly digested, is very helpful.
But it turns out the totalpages parameter is also critical to make
sense of what is shown.

So if we report the fooWidget task was using ~15% of memory (I know
this is just an approximation but it is often an adequate metric) we
often can tell just from that the number is larger than expected so we
can start there.
Even though the % is a ballpark number, if you are familiar with the
tasks on your system and approximately how much memory you expect them
to use you can often tell if memory usage is excessive.
This is not always the case but it is a fair amount of the time.
So the % of memory field is helpful. But we've found we need totalpages as well.
The totalpages effects the % of memory the task uses.

You're an OOM expert so I don't need to tell you, but just for
clarity, that if a system we're expecting to have swap space has it's
swap diminshed or removed, that can have a significant effect both on
the available memory and the % of memory/swap the task consumes.
Just as if you run a task of a fixed memory size on a system with half
the memory it's % of memory jumps up as does it's oom_score.
Often we know the Memory Size and how much swap space a system is
expected to have, printing totalpages allows us to confirm that this
was in fact the case at the time of the oom event.
Also the size of totalpages is very important to being to tell
approximately how much memory/swap, the task was using because we have
the % and we can quickly get an idea of usage.
For systems that come in a variety of sizes that is important, the
percentage number in conjunction with totalpages is essential since
they are dependent on each other.

With memcg usage increasing, having totalpages readily available is
even more important because the memory container caps the value and it
is helpful to know the value that was in use at the time of the oom
event.

The oom_score tells us how Linux calculated the score for the task,
the oom_score_adj effects this so it is helpful to have that in
conjunction with the oom_score.
If the adjust is high it can tell us that the task was acting as a
canary and so it's oom_score is high even though it's memory
utilization can be modest or low.
In that case we may need more information about what was going on
because the task selected was not necessarily using much memory.
But at least we know why it was selected. The kill message with a high
oom_score_adjust and high oom_score makes that obvious.

Just by adding a few values to the kill message we're often able to
quickly get an idea of what the cause of an oom event was, or at least
we have a better idea where to start looking.

Since we're running a business and so are our customers anything we
can do speed up the triage process saves money and makes people more
productive, so we find it valuable.

What other justification is needed? Let me know.

Thanks!

P.S.

By the way, just for feedback, the recent reorganization of the OOM
sections and print output, for those of us that do have to wade
through OOM output, was appreciated:

commit ef8444ea01d7442652f8e1b8a8b94278cb57eafd    (v5.0-rc1-107^2~63)
Author: yuzhoujian <yuzhoujian@didichuxing.com>
Date:   Fri Dec 28 00:36:07 2018 -0800

    mm, oom: reorganize the oom report in dump_header



On Thu, Aug 8, 2019 at 1:07 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> [please do not top-post]
>
> On Thu 08-08-19 12:21:30, Edward Chron wrote:
> > It is helpful to the admin that looks at the kill message and records this
> > information. OOMs can come in bunches.
> > Knowing how much resource the oom selected process was using at the time of
> > the OOM event is very useful, these fields document key process and system
> > memory/swap values and can be quite helpful.
>
> I do agree and we already print that information. rss with a break down
> to anonymous, file backed and shmem, is usually a large part of the oom
> victims foot print. It is not a complete information because there might
> be a lot of memory hidden by other resource (open files etc.). We do not
> print that information because it is not considered in the oom
> selection. It is also not guaranteed to be freed upon the task exit.
>
> > Also can't you disable printing the oom eligible task list? For systems
> > with very large numbers of oom eligible processes that would seem to be
> > very desirable.
>
> Yes that is indeed the case. But how does the oom_score and
> oom_score_adj alone without comparing it to other eligible tasks help in
> isolation?
>
> [...]
>
> > I'm not sure that change would be supported upstream but again in our
> > experience we've found it helpful, since you asked.
>
> Could you be more specific about how that information is useful except
> for recording it? I am all for giving an useful information in the OOM
> report but I would like to hear a sound justification for each
> additional piece of information.
>
> E.g. this helped us to understand why the task has been selected - this
> is usually dump_tasks portion of the report because it gives a picture
> of what the OOM killer sees when choosing who to kill.
>
> Then we have the summary to give us an estimation on how much
> memory will get freed when the victim dies - rss is a very rough
> estimation. But is a portion of the overal memory or oom_score{_adj}
> important to print as well? Those are relative values. Say you get
> memory-usage:10%, oom_score:42 and oom_score_adj:0. What are you going
> to tell from that information?
> --
> Michal Hocko
> SUSE Labs

