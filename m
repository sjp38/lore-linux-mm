Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB147C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 15:50:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D56B2067D
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 15:50:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="Cc+rnM3w"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D56B2067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 496288E0009; Mon, 29 Jul 2019 11:50:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 446638E0002; Mon, 29 Jul 2019 11:50:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3838E8E0009; Mon, 29 Jul 2019 11:50:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1973A8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 11:50:01 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id p193so26653820vkd.7
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 08:50:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=uUW0YKHPLieEQydyNjaqE+DPJSP/Cf4fqcZtPwBzjUQ=;
        b=ftc0SqCT3LAcQnw9llM0DfVd2VKINEGFUgGebo+VrelPFwHnpriXQCtTwbQqT/3Wqv
         I2xInSYG89KqLvPghSqn+MwztNiZUSXVjG2q0NRgn6dP4+tYcnDvIWVU68whzkSNdRjT
         Jvcsl4BsahTTZY1+P4+ya6leEx8JF43+uN9vNdkpXd3klyPt6+z1SLrz3itVvrd+ylKl
         ITzJh8Y+ZySKtWaWOmBCdt1z/cWVb78K/8khAWC6MC8lfoDR7awiQXKYTN7CyG+bsXUP
         S8KmBBsChGCfCs1C5tZe1DUEalxpnIvsJkIbngRKU/Som/RiRa3lWvXgvdgClss6TU/G
         3XRA==
X-Gm-Message-State: APjAAAWRPBpMgjEhjTViwnoqVXIHr19KKVtDB5tD0SK9t2vhKm9Hdir9
	JaJ5BY9ocRFWn+f00wITksJSBiVSDI3i6WA6gf6HtoBqYg2QcQo/nj9e0OcSmQP13uhQ94sI46P
	qFAUPbMDB9BzHDNsg5+s+3viGfyrzfVF/UW4I/jZre4j8/H0N+xMzX7i/Iy0c1/zJ9g==
X-Received: by 2002:a67:8907:: with SMTP id l7mr68614670vsd.194.1564415400846;
        Mon, 29 Jul 2019 08:50:00 -0700 (PDT)
X-Received: by 2002:a67:8907:: with SMTP id l7mr68614611vsd.194.1564415400353;
        Mon, 29 Jul 2019 08:50:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564415400; cv=none;
        d=google.com; s=arc-20160816;
        b=nCBRAaZBZvfxP1KqIp3htDzfoBA83tDh0+MGVvTRoLSopEP/4KoPdhST0vxLaOSlE7
         gAsnRutRTTLo8tTuBHWPN9yxn0fG1NJukRVFSks4PNc3L+6G4EeKDHiwD/yVHDXSRLSO
         puXc/11l9RYf2QyowHBmiadYVNJbGwHHVufHokStZwfpfnJ1f1DfCLQp3P4jQ2W/5m/C
         qY1ANmYblzAfMrqxG22YqgQHoGQjCzBkrqfTy81K+NrIohMSt0GsRlq5gGYa0KKkto0K
         VymRye7lMJFHKr/GyHDH815CukLDBtSUyAtixLkdo94BAcuxsBtK/5Lv8nNvcEYbU5jw
         3Qbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=uUW0YKHPLieEQydyNjaqE+DPJSP/Cf4fqcZtPwBzjUQ=;
        b=s7IYEGj7ja9sREvkAGab+d3FI13GsoUbNQ4kRQp04Lv4PsL+iHR3Xlf+UwT58dei9l
         hNwYwBiEwe58QxNW+cgZ3gcMdfuyC2X2jV5pQk3zuxPkAXEOEPm0k0SOhtUPkMhEGO6D
         c46eAVBDfU8LpPIk2UZcVraPwBlTs1t+K3Iq3WJ2DqITYiqByrqUV84s2uuw3zMtOiqI
         7uuIXN4CR252FF1h9r5N2jxC7BoO5xQP1vefLfX4V/nvnY+Gd+0xI+YCk0fp1+1FSLy1
         zgzDrB07R7Sp0o4MkvOmqbQf9wzCf5hFQ6gKpunEm8EeybiMyprZcQD2Q/NN5RZThj+X
         Tccg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=Cc+rnM3w;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k29sor30485837vsj.27.2019.07.29.08.49.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jul 2019 08:49:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=Cc+rnM3w;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=uUW0YKHPLieEQydyNjaqE+DPJSP/Cf4fqcZtPwBzjUQ=;
        b=Cc+rnM3wvWjLyuINuMWXDGs5fxT5e9t10JNduKKSfTicMo308IATLLWRf1HbfpWVFJ
         b9HvoMhkEEadSy05edUEx8sn1mVyofmiYp6O2xYQvx9A1WtU4SuHaPssop3lf5ncDbCt
         yG5gMY4JLtex+4bR+Q44glXssu1lBsGRrlcGVKY1Zanm/FcxXPu9Lpcm8BrKG2Kqswp+
         rb3AJRXbn4R0hDAXhtZXs3XIx2+JoGwvRFnm4k9C4FTS9vMmF8Ya9luCi/wweOUwz+Vp
         ouAIcGKMhFgKox4L1g3oYilw3A/fOpStl9pHs6Z5h8qQlenPlAGWPeZVHxefOnX7b/y2
         zufw==
X-Google-Smtp-Source: APXvYqzvvmRlC370jmHcQF5fxfCKQPBjEkd1dfVOREKA/n9iD4FSeCbNS9niC5SCPNU2sBDZeyzhIA==
X-Received: by 2002:a67:7087:: with SMTP id l129mr68222271vsc.206.1564415393680;
        Mon, 29 Jul 2019 08:49:53 -0700 (PDT)
Received: from localhost (pool-108-27-252-85.nycmny.fios.verizon.net. [108.27.252.85])
        by smtp.gmail.com with ESMTPSA id q15sm25893828vka.44.2019.07.29.08.49.52
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 08:49:53 -0700 (PDT)
Date: Mon, 29 Jul 2019 11:49:52 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	cgroups@vger.kernel.org, Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH RFC] mm/memcontrol: reclaim severe usage over high limit
 in get_user_pages loop
Message-ID: <20190729154952.GC21958@cmpxchg.org>
References: <156431697805.3170.6377599347542228221.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <156431697805.3170.6377599347542228221.stgit@buzz>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jul 28, 2019 at 03:29:38PM +0300, Konstantin Khlebnikov wrote:
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -847,8 +847,11 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  			ret = -ERESTARTSYS;
>  			goto out;
>  		}
> -		cond_resched();
>  
> +		/* Reclaim memory over high limit before stocking too much */
> +		mem_cgroup_handle_over_high(true);

I'd rather this remained part of the try_charge() call. The code
comment in try_charge says this:

	 * We can perform reclaim here if __GFP_RECLAIM but let's
	 * always punt for simplicity and so that GFP_KERNEL can
	 * consistently be used during reclaim.

The simplicity argument doesn't hold true anymore once we have to add
manual calls into allocation sites. We should instead fix try_charge()
to do synchronous reclaim for __GFP_RECLAIM and only punt to userspace
return when actually needed.

