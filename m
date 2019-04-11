Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25F64C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 12:16:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E07552133D
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 12:16:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E07552133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 835CF6B000A; Thu, 11 Apr 2019 08:16:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BF5C6B000C; Thu, 11 Apr 2019 08:16:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 660D96B000D; Thu, 11 Apr 2019 08:16:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 117EA6B000A
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 08:16:40 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id g1so3006488edm.16
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 05:16:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=edXSCP5OqM8PLr1UPZsTym0h9sgEKE5VTgkryqhvo5g=;
        b=fP+W0aPAXv7eOe+Hxt1WXfI6XjBfUrpYCycOi66fRXNX2DnkHKUOt3jpUWuRqJ+FL9
         B7L6sPPb4hYdQkZIB7uF22AGgkh/H7m0pSeKs6I3XGH/xujKP4B/wa+4OvEPY0C1gE3F
         fld4bG2bxtKqAwtaxWmivAsQBcZDp0l34SE/NHLUq15Yrcmq76Y23f1COHokVTb79Kfu
         GG+EK5hwV9k9+oUoO+7pJAnaBJfGwMt1AKfgjeFz8ciJxVoklktpjmHaH0rnbQDixFaS
         WMmMXN0cT+N+XiRrrtmUGXI2BmDuEEkWQZKdMfuUPOlAmDTMGduIi9ufeU0KIPwjCci5
         sBJw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXevdbXrbrR2gDoN2+dbevFNxGUnhwdR/h6ZWl/un8Xk6vYsfOi
	YHNQVyHBL8dx50pFZIDRAZFa8XtWMn6F+TE4O+QjuSpqXuvI6gUzz2tztPC/R0FE11dgEr2RXdQ
	V+zq5SO3BHezpFax3ZLC2IovaBWSwskluv5CQFNHEtHg1OxhaZ6+d0axbrOI44Qw=
X-Received: by 2002:a05:6402:383:: with SMTP id o3mr31303079edv.173.1554984999627;
        Thu, 11 Apr 2019 05:16:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzy4TtR7Wn0RSwbKKe2bFdT6QSVn5+04lgbSSp60VIcyerMhA5ThcWvRc3ee2S9T/YKoGjE
X-Received: by 2002:a05:6402:383:: with SMTP id o3mr31303035edv.173.1554984998909;
        Thu, 11 Apr 2019 05:16:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554984998; cv=none;
        d=google.com; s=arc-20160816;
        b=e/v7sQpOxWsC3sERkEcO8y4nBHZSjUFcOovLQ2Z9tlKG1I0nirchcN2YjsPr2aTHwG
         1c4ec2FMN7m0Q2HLmzJQ/3XP/BvIqr/eFjp0Ma6+Z80L/L0s3Uz5/v2QFk02WU+li4jB
         9tneCWcfbKKLfhvKufFte7o5cDjyr9Ry/mlIFxKMqZWAB5/PtLhyacfRH3JWkAyqMu7x
         eYUzm+QqsET7lY6uTo76Uy8uUCUynZamKkFzRD68A4GExDyEbnIx5OhOvc0RHYzBf6g+
         J2cAK6Ta7MimZaFz4luS4N4RpzqmeEGYKKuUWtxoedhoDjdIunFVUXpdF49ltuiAr8XS
         9EYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=edXSCP5OqM8PLr1UPZsTym0h9sgEKE5VTgkryqhvo5g=;
        b=TaLUw6t6F6ywFii81La6yrjgzgYE9ppsqv7GVx6IgVhW3ZKeKLIfG3XMLolh+EFOJZ
         k/rqtEMTnt0NLvBeImyXvVkS3kWlUgAKpk4fNbj8Ty+JwUOWjUW6R/SE7ra8FVcTLY0Z
         h47yYGzM2jaiNc34yA9+yotbJpO/UjF/aPUu2oywuXHDp4TFcNUIO0/SuBhlWqiMvPhZ
         c87pE1cg1TblkMaqcmwV0QdnZ0fPoE8/4h6aBjXCE3JSPaKzxknMK6w78LFBGS65FZhY
         oNtUSJ8kVDaqqVuqErqC0qryV6JamNu/zzwNQdvN/TR/skQrnItQTzf+onrYEbNLR1YE
         BKmA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c18si7717183ejo.102.2019.04.11.05.16.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 05:16:38 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 80279AC4C;
	Thu, 11 Apr 2019 12:16:37 +0000 (UTC)
Date: Thu, 11 Apr 2019 14:16:33 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Rik van Riel <riel@surriel.com>
Cc: Suren Baghdasaryan <surenb@google.com>, akpm@linux-foundation.org,
	dancol@google.com, jannh@google.com, minchan@kernel.org,
	penguin-kernel@I-love.SAKURA.ne.jp, kernel-team@android.com,
	rientjes@google.com, linux-kernel@vger.kernel.org,
	willy@infradead.org, linux-mm@kvack.org, hannes@cmpxchg.org,
	shakeelb@google.com, jrdr.linux@gmail.com,
	yuzhoujian@didichuxing.com, joel@joelfernandes.org,
	timmurray@google.com, lsf-pc@lists.linux-foundation.org,
	guro@fb.com, christian@brauner.io, ebiederm@xmission.com
Subject: Re: [Lsf-pc] [RFC 0/2] opportunistic memory reclaim of a killed
 process
Message-ID: <20190411121633.GV10383@dhcp22.suse.cz>
References: <20190411014353.113252-1-surenb@google.com>
 <e1fc2c84f5ef2e1408f6fee7228a52a458990b31.camel@surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e1fc2c84f5ef2e1408f6fee7228a52a458990b31.camel@surriel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 11-04-19 07:51:21, Rik van Riel wrote:
> On Wed, 2019-04-10 at 18:43 -0700, Suren Baghdasaryan via Lsf-pc wrote:
> > The time to kill a process and free its memory can be critical when
> > the
> > killing was done to prevent memory shortages affecting system
> > responsiveness.
> 
> The OOM killer is fickle, and often takes a fairly
> long time to trigger. Speeding up what happens after
> that seems like the wrong thing to optimize.
> 
> Have you considered using something like oomd to
> proactively kill tasks when memory gets low, so
> you do not have to wait for an OOM kill?

AFAIU, this is the point here. They probably have a user space OOM
killer implementation and want to achieve killing to be as swift as
possible.

-- 
Michal Hocko
SUSE Labs

