Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 789A2C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 07:07:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3CAEA2070C
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 07:07:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3CAEA2070C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CCE246B0006; Tue,  6 Aug 2019 03:07:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C7DD96B0008; Tue,  6 Aug 2019 03:07:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B46736B000A; Tue,  6 Aug 2019 03:07:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 66D336B0006
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 03:07:31 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id o13so53195707edt.4
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 00:07:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=jmsxLe6gA4qo7GiwacLncpeaNPy+mmkmbJLoXVYXSEE=;
        b=tbpJyxX40HSfRkHW9KDF0TRKPmFxnCGe2J40AvG+r0Cujsm+2FfLzneRWe4tQ9m9Ym
         Mdi/xAKCyyHJlqYUsmXubE2Bq6h9RiiEBzKwFVYZAAhO092KY+SBtAZLLDRs5wQyJ3Id
         FEyP5tHKuZzAU260A6efQOssP0GqbctJoelufMFWMAnpVj0e98CopLTUJwFyRapF4e6u
         PE/7+4arElH0TbSR1W3tRUSeIBDtpQ/r6UB6dk2PPBgT9l8C48NFh5VFjEiLCCUVdtZG
         kT4GwcXIAk1nQqDYkkVRIgh6IX62U5YId+Y/saK+FSBKW6+oZWxGe3igqvLfcfn71TXc
         sfqg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXvZFdNRn552bwBWen/7khhQvuuSo0qwZbv/AXiiz9y5Q1XKnIW
	kil76sUCP7N4eBB4qkysZ7AW9559kj0ajIO5+uUGXlmWgZ6r7PmXkjKIBfZ5xyklVkmhjVPqO9u
	zgbqofWT52BawRyn+SlhsgJylYQ4ncmN9fMTz6Fnb6UO1f0RqeQN9x/+hEs6nltQ=
X-Received: by 2002:a17:906:af54:: with SMTP id ly20mr1702578ejb.194.1565075251012;
        Tue, 06 Aug 2019 00:07:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx36c4KoBNDaRf0apXxFfBXpYRIS2Rr5Mhm0pJkrWHTolBrRJ+PNN7hCLjalbIYEymi7pdn
X-Received: by 2002:a17:906:af54:: with SMTP id ly20mr1702558ejb.194.1565075250460;
        Tue, 06 Aug 2019 00:07:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565075250; cv=none;
        d=google.com; s=arc-20160816;
        b=AsN2ZDKeqkAgBIHjI4tG/xzRZMOtMun8BKguG0vbUSGXHbh1ckUnoGyXy53L4K1x/Q
         87c4d7Q8V8rtByLHr6saPal3H2orkqleqhNZUWPfwdPttrnBxITQoQkhszncvI5H3Cs3
         FeMUr90O4IgfRW86ZqHruOgzHmpXNGub+goB7Amigosq9/spVWHtjtbIiJoOHo6rCgvZ
         fRCETzQU48Tar6im/KSaYZcdYyZAuyqqhA7dozlmbNgXLRW0xcaQvJ36qgb4DFURoaYF
         q7lCVGtrSULKEj4ZUPI/YYIpcMlfnPpFUQEr+rGJgsIBXWsYAHJNXzxRpiV3clxzYXKA
         Ci+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=jmsxLe6gA4qo7GiwacLncpeaNPy+mmkmbJLoXVYXSEE=;
        b=Wb2GDzojhoIHR4qPX4nXPFoBWucd8xjPCWX8S+qxFANnGMPGnHFAH9Ryvodve2OhxM
         0TuWbMAUNVMLmQRM9E6H+TaafssEyBO1HYx//5c1/kLUWuz7R+g85PN6epC1uL6Eg//D
         uM2zxhrvvJcZw0INHg3CyaI5BP5HPegEEVdJhvT2zRcfCyt/soyQ1Ch9Jgjf36Q5pMGD
         lC9y1E/M+VH27FJBlj25eDFVSsQ/J4jxX+KazubiLpxEM68Big+DpWRUhBM0PFLuJRS9
         eiXlpZa5xC6zB2uzLqr7FyJreF2NgOXQytlZjKqsEkUz/phc4ypMZ1rJZvct8afgdLFf
         RjKw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s19si26943435ejq.6.2019.08.06.00.07.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 00:07:30 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A6827ADD9;
	Tue,  6 Aug 2019 07:07:29 +0000 (UTC)
Date: Tue, 6 Aug 2019 09:07:28 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH RFC] mm/memcontrol: reclaim severe usage over high limit
 in get_user_pages loop
Message-ID: <20190806070728.GB11812@dhcp22.suse.cz>
References: <156431697805.3170.6377599347542228221.stgit@buzz>
 <20190729154952.GC21958@cmpxchg.org>
 <20190729185509.GI9330@dhcp22.suse.cz>
 <20190802094028.GG6461@dhcp22.suse.cz>
 <105a2f1f-de5c-7bac-3aa5-87bd1dbcaed9@yandex-team.ru>
 <20190802114438.GH6461@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190802114438.GH6461@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 02-08-19 13:44:38, Michal Hocko wrote:
[...]
> > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > index ba9138a4a1de..53a35c526e43 100644
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -2429,8 +2429,12 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
> > >   				schedule_work(&memcg->high_work);
> > >   				break;
> > >   			}
> > > -			current->memcg_nr_pages_over_high += batch;
> > > -			set_notify_resume(current);
> > > +			if (gfpflags_allow_blocking(gfp_mask)) {
> > > +				reclaim_high(memcg, nr_pages, GFP_KERNEL);
> 
> ups, this should be s@GFP_KERNEL@gfp_mask@
> 
> > > +			} else {
> > > +				current->memcg_nr_pages_over_high += batch;
> > > +				set_notify_resume(current);
> > > +			}
> > >   			break;
> > >   		}
> > >   	} while ((memcg = parent_mem_cgroup(memcg)));
> > > 

Should I send an official patch for this?
-- 
Michal Hocko
SUSE Labs

