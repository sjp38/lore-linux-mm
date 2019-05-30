Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 053B0C46460
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 06:51:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB8C525B88
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 06:51:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB8C525B88
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A1106B0288; Thu, 30 May 2019 02:51:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 450796B0289; Thu, 30 May 2019 02:51:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3668C6B028A; Thu, 30 May 2019 02:51:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DFB976B0288
	for <linux-mm@kvack.org>; Thu, 30 May 2019 02:51:15 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f15so5424676ede.8
        for <linux-mm@kvack.org>; Wed, 29 May 2019 23:51:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=pl46aRszmpdjuU2z6gGkrMXy/xn/vJww6HCwYJJamOU=;
        b=muainVy90xWstQqqQibsuciWeqXYWZhTqXYcskKBq6jf5QIwJWXKluRun0LuIPSpxZ
         kvAByVzTBtB8k3mBBg+0nnaYDWDb1OTOn4gO3pW9IvnB94LcFdBUIShI6j68MmTHBQzZ
         Bn/gQKS0cxmb1K4uGoO0V8SMt1ZhUR56bTtE6nMMoSZchjaUINe8jfK3WUikeYH2ZE8p
         tGNApZzFzZAVOEmRRqceo749/LggXYFOkLf6s0rogrTvpxAYsBwP5tNs9g8ONuA/VJvz
         LkB/cHDaD4gRbhIrg6nQH7gG0BBA5HEbPIp+cGaj8lzJl6NjlmyJaI3icGbDSAsa14S9
         EeKA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXKDkNrrTKP1K77bcNaHuqLyGh3FUjCtPZS1NUI0SGXing0kr3C
	Q1wU1f6h0Y9UL1oB8xBZqWOZXwPbzaC7JxenGIVfW35TCnihcb49S8rok+tEAJA45CBRpzbyYFd
	b5vCsCfO722kxa7sqZVhLXioOoLhhsY5RLY0aNxrS638IiWUFNVkslUyWauSO7b8=
X-Received: by 2002:a17:906:2e58:: with SMTP id r24mr1931351eji.184.1559199075485;
        Wed, 29 May 2019 23:51:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxeSzWL9p/Myg0hppsY1ZiI8QKlYTORbvrXoFrDqF82H/pINvi2h+5bDv9diVKAkPq78Dwi
X-Received: by 2002:a17:906:2e58:: with SMTP id r24mr1931308eji.184.1559199074559;
        Wed, 29 May 2019 23:51:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559199074; cv=none;
        d=google.com; s=arc-20160816;
        b=A/+MVvto67u7eODclUpwGl54xR3TmaiNsN62+5LMa00fVyk5QqXylUNcvoEklBVRhc
         9MHZStG6aD+8SwoZoVMADwP3LQ16E1wfQLIyvMAGkkvT8h1vlHLCFNMbpklcc9CljjcZ
         pSf3GX2DCPmgdFC5FU3N/OFns8h0OrrAkt2SO4a0lxStlSnv1z/J7pSg1le+aH5zayH7
         2xXpZK0v+kFYSeyHk98DF0G98f/359/qvFP7RGQ/5Mrt+zKatU4MF6+eJuSJEaOQoD7s
         S1jZn4X8lzykymI8Cgbscz85BLa2rkc15wKFHypsRc1a3vihILs9+mKL7G4BJ63PtkCW
         I1vA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=pl46aRszmpdjuU2z6gGkrMXy/xn/vJww6HCwYJJamOU=;
        b=0HxCBhnoFk/Qlg4V92kGBZUBmbZ2WFSJPGM4aGZE3B4rx59exD85P+G39+Ee1pqvya
         oF7hpKR2iEJtNIsv691qsxl9hVSw8RuwqFrxPvRSLO5GccMd+/5WO1LgzIIOHlFr9Ngb
         4VUFAwTueNhjqKDbHz5gR4A+x4F47MrcWlTyoCTcz7J2X7jRCuxXHfKGk3FkYWy1r4p0
         3K/wDoIYE06cTVS8hZi6Iw2mKMc1Qw4CEpG7nlFM83o6EXJCYbHc2AYsmMqe8hy90FjQ
         YzDDzGaRZ2miRLkLd+BaFUwecav5MNugF4J2GPDUVyuUOjRVAadlIA6TcceZO4fbzlOJ
         4CLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t22si1258240ejq.16.2019.05.29.23.51.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 23:51:14 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 15D2EACF8;
	Thu, 30 May 2019 06:51:14 +0000 (UTC)
Date: Thu, 30 May 2019 08:51:11 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Chris Down <chris@chrisdown.name>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>,
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH REBASED] mm, memcg: Make scan aggression always exclude
 protection
Message-ID: <20190530065111.GC6703@dhcp22.suse.cz>
References: <20190228213050.GA28211@chrisdown.name>
 <20190322160307.GA3316@chrisdown.name>
 <20190530061221.GA6703@dhcp22.suse.cz>
 <20190530064453.GA110128@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190530064453.GA110128@chrisdown.name>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 29-05-19 23:44:53, Chris Down wrote:
> Michal Hocko writes:
> > Maybe I am missing something so correct me if I am wrong but the new
> > calculation actually means that we always allow to scan even min
> > protected memcgs right?
> 
> We check if the memcg is min protected as a precondition for coming into
> this function at all, so this generally isn't possible. See the
> mem_cgroup_protected MEMCG_PROT_MIN check in shrink_node.

OK, that is the part I was missing, I got confused by checking the min
limit as well here. Thanks for the clarification. A comment would be
handy or do we really need to consider min at all?

> (Of course, it's possible we race with going within protection thresholds
> again, but this patch doesn't make that any better or worse than the
> previous situation.)

Yeah.

With the above clarified. The code the resulting code is much easier to
follow and the overal logic makes sense to me.

Acked-by: Michal Hocko <mhocko@suse.com>

-- 
Michal Hocko
SUSE Labs

