Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7407BC06510
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 13:51:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 238CB2063F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 13:51:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 238CB2063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 662146B0005; Tue,  2 Jul 2019 09:51:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 611288E0003; Tue,  2 Jul 2019 09:51:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D9328E0001; Tue,  2 Jul 2019 09:51:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id F39666B0005
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 09:51:51 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y24so19584462edb.1
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 06:51:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/BKfOgON0ZnyHjQdXoZ+uZX0P+k8TZ9Lj6GkqyWswoI=;
        b=FNwvy2Z8vLqEHFU8VzH26AnT0kcn7OimljCh7BXkkuuLATO4rJpfuw+Ifnqo2GL+lh
         zv23YYIwmdTbvvJYNxTBt6ksMMh1moNASYbNFj/YFyT3YCpbaDGHvwbGTYsMGwRejeJs
         ly6kLxjqFY5/PZgK3j0KO6uq5hM4p02g3rjv7MPYMqek+7o0ZRr4Yv1mCwOwGUmakPm0
         o5M1Osz8WBzURTc7mueZXvjtD9xEdD+4LVvrplscs9Mr6yXrd3WZhzJ84LbpK/gPRIFk
         dKu7/2+CKoEkn8FyEJxu6pvE/r4J/XrSvvaSZD91+ITnKxAYmoFxOm4jNLne5lW3wn22
         fDQQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWJ1eBVzO2s+Rs5HGb5bUjCznbuxkKWU3SYRNcXJSzRHSH9FYAi
	cDfNnws5KDMWK3/7FeB7Ao9qiu6u2KCcTqoVsohxQ/oIU/jSx7TVPKNOxjeOtW2z7NTiIeemhbf
	dosGlOOvo3AbVtOWRZDPaMLmAcA2daIpDd/N4t1W0IiE5zmk+Lu9oQa7JZf/5SZA=
X-Received: by 2002:a17:906:ad86:: with SMTP id la6mr28639437ejb.43.1562075511557;
        Tue, 02 Jul 2019 06:51:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLpAL0ZWFP41spWKv/1Dwio2F4uVmsEXbBlqoAwifPMSrUSUi7A/FbOJMwGC8a6lXfgdVC
X-Received: by 2002:a17:906:ad86:: with SMTP id la6mr28639358ejb.43.1562075510470;
        Tue, 02 Jul 2019 06:51:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562075510; cv=none;
        d=google.com; s=arc-20160816;
        b=We7+QTrYPGVlTdbCNi4e4PaqXseGklY4t/eDMInhx5Cc9/T+QhRODNs0OGXMhjQeSu
         9H2GSOklizAJD0xcoFbOTkSyyj4HXZZ9VBb3LuFbIYDr9xnx1R46tgr3IcmNaguyTzbM
         Kx9FTgb059i76oZ04QhK+4uiCNYqEEwXyClkf9NcjPafeTk/Z2wykwyTMBhkL4wj0+uA
         qHAH+B3hP+Fzr8u5O9rSOUOef1CpKKdMWogJFEBlwvPcWkRhyyDtfVS3k9lTiziXU/Df
         8hkAl0Vocn8ot+uUjWdoXkZDO457mMIkv3wdRDJj3HEZHo5rNVRIG4/XJXo8guYRSVel
         cNGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/BKfOgON0ZnyHjQdXoZ+uZX0P+k8TZ9Lj6GkqyWswoI=;
        b=Ym2+m2wpm57p2R2xtuR+czdu3/RJynqwrr9iQA0SiLRuAS6JYFywN/tt1rnaAukyPl
         Mg/B91ByrNv/9VHu8sJP7q0TFPOX4Zc1GYv9oS03vL0gdrq1I+VMtilYg9bMwqNTQqTo
         1FuHPZ5W2ZO2phOkhfd0NBeESwCdq3iUVBM5Nhro2yTGG6YrbF9sjrepnYiylkwT7x+X
         ltpiQ6dtSt80pbx3TRh0cTVG3yi/p6Honi7/s/tt31jtVftTtNWfTTpIZsyuQ4bAOVlk
         I9/XmCjs3jrJVryHPMsWz2uYhjpFHUrogWjb6x09QCc5G1jxGcWKvPdvP5BPN9BNulRA
         nqXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g25si6968155ejc.69.2019.07.02.06.51.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 06:51:50 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A69B1B622;
	Tue,  2 Jul 2019 13:51:49 +0000 (UTC)
