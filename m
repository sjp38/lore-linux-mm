Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D15E1C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 16:20:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 910D320880
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 16:20:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="Kw/tJPZQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 910D320880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 08EA98E0025; Wed, 20 Feb 2019 11:20:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 03F158E0002; Wed, 20 Feb 2019 11:20:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E70BB8E0025; Wed, 20 Feb 2019 11:20:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id BBF298E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 11:20:26 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id r8so15628555ywh.10
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 08:20:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=C070tjgZJxeeM7qSOkI80GMDNtIZkLi+xqFiicAZtLg=;
        b=WMPFiM62Ni+WApTSggVzp1PDoRYagwlI4y5v2P1B0JLaJj5FubZHlIcTACl3vVn3fH
         Gp/32E3ptYMvDyudXzU2aZ3/GzfoVkO6HoQWOTsFohhOuRDIZDEwiPKqxNWLlNTZIoox
         JlRfL5cSK0XlejR4DpquuNETv9FRunxH6vQK8GrA9sZlTdJAaFuOgM42aHUM9DLNMg00
         VBwWIOajB/JV5XDBIYgQqEhnYoh61p9jEr9N4z+XaDKHmOKCW3YGpqVaLjHR/U7BQUQM
         hSNK/YAwDg75TtJTSWdEUw8uweyH4U/s/La6mlUydy1tKFJ9n8jJ3cAJUqrsM6wlWTeq
         FEvQ==
X-Gm-Message-State: AHQUAuanGz+lfp3NN8IYc/bPIpKidBBWBDPSqFUYeLePokL2E3RueIwK
	r62YhpYjInlYLLbNYtEHrulr/S04TdNF2JcK59uNU/zxvuNPjvKSnDZt5o/9CHNwdlvjSb9hXcp
	0JKIaJU6xgHPLbfPkRy4MAP6oMy+3+GvLpocoboI5/dolPKDr9QBg2UwdBORCSVORUFH00v8T64
	5ACvKKqKLB9uCM2SbydgCV2oICJmywaVmsK2YZLS5fcNDptqNs8POBQPrtyqVHvVWModKAjEEyD
	AGHfx1Dy+svGYaOWTVAu4vpGSXV+jmiP0rpmD/slg9NItJfLG8iDtYINW6eRPMljAhfHrmaNqCf
	A+xgq+9BGYaW+s+gQNH5iSzvw9x/W9YWI1O7NGlZNpxqgtt9x/Hf7DFhZ5FGSqq+ICwKU+Fo83o
	U
X-Received: by 2002:a81:3dd5:: with SMTP id k204mr28411462ywa.502.1550679626364;
        Wed, 20 Feb 2019 08:20:26 -0800 (PST)
