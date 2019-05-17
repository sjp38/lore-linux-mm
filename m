Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BAB3C04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 12:33:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA8F5205ED
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 12:33:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA8F5205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 955836B0010; Fri, 17 May 2019 08:33:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 906396B0266; Fri, 17 May 2019 08:33:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 81BF86B0269; Fri, 17 May 2019 08:33:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 345316B0010
	for <linux-mm@kvack.org>; Fri, 17 May 2019 08:33:13 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id n23so10475747edv.9
        for <linux-mm@kvack.org>; Fri, 17 May 2019 05:33:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=QXGwpNuByKXzu7nV8wRVAREVSAlMeT2XL2bkzb4siZc=;
        b=uK5rTUAF6bX35sSHdmMJXMhz0E/RN57dm+REBZMeJJIGDuvsGq4Z//WfN5wAeNHlhV
         JBUX9PsQu1/IVq032mKCEoCE0LVZkfaoJKtETanu+rehCTEutzZxqT4u/o+viG/rcwqc
         drJ4lD55dmA9W9pg84cmLCl4b/hFxpA8yd8bQtO+RLw/iFS6R7fu4/zNe5ND7J0pdXac
         2MYSxyJ1UNrh+XnUEbceP5e03n9KlKLlyKynMsFM/7hPgG9b/kDR9O5k6+T3pIK8czOJ
         5Jcdr8/ELFJLCpvfJOCblOZX0//wgJYlVwLTibqVai3U6ZQcQYRGYMN0TkMY1Enaop5i
         f8XQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWrDF7Sg7CU8KE9pejkAm1SnheUQ9DLFp6k4W8Z6Dk/b+PKZF4I
	p8wMDZV28MnkAgx9hLSfAQZpPYuKVIDM0xjCc7sExOUKS5By39u/5T1d41tuyGTftoqwfVBJTCh
	FnTndXwlCusTlpXKeyXOXMoFwo3XTMirxlLjIkho8sJbMJm6sWHvmK6PhQWd0sEA=
X-Received: by 2002:a50:a5b5:: with SMTP id a50mr56984545edc.109.1558096392770;
        Fri, 17 May 2019 05:33:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxcJ4V3xevb4hhW+aXCb/WeFh/kDBO136btyPNSgajW330oqZODnSonwSDc0gpb+p0eLrpB
X-Received: by 2002:a50:a5b5:: with SMTP id a50mr56984461edc.109.1558096391946;
        Fri, 17 May 2019 05:33:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558096391; cv=none;
        d=google.com; s=arc-20160816;
        b=jFAyr18Abt6WT5I5+0S1xmUWocIMPi6f83NBHylg1PgIoAyLVfIqtuguHADSH2ID4Y
         maPNvczWR7uPIEQ5jfxkpe3fzZ5OPHcUqyC0dMyVkRXbywO3uO4OlcVrX+BQaajlaZDp
         ToSkt3kT337FjtetiMxknu0s02YxiJprZE8Z5af9wM5P1ToAT4ip4AmsMPgCSkZdrOFa
         yEYpwx0dG+LIatJ/0m6JMUiCn2oGv9HYqurb5I8DzzQv6CrlO+9DOIELTo4JwKRgsrvy
         ve7D4fQayVS2ukSNVOuW7paFzj7ppVZ8K4iEndU98M4JeuKstAZLAyoESsqnSPOy0y0f
         afhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=QXGwpNuByKXzu7nV8wRVAREVSAlMeT2XL2bkzb4siZc=;
        b=pndfncJ0H4JKy8yfwvMAc1UEAeEZKXsp+TDh8v8rL02MIyWCcEzv5c27yGF6+WUrG4
         Y9EnrdgII/bcBqhslruP10G6l1o6A6++oEmn14x9W/PquUOd0xJPY3qZZZQFs6sWnSB0
         IIPrJvBUImuSUFv/ILCAf99xfkbWHDug/D62gBkX3bbRYaaNc3pAL+77S9QsJpanIhGt
         nzHQxY8Q+CBUQQr9WlQ6MFgWOKsZxJPG5QCygfUIQ/W8mDfUqUlycxsG0jOZx2ZcRgIX
         0Sj25KTE+CBo/SNxBD5iQwX6wsyON0TVSTLsQyu714pcs41j4MiYA/GM8cPuWjCYFZDv
         2rXg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x12si3999776eju.390.2019.05.17.05.33.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 05:33:11 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1D0C2AF7C;
	Fri, 17 May 2019 12:33:11 +0000 (UTC)
