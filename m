Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 115C7C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 07:36:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF87C2189F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 07:36:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF87C2189F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 788966B0003; Tue,  6 Aug 2019 03:36:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7394B6B0006; Tue,  6 Aug 2019 03:36:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64F2B6B0008; Tue,  6 Aug 2019 03:36:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 184BE6B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 03:36:29 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b33so53196859edc.17
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 00:36:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=vJW7w2hZLSxzg7o+uIAszwA6zwFNEzlTnIB/U1IKy3Y=;
        b=hHZSLqjlwgLILkZs1MjW4VhI+3BKhyBFloqjzuBgqR8o9QS1GQxa5xbEFqj1v9gYxc
         opPWG0iPsRgkaIK5c1LbjWnq357Ru8LhLodh09of9tR6TfAehrJUm1QlzeWdi2lIVjle
         dhflQIF2FWLmR86fgkEDSI0M76OZHkF0w/Szd8nV81yxjGrXq+NK82nV0r8u0qqtYnFx
         iG93mWmMTKUD+5AozR9mbyuihKfUh5+jRj13aOa1EVvwRre0wGzxZeiIevxQcJ8KcePL
         Vd9yRh49TW1W2aWDZlV4C5NJxmNmuPMEZ9I2w48We17sVx58lbXcrg0Ngb4pWUmPcrFv
         PLBA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXlDp33zSF1kp62KcZXkhWcAKWQOxC7/NmeVFc3Rwg8Z6bsw3ld
	wacC54E/wBjFrV/apNIhaV3eLmTzQbQO15BpbX80Xp81LIwefdaAnMOHrzHb7suMYA13g7+3CGN
	knqXhWfGeV7KD8wjGCMd6LxBBO+25reLE5cwgkS3ye+lP7LTJZ6fIfLKlvxgnwS4=
X-Received: by 2002:a17:906:5ad0:: with SMTP id x16mr1846698ejs.23.1565076988592;
        Tue, 06 Aug 2019 00:36:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw3PZH0dJscT4RJo5GK+5I2hh2yNLO5LvL9nQX8J8DHseNWwcLY06sAJUTEeloTFMQRsoVP
X-Received: by 2002:a17:906:5ad0:: with SMTP id x16mr1846669ejs.23.1565076988039;
        Tue, 06 Aug 2019 00:36:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565076988; cv=none;
        d=google.com; s=arc-20160816;
        b=IFkgjvWLNaFUoqurY7DETwSPtyCewkC7GzucIuVAc2/yJInLWjW4X3d0AW6RQ4ifxm
         JhgQhVBSWANxSgTUFQ1o2hVoxPMIJ26BFLSewjeNkOdk7EcXnj7jENUtyRjdumOOVyMV
         E4LGSda41vUC6RVltB3avKcN/9/7w9txLi9OI42HAlyfo7iwf6u+HHvg173cNurgCvQl
         mSNBldQtRsbxz55AUtV90MnFCP91BRbZ1N/wFyLqTOq38f304WutoBJaYCUm5zN6Svk3
         iJ6l0AegRa/w4GO5dqlOG9NzuCytvzuU7j6CkslNlDgCgJicAjJLiYFEvj2eAsV0lm34
         aDhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=vJW7w2hZLSxzg7o+uIAszwA6zwFNEzlTnIB/U1IKy3Y=;
        b=YN8e2/9WI526VsbYqv102hMeEOsmY66U5OESg8ZaIN/e+cTNTr6T+lFD9xGAXJIycL
         yb+mvYJc3u54jKBVJCr+XIUFda8efsdLDCrtPKwHyjvZDoQDfvkEXOpjvltK3w8MtFPj
         bo+MQnqxgCZJ3l8xUNdG9b0M099AnjTHLtHA3b8+0BrotBQ0jAFbiKllo/lcvleLRn1h
         qtgqbEnT885ZFjiFD8/J7rydpWz7I+ONJB0O319EO2XcXDorKr0n4fIzMMTm6VbyPzzS
         EqVAx0dt8esE4wBPDTBouWTHMUBwAQDREm7mko8LEqNXrxtNn/bhGeEZ48eKH4Lp8+2Y
         RUZw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z7si6299748edc.200.2019.08.06.00.36.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 00:36:28 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 922ECAD7F;
	Tue,  6 Aug 2019 07:36:27 +0000 (UTC)
Date: Tue, 6 Aug 2019 09:36:24 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH RFC] mm/memcontrol: reclaim severe usage over high limit
 in get_user_pages loop
Message-ID: <20190806073624.GD11812@dhcp22.suse.cz>
References: <156431697805.3170.6377599347542228221.stgit@buzz>
 <20190729154952.GC21958@cmpxchg.org>
 <20190729185509.GI9330@dhcp22.suse.cz>
 <20190802094028.GG6461@dhcp22.suse.cz>
 <105a2f1f-de5c-7bac-3aa5-87bd1dbcaed9@yandex-team.ru>
 <20190802114438.GH6461@dhcp22.suse.cz>
 <20190806070728.GB11812@dhcp22.suse.cz>
 <c6b2c864-985a-2565-95e7-3af9e3e015f8@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c6b2c864-985a-2565-95e7-3af9e3e015f8@yandex-team.ru>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 06-08-19 10:19:49, Konstantin Khlebnikov wrote:
> On 8/6/19 10:07 AM, Michal Hocko wrote:
> > On Fri 02-08-19 13:44:38, Michal Hocko wrote:
> > [...]
> > > > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > > > index ba9138a4a1de..53a35c526e43 100644
> > > > > --- a/mm/memcontrol.c
> > > > > +++ b/mm/memcontrol.c
> > > > > @@ -2429,8 +2429,12 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
> > > > >    				schedule_work(&memcg->high_work);
> > > > >    				break;
> > > > >    			}
> > > > > -			current->memcg_nr_pages_over_high += batch;
> > > > > -			set_notify_resume(current);
> > > > > +			if (gfpflags_allow_blocking(gfp_mask)) {
> > > > > +				reclaim_high(memcg, nr_pages, GFP_KERNEL);
> > > 
> > > ups, this should be s@GFP_KERNEL@gfp_mask@
> > > 
> > > > > +			} else {
> > > > > +				current->memcg_nr_pages_over_high += batch;
> > > > > +				set_notify_resume(current);
> > > > > +			}
> > > > >    			break;
> > > > >    		}
> > > > >    	} while ((memcg = parent_mem_cgroup(memcg)));
> > > > > 
> > 
> > Should I send an official patch for this?
> > 
> 
> I prefer to keep it as is while we have no better solution.

Fine with me.

-- 
Michal Hocko
SUSE Labs

