Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C662C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 16:49:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B8B72054F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 16:49:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B8B72054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CFB238E0004; Tue, 12 Mar 2019 12:49:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA8828E0002; Tue, 12 Mar 2019 12:49:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B974D8E0004; Tue, 12 Mar 2019 12:49:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 61B4A8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 12:49:00 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id m25so1360037edd.6
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 09:49:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=+5duUyg2h3TIcoE6yBK501y/vGBGxqa7lpnsuVb7M6s=;
        b=gDBL2OJUEFw/ROw0Erh20CdXACx65cKtAfMewRUiB6Oiyn5HIg0bN4y86ekdWIq1jt
         yvASspFOjtjN2EUVUklwhbYjRnaB7HQyz3PYNHmRFtiBEa860HUHMjGf/RaicQL9xJb5
         jTC/MagqtZPVbiPb0GBmUz9o8Xzs3Q0cWbeqjN4V+cK6R/pjF5x2zsNwQONtwa63Crv6
         NrnKlv8BIiZKjJQ4YLcoX5iw3Urswq1C60A714YtVY7gKO3pEe2Rwaim1hCbBV/XJdIX
         DGw1YzVpTKHyN/02MUS0CYU1Ao4dR0rRq0o6aBnIPiCRjZAQNB4E8IsjP5rY/nk/lWI+
         YCTQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAU4+ceKIzO1RiATML1ZVeDx74WwGyyvkNZO2JLsGOqVMGpEbBEU
	gzf+zKb24FO7AFya/zvUJkVUHPIACSOQH/UaCfaHIaQExwOLxFb2+ZIco0dSzS6sbK5bsKeDard
	suKXWLVH7EpQ0kEi71eIOEtAbrM3IvUE7E2EiDrCvV+hmmx/mRfGWxUbWw81hZF4=
X-Received: by 2002:aa7:ccce:: with SMTP id y14mr4258934edt.160.1552409339969;
        Tue, 12 Mar 2019 09:48:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx9s/wv9G5WcnySmGW38S5fYo96fPK2SHqje358uL2XvgM2khEVBLs0iv35/pBvLIh7VQrQ
X-Received: by 2002:aa7:ccce:: with SMTP id y14mr4258882edt.160.1552409339142;
        Tue, 12 Mar 2019 09:48:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552409339; cv=none;
        d=google.com; s=arc-20160816;
        b=gCX0PDmWypZwI1igTAMle9EZ1bhZZt/QwTp1U/RvD+jpx9mFU5maRRV+/+dKrK59vA
         5OvJzKuNdNtjb/Jk+WVzy21fz8ehTqaq+bCh9lFEyRr3K/3eX0qJ9r8VNanCsKJXkLft
         jBfkHpn9AlTVCrotmt96izIa7YAYQ0JKgWEyexGytugzaHfeFxjpsleLW3Mng0fTdNog
         7GoKTGVQDdGF2NV3hX3PLLQZKzob39vGMmDd3w2GLmusNPA56acy51TC37IoZGD9gntS
         Clm12n8ijFTftZHKT8zWjBlK0oHENvYEB4uh5rNDQEU0tCVckgy9uw+fvf8rYi+S9gdu
         683A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=+5duUyg2h3TIcoE6yBK501y/vGBGxqa7lpnsuVb7M6s=;
        b=07a6+8nNo3RVg/R3VYzV/F2kagam+LVi6YcRcJ/kb3jUhSpbSWJ/N6mUO25jhwaTh1
         8+/jWVO/EfMd5k7R7+HXOC3gdJW1OeCeKfu4mQfzKdGNnzkrJIGYoD4FA2RyKPQUH2Yp
         U9Psi5xzpnKCSfjclRx86veb6GxATwfHfZYtvEALPJ+oxzg1saRplXGGROqxZP8igw12
         3YrTDmOLkKleejAOdiWJFUZxsoowPBejR1l/s7J+tK2rK9LVKnDlNJWM5mmkymGL+YUD
         9oC3dm4/qo1OXXQgMP0WADQknd1Z0zRWxfZrsJJ/Nf7geRZdi+/NmGGi2Jr7AUuLLA7G
         zRfg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y56si2728313edb.18.2019.03.12.09.48.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 09:48:59 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7F914AFE8;
	Tue, 12 Mar 2019 16:48:58 +0000 (UTC)
Date: Tue, 12 Mar 2019 17:48:57 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Sultan Alsawaf <sultan@kerneltoast.com>
Cc: Suren Baghdasaryan <surenb@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Christian Brauner <christian@brauner.io>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, devel@driverdev.osuosl.org,
	linux-mm <linux-mm@kvack.org>, Tim Murray <timmurray@google.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190312164857.GE5721@dhcp22.suse.cz>
References: <20190310203403.27915-1-sultan@kerneltoast.com>
 <20190311174320.GC5721@dhcp22.suse.cz>
 <20190311175800.GA5522@sultan-box.localdomain>
 <CAJuCfpHTjXejo+u--3MLZZj7kWQVbptyya4yp1GLE3hB=BBX7w@mail.gmail.com>
 <20190311204626.GA3119@sultan-box.localdomain>
 <CAJuCfpGpBxofTT-ANEEY+dFCSdwkQswox3s8Uk9Eq0BnK9i0iA@mail.gmail.com>
 <20190312080532.GE5721@dhcp22.suse.cz>
 <20190312163741.GA2762@sultan-box.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190312163741.GA2762@sultan-box.localdomain>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 12-03-19 09:37:41, Sultan Alsawaf wrote:
> On Tue, Mar 12, 2019 at 09:05:32AM +0100, Michal Hocko wrote:
> > The only way to control the OOM behavior pro-actively is to throttle
> > allocation speed. We have memcg high limit for that purpose. Along with
> > PSI, I can imagine a reasonably working user space early oom
> > notifications and reasonable acting upon that.
> 
> The issue with pro-active memory management that prompted me to create this was
> poor memory utilization. All of the alternative means of reclaiming pages in the
> page allocator's slow path turn out to be very useful for maximizing memory
> utilization, which is something that we would have to forgo by relying on a
> purely pro-active solution. I have not had a chance to look at PSI yet, but
> unless a PSI-enabled solution allows allocations to reach the same point as when
> the OOM killer is invoked (which is contradictory to what it sets out to do),
> then it cannot take advantage of all of the alternative memory-reclaim means
> employed in the slowpath, and will result in killing a process before it is
> _really_ necessary.

If you really want to reach the real OOM situation then you can very
well rely on the in-kernel OOM killer. The only reason you want a
customized oom killer is the tasks clasification. And that is a
different story. User space hints on the victim selection has been a
topic for quite while. It never get to any conclusion as interested
parties have always lost an interest because it got hairy quickly.

> > If you design is relies on the speed of killing then it is fundamentally
> > flawed AFAICT. You cannot assume anything about how quickly a task dies.
> > It might be blocked in an uninterruptible sleep or performin an
> > operation which takes some time. Sure, oom_reaper might help here but
> > still.
> 
> In theory we could instantly zap any process that is not trapped in the kernel
> at the time that the OOM killer is invoked without any consequences though, no?

No, this is not so simple. Have a look at the oom_reaper and hops it has
to go through.
-- 
Michal Hocko
SUSE Labs