Date: Fri, 17 May 2019 14:33:10 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, tj@kernel.org,
	guro@fb.com, dennis@kernel.org, chris@chrisdown.name,
	cgroups mailinglist <cgroups@vger.kernel.org>, linux-mm@kvack.org
Subject: Re: + mm-consider-subtrees-in-memoryevents.patch added to -mm tree
Message-ID: <20190517123310.GI6836@dhcp22.suse.cz>
References: <20190212224542.ZW63a%akpm@linux-foundation.org>
 <20190213124729.GI4525@dhcp22.suse.cz>
 <20190516175655.GA25818@cmpxchg.org>
 <20190516180932.GA13208@dhcp22.suse.cz>
 <20190516193943.GA26439@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190516193943.GA26439@cmpxchg.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 16-05-19 15:39:43, Johannes Weiner wrote:
> On Thu, May 16, 2019 at 08:10:42PM +0200, Michal Hocko wrote:
> > On Thu 16-05-19 13:56:55, Johannes Weiner wrote:
> > > On Wed, Feb 13, 2019 at 01:47:29PM +0100, Michal Hocko wrote:
[...]
> > > > FTR: As I've already said here [1] I can live with this change as long
> > > > as there is a larger consensus among cgroup v2 users. So let's give this
> > > > some more time before merging to see whether there is such a consensus.
> > > > 
> > > > [1] http://lkml.kernel.org/r/20190201102515.GK11599@dhcp22.suse.cz
> > > 
> > > It's been three months without any objections.
> > 
> > It's been three months without any _feedback_ from anybody. It might
> > very well be true that people just do not read these emails or do not
> > care one way or another.
> 
> This is exactly the type of stuff that Mel was talking about at LSFMM
> not even two weeks ago. How one objection, however absurd, can cause
> "controversy" and block an effort to address a mistake we have made in
> the past that is now actively causing problems for real users.
> 
> And now after stalling this fix for three months to wait for unlikely
> objections, you're moving the goal post. This is frustrating.

I see your frustration but I find the above wording really unfair. Let me
remind you that this is a considerable user visible change in the
semantic and that always has to be evaluated carefuly. A change that would
clearly regress anybody who rely on the current semantic. This is not an
internal implementation detail kinda thing.

I have suggested an option for the new behavior to be opt-in which
would be a regression safe option. You keep insisting that we absolutely
have to have hierarchical reporting by default for consistency reasons.
I do understand that argument but when I weigh consistency vs. potential
regression risk I rather go a conservative way. This is a traditional
way how we deal with semantic changes like this. There are always
exceptions possible and that is why I wanted to hear from other users of
cgroup v2, even from those who are not directly affected now.

If you feel so stronly about this topic and the suggested opt-in is an
absolute no-go then you are free to override my opinion here. I haven't
Nacked this patch.

> Nobody else is speaking up because the current user base is very small
> and because the idea that anybody has developed against and is relying
> on the current problematic behavior is completely contrived. In
> reality, the behavior surprises people and causes production issues.

I strongly suspect users usually do not follow discussions on our
mailing lists. They only come up later when something breaks and that
is too late. I do realize that this makes the above call for a wider
consensus harder but a lack of upstream bug reports also suggests that
people do not care or simply haven't noticed any issues due to way how
they use the said interface (maybe deeper hierarchies are not that
common).

> > > Can we merge this for
> > > v5.2 please? We still have users complaining about this inconsistent
> > > behavior (the last one was yesterday) and we'd rather not carry any
> > > out of tree patches.
> > 
> > Could you point me to those complains or is this something internal?
> 
> It's something internal, unfortunately, or I'd link to it.
> 
> In this report yesterday, the user missed OOM kills that occured in
> nested subgroups of individual job components. They monitor the entire
> job status and health at the top-level "job" cgroup: total memory
> usage, VM activity and trends from memory.stat, pressure for cpu, io,
> memory etc. All of these are recursive. They assumed they could
> monitor memory.events likewise and were left in the assumption that
> everything was fine when in reality there was OOM killing going on in
> one of the leaves.

This kind of argument has been already mentioned during the discussion
and I understand it.
-- 
Michal Hocko
SUSE Labs

