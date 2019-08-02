Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2DB3C32750
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 17:14:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D81D20B7C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 17:14:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D81D20B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B92156B0008; Fri,  2 Aug 2019 13:14:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B42346B000A; Fri,  2 Aug 2019 13:14:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A31F66B000D; Fri,  2 Aug 2019 13:14:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 57B0D6B0008
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 13:14:56 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id o13so47413893edt.4
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 10:14:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=X12x9BnxM0B8km5jGc2V+cDz3hgEs2G1reaDM4FgC2o=;
        b=Nv0bFSZLapHTzIiqahc/etxO1qmm0dqnhHs4UfRx7D4Nc/jYPE0UUfUIjZ4jUVfpQA
         B4OoQVBv/QUqir4cLqdjuEA3knTcCHULF3SA+5J6j/Y78W6BHF0ThhZC4tRq7B5fT7ZB
         QgRFKG1wRQKHLFurYKhKQ9s6/gcJpCXtyzgau2SvNnxbIfepzV+IeyHPT6Pw3LLTOC9Y
         JLyXaNFq0fMeWfYf6Siw5BzXdjTidhbO97AmW40gS41sBngnziX+COGkcJKanUKUAWR4
         lDLzH/f9LZK6i7hcTb0Rc2WS8g2Do1VFFKh8rwPHo0JU0Pyqa0H0R4lQHx0x6QvyvWni
         UlVw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUyG2jese1NLIWEu6D3TtAF9khLI9ilM226+3HLTCOhnk8W2vHz
	nOqq/hI+H4LEUyg3csd4Ey37ycNhGSK/qObla8Yrfk78Ls9ID5uCeHzIfYOEOzeJmkfVdJWZF7f
	aQlgtPNxRJCHFWWTW2J3NQN36bLYIBsx+s1K7HzT2Mn9H6nZaLO6Ou9gZxl92S7c=
X-Received: by 2002:a50:900d:: with SMTP id b13mr55863513eda.289.1564766095831;
        Fri, 02 Aug 2019 10:14:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzThjZilqWOK3+T40faTncftLVtuupEGGVU03ltjbwcLnC01tu8SWVWJs9m55T8qmv0lukn
X-Received: by 2002:a50:900d:: with SMTP id b13mr55863439eda.289.1564766094821;
        Fri, 02 Aug 2019 10:14:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564766094; cv=none;
        d=google.com; s=arc-20160816;
        b=HcTX54tge4365bnoySeQPvPrNpMebMBnnzCwlowjSrr8f968/exhQzPY46EkZhh/xd
         keG1mAtIGj02IAWk3nxV2ndViS7DeXGDA0ZcJhys2tMcPOnod6kUDR/BYI72dkXVcbZj
         hryErt4mNsWtlnSbGYyEC1JqvMoHeEErs64GSWll4zHlQGjU1radcy+WMfvwt1NVj4UX
         joAvniJD1524PuU5WvgO96YBTOlX8KartekrqnwNm7pvFEJBUHP7sFk9lapGFVdDycD7
         GV7sZhuwfkLjksYMjkGh7VlHJ76t/la2rHmAar2vWrBNyg285hSeedmr5zlRUVmBVNZz
         TMtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=X12x9BnxM0B8km5jGc2V+cDz3hgEs2G1reaDM4FgC2o=;
        b=RLLfHlQShocQJM44JLP3UZccV28uIvTWtTpBh8sr3d6gBkFx8sWaJbn2DKLMIHlX/g
         0lcSWqaohDxcDdQkHmeZFuSDRszuMi1sOxBHofIcxTg4vAH98VJrbKQSCnXk17ljBOtK
         omXodl3A9/RsLfDFIflTYJd3OLVRO3UtVPRpWogxVE5Cj8xHb6Q/FDlz8LlJuDvtpXaE
         K3x7dcoZzmEyCmZrtyz101xS8X1lWitonOlaNSZ9U6qvgQa0m+I3tPu4Vg7PavPozTHQ
         eejmKCG3CSKkOcGw2Sl528BOALuFywiRkWKTzDI90JsDH5XfH7ZWaKyBuu4/rM/lTJcD
         UNLA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o4si23127177ejn.27.2019.08.02.10.14.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 10:14:54 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E9D3EACC6;
	Fri,  2 Aug 2019 17:14:53 +0000 (UTC)
Date: Fri, 2 Aug 2019 19:14:51 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Kernel Team <Kernel-team@fb.com>
Subject: Re: [PATCH] mm: memcontrol: switch to rcu protection in
 drain_all_stock()
Message-ID: <20190802171451.GN6461@dhcp22.suse.cz>
References: <20190801233513.137917-1-guro@fb.com>
 <20190802080422.GA6461@dhcp22.suse.cz>
 <20190802085947.GC6461@dhcp22.suse.cz>
 <20190802170030.GB28431@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190802170030.GB28431@tower.DHCP.thefacebook.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 02-08-19 17:00:34, Roman Gushchin wrote:
> On Fri, Aug 02, 2019 at 10:59:47AM +0200, Michal Hocko wrote:
> > On Fri 02-08-19 10:04:22, Michal Hocko wrote:
> > > On Thu 01-08-19 16:35:13, Roman Gushchin wrote:
> > > > Commit 72f0184c8a00 ("mm, memcg: remove hotplug locking from try_charge")
> > > > introduced css_tryget()/css_put() calls in drain_all_stock(),
> > > > which are supposed to protect the target memory cgroup from being
> > > > released during the mem_cgroup_is_descendant() call.
> > > > 
> > > > However, it's not completely safe. In theory, memcg can go away
> > > > between reading stock->cached pointer and calling css_tryget().
> > > 
> > > I have to remember how is this whole thing supposed to work, it's been
> > > some time since I've looked into that.
> > 
> > OK, I guess I remember now and I do not see how the race is possible.
> > Stock cache is keeping its memcg alive because it elevates the reference
> > counting for each cached charge. And that should keep the whole chain up
> > to the root (of draining) alive, no? Or do I miss something, could you
> > generate a sequence of events that would lead to use-after-free?
> 
> Right, but it's true when you reading a local percpu stock.
> But here we read a remote stock->cached pointer, which can be cleared
> by a remote concurrent drain_local_stock() execution.

OK, I can see how refill_stock can race with drain_all_stock. I am not
sure I see drain_local_stock race because that should be triggered only
from drain_all_stock and only one cpu is allowed to do that. Maybe we
might have scheduled a work from the previous run?

In any case, please document the race in the changelog please. This code
is indeed tricky and a comment would help as well.

-- 
Michal Hocko
SUSE Labs

