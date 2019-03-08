Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB5B0C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 11:54:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6893920851
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 11:54:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6893920851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C2778E0004; Fri,  8 Mar 2019 06:54:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 171098E0002; Fri,  8 Mar 2019 06:54:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0656D8E0004; Fri,  8 Mar 2019 06:54:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A45A98E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 06:54:16 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id h37so9633938eda.7
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 03:54:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=kTE20E9w5ymNyMXxey3xf6ZiaKrmqWAm2aX3DRAXCBk=;
        b=CW5KAUDgQrGYkbZgy9jOXhNxXjMImAUz0HeP4Pay7Y390iEJoHMj5xrXJmVzidJfG+
         6KzCEFYcFsbh1WWM+HofNxQivrIr1nNkuusllA1SYnV1l8Jgob3m3KpSHgpuoZBFe5yA
         tK2A02FzSKr0oLMTdWYPP9jJnAv1omDTECTxT3vxNf4u0/tS14XGd7+lmueFTrWEZrrV
         ROBPqaM//6+IwmZWI0b7HjiuS8qdmjcSukOz7Cj6aZVDhmzAuSYx7SE3k+oJYHChVaiL
         qbRS0G5TFKVUkkBTUJ6vOD9pFH5D8po1Gqt2dj/8hLCfdKMKgjmP8uz638lVvuXOj+2h
         fHcg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXEjyxoh5M3Ra32p1GI/dMJeXzfKbohMKMUDpzdzCrNpQHJiM+Z
	yyH88vCxQgbDvxmGp7/OYlpU9LPif0tWIeSQfVVd0fVVx9SeHdth/8Mtdz2xAb6+I3x3Qwk2aCv
	A1H+PM5mQmRDs96VXOUkG2HGV/Qcv33VAh2Hzhi6Cib8EnPsBWPabwz7aSAgOpSc=
X-Received: by 2002:a50:ba59:: with SMTP id 25mr33219738eds.260.1552046056172;
        Fri, 08 Mar 2019 03:54:16 -0800 (PST)
X-Google-Smtp-Source: APXvYqwahgWobtZhHgWJ9zBxlnnR1AQB3woEIXO6K9XLW2SEV4mend1TaFsZhruz9VGgHpwaVfox
X-Received: by 2002:a50:ba59:: with SMTP id 25mr33219680eds.260.1552046055230;
        Fri, 08 Mar 2019 03:54:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552046055; cv=none;
        d=google.com; s=arc-20160816;
        b=hh4Cs4B76yfLsXm5R4SPerob/1+kNrWKXjWbHalVy8WxN/CDK/I71rfKIVeON+qdRM
         T/conKuFMFytMxT6cFrV4vRca1rvAF8/NA7l4JvYJXO/qF6BbOY3//8AR3EkyinJfT7Y
         Ma0PDmVZHMPw/HKjfq8CTE5OEe2Lm6/xhITBLPFXbDubzv8QsdgwsR/GeOzSyGvcyis9
         2+FFt8lu6bFzDpPg8kyBTwtvx0ghxYtjwSylFDVUSGGquCUiwcXntUK9CROsv9JFhSQS
         oprjg43I8TaRQmZsuCFfai9zYJBvSfu+LZpgzaLl9G38EL5G4ZpYm20FMZXtjuX0BOZp
         zTqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=kTE20E9w5ymNyMXxey3xf6ZiaKrmqWAm2aX3DRAXCBk=;
        b=dXQ/GE+23NqFduVr22fexLnm0gz6yQMzZhjIqA2n6ngqd+4sIMvkgc8aNfAQZxbvCC
         jeo8jRJ247V43ckH+CES7go6hMnzyPSxJTPQy4vsC/hPZlI6i+ZRVEMXIVwNiU8gcIuL
         JycFi1xDgPmToDyrxEajqQwaH2VvIxoeY9M50P9ph5qes5TtWphUMMpwTwrPXG8rbXOY
         kydBa7EjJWAJI+b/f2qwk/fzouQ9gImtDXjuGEBQcUpb6nmpJV9hNIgtU/fOY2ptea0l
         4c7hEKIuXINP60sbRjhMCvdWp7C0S5HK3+zvHAWMKSyAaXPSeqXOdwwl7hWnxWCv+qWE
         WUIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gx17si2868807ejb.28.2019.03.08.03.54.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 03:54:15 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C4C27ADD8;
	Fri,  8 Mar 2019 11:54:14 +0000 (UTC)
Date: Fri, 8 Mar 2019 12:54:13 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
Subject: Re: [PATCH] mm,oom: Teach lockdep about oom_lock.
Message-ID: <20190308115413.GI5232@dhcp22.suse.cz>
References: <1552040522-9085-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190308110325.GF5232@dhcp22.suse.cz>
 <0ada8109-19a7-6d9c-8420-45f32811c6aa@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0ada8109-19a7-6d9c-8420-45f32811c6aa@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Cc Petr for the lockdep part - the patch is
http://lkml.kernel.org/r/1552040522-9085-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp]

On Fri 08-03-19 20:29:46, Tetsuo Handa wrote:
> On 2019/03/08 20:03, Michal Hocko wrote:
> > On Fri 08-03-19 19:22:02, Tetsuo Handa wrote:
> >> Since we are not allowed to depend on blocking memory allocations when
> >> oom_lock is already held, teach lockdep to consider that blocking memory
> >> allocations might wait for oom_lock at as early location as possible, and
> >> teach lockdep to consider that oom_lock is held by mutex_lock() than by
> >> mutex_trylock().
> > 
> > I do not understand this. It is quite likely that we will have multiple
> > allocations hitting this path while somebody else might hold the oom
> > lock.
> 
> The thread who succeeded to hold oom_lock must not involve blocking memory
> allocations. It is explained in the comment before get_page_from_freelist().

Yes this is correct.

> > What kind of problem does this actually want to prevent? Could you be
> > more specific please?
> 
> e.g.
> 
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3688,6 +3688,7 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
>          * attempt shall not depend on __GFP_DIRECT_RECLAIM && !__GFP_NORETRY
>          * allocation which will never fail due to oom_lock already held.
>          */
> +       kfree(kmalloc(PAGE_SIZE, GFP_NOIO));
>         page = get_page_from_freelist((gfp_mask | __GFP_HARDWALL) &
>                                       ~__GFP_DIRECT_RECLAIM, order,
>                                       ALLOC_WMARK_HIGH|ALLOC_CPUSET, ac);
> 
> 
> Since https://lore.kernel.org/lkml/20190308013134.GB4063@jagdpanzerIV/T/#u made me
> worry that we might by error introduce such dependency in near future, I propose
> this change as a proactive protection.

OK, that makes sense to me. I cannot judge the implementation because I
am not really familiar with lockdep machinery. Could you explain how it
doesn't trigger for all other allocations?

Also why it is not sufficient to add the lockdep annotation prior to the
trylock in __alloc_pages_may_oom?

-- 
Michal Hocko
SUSE Labs

