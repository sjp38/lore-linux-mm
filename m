Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9FF9C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 15:51:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 826C92166E
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 15:51:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="MbCgM+uu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 826C92166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18F426B0276; Tue, 28 May 2019 11:51:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 140CC6B0279; Tue, 28 May 2019 11:51:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 006F06B027A; Tue, 28 May 2019 11:51:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id BE02D6B0276
	for <linux-mm@kvack.org>; Tue, 28 May 2019 11:51:40 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d7so14262034pgc.8
        for <linux-mm@kvack.org>; Tue, 28 May 2019 08:51:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=dsL/8BpLj54WzcwU9lA3tyWUUF9Wxnm/30yw4mZ1tyw=;
        b=YlhrXrnfu4C1RNCfWdv0+6AVIDSdLA3oj9lolyz9Hbe/v7wTcM+LxJ8TWeQ3v3JTzZ
         bx7FCSB3sLWkFcGcExk5ErGlHvD/1Lu4pA/Gfvm8rodmQ/oJ49B639rAezAkLB7V84HI
         v8mCmoCnUlpPUr5ja/hpuxw6ocan3Ti6E6aPEQLJY8nsjVkAg0BgS6QdS9a8rjoKXA1z
         vzAUOJo+E60U4WffF0AoNaNoi9DBpqYvEJbGKNC4RkbEZIu2XgyQuPixxown24ZAd4L/
         yX3vOoBhbo5fp0rPjwPvsTodJkjvStn29V8Y83coP/9B+DKGsg19VveWcxTr/sRdSiMx
         7MmA==
X-Gm-Message-State: APjAAAV8qK+aFXIScvh0r8DQvnepzl5z/BjXIvq2rBDnd/m76xF5jT1f
	rHI0xV7a6dLTdTOE7WDBlPADk1Eh7+9fktaTeEsXXHXoVsHhZrzeE4h6OaEK2e8YOSFBu8CW3Cz
	fD0QSRL+783R2MW9veZHgZvZId7dy6repndChZlvjAXpB2EShTG/OAZZ+4QHWGeiwsg==
X-Received: by 2002:a17:90a:ac04:: with SMTP id o4mr6831148pjq.134.1559058700338;
        Tue, 28 May 2019 08:51:40 -0700 (PDT)
X-Received: by 2002:a17:90a:ac04:: with SMTP id o4mr6831058pjq.134.1559058699588;
        Tue, 28 May 2019 08:51:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559058699; cv=none;
        d=google.com; s=arc-20160816;
        b=d+k7DPqmJb36QyKpI8OE32QG3rQNMOy9/dKZM7ij2weREqQMto+PZQKL/aG9KSuWsv
         S1rFMhQkpj9C3R5ljnZ6NnyATuWcEeOwxtc6QuMUfYc1JCxllcQGBQXsJ8i+whTi/N8W
         HMc02oJJlxrr+1tl1bfteMlZKnuEloCebVqD93Si6yxBTx94fk+MnRbo1sZRxytEWrN4
         xgriA+3UgKFTEKHLCWb2MLaKWouWFrBGS//yngdT30lJrZLvXzPu52TnaPSZ6iTuKlxd
         ZP9wM/ayK9xBr7z4nNeCOpudJAnwxxf7q03ZwMD1jAxEEbH5JWDSvgxnKM/mC+pV64GF
         0LFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=dsL/8BpLj54WzcwU9lA3tyWUUF9Wxnm/30yw4mZ1tyw=;
        b=tWPHA2jOqToKEBy9/HQPHPfFx/YMqCOvT1buwDRUMUaxpc2F3YELMiTcWqdvwCdmbS
         TZIXSu6m0/6AhkJg03bUNtuL30R6qQyVZEqlUxdpSnD32Xaz5tZIwsx+bilRlzJfuYiO
         d1hp+50sNZzdKL4g89wFwIbWa+NUNZHN1IxeOrsZxrvdRS6A4mA8Hc7gaGugv1kdcU/D
         hYXWwXRCirMSaQSp3/Zto94Gzr/zPmASAcx95xa+bM/RxM6N1vGhOC3iyV/rDzef35HG
         AGbwz6Tn6TCpzxrnzycZQIBn59cDzcOsJHsIpQDJTdLcfa8XPA1NrDQJiq80Aeqo7zVx
         347A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=MbCgM+uu;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b36sor17749199plb.26.2019.05.28.08.51.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 08:51:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=MbCgM+uu;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=dsL/8BpLj54WzcwU9lA3tyWUUF9Wxnm/30yw4mZ1tyw=;
        b=MbCgM+uuboSRTMuXJWeTUpgN2WFc5/X4Dc4fFWWLthvlCgFt+H/q0c7MBnqyRO7Z73
         w7T0dnWfCYPRON17hleGt5B//BaJJ6P+/svHaSMANSgZFw4vDArgF7z9xMnQXaa6t1dO
         04htcAMNkhBSLk8WJByTHg5qLbgRJIRtYzPiCo4TYXjLU44z5ybaQ8J6GQu4WgKUV3d2
         jshy7wZUxxJDCiA37j8Ddy/fCvVbsApXG4DSLEjIEyQ85zf041ZF18M69u9hcckGBRkm
         1ryDB+ODoSp4BBE1iTWsrO4LN+YTnvwGe8/vzwMvAwNjIL6/Zh9sRGlzcvWo0U8K+hf4
         oghw==
X-Google-Smtp-Source: APXvYqyCPuhVHIxRFHyQfClQ2dTMU+08Qh2WIkGk1uZKDPtC7EX9dh0rLthtc16TUF6CW08MeVEZeQ==
X-Received: by 2002:a17:902:b615:: with SMTP id b21mr72986281pls.12.1559058696744;
        Tue, 28 May 2019 08:51:36 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1234])
        by smtp.gmail.com with ESMTPSA id k2sm2903202pjl.23.2019.05.28.08.51.35
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 May 2019 08:51:35 -0700 (PDT)
Date: Tue, 28 May 2019 11:51:34 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, daniel.m.jordan@oracle.com, mhocko@suse.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH REBASED 1/4] mm: Move recent_rotated pages calculation to
 shrink_inactive_list()
Message-ID: <20190528155134.GA14663@cmpxchg.org>
References: <155290113594.31489.16711525148390601318.stgit@localhost.localdomain>
 <155290127956.31489.3393586616054413298.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155290127956.31489.3393586616054413298.stgit@localhost.localdomain>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 18, 2019 at 12:27:59PM +0300, Kirill Tkhai wrote:
> @@ -1945,6 +1942,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  		count_memcg_events(lruvec_memcg(lruvec), PGSTEAL_DIRECT,
>  				   nr_reclaimed);
>  	}
> +	reclaim_stat->recent_rotated[0] = stat.nr_activate[0];
> +	reclaim_stat->recent_rotated[1] = stat.nr_activate[1];

Surely this should be +=, right?

Otherwise we maintain essentially no history of page rotations and
that wreaks havoc on the page cache vs. swapping reclaim balance.

