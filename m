Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 072CEC433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 10:50:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C874120818
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 10:50:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C874120818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 65C216B0003; Tue,  6 Aug 2019 06:50:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 60B076B0008; Tue,  6 Aug 2019 06:50:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D2FD6B000A; Tue,  6 Aug 2019 06:50:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 018F76B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 06:50:08 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id w25so53537583edu.11
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 03:50:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=hGUDvscigyvIQucy1kRIUgv1nHN01/lGzdk20VBl5RU=;
        b=jzAAcBFxMxwd16OdpRu3cqsaal2cRg5VhPQJpbRXhygIaA2tKmoA10VrwhNk0U8XU8
         1WI5tphsRIsUQFS+iP45so2sokmKHl6Uoe7IPCK6msSKjR3hZPrg5Ho/a8QPQ0pj7VlK
         D0qR/9aSvF+trANzst6fUBaymIi1csPBaI1VZlVFgR6mhq6VrOW0ZlSAVZH8GaO+iJxG
         mFvWNqCKAWKs2xUHvN86dnW0Gews/RCDtmLSa4BOqUAZZd2e8rvAr5mauVAxMzlUx8nX
         QwXOZwHaGkJDdCjSapW/SNCMd8JaAGDdBvqhrHvl5T4SYDN06Vad1XfgrUFtckDbemwd
         8Mlw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUXhqRTqjwUN9EWoOMeKp0rmS3J9juXQ8McJ5KKxIj13EZT9pPB
	mje4lExjSI22x2TaHVC0x1cKsOUUkecXJcN5QP/Nlcm4j0uFbXGtwS9hds5LtPim9ct4q9fEmvt
	5DsaIwL/iuaI9BSOUOmgyuvh7rU2sKf1oX1TJM3VFGnEL3mbfmCg9k5Sy4YWuAGM=
X-Received: by 2002:a50:ac4a:: with SMTP id w10mr3102583edc.33.1565088607569;
        Tue, 06 Aug 2019 03:50:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzp0EWzSva0B9bHxvV9P/Y3D9giRJlwuoFCu/5st9oI9YA2bNMZCeK6k3IQR9+rfKMEqVx8
X-Received: by 2002:a50:ac4a:: with SMTP id w10mr3102537edc.33.1565088606909;
        Tue, 06 Aug 2019 03:50:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565088606; cv=none;
        d=google.com; s=arc-20160816;
        b=vvKjw8aGu+pLArAORHBJgncAB0Dj1yIyyy8jxtUmJhqIthqDj6hRFLgMJQsrq3qPCf
         3d4lXD96V/dYpZALxkoyRDGRXp3/SII9zjVudQ/bT+EQgyfuuPkiSnhO3sjJLI5ge08/
         /f+vrQmpHuKuq3elUuRJoGbeLYUiApao58sBDJoDpdVCWVY5VtEp1ibL88PBtd/Wxh/J
         gkyqLIvKvQkpVW3Z2t8Fpa57c309RQGKxSsSbX3RNcmYPaR+ATkp894KDslalEbN3nue
         17MWB4nFwq9GD5axNi9kW+ZtB3vYNAkwgGAaC1GZypRZiZruTsV5oe+WfdQbbf6d8B26
         C3ig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=hGUDvscigyvIQucy1kRIUgv1nHN01/lGzdk20VBl5RU=;
        b=qIaa0og5lyo2v8QnpObVsieoJUWixZs/8zwxFyJTM689OdEbDhpX05L2E+RgX4z46d
         rZC0dRcs+TO3fIHcq8kQuL9McVsnA3HH+L1Q+rMl5gEct+mnGPmYCWNqpltkowfEK4H8
         /2pCpP6vxpq+fjgaC68fsBW4cufinUAxvRUs2f1QYG5nT8nfkG08UpFSlEuFh45QWmnO
         bSuEHc3S9WQSIl4B7q7z7YFh8AlOoL54VAYHu1VHa4zjkOvamrw4GKm3XHkhxolE0KKl
         Y0N2FbsUpxevcL3z9i18X5klg58NjJF/QROsEGcx0UmoFwgXus/YnsXFZUk0P0vuFlqA
         d4lg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c25si19028713ejx.201.2019.08.06.03.50.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 03:50:06 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D2D8FAFCC;
	Tue,  6 Aug 2019 10:50:05 +0000 (UTC)
Date: Tue, 6 Aug 2019 12:50:04 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Masoud Sharbiani <msharbiani@apple.com>,
	Greg KH <gregkh@linuxfoundation.org>, hannes@cmpxchg.org,
	vdavydov.dev@gmail.com, linux-mm@kvack.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: Possible mem cgroup bug in kernels between 4.18.0 and 5.3-rc1.
Message-ID: <20190806105004.GS11812@dhcp22.suse.cz>
References: <20190802191430.GO6461@dhcp22.suse.cz>
 <A06C5313-B021-4ADA-9897-CE260A9011CC@apple.com>
 <f7733773-35bc-a1f6-652f-bca01ea90078@I-love.SAKURA.ne.jp>
 <d7efccf4-7f07-10da-077d-a58dafbf627e@I-love.SAKURA.ne.jp>
 <20190805084228.GB7597@dhcp22.suse.cz>
 <7e3c0399-c091-59cd-dbe6-ff53c7c8adc9@i-love.sakura.ne.jp>
 <20190805114434.GK7597@dhcp22.suse.cz>
 <0b817204-29f4-adfb-9b78-4fec5fa8f680@i-love.sakura.ne.jp>
 <20190805142622.GR7597@dhcp22.suse.cz>
 <56d98a71-b77e-0ad7-91ad-62633929c736@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56d98a71-b77e-0ad7-91ad-62633929c736@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 06-08-19 19:26:12, Tetsuo Handa wrote:
> On 2019/08/05 23:26, Michal Hocko wrote:
> > On Mon 05-08-19 23:00:12, Tetsuo Handa wrote:
> >> On 2019/08/05 20:44, Michal Hocko wrote:
> >>>> Allowing forced charge due to being unable to invoke memcg OOM killer
> >>>> will lead to global OOM situation, and just returning -ENOMEM will not
> >>>> solve memcg OOM situation.
> >>>
> >>> Returning -ENOMEM would effectivelly lead to triggering the oom killer
> >>> from the page fault bail out path. So effectively get us back to before
> >>> 29ef680ae7c21110. But it is true that this is riskier from the
> >>> observability POV when a) the OOM path wouldn't point to the culprit and
> >>> b) it would leak ENOMEM from g-u-p path.
> >>>
> >>
> >> Excuse me? But according to my experiment, below code showed flood of
> >> "Returning -ENOMEM" message instead of invoking the OOM killer.
> >> I didn't find it gets us back to before 29ef680ae7c21110...
> > 
> > You would need to declare OOM_ASYNC to return ENOMEM properly from the
> > charge (which is effectivelly a revert of 29ef680ae7c21110 for NOFS
> > allocations). Something like the following
> > 
> 
> OK. We need to set current->memcg_* before declaring something other than
> OOM_SUCCESS and OOM_FAILED... Well, it seems that returning -ENOMEM after
> setting current->memcg_* works as expected. What's wrong with your approach?

As I've said, and hoped you could pick up parts for your changelog for
the ENOMEM part, a) oom path is lost b) some paths will leak ENOMEM e.g.
g-u-p. So your patch to trigger the oom even for NOFS is a better
alternative I just found your ENOMEM note misleading and something that
could improve.
-- 
Michal Hocko
SUSE Labs