Date: Tue, 2 Jul 2019 15:51:48 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org
Subject: Re: [PATCH] mm: mempolicy: don't select exited threads as OOM victims
Message-ID: <20190702135148.GF978@dhcp22.suse.cz>
References: <1561807474-10317-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190701111708.GP6376@dhcp22.suse.cz>
 <15099126-5d0f-51eb-7134-46c5c2db3bf0@i-love.sakura.ne.jp>
 <20190701131736.GX6376@dhcp22.suse.cz>
 <ecc63818-701f-403e-4d15-08c3f8aea8fb@i-love.sakura.ne.jp>
 <20190701134859.GZ6376@dhcp22.suse.cz>
 <a78dbba0-262e-87c5-e278-9e17cf9a63f7@i-love.sakura.ne.jp>
 <20190701140434.GA6376@dhcp22.suse.cz>
 <20190701141647.GB6376@dhcp22.suse.cz>
 <0d81f46e-0b5f-0792-637f-fa88468f33cf@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0d81f46e-0b5f-0792-637f-fa88468f33cf@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 02-07-19 22:19:27, Tetsuo Handa wrote:
> On 2019/07/01 23:16, Michal Hocko wrote:
> > Thinking about it some more it seems that we can go with your original
> > fix if we also reorder oom_evaluate_task
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index f719b64741d6..e5feb0f72e3b 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -318,9 +318,6 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
> >  	struct oom_control *oc = arg;
> >  	unsigned long points;
> >  
> > -	if (oom_unkillable_task(task, NULL, oc->nodemask))
> > -		goto next;
> > -
> >  	/*
> >  	 * This task already has access to memory reserves and is being killed.
> >  	 * Don't allow any other task to have access to the reserves unless
> > @@ -333,6 +330,9 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
> >  		goto abort;
> >  	}
> >  
> > +	if (oom_unkillable_task(task, NULL, oc->nodemask))
> > +		goto next;
> > +
> >  	/*
> >  	 * If task is allocating a lot of memory and has been marked to be
> >  	 * killed first if it triggers an oom, then select it.
> > 
> > I do not see any strong reason to keep the current ordering. OOM victim
> > check is trivial so it shouldn't add a visible overhead for few
> > unkillable tasks that we might encounter.
> > 
> 
> Yes if we can tolerate that there can be only one OOM victim for !memcg OOM events
> (because an OOM victim in a different OOM context will hit "goto abort;" path).

You are right. Considering that we now have a guarantee of a forward
progress then this should be tolerateable (a victim in a disjoint
numaset will go away and other one can go ahead and trigger its own
OOM).
 
> Thinking again, I think that the same problem exists for mask == NULL path
> as long as "a process with dying leader and live threads" is possible. Then,
> fixing up after has_intersects_mems_allowed()/cpuset_mems_allowed_intersects()
> judged that some thread is eligible is better.

This is getting more and more hair for something that is not really
clear to be an actual problem. Don't you think?

> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index d1c9c4e..43e499e 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -109,8 +109,23 @@ static bool oom_cpuset_eligible(struct task_struct *start,
>  			 */
>  			ret = cpuset_mems_allowed_intersects(current, tsk);
>  		}
> -		if (ret)
> -			break;
> +		if (ret) {
> +			/*
> +			 * Exclude dead threads as ineligible when selecting
> +			 * an OOM victim. But include dead threads as eligible
> +			 * when waiting for OOM victims to get MMF_OOM_SKIP.
> +			 *
> +			 * Strictly speaking, tsk->mm should be checked under
> +			 * task lock because cpuset_mems_allowed_intersects()
> +			 * does not take task lock. But racing with exit_mm()
> +			 * is not fatal. Thus, use cheaper barrier rather than
> +			 * strict task lock.
> +			 */
> +			smp_rmb();
> +			if (tsk->mm || tsk_is_oom_victim(tsk))
> +				break;
> +			ret = false;
> +		}
>  	}
>  	rcu_read_unlock();
>  

-- 
Michal Hocko
SUSE Labs

