Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33DEAC32750
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 09:35:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03246217D4
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 09:35:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03246217D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 855376B0003; Fri,  2 Aug 2019 05:35:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7DE856B0005; Fri,  2 Aug 2019 05:35:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A5536B0006; Fri,  2 Aug 2019 05:35:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1AF6A6B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 05:35:11 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id w25so46549861edu.11
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 02:35:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=3D3mT8Hdds27dRq1XumagADjxjteQlLAsabw6LIVu+8=;
        b=WF/72p1Hn/9NtK0axfS7C1ze/XicFQdiRbFFO61D9OIOEI8VzFPZ5uXEMX3BODKB1h
         Rftm+hgMCL7S5ALMSQ9oY0uDHSB3EzO7I7yQxti82+D6CsfC0scVVB39yY8CQrC6ovOR
         v5iaW85H2Dv6QG9DJlUKakn9o/TzKUG6pJryYv2xkVaJBLVO8FUFRSA4zhN1SKmdI9G3
         ohLfKP53pH1Hq0jDBdol5AGml3ceLuHEm9ETtGW9SDwOm6se8iBfzXuiNibT4Bj97/zq
         +mWZNC+Bt1Wi6VgPIZ+OzyfqlUuw47hgd5lSH/83v3S6SuBUSfo1GzCkc65LxJGiy+E5
         trGA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXK2tiZBW1LodW+FbH6LbKUpaTjDPX3NPqeAY+JyyqiSZB05jwW
	hYOo3B4nsgPIpwAaxmgRS1C79mLdnU53ieEKDs4cx+Ts0xLIYfz9SP3tJvhNMOa/tYTeZT8c2nn
	LAuwCFQjavhtwRERyjPRZeBXpumjfy3rUo5b6loBEFJrTlpelBMLbUSs3lUynHW8=
X-Received: by 2002:aa7:d404:: with SMTP id z4mr117959340edq.131.1564738510666;
        Fri, 02 Aug 2019 02:35:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyEUF8XeeS851u7bMLH4+o9IxfgeS9fSI4Go07tBhO53o3Xbo3GkHHHj6um98S2c2Moo89I
X-Received: by 2002:aa7:d404:: with SMTP id z4mr117959294edq.131.1564738509771;
        Fri, 02 Aug 2019 02:35:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564738509; cv=none;
        d=google.com; s=arc-20160816;
        b=lvgpJPOwhHsBcy8Ym9s311Y2wAEdJ1vvPn5dnSnA36AmXskM5YrCJkmwDOrhGAqMvq
         X503SHxz0+x/gJUwMFu2X9LaQ9wfvNWmCpUAdsBex2Mi4vCOCm0+Xq7pn2CP497ZoQhO
         f3jeOnryw9Nrh/pEVLKpdhO7czqAnq3yR6zHIdbPKDwhQvNEzNEUmMCQo6T6RuzR3Eq0
         2LXq40W4XVNFVV2M2gXgnqZZwCWgtfp970VSnlhNPw2r3YnoV/dWJV+xJbWfgC6W6O3/
         pA3REuGl7JHQBQLBeIjZzcizSKyiStZNo+xA0vxLCJbjxp2zi7sTwp+gA8GiQY/f1GsE
         ce3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=3D3mT8Hdds27dRq1XumagADjxjteQlLAsabw6LIVu+8=;
        b=Tp9KF/Mmjd9EBq+5T6GN1ZoDS8eyhRtNyMY4UNp257eG1BgdNHteit/ZSWXHJONS3q
         ZOeTSISyPY3fTm/5uu+AhDwbHZsRrEWnts+55HIxLz2JcURlBoG7Q8rWirs31GU0j1nK
         nsxu2ngMjIKYT+OecBToD8MIelESr0IaP/2lvck8IHUZG0DfloIPnQR2RFilVnqUv0kr
         CG2MWjGfSuHnml2xQ1mUxjvW2YijhV5X9KvFGTMCuGm0Lq/YJMPVMDukSYQ+fbav2LpE
         PMg60vH4VBiRyAj1OWb4HtqMZn6gXqJ/sfnl3Ijsw/BGUVm6Nqb7N7dnR+XSDL1g3rYn
         HkuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k28si27463024ede.131.2019.08.02.02.35.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 02:35:09 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 12CB4AC7F;
	Fri,  2 Aug 2019 09:35:09 +0000 (UTC)
Date: Fri, 2 Aug 2019 11:35:07 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <shy828301@gmail.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	cgroups@vger.kernel.org, Vladimir Davydov <vdavydov.dev@gmail.com>,
	Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH RFC] mm/memcontrol: reclaim severe usage over high limit
 in get_user_pages loop
Message-ID: <20190802093507.GF6461@dhcp22.suse.cz>
References: <156431697805.3170.6377599347542228221.stgit@buzz>
 <20190729091738.GF9330@dhcp22.suse.cz>
 <3d6fc779-2081-ba4b-22cf-be701d617bb4@yandex-team.ru>
 <20190729103307.GG9330@dhcp22.suse.cz>
 <CAHbLzkrdj-O2uXwM8ujm90OcgjyR4nAiEbFtRGe7SOoY_fs=BA@mail.gmail.com>
 <20190729184850.GH9330@dhcp22.suse.cz>
 <CAHbLzkp9xFV2sE0TdKfWNRVcAwaYNKwDugRiBBoEKx6A_Hr3Jw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHbLzkp9xFV2sE0TdKfWNRVcAwaYNKwDugRiBBoEKx6A_Hr3Jw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 01-08-19 14:00:51, Yang Shi wrote:
> On Mon, Jul 29, 2019 at 11:48 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Mon 29-07-19 10:28:43, Yang Shi wrote:
> > [...]
> > > I don't worry too much about scale since the scale issue is not unique
> > > to background reclaim, direct reclaim may run into the same problem.
> >
> > Just to clarify. By scaling problem I mean 1:1 kswapd thread to memcg.
> > You can have thousands of memcgs and I do not think we really do want
> > to create one kswapd for each. Once we have a kswapd thread pool then we
> > get into a tricky land where a determinism/fairness would be non trivial
> > to achieve. Direct reclaim, on the other hand is bound by the workload
> > itself.
> 
> Yes, I agree thread pool would introduce more latency than dedicated
> kswapd thread. But, it looks not that bad in our test. When memory
> allocation is fast, even though dedicated kswapd thread can't catch
> up. So, such background reclaim is best effort, not guaranteed.
> 
> I don't quite get what you mean about fairness. Do you mean they may
> spend excessive cpu time then cause other processes starvation? I
> think this could be mitigated by properly organizing and setting
> groups. But, I agree this is tricky.

No, I meant that the cost of reclaiming a unit of charges (e.g.
SWAP_CLUSTER_MAX) is not constant and depends on the state of the memory
on LRUs. Therefore any thread pool mechanism would lead to unfair
reclaim and non-deterministic behavior.

I can imagine a middle ground where the background reclaim would have to
be an opt-in feature and a dedicated kernel thread would be assigned to
the particular memcg (hierarchy).
-- 
Michal Hocko
SUSE Labs