X-Received: by 2002:a81:3dd5:: with SMTP id k204mr28411419ywa.502.1550679625773;
        Wed, 20 Feb 2019 08:20:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550679625; cv=none;
        d=google.com; s=arc-20160816;
        b=l4u4ua1APkyNvEr+tUkL6o1HfXJOI23pUCZe9/SPPj3KsFV06rjRcaMwub+Jhk/WmL
         JT61EhF7KqQbbqL/Bl5O/zZkwXHfigJFjTG8EPD7iItbXxk7G1NocCpc5dpB1VtZ1I7K
         +b8l+PX+u/MzCrtCM6NT9aE9qJ4o1SWJ2OfMvcYkpDLGgGV4Sbt5Iu0IRc2hczZmOJuD
         ivoLTy7fF1gzwJmLCzivDljYTd3uxwtsbB41/zdQ3JhbLT5s1TSCHxp1bN4bXifN3TQm
         +df/pOwgJhmOP6va4tv1E190CZQd94sOSuJ8k5L2u6CS4cgCrwAVcnnSknoowclqgBQa
         KX/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=C070tjgZJxeeM7qSOkI80GMDNtIZkLi+xqFiicAZtLg=;
        b=aaCxheeROFhOvs6zq/PdGfxImtyW58m3FFGODeCjpnlJPIymjmGjDX/qADy6QQAV95
         Ps2elcmFrUzzDA+9zCVjD5XZmtlDRGlMc3kFlnBH6yLqu/S+fBdg+QAEAJn1jBMcZvrc
         M+AVOee2qLj31x5sAbxC6cp+r0vfJ/iX1x5jQqFiF8y45WWM2IPa3PUxnPJK32n09HTO
         gVbvjVLatcg0Tp0RGRhe7LqkHxGbrHSteJPrn8llrYFpnAj+bAUKWPPgiKVx/vRoCZSx
         kLkfjzj1e0+JC7PN8yuXJAggVhGTWtz5Ox5KHG/Itf5FvokdE9WT33g/aUF3U/MMOhfX
         UlXA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b="Kw/tJPZQ";
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n137sor5258546yba.166.2019.02.20.08.20.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Feb 2019 08:20:23 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b="Kw/tJPZQ";
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=C070tjgZJxeeM7qSOkI80GMDNtIZkLi+xqFiicAZtLg=;
        b=Kw/tJPZQVwsHlVFpahkttIFQss0Eipp5XPVuDSea8auNp+jXZgZaQInhaP5RWYuzjf
         gvUf9FmsQQ/fuztL1dblZUSAIUR9TgRJBm7m3zr51zMcEYfKKrZ10Hw9uP7YX43YmdLX
         C/AyIPk5gH9TKLYM0mpLa/RLhcU0aepE36Yg5IYCUy9wNLFJTt+XT/EOK6v1O29O5e8V
         G1kX9JR4zHR+7EMAHgfpnhYMsl/BIwPJjJtVp3gxZPiXiN5PSSof6zUKdXlU5ADVVxxc
         MEuwxE16uexTQU3v82WA6ZmU9pGBHLooUNGoDqBWwRzYFHYRN7IJjuPgtIXo4fubEPVD
         rJBQ==
X-Google-Smtp-Source: AHgI3IZN1W/wbKuBXgVLSt798kyCnFIfqASvAzckD4HrIGMC9bsKeYF5LF5F7AKF7bKQac8nfIa2MA==
X-Received: by 2002:a25:c887:: with SMTP id y129mr29225474ybf.398.1550679622984;
        Wed, 20 Feb 2019 08:20:22 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::7:9eba])
        by smtp.gmail.com with ESMTPSA id x82sm39758ywd.11.2019.02.20.08.20.21
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Feb 2019 08:20:22 -0800 (PST)
Date: Wed, 20 Feb 2019 11:20:21 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Roman Gushchin <guro@fb.com>,
	"lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"riel@surriel.com" <riel@surriel.com>,
	"dchinner@redhat.com" <dchinner@redhat.com>,
	"guroan@gmail.com" <guroan@gmail.com>,
	Kernel Team <Kernel-team@fb.com>
Subject: Re: [LSF/MM TOPIC] dying memory cgroups and slab reclaim issues
Message-ID: <20190220162021.GB12866@cmpxchg.org>
References: <20190219071329.GA7827@castle.DHCP.thefacebook.com>
 <20190220024723.GA20682@dastard>
 <20190220055031.GA23020@dastard>
 <20190220072707.GB23020@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190220072707.GB23020@dastard>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 06:27:07PM +1100, Dave Chinner wrote:
> freeable = 1
> 
> ratio	4.15	priority	4.16	4.18		new
> 1:100	  1	   12		0	batch		1
> 1.32	  1	    9		0	batch		1
> 1:12	  1	    6		0	batch		1
> 1:6	  1	    3		0	batch		1
> 1:1	  1	    1		1	batch		1

> @@ -479,7 +479,16 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
>  
>  	total_scan = nr;
>  	if (shrinker->seeks) {
> -		delta = freeable >> priority;
> +		/*
> +		 * Use a small non-zero offset for delta so that if the scan
> +		 * priority is low we always accumulate some pressure on caches
> +		 * that have few freeable objects in them. This allows light
> +		 * memory pressure to turn over caches with few freeable objects
> +		 * slowly without the need for memory pressure priority to wind
> +		 * up to the point where (freeable >> priority) is non-zero.
> +		 */
> +		delta = ilog2(freeable);

The idea makes sense to me, but log2 fails us when freeable is
1. fls() should work, though.

> +		delta += freeable >> priority;
>  		delta *= 4;
>  		do_div(delta, shrinker->seeks);
>  	} else {

