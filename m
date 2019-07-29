Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39AC2C76186
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 18:55:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08D8521655
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 18:55:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08D8521655
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 962748E0005; Mon, 29 Jul 2019 14:55:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8EBFA8E0002; Mon, 29 Jul 2019 14:55:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7DADC8E0005; Mon, 29 Jul 2019 14:55:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2DB878E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 14:55:12 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b12so38780909eds.14
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 11:55:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=hLZTlZdeqz/EdF4H9Q3XU6OxO5W0ahZJon+kTGG46T0=;
        b=rP/Nyy/puZBp5QlUz469ulUizOhYAcdxUNPXYUxnm++jPM9DQn8McZZMis0sKIQKKt
         SroJJThv4EG2WbRlvqcVyu2jS9tiaE9qu46nXErgiv9xkm1wxnwcNGDV/PUUNfPfoq4l
         cMaFmtbBb0UqkQmr+tLFhrMH+/oc8q/uibcwnhgUbjLg0uYSr8HWZ+Bn17JEFPzXknAd
         cKJ7h0pije5fg70zq5WC02mWv75Pcp3sqmdTRgIf6ts6QcM8tLeoLUdgqA8XwPXHDQve
         td1DSklqN4z+k3dWXfkSomlvFkyt6oiBq5h2E9ByansVF+Rx2MWiRKPjQuA7YHPLZscg
         nuxg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWtxK+LZui9ajPa3mS7dAX3iv0QPq9Qkw974P+3YF4gqXsXZF7s
	JBxnlJUpXIjNhLd02xrur0JJOCLJusLbQX8hcZWPlUnmOw5oROv65LsgkKaAVMyEU15pNuQK6u4
	HvLo+E9R78x58nwKhbJd6+bhIZ8fV3ZFycOOKT3uaAA46W378xARS128ztcn0O4w=
X-Received: by 2002:a50:f7c6:: with SMTP id i6mr96984741edn.51.1564426511741;
        Mon, 29 Jul 2019 11:55:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxaz3YjoO+PzkggmMxJGc4LE8g1cYcDJVLuR6CAZx0AsLXl3XqinikIuMYkkr5Y7TFLVi4A
X-Received: by 2002:a50:f7c6:: with SMTP id i6mr96984701edn.51.1564426511083;
        Mon, 29 Jul 2019 11:55:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564426511; cv=none;
        d=google.com; s=arc-20160816;
        b=mg+62CAv5IRXOx49jH8y1YPM2p4OaGlll+v213mGEUYxJORbRw3a5YXU2ozJ0YQHzT
         bOSlBg3zcPaX+esb8sWJEZzln3bATOTwLe2RkeZoelesyCpO0QGDjMyaLCxdi56rPyi2
         gfTsU8Z1HywRcBUFLTC0Haa6mcpG0RRpRUDTb/f2UJL5HfrVl9lHpmRIEIDU3GymG0PX
         x7tjS8N+ksjlE9EYx2b7jIRLJC9AxrajCEKlmTMotgI+LOHtZmtUKBFHX4aF61X0d0zs
         V0PMVhM716iWt/H/CQHX86kumn1T4Hfbd93/QcYTs+hVsfV987q8DY9ZYawrx1uo8p8o
         Z1iA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=hLZTlZdeqz/EdF4H9Q3XU6OxO5W0ahZJon+kTGG46T0=;
        b=uA+HNWTAcKOZu5acOOi2tLVjmUDtv+IX84fuEnZCgiOFfaMcFUTReMlfOzqLsEJsZ4
         HPmc7+KeCENJ+4erXsEyrCSHfqqnUf0QG+em54WtAv8uICz6hUSzYuxze2FGuw0yduDT
         pBKJZfz4vl4A4wQxMHyxqreJZCF18C/+R+p9aHmApuwRzj7h0q/XJ8dNNxlmVMQ4MgPd
         KYvn5Q1i44sRoqRSjiywnJYLg5ixM1uc5ItkHXTDb3Kbx9XJLU1iG9yF77iXfEBgeStV
         pT8LLGD/gtaKrzgS4kZZFB4r0eFlqC8IRGxC88sJeEeU/icLi6GTjMaqeEGTzSQUSsMx
         UWGA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o5si15404402ejb.204.2019.07.29.11.55.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 11:55:11 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 40BB2AD43;
	Mon, 29 Jul 2019 18:55:10 +0000 (UTC)
Date: Mon, 29 Jul 2019 20:55:09 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH RFC] mm/memcontrol: reclaim severe usage over high limit
 in get_user_pages loop
Message-ID: <20190729185509.GI9330@dhcp22.suse.cz>
References: <156431697805.3170.6377599347542228221.stgit@buzz>
 <20190729154952.GC21958@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190729154952.GC21958@cmpxchg.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 29-07-19 11:49:52, Johannes Weiner wrote:
> On Sun, Jul 28, 2019 at 03:29:38PM +0300, Konstantin Khlebnikov wrote:
> > --- a/mm/gup.c
> > +++ b/mm/gup.c
> > @@ -847,8 +847,11 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
> >  			ret = -ERESTARTSYS;
> >  			goto out;
> >  		}
> > -		cond_resched();
> >  
> > +		/* Reclaim memory over high limit before stocking too much */
> > +		mem_cgroup_handle_over_high(true);
> 
> I'd rather this remained part of the try_charge() call. The code
> comment in try_charge says this:
> 
> 	 * We can perform reclaim here if __GFP_RECLAIM but let's
> 	 * always punt for simplicity and so that GFP_KERNEL can
> 	 * consistently be used during reclaim.
> 
> The simplicity argument doesn't hold true anymore once we have to add
> manual calls into allocation sites. We should instead fix try_charge()
> to do synchronous reclaim for __GFP_RECLAIM and only punt to userspace
> return when actually needed.

Agreed. If we want to do direct reclaim on the high limit breach then it
should go into try_charge same way we do hard limit reclaim there. I am
not yet sure about how/whether to scale the excess. The only reason to
move reclaim to return-to-userspace path was GFP_NOWAIT charges. As you
say, maybe we should start by always performing the reclaim for
sleepable contexts first and only defer for non-sleeping requests.

-- 
Michal Hocko
SUSE Labs

